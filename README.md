# AeroGameFramework
A game framework for the Roblox game platform.

AeroGameFramework makes Roblox game development easy and fun. The framework is designed to alleviate the strain of communication between your code and to simplify communication between the server/client model. Never again will you have to touch RemoteFunctions or RemoteEvents.

# Video Tutorial
Learn how to use the framework in the video tutorial series:
https://www.youtube.com/watch?v=0oOFgZJPIcY&list=PLk3R4TM3pnqv7doCTUHtn-wkydaA08npc

# Install & Update
Run the following code snippet in the Command Line within Roblox Studio to install or update the framework:
```lua
require(932606289)()
```

**Note:** Always be careful when executing code unfamiliar to you. Before running the code snippet above, feel free to inspect the [module that is being executed](https://www.roblox.com/library/932606289/AeroGameFramework-Installer), and inspect the `install.lua` file in the repository.

# Structure
AeroGameFramework is structured into three categories: Server, Client, and Shared.

- `[Server] ServerStorage.Aero.Services`
- `[Server] ServerStorage.Aero.Modules`
- `[Client] StarterPlayerScripts.Aero.Controllers`
- `[Client] StarterPlayerScripts.Aero.Modules`
- `[Shared] ReplicatedStorage.Aero.Shared`

## Server
`ServerStorage.Aero.Services` & `ServerStorage.Aero.Modules`

#### Services
Services are modules that are initialized and ran at runtime. All services are exposed to each other. Services can also expose functions and events to the client.

#### Modules
Modules are lazy-loaded modules that services can access as needed. Modules can also access Shared Modules and call upon Services.

## Client
`StarterPlayerScripts.Aero.Controllers` & `StarterPlayerScripts.Aero.Modules`

#### Controllers
Client controllers work similarly to server-side services, whereas all the modules are initialized and started at runtime and all modules are exposed to each other. Services that expose client-side methods and events can be accessed with these controller modules.

#### Modules
Client-side modules have the exact functionality as server-side modules, except that they are ran on the client.

## Shared
`ReplicatedStorage.Aero.Shared`

Shared modules are modules that can be used by both the client and the server. This means that the code is hosted on the server, and then replicated (copied) to the client when each player connects; so both the server and client can both execute the same code, but strictly in the client, or server. Imagine having a utility module that encodes a string to Base64, and you want both the server and client to both have access to this module but don't want to setup a remote function for the client to call to the server. This is what shared modules are for.

# API
Documentation of how to use server services and client modules.

## API - Server Service
Services are singletons. This means that only one instance of the service is running, and everytime you call a method in the service, it is always from the same instance.
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
- `service.Modules` Table of all objects, referenced by the name of the ModuleScript
- `service.Shared` Table of all shared modules, referenced by the name of the ModuleScript
- `service.Client.Server` References back to the service, so client-facing methods can invoke server-facing methods
#### Injected Methods:
- `Void        service:RegisterEvent(String eventName)`
- `Void        service:RegisterClientEvent(String eventName)`
- `Void        service:FireEvent(String eventName, ...)`
- `Void        service:FireClientEvent(String eventName, Instance player, ...)`
- `Void        service:FireAllClientsEvent(String eventName, ...)`
- `Connection  service:ConnectEvent(String eventName, Function function)`
- `Connection  service:ConnectClientEvent(String eventName, Function function)`

## API - Server Module
Modules are different than services, in that they are constructed new each time you use them. Calling a Module.new() instantiates the object as a brand new object. Unlike services, server modules are lazily loaded, which means they are not instantiated until you call them with the .new() constructor.
```lua
local MyServerModule = {}

local MyServerModule.__index = MyServerModule

function MyServerModule.new()
  local self = setmetatable({
    -- add properties you can access later wtih self.MyProperty
  }, MyServerModule)
end

-- add methods
function MyServerModule:MyMethod(a, b)
  return a + b
end

return MyServerModule
```
#### Injected Properties:
- `module.Services` Table of all other services, referenced by the name of the ModuleScript
- `module.Modules` Table of all objects, referenced by the name of the ModuleScript
- `module.Shared` Table of all shared modules, referenced by the name of the ModuleScript
#### Injected Methods:
- `Void        module:RegisterEvent(String eventName)`
- `Void        module:RegisterClientEvent(String eventName)`
- `Void        module:FireEvent(String eventName, ...)`
- `Void        module:FireClientEvent(String eventName, Instance player, ...)`
- `Void        module:FireAllClientsEvent(String eventName, ...)`
- `Connection  module:ConnectEvent(String eventName, Function function)`
- `Connection  module:ConnectClientEvent(String eventName, Function function)`

## API - Server Shared
Shared Modules are just like Server Modules, accept they are replicated between the server and client. This means that the same code that is on the server, is also on the client. However, the injected properties and methods are different, depending on if the code is on the server or client. Shared modules are good for utilities that both the server and the client need, so you can avoid adding repetitive code to your project. Just like server module, a shared module is is lazily loaded and instantiate new everytime you want to use it with the Module.new() method.
```lua
local MySharedModule = {}

local MySharedModule.__index = MySharedModule

function MySharedModule.new()
  local self = setmetatable({
    -- add properties you can access later wtih self.MyProperty
  }, MyServerModule)
end

function MySharedModule:MyMethod(a, b)
  return a + b
end

return MySharedModule
```
#### Injected Properties:
- `shared.Services` Table of all other services, referenced by the name of the ModuleScript
- `shared.Modules` Table of all objects, referenced by the name of the ModuleScript
- `shared.Shared` Table of all shared modules, referenced by the name of the ModuleScript
#### Injected Methods:
- `Void        shared:RegisterEvent(String eventName)`
- `Void        shared:FireEvent(String eventName, ...)`
- `Connection  shared:ConnectEvent(String eventName, Function function)`

Although shared modules can use the framework events, you must do so very carefully since the module runs on both the server and client. If you have a shared module that executes `shared:FireEvent`, then that event would be fired on both the client and server whenever that code is ran. So you would need to make sure you have properly execute `shared:RegisterEvent` before the FireEvent is fired on both the client and server somewhere in order to avoid error.

A shared module should be very careful when referencing injected properties like `shared.Services`, `shared.Modules` and etc. Injected properties point to objects which might not be available on the client or server at runtime, depending on the reference. Normally, it is desireable to reference only `shared.Shared` within a shared module.

## API - Client Controller
```lua
local MyController = {}

function MyController:Start()
  -- Called when all controllers have been initialized
end

function MyController:Init()
  -- Called when the controller is first loaded.
  -- Safe to reference 'self.Controllers/Modules/Objects/Shared'
  -- NOT safe to USE/INVOKE other controllers yet (use them in/after Start method)
end

return MyController
```
#### Injected Properties:
- `controller.Controllers` Table of all other controllers, referenced by the name of the ModuleScript
- `controller.Modules` Table of all modules, referenced by the name of the ModuleScript
- `controller.Shared` Table of all shared modules, referenced by the name of the ModuleScript
- `controller.Services` Table of all service-side services, referenced by the name of the ModuleScript
- `controller.Player` Reference to the LocalPlayer (i.e. `game.Players.LocalPlayer`)

#### Injected Methods:
- `Void        controller:RegisterEvent(String eventName)`
- `Void        controller:FireEvent(String eventName, ...)`
- `Connection  controller:ConnectEvent(String eventName, Function function)`

## API - Client Module
Modules are different than controllers, in that they are constructed new each time you use them, just like server modules. Calling a Module.new() instantiates the object as a brand new object. Unlike controllers, server modules are lazily loaded, which means they are not instantiated until you call them with the .new() constructor.
```lua
local MyClientModule = {}

local MyClientModule.__index = MyClientModule

function MyClientModule.new()
  local self = setmetatable({
    -- add properties you can access later wtih self.MyProperty
  }, MyClientModule)
end

function MyClientModule:MyMethod(a, b)
  return a + b
end

return MyClientModule
```
#### Injected Properties:
- `module.Controllers` Table of all other controllers, referenced by the name of the ModuleScript
- `module.Modules` Table of all modules, referenced by the name of the ModuleScript
- `module.Shared` Table of all shared modules, referenced by the name of the ModuleScript
- `module.Services` Table of all service-side services, referenced by the name of the ModuleScript

#### Injected Methods:
- `Void        module:RegisterEvent(String eventName)`
- `Void        module:FireEvent(String eventName, ...)`
- `Connection  module:ConnectEvent(String eventName, Function function)`

## API - Client Shared Module
Shared Modules are just like Server Modules, accept they are replicated between the server and client. This means that the same code that is on the server, is also on the client. However, the injected properties and methods are different, depending on if the code is on the server or client. Shared modules are good for utilities that both the server and the client need, so you can avoid adding repetitive code to your project. Just like server module, a shared module is is lazily loaded and instantiate new everytime you want to use it with the Module.new() method.
```lua
local MyClientSharedModule = {}

local MyClientSharedModule.__index = MyClientSharedModule

function MyClientSharedModule.new()
  local self = setmetatable({
    -- add properties you can access later wtih self.MyProperty
  }, MyClientSharedModule)
end

function MyClientSharedModule:MyMethod(a, b)
  return a + b
end

return MyClientSharedModule
```
#### Injected Properties:
- `shared.Controllers` Table of all other controllers, referenced by the name of the ModuleScript
- `shared.Modules` Table of all modules, referenced by the name of the ModuleScript
- `shared.Shared` Table of all shared modules, referenced by the name of the ModuleScript
- `shared.Services` Table of all service-side services, referenced by the name of the ModuleScript

Although shared modules can use the framework events, you must do so very carefully since the module runs on both the server and client. If you have a shared module that executes `shared:FireEvent`, then that event would be fired on both the client and server whenever that code is ran. So you would need to make sure you have properly execute `shared:RegisterEvent` before the FireEvent is fired on both the client and server somewhere in order to avoid error.

A shared module should be very careful when referencing injected properties like `shared.Controllers`, `shared.Modules` and etc. Injected properties point to objects which might not be available on the client or server at runtime, depending on the reference. Normally, it is desireable to reference only `shared.Shared` within a shared module.

#### Injected Methods:
- `Void        shared:RegisterEvent(String eventName)`
- `Void        shared:FireEvent(String eventName, ...)`
- `Connection  shared:ConnectEvent(String eventName, Function function)`

## Events
Server events share a common dictionary between service, modules and shared modules. On the client-side, events share a dictionary between controllers, modules and shared modules. This means that if you `RegisterEvent("MY_EVENT_NAME")` using the framework provided event method, that `MY_EVENT_NAME` is registered globally within the scope of Aero or AreoServer and will be able to be used in any of the other event methods, even in seperate modules. This is particularly useful when you need to manage events across different modules.

Sometimes, it is desired to use duplicate event names which are actually different events. For example, I might have two scripts, and I want to have an event name for both that is `ON_CLICKED`, and no other script/module/service/etc is expected to interact with that event. In this case, use the `Shared.Event.new()` shared module for creating individual events which need to be maintained outside the framework dictionary of events. It works similarly to the framework methods, and actually, the framework uses this shared library for the management of framework events.

# Basic Examples - Server

## Server Service
Here is a basic service:

```lua
local TestService = {
  -- add properties to the object for later use
  Debug = true;
}

function TestService:Add(a, b)
  if self.Debug then print("TestService:Add running.") end

  return a + b
end

function TestService:Start()
  -- Ran after all services have been initialized.
  -- Safe to run code from other services.
end

function TestService:Init()
  -- Do anything to set up the service, such as hydrating object properties.
  -- It is NOT safe to run code from other services, but they CAN be referenced.
  -- It is NOT safe to call modules which call upon other services.
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

Or, using properties within the service:

```lua
local AnotherService = {
    TestService = nil;
}

function AnotherService:Start()
  -- Invoke the TestService:
  local sum = self.TestService:Add(5, 3)
  print("5 + 3 = ", sum)
end

function AnotherService:Init()
  -- Reference the TestService:
  self.TestService = self.Services.TestService
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

Or, using internal service functions:

```lua
local MyService = {}

function MyService:OnSayHello(msg)
  print(msg)
end

function MyService:Start()

  -- Connect to the event:
  self:ConnectEvent("Hello", function(msg)
    self:OnSayHello(msg)
  end)

end

function MyService:Init()

  -- Register the event globally:
  self:RegisterEvent("Hello")

  -- Fire the event after 5 seconds:
  delay(5, function()
    self:FireEvent("Hello", "How are you?")
  end)

end

return MyService
```

Or, using the `Shared.Event` module:

```lua
local MyService = {
  MyHelloEvent = nil;
}

function MyService:OnSayHello(msg)
  print(msg)
end

function MyService:Start()

  -- Connect to the event:
  self.MyHelloEvent:Connect(function(msg)
      self.MyService:OnSayHello(msg)
  end)

end

function MyService:Init()

  self.MyHelloEvent = self.Shared.Event.new()

  -- Fire the event after 5 seconds:
  delay(5, function()
    self.MyHelloEvent:Fire("How are you?")
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

## Service client method invoking server method
Sometimes your client-facing methods need to invoke your server-facing methods. Reference the `self.Server` field to do this:
```lua
local MyService = {Client = {}}

function MyService:DoSomethingServerSide()
  return math.random()
end

-- Client-facing method:
function MyService.Client:GetRandom()
  -- Invoke server-facing method:
  local number = self.Server:DoSomethingServerSide()
  return number
end

function MyService:Start() end
function MyService:Init() end

return MyService
```

# Basic Examples - Client

## Client Controller
Here is a basic client controller that also connects to a server-side service:

```lua
local SomeController = {}

function SomeController:Test(x)
  print("Test!")
  return x * 2
end

function SomeController:Start()

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

function SomeController:Init()
  -- Run code here to set up the controller.
  -- Similar to services, it is NOT safe to invoke other controllers in this method, but you CAN reference them.
end

return SomeController
```

Controllers have the `Player` injected into them, available as `self.Player`. Since controllers do not execute everytime the player spawns, getting access to the player character can be challenging.

Here is an example of gettng access to the player character:

```lua
local SomeController = {
  PlayerCharacter = nil;
}

function SomeContoller:MyMethod()
    -- do something with self.PlayerCharacter
end

function SomeController:Start()

  self.PlayerCharacter = self.Player.Character
  
  if not self.PlayerCharacter or not self.PlayerCharacter.Parent then
    self.PlayerCharacter = self.Player.CharacterAdded:wait()
  end
  
  -- handle when the character respawns
  self.Player.CharacterAdded:connect(function(Character)
    -- do stuff when the character respawns
    self.PlayerCharacter = Character
    
    self:MyMethod()
    
    self.PlayerCharacter:WaitForChild("Humanoid").Died:connect(function()
      -- do stuff when the player dies
    end)
  end)
  
  -- following code executes when player first joins server
  -- The PlayerAdded event will not fire as this controller fires AFTER they already joined
  self.PlayerCharacter:WaitForChild("Humanoid").Died:connect(function()
    -- do stuff when the player dies the first time
  end)
  
  -- do stuff as the player was just added to the server
  self:MyMethod()
  
end

function SomeController:Init()
  -- Run code here to set up the controller.
end

return SomeController
```

## Client controller invoking another controller
Here is an example of a client controller invoking another client controller:

```lua
local MyController = {}

local someController

function MyController:Start()
  -- Invoke the other controller:
  local result = someController:Test(32)
  print(result)
end

function MyController:Init()
  -- Reference the other controller:
  someController = self.Modules.SomeController
end

return MyController
```

# Global
In certain circumstances, you may want to access the framework from code executing independent from the framework. In order to do this, both the client and the server root tables have been exposed on the global scope. Because they are not exposed until fully loaded, you will have to wait for them to exist by using a `while` or `repeat` loop, as shown in the examples below.

### Server Global Example
```lua
while (not _G.AeroServer) do wait() end
local aeroServer = _G.AeroServer

aeroServer.Services.SomeService:DoSomething()
```

### Client Global Example
```lua
while (not _G.Aero) do wait() end
local aero = _G.Aero

aero.Controllers.Fade:In()
aero.Services.TestService:Hello()
```

# Internal
AeroGameFramework is run by two scripts, `AeroServer` and `AeroClient`. The `AeroServer` script is located under `ServerScriptService.Aero`, and the `AeroClient` script is located under `StarterPlayerScripts.Aero`. These two scripts take care of executing the modules within the game framework. For the sake of stability, it is recommended that these scripts remain unaltered.

When looking at in-game statistics, such as memory usage, it is important to note that all modules created within the framework will be listed under either of these two scripts.

## Init & Start Methods
For both server-side services and client-side controllers, the `Init` methods are executed one-by-one on the _same_ thread. Each `Init` method must finish before the next one is called. Once every single `Init` is finished, the framework will then call each `Start` method on _different_ threads. Therefore, it is not wise to yield within any `Init` method, but doing so in the `Start` methods will be fine.
