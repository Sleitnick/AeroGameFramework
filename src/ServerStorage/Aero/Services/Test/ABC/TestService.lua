local TestService = {Client = {}}


TestService.FavoriteNumber = 32


function TestService:Start()
	print("Start TestService")
	print("Message:", self.Services.AnotherService.Message)
end


function TestService:Init()
	print("Init TestService")
	self:RegisterEvent("Hi")
end


return TestService