The Gamepad class represents gamepad instances that can be used to capture control inputs from the user.

--------------------

## Constructor

```lua
local gamepad = userInput:Get("Gamepad").new(Enum.UserInputType.Gamepad1)
```

--------------------

## Methods

### `IsDown(keyCode)`

Returns `true|false` if the button is down.

```lua
if (gamepad:IsDown(Enum.KeyCode.ButtonA)) then
	print("ButtonA down")
end
```

--------------------

### `IsConnected()`

Returns `true|false` if the gamepad is connected.

--------------------

### `GetState(keyCode)`

Returns the UserInputState of the given keycode button.

```lua
local thumbstick1 = gamepad:GetState(Enum.KeyCode.Thumbstick1)
print("Left Thumbstick Position", thumbstick1.Position)
```

--------------------

### `SetMotor(motor, value)`

Sets the vibration motor on to a given value. The `value` should be between `0` and `1`. Setting the value to `0` will turn the motor off (which is exactly what the `StopMotor` method does).

```lua
gamepad:SetMotor(Enum.VibrationMotor.Large, 0.75)
```

--------------------

### `StopMotor(motor)`

Stops the vibration motor. This is the same as setting the motor to a value of `0`.

```lua
gamepad:StopMotor(Enum.VibrationMotor.Large)
```

--------------------

### `StopAllMotors()`

Stops all motors from vibrating.

```lua
gamepad:StopAllMotors()
```

--------------------

### `IsMotorSupported(motor)`

Returns `true|false` whether or not the motor is supported on this gamepad.

--------------------

### `IsVibrationSupported()`

Returns `true|false` whether or not vibration is supported on this gamepad.

--------------------

### `GetMotorValue(motor)`

Returns the current value for the given motor. Will return a number between `0` to `1`. A value of `0` indicates that the motor is off.

--------------------

### `ApplyDeadzone(value, threshold)`

Remaps the value to ignore values under the threshold. Because it is remapped, it is _not_ just cutting out the lower values, but interpolates the value from `0` to `1` properly outside the threshold.

```lua
local DEADZONE_THRESHOLD = 0.1
local thumbstick1 = gamepad:GetState(Enum.KeyCode.Thumbstick1)
local x = gamepad:ApplyDeadzone(thumbstick.Position.X, DEADZONE_THRESHOLD)
local y = gamepad:ApplyDeadzone(thumbstick.Position.Y, DEADZONE_THRESHOLD)
print("Left Thumbstick Position", x, y)
```

--------------------

## Events

### `ButtonDown`

Fires when a button is pressed down.

```lua
gamepad.ButtonDown:Connect(function(keyCode)
	if (keyCode == Enum.KeyCode.ButtonA) then
		print("ButtonA pressed down")
	end
end)
```

--------------------

### `ButtonUp`

Fires when a button is released.

```lua
gamepad.ButtonUp:Connect(function(keyCode)
	if (keyCode == Enum.KeyCode.ButtonA) then
		print("ButtonA released")
	end
end)
```

--------------------

### `Changed`

Fires when the input changes.

```lua
gamepad.Changed:Connect(function(keyCode, input)
	if (keyCode == Enum.KeyCode.Thumbstick1) then
		print("Left Thumbstick Changed", input.Position)
	end
end)
```

!!! warning
	Checking for changes in analog controls can be buggy (i.e. it can fail to register when the analog stick goes back to a 0,0 position). Therefore, it is preferrable to use `GetState` and continuously poll the input's position. See example at the bottom of this page.

--------------------

### `Connected`

Fires when this gamepad is connected.

--------------------

### `Disconnected`

Fires when this gamepad is disconnected.

--------------------

## Polling Example

Continuously poll the position of the thumbstick:

```lua
local thumbstick1 = gamepad:GetState(Enum.KeyCode.Thumbstick1)

game:GetService("RunService").Heartbeat:Connect(function()
	local leftThumbPos = thumbstick1.Position
	print("Left Thumbstick", leftThumbPos)
end)
```