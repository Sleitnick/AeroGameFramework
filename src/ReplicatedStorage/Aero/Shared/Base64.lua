--- Base64
-- Encodes and decodes values to and from Base64
-- @author antifragileer <https://www.roblox.com/users/443282130/profile>
-- @see Developed for the Aero Game Framework <https://github.com/Sleitnick/AeroGameFramework>
-- @see Adapted from https://github.com/toastdriven/lua-base64 for the Roblox game.
-- @see Re-adapted from https://gist.github.com/howmanysmall/016a35f0debcfb81f14e6bee03d450de and https://gist.github.com/Reselim/40d62b17d138cc74335a1b0709e19ce2.
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

local Alphabet = {}
local Indexes = {}

for Index = 65, 90 do table.insert(Alphabet, Index) end -- A-Z
for Index = 97, 122 do table.insert(Alphabet, Index) end -- a-z
for Index = 48, 57 do table.insert(Alphabet, Index) end -- 0-9

table.insert(Alphabet, 43) -- +
table.insert(Alphabet, 47) -- /

for Index, Character in ipairs(Alphabet) do
	Indexes[Character] = Index
end

local Base64 = {
	ClassName = "Base64";
	__tostring = function(self) return self.ClassName end;
}

Base64.__index = Base64

local bit32_rshift = bit32.rshift
local bit32_lshift = bit32.lshift
local bit32_band = bit32.band

function Base64.new()
	return setmetatable({}, Base64)
end

--[[**
	Encodes a string in Base64.
	@param [string] Input The input string to encode.
	@returns [string] The string encoded in Base64.
**--]]
function Base64:Encode(Input)
	local Output = {}
	local Length = 0

	for Index = 1, #Input, 3 do
		local C1, C2, C3 = string.byte(Input, Index, Index + 2)

		local A = bit32_rshift(C1, 2)
		local B = bit32_lshift(bit32_band(C1, 3), 4) + bit32_rshift(C2 or 0, 4)
		local C = bit32_lshift(bit32_band(C2 or 0, 15), 2) + bit32_rshift(C3 or 0, 6)
		local D = bit32_band(C3 or 0, 63)

		Output[Length + 1] = Alphabet[A + 1]
		Output[Length + 2] = Alphabet[B + 1]
		Output[Length + 3] = C2 and Alphabet[C + 1] or 61
		Output[Length + 4] = C3 and Alphabet[D + 1] or 61
		Length = Length + 4
	end

	local NewOutput = {}
	local NewLength = 0

	for Index = 1, Length, 4096 do
		NewLength = NewLength + 1
		NewOutput[NewLength] = string.char(table.unpack(Output, Index, math.min(Index + 4096 - 1, Length)))
	end

	return table.concat(NewOutput)
end

--[[**
	Decodes a string from Base64.
	@param [string] Input The input string to decode.
	@returns [string] The newly decoded string.
**--]]
function Base64:Decode(Input)
	local Output = {}
	local Length = 0

	for Index = 1, #Input, 4 do
		local C1, C2, C3, C4 = string.byte(Input, Index, Index + 3)

		local I1 = Indexes[C1] - 1
		local I2 = Indexes[C2] - 1
		local I3 = (Indexes[C3] or 1) - 1
		local I4 = (Indexes[C4] or 1) - 1

		local A = bit32_lshift(I1, 2) + bit32_rshift(I2, 4)
		local B = bit32_lshift(bit32_band(I2, 15), 4) + bit32_rshift(I3, 2)
		local C = bit32_lshift(bit32_band(I3, 3), 6) + I4

		Length = Length + 1
		Output[Length] = A
		if C3 ~= 61 then Length = Length + 1 Output[Length] = B end
		if C4 ~= 61 then Length = Length + 1 Output[Length] = C end
	end

	local NewOutput = {}
	local NewLength = 0

	for Index = 1, Length, 4096 do
		NewLength = NewLength + 1
		NewOutput[NewLength] = string.char(table.unpack(Output, Index, math.min(Index + 4096 - 1, Length)))
	end

	return table.concat(NewOutput)
end

return Base64
