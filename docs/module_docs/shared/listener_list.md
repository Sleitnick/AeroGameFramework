The ListenerList allows developers to keep a list of connections that can all be disconnected at the same time. This is useful when creating custom objects that need to be destroyed and cleaned up.

--------------------

## Constructor

### `ListenerList.new()`
Creates a new ListenerList instance.
```lua
local listenerList = ListenerList.new()
```

--------------------

## Methods

### `Connect(event, func)`
Connect to an event.

**Returns:** [Connection](https://developer.roblox.com/en-us/api-reference/datatype/RBXScriptConnection)
```lua
listenerList:Connect(workspace.Changed, function(property)
	print("Workspace property " .. property .. " changed")
end)
```

--------------------

### `BindToRenderStep(name, priority, func)`
Exactly the same as [RunService:BindToRenderStep](https://developer.roblox.com/en-us/api-reference/function/RunService/BindToRenderStep). See documentation there.
```lua
listenerList:BindToRenderStep("R", Enum.RenderPriority.Camera.Value, function()
	-- Render step
end)
```

--------------------

### `BindAction(name, func, btn [, inputTypes...])`
The same as [ContextActionService:BindAction](https://developer.roblox.com/en-us/api-reference/function/ContextActionService/BindAction).

--------------------

### `BindActionAtPriority(name, func, btn, priority [, inputTypes...])`
The same as [ContextActionService:BindActionAtPriority](https://developer.roblox.com/en-us/api-reference/function/ContextActionService/BindActionAtPriority).

--------------------

### `DisconnectAll()`
Disconnect all events, and unbind both RenderStep and Action bindings.
```lua
listenerList:DisconnectAll()
```

--------------------

### `DisconnectEvents()`
Only disconnect events in the list.

--------------------

### `DisconnectRenderSteps()`
Only unbind any bound RenderSteps.

--------------------

### `DisconnectActions()`
Only unbind any bound actions.

--------------------

### `Destroy()`
Alias for `DisconnectAll`.