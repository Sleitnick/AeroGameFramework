-- User Input
-- Crazyman32
-- January 2, 2018

--[[
	
	UserInput simply encapsulates all user input modules.
	
	
	UserInput:Get(inputModuleName)
	
	
	Example:
	
	local keyboard = userInput:Get("Keyboard")
	keyboard.KeyDown:Connect(function(key) end)
	
--]]



local UserInput = {}

local modules = {}


function UserInput:Get(moduleName)
	local module = modules[moduleName]
	if (not module) then
		local moduleScript = script:FindFirstChild(moduleName)
		if (moduleScript and moduleScript:IsA("ModuleScript")) then
			module = require(moduleScript)
			setmetatable(module, getmetatable(self))
			if (type(module.Init) == "function") then
				module:Init()
			end
			if (type(module.Start) == "function") then
				coroutine.wrap(module.Start)(module)
			end
			modules[moduleName] = module
		end
	end
	return module
end


return UserInput