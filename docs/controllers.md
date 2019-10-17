# Controllers

A service is a singleton initiated at runtime on the server. Services should serve specific purposes. For instance, the provided DataService allows simplified data management. You might also create a WeaponService, which might be used for holding and figuring out weapon information for the players.

A controller is a singleton initiated at runtime on the client. Controllers should serve a specific purpose. For instance, the provided Fade controller allows for control of simple screen fading. Controllers often interact with server-side services as well. Another example of a controller could be a Camera controller, which has the task of specifically controlling the player's camera.

--------------------------

## API

A controller in its simplest form looks like this:

```lua
local MyController = {}

function MyController:Start()
	-- Called after all controllers have been initialized
	-- Called asynchronously from other controllers
	-- Safe to call any other framework modules
end

function MyController:Init()
	-- Called after all modules have been "required" but before 'Start()' has been called on any of them
	-- Safe to reference 'self.Services/Controllers/Modules/Shared'
	-- NOT safe to USE/CALL other services yet (use them in/after Start method)
	-- Register all events here (but only connect to events in Start)
end

return MyController
```

### Injected Properties

| Property | Description |
| -------- | ----------- |
| `controller.Controllers` | Table of all other controllers, referenced by the name of the ModuleScript |
| `controller.Modules` | Table of all modules, referenced by the name of the ModuleScript |
| `controller.Shared` | Table of all shared modules, referenced by the name of the ModuleScript |
| `controller.Services` | Table of all server-side services, referenced by the name of the ModuleScript |
| `controller.Player` | Reference to the LocalPlayer (`game.Players.LocalPlayer`) |

### Injected Methods

| Returns | Method |
| -------- | ----------- |
| `void` | `controller:WrapModule(Table tbl)` |
| `void` | `controller:RegisterEvent(String eventName)` |
| `void` | `controller:FireEvent(String eventName, ...)` |
| `void` | `controller:ConnectEvent(String eventName, Function handler)` |

--------------------------

## `controller:Init()`

The `Init` method is called on each controller in the framework in a synchronous and linear progression. In other words, each controller's `Init` method is invoked one after the other. Each `Init` method must fully execute before moving onto the next. This is essentially the constructor for the controller singleton.

The method should be used to set up your controller. For instance, you might want to create events or reference other controllers.

Use the `Init` method to register events and initialize any necessary components before the `Start` method is invoked.

!!! warning
	The `Init` method should not invoke any methods from other controllers yet, because it is not guaranteed that those controllers have had their `Init` methods invoked yet. It is safe to reference other controllers, but not to invoke their methods.

--------------------------

## `controller:Start()`

The `Start` method is called after all controllers have been initialized (i.e. their `Init` methods have been fully executed). Each `Start` method is executed on a _separate_ thread (asynchronously). From here, it is safe to reference and invoke other controllers in the framework.

--------------------------

## Custom Methods

Adding your own methods to a controller is very easy. Simply attach a function to the controller table:

```lua
-- Custom method:
function MyController:PrintSomething(...)
	print("MyController:", ...)
end

function MyController:Start()
	-- Invoke the custom method:
	self:PrintSomething("Hi", "Hello", 32, true, "ABC")
end
```

Other controllers can also invoke your custom method:

```lua
function AnotherController:Start()
	self.Services.MyService:PrintSomething("Hello", false, 64)
end
```

--------------------------

## Events

You can create and listen to events using the `RegisterEvent`, `ConnectEvent`, and `FireEvent` methods. All events should always be registered within the `Init` method. The `ConnectEvent` and `FireEvent` methods should never be used within an `Init` method.

```lua
function MyController:Start()
	-- Connect to 'Hello' event:
	self:ConnectEvent("Hello", function(msg)
		print(msg)
	end)
	-- Fire 'Hello' event:
	self:FireEvent("Hello", "Hello world!")
end

function MyController:Init()
	-- Register 'Hello' event:
	self:RegisterEvent("Hello")
end
```

Alternatively, the Event object is available under Shared:

```lua
function MyController:Start()
	-- Connect to 'Hello' event:
	self.Hello:Connect(function(msg)
		print(msg)
	end)
	-- Fire 'Hello' event:
	self.Hello:Fire("Hello world!")
end

function MyController:Init()
	-- Create 'Hello' event:
	self.Hello = self.Shared.Event.new()
end
```

--------------------------

## `WrapModule`

The `WrapModule` method can be used to transform a table into a framework-like module. In other words, it sets the table's metatable to the same metatable used by other framework modules, thus exposing the framework to the given table.

```lua
function MyController:Start()

	local thisThing = {}
	function thisThing:Start()
		print("thisThing started")
	end
	function thisThing:Init()
		print("thisThing initialized")
	end

	-- Transform 'thisThing' into a framework object:
	self:WrapModule(thisThing)

	-- Another example where an external module is loaded:
	local anotherThing = require(someModule)
	self:WrapModule(anotherThing)

end
```

!!! tip
	This can be useful if you are requiring other non-framework modules in which you want to expose the framework.

--------------------------

## Other Examples

### Invoking another controller

```lua
function MyController:Start()
	local fade = self.Controllers.Fade
	fade:SetText("Fade Example")
	fade:Out()
	wait(1)
	fade:In()
end
```

### Invoking a service

```lua
function MyController:Start()
	-- Get pints:
	local pointsService = self.Services.PointsService
	local points = pointsService:GetPoints()
	print("Points:", points)
end
```

### Using a module

```lua
function MyController:Start()
	local someModule = self.Modules.SomeModule
	someModule:DoSomething()
end
```

### Using a shared module

```lua
function MyController:Start()
	-- Print the current date:
	local Date = self.Shared.Date
	local now = Date.new()
	print("Now", now)
end
```

### Connecting to a service event

```lua
function MyController:Start()
	local dataService = self.Services.DataService
	dataService.Failed:Connect(function(method, key, errorMessage)
		warn("DataService failed:", method, key, errorMessage)
	end)
end
```

### Firing a service event

```lua
-- Client controller:
function MyController:Start()
	self.Services.CustomService.Hello:Fire("Hello from the client")
end

---------------------------------------------------------------------

-- Server service:
function CustomService:Start()
	self.Services:ConnectClientEvent("Hello", function(player, msg)
		print(player.Name .. " says: " .. msg)
	end)
end

function CustomService:Init()
	self:RegisterClientEvent("Hello")
end
```

--------------------------

## No Server-to-Client Methods

As you may have noticed, there is no way to create a method on a controller that a server-side service can invoke. This is by design. There are a lot of dangers in allowing the server to invoke client-side methods, and thus the framework simply does not supply a way of doing so. Internally, this would be allowed via `remoteFunction:InvokeClient(...)`. If the server needs information from a client, a client controller should fire a service event.

For more information, please read the "Note" and "Warning" section under the [`RemoteFunction:InvokeClient()` documentation page](https://developer.roblox.com/en-us/api-reference/function/RemoteFunction/InvokeClient) and this [YouTube video](https://youtu.be/0H_xcA-0LDE) discussing the issue in more detail.