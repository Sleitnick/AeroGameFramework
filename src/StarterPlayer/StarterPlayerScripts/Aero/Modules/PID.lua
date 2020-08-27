-- PID
-- August 11, 2020

--[[

	PID stands for Proportional-Integral-Derivative. One example of PID controllers in
	real-life is to control the input to each motor of a drone to keep it stabilized.
	Another example is cruise-control on a car.

	-----------------------------------------------

	Constructor:

		pid = PID.new(min, max, kP, kD, kI)


	Methods:

		pid:Calculate(dt, setpoint, pv)
		> Calculates and returns the new value
			> dt: DeltaTime
			> setpoint: The current point
			> pv: The process variable (i.e. goal)

		pid:Reset()
		> Resets the PID

	-----------------------------------------------

--]]


local PID = {}
PID.__index = PID


function PID.new(min, max, kp, kd, ki)
	local self = setmetatable({}, PID)
	self._min = min
	self._max = max
	self._kp = kp
	self._kd = kd
	self._ki = ki
	self._preError = 0
	self._integral = 0
	return self
end


function PID:Reset()
	self._preError = 0
	self._integral = 0
end


function PID:Calculate(dt, setpoint, pv)
	local err = (setpoint - pv)
	local pOut = (self._kp * err)
	self._integral += (err * dt)
	local iOut = (self._ki * self._integral)
	local deriv = ((err - self._preError) / dt)
	local dOut = (self._kd * deriv)
	local output = math.clamp((pOut + iOut + dOut), self._min, self._max)
	self._preError = err
	return output
end


function PID:SetMinMax(min, max)
	self._min = min
	self._max = max
end


return PID