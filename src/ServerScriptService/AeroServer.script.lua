-- Aero Server
-- Crazyman32
-- July 21, 2017



local AeroServer = {
	Services = {};
	Modules  = {};
	Shared   = {};
}


local servicesFolder = game:GetService("ServerStorage"):WaitForChild("Services")
local modulesFolder = game:GetService("ServerStorage"):WaitForChild("Modules")
local sharedFolder = game:GetService("ReplicatedStorage"):WaitForChild("Shared")

local remoteServices = Instance.new("Folder")
remoteServices.Name = "AeroRemoteServices"


function AeroServer:RegisterEvent(eventName)
	local event = self.Shared.Event.new()
	self._events[eventName] = event
	return event
end


function AeroServer:RegisterClientEvent(eventName)
	local event = Instance.new("RemoteEvent", self._remoteFolder)
	event.Name = eventName
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


function AeroServer:RegisterClientFunction(funcName, func)
	local remoteFunc = Instance.new("RemoteFunction", self._remoteFolder)
	remoteFunc.Name = funcName
	remoteFunc.OnServerInvoke = func
	return remoteFunc
end


-- Setup table to load modules on demand:
function LazyLoadSetup(tbl, folder, exposeAero)
	setmetatable(tbl, {
		__index = function(t, i)
			local obj = require(folder[i])
			if (type(obj) == "table") then
				if (exposeAero) then
					setmetatable(obj, {__index = AeroServer})
				end
				if (type(obj.Init) == "function") then
					obj:Init(AeroServer)
				end
			end
			rawset(t, i, obj)
			return obj
		end;
	})
end


-- Load service from module:
function LoadService(module)
	
	local remoteFolder = Instance.new("Folder", remoteServices)
	remoteFolder.Name = module.Name
	
	local service = require(module)
	AeroServer.Services[module.Name] = service
	
	if (not service.Client) then service.Client = {} end
	service.Client.Server = service
	
	setmetatable(service, {__index = AeroServer})
	
	service._events = {}
	service._clientEvents = {}
	service._remoteFolder = remoteFolder
	
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


function Init()
	
	-- Lazy-load server and shared modules:
	LazyLoadSetup(AeroServer.Modules, modulesFolder, true)
	LazyLoadSetup(AeroServer.Shared, sharedFolder, false)
	
	-- Load services:
	for _,module in pairs(servicesFolder:GetChildren()) do
		if (module:IsA("ModuleScript")) then
			LoadService(module)
		end
	end
	
	-- Start services:
	for _,service in pairs(AeroServer.Services) do
		if (type(service.Start) == "function") then
			coroutine.resume(coroutine.create(service.Start), service)
		end
	end
	
	remoteServices.Parent = game:GetService("ReplicatedStorage")
	
end


Init()