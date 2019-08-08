function MyController:Start()
	-- Connect to 'Hello' event:
	self.Hello:Connect(function(msg)
		print(msg)
	end)
	-- Fire 'Hello' event:
	self.Hello:Fire("Hello world!")
end

function MyController:Init()
	-- Create 'Hello' event:
	self.Hello = self.Shared.Event.new()
end