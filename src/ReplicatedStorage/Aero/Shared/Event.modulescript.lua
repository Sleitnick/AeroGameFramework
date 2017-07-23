-- Event
-- Crazyman32
-- March 17, 2017

--[[
	
	event = Event.new()
	
	
	event:Fire(...)
	event:Wait()
	event:DisconnectAll()
	
	connection = event:Connect(func)
		connection.Connected
		connection:Disconnect()
	
	event:Destroy()
	
--]]



local CO_WRAP = coroutine.wrap


local Event = {}
Event.__index = Event

local Connection = {}
Connection.__index = Connection


function Event.new()
	
	local self = setmetatable({
		_connections = {};
		_destroyed = false;
	}, Event)
	
	return self
	
end


function Event:Fire(...)
	local connections = self._connections
	for i = 1,#connections do
		local f = connections[i]._func
		CO_WRAP(f)(...)
	end
end


function Event:Wait()
	local c, returnArgs = nil, nil
	c = self:Connect(function(...)
		c:Disconnect()
		returnArgs = {...}
	end)
	while (not returnArgs) do wait() end
	return unpack(returnArgs)
end


function Event:Connect(func)
	assert(not self._destroyed, "Cannot connect to destroyed event")
	assert(type(func) == "function", "Argument must be function")
	local connection = Connection.new(func, self)
	table.insert(self._connections, connection)
	return connection
end


function Event:DisconnectAll()
	for _,c in pairs(self._connections) do
		c.IsConnected = false
	end
	self._connections = {}
end


function Event:Disconnect(connection)
	for i,c in pairs(self._connections) do
		if (c == connection) then
			table.remove(self._connections, i)
			break
		end
	end
end


function Event:Destroy()
	if (self._destroyed) then return end
	self._destroyed = true
	self:DisconnectAll()
end


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


return Event