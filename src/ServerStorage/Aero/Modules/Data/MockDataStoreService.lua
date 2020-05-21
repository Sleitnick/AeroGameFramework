-- Mock DataStoreService
-- Stephen Leitnick
-- August 20, 2014


--[[
	
	USAGE EXAMPLE:
	
		--------
		local dataStoreService = game:GetService("DataStoreService")
		
		-- Mock service if the game is offline:
		if (game.PlaceId == 0) then
			dataStoreService = require(game.ServerStorage.MockDataStoreService)
		end
		
		-- dataStoreService will act exactly like the real one
		--------
	
	The mocked data store service should function exactly like the
	real service. What the mocked service does is "override" the
	core methods, such as GetAsync. If you try to index a property
	that hasn't been overridden (such as dataStoreService.Name), it
	will reference the actual property in the real dataStoreService.
	
	NOTE:
		This has been created based off of the DataStoreService on
		August 20, 2014. If a change has been made to the service,
		this mocked version will not reflect the changes.
	
--]]



local DataStoreService = {}
local API = {}
local MT = {}


-----------------------------------------------------------------------------------------------------------

local realDataStoreService = game:GetService("DataStoreService")
local allStores = {}

if (game:GetService("Players").LocalPlayer) then
	warn("Mocked DataStoreService is functioning on the client: The real DataStoreService will not work on the client")
end


-----------------------------------------------------------------------------------------------------------
-- API:

function API:GetDataStore(name, scope)
	assert(type(name) == "string", "DataStore name must be a string; got" .. type(name))
	assert(type(scope) == "string" or scope == nil, "DataStore scope must be a string; got" .. type(scope))
	scope = (scope or "global")
	if (allStores[scope] and allStores[scope][name]) then
		return allStores[scope][name]
	end
	local data = {}
	local d = {}
	local updateListeners = {}
	function d.SetAsync(_s, k, v)
		assert(v ~= nil, "Value cannot be nil")
		data[k] = v
		if (updateListeners[k]) then
			for _,f in ipairs(updateListeners[k]) do
				spawn(function() f(v) end)
			end
		end
	end
	function d.UpdateAsync(_s, k, func)
		local v = func(data[k])
		assert(v ~= nil, "Value cannot be nil")
		data[k] = v
		if (updateListeners[k]) then
			for _,f in ipairs(updateListeners[k]) do
				spawn(function() f(v) end)
			end
		end
	end
	function d.GetAsync(_s, k)
		return data[k]
	end
	function d.RemoveAsync(_s, k)
		data[k] = nil
		if (updateListeners[k]) then
			for _,f in ipairs(updateListeners[k]) do
				spawn(function() f(nil) end)
			end
		end
	end
	function d.IncrementAsync(_s, k, delta)
		if (delta == nil) then delta = 1 end
		assert(type(delta) == "number", "Can only increment numbers")
		_s:UpdateAsync(k, function(num)
			if (num == nil) then
				return num
			end
			assert(type(num) == "number", "Can only increment numbers")
			return (num + delta)
		end)
	end
	function d.OnUpdate(_s, k, onUpdateFunc)
		assert(type(onUpdateFunc) == "function", "Update function argument must be a function")
		if (not updateListeners[k]) then
			updateListeners[k] = {onUpdateFunc}
		else
			table.insert(updateListeners[k], onUpdateFunc)
		end
	end
	if (not allStores[scope]) then
		allStores[scope] = {}
	end
	allStores[scope][name] = d
	return d
end


function API:GetGlobalDataStore()
	return self:GetDataStore("global", "global")
end


function API:GetOrderedDataStore(name, scope)
	local dataStore = self:GetDataStore(name, scope)
	local allData = {}
	local d = {}
	function d.GetAsync(_s, k)
		return dataStore:GetAsync(k)
	end
	function d.SetAsync(_s, k, v)
		assert(type(v) == "number", "Value must be a number")
		dataStore:SetAsync(k, v)
		allData[k] = v
	end
	function d.UpdateAsync(_s, k, func)
		dataStore:UpdateAsync(k, function(oldValue)
			local v = func(oldValue)
			assert(type(v) == "number", "Value must be a number")
			allData[k] = v
			return v
		end)
	end
	function d.IncrementAsync(_s, k, delta)
		dataStore:IncrementAsync(k, delta)
		allData[k] = ((allData[k] or 0) + delta)
	end
	function d.RemoveAsync(_s, k)
		dataStore:RemoveAsync(k)
		allData[k] = nil
	end
	function d.GetSortedAsync(_s, isAscending, pageSize, minValue, maxValue)
		assert(type(pageSize) == "number" and math.floor(pageSize) > 0, "PageSize must be an integer and greater than 0")
		assert(minValue == nil or type(minValue) == "number", "MinValue must be a number")
		assert(maxValue == nil or type(maxValue) == "number", "MaxValue must be a number")
		if (minValue and maxValue) then
			assert(minValue <= maxValue, "MinValue must be less or equal to MaxValue")
		end
		local data = {}
		for k,v in pairs(allData) do
			local pass = ((not minValue or v >= minValue) and (not maxValue or v <= maxValue))
			if (pass) then
				table.insert(data, {key = k, value = v})
			end
		end
		table.sort(data,
			(isAscending and
				function(a, b) return (a.value < b.value) end
			or
				function(a, b) return (b.value < a.value) end
			)
		)
		pageSize = math.floor(pageSize)
		local pages = {IsFinished = false}
		for i,v in pairs(data) do
			local pageNum = math.ceil(i / pageSize)
			local page = pages[pageNum]
			if (not page) then
				page = {}
				pages[pageNum] = page
			end
			local index = (((i - 1) % pageSize) + 1)
			page[index] = v
		end
		do
			local currentPage = 1
			function pages.GetCurrentPage(p)
				return p[currentPage]
			end
			function pages.AdvanceToNextPageAsync(p)
				local numPages = #pages
				if (currentPage < numPages) then
					currentPage = (currentPage + 1)
				end
				p.IsFinished = (currentPage >= numPages)
			end
		end
		return pages
	end
	return d
end


function API:GetRequestBudgetForRequestType(requestType)
	return realDataStoreService:GetRequestBudgetForRequestType(requestType)
end


-----------------------------------------------------------------------------------------------------------
-- Metatable:

MT.__metatable = true
MT.__index = function(_tbl, index)
	return (API[index] or realDataStoreService[index])
end
MT.__newindex = function()
	error("Cannot edit MockDataStoreService")
end
setmetatable(DataStoreService, MT)

-----------------------------------------------------------------------------------------------------------

return DataStoreService