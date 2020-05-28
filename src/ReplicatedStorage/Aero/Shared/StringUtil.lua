-- String Util
-- Stephen Leitnick
-- December 3, 2019

--[[

	StringUtil.Trim(String str)
	StringUtil.TrimStart(String str)
	StringUtil.TrimEnd(String str)
	StringUtil.EqualsIgnoreCase(String str, String compare)
	StringUtil.RemoveWhitespace(String str)
	StringUtil.RemoveExcessWhitespace(String str)
	StringUtil.EndsWith(String str, String endsWith)
	StringUtil.StartsWith(String str, String startsWith)
	StringUtil.Contains(String str, String contains)
	StringUtil.ToCharArray(String str)
	StringUtil.ToByteArray(String str)
	StringUtil.ByteArrayToString(Table bytes)
	StringUtil.ToCamelCase(String str)
	StringUtil.ToPascalCase(String str)
	StringUtil.ToSnakeCase(String str [, uppercase])
	StringUtil.ToKebabCase(String str [, uppercase])
	StringUtil.Escape(str)
	StringUtil.StringBuilder()

	EXAMPLES:

		Trim:

			Trims whitespace from the start and end of the string.

			StringUtil.Trim("  hello world  ") == "hello world"


		TrimStart:

			The same as Trim, but only trims the start of the string.

			StringUtil.TrimStart("  hello world  ") == "hello world  "


		TrimEnd:

			The same as Trim, but only trims the end of the string.

			StringUtil.TrimEnd("  hello world  ") == "  hello world"


		EqualsIgnoreCase:

			Checks if two strings are equal, but ignores their case.

			StringUtil.EqualsIgnoreCase("HELLo woRLD", "hEllo wORLd") == true


		RemoveWhitespace:

			Removes all whitespace from a string.

			StringUtil.RemoveWhitespace("  hello World!\n") == "helloWorld!"


		RemoveExcessWhitespace:

			Replaces all whitespace with a single space. This does not trim the string.

			StringUtil.RemoveExcessWhitespace("This     is    a   \n  test") == "This is a test"


		EndsWith:

			Checks if a string ends with a certain string.

			StringUtil.EndsWith("Hello world", "rld") == true


		StartsWith:

			Checks if a string starts with a certain string.

			StringUtil.StartsWith("Hello world", "He") == true


		Contains:

			Checks if a string contains another string.

			StringUtil.Contains("Hello world", "lo wor") == true


		ToCharArray:

			Returns a table of all the characters in the string.

			StringUtil.ToCharArray("Hello") >>> {"H","e","l","l","o"}


		ToByteArray:

			Returns a table of all the bytes of each character in the string.

			StringUtil.ToByteArray("Hello") >>> {72,101,108,108,111}


		ByteArrayToString:

			Transforms an array of bytes into a string.

			StringUtil.ByteArrayToString({97, 98, 99}) == "abc"


		ToCamelCase:

			Returns a string in camelCase.

			StringUtil.ToCamelCase("Hello_world-abc") == "helloWorldAbc"


		ToPascalCase:

			Returns a string in PascalCase.

			StringUtil.ToPascalCase("Hello_world-abc") == "HelloWorldAbc"


		ToSnakeCase:

			Returns a string in snake_case or SNAKE_CASE.

			StringUtil.ToPascalCase("Hello_world-abc") == "hello_world_abc"
			StringUtil.ToPascalCase("Hello_world-abc", true) == "HELLO_WORLD_ABC"


		ToKebabCase:

			Returns a string in kebab-case or KEBAB-CASE.

			StringUtil.ToKebabCase("Hello_world-abc") == "hello-world-abc"
			StringUtil.ToKebabCase("Hello_world-abc", true) == "HELLO-WORLD-ABC"


		Escape:

			Escapes a string from pattern characters. In other words, it prefixes
			any special pattern characters with a %. For example, the dollar
			sign $ would become %$. See the example below.

			StringUtil.Escape("Hello. World$ ^-^") == "Hello%. World%$ %^%-%^"


		StringBuilder:

			Creates a StringBuilder object that can be used to build a string. This
			is useful when a large string needs to be concatenated. Traditional
			concatenation of a string using ".." can be a performance issue, and thus
			StringBuilders can be used to store the pieces of the string in a table
			and then concatenate them all at once.

			local builder = StringUtil.StringBuilder()

			builder:Append("world")
			builder:Prepend("Hello ")
			builder:ToString() == "Hello world"
			tostring(builder)  == "Hello world"

--]]


