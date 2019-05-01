-- Data
-- Crazyman32
-- November 20, 2018


--[[
	
	CONSTRUCTORS:
		data = Data.new(name, scope)              [Creates or gets existing Data object for given name and scope]
		data = Data.ForPlayer(userId | player)    [Creates or gets existing Data object for given player OR UserId]
		data = Data.ForServer()                   [Creates or gets existing Data object for the server]

	STATIC FIELDS:
		Data.IsUsingMockService        [Whether or not the MockDataStoreService is being utilized]
		Data.AutoSaveInterval          [How often all data auto-saves. Defaults to '60' seconds]
		Data.PlayerLeftSaveInterval    [How long to wait after a player leaves before saving all data. Defaults to '10' seconds]
		Data.SaveInStudio              [Defaults to 'false'; indicates if data should save when testing in Studio]

	STATIC METHODS:
		Data:OnClose(onCloseFunc)      [Guaranteed to be executed before all data is saved when server is closing]

	FIELDS:
		data.CanAutoSave        [Defaults to 'true']
		data.DestroyOnLeave     [Defaults to 'true'; if linked to a player, 'Destroy()' will automatically be invoked when the player leaves; see static field PlayerLeftSaveInterval]

	METHODS:
		success, value          data:Get(key [, defaultValue])                 [Gets/loads the value from the key; optional default value]
		success                 data:Set(key, value)                           [Sets the value to the given key]
		success                 data:Delete(key)                               [Deletes the value to the given key; NOTE: immediate DataStore call]
		success, value          data:Increment(key, incrementValue)            [Increments the value at the given key by 'incrementValue']
		number                  data:GetRequestBudget(dataStoreRequestType)    [Gets the current RequestBudget for the given dataStoreRequestType]
		success, connection     data:OnUpdate(key, callback)                   [Listens for value changes for a given key]
		success                 data:Save(key)                                 [Saves the current cached value for the given key; NOTE: immediate DataStore call]
		allSuccess              data:SaveAll(stopIfError, errCallback)         [Saves all cached values one-by-one; NOTE: immediate DataStore call]
		void                    data:SaveAllConcurrent(errCallback)            [Saves all cached values at the same time; NOTE: immediate DataStore call]
		void                    data:Destroy([saveAll])                        [Destroys the current Data object; optional 'saveAll' flag (default is 'false')]


	For in-depth info:

		https://devforum.roblox.com/t/details-on-datastoreservice-for-advanced-developers/175804

--]]




local Data = {}
Data.__index = Data
Data._onCloseHandlers = {}

Data.AutoSaveInterval = 60
Data.PlayerLeftSaveInterval = 10
Data.SaveInStudio = false

local NAME_MAX_LEN = 50
local SCOPE_MAX_LEN = 50
local KEY_MAX_LEN = 49

local KEY_MAX_LEN_ERR = "Key must be a string less or equal to " .. KEY_MAX_LEN .. " characters"

local PLAYER_DATA_NAME = "PlayerData"

local dataStoreService = game:GetService("DataStoreService")
Data.IsUsingMockService = false

local dataPool = {}
local assert = assert


