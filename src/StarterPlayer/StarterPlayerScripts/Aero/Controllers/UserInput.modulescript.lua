-- User Input
-- Crazyman32
-- January 2, 2018

--[[
	
	UserInput simply encapsulates all user input modules.
	
	
	UserInput.(ModuleName)
	
	UserInput.Keyboard
	UserInput.Mouse
	UserInput.Gamepad
	UserInput.Mobile
	
	
	Example:
	
	local keyboard = userInput.Keyboard
	keyboard.KeyDown:Connect(function(key) end)
	
--]]



local UserInput = {}

local modules = {}


function UserInput:Start()
	
end


function UserInput:Init()
	
	local fallbackIndex = getmetatable(self).__index
	
	setmetatable(self, {
		__index = function(t, index)
			local value = modules[index] or fallbackIndex[index]
			if (value == nil and type(index) == "string") then
				local moduleScript = script:FindFirstChild(index)
				if (moduleScript and moduleScript:IsA("ModuleScript")) then
					-- Load, initiate, start, and return module:
					local module = require(moduleScript)
					setmetatable(module, {
						__index = fallbackIndex;
					})
					if (type(module.Init) == "function") then
						module:Init()
					end
					if (type(module.Start) == "function") then
						coroutine.wrap(module.Start)(module)
					end
					modules[index] = module
					value = module
				end
			end
			return value
		end;
	})
	
end


return UserInput