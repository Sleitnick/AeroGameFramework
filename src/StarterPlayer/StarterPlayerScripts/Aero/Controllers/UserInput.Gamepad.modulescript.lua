-- Gamepad
-- Crazyman32
-- December 28, 2017

--[[
	
	gamepad = Gamepad.new(gamepadUserInputType)
	
	Vector3	     gamepad.LeftPosition
	Vector3      gamepad.RightPosition

	Boolean      gamepad:IsConnected()
	InputObject  gamepad:GetState(keyCode)
	Void         gamepad:SetMotor(motor, value)
	Void         gamepad:StopMotor(motor)
	Void         gamepad:StopAllMotors()
	Boolean      gamepad:IsMotorSupported(motor)
	Boolean      gamepad:IsVibrationSupported()
	Float        gamepad:GetMotorValue(motor)
	
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


function Gamepad.new(gamepad)
	
	if (gamepadsByInputType[gamepad]) then
		return gamepadsByInputType[gamepad]
	end
	
	local self = setmetatable({
		_gamepadInput = gamepad;
		_state = {};
		_isConnected = false;
	}, Gamepad)
	
	self.LeftPosition 	= Vector3.new()
	self.RightPosition 	= Vector3.new
	
	self.ButtonDown   = self.Shared.Event.new()
	self.ButtonUp     = self.Shared.Event.new()
	self.Changed      = self.Shared.Event.new()
	self.Connected    = self.Shared.Event.new()
	self.Disconnected = self.Shared.Event.new()
	
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
			self.ButtonDown:Fire(input.KeyCode)
		end
	end)
	
	-- Input Ended:
	self._listeners:Connect(userInput.InputEnded, function(input, processed)
		if (input.UserInputType == self._gamepadInput) then
			self.ButtonUp:Fire(input.KeyCode)
		end
	end)
	
	-- Input Changed:
	self._listeners:Connect(userInput.InputChanged, function(input, processed)
		if (input.UserInputType == self._gamepadInput) then
			self.Changed:Fire(input.KeyCode, input)
			if (input.KeyCode == Enum.KeyCode.Thumbstick1) then
				self.LeftPosition = input.Position
			elseif (input.KeyCode == Enum.KeyCode.Thumbstick2) then
				self.RightPosition = input.Position
			end
		end
	end)
	
end


function Gamepad:DisconnectAll()
	self._listeners:DisconnectAll()
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


function Gamepad:Start()
	
end


function Gamepad:Init()
	
end


return Gamepad
