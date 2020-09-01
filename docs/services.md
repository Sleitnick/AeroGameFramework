# Services

A service is a singleton initiated at runtime on the server. Services should serve specific purposes. For instance, the provided DataService allows simplified data management. You might also create a WeaponService, which might be used for holding and figuring out weapon information for the players.

--------------------------

## API

A service in its simplest form looks like this:

```lua
local MyService = {Client = {}}

function MyService:Start()
	-- Called after all services have been initialized
	-- Called asynchronously from other services
	-- Safe to call any other framework modules
end

function MyService:Init()
	-- Called after all modules have been "required" but before 'Start()' has been called on any of them
	-- Safe to reference 'self.Services/Modules/Shared'
	-- NOT safe to USE/CALL other services yet (use them in/after Start method)
	-- Register all events here (but only connect to events in Start)
end

return MyService
```

### Injected Properties

| Property | Description |
| -------- | ----------- |
| `service.Services` | Table of all other services, referenced by the name of the ModuleScript |
| `service.Modules` | Table of all modules, referenced by the name of the ModuleScript |
| `service.Shared` | Table of all shared modules, referenced by the name of the ModuleScript |
| `service.Client.Server` | Reference back to the service, so client-facing methods can invoke server-facing methods |

### Injected Methods

| Returns | Method |
| -------- | ----------- |
| `void` | `service:RegisterEvent(String eventName)` |
| `void` | `service:RegisterClientEvent(String clientEventName)` |
| `void` | `service:Fire(String eventName, ...)` |
| `void` | `service:FireClient(String clientEventName, Player player, ...)` |
| `void` | `service:FireAllClients(String clientEventName, ...)` |
| `void` | `service:FireOtherClients(String clientEventName, Player player, ...)` |
| `Table` | `service:WrapModule(Table tbl)` |
| `Connection` | `service:ConnectEvent(String eventName, Function handler)` |
| `Connection` | `service:ConnectClientEvent(String clientEventName, Function handler)` |

--------------------------

## `service:Init()`

The `Init` method is called on each service in the framework in a synchronous and linear progression. In other words, each service's `Init` method is invoked one after the other. Each `Init` method must fully execute before moving onto the next. This is essentially the constructor for the service singleton.

The method should be used to set up your service. For instance, you might want to create events or reference other services.

Use the `Init` method to register events and initialize any necessary components before the `Start` method is invoked.

!!! warning
	The `Init` method should _not_ invoke any methods from other services yet, because it is not guaranteed that those services have had their `Init` methods invoked yet. It is safe to _reference_ other services, but not to invoke their methods.

--------------------------

## `service:Start()`

The `Start` method is called after all services have been initialized (i.e. their `Init` methods have been fully executed). Each `Start` method is executed on a _separate_ thread (asynchronously). From here, it is safe to reference and invoke other services in the framework.

--------------------------

## Custom Methods

Adding your own methods to a service is very easy. Simply attach a function to the service table:

```lua
-- Custom method:
function MyService:PrintSomething(...)
	print("MyService:", ...)
end

function MyService:Start()
	-- Invoke the custom method:
	self:PrintSomething("Hi", "Hello", 32, true, "ABC")
end
```

Other services can also invoke your custom method:

```lua
function AnotherService:Start()
	self.Services.MyService:PrintSomething("Hello", false, 64)
end
```

--------------------------

## Server Events

You can create and listen to events using the `RegisterEvent`, `ConnectEvent`, and `Fire` methods. All events should always be registered within the `Init` method. The `ConnectEvent` and `Fire` methods should never be used within an `Init` method.

```lua
function MyService:Start()
	-- Connect to 'Hello' event:
	self:ConnectEvent("Hello", function(msg)
		print(msg)
	end)
	-- Fire 'Hello' event:
	self:Fire("Hello", "Hello world!")
end

function MyService:Init()
	-- Register 'Hello' event:
	self:RegisterEvent("Hello")
end
```

--------------------------

## WrapModule

The `WrapModule` method can be used to transform a table into a framework-like module. In other words, it sets the table's metatable to the same metatable used by other framework modules, thus exposing the framework to the given table.

```lua
function MyService:Start()

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

	-- Wrapping and requiring an external module in one line:
	local otherModuleWrapped = self:WrapModule(require(otherModule))

end
```

!!! tip
	This can be useful if you are requiring other non-framework modules in which you want to expose the framework.

--------------------------

## Client Table

The `Client` table is used to expose methods and events to the client.

### Client Methods

To expose a method to the client, write a function attached to the client table:

```lua
function MyService.Client:Echo(player, message)
	return message
end
```

!!! attention
	The `player` argument must _always_ be the first argument for client methods. Any other arguments reflect what the client has sent.

### Client Events

To expose an event to the client, use the `RegisterClientEvent` method in the `Init` method. Use `FireClient` and `FireAllClients` to fire the event:

```lua
function MyService:Start()
	-- Fire client event for a specific player:
	self:FireClient("MyClientEvent", somePlayer, "Hello")

	-- Fire client event for all players:
	self:FireAllClients("MyClientEvent", "Hello")
end

function MyService:Init()
	-- Register client event:
	self:RegisterClientEvent("MyClientMethod")
end
```

### Reference Server Table

When executing code with a client-exposed method, it is useful to be able to reference back to the main service table. Therefore, the `Server` property has been injected into the `Client` table:

```lua
-- Client-exposed 'Echo' method invoking 'Print' method:
function MyService.Client:Echo(player, message)
	self.Server:Print(message) -- Note the reference to 'self.Server'
	return message
end

function MyService:Print(msg)
	return msg
end
```

### Caching Results

In some cases, it is nice for the client to cache the results returned from the server to reduce the server load. This is especially true in cases where the returned values do not change. To enable caching, the `CacheClientMethod` method must be invoked for each client method.

When enabling caching, the TTL (time to live) period can be set. For instance, if TTL is set to `10`, then the client will only invoke the server if the current value returned is older than 10 seconds. If the TTL argument left blank, the first value cached will always be used and will never invoke the server again.

```lua
function MyService.Client:Hello(player)
	return "Hello! " .. math.random()
end

function MyService.Client:Bye(player)
	return "Bye! " .. math.random()
end

function MyService:Init()

	-- The client will cache the result of 'Hello' forever:
	self:CacheClientMethod("Hello")

	-- The client will cache the result of 'Bye' for 60 seconds:
	self:CacheClientMethod("Bye", 60)

end
```

!!! note
	No changes need to be done on the client. The client will automatically pick up on the caching rules defined in the service.

!!! warning
	The `CacheClientMethod` should only be invoked within the `Init` method of a service.

--------------------------

## Forcing `Init` Order

By using the `Order` setting, the `Init` execution order can be defined. By default, the order of execution is undetermined. For instance, you have services called `MyService` and `AnotherService`, you could have `MyService.settings` and `AnotherService.settings` modules with the following configuration:

```lua
-- MyService.settings
return {
	Order = 1;
}
```

```lua
-- AnotherService.settings
return {
	Order = 2;
}
```

With this configuration, it is guaranteed that `MyService` will have `Init` invoked before `AnotherService`.

--------------------------

## Other Examples

### Invoking another service

```lua
function MyService:Start()
	-- Get some global data from the DataService:
	local dataService = self.Services.DataService
	local data = dataService:GetGlobal("Test")
end
```

### Using a Module

```lua
function MyService:Start()
	local someModule = self.Modules.SomeModule
	someModule:DoSomething()
end
```

### Using a Shared module

```lua
function MyService:Start()
	-- Print the current date:
	local Date = self.Shared.Date
	local now = Date.new()
	print("Now", now)
end
```
