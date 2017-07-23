-- Data Service
-- Crazyman32
-- February 3, 2017

--[[
	
	Server:
	
		DataService:Set(player, key, value)
		DataService:Get(player, key)
		DataService:Flush(player)
		DataService:FlushKey(player, key)
		DataService:FlushAll()
		DataService:FlushAllConcurrent()
		
		DataService:SetGlobal(key, value)
		DataService:GetGlobal(key)
		
		DataService:SetCustom(dataStoreName, dataStoreScope, key, value)
		DataService:GetCustom(dataStoreName, dataStoreScope, key)
		DataService:FlushCustom(dataStoreName, dataStoreScope, key)
		DataService:FlushAllCustom(dataStoreName, dataStoreScope, key)
		
		DataService:BindToClose(callbackFunction)
	
	
	Client:
	
		DataService:Get(key)
	
--]]



local DataService = {
	Client = {};
}

local SCOPE = "PlayerData"
local AUTOSAVE_INTERVAL = 60

local NAME_SCOPE_KEY_FORMAT = "name=%s;scope=%s"

local Cache-- = require(script:WaitForChild("Cache"))

local playerCaches = {}
local customCaches = {}
local globalCache

local boundToCloseFuncs = {}


local function GetPlayerCache(player)
	local cache = playerCaches[player]
	if (not cache) then
		if (player.UserId > 0) then
			cache = Cache.new(tostring(player.UserId), SCOPE)
		else
			-- Guest cache (not linked to DataStore):
			cache = Cache.new()
		end
		playerCaches[player] = cache
	end
	return cache
end


local function GetCustomCache(name, scope)
	local nameScopeKey = NAME_SCOPE_KEY_FORMAT:format(name, scope)
	local cache = customCaches[nameScopeKey]
	if (not cache) then
		cache = Cache.new(name, scope)
		customCaches[nameScopeKey] = cache
	end
	return cache
end


function DataService:Set(player, key, value)
	GetPlayerCache(player):Set(key, value)
end


function DataService:Get(player, key)
	return GetPlayerCache(player):Get(key)
end


function DataService:SetGlobal(key, value)
	globalCache:Set(key, value)
end


function DataService:GetGlobal(key)
	return globalCache:Get(key)
end


function DataService:SetCustom(name, scope, key, value)
	GetCustomCache(name, scope):Set(key, value)
end


function DataService:GetCustom(name, scope, key)
	return GetCustomCache(name, scope):Get(key)
end


function DataService:Flush(player)
	GetPlayerCache(player):FlushAll()
end


function DataService:FlushKey(player, key)
	GetPlayerCache(player):Flush(key)
end


function DataService:FlushCustom(name, scope, key)
	GetCustomCache(name, scope):Flush(key)
end


function DataService:FlushAllCustom(name, scope, key)
	GetCustomCache(name, scope):FlushAll()
end


function DataService:FlushAll()
	for player,cache in pairs(playerCaches) do
		cache:FlushAll()
	end
	for _,cache in pairs(customCaches) do
		cache:FlushAll()
	end
	globalCache:FlushAll()
end


function DataService:FlushAllConcurrent()
	local numCaches = 0
	local numFlushed = 0
	for _ in pairs(playerCaches) do
		numCaches = (numCaches + 1)
	end
	for _,cache in pairs(customCaches) do
		numCaches = (numCaches + 1)
	end
	for player,cache in pairs(playerCaches) do
		spawn(function()
			cache:FlushAllConcurrent()
			numFlushed = (numFlushed + 1)
		end)
	end	
	for _,cache in pairs(customCaches) do
		spawn(function()
			cache:FlushAll()
			numFlushed = (numFlushed + 1)
		end)
	end
	globalCache:FlushAll()
	while (numFlushed < numCaches) do wait() end
end


function DataService:BindToClose(func)
	assert(type(func) == "function", "Argument #1 must be a function")
	boundToCloseFuncs[#boundToCloseFuncs + 1] = func
end


function DataService:AutoSaveLoop()
	while (not self.GameClosing) do
		self:FlushAll()
		wait(AUTOSAVE_INTERVAL)
	end
end


function DataService.Client:Get(player, key)
	return self.Server:Get(player, key)
end


function DataService:Start()
	
	self.GameClosing = false
	
	local function FireBoundToCloseCallbacks()
		local numBinded = #boundToCloseFuncs
		local numCompleted = 0
		local maxWait = 20
		local start = tick()
		for _,func in pairs(boundToCloseFuncs) do
			coroutine.wrap(function()
				func()
				numCompleted = (numCompleted + 1)
			end)()
		end
		while (numCompleted < numBinded and (tick() - start) < maxWait) do wait() end
	end
	
	-- Flush cache:
	local function PlayerRemoving(player)
		if (self.GameClosing) then return end
		self:Flush(player)
		wait(5)
		playerCaches[player] = nil
	end
	
	local function GameClosing()
		self.GameClosing = true
		FireBoundToCloseCallbacks()
		self:FlushAllConcurrent()
	end
	
	game.Players.PlayerRemoving:Connect(PlayerRemoving)
	
	game:BindToClose(GameClosing)
	
	delay(AUTOSAVE_INTERVAL, function()
		self:AutoSaveLoop()
	end)
	
end


function DataService:Init()
	Cache = self.Modules.DataStoreCache
	globalCache = Cache.new("global", "global")
end


return DataService