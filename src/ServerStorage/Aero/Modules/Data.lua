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
		Promise<Value>       data:Get(String key [, Any defaultValue])
		Promise<Void>        data:Set(String key, String value)
		Promise<Void>        data:Delete(String key)
		Promise<Value>       data:Increment(String key, Number incrementValue)
		Promise<Connection>  data:OnUpdate(String key, Function callback)
		Promise<Void>        data:Save(String key)
		Promise<Void>        data:SaveAll()
		Promise<Void>        data:Destroy([Boolean saveAll])
		Number               data:GetRequestBudget(DataStoreRequestType requestType)

	METHOD DESCRIPTIONS:
		Get
			Gets/loads the value from the key. The optional 'defaultValue' can be used
			if the retrieved value from the DataStore is nil. This method will only
			call the DataStore if it has not yet done so and gotten a non-nil value. If
			a call has already been made for the given key, the value will be cached
			and the cached value will be returned.

		Set
			Sets the value to the given key in the local cache. This does NOT set the
			value in the DataStore. Call 'Save' or 'SaveAll' to explicitly save to the
			DataStore. Otherwise, the key will automatically save during the auto-save
			period, when the player leaves, or when the server shuts down.

			If you try to set a value to a key that has not yet been cached, it will
			first try to call the DataStore to ensure it is working. If DataStores
			are down, this call will fail, ensuring that you don't start overriding
			values during DataStore downtime.

		Delete
			This deletes the value from the cache AND the DataStore. This is the same
			as calling 'data:Set("key", nil)' but is preferred for its explicit naming.

		Increment
			This increments a value on a given key. If the current value doesn't exist,
			then it will assume a starting value of 0. This will fail if the increment
			or the existing value is not a number.

		OnUpdate
			This registers a function to listen for changes on a key at the DataStore
			level, NOT the cache level. Thus, using 'data:Set()' won't trigger a bound
			function on OnUpdate. In other words, this function can be used to tell
			when a key has been saved onto the DataStore.

		Save
			Saves a cached key to the DataStore. The key must currently have a cached
			value, otherwise this request will fail.

		SaveAll
			Saves all currently cached keys to the DataStore.

		Destroy
			Destroys the data object instance. If 'saveAll' is set to 'true', this will
			also call 'SaveAll' before removing any of the data.

		GetRequestBudget
			This is exactly the same as the DataStoreService's GetRequestBudget. Read
			the documentation on the Roblox Developer site:
			https://developer.roblox.com/api-reference/function/DataStoreService/GetRequestBudgetForRequestType
	

	EXAMPLES:

		data = Data.ForPlayer(somePlayer)

		-- Using 'Await' to get money:
		local success, money = data:Get("money", 0):Await()
		if (success) then
			print("Money", money)
		else
			warn("Failed to get money", money)
		end

		-- Using 'Then' to get money:
		data:Get("money", 0):Then(function(money)
			print("Money", money)
		end, function(err)
			warn("Failed to get money", err)
		end)

		-- Setting money:
		data:Set("money", 25):Await()

		-- Saving:
		data:Save("money"):Then(function()
			print("Successfully saved money")
		end):Catch(function(err)
			warn("Failed to save money", err)
		end):Finally(function()
			-- Cleanup stuff
		end)

			


	For in-depth info on DataStores:

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
local tableUtil
local Promise


