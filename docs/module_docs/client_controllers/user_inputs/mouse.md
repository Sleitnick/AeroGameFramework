The Mouse object represents a player's mouse and any associated inputs.

--------------------

## Obtain Mouse

```lua
local mouse = userInput:Get("Mouse")
```

--------------------

## Methods

### `GetPosition()`

Returns a Vector2 of the mouse's screen position.

--------------------

### `GetDelta()`

Returns a Vector2 of the mouse's delta position (i.e. change in position).

!!! warning
	This only works if the mouse is locked. If not locked, it will return a zero-value Vector2.

--------------------

### `Lock()`

Locks the mouse's position on-screen at its current location.

--------------------

### `LockCenter()`

Locks the mouse's position at the center of the screen.

--------------------

### `Unlock()`

Unlocks the mouse's position.

--------------------

### `GetRay(distance)`

Get a ray object from the mouse's position into the 3D world. This is mostly used internally for raycasting.

--------------------

### `GetRayFromXY(x, y)`

Get a ray object projecting from the XY screen position into the 3D world.

--------------------

### `SetMouseIcon(iconId)`

Set the mouse icon.

--------------------

### `SetMouseIconEnabled(isEnabled)`

Set whether or not the mouse icon is enabled.

--------------------

### `IsMouseIconEnabled()`

Returns `true|false` whether or not the mouse icon is enabled.

--------------------

### `IsButtonPressed(mouseButton)`

Returns `true|false` if the given mouse button is pressed (e.g. `Enum.UserInputType.MouseButton1`).

--------------------

### `Cast(ignoreInstance, terrainCellsAreCubes, ignoreWater)`

Performs a raycast operation from the mouse's position projected into the 3D world. Returns everything that `workspace:FindPartOnRay` returns (part, cframe, normal, material).

--------------------

### `CastWithIgnoreList(ignoreTbl, terrainCellsAreCubes, ignoreWater)`

The same as `Cast`, but with a given blacklist table.

--------------------

### `CastWithWhitelist(whitelistTbl, terrainCellsAreCubes, ignoreWater)`

The same as `Cast`, but with a given whitelist table.

--------------------

## Events

### `LeftDown`

The left button was pressed down.

--------------------

### `LeftUp`

The left button was released.

--------------------

### `RightDown`

The right button was pressed down.

--------------------

### `RightUp`

The right button was released.

--------------------

### `MiddleDown`

The middle button was pressed down.

--------------------

### `MiddleUp`

The middle button was released.

--------------------

### `Moved`

The mouse has moved.

```lua
mouse.Moved:Connect(function()
	print("The mouse moved")
end)
```

--------------------

### `Scrolled`

Mouse wheel scrolled. Passes the increment of scrolling performed.

```lua
mouse.Scrolled:Connect(function(amount)
	print("Scrolled", amount)
end)
```

--------------------