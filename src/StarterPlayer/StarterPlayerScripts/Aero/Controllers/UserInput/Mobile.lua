-- Mobile
-- Stephen Leitnick
-- December 28, 2017

--[[

	Mobile:GetDeviceAcceleration()
	Mobile:GetDeviceGravity()
	Mobile:GetDeviceRotation()
	
	Mobile.TouchStarted(position)
	Mobile.TouchEnded(position)
	Mobile.TouchMoved(position, delta)
	Mobile.TouchTapInWorld(position)
	Mobile.TouchPinch(touchPositions, scale, velocity, state)
	Mobile.TouchLongPress(touchPositions, state)
	Mobile.TouchPan(touchPositions, totalTranslation, velocity, state)
	Mobile.TouchRotate(touchPositions, rotation, velocity, state)
	Mobile.TouchSwipe(swipeDirection, numberOfTouches)
	Mobile.TouchTap(touchPositions)
	Mobile.DeviceAccelerationChanged(acceleration)
	Mobile.DeviceGravityChanged(gravity)
	Mobile.DeviceRotationChanged(rotation, cframe)
	
--]]



local Mobile = {}

local RAY = Ray.new
local workspace = workspace

local userInput = game:GetService("UserInputService")
local cam = workspace.CurrentCamera


function Mobile:GetRay(position)
	local viewportMouseRay = cam:ViewportPointToRay(position.X, position.Y)
	return RAY(viewportMouseRay.Origin, viewportMouseRay.Direction * 999)
end


function Mobile:Cast(position, ignoreDescendantsInstance, terrainCellsAreCubes, ignoreWater)
	return workspace:FindPartOnRay(self:GetRay(position), ignoreDescendantsInstance, terrainCellsAreCubes, ignoreWater)
end


function Mobile:CastWithIgnoreList(position, ignoreDescendantsTable, terrainCellsAreCubes, ignoreWater)
	return workspace:FindPartOnRayWithIgnoreList(self:GetRay(position), ignoreDescendantsTable, terrainCellsAreCubes, ignoreWater)
end


function Mobile:CastWithWhitelist(position, whitelistDescendantsTable, ignoreWater)
	return workspace:FindPartOnRayWithWhitelist(self:GetRay(position), whitelistDescendantsTable, ignoreWater)
end


function Mobile:Start()
	
end


function Mobile:Init()
	
	self.TouchStarted = self.Shared.Event.new()
	self.TouchEnded = self.Shared.Event.new()
	self.TouchMoved = self.Shared.Event.new()
	self.TouchTapInWorld = self.Shared.Event.new()
	self.TouchPinch = self.Shared.Event.new()
	self.TouchLongPress = self.Shared.Event.new()
	self.TouchPan = self.Shared.Event.new()
	self.TouchRotate = self.Shared.Event.new()
	self.TouchSwipe = self.Shared.Event.new()
	self.TouchTap = self.Shared.Event.new()
	
	userInput.TouchStarted:Connect(function(input, processed)
		if (processed) then return end
		self.TouchStarted:Fire(input.Position)
	end)
	
	userInput.TouchEnded:Connect(function(input, _processed)
		self.TouchEnded:Fire(input.Position)
	end)
	
	userInput.TouchMoved:Connect(function(input, processed)
		if (processed) then return end
		self.TouchMoved:Fire(input.Position, input.Delta)
	end)
	
	userInput.TouchTapInWorld:Connect(function(position, processed)
		if (processed) then return end
		self.TouchTapInWorld:Fire(position)
	end)
	
	userInput.TouchPinch:Connect(function(touchPositions, scale, velocity, state, processed)
		if (processed) then return end
		self.TouchPinch:Fire(touchPositions, scale, velocity, state)
	end)

	userInput.TouchLongPress:Connect(function(touchPositions, state, processed)
		if (processed) then return end
		self.TouchLongPress:Fire(touchPositions, state)
	end)

	userInput.TouchPan:Connect(function(touchPositions, totalTranslation, velocity, state, processed)
		if (processed) then return end
		self.TouchPan:Fire(touchPositions, totalTranslation, velocity, state)
	end)

	userInput.TouchRotate:Connect(function(touchPositions, rotation, velocity, state, processed)
		if (processed) then return end
		self.TouchRotate:Fire(touchPositions, rotation, velocity, state)
	end)

	userInput.TouchSwipe:Connect(function(swipeDirection, numberOfTouches, processed)
		if (processed) then return end
		self.TouchSwipe:Fire(swipeDirection, numberOfTouches)
	end)

	userInput.TouchTap:Connect(function(touchPositions, processed)
		if (processed) then return end
		self.TouchTap:Fire(touchPositions)
	end)

	self.GetDeviceAcceleration = userInput.GetDeviceAcceleration
	self.GetDeviceGravity = userInput.GetDeviceGravity
	self.GetDeviceRotation = userInput.GetDeviceRotation
	self.DeviceAccelerationChanged = userInput.DeviceAccelerationChanged
	self.DeviceGravityChanged = userInput.DeviceGravityChanged
	self.DeviceRotationChanged = userInput.DeviceRotationChanged
	
end


return Mobile
