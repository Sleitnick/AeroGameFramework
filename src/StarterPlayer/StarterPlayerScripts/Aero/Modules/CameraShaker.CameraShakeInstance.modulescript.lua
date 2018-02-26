-- Camera Shake Instance
-- Crazyman32
-- February 26, 2018

--[[
	
	cameraShakeInstance = CameraShakeInstance.new(magnitude, roughness, fadeInTime, fadeOutTime)
	
--]]



local CameraShakeInstance = {}
CameraShakeInstance.__index = CameraShakeInstance

local V3 = Vector3.new
local NOISE = math.noise


CameraShakeInstance.CameraShakeState = {
	FadingIn = 0;
	FadingOut = 1;
	Sustained = 2;
	Inactive = 3;
}


function CameraShakeInstance.new(magnitude, roughness, fadeInTime, fadeOutTime)
	
	if (fadeInTime == nil) then fadeInTime = 0 end
	if (fadeOutTime == nil) then fadeOutTime = 0 end
	
	local self = setmetatable({
		Magnitude = magnitude;
		Roughness = roughness;
		PositionInfluence = Vector3.new();
		RotationInfluence = Vector3.new();
		DeleteOnInactive = true;
		roughMod = 1;
		magnMod = 1;
		fadeOutDuration = fadeOutTime;
		fadeInDuration = fadeInTime;
		sustain = (fadeInTime > 0);
		currentFadeTime = (fadeInTime > 0 and 0 or 1);
		tick = Random.new():NextNumber(-100, 100);
	}, CameraShakeInstance)
	
	return self
	
end


function CameraShakeInstance:UpdateShake(dt)
	
	local x = NOISE(self.tick, 0) - 0.5
	local y = NOISE(0, self.tick) - 0.5
	local z = NOISE(self.tick, self.tick) - 0.5
	
	if (self.fadeInDuration > 0 and self.sustain) then
		if (self.currentFadeTime < 1) then
			self.currentFadeTime = self.currentFadeTime + (dt / self.fadeInDuration)
		elseif (self.fadeOutDuration > 0) then
			self.sustain = false
		end
	end
	
	if (not self.sustain) then
		self.currentFadeTime = self.currentFadeTime - (dt / self.fadeOutDuration)
	end
	
	if (self.sustain) then
		self.tick = self.tick + (dt * self.Roughness * self.roughMod)
	else
		self.tick = self.tick + (dt * self.Roughness * self.roughMod * self.currentFadeTime)
	end
	
	return V3(x, y, z) * self.Magnitude * self.magnMod * self.currentFadeTime
	
end


function CameraShakeInstance:StartFadeOut(fadeOutTime)
	if (fadeOutTime == 0) then
		self.currentFadeTime = 0
	end
	self.fadeOutDuration = fadeOutTime
	self.fadeInDuration = 0
	self.sustain = false
end


function CameraShakeInstance:StartFadeIn(fadeInTime)
	if (fadeInTime == 0) then
		self.currentFadeTime = 1
	end
	self.fadeInDuration = fadeInTime or self.fadeInDuration
	self.fadeOutDuration = 0
	self.sustain = true
end


function CameraShakeInstance:GetScaleRoughness()
	return self.roughMod
end


function CameraShakeInstance:SetScaleRoughness(v)
	self.roughMod = v
end


function CameraShakeInstance:GetScaleMagnitude()
	return self.magnMod
end


function CameraShakeInstance:SetScaleMagnitude(v)
	self.magnMod = v
end


function CameraShakeInstance:GetNormalizedFadeTime()
	return self.currentFadeTime
end


function CameraShakeInstance:IsShaking()
	return (self.currentFadeTime > 0 or self.sustain)
end


function CameraShakeInstance:IsFadingOut()
	return ((not self.sustain) and self.currentFadeTime > 0)
end


function CameraShakeInstance:IsFadingIn()
	return (self.currentFadeTime < 1 and self.sustain and self.fadeInDuration > 0)
end


function CameraShakeInstance:GetState()
	if (self:IsFadingIn()) then
		return CameraShakeInstance.CameraShakeState.FadingIn
	elseif (self:IsFadingOut()) then
		return CameraShakeInstance.CameraShakeState.FadingOut
	elseif (self:IsShaking()) then
		return CameraShakeInstance.CameraShakeState.Sustained
	else
		return CameraShakeInstance.CameraShakeState.Inactive
	end
end


return CameraShakeInstance