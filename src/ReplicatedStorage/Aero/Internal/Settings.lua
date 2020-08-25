-- Settings
-- Stephen Leitnick
-- August 25, 2020

--[[

	Settings.InternalSettings {
		DefaultOrder: number
	}

	Settings:Get(moduleScript) -> table
	Settings:GetDefault() -> table
	Settings:IsSettingsModule(moduleScript) -> boolean

--]]



local Settings = {}

Settings.InternalSettings = {
	DefaultOrder = 1000;
}

local SUFFIX = ".settings"
local DEFAULT_SETTINGS = {
	Order = Settings.InternalSettings.DefaultOrder;
	PreventInit = false;
	PreventStart = false;
	Standalone = false;
}

local cache = {}


function Settings:GetDefault()
	-- Make a copy of the default settings table:
	local s = {}
	for k,v in pairs(DEFAULT_SETTINGS) do
		s[k] = v
	end
	return s
end


function Settings:Get(moduleScript, shouldCache)

	local settingsName = (moduleScript.Name .. SUFFIX)
	local settingsTbl = cache[settingsName]

	-- Return from cache if found:
	if (settingsTbl) then
		return settingsTbl
	end

	-- Find the actual settings module:
	local settingsModule = moduleScript.Parent:FindFirstChild(settingsName)

	-- Load settings module if available, or else load default settings:
	if (settingsModule) then
		settingsTbl = require(settingsModule)
		assert(type(settingsTbl) == "table", "Settings module should return a table")
	else
		settingsTbl = self:GetDefault()
	end

	-- Cache if requested:
	if (shouldCache) then
		cache[settingsName] = settingsTbl
	end

	return settingsTbl

end


function Settings:IsSettingsModule(moduleScript)
	return (moduleScript:IsA("ModuleScript") and moduleScript.Name:match(SUFFIX .. "$") ~= nil)
end


return Settings