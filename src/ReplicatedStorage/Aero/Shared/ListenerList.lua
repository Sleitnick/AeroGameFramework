-- Listener List
-- Stephen Leitnick
-- November 1, 2015

--[[
	
	local listeners = ListenerList.new()
	
	listeners:Connect(event, func)
	listeners:BindToRenderStep(name, priority, func)
	listeners:BindAction(actionName, funcToBind, createTouchBtn [, inputTypes...])
	listeners:BindActionAtPriority(actionName, funcToBind, createTouchBtn, priorityLevel [, inputTypes...])

	listeners:DisconnectAll()
	listeners:DisconnectEvents()
	listeners:DisconnectRenderSteps()
	listeners:DisconnectActions()

	listeners:Destroy()
		> Alias for DisconnectAll
	
--]]



local ListenerList = {}
ListenerList.__index = ListenerList


function ListenerList.new()
	local self = setmetatable({
		_listeners = {};
		_renderStepNames = {};
		_actionNames = {};
	}, ListenerList)
	return self
end


-- Connect a function to an event and store it in the list:
function ListenerList:Connect(event, func)
	local listener = event:Connect(func)
	table.insert(self._listeners, listener)
	return listener
end


function ListenerList:BindToRenderStep(name, ...)
	table.insert(self._renderStepNames, name)
	game:GetService("RunService"):BindToRenderStep(name, ...)
end


function ListenerList:BindAction(name, ...)
	table.insert(self._actionNames, name)
	game:GetService("ContextActionService"):BindAction(name, ...)
end


function ListenerList:BindActionAtPriority(name, ...)
	table.insert(self._actionNames, name)
	game:GetService("ContextActionService"):BindActionAtPriority(name, ...)
end


function ListenerList:DisconnectEvents()
	for _,l in ipairs(self._listeners) do
		if (l.Connected) then
			l:Disconnect()
		end
	end
	self._listeners = {}
end


function ListenerList:DisconnectRenderSteps()
	local runService = game:GetService("RunService")
	for _,n in ipairs(self._renderStepNames) do
		runService:UnbindFromRenderStep(n)
	end
	self._renderStepNames = {}
end


function ListenerList:DisconnectActions()
	local ctxService = game:GetService("ContextActionService")
	for _,n in ipairs(self._actionNames) do
		ctxService:UnbindAction(n)
	end
	self._actionNames = {}
end


-- Disconnect all events in the list and clear the list:
function ListenerList:DisconnectAll()
	self:DisconnectEvents()
	self:DisconnectRenderSteps()
	self:DisconnectActions()
end


ListenerList.Destroy = ListenerList.DisconnectAll


return ListenerList