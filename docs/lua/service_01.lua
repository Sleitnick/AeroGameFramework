local MyService = {Client = {}}

function MyService:Start()
	-- Called after all services have been initialized
	-- Called asynchronously from other services
	-- Safe to call any other framework modules
end

function MyService:Init()
	-- Called after all modules have been "required" but before 'Start()' has been called on any of them
	-- Safe to reference 'self.Servces/Modules/Shared'
	-- NOT safe to USE/CALL other services yet (use them in/after Start method)
	-- Register all events here (but only connect to events in Start)
end

return MyService