function MyService:Start()
	-- Fire client event for a specific player:
	self:FireClientEvent("MyClientEvent", somePlayer, "Hello")

	-- Fire client event for all players:
	self:FireAllClientsEvent("MyClientEvent", "Hello")
end

function MyService:Init()
	-- Register client event:
	self:RegisterClientEvent("MyClientMethod")
end