local function CheckKey(key)
	return (type(key) == "string" and #key <= KEY_MAX_LEN)
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
	return Promise.new(function(resolve, reject)
		local success, value = pcall(function()
			return self._ds:GetAsync(key)
		end)
		if (success) then
			self._cache[key] = value
			resolve(value)
		else
			reject(value)
		end
	end, true)
end


function Data:_loadIfNotCached(key)
	if (self._cache[key] ~= nil) then
		return Promise.Resolve(self._cache[key])
	end
	return self:_load(key)
end


function Data:_save(key, value)
	return Promise.new(function(resolve, reject)
		local success, err = pcall(function()
			return self._ds:SetAsync(key, value)
		end)
		if (success) then
			resolve()
		else
			reject(err)
		end
	end, true)
end


function Data:_delete(key)
	return Promise.new(function(resolve, reject)
		local success, err = pcall(function()
			return self._ds:RemoveAsync(key)
		end)
		if (success) then
			resolve()
		else
			reject(err)
		end
	end, true)
end


function Data:_update(key, transformFunc)
	return Promise.new(function(resolve, reject)
		local success, value = pcall(function()
			return self._ds:UpdateAsync(key, transformFunc)
		end)
		if (success) then
			resolve(value)
		else
			reject(value)
		end
	end, true)
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
	if (self._destroyed) then
		return Promise.Reject("Data already destroyed")
	end
	if (not CheckKey(key)) then
		return Promise.Reject(KEY_MAX_LEN_ERR)
	end
	if (self._cache[key] ~= nil) then
		return Promise.Resolve(self._cache[key])
	end
	return self:_load(key):Then(function(value)
		if (value == nil and defaultVal ~= nil) then
			value = (typeof(defaultVal) ~= "table" and defaultVal or tableUtil.Copy(defaultVal))
			return self:Set(key, value)
		else
			return value
		end
	end)
end


function Data:Set(key, value)
	if (self._destroyed) then
		return Promise.Reject("Data already destroyed")
	end
	if (not CheckKey(key)) then
		return Promise.Reject(KEY_MAX_LEN_ERR)
	end
	return self:_loadIfNotCached(key):Then(function()
		if (value == nil) then
			self._cache[key] = nil
			return self:_delete(key)
		else
			self._cache[key] = value
		end
	end)
end


function Data:Increment(key, increment)
	if (self._destroyed) then
		return Promise.Reject("Data already destroyed")
	end
	if (type(increment) ~= "number") then
		return Promise.Reject("Increment must be a number")
	end
	return self:Get(key, 0):Then(function(value)
		if (type(value) ~= "number") then
			error("Cannot increment a non-number value")
			return
		end
		value = (value + increment)
		return self:Set(key, value):Then(function()
			return value
		end)
	end)
end


function Data:Delete(key)
	return self:Set(key, nil)
end


function Data:OnUpdate(key, callback)
	if (self._destroyed) then
		return Promise.Reject("Data already destroyed")
	end
	if (not CheckKey(key)) then
		return Promise.Reject(KEY_MAX_LEN_ERR)
	end
	if (type(callback) ~= "function") then
		return Promise.Reject("Callback must be a function")
	end
	return Promise.new(function(resolve, reject)
		local success, err = pcall(function()
			return self._ds:OnUpdate(key, callback)
		end)
		if (success) then
			resolve()
		else
			reject(err)
		end
	end)
end


function Data:Save(key)
	if (self._destroyed) then
		return Promise.Reject("Data already destroyed")
	end
	if (not CheckKey(key)) then
		return Promise.Reject(KEY_MAX_LEN_ERR)
	end
	local cachedVal = self._cache[key]
	if (cachedVal == nil) then
		return Promise.Reject("Cannot save key that has not already been loaded via Data:Get(key)")
	end
	return self:_save(key, cachedVal)
end


function Data:SaveAll()
	if (self._destroyed) then
		return Promise.Reject("Data already destroyed")
	end
	local promises = {}
	for key in pairs(self._cache) do
		promises[#promises + 1] = self:Save(key)
	end
	return Promise.All(promises)
end


function Data:Update(key, transformFunc)
	if (self._destroyed) then
		return Promise.Reject("Data already destroyed")
	end
	if (not CheckKey(key)) then
		return Promise.Reject(KEY_MAX_LEN_ERR)
	end
	if (type(transformFunc) ~= "function") then
		return Promise.Reject("TransformFunction must be a function")
	end
	return self:_update(key, transformFunc)
end


function Data:Destroy(save)
	if (self._destroyed) then
		return Promise.Reject("Data already destroyed")
	end
	self._destroyed = true
	local savePromise
	if (save) then
		savePromise = self:SaveAll(false, nil)
	else
		savePromise = Promise.Resolve()
	end
	return savePromise:Then(function()
		self._cache = {}
		dataPool[self._ds] = nil
	end)
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
	local autoSaving = false

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
		if (autoSaving) then return end
		autoSaving = true
		local promises = {}
		for _,data in pairs(dataPool) do
			if (data.CanAutoSave) then
				--local budget = dataStoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.SetIncrementAsync)
				--local keys = data:_countKeysInCache()
				local saveAllPromise = data:SaveAll()
				if (not gameClosing) then
					saveAllPromise:Await()
				else
					promises[#promises + 1] = saveAllPromise
				end
			end
		end
		if (#promises == 0) then
			autoSaving = false
		else
			Promise.All(promises):Await()
			autoSaving = false
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
		while (true) do
			wait(self.AutoSaveInterval)
			if (gameClosing) then break end
			AutoSaveAllData()
		end
	end)

end


function Data:Init()
	Promise = self.Shared.Promise
	tableUtil = self.Shared.TableUtil
end


return Data
