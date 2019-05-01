function MyService:Start()
	-- Connect to 'Hello' event:
	self:ConnectEvent("Hello", function(msg)
		print(msg)
	end)
	-- Fire 'Hello' event:
	self:FireEvent("Hello", "Hello world!")
end

function MyService:Init()
	-- Register 'Hello' event:
	self:RegisterEvent("Hello")
end