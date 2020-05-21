-- Author: EchoReaper
-- Roblox Link: https://www.roblox.com/Task-Scheduler-item?id=348019935
-- Publically released January 25, 2016

-- Changes made from EchoReaper's version:
	-- GetCurrentFPS() method removed
	-- FPS is only tracked when the 'Loop' function is running for performance reasons
	-- Styled code in consistency with the rest of the AeroGameFramework codebase

--[[
	
	local scheduler = TaskScheduler:CreateScheduler(targetedMinimumFPS)
	
	scheduler:QueueTask(function)
	scheduler:Pause()
	scheduler:Resume()
	scheduler:Destroy()
	
--]]




local TaskScheduler = {}

local lastIteration
local frameUpdateTable = {}

local runService = game:GetService("RunService")

--[[
	param targetFps  Task scheduler won't run a task if it'd make the FPS drop below this amount
					 (WARNING) this only holds true if it is used properly. If you try to complete 10 union operations
					 at once in a single task then of course your FPS is going to drop -- queue the union operations
					 up one at a time so the task scheduler can do its job.
					
					
	returns scheduler
		method Pause      Pauses the scheduler so it won't run tasks. Tasks may still be added while the scheduler is
						  paused. They just won't be touched until it's resumed. Performance efficient -- disables
						  execution loop entirely until scheduler is resumed.
		
		method Resume     Resumes the paused scheduler.
		
		method Destroy    Destroys the scheduler so it can't be used anymore.
		
		method QueueTask  Queues a task for automatic execution.
			param callback  function (task) to be run.
	
	Example usage:
	
	local scheduler = TaskScheduler:CreateScheduler(60)
	local totalOperations = 0
	local paused
	for i=1,100 do
		scheduler:QueueTask(function()
			local partA = Instance.new("Part", workspace)
			local partB = Instance.new("Part", workspace)
			plugin:Union({partA, partB}):Destroy()
			totalOperations = totalOperations + 1
			print("Times unioned:", totalOperations)
			if (totalOperations == 50) then
				scheduler:Pause()
				paused = true
			end
		end)
	end
	
	repeat wait() until paused
	wait(2)
	scheduler:Resume()
--]]


function TaskScheduler:CreateScheduler(targetFps)
	
	local scheduler = {}
	local queue = {}
	local sleeping = true
	local paused
	
	local updateFrameTableEvent = nil
	
	local start = tick()
	runService.RenderStepped:Wait()
	
	local function UpdateFrameTable()
		lastIteration = tick()
		for i = #frameUpdateTable,1,-1 do
			frameUpdateTable[i + 1] = ((frameUpdateTable[i] >= (lastIteration - 1)) and frameUpdateTable[i] or nil)
		end
		frameUpdateTable[1] = lastIteration
	end

	local function Loop()
		updateFrameTableEvent = runService.RenderStepped:Connect(UpdateFrameTable)
		while (true) do
			if (sleeping) then break end
			local fps = (((tick() - start) >= 1 and #frameUpdateTable) or (#frameUpdateTable / (tick() - start)))
			if (fps >= targetFps and (tick() - frameUpdateTable[1]) < (1 / targetFps)) then
				if (#queue > 0) then
					queue[1]()
					table.remove(queue, 1)
				else
					sleeping = true
					break
				end
			else
				runService.RenderStepped:Wait()
			end
		end
		updateFrameTableEvent:Disconnect()
		updateFrameTableEvent = nil
	end

	function scheduler.Pause(_s)
		paused = true
		sleeping = true
	end
	
	function scheduler.Resume(_s)
		if (paused) then
			paused = false
			sleeping = false
			Loop()
		end
	end
	
	function scheduler.Destroy(_s)
		scheduler:Pause()
		for i in pairs(scheduler) do
			scheduler[i] = nil
		end
		setmetatable(scheduler, {
			__index = function()
				error("Attempt to use destroyed scheduler")
			end;
			__newindex = function()
				error("Attempt to use destroyed scheduler")
			end;
		})
	end
	
	function scheduler.QueueTask(_s, callback)
		queue[#queue + 1] = callback
		if (sleeping and not paused) then
			sleeping = false
			Loop()
		end
	end
	
	return scheduler
	
end


return TaskScheduler