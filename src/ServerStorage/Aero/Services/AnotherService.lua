local AnotherService = {Client = {}}


AnotherService.Message = "Hello from AnotherService"


function AnotherService.Client:Test()
	return 32
end


function AnotherService:Start()
	local favNum = self.Services.Test.ABC.TestService.FavoriteNumber
	print("My favorite number is " .. favNum)
	print(self.Shared.Sharable.Lunch.Apple)
end


function AnotherService:Init()
end


return AnotherService