-- Client controller:
function MyController:Start()
	self.Services.CustomService.Hello:Fire("Hello from the client")
end

---------------------------------------------------------------------

-- Server service:
function CustomService:Start()
	self.Services:ConnectClientEvent("Hello", function(player, msg)
		print(player.Name .. " says: " .. msg)
	end)
end

function CustomService:Init()
	self:RegisterClientEvent("Hello")
end