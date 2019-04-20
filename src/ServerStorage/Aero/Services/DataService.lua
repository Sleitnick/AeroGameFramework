-- Data Service
-- Crazyman32
-- February 3, 2017

--[[
	
	Server:
		PLAYER DATA METHODS:
	
			DataService:Set(player, key, value)
			DataService:Get(player, key)
			DataService:Remove(player, key)
			DataService:OnUpdate(player, key, callback)
			DataService:Flush(player)
			DataService:FlushKey(player, key)
			DataService:FlushAll()
			DataService:FlushAllConcurrent()
		GLOBAL DATA METHODS:
				
			DataService:SetGlobal(key, value)
			DataService:GetGlobal(key)
			DataService:RemoveGlobal(key)
			DataService:OnUpdateGlobal(key, callback)
			DataService:FlushGlobal(key)
			DataService:FlushAllGlobal()
		CUSTOM DATA METHODS:
		
			DataService:SetCustom(name, scope, key, value)
			DataService:GetCustom(name, scope, key)
			DataService:RemoveCustom(name, scope, key)
			DataService:OnUpdateCustom(name, scope, key, callback)
			DataService:FlushCustom(name, scope, key)
			DataService:FlushAllCustom(name, scope, key)
		
		GAME CLOSING CALLBACK:
			DataService:BindToClose(callbackFunction)
		EVENTS:
			DataService.PlayerFailed(player, method, key, errorMessage)
			DataService.GlobalFailed(method, key, errorMessage)
			DataService.CustomFailed(name, scope, method, key, errorMessage)
		
	
	Client:
	
		DataService:Get(key)
		DataService.Failed(method, key, errorMessage)
	
--]]



local DataService = {
	Client = {};
}

local SCOPE = "PlayerData"
local AUTOSAVE_INTERVAL = 60

local NAME_SCOPE_KEY_FORMAT = "name=%s;scope=%s"

local PLAYER_FAILED_EVENT = "PlayerFailed"
local GLOBAL_FAILED_EVENT = "GlobalFailed"
local CUSTOM_FAILED_EVENT = "CustomFailed"
local CLIENT_FAILED_EVENT = "Failed"

local Cache

local playerCaches = {}
local customCaches = {}
local globalCache

local boundToCloseFuncs = {}


function DataService:GetPlayerCache(player)
	local cache = playerCaches[player]
	if (not cache) then
		if (player.UserId > 0) then
			cache = Cache.new(tostring(player.UserId), SCOPE)
		else
			-- Guest/offline cache (not linked to DataStore):
			cache = Cache.new()
		end
		playerCaches[player] = cache
		cache.Failed:Connect(function(method, key, errMsg)
			self:FireEvent(PLAYER_FAILED_EVENT, player, method, key, errMsg)
			self:FireClientEvent(CLIENT_FAILED_EVENT, player, method, key, errMsg)
		end)
	end
	return cache
end


function DataService:GetCustomCache(name, scope)
	local nameScopeKey = NAME_SCOPE_KEY_FORMAT:format(name, scope)
	local cache = customCaches[nameScopeKey]
	if (not cache) then
		cache = Cache.new(name, scope)
		customCaches[nameScopeKey] = cache
		cache.Failed:Connect(function(method, key, errMsg)
			self:FireEvent(CUSTOM_FAILED_EVENT, name, scope, method, key, errMsg)
		end)
	end
	return cache
end


function DataService:Set(player, key, value)
	self:GetPlayerCache(player):Set(key, value)
end


function DataService:Get(player, key)
	return self:GetPlayerCache(player):Get(key)
end


function DataService:Remove(player, key)
	self:GetPlayerCache(player):Remove(key)
end


function DataService:OnUpdate(player, key, callback)
	self:GetPlayerCache(player):OnUpdate(key, callback)
end


function DataService:SetGlobal(key, value)
	globalCache:Set(key, value)
end


function DataService:GetGlobal(key)
	return globalCache:Get(key)
end


function DataService:RemoveGlobal(key)
	globalCache:Remove(key)
end


function DataService:OnUpdateGlobal(key, callback)
	return globalCache:OnUpdate(key, callback)
end


function DataService:SetCustom(name, scope, key, value)
	self:GetCustomCache(name, scope):Set(key, value)
end


