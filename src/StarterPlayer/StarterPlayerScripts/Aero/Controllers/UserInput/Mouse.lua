-- Mouse
-- Stephen Leitnick
-- December 28, 2017

--[[

	Vector2   Mouse:GetPosition()
	Vector2   Mouse:GetDelta()
	Void      Mouse:Lock()
	Void      Mouse:LockCenter()
	Void      Mouse:Unlock()
	Ray       Mouse:GetRay(distance)
	Ray       Mouse:GetRayFromXY(x, y)
	Void      Mouse:SetMouseIcon(iconId)
	Void      Mouse:SetMouseIconEnabled(isEnabled)
	Boolean   Mouse:IsMouseIconEnabled()
	Booleam   Mouse:IsButtonPressed(mouseButton)
	Many      Mouse:Cast(ignoreDescendantsInstance, terrainCellsAreCubes, ignoreWater)
	Many      Mouse:CastWithIgnoreList(ignoreDescendantsTable, terrainCellsAreCubes, ignoreWater)
	Many      Mouse:CastWithWhitelist(whitelistDescendantsTable, ignoreWater)

	Mouse.LeftDown()
	Mouse.LeftUp()
	Mouse.RightDown()
	Mouse.RightUp()
	Mouse.MiddleDown()
	Mouse.MiddleUp()
	Mouse.Moved()
	Mouse.Scrolled(amount)

--]]


local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Mouse = {}

local playerMouse = Players.LocalPlayer:GetMouse()
local cam = Workspace.CurrentCamera

local workspace = workspace
local RAY = Ray.new

local RAY_DISTANCE = 999


function Mouse.GetPosition()
	return UserInputService:GetMouseLocation()
end


function Mouse.GetDelta()
	return UserInputService:GetMouseDelta()
end


function Mouse.Lock()
	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
end


function Mouse.LockCenter()
	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
end


function Mouse.Unlock()
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
end


function Mouse.SetMouseIcon(_, iconId)
	playerMouse.Icon = (iconId and ("rbxassetid://" .. iconId) or "")
end


function Mouse.SetMouseIconEnabled(_, enabled)
	UserInputService.MouseIconEnabled = enabled
end


function Mouse.IsMouseIconEnabled()
	return UserInputService.MouseIconEnabled
end


function Mouse.IsButtonPressed(_, mouseButton)
	return UserInputService:IsMouseButtonPressed(mouseButton)
end


function Mouse.GetRay(_, distance)
	local mousePos = UserInputService:GetMouseLocation()
	local viewportMouseRay = cam:ViewportPointToRay(mousePos.X, mousePos.Y)
	return RAY(viewportMouseRay.Origin, viewportMouseRay.Direction * distance)
end


function Mouse.GetRayFromXY(_, x, y)
	local viewportMouseRay = cam:ViewportPointToRay(x, y)
	return RAY(viewportMouseRay.Origin, viewportMouseRay.Direction)
end


function Mouse.GetOriginAndDirection(_, distance)
	local mousePos = UserInputService:GetMouseLocation()
	local viewportMouseRay = cam:ViewportPointToRay(mousePos.X, mousePos.Y)
	return viewportMouseRay.Origin, viewportMouseRay.Direction * distance
end


function Mouse.GetOriginAndDirectionFromXY(_, x, y)
	local viewportMouseRay = cam:ViewportPointToRay(x, y)
	return viewportMouseRay.Origin, viewportMouseRay.Direction
end


function Mouse:CastLegacy(ignoreDescendantsInstance, terrainCellsAreCubes, ignoreWater)
	return Workspace:FindPartOnRay(self:GetRay(RAY_DISTANCE), ignoreDescendantsInstance, terrainCellsAreCubes, ignoreWater)
end


function Mouse:CastWithIgnoreListLegacy(ignoreDescendantsTable, terrainCellsAreCubes, ignoreWater)
	return Workspace:FindPartOnRayWithIgnoreList(self:GetRay(RAY_DISTANCE), ignoreDescendantsTable, terrainCellsAreCubes, ignoreWater)
