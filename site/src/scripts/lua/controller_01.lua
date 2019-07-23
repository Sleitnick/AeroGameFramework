local MyController = {}

function MyController:Start()
	-- Called after all controllers have been initialized
	-- Called asynchronously from other controllers
	-- Safe to call any other framework modules
end

function MyController:Init()
	-- Called after all modules have been "required" but before 'Start()' has been called on any of them
	-- Safe to reference 'self.Services/Controllers/Modules/Shared'
	-- NOT safe to USE/CALL other services yet (use them in/after Start method)
	-- Register all events here (but only connect to events in Start)
end

return MyController