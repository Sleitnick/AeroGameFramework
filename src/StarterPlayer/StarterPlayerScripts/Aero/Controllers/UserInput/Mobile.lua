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

local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local Mobile = {}

local cam = Workspace.CurrentCamera


function Mobile.GetRay(_, position)
	local viewportMouseRay = cam:ViewportPointToRay(position.X, position.Y)
	return Ray.new(viewportMouseRay.Origin, viewportMouseRay.Direction * 999)
end


function Mobile.GetOriginAndDirection(_, position)
	local viewportMouseRay = cam:ViewportPointToRay(position.X, position.Y)
	return viewportMouseRay.Origin, viewportMouseRay.Direction * 999
end


function Mobile:CastLegacy(position, ignoreDescendantsInstance, terrainCellsAreCubes, ignoreWater)
	return Workspace:FindPartOnRay(self:GetRay(position), ignoreDescendantsInstance, terrainCellsAreCubes, ignoreWater)
end


function Mobile:CastWithIgnoreListLegacy(position, ignoreDescendantsTable, terrainCellsAreCubes, ignoreWater)
	return Workspace:FindPartOnRayWithIgnoreList(self:GetRay(position), ignoreDescendantsTable, terrainCellsAreCubes, ignoreWater)
end


function Mobile:CastWithWhitelistLegacy(position, whitelistDescendantsTable, ignoreWater)
	return Workspace:FindPartOnRayWithWhitelist(self:GetRay(position), whitelistDescendantsTable, ignoreWater)
end


local castParameters = RaycastParams.new()
castParameters.FilterType = Enum.RaycastFilterType.Blacklist

function Mobile:Cast(position, ignoreDescendantsInstance, _, ignoreWater)
	castParameters.FilterDescendantsInstances = table.create(1, ignoreDescendantsInstance)
	castParameters.IgnoreWater = ignoreWater

	local raycastResults = Workspace:Raycast(self:GetOriginAndDirection(position), castParameters)
	if raycastResults then
		return raycastResults.Instance, raycastResults.Position, raycastResults.Normal, raycastResults.Material
	else
		return nil, nil, nil, nil
	end
end


local ignoreListParameters = RaycastParams.new()
ignoreListParameters.FilterType = Enum.RaycastFilterType.Blacklist

function Mobile:CastWithIgnoreList(position, ignoreDescendantsTable, _, ignoreWater)
	ignoreListParameters.FilterDescendantsInstances = ignoreDescendantsTable
	ignoreListParameters.IgnoreWater = ignoreWater

	local raycastResults = Workspace:Raycast(self:GetOriginAndDirection(position), ignoreListParameters)
	if raycastResults then
		return raycastResults.Instance, raycastResults.Position, raycastResults.Normal, raycastResults.Material
	else
		return nil, nil, nil, nil
	end
end


local whitelistParameters = RaycastParams.new()
whitelistParameters.FilterType = Enum.RaycastFilterType.Whitelist

function Mobile:CastWithWhitelist(position, whitelistDescendantsTable, ignoreWater)
	whitelistParameters.FilterDescendantsInstances = whitelistDescendantsTable
	whitelistParameters.IgnoreWater = ignoreWater

	local raycastResults = Workspace:Raycast(self:GetOriginAndDirection(position), whitelistParameters)
	if raycastResults then
		return raycastResults.Instance, raycastResults.Position, raycastResults.Normal, raycastResults.Material
	else
		return nil, nil, nil, nil
	end
end


function Mobile.Start()

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

	UserInputService.TouchStarted:Connect(function(input, processed)
		if (processed) then
			return
		end
		self.TouchStarted:Fire(input.Position)
	end)

	UserInputService.TouchEnded:Connect(function(input)
		self.TouchEnded:Fire(input.Position)
	end)

	UserInputService.TouchMoved:Connect(function(input, processed)
		if (processed) then
			return
		end
		self.TouchMoved:Fire(input.Position, input.Delta)
	end)

	UserInputService.TouchTapInWorld:Connect(function(position, processed)
		if (processed) then
			return
		end
		self.TouchTapInWorld:Fire(position)
	end)

	UserInputService.TouchPinch:Connect(function(touchPositions, scale, velocity, state, processed)
		if (processed) then
			return
		end
		self.TouchPinch:Fire(touchPositions, scale, velocity, state)
	end)

	UserInputService.TouchLongPress:Connect(function(touchPositions, state, processed)
		if (processed) then
			return
		end
		self.TouchLongPress:Fire(touchPositions, state)
	end)

	UserInputService.TouchPan:Connect(function(touchPositions, totalTranslation, velocity, state, processed)
		if (processed) then
			return
		end
		self.TouchPan:Fire(touchPositions, totalTranslation, velocity, state)
	end)

	UserInputService.TouchRotate:Connect(function(touchPositions, rotation, velocity, state, processed)
		if (processed) then
			return
		end
		self.TouchRotate:Fire(touchPositions, rotation, velocity, state)
	end)

	UserInputService.TouchSwipe:Connect(function(swipeDirection, numberOfTouches, processed)
		if (processed) then
			return
		end
		self.TouchSwipe:Fire(swipeDirection, numberOfTouches)
	end)

	UserInputService.TouchTap:Connect(function(touchPositions, processed)
		if (processed) then
			return
		end
		self.TouchTap:Fire(touchPositions)
	end)

	self.GetDeviceAcceleration = UserInputService.GetDeviceAcceleration
	self.GetDeviceGravity = UserInputService.GetDeviceGravity
	self.GetDeviceRotation = UserInputService.GetDeviceRotation
	self.DeviceAccelerationChanged = UserInputService.DeviceAccelerationChanged
	self.DeviceGravityChanged = UserInputService.DeviceGravityChanged
	self.DeviceRotationChanged = UserInputService.DeviceRotationChanged

end


return Mobile
