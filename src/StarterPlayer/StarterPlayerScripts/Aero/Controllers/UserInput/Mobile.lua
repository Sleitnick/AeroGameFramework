-- Mobile
-- Crazyman32
-- December 28, 2017

--[[
	
	Events:
		Mobile.TouchStarted(position)
		Mobile.TouchEnded(position)
		Mobile.TouchMoved(position, delta)
		Mobile.TouchTapInWorld(position)
		Mobile.TouchPinch(scale, state)
	
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
	
	userInput.TouchStarted:Connect(function(input, processed)
		if (processed) then return end
		self:FireEvent('TouchStarted', input.Position)
	end)
	
	userInput.TouchEnded:Connect(function(input, processed)
		self:FireEvent('TouchEnded', input.Position)
	end)
	
	userInput.TouchMoved:Connect(function(input, processed)
		if (processed) then return end
		self:FireEvent('TouchMoved', input.Position, input.Delta)
	end)
	
	userInput.TouchTapInWorld:Connect(function(position, processed)
		if (processed) then return end
		self:FireEvent('TouchTapInWorld', position)
	end)
	
	userInput.TouchPinch:Connect(function(touchPositions, scale, velocity, state, processed)
		if (processed) then return end
		self:FireEvent('TouchPinch', scale, state)
	end)
	
end


function Mobile:Init()
	
	self:RegisterEvent('TouchStarted')
	self:RegisterEvent('TouchEnded')
	self:RegisterEvent('TouchMoved')
	self:RegisterEvent('TouchTapInWorld')
	self:RegisterEvent('TouchPinch')
	
end


return Mobile
