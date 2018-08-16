# Server Service

A Service is a singleton initiated at runtime. Services should serve specific purposes. For instance, the provided DataService allows simplified player data management.

-----------------------------------------------

## API
A service in its simplest form:

```lua
local MyService = {Client = {}}

function MyService:Start()
	-- Called when all services have been initialized
end

function MyService:Init()
	-- Called when the module is first loaded.
	-- Safe to reference 'self.Services/Modules/Shared'
	-- NOT safe to USE/INVOKE other services yet (use them in/after Start method)
end

return MyService
```

#### Injected Properties:
- `service.Services` Table of all other services, referenced by the name of the ModuleScript
- `service.Modules` Table of all modules, referenced by the name of the ModuleScript
- `service.Shared` Table of all shared modules, referenced by the name of the ModuleScript
- `service.Client.Server` Reference back to the service, so client-facing methods can invoke server-facing methods

#### Injected Methods:
- `Void service:RegisterEvent(String eventName)`
- `Void service:RegisterClientEvent(String eventName)`
- `Void service:FireEvent(String eventName, ...)`
- `Void service:FireClientEvent(String eventName, Instance player, ...)`
- `Void service:FireAllClientsEvent(String eventName, ...)`
- `Connection service:ConnectEvent(String eventName, Function handler)`
- `Connection service:ConnectClientEvent(String eventName, Function handler)`

Every service should have a Start and Init method; however, they are not required.

### Init
The `Init` method is called on each service in the framework in a synchronous and linear progression. In other words, each service's `Init` method is invoked one after the other. Each `Init` method must fully execute before moving onto the next. This is essentially the constructor for the service singleton.

This method should be used to set up your service. For instance, you might want to create events or reference other services.

The `Init` method should _not_ invoke any methods from other services yet, because it is not guaranteed that those services have had their `Init` methods invoked yet. It is safe to _reference_ other services, but not invoke their methods.

### Start
The `Start` method is called after all services have been initiated (i.e. their `Init` methods have been fully executed).

Each `Start` method is executed on a _separate_ thread. From here, it is safe to reference and invoke other services in the framework.

### Custom Methods
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

Other services can also invoke your custom service methods.

### Server Events
You can create and listen to events using the `RegisterEvent`, `ConnectEvent`, and `FireEvent` methods. All events should _always_ be registered within the `Init` method. The `ConnectEvent` and `FireEvent` methods should _never_ be used within an `Init` method.
```lua
function MyService:Start()
	-- Connect to 'Hello' event:
	self:ConnectEvent("Hello", function(msg)
		print(msg)
	end)
	-- Fire 'Hello' event:
	self:FireEvent("Hello", "Hello world!")
end

function MyService:Init()
	-- Register 'Hello' event:
	self:RegisterEvent("Hello")
end
```

### Client Table
The `Client` table is used to expose methods and events to the client.

#### Client Methods
To expose a method to the client, write a function attached to the Client table:
```lua
function MyService.Client:Echo(player, message)
	return message
end
```
Note that the `player` argument must _always_ be the first argument for client methods. Any other arguments reflect what the client has sent.

#### Client Events
To expose an event to the client, use the `RegisterClientEvent` method in the `Init` method. Use `FireClientEvent` and `FireAllClientsEvent` to fire the event:
```lua
function MyService:Start()
	-- Fire client event for a specific player:
	self:FireClientEvent("MyClientEvent", somePlayer, "Hello")

	-- Fire client event for all players:
	self:FireAllClientsEvent("MyClientEvent", "Hello")
end

function MyService:Init()
	-- Register client event:
	self:RegisterClientEvent("MyClientMethod")
end
```

#### Reference Server Table
When executing code within a client-exposed method, it is useful to be able to reference back to the main service table. Therefore, the `Server` property has been injected into the `Client` table:
```lua
-- Client-exposed 'Echo' method invoking 'Print' method:
function MyService.Client:Echo(player, message)
	self.Server:Print(msg) -- Note the reference to 'self.Server'
	return message
end

function MyService:Print(msg)
	return msg
end
```

-----------------------------------------------

## Other Examples

#### Invoking another service:
```lua
function MyService:Start()
	-- Get some global data from the DataService:
	local dataService = self.Services.DataService
	local data = dataService:GetGlobal("Test")
end
```

#### Using a Module:
```lua
function MyService:Start()
	local someModule = self.Modules.SomeModule
	someModule:DoSomething()
end
```

#### Using a Shared module:
```lua
function MyService:Start()
	-- Print the current date:
	local Date = self.Shared.Date
	local now = Date.new()
	print("Now", now)
end
```