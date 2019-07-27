-- Mouse
-- Crazyman32
-- December 28, 2017

--[[
	
	Methods:
		Vector2   Mouse:GetPosition()
		Vector2   Mouse:GetDelta()
		Void      Mouse:Lock()
		Void      Mouse:LockCenter()
		Void      Mouse:Unlock()
		Void      Mouse:SetMouseIcon(iconId)
		Void      Mouse:SetMouseIconEnabled(isEnabled)
		Boolean   Mouse:IsMouseIconEnabled()
		Many      Mouse:Cast(ignoreDescendantsInstance, terrainCellsAreCubes, ignoreWater)
		Many      Mouse:CastWithIgnoreList(ignoreDescendantsTable, terrainCellsAreCubes, ignoreWater)
		Many      Mouse:CastWithWhitelist(whitelistDescendantsTable, ignoreWater)
	
	
	Events:
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


function Mouse:GetRay()
	local mousePos = userInput:GetMouseLocation()
	local viewportMouseRay = cam:ViewportPointToRay(mousePos.X, mousePos.Y)
	return RAY(viewportMouseRay.Origin, viewportMouseRay.Direction * 999)
end


function Mouse:Cast(ignoreDescendantsInstance, terrainCellsAreCubes, ignoreWater)
	return workspace:FindPartOnRay(self:GetRay(), ignoreDescendantsInstance, terrainCellsAreCubes, ignoreWater)
end


function Mouse:CastWithIgnoreList(ignoreDescendantsTable, terrainCellsAreCubes, ignoreWater)
	return workspace:FindPartOnRayWithIgnoreList(self:GetRay(), ignoreDescendantsTable, terrainCellsAreCubes, ignoreWater)
end


function Mouse:CastWithWhitelist(whitelistDescendantsTable, ignoreWater)
	return workspace:FindPartOnRayWithWhitelist(self:GetRay(), whitelistDescendantsTable, ignoreWater)
end


function Mouse:Start()
	
	userInput.InputBegan:Connect(function(input, processed)
		if (processed) then return end
		if (input.UserInputType == Enum.UserInputType.MouseButton1) then
			self:FireEvent('LeftDown')
		elseif (input.UserInputType == Enum.UserInputType.MouseButton2) then
			self:FireEvent('RightDown')
		elseif (input.UserInputType == Enum.UserInputType.MouseButton3) then
			self:FireEvent('MiddleDown')
		end
	end)
	
	userInput.InputEnded:Connect(function(input, processed)
		if (input.UserInputType == Enum.UserInputType.MouseButton1) then
			self:FireEvent('LeftUp')
		elseif (input.UserInputType == Enum.UserInputType.MouseButton2) then
			self:FireEvent('RightUp')
		elseif (input.UserInputType == Enum.UserInputType.MouseButton3) then
			self:FireEvent('MiddleUp')
		end
	end)
	
	userInput.InputChanged:Connect(function(input, processed)
		if (input.UserInputType == Enum.UserInputType.MouseMovement) then
			self:FireEvent('Moved')
		elseif (input.UserInputType == Enum.UserInputType.MouseWheel) then
			if (processed) then return end
			
			self:FireEvent('Scrolled', input.Position.Z)
		end
	end)
	
end


function Mouse:Init()
	
	self:RegisterEvent('LeftDown')
	self:RegisterEvent('LeftUp')
	self:RegistetEvent('RightDown')
	self:RegisterEvent('RightUp')
	self:RegisterEvent('MiddleDown')
	self:RegisterEvent('MiddleUp')
	self:RegisterEvent('Moved')
	self:RegisterEvent('Scrolled')
	
end


return Mouse
