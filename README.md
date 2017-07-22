# AeroGameFramework
A game framework for the ROBLOX game platform.

AeroGameFramework makes ROBLOX game development easy and fun. The framework is designed to alleviate the strain of communication between your code and to simplify communication between the server/client model.

# Install & Update
Run the following code snippet in the Command Line within ROBLOX Studio to install or update the framework:
```lua
require(932606289)()
```

# Structure
AeroGameFramework is structured into three categories: Server, Client, and Shared.

- `[Server] ServerStorage.Services`
- `[Server] ServerStorage.Objects`
- `[Client] StarterPlayerScripts.Modules`
- `[Client] StarterPlayerScripts.Objects`
- `[Shared] ReplicatedStorage.Shared`

## Server
`ServerStorage.Services` & `ServerStorage.Objects`

#### Services
Services are modules that are initialized and ran at runtime. All services are exposed to each other. Services can also expose functions and events to the client.

#### Objects
Objects are lazy-loaded modules that services can access as needed.

## Client
`StarterPlayerScripts.Modules` & `StarterPlayerScripts.Objects`

#### Modules
Client modules work similarly to server-side services, whereas all the modules are initialized and started at runtime and all modules are exposed to each other. Services that expose client-side methods and events can be accessed with these modules.

#### Objects
Client-side objects have the exact functionality as server-side objects, except that they are ran on the client.

## Shared
`ReplicatedStorage.Shared`

Shared modules are modules that can be used by both the client and the server. Just like objects, shared modules are lazy-loaded.

# Basic Examples

## Server Service
Here is a basic service:

```lua
local TestService = {}

function TestService:Add(a, b)
  return a + b
end

function TestService:Start()
  -- Ran after all services have been initialized
end

function TestService:Init()
  -- Do anything to set up the service.
  -- It is NOT safe to run code from other services, but they CAN be referenced.
end

return TestService
```

## Service-to-service Communication
Here is an example of a service invoking the method of another service. Note that `self.Services` exposes all the services:

```lua
local AnotherService = {}

local testService

function AnotherService:Start()
  -- Invoke the TestService:
  local sum = testService:Add(5, 3)
  print("5 + 3 = ", sum)
end

function AnotherService:Init()
  -- Reference the TestService:
  testService = self.Services.TestService
end

return AnotherService
```

## Service Events
Here is an example of a service registering, firing, and connecting to an event:

```lua
local MyService = {}

function MyService:Start()

  -- Connect to the event:
  self:ConnectEvent("Hello", function(msg)
    print(msg)
  end)

end

function MyService:Init()

  -- Register the event:
  self:RegisterEvent("Hello")

  -- Fire the event after 5 seconds:
  delay(5, function()
    self:FireEvent("Hello", "How are you?")
  end)

end

return MyService
```

## Service exposing method and event to client
Here's an example where a service exposes a method and event to the client:
```lua
local MyService = {Client={}} -- Notice the 'Client={}'

-- Client-exposed method:
function MyService.Client:Hello(player, ...)
  print(player.Name .. " says hello")
  return "Hello to you too!"
end

function MyService:Start()

  -- Fire client event after 5 seconds:
  delay(5, function()
    self:FireAllClientsEvent("HelloClient", "Hello!")
  end)

  -- Fire client event to individual player:
  delay(5, function()
    self:FireClientEvent("HelloClient", game.Players.SomePlayer, "Hi!")
  end)

end

function MyService:Init()

  -- Expose client event:
  self:RegisterClientEvent("HelloClient")

  -- Connecting to client event:
  self:ConnectClientEvent("HelloClient", function(player, ...)
    -- Foo
  end)

end

return MyService
```

# Client Module
Here is a basic client module that also connects to a server-side service:

```lua
local SomeModule = {}

function SomeModule:Test(x)
  print("Test!")
  return x * 2
end

function SomeModule:Start()

  -- Connect to server event:
  self.Services.MyService.HelloClient:Connect(function(msg)
    print(msg)
    -- Fire event back to server:
    self.Services.MyService.HelloClient:Fire("Hello to you too!")
  end)
  
  -- Fire server method:
  local msg = self.Services.MyService:Hello("Hi there")
  print(msg)
  
end

function SomeModule:Init()
  -- Run code here to set up the module.
  -- Similar to services, it is NOT safe to invoke other modules in this method, but you CAN reference them.
end

return SomeModule
```

# Client module invoking another module
Here is an example of a client module invoking another client module:

```lua
local MyModule = {}

local someModule

function MyModule:Start()
  local result = someModule:Test(32)
  print(result)
end

function MyModule:Init()
  someModule = self.Modules.SomeModule
end

return MyModule
```
