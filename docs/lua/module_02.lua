local MyModule = {}

-- Prevent the framework from invoking the 'Start' method:
MyModule.__aeroPreventStart = true

function MyModule:Start()
	-- Won't be invoked by the framework
end

function MyModule:Init()
	-- Still will be invoked by the framework
end

return MyModule