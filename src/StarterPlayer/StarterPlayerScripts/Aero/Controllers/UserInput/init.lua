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
	return modules[moduleName]
end


function UserInput:Init()
	for _,obj in pairs(script:GetChildren()) do
		if (obj:IsA("ModuleScript")) then
			local module = require(obj)
			setmetatable(module, getmetatable(self))
			if (type(module.Init) == "function") then
				module:Init()
			end
			if (type(module.Start) == "function") then
				coroutine.wrap(module.Start)(module)
			end
			modules[obj.Name] = module
		end
	end
end


return UserInput