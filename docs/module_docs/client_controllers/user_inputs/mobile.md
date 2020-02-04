The Mobile module exposes events related to mobile input.

--------------------

## Obtain Mobile

```lua
local mobile = userInput:Get("Mobile")
```

--------------------

## Events

### `TouchStarted`

Fires when a touch is started.

```lua
mobile.TouchStarted:Connect(function(screenPosition)
	print("TouchStarted", screenPosition)
end)
```

--------------------

### `TouchEnded`

Fires when a touch ends.

```lua
mobile.TouchEnded:Connect(function(screenPosition)
	print("TouchEnded", screenPosition)
end)
```

--------------------

### `TouchMoved`

Fires when a touch moves.

```lua
mobile.TouchMoved:Connect(function(screenPosition, deltaPosition)
	print("TouchMoved", screenPosition, deltaPosition)
end)
```

--------------------

### `TouchTapInWorld`

Fires when a touch tap is registered in the 3D world.

```lua
mobile.TouchTapInWorld:Connect(function(position)
	print("TouchTapInWorld", position)
end)
```

--------------------

### `TouchPinch`

Fires when a touch pinch is registered.

```lua
mobile.TouchPinch:Connect(function(scale, userInputState)
	print("TouchPinch", scale, userInputState)
end)
```