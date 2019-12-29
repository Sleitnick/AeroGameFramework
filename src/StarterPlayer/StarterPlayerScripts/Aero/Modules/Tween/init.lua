-- Tween
-- Stephen Leitnick
-- June 21, 2017

--[[
	
	Native:
		
		tween = Tween.FromService(instance, tweenInfo, properties)
		
		See Wiki page on Tween object for methods and such
		
		
	Custom:
	
		tween = Tween.new(tweenInfo, callbackFunction)
		
		tween.TweenInfo
		tween.Callback
		tween.PlaybackState
		
		tween:Play()
		tween:Pause()
		tween:Cancel()
		
		tween.Completed(playbackState)
		tween.PlaybackStateChanged(playbackState)
	
	
	Custom Example:
	
		tween = Tween.new(TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true, 0), function(n)
			print(n)
		end)
		
		tween:Play()
		tween.Completed:Wait()
	
--]]



local Tween = {}
Tween.__index = Tween


Tween.Easing = require(script:WaitForChild("Easing"))


function Tween.new(tweenInfo, callback)
	
	do
		-- Verify callback is function:
		assert(typeof(callback) == "function", "Callback argument must be a function")
		
		-- Verify tweenInfo:
		local typeOfTweenInfo = typeof(tweenInfo)
		assert(typeOfTweenInfo == "TweenInfo" or typeOfTweenInfo == "table", "TweenInfo must be of type TweenInfo or table")
		
		-- Defaults:
		if (typeOfTweenInfo == "table") then
			if (tweenInfo.Time == nil) then tweenInfo.Time = 1 end
			if (tweenInfo.EasingStyle == nil) then tweenInfo.EasingStyle = Enum.EasingStyle.Quad end
			if (tweenInfo.EasingDirection == nil) then tweenInfo.EasingDirection = Enum.EasingDirection.Out end
			if (tweenInfo.RepeatCount == nil) then tweenInfo.RepeatCount = 0 end
			if (tweenInfo.Reverses == nil) then tweenInfo.Reverses = false end
			if (tweenInfo.DelayTime == nil) then tweenInfo.DelayTime = 0 end
		end
		
	end
	
	local completed = Instance.new("BindableEvent")
	local playbackStateChanged = Instance.new("BindableEvent")
	
	local self = setmetatable({
		
		TweenInfo = tweenInfo;
		Callback = callback;
		PlaybackState = Enum.PlaybackState.Begin;
		Completed = completed.Event;
		PlaybackStateChanged = playbackStateChanged.Event;
		
		_id = "tween_" .. game:GetService("HttpService"):GenerateGUID(false);
		_playing = false;
		_paused = false;
		_completed = completed;
		_playbackStateChanged = playbackStateChanged;
		_elapsedTime = 0;
		_repeated = 0;
		_reversing = false;
		_elapsedDelayTime = 0;
		
	}, Tween)
	
	return self
	
end


function Tween:ResetState()
	self._playing = false
	self._paused = false
	self._elapsedTime = 0
	self._repeated = 0
	self._reversing = false
	self._elapsedDelayTime = 0
end


function Tween:SetPlaybackState(state)
	local lastState = self.PlaybackState
	self.PlaybackState = state
	if (state ~= lastState) then
		self._playbackStateChanged:Fire(state)
	end
end


function Tween:Play()
	
	if (self._playing and not self._paused) then return end
	self._playing = true
	self._paused = false
	
	-- Resolve easing function:
	local easingFunc
	if (typeof(self.TweenInfo) == "TweenInfo") then
		easingFunc = Tween.Easing[self.TweenInfo.EasingDirection.Name][self.TweenInfo.EasingStyle.Name]
	else
		local dir, style
		dir = typeof(self.TweenInfo.EasingDirection) == "EnumItem" and self.TweenInfo.EasingDirection.Name or self.TweenInfo.EasingDirection
		style = typeof(self.TweenInfo.EasingStyle) == "EnumItem" and self.TweenInfo.EasingStyle.Name or self.TweenInfo.EasingStyle
		easingFunc = Tween.Easing[dir][style]
		if (not self.TweenInfo.RepeatCount) then
			self.TweenInfo.RepeatCount = 0
		end
	end
	
	local tick = tick
	
	local elapsed = self._elapsedTime
	local duration = self.TweenInfo.Time
	local last = tick()
	local callback = self.Callback
	local reverses = self.TweenInfo.Reverses
	
	local elapsedDelay = self._elapsedDelayTime
	local durationDelay = self.TweenInfo.DelayTime
	
	local reversing = self._reversing
	
	local function OnCompleted()
		callback(easingFunc(duration, 0, 1, duration))
		game:GetService("RunService"):UnbindFromRenderStep(self._id)
		self.PlaybackState = Enum.PlaybackState.Completed
		self._completed:Fire(self.PlaybackState)
		self:ResetState()
	end
	
	local function IsDelayed(dt)
		if (elapsedDelay >= durationDelay) then return false end
		elapsedDelay = (elapsedDelay + dt)
		self._elapsedDelayTime = elapsedDelay
		if (elapsedDelay < durationDelay) then
			self:SetPlaybackState(Enum.PlaybackState.Delayed)
		else
			self:SetPlaybackState(Enum.PlaybackState.Playing)
		end
		return (elapsedDelay < durationDelay)
	end
	
	-- Tween:
	game:GetService("RunService"):BindToRenderStep(self._id, Enum.RenderPriority.Camera.Value - 1, function()
		local now = tick()
		local dt = (now - last)
		last = now
		if (IsDelayed(dt)) then return end
		elapsed = (elapsed + dt)
		self._elapsedTime = elapsed
		local notDone = (elapsed < duration)
		if (notDone) then
			if (reversing) then
				callback(easingFunc(elapsed, 1, -1, duration))
			else
				callback(easingFunc(elapsed, 0, 1, duration))
			end
		else
			if ((self._repeated < self.TweenInfo.RepeatCount) or reversing) then
				if (reverses) then
					reversing = (not reversing)
					self._reversing = reversing
				end
				if ((not reverses) or (reversing)) then
					self._repeated = (self._repeated + 1)
				end
				if (not reversing) then
					self._elapsedDelayTime = 0
					elapsedDelay = 0
				end
				self._elapsedTime = 0
				elapsed = 0
			else
				OnCompleted()
			end
		end
	end)
	
end


function Tween:Pause()
	if ((not self._playing) or (self._paused)) then return end
	self._paused = true
	self:SetPlaybackState(Enum.PlaybackState.Paused)
	game:GetService("RunService"):UnbindFromRenderStep(self._id)
end


function Tween:Cancel()
	if (not self._playing) then return end
	game:GetService("RunService"):UnbindFromRenderStep(self._id)
	self:ResetState()
	self:SetPlaybackState(Enum.PlaybackState.Cancelled)
	self._completed:Fire(self.PlaybackState)
end


function Tween.fromService(...)
	return game:GetService("TweenService"):Create(...)
end


Tween.FromService = Tween.fromService
Tween.New = Tween.new


return Tween