local StringUtil = {}

local MAX_TUPLE = 7997


function StringUtil.Escape(str)
	local escaped = string.gsub(str, "([%.%$%^%(%)%[%]%+%-%*%?%%])", "%%%1")
	return escaped
end


function StringUtil.Trim(str)
	return string.match(str, "^%s*(.-)%s*$")
end


function StringUtil.TrimStart(str)
	return string.match(str, "^%s*(.+)")
end


function StringUtil.TrimEnd(str)
	return string.match(str, "(.-)%s*$")
end


function StringUtil.RemoveExcessWhitespace(str)
	return string.gsub(str, "%s+", " ")
end


function StringUtil.RemoveWhitespace(str)
	return string.gsub(str, "%s+", "")
end


function StringUtil.EndsWith(str, ends)
	return string.match(str, StringUtil.Escape(ends) .. "$") ~= nil
end


function StringUtil.StartsWith(str, starts)
	return string.match(str, "^" .. StringUtil.Escape(starts)) ~= nil
end


function StringUtil.Contains(str, contains)
	return string.find(str, contains) ~= nil
end


function StringUtil.StringBuilder()
	local sb = {}
	local str = {}
	function sb.Append(_, s)
		str[#str + 1] = s
	end
	function sb.Prepend(_, s)
		table.insert(str, 1, s)
	end
	function sb.ToString()
		return table.concat(str, "")
	end
	setmetatable(sb, {__tostring = sb.ToString})
	return sb
end


function StringUtil.ToCharArray(str)
	local len = #str
	local chars = table.create(len)
	for i = 1,len do
		chars[i] = string.sub(str, i, i)
	end
	return chars
end


function StringUtil.ToByteArray(str)
	local len = #str
	if (len == 0) then
		return {}
	end
	if (len <= MAX_TUPLE) then
		return table.pack(string.byte(str, 1, #str))
	end
	local bytes = table.create(len)
	for i = 1, len do
		bytes[i] = string.byte(str, i, i)
	end
	return bytes
end


function StringUtil.ByteArrayToString(bytes)
	local size = #bytes
	if (size <= MAX_TUPLE) then
		return string.char(table.unpack(bytes))
	end
	local numChunks = math.ceil(size / MAX_TUPLE)
	local stringBuild = table.create(numChunks)
	for i = 1, numChunks do
		local chunk = string.char(table.unpack(bytes, ((i - 1) * MAX_TUPLE) + 1, math.min(size, ((i - 1) * MAX_TUPLE) + MAX_TUPLE)))
		stringBuild[i] = chunk
	end
	return table.concat(stringBuild)
end


function StringUtil.EqualsIgnoreCase(str1, str2)
	return (string.lower(str1) == string.lower(str2))
end


function StringUtil.ToCamelCase(str)
	str = string.gsub(str, "[%-_]+([^%-_])", string.upper)
	return string.lower(string.sub(str, 1, 1)) .. string.sub(str, 2)
end


function StringUtil.ToPascalCase(str)
	str = StringUtil.ToCamelCase(str)
	return string.upper(string.sub(str, 1, 1)) .. string.sub(str, 2)
end


local function SnakeCaseReplacement(s1, s2)
	return s1 .. "_" .. string.lower(s2)
end


function StringUtil.ToSnakeCase(str, uppercase)
	str = string.gsub(string.gsub(str, "[%-_]+", "_"), "([^%u%-_])(%u)", SnakeCaseReplacement)
	if (uppercase) then
		str = string.upper(str)
	else
		str = string.lower(str)
	end
	return str
end


local function KebabCaseReplacement(s1, s2)
	return s1 .. "-" .. string.lower(s2)
end


function StringUtil.ToKebabCase(str, uppercase)
	str = string.gsub(string.gsub(str, "[%-_]+", "-"), "([^%u%-_])(%u)", KebabCaseReplacement)
	if (uppercase) then
		str = string.upper(str)
	else
		str = string.lower(str)
	end
	return str
end


setmetatable(StringUtil, {__index = string})


return StringUtil