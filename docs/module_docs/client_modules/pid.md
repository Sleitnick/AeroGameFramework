PID stands for Proportional-Integral-Derivative. It is common practice to use a [PID Controller](https://en.wikipedia.org/wiki/PID_controller) (like this one) to calculate the desired output to meet a certain setpoint or target. For instance, a car's cruise control setting might use a PID Controller to calculate the necessary acceleration needed to go from the current speed to the desired speed.

--------------------

## Constructor

### `new(Number kp, Number ki, Number kd)`
Constructs a new PID instance.

```lua
local pid = PID.new(0.01, 0.01, -0.01)
```

--------------------

## Methods

### `SetInput(Number input, [ Boolean clampMinMax])`
Set the current input for the PID.

```lua
pid:SetInput(car.Velocity.Magnitude)
```

--------------------

### `SetTarget(Number target, [ Boolean clampMinMax])`
Set the target value for the PID.

```lua
pid:SetTarget(desiredCarSpeed)
```

--------------------

### `Compute()`
Compute the new value.

```lua
local acceleration = pid:Compute()
```

--------------------

### `SetTunings(Number kp, Number ki, Number kd)`
Tune the PID. Setting the correct values for a PID controller can be very tricky and will take some time to learn and understand for each application.

```lua
pid:SetTunings(0.1, 0.01, 0)
```

--------------------

### `SetSampleTime(Number sampleTimeMilliseconds)`
Set how frequently (in milliseconds) the `Compute` method is allowed to actually calculate a new value. If `Compute` is called within this range, it will simpy use the last value calculated. Lower sample times will be more accurate, but may hurt performance under heavy load.

--------------------

### `SetOutputLimits(Number min, Number max)`
Set the output limit range. The output will be clamped between `min` and `max`.

```lua
pid:SetOutputLimits(0, 10)
```

--------------------

### `ClearOutputLimits()`
Clears the output limits. With no limits, the output will not be restricted to any range. This is the default.

```lua
pid:ClearOutputLimits()
```

--------------------

### `Run(Function callbackBefore, Function callbackAfter)`
Run the PID continuously on a Heartbeat loop. Two callbacks are used: One for pre-computation, and one for post-computation. In the pre-computation step (i.e. `callbackBefore`), it is best to adjust the target and input. In the post-computation step (i.e. `callbackAfter`), the calculated value will be passed along and can be used.

```lua
pid:Run(
	function()
		pid:SetInput(carSpeed)
		pid:SetTarget(carDesiredSpeed)
	end,
	function(accel)
		car:SetAcceleration(accel)
	end
)
```

--------------------

### `Stop()`
Stops the running PID.

```lua
pid:Stop()
```

--------------------

### `Pause()`
Pauses the running PID.

```lua
pid:Pause()
```

--------------------

### `Resume()`
Resumes the paused PID.

```lua
pid:Resume()
```

--------------------

### `Clone()`
Clones the PID.

```lua
local pid2 = pid:Clone()
```

--------------------

## Example

```lua
local pid = PID.new(0.01, 0.01, -0.01)

pid:Run(
	function()
		pid:SetInput(currentSpeed)
		pid:SetTarget(desiredSpeed)
	end,
	function(output)
		car:SetAcceleration(output)
	end
)
```