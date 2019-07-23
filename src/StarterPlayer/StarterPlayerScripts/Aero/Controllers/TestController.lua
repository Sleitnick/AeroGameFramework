local TestController = {}


function TestController:Start()
	local testService = self.Services.Test.ABC.TestService
	local sum = testService:Add(5, 4)
	print("5 + 4 = " .. sum)
	print("Test", self.Services.AnotherService:Test())
end


return TestController