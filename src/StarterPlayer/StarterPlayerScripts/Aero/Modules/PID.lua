-- PID
-- Stephen Leitnick
-- July 14, 2018

--[[
	
	PID stands for Proportional-Integral-Derivative. It is common practice to use
	a "PID Controller" (like this one) to calculate the desired output to meet a
	certain setpoint or target. For instance, a car's cruise control setting
	might use a PID Controller to calculate the necessary acceleration needed
	to go from the current speed to the desired speed.
	
	
	pid = PID.new(kp, ki, kd)
	
		VOID    pid:SetInput(input [, clampToMinMax])
		VOID    pid:SetTarget(target [, clampToMinMax])
		
		NUMBER  pid:Compute()
		
		VOID    pid:SetTunings(kp, ki, kd)
		VOID    pid:SetSampleTime(sampleTimeMillis)
		VOID    pid:SetOutputLimits(min, max)
		VOID    pid:ClearOutputLimits()
		
		VOID    pid:Run(callbackBefore, callbackAfter)
		VOID    pid:Stop()
		VOID    pid:Pause()
		VOID    pid:Resume()
		
		VOID    pid:Clone()
		
	
	EXAMPLE:
	
		pid = PID.new(0.01, 0.01, -0.01)
		
		pid:Run(
			function()
				pid:SetInput(currentSpeed)
				pid:SetTarget(desiredSpeed)
			end,
			function(output)
				car:SetAcceleration(output)
			end
		)
	
--]]



local PID = {}
PID.__index = PID


local tick = tick
local function millis()
	return tick() * 1000
end


function PID.new(kp, ki, kd)
	
	local self = setmetatable({
		Input = 0;
		Target = 0;
		P = 0;
		I = 0;
		D = 0;
		LastInput = 0;
		ITerm = 0;
		LastError = 0;
		Output = 0;
		SampleTimeMillis = 10;
		LastTime = 0;
		OutMin = -math.huge;
		OutMax = math.huge;
		_paused = false;
	}, PID)
	
	self:SetTunings(kp, ki, kd)
	
	return self
	
end


function PID:SetInput(input, clampToMinMax)
	if (clampToMinMax) then
		self.Input = math.clamp(input, self.OutMin, self.OutMax)
	else
		self.Input = input
	end
end


function PID:SetTarget(target, clampToMinMax)
	if (clampToMinMax) then
		self.Target = math.clamp(target, self.OutMin, self.OutMax)
	else
		self.Target = target
	end
end


function PID:SetTunings(kp, ki, kd)
	self.P = kp
	self.I = ki * self.SampleTimeMillis
	self.D = kd / self.SampleTimeMillis
end


function PID:SetSampleTime(newSampleTime)
	newSampleTime = math.max(newSampleTime, 0)
	local ratio = newSampleTime / self.SampleTimeMillis
	self.I = self.I * ratio
	self.D = self.D / ratio
	self.SampleTimeMillis = newSampleTime
end


function PID:SetOutputLimits(min, max)
	self.OutMin = math.min(min, max)
	self.OutMax = math.max(min, max)
	if (self.Output > self.OutMax) then
		self.Output = self.OutMax
	elseif (self.Output < self.OutMin) then
		self.Output = self.OutMin
	end
	if (self.ITerm > self.OutMax) then
		self.ITerm = self.OutMax
	elseif (self.ITerm < self.OutMin) then
		self.ITerm = self.OutMin
	end
end


function PID:ClearOutputLimits()
	self:SetOutputLimits(-math.huge, math.huge)
end


function PID:Compute()
	
	local now = millis()
	local timeChange = (now - self.LastTime)
	
	if (timeChange > self.SampleTimeMillis) then
	
		local err = self.Target - self.Input
		self.ITerm = math.clamp((self.ITerm + (self.I * err)), self.OutMin, self.OutMax)
		local dInput = (self.Input - self.LastInput)
		
		self.Output = math.clamp((self.P * err) + (self.ITerm) - (self.D * dInput), self.OutMin, self.OutMax)
		
		self.LastError = err
		self.LastInput = self.Input
		self.LastTime = now
		
	end
	
	return self.Output
	
end


function PID:_hookupHeartbeat()
	self._heartbeat = game:GetService("RunService").Heartbeat:Connect(self._callback)
end


function PID:Run(callbackBefore, callbackAfter)
	if (self._running) then
		error("Already running")
		return
	end
	self._running = true
	self._paused = false
	self._callback = function(dt)
		callbackBefore(dt)
		callbackAfter(self:Compute())
	end
	self:_hookupHeartbeat()
end


function PID:Stop()
	if (not self._running) then return end
	self._heartbeat:Disconnect()
	self._heartbeat = nil
	self._callback = nil
	self._running = false
end


function PID:Pause()
	if (self._running and not self._paused) then
		self._paused = true
		self._heartbeat:Disconnect()
	end
end


function PID:Resume()
	if (self._running and self._paused and self._callback) then
		self.LastInput = self.Input
		self.ITerm = math.clamp(self.Output, self.OutMin, self.OutMax)
		self._paused = false
		self:_hookupHeartbeat()
	end
end


function PID:Clone()
	local clone = PID.new(self.P, self.I, self.D)
	clone:SetSampleTime(self.SampleTimeMillis)
	return clone
end


return PID