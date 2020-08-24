-- Data
-- Stephen Leitnick
-- November 20, 2018


--[[
	
	CONSTRUCTORS:
		data = Data.new(name, scope [, ordered])              [Creates or gets existing Data object for given name and scope]
		data = Data.ForPlayer(userId | player [, ordered])    [Creates or gets existing Data object for given player OR UserId]
		data = Data.ForServer([ordered])                      [Creates or gets existing Data object for the server]

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
		Promise<Value>          data:Get(String key [, Any defaultValue])
		Promise<DataStorePage>  data:GetSorted(Boolean isAscendint, Int pageSize, Number minValue, Number maxValue)
		Promise<Void>           data:Set(String key, String value)
		Promise<Void>           data:Delete(String key)
		Promise<Value>          data:Increment(String key, Number incrementValue)
		Promise<Connection>     data:OnUpdate(String key, Function callback)
		Promise<Void>           data:Save(String key)
		Promise<Void>           data:SaveAll()
		Promise<Void>           data:Destroy([Boolean saveAll])
		Number                  data:GetRequestBudget(DataStoreRequestType requestType)
		Void                    data:MarkDirty(String key)
		
	EVENTS:
		data.Success         data.Success:Connect(String method, String key)
		data.Failed          data.Failed:Connect(String method, String key, String err)

	METHOD DESCRIPTIONS:
		Get
			Gets/loads the value from the key. The optional 'defaultValue' can be used
			if the retrieved value from the DataStore is nil. This method will only
			call the DataStore if it has not yet done so and gotten a non-nil value. If
			a call has already been made for the given key, the value will be cached
			and the cached value will be returned.

		GetSorted
			Calls the GetSortedAsync method on the OrderedDataStore connected to this
			data object. It will return a custom DataStorePage object described below:

			DataStorePage:
				Boolean         dataStorePage.IsFinished
				Promise<Void>   dataStorePage:AdvanceToNextPage()
				Promise<Table>  dataStorePage:GetCurrentPage()

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

		MarkDirty
			Marks the key as dirty, which means that it will be forced to save the
			next time a save invocation occurs. This is necessary when making changes
			to tables.
	

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


		-- OrderedDataStore example:
		data = Data.ForPlayer(somePlayer, true)

		data:GetSorted(true, 10, 0, 1000):Then(function(pages)
			return pages:GetCurrentPage()
		end):Then(function(page)
			for k,v in pairs(page) do
				print(k, v)
			end
		end)



	For in-depth info on DataStores:

		https://devforum.roblox.com/t/details-on-datastoreservice-for-advanced-developers/175804

--]]



local Data = {}
Data.__index = Data
Data._onCloseHandlers = {}

-- Static fields; customize as needed:
Data.AutoSaveInterval = 60
Data.PlayerLeftSaveInterval = 10
Data.SaveInStudio = false
Data.Log = false

-- Constants based on internal Roblox DataStore; DO NOT CHANGE:
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


local function Log(...)
	if (not Data.Log) then return end
	print("Data ->", ...)
end


local function HeartbeatSpawn(callback, ...)
	local hb
	local args = table.pack(...)
	hb = game:GetService("RunService").Heartbeat:Connect(function()
		hb:Disconnect()
		callback(table.unpack(args, 1, args.n))
	end)
end


