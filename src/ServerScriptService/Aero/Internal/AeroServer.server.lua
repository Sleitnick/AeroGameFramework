-- Aero Server
-- Stephen Leitnick
-- July 21, 2017



local AeroServer = {
	Services = {};
	Modules = {};
	Shared = {};
}

local mt = {__index = AeroServer}

local servicesFolder = game:GetService("ServerStorage").Aero.Services
local modulesFolder = game:GetService("ServerStorage").Aero.Modules
local sharedFolder = game:GetService("ReplicatedStorage").Aero.Shared

local remoteServices = Instance.new("Folder")
remoteServices.Name = "AeroRemoteServices"

local players = {}
local modulesAwaitingStart = {}

local SpawnNow = require(sharedFolder.Thread:Clone()).SpawnNow

local function PreventEventRegister()
	error("Cannot register event after Init method")
end

local function PreventFunctionRegister()
	error("Cannot register function after Init method")
end

local function PreventMethodCache()
	error("Cannot mark method as cachable after Init method")
end


function AeroServer:RegisterEvent(eventName)
	local event = self.Shared.Event.new()
	self._events[eventName] = event
	return event
end


function AeroServer:RegisterClientEvent(eventName)
	local event = Instance.new("RemoteEvent")
	event.Name = eventName
	event.Parent = self._remoteFolder
	self._clientEvents[eventName] = event
	return event
end


function AeroServer:Fire(eventName, ...)
	self._events[eventName]:Fire(...)
end


function AeroServer:FireEvent(eventName, ...)
	warn("FireEvent has been deprecated in favor of Fire")
	self:Fire(eventName, ...)
end


function AeroServer:FireClient(eventName, client, ...)
	self._clientEvents[eventName]:FireClient(client, ...)
end


function AeroServer:FireClientEvent(eventName, client, ...)
	warn("FireClientEvent has been deprecated in favor of FireClient")
	self:FireClient(eventName, client, ...)
end


function AeroServer:FireAllClients(eventName, ...)
	self._clientEvents[eventName]:FireAllClients(...)
end


function AeroServer:FireAllClientsEvent(eventName, ...)
	warn("FireAllClientsEvent has been deprecated in favor of FireAllClients")
	self:FireAllClients(eventName, ...)
end


function AeroServer:FireOtherClients(eventName, clientIgnore, ...)
	local event = self._clientEvents[eventName]
	for _,player in ipairs(players) do
		if (player ~= clientIgnore) then
			event:FireClient(player, ...)
		end
	end
end


function AeroServer:FireAllClientsEventExcept(eventName, client, ...)
	warn("FireAllClientsEventExcept has been deprecated in favor of FireOtherClients")
	self:FireOtherClients(eventName, client, ...)
end


function AeroServer:ConnectEvent(eventName, func)
	return self._events[eventName]:Connect(func)
end


function AeroServer:ConnectClientEvent(eventName, func)
	return self._clientEvents[eventName].OnServerEvent:Connect(func)
end


function AeroServer:WaitForEvent(eventName)
	return self._events[eventName]:Wait()
end


function AeroServer:WaitForClientEvent(eventName)
	return self._clientEvents[eventName]:Wait()
end


function AeroServer:RegisterClientFunction(funcName, func, cacheTTL)
	local remoteFunc = Instance.new("RemoteFunction")
	remoteFunc.Name = funcName
	remoteFunc.OnServerInvoke = function(...)
		return func(self.Client, ...)
	end
	if (cacheTTL ~= nil) then
		local cache = Instance.new("NumberValue")
		cache.Name = "Cache"
		cache.Value = cacheTTL
		cache.Parent = remoteFunc
	end
	remoteFunc.Parent = self._remoteFolder
	return remoteFunc
end


