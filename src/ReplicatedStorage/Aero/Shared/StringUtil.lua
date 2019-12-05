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
	StringUtil.ToCamelCase(String str)
	StringUtil.ToPascalCase(String str)
	StringUtil.ToSnakeCase(String str [, uppercase])
	StringUtil.ToKebabCase(String str [, uppercase])
	StringUtil.StringBuilder()

	EXAMPLES:

		Trim:

			Trims whitespace from the start and end of the string.

			StringUtil.Trim("  hello world  ") == "hello world"


		TrimStart:

			The same as Trim, but only trims the start of the string:

			StringUtil.TrimStart("  hello world  ") == "hello world  "


		TrimEnd:

			The same as Trim, but only trims the end of the string:

			StringUtil.TrimEnd("  hello world  ") == "  hello world"


		EqualsIgnoreCase:

			Checks if two strings are equal, but ignores their case:

			StringUtil.EqualsIgnoreCase("HELLo woRLD", "hEllo wORLd") == true


		RemoveWhitespace:

			Removes all whitespace from a string:

			StringUtil.RemoveWhitespace("  hello World!\n") == "helloWorld!"


		RemoveExcessWhitespace:

			Replaces all whitespace with a single space. This does not trim the string:

			StringUtil.RemoveExcessWhitespace("This     is    a   \n  test") == "This is a test"


		EndsWith:

			Checks if a string ends with a certain string:

			StringUtil.EndsWith("Hello world", "rld") == true


		StartsWith:

			Checks if a string starts with a certain string:

			StringUtil.StartsWith("Hello world", "He") == true


		Contains:

			Checks if a string contains another string:

			StringUtil.Contains("Hello world", "lo wor") == true


		ToCharArray:

			Returns a table of all the characters in the string:

			StringUtil.ToCharArray("Hello") >>> {"H","e","l","l","o"}


		ToByteArray:

			Returns a table of all the bytes of each character in the string:

			StringUtil.ToByteArray("Hello") >>> {72,101,108,108,111}


		ToCamelCase:
		
			Returns a string in camelCase:

			StringUtil.ToCamelCase("Hello_world-abc") == "helloWorldAbc"


		ToPascalCase:
		
			Returns a string in PascalCase:

			StringUtil.ToPascalCase("Hello_world-abc") == "HelloWorldAbc"


		ToSnakeCase:
		
			Returns a string in snake_case or SNAKE_CASE:

			StringUtil.ToPascalCase("Hello_world-abc") == "hello_world_abc"
			StringUtil.ToPascalCase("Hello_world-abc", true) == "HELLO_WORLD_ABC"


		ToKebabCase:
		
			Returns a string in kebab-case or KEBAB-CASE:

			StringUtil.ToKebabCase("Hello_world-abc") == "hello-world-abc"
			StringUtil.ToKebabCase("Hello_world-abc", true) == "HELLO-WORLD-ABC"


		StringBuilder:

			Creates a StringBuilder object that can be used to build a string. This
			is useful when a large string needs to be concatenated. Traditional
			concatenation of a string using ".." can be a performance issue, and thus
			StringBuilders can be used to store the pieces of the string in a table
			and then concatenate them all at once:

			local builder = StringUtil.StringBuilder()

			builder:Append("world")
			builder:Prepend("Hello ")
			builder:ToString() == "Hello world"
			tostring(builder)  == "Hello world"

--]]


local StringUtil = {}


function StringUtil.Escape(str)
	local escaped = str:gsub("([%.%$%^%(%)%[%]%+%-%*%?%%])", "%%%1")
	return escaped
end


function StringUtil.Trim(str)
	return str:match("^%s*(.-)%s*$")
end


function StringUtil.TrimStart(str)
	return str:match("^%s*(.+)")
end


function StringUtil.TrimEnd(str)
	return str:match("(.-)%s*$")
end


function StringUtil.RemoveExcessWhitespace(str)
	return str:gsub("%s+", " ")
end


function StringUtil.RemoveWhitespace(str)
	return str:gsub("%s+", "")
end


function StringUtil.EndsWith(str, ends)
	return str:match(StringUtil.Escape(ends) .. "$") ~= nil
end


function StringUtil.StartsWith(str, starts)
	return str:match("^" .. StringUtil.Escape(starts)) ~= nil
end


function StringUtil.Contains(str, contains)
	return str:find(contains) ~= nil
end


function StringUtil.StringBuilder()
	local sb = {}
	local str = {}
	function sb:Append(s)
		str[#str + 1] = s
	end
	function sb:Prepend(s)
		table.insert(str, 1, s)
	end
	function sb:ToString()
		return table.concat(str, "")
	end
	setmetatable(sb, {__tostring=sb.ToString})
	return sb
end


function StringUtil.ToCharArray(str)
	local chars = {}
	for i = 1,#str do
		chars[i] = str:sub(i, i)
	end
	return chars
end


function StringUtil.ToByteArray(str)
	local bytes = {}
	for i = 1,#str do
		bytes[i] = str:sub(i, i):byte()
	end
	return bytes
end


function StringUtil.EqualsIgnoreCase(str1, str2)
	return (str1:lower() == str2:lower())
end


function StringUtil.ToCamelCase(str)
	str = str:gsub("[%-_]+([^%-_])", function(s) return s:upper() end)
	return str:sub(1, 1):lower() .. str:sub(2)
end


function StringUtil.ToPascalCase(str)
	str = StringUtil.ToCamelCase(str)
	return str:sub(1, 1):upper() .. str:sub(2)
end


function StringUtil.ToSnakeCase(str, uppercase)
	str = str:gsub("[%-_]+", "_"):gsub("([^%u%-_])(%u)", function(s1, s2) return s1 .. "_" .. s2:lower() end)
	if (uppercase) then str = str:upper() else str = str:lower() end
	return str
end


function StringUtil.ToKebabCase(str, uppercase)
	str = str:gsub("[%-_]+", "-"):gsub("([^%u%-_])(%u)", function(s1, s2) return s1 .. "-" .. s2:lower() end)
	if (uppercase) then str = str:upper() else str = str:lower() end
	return str
end


setmetatable(StringUtil, {__index = string})


return StringUtil