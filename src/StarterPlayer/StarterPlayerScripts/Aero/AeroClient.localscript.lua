-- Aero Client
-- Crazyman32
-- July 21, 2017



local Aero = {
	Controllers = {};
	Modules     = {};
	Shared      = {};
	Services    = {};
}


local controllersFolder = script.Parent:WaitForChild("Controllers")
local modulesFolder = script.Parent:WaitForChild("Modules")
local sharedFolder = game:GetService("ReplicatedStorage"):WaitForChild("Aero"):WaitForChild("Shared")


function Aero:RegisterEvent(eventName)
	local event = self.Shared.Event.new()
	self._events[eventName] = event
	return event
end


function Aero:FireEvent(eventName, ...)
	self._events[eventName]:Fire(...)
end


function Aero:ConnectEvent(eventName, func)
	return self._events[eventName]:Connect(func)
end


function LoadService(serviceFolder)
	local service = {}
	Aero.Services[serviceFolder.Name] = service
	for _,v in pairs(serviceFolder:GetChildren()) do
		if (v:IsA("RemoteEvent")) then
			local event = Aero.Shared.Event.new()
			local fireEvent = event.Fire
			function event:Fire(...)
				v:FireServer(...)
			end
			v.OnClientEvent:Connect(function(...)
				fireEvent(event, ...)
			end)
			service[v.Name] = event
		elseif (v:IsA("RemoteFunction")) then
			service[v.Name] = function(self, ...)
				return v:InvokeServer(...)
			end
		end
	end
end


function LoadServices()
	local remoteServices = game:GetService("ReplicatedStorage"):WaitForChild("AeroRemoteServices")
	for _,serviceFolder in pairs(remoteServices:GetChildren()) do
		if (serviceFolder:IsA("Folder")) then
			LoadService(serviceFolder)
		end
	end
end


-- Setup table to load modules on demand:
function LazyLoadSetup(tbl, folder)
	setmetatable(tbl, {
		__index = function(t, i)
			local obj = require(folder[i])
			if (type(obj) == "table") then
				obj.Aero = Aero
				if (type(obj.Init) == "function") then
					obj:Init(Aero)
				end
			end
			rawset(t, i, obj)
			return obj
		end;
	})
end


function LoadController(module)
	local controller = require(module)
	Aero.Controllers[module.Name] = controller
	controller._events = {}
	setmetatable(controller, {__index = Aero})
	if (type(controller.Init) == "function") then
		controller:Init()
	end
end


function Init()
	
	-- Lazy load modules:
	LazyLoadSetup(Aero.Modules, modulesFolder)
	LazyLoadSetup(Aero.Shared, sharedFolder)
	
	-- Load server-side services:
	LoadServices()
	
	-- Load controllers:
	for _,module in pairs(controllersFolder:GetChildren()) do
		if (module:IsA("ModuleScript")) then
			LoadController(module)
		end
	end
	
	-- Start controllers:
	for _,controller in pairs(Aero.Controllers) do
		if (type(controller.Start) == "function") then
			coroutine.resume(coroutine.create(controller.Start), controller)
		end
	end
	
end


Init()
_G.Aero = Aero