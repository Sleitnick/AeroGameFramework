-- Event
-- Stephen Leitnick
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
		If an event is no longer being used, be sure to invoke the 'Destroy' method
		to ensure that all events are properly released. Failure to do so could
		result in memory leaks due to connections still being referenced.

	WHY NOT BINDABLE EVENTS:
		This module passes by reference, whereas BindableEvents pass by value.
		In other words, BindableEvents will create a copy of whatever is passed
		rather than the original value itself. This becomes difficult when dealing
		with tables, where passing by reference is usually most ideal.
	
--]]



local ASSERT  = assert
local SELECT  = select
local UNPACK  = unpack
local TYPE    = type


local Event = {}
Event.__index = Event


function Event.new()
	
	local self = setmetatable({
		_connections = {};
		_destroyed = false;
		_firing = false;
		_bindable = Instance.new("BindableEvent");
	}, Event)
	
	return self
	
end


function Event:Fire(...)
	self._args = {...}
	self._numArgs = SELECT("#", ...)
	self._bindable:Fire()
end


function Event:Wait()
	self._bindable.Event:Wait()
	return UNPACK(self._args, 1, self._numArgs)
end


function Event:Connect(func)
	ASSERT(not self._destroyed, "Cannot connect to destroyed event")
	ASSERT(TYPE(func) == "function", "Argument must be function")
	return self._bindable.Event:Connect(function()
		func(UNPACK(self._args, 1, self._numArgs))
	end)
end


function Event:DisconnectAll()
	self._bindable:Destroy()
	self._bindable = Instance.new("BindableEvent")
end


function Event:Destroy()
	if (self._destroyed) then return end
	self._destroyed = true
	self._bindable:Destroy()
end


return Event