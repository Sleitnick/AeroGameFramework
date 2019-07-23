local TestService = {Client = {}}


TestService.FavoriteNumber = 32


function TestService.Client:Add(player, a, b)
	return (a + b)
end


function TestService:Start()
	print("Start TestService")
	print("Message:", self.Services.AnotherService.Message)
end


function TestService:Init()
	print("Init TestService")
end


return TestService