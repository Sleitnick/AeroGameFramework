Allows the creation of custom events.

--------------------

## Constructor

### Signal.new()
Creates a new Signal object.
```lua
local signal = Signal.new()
```

--------------------

## Methods

### `Fire(Variant args...)`
Fire the event with any number of arguments.
```lua
signal:Fire("Hello world")
```

--------------------

### `Wait()`
Yields until the next time the event is fired, and returns anything that the fired event passed.
```lua
local message = signal:Wait()
```

--------------------

### `WaitPromise()`
Returns a Promise that resolves when the event fires next.
```lua
signal:WaitPromise():Then(function(message)
	print(message)
end)
```

--------------------

### `Connect(Function handler)`
Connects a function to the event. The function will be called every time the event is fired.

**Returns:** [Connection](https://developer.roblox.com/en-us/api-reference/datatype/RBXScriptConnection)
```lua
signal:Connect(function(message)
	print("Event fired! Got message:", message)
end)
```

--------------------

### `DisconnectAll()`
Disconnects all connected functions.
```lua
signal:DisconnectAll()
```

--------------------

### `Destroy()`
Destroys the event, which also disconnects all connections.
```lua
signal:Destroy()
```