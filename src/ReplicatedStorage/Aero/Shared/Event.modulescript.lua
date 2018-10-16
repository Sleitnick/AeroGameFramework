-- Event
-- Crazyman32
-- March 17, 2017

--[[
	
	event = Event.new()
	
	event:Fire(...)
	event:Wait()
	event:Connect(functionHandler)
	event:DisconnectAll()
	event:Destroy()
	
	
	Using 'Connect':

		connection = event:Connect(func)
			connection.Connected
			connection:Disconnect()
	

	-----------------------------------------------------------------------------

	NOTE ON MEMORY LEAK PREVENTION:
		Invoking 'Destroy' on an event will call 'DisconnectAll' and will prevent
		further connections of functions. Use this if the event object is no
		longer being used. Failure to call 'Destroy' when the event is no longer
		in use could result in memory leaks due to connections still being
		referenced. Trying to connect a function to a destroyed event will throw
		an error.
	
--]]



local CO_WRAP    = coroutine.wrap
local CO_RUNNING = coroutine.running
local CO_YIELD   = coroutine.yield
local CO_RESUME  = coroutine.resume
local BLANK_FUNC = function() end


local Event = {}
Event.__index = Event

local Connection = {}
Connection.__index = Connection


------------------------------------------------------------------
-- Event


function Event.new()
	
	local self = setmetatable({
		_connections = {};
		_destroyed = false;
		_firing = false;
	}, Event)
	
	return self
	
end


function Event:Fire(...)
	self._firing = true
	local connections = self._connections
	for i = 1,#connections do
		CO_WRAP(connections[i]._func)(...)
	end
	self._firing = false
end


function Event:Wait()
	local thread = CO_RUNNING()
	local connection
	connection = self:Connect(function(...)
		connection:Disconnect()
		CO_RESUME(thread, ...)
	end)
	return CO_YIELD()
end


function Event:Connect(func)
	assert(not self._destroyed, "Cannot connect to destroyed event")
	assert(type(func) == "function", "Argument must be function")
	local connection = Connection.new(func, self)
	table.insert(self._connections, connection)
	return connection
end


function Event:DisconnectAll()
	local function DisconnectAll()
		for _,c in pairs(self._connections) do
			c.IsConnected = false
		end
		self._connections = {}
	end
	if (self._firing) then
		for _,c in pairs(self._connections) do
			c._func = BLANK_FUNC
		end
		spawn(DisconnectAll)
	else
		DisconnectAll()
	end
end


function Event:Disconnect(connection)
	local function Disconnect()
		local connections = self._connections
		local numConnections = #connections
		for i = 1,numConnections do
			local c = connections[i]
			if (c == connection) then
				connections[i] = connections[numConnections]
				connections[numConnections] = nil
				break
			end
		end
	end
	if (self._firing) then		
		connection._func = BLANK_FUNC
		spawn(Disconnect)
	else
		Disconnect()
	end
end


function Event:Destroy()
	if (self._destroyed) then return end
	self._destroyed = true
	self:DisconnectAll()
end


------------------------------------------------------------------
-- Connection


function Connection.new(func, event)
	local self = setmetatable({
		Connected = true;
		_func = func;
		_event = event;
	}, Connection)
	return self
end


function Connection:Disconnect()
	if (not self.Connected) then return end
	self.Connected = false
	self._event:Disconnect(self)
end


------------------------------------------------------------------


return Event