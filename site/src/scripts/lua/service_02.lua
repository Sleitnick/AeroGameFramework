-- Custom method:
function MyService:PrintSomething(...)
	print("MyService:", ...)
end

function MyService:Start()
	-- Invoke the custom method:
	self:PrintSomething("Hi", "Hello", 32, true, "ABC")
end