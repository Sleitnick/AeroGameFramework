local AnotherService = {}


AnotherService.Message = "Hello from AnotherService"


function AnotherService:Start()
	local favNum = self.Services.Test.ABC.TestService.FavoriteNumber
	print("My favorite number is " .. favNum)
end


function AnotherService:Init()
end


return AnotherService