# Client Controller

A Controller is a singleton initiated at runtime. Controllers are essentially the same as server services, except that they are executed on the client. Controllers should perform specific purposes. For example, the Fade controller serves the purpose of easily fading the screen in and out.

-----------------------------------------------

## API
A controller in its simplest form:

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
- `controller.Services` Table of all server-side services, referenced by the name of the ModuleScript
- `controller.Player` Reference to the LocalPlayer (i.e. `game.Players.LocalPlayer`)

#### Injected Methods:
- `Void controller:RegisterEvent(String eventName)`
- `Void controller:FireEvent(String eventName, ...)`
- `Connection controller:ConnectEvent(String eventName, Function handler)`

### Init
The `Init` method is called on each controller in the framework in a synchronous and linear progression. In other words, each controller's `Init` method is invoked one after the other. Each `Init` method must fully execute before moving onto the next. This is essentially the constructor for the controller singleton.

This method should be used to set up your controller. For instance, you might want to create events or reference other controllers.

The `Init` method should _not_ invoke any methods from other controllers yet, because it is not guaranteed that those controllers have had their `Init` methods invoked yet. It is safe to _reference_ other controllers, but not invoke their methods.

### Start
The `Start` method is called after all controllers have been initiated (i.e. their `Init` methods have been fully executed).

Each `Start` method is executed on a _separate_ thread. From here, it is safe to reference and invoke other controllers in the framework.

### Custom Methods
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

Other controllers can also invoke your custom controller methods.

### Events
You can create and listen to events using the `RegisterEvent`, `ConnectEvent`, and `FireEvent` methods. All events should _always_ be registered within the `Init` method. The `ConnectEvent` and `FireEvent` methods should _never_ be used within an `Init` method.
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

-----------------------------------------------

## Other Examples

#### Invoking another controller:
```lua
function MyController:Start()
	local fade = self.Controllers.Fade
	fade:SetText("Fade Example")
	fade:Out()
	wait(1)
	fade:In()
end
```

#### Invoking a service:
```lua
function MyController:Start()
	-- Get pints:
	local pointsService = self.Services.PointsService
	local points = pointsService:GetPoints()
	print("Points:", points)
end
```

#### Using a Module:
```lua
function MyController:Start()
	local someModule = self.Modules.SomeModule
	someModule:DoSomething()
end
```

#### Using a Shared module:
```lua
function MyController:Start()
	-- Print the current date:
	local Date = self.Shared.Date
	local now = Date.new()
	print("Now", now)
end
```

#### Connecting to a service event:
```lua
function MyController:Start()
	local dataService = self.Services.DataService
	dataService.Failed:Connect(function(method, key, errorMessage)
		warn("DataService failed:", method, key, errorMessage)
	end)
end
```