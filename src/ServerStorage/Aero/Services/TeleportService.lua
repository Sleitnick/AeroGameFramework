-- Teleport Service
-- Rocky28447
-- August 16, 2019

--[[
	
	An abstraction of Roblox's default TeleportService that interfaces
	with Aero's default data module to allow saving of player data before
	initiating player teleports with the intention of reducing risk of
	data loss. If you do not use Aero's default data module, a custom
	yield function may be passed.
	
	
	Server:
		
		TeleportService:Teleport(placeId, player [, teleportData, saveAndWait, customYieldFunction])
		TeleportService:TeleportParty(placeId, players [, teleportData, saveAndWait, customYieldFunction])
		TeleportService:TeleportToPlaceInstance(placeId, instanceId, player [, spawnName, teleportData, saveAndWait, customYieldFunction])
		TeleportService:TeleportToPrivateServer(placeId, players [, spawnName, teleportData, saveAndWait, customYieldFunction])
		TeleportService:TeleportToSpawnByName(placeId, spawnName, player [, teleportData, saveAndWait, customYieldFunction])
	
		TeleportService.TeleportInitFailed()


	Client:
		
	

--]]



local TeleportService = {Client = {}}
local literalTeleportService = game:GetService("TeleportService")
local DefaultDataModuleEnabled = false
local Data

local TELEPORT_INIT_FAILED_EVENT = "TeleportInitFailed"


local function SaveAllDefault(players)
	if (not DefaultDataModuleEnabled) then return end
	
	local thread = coroutine.running()
	local numPlayers = #players
	local numFlushed = 0
	local allSuccess = true
	if (numPlayers == 0) then return end
	
	local function IncFlushed()
		numFlushed = (numFlushed + 1)
		if (numFlushed == numPlayers) then
			assert(coroutine.resume(thread))
		end
	end
	
	for _, player in pairs(players) do
		spawn(function()
			local playerDataObject = Data.ForPlayer(player)
			local success = playerDataObject:SaveAll():Await()
			if (not success) then
				allSuccess = false
			end
			IncFlushed()
		end)
	end
	coroutine.yield()
	
--	if (not allSuccess) then
--		SaveAllDefault(players)
--	end
end


local function SaveDefaultOrYieldCustom(players, save, customYieldFunction)
	if (DefaultDataModuleEnabled and save) then
		SaveAllDefault(players)
	elseif (customYieldFunction and typeof(customYieldFunction) == "function") then
		customYieldFunction()
	end
end


function TeleportService:Teleport(placeId, player, teleportData, saveAndWait, customYieldFunction)
	SaveDefaultOrYieldCustom({player}, saveAndWait, customYieldFunction)
	literalTeleportService:Teleport(placeId, player, teleportData)
end


function TeleportService:TeleportParty(placeId, players, teleportData, saveAndWait, customYieldFunction)
	SaveDefaultOrYieldCustom(players, saveAndWait, customYieldFunction)
	literalTeleportService:TeleportPartyAsync(placeId, players, teleportData)
end


function TeleportService:TeleportToPlaceInstance(placeId, instanceId, player, spawnName, teleportData, saveAndWait, customYieldFunction)
	SaveDefaultOrYieldCustom({player}, saveAndWait, customYieldFunction)
	literalTeleportService:TeleportPartyAsync(placeId, instanceId, player, spawnName, teleportData)
end


function TeleportService:TeleportToPrivateServer(placeId, players, spawnName, teleportData, saveAndWait, customYieldFunction)
	local accessCode, privateServerId = literalTeleportService:ReserveServer(placeId)
	SaveDefaultOrYieldCustom(players, saveAndWait, customYieldFunction)
	literalTeleportService:TeleportToPrivateServer(placeId, accessCode, players, spawnName, teleportData)
end


function TeleportService:TeleportToSpawnByName(placeId, spawnName, player, teleportData, saveAndWait, customYieldFunction)
	SaveDefaultOrYieldCustom({player}, saveAndWait, customYieldFunction)
	literalTeleportService:TeleportToSpawnByName(placeId, spawnName, player, teleportData)
end


function TeleportService:Start()
	
	literalTeleportService.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage)
		self:FireEvent(TELEPORT_INIT_FAILED_EVENT, player, teleportResult, errorMessage)
	end)
	
end


function TeleportService:Init()
	
	Data = self.Modules.Data
	
	if (Data) then
		DefaultDataModuleEnabled = true
	else
		warn('The default Aero data module ("data" branch on GitHub) is not enabled so player data will not be saved before teleport.')
	end
	
	self:RegisterEvent(TELEPORT_INIT_FAILED_EVENT)

end


return TeleportService
