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
local BLANK_FUNC = function() end


local Event = {}
Event.__index = Event

local Connection = {}
Connection.__index = Connection


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
		local f = connections[i]._func
		CO_WRAP(f)(...)
	end
	self._firing = false
end


function Event:Wait()
	local c, returnArgs = nil, nil
	local be = Instance.new("BindableEvent")
	c = self:Connect(function(...)
		c:Disconnect()
		returnArgs = {...}
		be:Fire()
	end)
	be.Event:Wait()
	be:Destroy()
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
		spawn(function()
			DisconnectAll()
		end)
	else
		DisconnectAll()
	end
end


function Event:Disconnect(connection)
	local function Disconnect()
		for i,c in pairs(self._connections) do
			if (c == connection) then
				table.remove(self._connections, i)
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