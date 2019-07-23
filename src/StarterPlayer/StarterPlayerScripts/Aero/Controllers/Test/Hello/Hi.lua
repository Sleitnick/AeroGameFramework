local Hi = {}


function Hi:Multiply(x, y)
	return x * y
end


function Hi:Start()
	print("Hi Start")
	local car = self.Modules.Detroit.Michigan.Car
	local apple = self.Shared.Sharable.Lunch.Apple
	print(car, apple)
end


function Hi:Init()
	print("Hi Init")
end


return Hi