local function AssertKey(key)
	assert(type(key) == "string" and #key <= KEY_MAX_LEN, KEY_MAX_LEN_ERR)
end


local function GetDataFromNameAndScope(name, scope)
	local ds = dataStoreService:GetDataStore(name, scope)
	return dataPool[ds]
end


---------------------------------------------------------------------------------------------------------------------------
-- CONSTRUCTORS:


function Data.new(name, scope)

	assert(type(name) == "string", "Argument #1 (name) must be a string")
	assert(type(scope) == "string", "Argument #2 (scope) must be a string")
	assert(#name <= NAME_MAX_LEN, "Argument #1 (name) must be less or equal to " .. NAME_MAX_LEN .. " characters")
	assert(#scope <= SCOPE_MAX_LEN, "Argument #1 (scope) must be less or equal to " .. SCOPE_MAX_LEN .. " characters")

	-- Get cached 'data' object if available:
	local ds = dataStoreService:GetDataStore(name, scope)
	local self = dataPool[ds]
	if (self and not self._destroyed) then return self end

	-- Create new 'data' object:
	self = setmetatable({
		Name = name;
		Scope = scope;
		CanAutoSave = true;
		DestroyOnLeave = true;
		_ds = ds;
		_cache = {};
		_destroyed = false;
	}, Data)

	dataPool[ds] = self

	return self

end


function Data.ForPlayer(userId)
	if (typeof(userId) == "Instance") then
		assert(userId:IsA("Player"), "Expected Player; got " .. userId.ClassName)
		userId = userId.UserId
	else
		assert(type(userId) == "number" and userId >= 0 and math.floor(userId) == userId, "Expected integer >= 0")
	end
	local scope = tostring(userId)
	local data = Data.new(PLAYER_DATA_NAME, scope)
	return data
end


function Data.ForServer()
	return Data.new("global", "global")
end


---------------------------------------------------------------------------------------------------------------------------
-- PRIVATE METHODS:


function Data:_load(key)
	return pcall(function()
		return self._ds:GetAsync(key)
	end)
end


function Data:_save(key, value)
	return pcall(function()
		return self._ds:SetAsync(key, value)
	end)
end


function Data:_delete(key)
	return pcall(function()
		return self._ds:RemoveAsync(key)
	end)
end


function Data:_update(key, transformFunc)
	return pcall(function()
		return self._ds:UpdateAsync(key, transformFunc)
	end)
end


function Data:_countKeysInCache()
	local keyCount = 0
	for _ in pairs(self._cache) do
		keyCount = (keyCount + 1)
	end
	return keyCount
end


---------------------------------------------------------------------------------------------------------------------------
-- PUBLIC METHODS:


function Data:GetRequestBudget(reqType)
	return dataStoreService:GetRequestBudgetForRequestType(reqType)
end


function Data:Get(key, defaultVal)
	assert(not self._destroyed, "Data already destroyed")
	AssertKey(key)
	local success = true
	local value = self._cache[key]
	if (value == nil) then
		success, value = self:_load(key)
		if (success and value == nil and defaultVal ~= nil) then
			value = defaultVal
			self:Set(key, defaultVal)
		end
	end
	return success, value
end


function Data:Set(key, value)
	assert(not self._destroyed, "Data already destroyed")
	AssertKey(key)
	if (value == nil) then
		self._cache[key] = nil
		return self:_delete(key)
	else
		self._cache[key] = value
		return true
	end
end


function Data:Increment(key, increment)
	assert(not self._destroyed, "Data already destroyed")
	local success, value = self:Get(key, 0)
	assert(type(value) == "number", "Cannot increment a non-number value")
	assert(type(increment) == "number", "Increment must be a number")
	value = (value + increment)
	return self:Set(key, value), value
end


function Data:Delete(key)
	return self:Set(key, nil)
end


function Data:OnUpdate(key, callback)
	assert(not self._destroyed, "Data already destroyed")
	AssertKey(key)
	assert(type(callback) == "function", "Callback must be a function")
	return pcall(function()
		return self._ds:OnUpdate(key, callback)
	end)
end


function Data:Save(key)
	assert(not self._destroyed, "Data already destroyed")
	AssertKey(key)
	local cachedVal = self._cache[key]
	assert(cachedVal ~= nil, "Cannot save key that has not already been loaded via Data:Get(key)")
	return self:_save(key, cachedVal)
end


function Data:SaveAll(stopIfError, errCallback)
	assert(not self._destroyed, "Data already destroyed")
	assert(type(errCallback) == "function" or errCallback == nil, "ErrorCallback must be a function (or nil)")
	local allSucceeded = false
	for key in pairs(self._cache) do
		local success,err = self:Save(key)
		if (not success) then
			allSucceeded = false
			if (errCallback) then
				errCallback(err)
			end
			if (stopIfError) then
				break
			end
		end
	end
	return allSucceeded
end


function Data:SaveAllConcurrent(errCallback)
	assert(not self._destroyed, "Data already destroyed")
	assert(type(errCallback) == "function" or errCallback == nil, "ErrorCallback must be a function (or nil)")
	local be = Instance.new("BindableEvent")
	--local thread = coroutine.running()
	local remaining = 0
	for key in pairs(self._cache) do
		remaining = (remaining + 1)
		spawn(function()
			local success,err = self:Save(key)
			if ((not success) and errCallback) then
				errCallback(err)
			end
			remaining = (remaining - 1)
			if (remaining <= 0) then
				--assert(coroutine.resume(thread))
				be:Fire()
			end
		end)
	end
	if (remaining > 0) then
		--coroutine.yield()
		be.Event:Wait()
		be:Destroy()
	end
end


function Data:Update(key, transformFunc)
	assert(not self._destroyed, "Data already destroyed")
	AssertKey(key)
	assert(type(transformFunc) == "function", "TransformFunction must be a function")
	return self:_update(key, transformFunc)
end


function Data:Destroy(save)
	assert(not self._destroyed, "Data already destroyed")
	self._destroyed = true
	if (save) then
		self:SaveAll(false, nil)
	end
	self._cache = {}
	dataPool[self._ds] = nil
end


---------------------------------------------------------------------------------------------------------------------------


function Data:OnClose(handler)
	assert(type(handler) == "function", "OnClose handler must be a function")
	for _,h in pairs(self._onCloseHandlers) do
		if (h == handler) then
			error("Handler already binded")
		end
	end
	table.insert(self._onCloseHandlers, handler)
end


function Data:Start()

	local gameClosing = false

	if (game.GameId == 0) then
		Data.IsUsingMockService = true
	elseif (game:GetService("RunService"):IsStudio()) then
		if (not Data.SaveInStudio) then
			Data.IsUsingMockService = true
		else
			local success,err = pcall(function()
				dataStoreService:GetDataStore("__aero"):UpdateAsync("dss_api_check", function(v) return v == nil and true or v end)
			end)
			if (not success) then
				-- Error codes: https://developer.roblox.com/articles/Datastore-Errors
				local errCode = tonumber(err:match("^%d+"))
				if (errCode == 502 or errCode == 403) then
					Data.IsUsingMockService = true
				elseif (errCode == 304) then
					error("DataStoreService API check failed on UpdateAsync (request queue full)")
				else
					error("DataStoreService API error " .. errCode or "[Unknown Status]" .. ": " .. err)
				end
			end
		end
	end

	local function AutoSaveAllData()
		for _,data in pairs(dataPool) do
			if (data.CanAutoSave) then
				--local budget = dataStoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.SetIncrementAsync)
				--local keys = data:_countKeysInCache()
				data:SaveAllConcurrent()
			end
		end
	end

	if (self.IsUsingMockService) then
		-- Use mock DataStoreService:
		dataStoreService = require(script.MockDataStoreService)
	else
		-- Auto-save all data before server closes:
		game:BindToClose(function()
			gameClosing = true
			AutoSaveAllData()
		end)
	end

	-- Destroy player data when player leaves:
	game:GetService("Players").PlayerRemoving:Connect(function(player)
		local data = GetDataFromNameAndScope(PLAYER_DATA_NAME, tostring(player.UserId))
		if (not data) then return end
		wait(self.PlayerLeftSaveInterval)
		if (gameClosing or not data.DestroyOnLeave) then return end
		data:Destroy(true)
	end)

	-- Auto-save cycle:
	spawn(function()
		while (not gameClosing) do
			wait(self.AutoSaveInterval)
			AutoSaveAllData()
		end
	end)

end


function Data:Init()

end


return Data
