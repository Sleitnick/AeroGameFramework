-- Keyboard
-- Crazyman32
-- December 28, 2017

--[[
	
	Methods:
		Boolean   Keyboard:IsDown(keyCode)
		Boolean   Keyboard:AreAllDown(keyCodes...)
		Boolean   Keyboard:AreAnyDown(keyCodes...)
	

	Events:
		Keyboard.KeyDown(keyCode)
		Keyboard.KeyUp(keyCode)
	
--]]



local Keyboard = {}

local userInput = game:GetService("UserInputService")


function Keyboard:IsDown(keyCode)
	return userInput:IsKeyDown(keyCode)
end


function Keyboard:AreAllDown(...)
	for _,keyCode in pairs{...} do
		if (not userInput:IsKeyDown(keyCode)) then
			return false
		end
	end
	return true
end


function Keyboard:AreAnyDown(...)
	for _,keyCode in pairs{...} do
		if (userInput:IsKeyDown(keyCode)) then
			return true
		end
	end
	return false
end


function Keyboard:Start()
	
	userInput.InputBegan:Connect(function(input, processed)
		if (processed) then return end
		if (input.UserInputType == Enum.UserInputType.Keyboard) then
			self:FireEvent('KeyDown', input.KeyCode)
		end
	end)
	
	userInput.InputEnded:Connect(function(input, processed)
		if (input.UserInputType == Enum.UserInputType.Keyboard) then
			self:FireEvent('KeyUp', input.KeyCode)
		end
	end)
	
end


function Keyboard:Init()
	
	self:RegisterEvent('KeyUp')
	self:RegisterEvent('KeyDown')
	
end


return Keyboard
