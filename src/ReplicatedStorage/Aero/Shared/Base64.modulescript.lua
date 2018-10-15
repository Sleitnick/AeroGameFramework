--- Base64
-- Encodes and decodes values to and from Base64
-- @author antifragileer <https://www.roblox.com/users/443282130/profile>
-- @see Developed for the Aero Game Framework <https://github.com/Sleitnick/AeroGameFramework>
-- @see Adapted from https://github.com/toastdriven/lua-base64 for the Roblox game.
-- @license BSD
-- July 15, 2018

--[[
	
	local base64 = Base64.new()
	
	Example:
	
	local myEncodedWord = base64:Encode("Hello")
	
	print(myEncodedWord)
	
	-- outputs: SGVsbG8=
	
	print(base64:Decode(myEncodedWord))
	
	-- outputs: Hello

--]]


local Base64 = {}
Base64.__index = Base64

local sub = string.sub
local byte = string.byte
local char = string.char
local gsub = string.gsub
local find = string.find

--- Object constructor
-- @return Base64
function Base64.new()
	
	local self = setmetatable({
		IndexTable = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
	}, Base64)
	
	return self
	
end 

--- Converts an integer to binary
-- @private
-- @param number Integer
-- @return string
function Base64:__BinaryEncode(Integer)
	
	local Remaining = tonumber(Integer)
	local BinaryBits = ''

	for i = 7, 0, -1 do
		local CurrentPower = 2 ^ i

		if Remaining >= CurrentPower then
			BinaryBits = BinaryBits .. '1'
			Remaining = Remaining - CurrentPower
		else
			BinaryBits = BinaryBits .. '0'
		end
	end

	return BinaryBits
	
end

--- Converts a binary bit to a number
-- @private
-- @param string BinaryBits
-- @return number
function Base64:__BinaryDecode(BinaryBits)
	
	return tonumber(BinaryBits, 2)
	
end

--- Converts a string or number to a Base64 value
-- @public
-- @param string|number Value
-- @return string
function Base64:Encode(Value)

	local BitPattern = ''
	local Encoded = ''
	local Trailing = ''

	for i = 1, #Value do
		BitPattern = BitPattern .. self:__BinaryEncode(byte(sub(Value, i, i)))
	end

	-- Check the number of bytes. If it's not evenly divisible by three,
	-- zero-pad the ending & append on the correct number of ``=``s.
	if #BitPattern % 3 == 2 then
		Trailing = '=='
		BitPattern = BitPattern .. '0000000000000000'
	elseif #BitPattern % 3 == 1 then
		Trailing = '='
		BitPattern = BitPattern .. '00000000'
	end

	for i = 1, #BitPattern, 6 do
		local Byte = sub(BitPattern, i, i+5)
		local Offset = tonumber(self:__BinaryDecode(Byte))
		
		Encoded = Encoded .. sub(self.IndexTable, Offset+1, Offset+1)
	end

	return sub(Encoded, 1, -1 - #Trailing) .. Trailing

end

--- Converts a Base64 encoded string to its original value
-- @public
-- @param string Value
-- @return string
function Base64:Decode(Value)
	
	local Padded = gsub(Value, "%s", "")
	local Unpadded = gsub(Padded, "=", "")
	local BitPattern = ''
	local Decoded = ''

	for i = 1, #Unpadded do
		local Char = sub(Value, i, i)
		local Offset, _ = find(self.IndexTable, Char)

		if Offset == nil then
			error("Invalid character \"" .. Char .. "\" found.")
		end

		BitPattern = BitPattern .. sub(self:__BinaryEncode(Offset-1), 3)
	end

	for i = 1, #BitPattern, 8 do
		local Byte = sub(BitPattern, i, i+7)

		Decoded = Decoded .. char(self:__BinaryDecode(Byte))
	end

	local PaddingLength = #Padded-#Unpadded

	if (PaddingLength == 1 or PaddingLength == 2) then
		Decoded = sub(Decoded, 1,-2)
	end

	return Decoded

end


return Base64
