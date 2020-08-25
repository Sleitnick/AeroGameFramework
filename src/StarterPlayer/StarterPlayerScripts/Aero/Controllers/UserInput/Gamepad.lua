-- Gamepad
-- Stephen Leitnick
-- December 28, 2017

--[[
	
	gamepad = Gamepad.new(gamepadUserInputType)
	
	Boolean      gamepad:IsDown(keyCode)
	Boolean      gamepad:IsConnected()
	InputObject  gamepad:GetState(keyCode)
	Void         gamepad:SetMotor(motor, value)
	Void         gamepad:StopMotor(motor)
	Void         gamepad:StopAllMotors()
	Boolean      gamepad:IsMotorSupported(motor)
	Boolean      gamepad:IsVibrationSupported()
	Float        gamepad:GetMotorValue(motor)
	Float        gamepad:ApplyDeadzone(value, deadzoneThreshold)
	
	gamepad.ButtonDown(keyCode)
	gamepad.ButtonUp(keyCode)
	gamepad.Changed(keyCode, input)
	gamepad.Connected()
	gamepad.Disconnected()
	
--]]



local Gamepad = {}
Gamepad.__index = Gamepad

local gamepadsByInputType = {}

local userInput = game:GetService("UserInputService")
local hapticService = game:GetService("HapticService")
local abs = math.abs

local InverseLerp


function Gamepad.new(gamepad)
	
	if (gamepadsByInputType[gamepad]) then
		return gamepadsByInputType[gamepad]
	end
	
	local self = setmetatable({
		_gamepadInput = gamepad;
		_state = {};
		_isConnected = false;
	}, Gamepad)
	
	self.ButtonDown   = self.Shared.Signal.new()
	self.ButtonUp     = self.Shared.Signal.new()
	self.Changed      = self.Shared.Signal.new()
	self.Connected    = self.Shared.Signal.new()
	self.Disconnected = self.Shared.Signal.new()
	
	self._listeners = self.Shared.ListenerList.new()
	
	if (userInput:GetGamepadConnected(gamepad)) then
		self._isConnected = true
		self:ConnectAll()
	end
	
	-- Connected:
	userInput.GamepadConnected:Connect(function(gamepadNum)
		if (gamepadNum == gamepad) then
			self._isConnected = true
			self:ConnectAll()
			self.Connected:Fire()
		end
	end)
	
	-- Disconnected:
	userInput.GamepadDisconnected:Connect(function(gamepadNum)
		if (gamepadNum == gamepad) then
			self._isConnected = false
			self:DisconnectAll()
			self.Disconnected:Fire()
		end
	end)
	
	-- Map InputObject states to corresponding KeyCodes:
	for _,input in ipairs(userInput:GetGamepadState(gamepad)) do
		self._state[input.KeyCode] = input
	end
	
	gamepadsByInputType[gamepad] = self
	
	return self
	
end


function Gamepad:ConnectAll()
	
	-- Input Began:
	self._listeners:Connect(userInput.InputBegan, function(input, processed)
		if (processed) then return end
		if (input.UserInputType == self._gamepadInput) then
			self.ButtonDown:Fire(input.KeyCode)
		end
	end)
	
	-- Input Ended:
	self._listeners:Connect(userInput.InputEnded, function(input, _processed)
		if (input.UserInputType == self._gamepadInput) then
			self.ButtonUp:Fire(input.KeyCode)
		end
	end)
	
	-- Input Changed:
	self._listeners:Connect(userInput.InputChanged, function(input, _processed)
		if (input.UserInputType == self._gamepadInput) then
			self.Changed:Fire(input.KeyCode, input)
		end
	end)
	
end


function Gamepad:DisconnectAll()
	self._listeners:DisconnectAll()
end


function Gamepad:IsDown(keyCode)
	return userInput:IsGamepadButtonDown(self._gamepadInput, keyCode)
end


function Gamepad:IsConnected()
	return self._isConnected
end


function Gamepad:GetState(keyCode)
	return self._state[keyCode]
end


function Gamepad:SetMotor(motor, value)
	hapticService:SetMotor(self._gamepadInput, motor, value)
end


function Gamepad:IsMotorSupported(motor)
	return hapticService:IsMotorSupported(self._gamepadInput, motor)
end


function Gamepad:IsVibrationSupported()
	return hapticService:IsVibrationSupported(self._gamepadInput)
end


function Gamepad:StopMotor(motor)
	self:SetMotor(motor, 0)
end


function Gamepad:GetMotorValue(motor)
	return hapticService:GetMotor(self._gamepadInput, motor)
end


function Gamepad:StopAllMotors()
	for _,motor in ipairs(Enum.VibrationMotor:GetEnumItems()) do
		self:StopMotor(motor)
	end
end


function Gamepad:ApplyDeadzone(value, deadzoneThreshold)
	if (abs(value) < deadzoneThreshold) then
		return 0
	else
		return InverseLerp(deadzoneThreshold, 1, abs(value)) * (value > 0 and 1 or -1)
	end
end


function Gamepad:Start()
	
end


function Gamepad:Init()
	InverseLerp = self.Shared.NumberUtil.InverseLerp
end


return Gamepad
