-- Smooth Damp
-- Crazyman32
-- January 30, 2017

--[[
	
	local SmoothDamp = require(this)
	
	smooth = SmoothDamp.new()
	smooth.MaxSpeed
	smooth:Update(currentVector, targetVector, smoothTime)
	smooth:UpdateAngle(currentVector, targetVector, smoothTime)
	
	
	Use UpdateAngle if smoothing out angles. The only difference is that
	it makes sure angles wrap properly (in radians). For instance, if
	damping a rotating wheel, UpdateAngle should be used.
	
	
	-- Example:
	
	local smooth = SmoothDamp.new()
	function Update()
		local current = camera.CFrame.p
		local target = (part.CFrame * CFrame.new(0, 5, -10)).p
		local camPos = smooth:Update(current, target, 0.2)
		camera.CFrame = CFrame.new(camPos, part.Position)
	end
	
--]]


----------------------------------------------------------------------------------------------------------------

local V3 = Vector3.new
local MAX = math.max
local PI = math.pi
local TAU = PI * 2
local tick = tick
local Dot = V3().Dot

local function DeltaAngle(current, target)
	local n = ((target - current) % TAU)
	return (n > PI and (n - TAU) or n)
end

local function DeltaAngleV3(p1, p2)
	return V3(DeltaAngle(p1.X, p2.X), DeltaAngle(p1.Y, p2.Y), DeltaAngle(p1.Z, p2.Z))
end

local function ClampMagnitude(v, mag)
	return (v.magnitude > mag and (v.unit * mag) or v)
end

----------------------------------------------------------------------------------------------------------------

local SmoothDamp = {}
SmoothDamp.__index = SmoothDamp

function SmoothDamp.new()
	local smoothDamp = setmetatable({
		MaxSpeed = math.huge;
		_update = tick();
		_velocity = V3();
	}, SmoothDamp)
	return smoothDamp
end

function SmoothDamp:Update(current, target, smoothTime)
	local currentVelocity = self._velocity
	local now = tick()
	local deltaTime = (now - self._update)
	smoothTime = MAX(0.0001, smoothTime)
	local num = (2 / smoothTime)
	local num2 = (num * deltaTime)
	local d = (1 / (1 + num2 + 0.48 * num2 * num2 + 0.235 * num2 * num2 * num2))
	local vector = (current - target)
	local vector2 = target
	local maxLength = (self.MaxSpeed * smoothTime)
	vector = ClampMagnitude(vector, maxLength)
	target = (current - vector)
	local vector3 = ((currentVelocity + num * vector) * deltaTime)
	currentVelocity = ((currentVelocity - num * vector3) * d)
	local vector4 = (target + (vector + vector3) * d)
	if (Dot(vector2 - current, vector4 - vector2) > 0) then
		vector4 = vector2
		currentVelocity = ((vector4 - vector2) / deltaTime)
	end
	self._velocity = currentVelocity
	self._update = now
	return vector4
end

function SmoothDamp:UpdateAngle(current, target, smoothTime)
	return self:Update(current, (current + DeltaAngleV3(current, target)), smoothTime)
end

return SmoothDamp
