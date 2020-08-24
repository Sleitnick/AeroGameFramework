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

local RAY_DISTANCE = 1000

local workspace = workspace

local userInput = game:GetService("UserInputService")
local cam = workspace.CurrentCamera


function Mobile:GetRay(position)
	local viewportMouseRay = cam:ViewportPointToRay(position.X, position.Y)
	return Ray.new(viewportMouseRay.Origin, viewportMouseRay.Direction * RAY_DISTANCE)
end


function Mobile:Cast(position, ignoreDescendantsInstance, terrainCellsAreCubes, ignoreWater)
	warn("Mobile:Cast() is deprecated; please use Mouse:Raycast(raycastParams) instead")
	return workspace:FindPartOnRay(self:GetRay(position), ignoreDescendantsInstance, terrainCellsAreCubes, ignoreWater)
end


function Mobile:CastWithIgnoreList(position, ignoreDescendantsTable, terrainCellsAreCubes, ignoreWater)
	warn("Mobile:CastWithIgnoreList() is deprecated; please use Mouse:Raycast(raycastParams) instead")
	return workspace:FindPartOnRayWithIgnoreList(self:GetRay(position), ignoreDescendantsTable, terrainCellsAreCubes, ignoreWater)
end


function Mobile:CastWithWhitelist(position, whitelistDescendantsTable, ignoreWater)
	warn("Mobile:CastWithWhitelist() is deprecated; please use Mouse:Raycast(raycastParams) instead")
	return workspace:FindPartOnRayWithWhitelist(self:GetRay(position), whitelistDescendantsTable, ignoreWater)
end


function Mobile:Raycast(raycastParams, distance)
	local mousePos = userInput:GetMouseLocation()
	local viewportMouseRay = cam:ViewportPointToRay(mousePos.X, mousePos.Y)
	return workspace:Raycast(viewportMouseRay.Origin, viewportMouseRay.Direction * (distance or RAY_DISTANCE), raycastParams)
end


function Mobile:Init()
	
	self.TouchStarted = self.Shared.Signal.new()
	self.TouchEnded = self.Shared.Signal.new()
	self.TouchMoved = self.Shared.Signal.new()
	self.TouchTapInWorld = self.Shared.Signal.new()
	self.TouchPinch = self.Shared.Signal.new()
	self.TouchLongPress = self.Shared.Signal.new()
	self.TouchPan = self.Shared.Signal.new()
	self.TouchRotate = self.Shared.Signal.new()
	self.TouchSwipe = self.Shared.Signal.new()
	self.TouchTap = self.Shared.Signal.new()
	
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
