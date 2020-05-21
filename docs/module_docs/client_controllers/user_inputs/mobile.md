The Mobile module exposes events related to mobile input.

--------------------

## Obtain Mobile

```lua
local mobile = userInput:Get("Mobile")
```

--------------------

## Methods

### `GetDeviceAcceleration()`
Get the acceleration of the device.
```lua
local acceleration = mobile:GetDeviceAcceleration()
```

--------------------

### `GetDeviceGravity()`
Get the gravitational force on the device.
```lua
local gravity = mobile:GetDeviceGravity()
```

--------------------

### `GetDeviceRotation()`
Get the rotation of the device.
```lua
local rotation, cframe = mobile:GetDeviceRotation()
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
mobile.TouchPinch:Connect(function(touchPositions, scale, velocity, state)
	print("TouchPinch", touchPositions, scale, velocity, state)
end)
```

--------------------

### `TouchLongPress`

Fires when a long press is registered.

```lua
mobile.TouchLongPress:Connect(function(touchPositions, state)
	print("TouchLongPress", touchPositions, state)
end)
```

--------------------

### `TouchPan`

Fires when a pan is registered.

```lua
mobile.TouchPan:Connect(function(touchPositions, totalTranslation, velocity, state)
	print("TouchPan", touchPositions, totalTranslation, velocity, state)
end)
```

--------------------

### `TouchRotate`

Fires when a rotation is registered.

```lua
mobile.TouchRotate:Connect(function(touchPositions, rotation, velocity, state)
	print("TouchRotate", touchPositions, rotation, velocity, state)
end)
```

--------------------

### `TouchSwipe`

Fires when a swipe is registered.

```lua
mobile.TouchSwipe:Connect(function(swipeDirection, numberOfTouches)
	print("TouchSwipe", swipeDirection, numberOfTouches)
end)
```

See [`SwipeDirection`](https://developer.roblox.com/en-us/api-reference/enum/SwipeDirection) for possible values.

--------------------

### `TouchTap`

Fires when a tap is registered.

```lua
mobile.TouchTap:Connect(function(touchPositions)
	print("TouchTap", touchPositions)
end)
```

--------------------

### `DeviceAccelerationChanged`

Fires when the device's acceleration changes.

```lua
mobile.DeviceAccelerationChanged:Connect(function(acceleration)
	print("DeviceAccelerationChanged", acceleration)
end)
```

--------------------

### `DeviceGravityChanged`

Fires when the device's gravitational pull changes.

```lua
mobile.DeviceGravityChanged:Connect(function(gravity)
	print("DeviceGravityChanged", gravity)
end)
```

--------------------

### `DeviceRotationChanged`

Fires when the device's rotation changes.

```lua
mobile.DeviceRotationChanged:Connect(function(rotation, cframe)
	print("DeviceRotationChanged", rotation, cframe)
end)
```