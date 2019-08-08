function MyController:Start()

	local thisThing = {}
	function thisThing:Start()
		print("thisThing started")
	end
	function thisThing:Init()
		print("thisThing initialized")
	end

	-- Transform 'thisThing' into a framework object:
	self:WrapModule(thisThing)

	-- Another example where an external module is loaded:
	local anotherThing = require(someModule)
	self:WrapModule(anotherThing)

end