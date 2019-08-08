function MyController:Start()
	-- Get pints:
	local pointsService = self.Services.PointsService
	local points = pointsService:GetPoints()
	print("Points:", points)
end