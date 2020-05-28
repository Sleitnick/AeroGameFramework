-- Keyboard
-- Stephen Leitnick
-- December 28, 2017

--[[

	Boolean   Keyboard:IsDown(keyCode)
	Boolean   Keyboard:AreAllDown(keyCodes...)
	Boolean   Keyboard:AreAnyDown(keyCodes...)

	Keyboard.KeyDown(keyCode)
	Keyboard.KeyUp(keyCode)

--]]


local UserInputService = game:GetService("UserInputService")

local Keyboard = {}


function Keyboard.IsDown(_, keyCode)
	return UserInputService:IsKeyDown(keyCode)
end


function Keyboard.AreAllDown(_, ...)
	for _,keyCode in ipairs{...} do
		if (not UserInputService:IsKeyDown(keyCode)) then
			return false
		end
	end
	return true
end


function Keyboard.AreAnyDown(_, ...)
	for _,keyCode in ipairs{...} do
		if (UserInputService:IsKeyDown(keyCode)) then
			return true
		end
	end
	return false
end


function Keyboard.Start()

end


function Keyboard:Init()

	self.KeyDown = self.Shared.Event.new()
	self.KeyUp = self.Shared.Event.new()

	UserInputService.InputBegan:Connect(function(input, processed)
		if (processed) then
			return
		end
		if (input.UserInputType == Enum.UserInputType.Keyboard) then
			self.KeyDown:Fire(input.KeyCode)
		end
	end)

	UserInputService.InputEnded:Connect(function(input, processed)
		if (processed) then
			return
		end
		if (input.UserInputType == Enum.UserInputType.Keyboard) then
			self.KeyUp:Fire(input.KeyCode)
		end
	end)

end


return Keyboard