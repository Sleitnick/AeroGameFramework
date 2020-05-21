The UserInput controller gives access to sub-modules for specific inputs to the mouse, keyboard, gamepad, and mobile.

--------------------

## Properties

### `Preferred`

A list of preferred inputs, which should be used in conjunction with `GetPreferred` and `PreferredChanged`.

|Preferred Input|
|----|
|`Preferred.Keyboard`|
|`Preferred.Mouse`|
|`Preferred.Gamepad`|
|`Preferred.Touch`|

Preferred inputs refer to the type of input last used by the user, and this is assumed is the input the user prefers.

--------------------

### `HideMouse`

Defaults to `false`. If set to `true`, the mouse will be automatically hidden when the preferred user input is switched away from mouse or keyboard. For instance, if the user starts using a gamepad, the mouse will be hidden automatically if this property is set to `true`.

This is off by default because it will conflict with setting the mouse visibility via the Mouse module.

--------------------

## Methods

### `Get(inputModuleName)`

Gets the input module with the given name. Module names available are [`Keyboard`](../user_inputs/keyboard/) `Keyboard`, `Mouse`, `Gamepad`, and `Mobile`.

```lua
local mouse    = userInput:Get("Mouse")
local keyboard = userInput:Get("Keyboard")
local gamepad1 = userInput:Get("Gamepad").new(Enum.UserInputType.Gamepad1)
local mobile   = userInput:Get("Mobile")
```

--------------------

### `GetPreferred()`

Get the preferred input, which will return one of the items from the `Preferred` table.

```lua
local preferred = userInput:GetPreferred()
if (preferred == userInput.Preferred.Gamepad) then
	-- Use gamepad
end
```

--------------------

## Events

### `PreferredChanged(preferred)`

Fires when the preferred input changes. This is useful for changing control schemas during runtime.

One use-case is when players use a gamepad on a computer. While a gamepad might be plugged in, the user might not want to use the gamepad. However, if the user decides to switch to use the gamepad during gameplay, it is useful to be able to respond to the change.

```lua
userInput.PreferredChanged:Connect(function(preferred)
	if (preferred == userInput.Preferred.Gamepad) then
		-- Use gamepad
	elseif (preferred == userInput.Preferred.Touch) then
		-- Use mobile
	else
		-- Use keyboard/mouse
	end
end)
```