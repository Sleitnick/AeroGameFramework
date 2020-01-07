The Smooth module allows for silky-smooth movements. It is great for camera damping and smooth movement effects.

The underlying concept is to feed the Smooth object a Vector3 goal, and the algorithm will smoothly move toward that goal.

---------------------------

## Constructor

### `Smooth.new(Vector3 initialValue, Number smoothTime)`
Constructs a new Smooth object. The `initialValue` is the starting point for the smoother, and the `smoothTime` is the amount of time it takes for the algorithm to reach its goal.

```lua
local smooth = Smooth.new(Vector3.new(), 0.1)
```

!!! tip
	Keep the `smoothTime` as low as possible. While smoothing effects are fun to make, the players will be annoyed by transitions and movements that are too slow.

---------------------------

## Methods

### `Update([Vector3 goal])`
Calculate the new value based on the goal.

```lua
-- Continuously update the 'goal' to be the mouse's position &
-- move 'part' to the new calculated position:
runService:BindToRenderStep("Example", 0, function()
	local position = smooth:Update(mouse.Hit.Position)
	part.Position = position
end)
```

---------------------------

### `UpdateAngle([Vector3 goal])`
The same as `Update`, but will wrap the value around Tau (2π), which is a full circle in radians. This is necessary if the Smooth object is being used to calculate any sort of rotation (e.g. camera rotation).

```lua
-- Inside RenderStep or Heartbeat loop:
local rotVector = smooth:UpdateAngle(newRotationVector)
```

---------------------------

### `SetMaxSpeed(Number speed)`
Set the max speed at which the smoothing algorithm can travel. By default, there is no maximum speed.

```lua
-- Limit speed to 10 studs per second:
smooth:SetMaxSpeed(10)
```

---------------------------

### `GetMaxSpeed()`
Gets the max speed set for the smoothing algorithm.

```lua
local maxSpeed = smooth:GetMaxSpeed()
```

---------------------------

## Properties

### `Value`
The current Vector3 value calculated by the smoothing algorithm.

---------------------------

### `Goal`
The current Vector3 goal that the smoothing algorithm is moving toward.

---------------------------

### `SmoothTime`
The time it takes for the smoothing algorithm to reach the goal.

---------------------------

## Example

```lua
-- Move 'part' smoothly toward the mouse:

local smoothPosition = Smooth.new(part.Position, 0.5)

runService:BindToRenderStep("Example", 0, function()
	local position = smoothPosition:Update(mouse.Hit.Position)
	part.Position = position
end)
```