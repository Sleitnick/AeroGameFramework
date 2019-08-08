-- Custom method:
function MyController:PrintSomething(...)
	print("MyController:", ...)
end

function MyController:Start()
	-- Invoke the custom method:
	self:PrintSomething("Hi", "Hello", 32, true, "ABC")
end