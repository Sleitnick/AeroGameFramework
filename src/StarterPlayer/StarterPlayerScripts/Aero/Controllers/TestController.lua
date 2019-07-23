local TestController = {}


function TestController:Start()
	local testService = self.Services.Test.ABC.TestService
	local sum = testService:Add(5, 4)
	print("5 + 4 = " .. sum)
	print("Test", self.Services.AnotherService:Test())
	print("8 * 3 = ", self.Controllers.Test.Hello.Hi:Multiply(8, 3))
end


function TestController:Init()
end


return TestController