-- Safe Data Store
-- Crazyman32
-- February 3, 2017

--[[
	
	Works exactly like the real DataStore.

	safeDataStore.Failed(method, key, errorMessage)
	
--]]



local SafeDataStore = {}
SafeDataStore.__index = SafeDataStore

local MAX_ATTEMPTS = 5
local ATTEMPT_INTERVAL = 2


local dataStoreService = game:GetService("DataStoreService")
if (game.PlaceId == 0) then
	dataStoreService = require(script:WaitForChild("MockDataStoreService"))
end

-- Map DataStoreService methods to associated RequestTypes:
local requestTypes = {
	GetAsync = Enum.DataStoreRequestType.GetAsync;
	SetAsync = Enum.DataStoreRequestType.SetIncrementAsync;
	OnUpdate = Enum.DataStoreRequestType.OnUpdate;
	IncrementAsync = Enum.DataStoreRequestType.SetIncrementAsync;
}


local function GetBudget(method)
	return dataStoreService:GetRequestBudgetForRequestType(requestTypes[method])
end


function SafeDataStore.new(name, scope)
	
	local self = setmetatable({
		DataStore = dataStoreService:GetDataStore(name, scope);
	}, SafeDataStore)

	self.Failed = self.Shared.Event.new()
	
	return self
	
end


function SafeDataStore:Try(method, k, v)
	local budget = GetBudget(method)
	if (budget == 0) then
		-- Do something in later implementation
	end
	local value = nil
	for i = 1,MAX_ATTEMPTS do
		local success,v = pcall(function()
			return self.DataStore[method](self.DataStore, k, v)
		end)
		if (success) then
			value = v
			break
		elseif (i == MAX_ATTEMPTS) then
			warn("DataStore " .. method .. " failed: " .. tostring(v))
			self.Failed:Fire(method, k, tostring(v))
		else
			wait(ATTEMPT_INTERVAL)
		end
	end
	return value
end


function SafeDataStore:OnUpdate(key, callback)
	return self.DataStore:OnUpdate(key, callback)
end


function SafeDataStore:GetAsync(key)
	return self:Try("GetAsync", key)
end


function SafeDataStore:IncrementAsync(key, delta)
	return self:Try("IncrementAsync", key, delta)
end


function SafeDataStore:SetAsync(key, value)
	return self:Try("SetAsync", key, value)
end


function SafeDataStore:RemoveAsync(key)
	return self:Try("RemoveAsync", key)
end


function SafeDataStore:UpdateAsync(key, transformFunction)
	return self:Try("UpdateAsync", key, transformFunction)
end


return SafeDataStore