--[[
	
	MIT License
	
	Copyright (c) 2018 Validark
	
	Permission is hereby granted, free of charge, to any person obtaining
	a copy of this software and associated documentation files (the "Software"),
	to deal in the Software without restriction, including without limitation
	the rights to use, copy, modify, merge, publish, distribute, sublicense,
	and/or sell copies of the Software, and to permit persons to whom the
	Software is furnished to do so, subject to the following conditions:
	
	The above copyright notice and this permission notice shall be included in
	all copies or substantial portions of the Software.
	
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

	--]]
	
-- FastSpawn
-- Validark
-- Original source: https://github.com/RoStrap/Helper/blob/master/FastSpawn.lua

-- An expensive way to spawn a function. However, unlike spawn(), it executes on the same frame, and
-- unlike coroutines, does not obscure errors

local Instance_new = Instance.new

local function FastSpawn(Function, ...)
	local BindableEvent = Instance_new("BindableEvent")
	if ... ~= nil then
		local Arguments = {...}
		BindableEvent.Event:Connect(function()
			Function(unpack(Arguments))
		end)
	else
		BindableEvent:Connect(Function)
	end
	
	BindableEvent:Fire()
	BindableEvent:Destroy()
end

return FastSpawn