-- Check if key matches DataStore criteria:
local function CheckKey(key)
	return (type(key) == "string" and #key <= KEY_MAX_LEN)
end

-- Retrieve cached DataStore from name and scope:
local function GetDataFromNameAndScope(name, scope)
	local ds = dataStoreService:GetDataStore(name, scope)
	return dataPool[ds]
end


---------------------------------------------------------------------------------------------------------------------------
-- DataStorePages wrapper for promises:

local DataStorePages = {}
DataStorePages.__index = DataStorePages
function DataStorePages.new(dsp)
	return setmetatable({
		DSP = dsp;
		IsFinished = dsp.IsFinished;
	}, DataStorePages)
end

function DataStorePages:AdvanceToNextPage()
	return Promise.new(function(resolve, reject)
		local success, err = pcall(self.DSP.AdvanceToNextPageAsync, self.DSP)
		self.IsFinished = self.DSP.IsFinished
		if (success) then resolve() else reject(err) end
	end)
end

function DataStorePages:GetCurrentPage()
	return Promise.new(function(resolve, reject)
		local success, page = pcall(self.DSP.GetCurrentPage, self.DSP)
		if (success) then resolve(page) else reject(page) end
	end)
end
---------------------------------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------------------------------
-- CONSTRUCTORS:


function Data.new(name, scope, ordered)

	-- Check arguments:
	assert(type(name) == "string", "Argument #1 (name) must be a string")
	assert(type(scope) == "string", "Argument #2 (scope) must be a string")
	assert(#name <= NAME_MAX_LEN, "Argument #1 (name) must be less or equal to " .. NAME_MAX_LEN .. " characters")
	assert(#scope <= SCOPE_MAX_LEN, "Argument #1 (scope) must be less or equal to " .. SCOPE_MAX_LEN .. " characters")
	assert(type(ordered) == "boolean" or ordered == nil, "Argument #3 (ordered) must be a boolean or nil")

	ordered = (not not ordered)

	-- Get cached 'data' object if available:
	local ds = (ordered and dataStoreService:GetOrderedDataStore(name, scope) or dataStoreService:GetDataStore(name, scope))
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
		_dirty = {};
		_ordered = ordered;
		_destroyed = false;
		_destroying = false;
	}, Data)
	
	-- Data events:
	self.Success = self.Shared.Signal.new()
	self.Failed = self.Shared.Signal.new()

	dataPool[ds] = self

	Log("Created new Data object:", tostring(self))

	return self

end


function Data.ForPlayer(userId, ordered)
	if (typeof(userId) == "Instance") then
		-- Capture UserId from the player object:
		assert(userId:IsA("Player"), "Expected Player; got " .. userId.ClassName)
		userId = userId.UserId
	else
		assert(type(userId) == "number" and userId >= 0 and math.floor(userId) == userId, "Expected integer >= 0")
	end
	local scope = tostring(userId)
	local data = Data.new(PLAYER_DATA_NAME, scope, ordered)
	return data
end


function Data.ForServer(ordered)
	return Data.new("global", "global", ordered)
end


---------------------------------------------------------------------------------------------------------------------------
-- PRIVATE METHODS:


-- Load a given key from the DataStore:
function Data:_load(key)
	Log("Loading " .. key .. "...")
	return Promise.new(function(resolve, reject)
		-- Call GetAsync and cache the results:
		local success, value = pcall(self._ds.GetAsync, self._ds, key)
		if (success) then
			Log("Succesfully loaded key " .. key .. ":", value)
			self._cache[key] = value
			self._dirty[key] = false
			self.Success:Fire("GetAsync", key)
			resolve(value)
		else
			Log("Failede to load key " .. key)
			self.Failed:Fire("GetAsync", key, value)
			reject(value)
		end
	end)
end


-- Get the cached value from the key, or load it from the DataStore if not yet cached:
function Data:_loadIfNotCached(key)
	if (self:_cacheExists(key)) then
		return Promise.Resolve(self:_getCache(key))
	end
	return self:_load(key)
end


-- Save the key/value to the DataStore:
function Data:_save(key, value)
	Log("Saving " .. key .. "...")
	if (self._dirty[key] == false) then
		-- If not dirty, the given key does not need to be saved:
		Log("No save necessary; " .. key .. " not marked as dirty")
		return Promise.Resolve()
	end
	return Promise.new(function(resolve, reject)
		-- Call SetAsync and mark key as no longer dirty:
		local valBeforeSave = self:_getCache(key)
		local success, err = pcall(self._ds.SetAsync, self._ds, key, value)
		if (success) then
			if (self:_getCache(key) == valBeforeSave) then
				self._dirty[key] = false
			end
			self.Success:Fire("SetAsync", key)
			Log("Successfully saved " .. key .. ":", value)
			resolve()
		else
			Log("Failed to save " .. key)
			self.Failed:Fire("SetAsync", key, err)
			reject(err)
		end
	end)
end


function Data:_delete(key)
	Log("Deleting " .. key .. "...")
	return Promise.new(function(resolve, reject)
		-- Call RemoveAsync and remove value from cache:
		local success, err = pcall(self._ds.RemoveAsync, self._ds, key)
		if (success) then
			Log("Successfully deleted key " .. key)
			self:_clearCache(key)
			self.Success:Fire("RemoveAsync", key)
			resolve()
		else
			Log("Failed to delete key " .. key)
			self.Failed:Fire("RemoveAsync", key, err)
			reject(err)
		end
	end)
end


function Data:_update(key, transformFunc)
	Log("Updating " .. key .. "...")
	return Promise.new(function(resolve, reject)
		-- Call UpdateAsync and update cache with returned value:
		local success, value = pcall(self._ds.UpdateAsync, self._ds, key, transformFunc)
		if (success) then
			Log("Successfully updated key " .. key)
			self:_setCache(key, value, true)
			self.Success:Fire("UpdateAsync", key)
			resolve(value)
		else
			Log("Failed to update key " .. key)
			self.Failed:Fire("UpdateAsync", key, value)
			reject(value)
		end
	end)
end


function Data:_getSorted(isAscending, pageSize, minValue, maxValue)
	return Promise.new(function(resolve, reject)
		-- Call GetSortedAsync and return the custom DataStorePages object:
		local success, dsp = pcall(self._ds.GetSortedAsync, self._ds, isAscending, pageSize, minValue, maxValue)
		if (success) then
			resolve(DataStorePages.new(dsp))
		else
			reject(dsp)
		end
	end)
end


-- Retrieve a cached value for the given key:
function Data:_getCache(key)
	return self._cache[key]
end


-- Set an item in the cache and mark clean or dirty:
function Data:_setCache(key, value, isClean)
	if (self._cache[key] ~= value) then
		self._cache[key] = value
		self._dirty[key] = (not isClean)
	end
end


-- Delete an item from the cache:
function Data:_clearCache(key)
	self._cache[key] = nil
	self._dirty[key] = nil
end


-- Check if a key has a value in the cache:
function Data:_cacheExists(key)
	return (self._cache[key] ~= nil)
end


-- Get the number of keys within the cache:
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
	-- See:
		-- https://developer.roblox.com/api-reference/function/DataStoreService/GetRequestBudgetForRequestType
		-- https://developer.roblox.com/api-reference/enum/DataStoreRequestType
		-- https://developer.roblox.com/articles/Datastore-Errors
	return dataStoreService:GetRequestBudgetForRequestType(reqType)
end


function Data:Get(key, defaultVal)
	if (self._destroyed) then
		return Promise.Reject("Data already destroyed")
	end
	if (not CheckKey(key)) then
		return Promise.Reject(KEY_MAX_LEN_ERR)
	end
	if (self:_cacheExists(key)) then
		-- Return the cached value:
		return Promise.Resolve(self:_getCache(key))
	end
	-- Load and return value since it was not in the cache:
	return self:_load(key):Then(function(value)
		if (value == nil and defaultVal ~= nil) then
			value = defaultVal
			if (typeof(defaultVal) == "table") then
				value = tableUtil.Copy(defaultVal)
			end
			return self:Set(key, value):Then(function()
				return value
			end)
		else
			return value
		end
	end)
end


function Data:GetSorted(isAscending, pageSize, minValue, maxValue)
	if (self._destroyed) then
		return Promise.Reject("Data already destroyed")
	end
	if (not self._ordered) then
		return Promise.Reject("GetSorted can only be invoked on an ordered data object")
	end
	return self:_getSorted(isAscending, pageSize, minValue, maxValue)
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
			return self:_delete(key)
		else
			self:_setCache(key, value)
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
	-- Get the current value, increment it, then set the new value:
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
		local success, err = pcall(self._ds.OnUpdate, self._ds, key, callback)
		if (success) then
			self.Success:Fire("OnUpdate", key)
			resolve()
		else
			self.Failed:Fire("OnUpdate", key, err)
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
	local cachedVal = self:_getCache(key)
	if (cachedVal == nil) then
		return Promise.Reject("Cannot save key that has not already been loaded via Data:Get(key)")
	end
	return self:_save(key, cachedVal)
end


function Data:SaveAll()
	if (self._destroyed) then
		return Promise.Reject("Data already destroyed")
	end
	-- Collect all 'Save' promises and return them all in a single promise:
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


function Data:MarkDirty(key)
	self._dirty[key] = true
end


function Data:Destroy(save)
	Log("Destroying data object:", tostring(self))
	if (self._destroyed or self._destroying) then
		return Promise.Reject("Data already destroyed")
	end
	self._destroying = true
	local savePromise
	if (save) then
		savePromise = self:SaveAll(false, nil)
	else
		savePromise = Promise.Resolve()
	end
	return savePromise:Then(function()
		-- Clear and destroy objects:
		Log("Data successfully destroyed")
		self._destroyed = true
		self._cache = {}
		self._dirty = {}
		self.Failed:Destroy()
		self.Success:Destroy()
		dataPool[self._ds] = nil
	end):Catch(function(err)
		-- Failed to destroy, thus remark as not destroyed & rethrow error:
		Log("   Saving failed")
		self._destroying = false
		error(err)
	end)
end


---------------------------------------------------------------------------------------------------------------------------


function Data:OnClose(handler)
	assert(type(handler) == "function", "OnClose handler must be a function")
	for _,h in ipairs(self._onCloseHandlers) do
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
			-- Verify status of the DataStoreService on startup:
			local success, err = pcall(function()
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
	
	local function FireBoundToCloseCallbacks()
		local numBinded = #self._onCloseHandlers
		if (numBinded == 0) then return end
		local bindable = Instance.new("BindableEvent")
		local numCompleted = 0
		for _,func in ipairs(self._onCloseHandlers) do
			HeartbeatSpawn(function()
				local success, err = pcall(func)
				if (not success) then
					warn("Data BindToClose function failed: " .. tostring(err))
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
			FireBoundToCloseCallbacks()
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
	HeartbeatSpawn(function()
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


function Data:__tostring()
	return ("Data (Name=%s, Scope=%s, Ordered=%s)"):format(self.Name, self.Scope, self._ordered and "Yes" or "No")
end


return Data