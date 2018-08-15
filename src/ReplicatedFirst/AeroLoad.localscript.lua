--[[
	
	At its heart, the way to wait for the AeroGameFramework to
	load is to simply wait for it to exist in the _G table:
	
		while (not _G.Aero) do wait() end
		local aero = _G.Aero
	
	
	The following code shows how to do this with a custom GUI,
	but you will have to fill in some of the code yourself.

	IF YOU USE THIS CODE, MAKE SURE TO PUT IT IN A FILE NAMED 
	SOMETHING OTHER THAN 'AeroLoad' SO FUTURE FRAMEWORK UPDATES 
	DO NOT OVERWRITE YOUR CUSTOM 'AeroLoad' SCRIPT. YOU CAN NAME 
	IT ANYTHING, LIKE 'MyCustomAeroLoad'
	
]]

--[[  UNCOMMENT TO USE THIS TEMPLATE (BUT BE SURE TO ADD YOUR OWN GUI ON LINE 47)

local player = game.Players.LocalPlayer

-- Temporary blackout used until the Aero Fade module is loaded:
local tempBlackout = Instance.new("ScreenGui")
tempBlackout.Name = "TemporaryBlackout"
tempBlackout.DisplayOrder = 10
do
	local frame = Instance.new("Frame")
	frame.Name = "Overlay"
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Size = UDim2.new(2, 0, 2, 0)
	frame.BackgroundColor3 = Color3.new(0, 0, 0)
	frame.Parent = tempBlackout
end

-- Remove default loading screen & replace with a temporary black overlay:
tempBlackout.Parent = player:WaitForChild("PlayerGui")
game:GetService("ReplicatedFirst"):RemoveDefaultLoadingScreen()

-- Wait for the Aero client to load:
while (not _G.Aero) do wait() end
local aero = _G.Aero

-- Make screen black using the Aero Fade module:
aero.Controllers.Fade:Out(0)

-- Remove the temporary overlay, since we don't need it anymore:
tempBlackout:Destroy()

-- Add in your own loading screen GUI:
local loadingGui = script.YOUR_CUSTOM_GUI
loadingGui.Parent = player:WaitForChild("PlayerGui")

-- Fade in slowly to show your loading screen:
aero.Controllers.Fade:In(1)

-- Wait for the game to load if not loaded yet:
if (not game:IsLoaded()) then
	game.Loaded:Wait()
end

-- INSERT OTHER LOADING THINGS HERE
-- EXAMPLE: game:GetService("ContentProvider"):PreloadAsync({foo, bar, etc})

-- Fade out to black, remove your GUI, and then fade back in:
wait(3)
aero.Controllers.Fade:Out(1)
loadingGui:Destroy()
aero.Controllers.Fade:In(1)

]]
