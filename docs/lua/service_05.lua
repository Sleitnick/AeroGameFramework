function MyService:Start()

	local thisThing = {}

	function thisThing:Start()
		print("thisThing started")
	end

	function thisThing:Init()
		print("thisThing initialized")
	end

	-- Transform 'thisThing' into a framework object:
	self:WrapModule(thisThing)

end