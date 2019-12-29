-- Smooth
-- Stephen Leitnick
-- June 3, 2018

--[[
	
	This is a wrapper for the SmoothDamp module. It stores
	all needed variables internally for ease of use.
	
	-------------------------------------------------------------------------

	local smooth = Smooth.new(Vector3 initialValue, Number smoothTime)
	
	smooth.Value
	smooth.Goal
	smooth.SmoothTime
	
	smooth:Update([Vector goal])
	smooth:UpdateAngle([Vector goal])
	smooth:SetMaxSpeed(Number speed)
	smooth:GetMaxSpeed()

	-------------------------------------------------------------------------

	EXAMPLE:

		local smoothPosition = Smooth.new(part.Position, 0.5)

		runService:BindToRenderStep("Example", 0, function()
			local position = smoothPosition:Update(mouse.Hit.p)
			part.Position = position
		end)

--]]



local Smooth = {}
Smooth.__index = Smooth

local SmoothDamp = require(script:WaitForChild("SmoothDamp"))


function Smooth.new(initialValue, smoothTime)

	assert(typeof(initialValue) == "Vector3", "initialValue should be Vector3")
	assert(typeof(smoothTime) == "number", "smoothTime should be a number")
	assert(smoothTime >= 0, "smoothTime must be a positive number")
	
	local self = setmetatable({
		Value = initialValue;
		Goal = initialValue;
		SmoothTime = smoothTime;
	}, Smooth)
	
	self._smoothDamp = SmoothDamp.new()
	
	return self
	
end


function Smooth:Update(goal)
	if (goal) then
		self.Goal = goal
	else
		goal = self.Goal
	end
	local value = self._smoothDamp:Update(self.Value, goal, self.SmoothTime)
	self.Value = value
	return value
end


function Smooth:UpdateAngle(goal)
	if (goal) then
		self.Goal = goal
	else
		goal = self.Goal
	end
	local value = self._smoothDamp:UpdateAngle(self.Value, goal, self.SmoothTime)
	self.Value = value
	return value
end


function Smooth:SetMaxSpeed(speed)
	self._smoothDamp.MaxSpeed = speed
end


function Smooth:GetMaxSpeed()
	return self._smoothDamp.MaxSpeed
end


return Smooth