end


function Mouse:CastWithWhitelistLegacy(whitelistDescendantsTable, ignoreWater)
	return Workspace:FindPartOnRayWithWhitelist(self:GetRay(RAY_DISTANCE), whitelistDescendantsTable, ignoreWater)
end


local castParameters = RaycastParams.new()
castParameters.FilterType = Enum.RaycastFilterType.Blacklist

function Mouse:Cast(ignoreDescendantsInstance, _, ignoreWater)
	castParameters.FilterDescendantsInstances = table.create(1, ignoreDescendantsInstance)
	castParameters.IgnoreWater = ignoreWater

	local raycastResults = Workspace:Raycast(self:GetOriginAndDirection(RAY_DISTANCE), castParameters)
	if raycastResults then
		return raycastResults.Instance, raycastResults.Position, raycastResults.Normal, raycastResults.Material
	else
		return nil, nil, nil, nil
	end
end


local ignoreListParameters = RaycastParams.new()
ignoreListParameters.FilterType = Enum.RaycastFilterType.Blacklist

function Mouse:CastWithIgnoreList(ignoreDescendantsTable, _, ignoreWater)
	ignoreListParameters.FilterDescendantsInstances = ignoreDescendantsTable
	ignoreListParameters.IgnoreWater = ignoreWater

	local raycastResults = Workspace:Raycast(self:GetOriginAndDirection(RAY_DISTANCE), ignoreListParameters)
	if raycastResults then
		return raycastResults.Instance, raycastResults.Position, raycastResults.Normal, raycastResults.Material
	else
		return nil, nil, nil, nil
	end
end


local whitelistParameters = RaycastParams.new()
whitelistParameters.FilterType = Enum.RaycastFilterType.Whitelist

function Mouse:CastWithWhitelist(whitelistDescendantsTable, ignoreWater)
	ignoreListParameters.FilterDescendantsInstances = whitelistDescendantsTable
	ignoreListParameters.IgnoreWater = ignoreWater

	local raycastResults = Workspace:Raycast(self:GetOriginAndDirection(RAY_DISTANCE), whitelistParameters)
	if raycastResults then
		return raycastResults.Instance, raycastResults.Position, raycastResults.Normal, raycastResults.Material
	else
		return nil, nil, nil, nil
	end
end


function Mouse.Start()

end


function Mouse:Init()

	self.LeftDown = self.Shared.Event.new()
	self.LeftUp = self.Shared.Event.new()
	self.RightDown = self.Shared.Event.new()
	self.RightUp = self.Shared.Event.new()
	self.MiddleDown = self.Shared.Event.new()
	self.MiddleUp = self.Shared.Event.new()
	self.Moved = self.Shared.Event.new()
	self.Scrolled = self.Shared.Event.new()

	UserInputService.InputBegan:Connect(function(input, processed)
		if (processed) then
			return
		end
		if (input.UserInputType == Enum.UserInputType.MouseButton1) then
			self.LeftDown:Fire()
		elseif (input.UserInputType == Enum.UserInputType.MouseButton2) then
			self.RightDown:Fire()
		elseif (input.UserInputType == Enum.UserInputType.MouseButton3) then
			self.MiddleDown:Fire()
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1) then
			self.LeftUp:Fire()
		elseif (input.UserInputType == Enum.UserInputType.MouseButton2) then
			self.RightUp:Fire()
		elseif (input.UserInputType == Enum.UserInputType.MouseButton3) then
			self.MiddleUp:Fire()
		end
	end)

	UserInputService.InputChanged:Connect(function(input, processed)
		if (input.UserInputType == Enum.UserInputType.MouseMovement) then
			self.Moved:Fire()
		elseif (input.UserInputType == Enum.UserInputType.MouseWheel) then
			if (not processed) then
				self.Scrolled:Fire(input.Position.Z)
			end
		end
	end)

end


return Mouse
