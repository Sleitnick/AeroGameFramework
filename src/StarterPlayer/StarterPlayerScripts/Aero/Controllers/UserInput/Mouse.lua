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



local Mouse = {}

local playerMouse = game:GetService("Players").LocalPlayer:GetMouse()
local userInput = game:GetService("UserInputService")
local cam = workspace.CurrentCamera

local workspace = workspace
local RAY = Ray.new

local RAY_DISTANCE = 999


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
	return RAY(viewportMouseRay.Origin, viewportMouseRay.Direction * distance)
end


function Mouse:GetRayFromXY(x, y)
	local viewportMouseRay = cam:ViewportPointToRay(x, y)
	return RAY(viewportMouseRay.Origin, viewportMouseRay.Direction)
end


function Mouse:Cast(ignoreDescendantsInstance, terrainCellsAreCubes, ignoreWater)
	return workspace:FindPartOnRay(self:GetRay(RAY_DISTANCE), ignoreDescendantsInstance, terrainCellsAreCubes, ignoreWater)
end


function Mouse:CastWithIgnoreList(ignoreDescendantsTable, terrainCellsAreCubes, ignoreWater)
	return workspace:FindPartOnRayWithIgnoreList(self:GetRay(RAY_DISTANCE), ignoreDescendantsTable, terrainCellsAreCubes, ignoreWater)
end


function Mouse:CastWithWhitelist(whitelistDescendantsTable, ignoreWater)
	return workspace:FindPartOnRayWithWhitelist(self:GetRay(RAY_DISTANCE), whitelistDescendantsTable, ignoreWater)
end


function Mouse:Start()
	
end


function Mouse:Init()
	
	self.LeftDown   = self.Shared.Event.new()
	self.LeftUp     = self.Shared.Event.new()
	self.RightDown  = self.Shared.Event.new()
	self.RightUp    = self.Shared.Event.new()
	self.MiddleDown = self.Shared.Event.new()
	self.MiddleUp   = self.Shared.Event.new()
	self.Moved      = self.Shared.Event.new()
	self.Scrolled   = self.Shared.Event.new()
	
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
