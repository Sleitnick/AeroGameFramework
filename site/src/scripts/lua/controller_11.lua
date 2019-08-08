function MyController:Start()
	local dataService = self.Services.DataService
	dataService.Failed:Connect(function(method, key, errorMessage)
		warn("DataService failed:", method, key, errorMessage)
	end)
end