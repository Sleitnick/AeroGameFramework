function MyService:Start()
	-- Print the current date:
	local Date = self.Shared.Date
	local now = Date.new()
	print("Now", now)
end