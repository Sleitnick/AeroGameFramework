-- Gamepad
-- Crazyman32
-- December 28, 2017

--[[
	
	gamepad = Gamepad.new(gamepadUserInputType)
	
	Methods:
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
	
	
	Events:
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


function Gamepad.new(gamepad)
	
	if (gamepadsByInputType[gamepad]) then
		return gamepadsByInputType[gamepad]
	end
	
	local self = setmetatable({
		_gamepadInput = gamepad;
		_state = {};
		_isConnected = false;
	}, Gamepad)
	
	self:RegisterEvent('ButtonDown')
	self:RegisterEvent('ButtonUp')
	self:RegisterEvent('Changed')
	self:RegisterEvent('Connected')
	self:RegisterEvent('Disconnected')
	
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
			self:FireEvent('Connected')
		end
	end)
	
	-- Disconnected:
	userInput.GamepadDisconnected:Connect(function(gamepadNum)
		if (gamepadNum == gamepad) then
			self._isConnected = false
			self:DisconnectAll()
			self:FireEvent('Disconnected')
		end
	end)
	
	-- Map InputObject states to corresponding KeyCodes:
	for _,input in pairs(userInput:GetGamepadState(gamepad)) do
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
			self:FireEvent('ButtonDown', input.KeyCode)
		end
	end)
	
	-- Input Ended:
	self._listeners:Connect(userInput.InputEnded, function(input, processed)
		if (input.UserInputType == self._gamepadInput) then
			self:FireEvent('ButtonUp', input.KeyCode)
		end
	end)
	
	-- Input Changed:
	self._listeners:Connect(userInput.InputChanged, function(input, processed)
		if (input.UserInputType == self._gamepadInput) then
			self:FireEvent('Changed', input.KeyCode, input)
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
	for _,motor in pairs(Enum.VibrationMotor:GetEnumItems()) do
		self:StopMotor(motor)
	end
end


function Gamepad:ApplyDeadzone(value, deadzoneThreshold)
	if (abs(value) < deadzoneThreshold) then
		return 0
	elseif (value > 0) then
		return ((value - deadzoneThreshold) / (1 - deadzoneThreshold))
	else
		return ((value + deadzoneThreshold) / (1 - deadzoneThreshold))
	end
end


return Gamepad
