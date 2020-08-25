-- Aero Client
-- Stephen Leitnick
-- July 21, 2017



local Aero = {
	Controllers = {};
	Modules = {};
	Shared = {};
	Services = {};
	Player = game:GetService("Players").LocalPlayer;
}

local NO_CACHE = {}

local mt = {__index = Aero}

local controllersFolder = script.Parent.Parent:WaitForChild("Controllers")
local modulesFolder = script.Parent.Parent:WaitForChild("Modules")
local sharedFolder = game:GetService("ReplicatedStorage"):WaitForChild("Aero"):WaitForChild("Shared")
local internalFolder = game:GetService("ReplicatedStorage").Aero:WaitForChild("Internal")
local modulesAwaitingStart = {}

local SpawnNow = require(sharedFolder:WaitForChild("Thread"):Clone()).SpawnNow
local Promise = require(sharedFolder:WaitForChild("Promise"):Clone())
local Settings = require(internalFolder:WaitForChild("Settings"))

local settingsPerTbl = {}


local function PreventEventRegister()
	error("Cannot register event after Init method")
end


function Aero:RegisterEvent(eventName)
	local event = self.Shared.Signal.new()
	self._events[eventName] = event
	return event
end


function Aero:FireEvent(eventName, ...)
	self._events[eventName]:Fire(...)
end


function Aero:ConnectEvent(eventName, func)
	return self._events[eventName]:Connect(func)
end


function Aero:WaitForEvent(eventName)
	return self._events[eventName]:Wait()
end