function DataService:GetCustom(name, scope, key)
	return self:GetCustomCache(name, scope):Get(key)
end


function DataService:RemoveCustom(name, scope, key)
	self:GetCustomCache(name, scope):Remove(key)
end


function DataService:OnUpdateCustom(name, scope, key, callback)
	return self:GetCustomCache(name, scope):OnUpdate(key, callback)
end


function DataService:Flush(player)
	self:GetPlayerCache(player):FlushAll()
end


function DataService:FlushKey(player, key)
	self:GetPlayerCache(player):Flush(key)
end


function DataService:FlushGlobal(key)
	globalCache:Flush(key)
end


function DataService:FlushAllGlobal()
	globalCache:FlushAll()
end


function DataService:FlushCustom(name, scope, key)
	self:GetCustomCache(name, scope):Flush(key)
end


function DataService:FlushAllCustom(name, scope, key)
	self:GetCustomCache(name, scope):FlushAll()
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
	local thread = coroutine.running()
	local numCaches = 0
	local numFlushed = 0
	for _ in pairs(playerCaches) do
		numCaches = (numCaches + 1)
	end
	for _,cache in pairs(customCaches) do
		numCaches = (numCaches + 1)
	end
	if (numCaches == 0) then return end
	local function IncFlushed()
		numFlushed = (numFlushed + 1)
		if (numFlushed == numCaches) then
			assert(coroutine.resume(thread))
		end
	end
	for player,cache in pairs(playerCaches) do
		spawn(function()
			cache:FlushAllConcurrent()
			IncFlushed()
		end)
	end	
	for _,cache in pairs(customCaches) do
		spawn(function()
			cache:FlushAll()
			IncFlushed()
		end)
	end
	globalCache:FlushAll()
	coroutine.yield()
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

		--[[ CONCURRENCY DISABLED DUE TO BINDTOCLOSE YIELDING BUG
		local thread = coroutine.running()
		local numBinded = #boundToCloseFuncs
		if (numBinded == 0) then return end
		local numCompleted = 0
		local maxWait = 20
		local start = tick()
		for _,func in pairs(boundToCloseFuncs) do
			coroutine.wrap(function()
				pcall(func)
				numCompleted = (numCompleted + 1)
				if (numCompleted == numBinded) then
					assert(coroutine.resume(thread))
				end
			end)()
		end
		coroutine.yield()
		]]

		-- Temporary patch using BindableEvent instead of coroutines:
		local numBinded = #boundToCloseFuncs
		if (numBinded == 0) then return end
		local bindable = Instance.new("BindableEvent")
		local numCompleted = 0
		for _,func in pairs(boundToCloseFuncs) do
			spawn(function()
				local success, err = pcall(func)
				if (not success) then
					warn("BindToClose function errored: " .. tostring(err))
				end
				numCompleted = (numCompleted + 1)
				if (numCompleted == numBinded) then
					bindable:Fire()
				end
			end)
		end
		bindable.Event:Wait()
		bindable:Destroy()

	end
	
	-- Flush cache:
	local function PlayerRemoving(player)
		if (self.GameClosing) then return end
		self:Flush(player)
		wait(5)
		if (playerCaches[player]) then
			playerCaches[player]:Destroy()
			playerCaches[player] = nil
		end
	end
	
	local function GameClosing()
		self.GameClosing = true
		FireBoundToCloseCallbacks()
		--self:FlushAllConcurrent()
		self:FlushAll()
	end
	
	game:GetService("Players").PlayerRemoving:Connect(PlayerRemoving)
	
	game:BindToClose(GameClosing)
	
	delay(AUTOSAVE_INTERVAL, function()
		self:AutoSaveLoop()
	end)
	
end


function DataService:Init()

	self:RegisterEvent(PLAYER_FAILED_EVENT)
	self:RegisterEvent(GLOBAL_FAILED_EVENT)
	self:RegisterEvent(CUSTOM_FAILED_EVENT)
	self:RegisterClientEvent(CLIENT_FAILED_EVENT)

	Cache = self.Modules.DataStoreCache

	globalCache = Cache.new("global", "global")
	globalCache.Failed:Connect(function(method, key, errMsg)
		self:FireEvent(GLOBAL_FAILED_EVENT, method, key, errMsg)
	end)

end


return DataService
