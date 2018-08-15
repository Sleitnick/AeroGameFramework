-- Aero Server
-- Crazyman32
-- July 21, 2017



local AeroServer = {
	Services		= {};
	Modules			= {};
	Shared			= {};
	Events			= {};
	ClientEvents	= {};
}

local mt = {__index = AeroServer}

local servicesFolder = game:GetService("ServerStorage"):WaitForChild("Aero"):WaitForChild("Services")
local modulesFolder = game:GetService("ServerStorage"):WaitForChild("Aero"):WaitForChild("Modules")
local sharedFolder = game:GetService("ReplicatedStorage"):WaitForChild("Aero"):WaitForChild("Shared")

local remoteServices = Instance.new("Folder")
remoteServices.Name = "AeroRemoteServices"


function AeroServer:RegisterEvent(eventName)
	assert(not self._events[eventName], string.format("The event name '%s' is already registered.", eventName))

	local event = self.Shared.Event.new()
	self._events[eventName] = event
	return event
end


function AeroServer:RegisterClientEvent(eventName)
	assert(not self._clientEvents[eventName], string.format("The client event name '%s' is already registered.", eventName))

	local event = Instance.new("RemoteEvent")
	event.Name = eventName
	event.Parent = self._remoteFolder
	self._clientEvents[eventName] = event
	return event
end


function AeroServer:FireEvent(eventName, ...)
	self._events[eventName]:Fire(...)
end


function AeroServer:FireClientEvent(eventName, client, ...)
	self._clientEvents[eventName]:FireClient(client, ...)
end


function AeroServer:FireAllClientsEvent(eventName, ...)
	self._clientEvents[eventName]:FireAllClients(...)
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


function AeroServer:RegisterClientFunction(funcName, func)
	local remoteFunc = Instance.new("RemoteFunction")
	remoteFunc.Name = funcName
	remoteFunc.OnServerInvoke = function(...)
		return func(self.Client, ...)
	end
	remoteFunc.Parent = self._remoteFolder
	return remoteFunc
end


function AeroServer:WrapModule(tbl)
	assert(type(tbl) == "table", "Expected table for argument")
	tbl._events = AeroServer.Events
	tbl._clientEvents = AeroServer.ClientEvents
	setmetatable(tbl, mt)
	if (type(tbl.Init) == "function") then
		tbl:Init()
	end
	if (type(tbl.Start) == "function") then
		coroutine.wrap(tbl.Start)(tbl)
	end
end

-- Setup table to load modules on demand:
function LazyLoadSetup(tbl, folder)
	setmetatable(tbl, {
		__index = function(t, i)
			local obj = require(folder[i])
			if (type(obj) == "table") then
				AeroServer:WrapModule(obj)
			end
			rawset(t, i, obj)
			return obj
		end;
	})
end


-- Load service from module:
function LoadService(module)
	
	local remoteFolder = Instance.new("Folder")
	remoteFolder.Name = module.Name
	remoteFolder.Parent = remoteServices
	
	local service = require(module)
	AeroServer.Services[module.Name] = service
	
	if (type(service.Client) ~= "table") then
		service.Client = {}
	end
	service.Client.Server = service
	
	setmetatable(service, mt)
	
	service._events = AeroServer.Events
	service._clientEvents = AeroServer.ClientEvents
	service._remoteFolder = remoteFolder
	
end


function InitService(service)
	
	-- Initialize:
	if (type(service.Init) == "function") then
		service:Init()
	end
	
	-- Client functions:
	for funcName,func in pairs(service.Client) do
		if (type(func) == "function") then
			service:RegisterClientFunction(funcName, func)
		end
	end
	
end


function StartService(service)

	-- Start services on separate threads:
	if (type(service.Start) == "function") then
		coroutine.wrap(service.Start)(service)
	end

end


function Init()
	
	-- Lazy-load server and shared modules:
	LazyLoadSetup(AeroServer.Modules, modulesFolder)
	LazyLoadSetup(AeroServer.Shared, sharedFolder)
	
	-- Load service modules:
	for _,module in pairs(servicesFolder:GetChildren()) do
		if (module:IsA("ModuleScript")) then
			LoadService(module)
		end
	end
	
	-- Initialize services:
	for _,service in pairs(AeroServer.Services) do
		InitService(service)
	end
	
	-- Start services:
	for _,service in pairs(AeroServer.Services) do
		StartService(service)
	end
	
	-- Expose server framework to client and global scope:
	remoteServices.Parent = game:GetService("ReplicatedStorage").Aero
	_G.AeroServer = AeroServer

end


Init()