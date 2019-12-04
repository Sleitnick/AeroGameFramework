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
		chars[i] = str:sub(1, 1)
	end
	return chars
end


function StringUtil.ToByteArray(str)
	local bytes = {}
	for i = 1,#str do
		bytes[i] = str:sub(1, 1):byte()
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