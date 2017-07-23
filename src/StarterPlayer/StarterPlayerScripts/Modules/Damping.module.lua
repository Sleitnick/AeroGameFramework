-- Damping
-- Crazyman32
-- September 30, 2015
-- Updated: January 1, 2017


--[[
	
	local Damping = require(this)
	
	local damping = Damping.new()
	
	damping.P = NUMBER
	damping.D = NUMBER
	damping.Position = Vector3
	damping.Goal = Vector3
	
	damping:Update()      [Returns Vector3 position]
	damping:UpdateAngle() [Returns Vector3 position, but each XYZ value is wrapped properly for pi*2 motion]
	
	
	
	EXAMPLE USE:
	
	-- Set D and P values:
	damping.P = 5
	damping.D = 0.1
	
	-- Set starting position:
	damping.Position = part.Position
	
	while (true) do
	
		wait()
		
		-- Update the goal:
		damping.Goal = mouse.Hit.p
		
		-- Calculate new position:
		local newPosition = damping:Update()
		part.Position = newPosition
		
	end
	
	
	
	ALGORITHM:
		
		velocity += P * ( (target - current) + D * -velocity );
		current += velocity * dt;
		
		Credit: http://www.gamedev.net/topic/561981-smooth-value-damping/
	
	
--]]


local Damping = {}
Damping.__index = Damping

local V3 = Vector3.new
local PI = math.pi
local TAU = PI * 2
local tick = tick


local function CheckNAN(value, returnIfNan)
	return (value == value and value or returnIfNan)
end


local function DeltaAngle(current, target)
	local num = (target - current) % TAU
	if (num > PI) then
		num = (num - TAU)
	end
	return num
end


local function DeltaAngleV3(pos1, pos2)
	local x = DeltaAngle(pos1.X, pos2.X)
	local y = DeltaAngle(pos1.Y, pos2.Y)
	local z = DeltaAngle(pos1.Z, pos2.Z)
	return V3(x, y, z)
end


function Damping.new()
	
	local damping = setmetatable({
		P = 5;
		D = 0.1;
		Position = V3();
		Velocity = V3();
		Goal = V3();
		Last = tick();
	}, Damping)
	
	return damping
	
end


function Damping:CheckNAN()
	self.Velocity = V3(CheckNAN(self.Velocity.X, 0), CheckNAN(self.Velocity.Y, 0), CheckNAN(self.Velocity.Z, 0))
	self.Position = V3(CheckNAN(self.Position.X, self.Goal.X), CheckNAN(self.Position.Y, self.Goal.Y), CheckNAN(self.Position.Z, self.Goal.Z))
end


function Damping:Update()
	local t = tick()
	local dt = (t - self.Last)
	self.Last = t
	self.Velocity = (self.Velocity + (self.P * ((self.Goal - self.Position) + (-self.Velocity * self.D))))
	self.Position = (self.Position + (self.Velocity * dt))
	self:CheckNAN()
	return self.Position
end


function Damping:UpdateAngle()
	self.Goal = (self.Position + DeltaAngleV3(self.Position, self.Goal))
	return self:Update()
end


return Damping