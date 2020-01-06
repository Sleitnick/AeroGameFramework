Allows the creation of custom events.

--------------------

## Constructor

### Event.new()
Creates a new Event object.
```lua
local event = Event.new()
```

--------------------

## Methods

### `Fire(Variant args...)`
Fire the event with any number of arguments.
```lua
event:Fire("Hello world")
```

--------------------

### `Wait()`
Yields until the next time the event is fired, and returns anything that the fired event passed.
```lua
local message = event:Wait()
```

--------------------

### `Connect(Function handler)`
Connects a function to the event. The function will be called every time the event is fired.

**Returns:** [Connection](https://developer.roblox.com/en-us/api-reference/datatype/RBXScriptConnection)
```lua
event:Connect(function(message)
	print("Event fired! Got message:", message)
end)
```

--------------------

### `DisconnectAll()`
Disconnects all connected functions.
```lua
event:DisconnectAll()
```

--------------------

### `Destroy()`
Destroys the event, which also disconnects all connections.
```lua
event:Destroy()
```