The Keyboard represents the keyboard inputs for the player.

--------------------

## Obtain Keyboard

```lua
local keyboard = userInput:Get("Keyboard")
```

--------------------

## Methods

### `IsDown(keyCode)`

Returns `true|false` if the key is down.

```lua
if (keyboard:IsDown(Enum.KeyCode.W)) then
	-- W key down
end
```

--------------------

### `AreAllDown(keyCodes...)`

Returns `true|false` if _all_ keys passed are down.

```lua
if (keyboard:AreAllDown(Enum.KeyCode.W, Enum.KeyCode.LeftShift)) then
	-- LeftShift + W keys down
end
```

--------------------

### `AreAnyDown(keyCodes...)`

Returns `true|false` if _any_ keys passed are down.

```lua
if (keyboard:AreAnyDown(Enum.KeyCode.W, Enum.KeyCode.Up)) then
	-- W or Up Arrow down
end
```

--------------------

## Events

### `KeyDown`

Fires when a key is pressed.

```lua
keyboard.KeyDown:Connect(function(keyCode)
	print(keyCode, "down")
end)
```

--------------------

### `KeyUp`

Fires when a key is released.

```lua
keyboard.KeyUp:Connect(function(keyCode)
	print(keyCode, "up")
end)
```