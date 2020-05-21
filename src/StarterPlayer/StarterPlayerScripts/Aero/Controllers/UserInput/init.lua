-- User Input
-- Stephen Leitnick
-- January 2, 2018

--[[
	
	UserInput simply encapsulates all user input modules.
	
	UserInput.Preferred
		- Keyboard
		- Mouse
		- Gamepad
		- Touch
	
	UserInput:Get(inputModuleName)
	UserInput:GetPreferred()

	UserInput.PreferredChanged(preferred)
	
	
	Example:
	
	local keyboard = userInput:Get("Keyboard")
	keyboard.KeyDown:Connect(function(key) end)
	
--]]



local UserInput = {}

UserInput.HideMouse = false

UserInput.Preferred = {
	Keyboard = 0;
	Mouse = 1;
	Gamepad = 2;
	Touch = 3;
}
UserInput._preferred = nil

local modules = {}
local userInput = game:GetService("UserInputService")


function UserInput:Get(moduleName)
	return modules[moduleName]
end


function UserInput:Init()

	for _,obj in ipairs(script:GetChildren()) do
		if (obj:IsA("ModuleScript")) then
			local module = require(obj)
			self:WrapModule(module)
			modules[obj.Name] = module
		end
	end
	
	local function SetMouseIconEnabled(enabled)
		if (self.HideMouse) then
			userInput.MouseIconEnabled = enabled
		end
	end

	local function ChangePreferred(newPreferred)
		if (self._preferred ~= newPreferred) then
			self._preferred = newPreferred
			self.PreferredChanged:Fire(newPreferred)
			if (newPreferred == self.Preferred.Mouse or newPreferred == self.Preferred.Keyboard) then
				SetMouseIconEnabled(true)
			else
				SetMouseIconEnabled(false)
			end
		end
	end

	local function LastInputTypeChanged(lastInputType)
		if (lastInputType.Name:match("^Mouse")) then
			ChangePreferred(self.Preferred.Mouse)
		elseif (lastInputType == Enum.UserInputType.Keyboard or lastInputType == Enum.UserInputType.TextInput) then
			ChangePreferred(self.Preferred.Keyboard)
		elseif (lastInputType.Name:match("^Gamepad")) then
			ChangePreferred(self.Preferred.Gamepad)
		elseif (lastInputType == Enum.UserInputType.Touch) then
			ChangePreferred(self.Preferred.Touch)
		end
	end

	userInput.LastInputTypeChanged:Connect(LastInputTypeChanged)
	self.PreferredChanged = self.Shared.Event.new()

	if (game:GetService("GuiService"):IsTenFootInterface()) then
		ChangePreferred(self.Preferred.Gamepad)
	elseif (userInput.TouchEnabled) then
		ChangePreferred(self.Preferred.Touch)
	else
		ChangePreferred(self.Preferred.Keyboard)
	end

end


function UserInput:GetPreferred()
	return self._preferred
end


return UserInput