function AeroServer:WrapModule(tbl)
	assert(type(tbl) == "table", "Expected table for argument")
	tbl._events = {}
	setmetatable(tbl, mt)
	if (type(tbl.Init) == "function" and not tbl.__aeroPreventInit) then
		tbl:Init()
	end
	if (type(tbl.Start) == "function" and not tbl.__aeroPreventStart) then
		if (modulesAwaitingStart) then
			modulesAwaitingStart[#modulesAwaitingStart + 1] = tbl
		else
			SpawnNow(tbl.Start, tbl)
		end
	end
end


function AeroServer:CacheClientMethod(methodName, ttl)
	assert(self._clientCaches, "CacheClientMethod must be called within Init method")
	assert(type(methodName) == "string", "CacheClientMethod argument #1 must be a string")
	assert(self.Client and type(self.Client[methodName]) == "function", "CacheClientMethod argument #1 must be a client method")
	if (ttl == nil) then ttl = 0 end
	assert(type(ttl) == "number" and ttl >= 0, "CacheClientMethod argument #2 must be a number >= 0")
	self._clientCaches[methodName] = (ttl or 0)
end


-- Setup table to load modules on demand:
local function LazyLoadSetup(tbl, folder)
	setmetatable(tbl, {
		__index = function(t, i)
			local child = folder[i]
			if (child:IsA("ModuleScript")) then
				local obj = require(child)
				rawset(t, i, obj)
				if (type(obj) == "table") then
					-- Only wrap module if it's actually a table, and not a table disguised as a function:
					local objMetatable = getmetatable(obj)
					if (not (objMetatable and objMetatable.__call)) then
						AeroServer:WrapModule(obj)
					end
				end
				return obj
			elseif (child:IsA("Folder")) then
				local nestedTbl = {}
				rawset(t, i, nestedTbl)
				LazyLoadSetup(nestedTbl, child)
				return nestedTbl
			end
		end;
	})
end


-- Load service from module:
local function LoadService(module, servicesTbl, parentFolder)
	
	local remoteFolder = Instance.new("Folder")
	remoteFolder.Name = module.Name
	remoteFolder.Parent = parentFolder
	
	local service = require(module)
	servicesTbl[module.Name] = service
	
	if (type(service.Client) ~= "table") then
		service.Client = {}
	end
	service.Client.Server = service
	
	setmetatable(service, mt)
	
	service._events = {}
	service._clientEvents = {}
	service._clientCaches = {}
	service._remoteFolder = remoteFolder
	
end


local function InitService(service)
	
	-- Initialize:
	if (type(service.Init) == "function") then
		service:Init()
	end
	
	-- Client functions:
	for funcName,func in pairs(service.Client) do
		if (type(func) == "function") then
			service:RegisterClientFunction(funcName, func, service._clientCaches[funcName])
		end
	end

	-- Disallow registering events/functions after init:
	service.RegisterEvent = PreventEventRegister
	service.RegisterClientEvent = PreventEventRegister
	service.RegisterClientFunction = PreventFunctionRegister
	service.CacheClientMethod = PreventMethodCache
	
end


local function StartService(service)

	-- Start services on separate threads:
	if (type(service.Start) == "function") then
		SpawnNow(service.Start, service)
	end

end


local function Init()

	local function PlayerAdded(player)
		players[#players + 1] = player
	end

	local function PlayerRemoving(player)
		local nPlayers = #players
		for i = 1,nPlayers do
			if (players[i] == player) then
				players[i] = players[nPlayers]
				players[nPlayers] = nil
			end
		end
	end
	
	-- Load service modules:
	local function LoadAllServices(parent, servicesTbl, parentFolder)
		for _,child in ipairs(parent:GetChildren()) do
			if (child:IsA("ModuleScript")) then
				LoadService(child, servicesTbl, parentFolder)
			elseif (child:IsA("Folder")) then
				local tbl = {}
				local folder = Instance.new("Folder")
				folder.Name = child.Name
				folder.Parent = parentFolder
				servicesTbl[child.Name] = tbl
				LoadAllServices(child, tbl, folder)
			end
		end
	end
	
	-- Initialize services:
	local function InitAllServices(services)
		-- Collect all services:
		local serviceTables = {}
		local function CollectServices(_services)
			for _,service in pairs(_services) do
				if (getmetatable(service) == mt) then
					serviceTables[#serviceTables + 1] = service
				else
					CollectServices(service)
				end
			end
		end
		CollectServices(services)
		-- Sort services by optional __aeroOrder field:
		table.sort(serviceTables, function(a, b)
			local aOrder = (type(a.__aeroOrder) == "number" and a.__aeroOrder or math.huge)
			local bOrder = (type(b.__aeroOrder) == "number" and b.__aeroOrder or math.huge)
			return (aOrder < bOrder)
		end)
		-- Initialize services:
		for _,service in ipairs(serviceTables) do
			InitService(service)
		end
	end

	-- Remove unused folders:
	local function ScanRemoteFoldersForEmpty(parent)
		for _,child in ipairs(parent:GetChildren()) do
			if (child:IsA("Folder")) then
				local remoteFunction = child:FindFirstChildWhichIsA("RemoteFunction", true)
				local remoteEvent = child:FindFirstChildWhichIsA("RemoteEvent", true)
				if ((not remoteFunction) and (not remoteEvent)) then
					child:Destroy()
				else
					ScanRemoteFoldersForEmpty(child)
				end
			end
		end
	end
	
	-- Start services:
	local function StartAllServices(services)
		for _,service in pairs(services) do
			if (getmetatable(service) == mt) then
				StartService(service)
			else
				StartAllServices(service)
			end
		end
	end

	-- Start modules that were already loaded:
	local function StartLoadedModules()
		for _,tbl in pairs(modulesAwaitingStart) do
			SpawnNow(tbl.Start, tbl)
		end
		modulesAwaitingStart = nil
	end

	--------------------------------------------------------------------

	players = game:GetService("Players"):GetPlayers()
	game:GetService("Players").PlayerAdded:Connect(PlayerAdded)
	game:GetService("Players").PlayerRemoving:Connect(PlayerRemoving)
	
	-- Lazy-load server and shared modules:
	LazyLoadSetup(AeroServer.Modules, modulesFolder)
	LazyLoadSetup(AeroServer.Shared, sharedFolder)

	-- Load, init, and start services:
	LoadAllServices(servicesFolder, AeroServer.Services, remoteServices)
	InitAllServices(AeroServer.Services)
	ScanRemoteFoldersForEmpty(remoteServices)
	StartAllServices(AeroServer.Services)
	StartLoadedModules()
	
	-- Expose server framework to client and global scope:
	remoteServices.Parent = game:GetService("ReplicatedStorage").Aero
	_G.AeroServer = AeroServer
	_G.Aero = AeroServer
	
end


Init()
