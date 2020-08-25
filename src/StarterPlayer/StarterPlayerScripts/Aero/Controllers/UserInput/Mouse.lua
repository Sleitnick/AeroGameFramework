-- Mouse
-- Stephen Leitnick
-- December 28, 2017

--[[
	
	Vector2        Mouse:GetPosition()
	Vector2        Mouse:GetDelta()
	Void           Mouse:Lock()
	Void           Mouse:LockCenter()
	Void           Mouse:Unlock()
	Ray            Mouse:GetRay(distance)
	Ray            Mouse:GetRayFromXY(x, y)
	Void           Mouse:SetMouseIcon(iconId)
	Void           Mouse:SetMouseIconEnabled(isEnabled)
	Boolean        Mouse:IsMouseIconEnabled()
	Boolean        Mouse:IsButtonPressed(mouseButton)
	RaycastResult  Mouse:Raycast(raycastParams [, distance = 1000])
	
	Mouse.LeftDown()
	Mouse.LeftUp()
	Mouse.RightDown()
	Mouse.RightUp()
	Mouse.MiddleDown()
	Mouse.MiddleUp()
	Mouse.Moved()
	Mouse.Scrolled(amount)
	
--]]



local Mouse = {}

local RAY_DISTANCE = 1000

local playerMouse = game:GetService("Players").LocalPlayer:GetMouse()
local userInput = game:GetService("UserInputService")
local cam = workspace.CurrentCamera

local workspace = workspace


function Mouse:GetPosition()
	return userInput:GetMouseLocation()
end


function Mouse:GetDelta()
	return userInput:GetMouseDelta()
end


function Mouse:Lock()
	userInput.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
end


function Mouse:LockCenter()
	userInput.MouseBehavior = Enum.MouseBehavior.LockCenter
end


function Mouse:Unlock()
	userInput.MouseBehavior = Enum.MouseBehavior.Default
end


function Mouse:SetMouseIcon(iconId)
	playerMouse.Icon = (iconId and ("rbxassetid://" .. iconId) or "")
end


function Mouse:SetMouseIconEnabled(enabled)
	userInput.MouseIconEnabled = enabled
end


function Mouse:IsMouseIconEnabled()
	return userInput.MouseIconEnabled
end


function Mouse:IsButtonPressed(mouseButton)
	return userInput:IsMouseButtonPressed(mouseButton)
end


function Mouse:GetRay(distance)
	local mousePos = userInput:GetMouseLocation()
	local viewportMouseRay = cam:ViewportPointToRay(mousePos.X, mousePos.Y)
	return Ray.new(viewportMouseRay.Origin, viewportMouseRay.Direction * distance)
end


function Mouse:GetRayFromXY(x, y)
	local viewportMouseRay = cam:ViewportPointToRay(x, y)
	return Ray.new(viewportMouseRay.Origin, viewportMouseRay.Direction)
end


function Mouse:Cast(ignoreDescendantsInstance, terrainCellsAreCubes, ignoreWater)
	warn("Mouse:Cast() is deprecated; please use Mouse:Raycast(raycastParams) instead")
	return workspace:FindPartOnRay(self:GetRay(RAY_DISTANCE), ignoreDescendantsInstance, terrainCellsAreCubes, ignoreWater)
end


function Mouse:CastWithIgnoreList(ignoreDescendantsTable, terrainCellsAreCubes, ignoreWater)
	warn("Mouse:CastWithIgnoreList() is deprecated; please use Mouse:Raycast(raycastParams) instead")
	return workspace:FindPartOnRayWithIgnoreList(self:GetRay(RAY_DISTANCE), ignoreDescendantsTable, terrainCellsAreCubes, ignoreWater)
end


function Mouse:CastWithWhitelist(whitelistDescendantsTable, ignoreWater)
	warn("Mouse:CastWithWhitelist() is deprecated; please use Mouse:Raycast(raycastParams) instead")
	return workspace:FindPartOnRayWithWhitelist(self:GetRay(RAY_DISTANCE), whitelistDescendantsTable, ignoreWater)
end


function Mouse:Raycast(raycastParams, distance)
	local mousePos = userInput:GetMouseLocation()
	local viewportMouseRay = cam:ViewportPointToRay(mousePos.X, mousePos.Y)
	return workspace:Raycast(viewportMouseRay.Origin, viewportMouseRay.Direction * (distance or RAY_DISTANCE), raycastParams)
end


function Mouse:Init()
	
	self.LeftDown   = self.Shared.Signal.new()
	self.LeftUp     = self.Shared.Signal.new()
	self.RightDown  = self.Shared.Signal.new()
	self.RightUp    = self.Shared.Signal.new()
	self.MiddleDown = self.Shared.Signal.new()
	self.MiddleUp   = self.Shared.Signal.new()
	self.Moved      = self.Shared.Signal.new()
	self.Scrolled   = self.Shared.Signal.new()
	
	userInput.InputBegan:Connect(function(input, processed)
		if (processed) then return end
		if (input.UserInputType == Enum.UserInputType.MouseButton1) then
			self.LeftDown:Fire()
		elseif (input.UserInputType == Enum.UserInputType.MouseButton2) then
			self.RightDown:Fire()
		elseif (input.UserInputType == Enum.UserInputType.MouseButton3) then
			self.MiddleDown:Fire()
		end
	end)
	
	userInput.InputEnded:Connect(function(input, _processed)
		if (input.UserInputType == Enum.UserInputType.MouseButton1) then
			self.LeftUp:Fire()
		elseif (input.UserInputType == Enum.UserInputType.MouseButton2) then
			self.RightUp:Fire()
		elseif (input.UserInputType == Enum.UserInputType.MouseButton3) then
			self.MiddleUp:Fire()
		end
	end)
	
	userInput.InputChanged:Connect(function(input, processed)
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
