function MyService:Start()
	-- Get some global data from the DataService:
	local dataService = self.Services.DataService
	local data = dataService:GetGlobal("Test")
end