# Modules

This section covers the three environments where modules exist: `Server`, `Client`, and `Shared`. Modules behave in the same way in each location.

--------------------------

## Usage

Like other framework objects, modules can also have `Init` and `Start` methods. However, these methods are optional.

The biggest difference with Modules is that they are lazy-loaded. In other words, modules are not necessarily loaded at the beginning of runtime. Instead, they are loaded the first time they are referenced. What this means is that you can have a large collection of modules that you reuse within many projects, but are not necessarily eating up much memory.

Lazy-loading is handled in the background, and it should not affect anything regarding the way you use a module. The most noticeable difference is that the `Init` and `Start` methods will not be invoked until the first time a module is referenced.

Like any ModuleScript on Roblox, modules have the same structure:

```lua
local MyModule = {}

-- 'MyModule:Start()' and 'MyModule:Init()' methods are optional.

return MyModule
```

--------------------------

## Classes

The Modules folder is the preferred location for classes. A Lua pseudo-class will usually look something like this at its core:
```lua
local MyClass = {}
MyClass.__index = MyClass

function MyClass.new()
	local self = setmetatable({
		-- Object properties here
	}, MyClass)
	return self
end

return MyClass
```

### Framework access
With classes, the Aero `Start` and `Init` methods are also available, and are invoked as _static_ methods once. In other words, the methods are not invoked on individual objects created from the class, but are invoked on the class itself. This is useful for referencing AGF modules that the class needs to use. For instance:
```lua
local MyClass = {}

local Maid

function MyClass.new()
	local self = setmetatable({
		maid = Maid.new(); -- Create a maid object
	}, MyClass)
	return self
end

function MyClass:Init()
	-- Reference the Maid object:
	Maid = self.Shared.Maid
end
```

Alternatively, the framework is also injected into the class, thus each object can still access AGF modules, just like other modules:

```lua
function MyClass:DoSomething()
	-- Call a controller within the framework:
	self.Controllers.MyController:Hello()
end
```

### Object Events

Creating events is very useful for custom objects, but it is important that these events are properly registered and cleaned up. It is recommended that the ListenerList and/or Maid class is used, as well as a custom-defined Destroy method on your object:
```lua
function MyClass.new()

	local self = setmetatable({}, MyClass)

	-- Create events:
	self.Start = self.Shared.Event.new()
	self.Stop = self.Shared.Event.new()

	-- Create maid:
	self.Maid = self.Shared.Maid.new()
	self.Maid:GiveTask(self.Start)
	self.Maid:GiveTask(self.Stop)

	return self
end

function MyClass:Destroy()
	-- Will destroy the events:
	self.Maid:Destroy()
end
```

Now, a `MyClass` instance could be used as such:
```lua
local obj = MyClass.new()
obj.Start:Connect(function() print("Start!") end)
wait(5)
obj:Destroy()
```

### Client/Server Communication

Allowing class objects to communicate between the server/client boundary is the same as other objects within the framework. For instance, an object on the client invoking the server:
```lua
function MyClass:DoSomething()
	self.Services.MyService:DoSomething()
end
```

--------------------------

## Prevent `Init` or `Start`

If you are trying to use a module that already has a `Start` or `Init` method that doesn't relate to the AeroGameFramework (e.g. a 3rd-party module not designed for the framework), then you can prevent the framework from invoking these methods. This is done by setting the `__aeroPreventInit` and `__aeroPreventStart` flags on the module. Note that those two flags are prefixed by two underscores, similar to Lua metamethods.

```lua
local MyModule = {}

-- Prevent the framework from invoking the 'Start' method:
MyModule.__aeroPreventStart = true

function MyModule:Start()
	-- Won't be invoked by the framework
end

function MyModule:Init()
	-- Still will be invoked by the framework
end

return MyModule
```