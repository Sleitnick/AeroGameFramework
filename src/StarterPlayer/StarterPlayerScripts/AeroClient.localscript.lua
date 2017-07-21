-- Aero Client
-- Crazyman32
-- July 21, 2017



local Aero = {
	Modules  = {};
	Objects  = {};
	Shared   = {};
	Services = {};
}


local modulesFolder = script.Parent:WaitForChild("Modules")
local objectsFolder = script.Parent:WaitForChild("Objects")
local sharedFolder = game:GetService("ReplicatedStorage"):WaitForChild("Shared")


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


function LoadModule(module)
	local mod = require(module)
	Aero.Modules[module.Name] = mod
	setmetatable(mod, {__index = Aero})
	if (type(mod.Init) == "function") then
		mod:Init()
	end
end


function Init()
	
	-- Lazy load objects:
	LazyLoadSetup(Aero.Objects, objectsFolder)
	LazyLoadSetup(Aero.Shared, sharedFolder)
	
	-- Load server-side services:
	LoadServices()
	
	-- Load modules:
	for _,module in pairs(modulesFolder:GetChildren()) do
		if (module:IsA("ModuleScript")) then
			LoadModule(module)
		end
	end
	
	-- Start modules:
	for _,mod in pairs(Aero.Modules) do
		if (type(mod.Start) == "function") then
			coroutine.resume(coroutine.create(mod.Start), mod)
		end
	end
	
end


Init()
_G.Aero = Aero