function Aero:WrapModule(tbl)
	assert(type(tbl) == "table", "Expected table for argument")
	tbl._events = {}
	setmetatable(tbl, mt)
	local objSettings = (settingsPerTbl[tbl] or Settings:GetDefault())
	if (type(tbl.Init) == "function" and not (objSettings.PreventInit or tbl.__aeroPreventInit)) then
		tbl:Init()
	end
	if (type(tbl.Start) == "function" and not (objSettings.PreventStart or tbl.__aeroPreventStart)) then
		if (modulesAwaitingStart) then
			modulesAwaitingStart[#modulesAwaitingStart + 1] = tbl
		else
			SpawnNow(tbl.Start, tbl)
		end
	end
	return tbl
end


local function LoadService(serviceFolder, servicesTbl)
	local service = {}
	servicesTbl[serviceFolder.Name] = service
	for _,v in ipairs(serviceFolder:GetChildren()) do
		if (v:IsA("RemoteEvent")) then
			local event = Aero.Shared.Signal.new()
			local fireEvent = event.Fire
			function event:Fire(...)
				v:FireServer(...)
			end
			v.OnClientEvent:Connect(function(...)
				fireEvent(event, ...)
			end)
			service[v.Name] = event
		elseif (v:IsA("RemoteFunction")) then
			local cacheTTL = v:FindFirstChild("Cache")
			if (cacheTTL) then
				cacheTTL = cacheTTL.Value
				local methodName = v.Name
				local cache = NO_CACHE
				local lastCacheTime = 0
				local fetchingPromise
				service[methodName] = function(self, ...)
					local now = tick()
					if (fetchingPromise) then
						local _,c = fetchingPromise:Await()
						return table.unpack(c)
					elseif (cache == NO_CACHE or (cacheTTL > 0 and (now - lastCacheTime) > cacheTTL)) then
						lastCacheTime = now
						local args = table.pack(...)
						fetchingPromise = Promise.new(function(resolve, _reject)
							resolve(table.pack(v:InvokeServer(table.unpack(args))))
						end)
						local success, _cache = fetchingPromise:Await()
						if (success) then
							cache = _cache
						end
						fetchingPromise = nil
						return table.unpack(_cache)
					end
					return table.unpack(cache)
				end
			else
				service[v.Name] = function(self, ...)
					return v:InvokeServer(...)
				end
			end
		end
	end
	return service
end


local function LoadServices()
	local remoteServices = game:GetService("ReplicatedStorage"):WaitForChild("Aero"):WaitForChild("AeroRemoteServices")
	local function LoadAllServices(folder, servicesTbl)
		for _,serviceFolder in ipairs(folder:GetChildren()) do
			if (serviceFolder:IsA("Folder")) then
				local service = LoadService(serviceFolder, servicesTbl)
				if (next(service) == nil) then
					LoadAllServices(serviceFolder, service)
				end
			end
		end
	end
	LoadAllServices(remoteServices, Aero.Services)
end


-- Setup table to load modules on demand:
local function LazyLoadSetup(tbl, folder)
	setmetatable(tbl, {
		__index = function(t, i)
			local child = folder[i]
			if (child:IsA("ModuleScript")) then
				local objSettings = Settings:Get(child)
				local obj = require(child)
				settingsPerTbl[obj] = objSettings
				rawset(t, i, obj)
				if (type(obj) == "table" and not objSettings.Standalone) then
					-- only wrap module if it's actually a table, and not a table disguised as a function
					local objMetatable = getmetatable(obj)
					if (not (objMetatable and objMetatable.__call)) then
						Aero:WrapModule(obj)
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


local function LoadController(module, controllersTbl)
	local controllerSettings = Settings:Get(module)
	local controller = require(module)
	controllersTbl[module.Name] = controller
	controller._events = {}
	setmetatable(controller, mt)
	settingsPerTbl[controller] = controllerSettings
end


local function InitController(controller)
	if (type(controller.Init) == "function") then
		controller:Init()
	end
	controller.RegisterEvent = PreventEventRegister
end


local function StartController(controller)
	-- Start controllers on separate threads:
	if (type(controller.Start) == "function") then
		SpawnNow(controller.Start, controller)
	end
end


local function Init()
	
	-- Load controllers:
	local function LoadAllControllers(parent, controllersTbl)
		for _,child in ipairs(parent:GetChildren()) do
			if (child:IsA("ModuleScript")) then
				if (not Settings:IsSettingsModule(child)) then
					LoadController(child, controllersTbl)
				end
			elseif (child:IsA("Folder")) then
				local tbl = {}
				controllersTbl[child.Name] = tbl
				LoadAllControllers(child, tbl)
			end
		end
	end
	
	-- Initialize controllers:
	local function InitAllControllers(controllers)
		-- Collect all controllers:
		local controllerTables = {}
		local function CollectControllers(ctrls)
			for _,controller in pairs(ctrls) do
				if (getmetatable(controller) == mt) then
					controllerTables[#controllerTables + 1] = controller
				else
					CollectControllers(controller)
				end
			end
		end
		CollectControllers(controllers)
		-- Sort controllers by optional Order setting or __aeroOrder field:
		local function GetOrder(controller)
			local ctrlSettings = settingsPerTbl[controller]
			local order
			if (type(ctrlSettings.Order) == "number") then
				order = ctrlSettings.Order
			elseif (type(controller.__aeroOrder) == "number") then
				order = controller.__aeroOrder
			else
				order = Settings.InternalSettings.DefaultOrder
			end
			return order
		end
		table.sort(controllerTables, function(a, b)
			return (GetOrder(a) < GetOrder(b))
		end)
		-- Initialize controllers:
		for _,controller in ipairs(controllerTables) do
			InitController(controller)
		end
	end
	
	-- Start controllers:
	local function StartAllControllers(controllers)
		for _,controller in pairs(controllers) do
			if (getmetatable(controller) == mt) then
				StartController(controller)
			else
				StartAllControllers(controller)
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

	------------------------------------------------------
	
	-- Lazy load modules:
	LazyLoadSetup(Aero.Modules, modulesFolder)
	LazyLoadSetup(Aero.Shared, sharedFolder)
	
	-- Load server-side services:
	LoadServices()

	-- Load, init, and start controllers:
	LoadAllControllers(controllersFolder, Aero.Controllers)
	InitAllControllers(Aero.Controllers)
	StartAllControllers(Aero.Controllers)
	StartLoadedModules()

	-- Expose client framework globally:
	_G.Aero = Aero
	
end


Init()
