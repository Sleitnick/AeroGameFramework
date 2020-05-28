-- Date
-- Stephen Leitnick
-- September 12, 2017

--[=[

	Represents a date at a specific time. On the server, this will
	return UTC time. On the client, this will return local time.
	Note that the server-side in Play-Solo testing will also return
	local time.

	You can optionally force UTC within the Date.new constructor.


	REQUIRE:

		local Date = require(thisModule)


	CONSTRUCTORS:

		local date = Date.new([seconds [, useUtc]])
		local date = Date.fromJSON(jsonString)


	METHODS:

		date:ToJSON()
		date:ToSeconds()
		date:GetTimezoneHourOffset()
		date:Format(strFormat)
		date:ToUTC()
		date:ToLocal()
		date:ToISOString()
		date:ToDateString()
		date:ToTimeString()
		date:ToString()


	PROPERTIES:

		date.Hour
		date.Minute
		date.Weekday
		date.Day
		date.Month
		date.Year
		date.Second
		date.Millisecond
		date.Yearday
		date.IsDST


	NOTE ON SAVING:

		You should use 'date:ToSeconds()' for saving. It can
		represent the date in the smallest format. While using
		'date:ToJSON()' will work too, it has a higher data
		footprint. Example:

		SAVE:

			local date = Date.new()
			dataStore:SetAsync("myDate", date:ToSeconds())

		LOAD:

			local myDateSeconds = dataStore:GetAsync("myDate")
			local date = Date.new(myDateSeconds)


--]=]


local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")


local Date = {}
Date.__index = Date


local useUTC = RunService:IsServer()


local WEEKDAYS = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}
local WEEKDAYS_SHORT = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"}

local MONTHS = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"}
local MONTHS_SHORT = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"}


-- Single-level table copy:
local function CopyTable(t)
	local tCopy = {}
	for k,v in pairs(t) do
		tCopy[k] = v
	end
	return tCopy
end


function Date.new(seconds, useUtcOverride)

	if (seconds ~= nil) then
		assert(type(seconds) == "number", "'seconds' argument #1 must be a number")
	else
		seconds = tick()
	end

	local utc = useUTC
	if (useUtcOverride ~= nil) then
		utc = useUtcOverride
	end

	local d = os.date(utc and "!*t" or "*t", seconds)

	local self = setmetatable({
		Hour = d.hour;
		Minute = d.min;
		Weekday = d.wday;
		Day = d.day;
		Month = d.month;
		Year = d.year;
		Second = d.sec;
		Millisecond = math.floor((seconds % 1) * 1000);
		Yearday = d.yday;
		IsDST = d.isdst;
		_d = d;
		_s = seconds;
	}, Date)

	return self

end


function Date.fromJSON(jsonStr)
	assert(type(jsonStr) == "string", "'jsonStr' argument #1 must be a string")
	local success, data = pcall(function()
		return HttpService:JSONDecode(jsonStr)
	end)
	if (not success) then
		error("Failed to decode JSON string: " .. tostring(data))
	end
	local seconds
	if (data._s) then
		seconds = data._s
	else
		seconds = os.time(data)
	end
	return Date.new(seconds)
end


function Date:ToJSON()
	local data = CopyTable(self._d)
	data._s = self._s
end


function Date:ToSeconds()
	return self._s
end


function Date:GetTimezoneHourOffset()
	local dUTC = os.date("!*t", self._s)
	return (self._d.hour - dUTC.hour)
end


function Date:ToISOString()
	local utc = self:ToUTC()
	local d = utc._d
	return string.format(
		"%.2i-%.2i-%.2iT%.2i:%.2i:%.2i.%.3i",
		d.year,
		d.month,
		d.day,
		d.hour,
		d.min,
		d.sec,
		math.floor((utc._s % 1) * 1000)
	)
end


function Date:ToDateString()
	local d = self._d
	return string.format(
		"%s %s %i %i",
		WEEKDAYS_SHORT[d.wday],
		MONTHS_SHORT[d.month],
		d.day,
		d.year
	)
end


function Date:ToTimeString()
	local d = self._d
	return string.format(
		"%.2i:%.2i:%.2i",
		d.hour,
		d.min,
		d.sec
	)
end


function Date:ToString()
	return (self:ToDateString() .. " " .. self:ToTimeString())
end


function Date:ToUTC()
	return Date.new(self._s, true)
end


function Date:ToLocal()
	return Date.new(self._s, false)
end


-- See GNU date commands:
-- https://www.cyberciti.biz/faq/linux-unix-formatting-dates-for-display/
function Date:Format(str)
	local d = self._d
	local h12 = d.hour
	if (h12 > 12) then
		h12 = h12 - 12
	end
	if (h12 == 0) then
		h12 = 0
	end
	str = string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(str,
		"%%a", WEEKDAYS_SHORT[d.wday]),
		"%%A", WEEKDAYS[d.wday]),
		"%%b", MONTHS_SHORT[d.month]),
		"%%B", MONTHS[d.month]),
		"%%c", self:ToString()),
		"%%C", ((d.year - (d.year % 1000)) / 100) + 1),
		"%%d", string.format("%.2i", d.day)),
		"%%D", string.format("%.2i/%.2i/%s", d.month, d.day, string.sub(tostring(d.year), -2))),
		"%%F", string.format("%i-%.2i-%.2i", d.year, d.month, d.day)),
		"%%H", string.format("%.2i", d.hour)),
		"%%k", string.format("%.2i", d.hour)),
		"%%I", string.format("%.2i", h12)),
		"%%l", string.format("%.2i", h12)),
		"%%j", string.format("%.3i", d.yday)),
		"%%m", string.format("%.2i", d.month)),
		"%%M", string.format("%.2i", d.min)),
		"%%n", "\n"),
		"%%p", (d.hour >= 12 and "PM" or "AM")),
		"%%P", (d.hour >= 12 and "pm" or "am")),
		"%%r", string.format("%.2i:%.2i:%.2i %s", h12, d.min, d.sec, (d.hour >= 12 and "PM" or "AM"))),
		"%%R", string.format("%.2i:%.2i", d.hour, d.min)),
		"%%s", math.floor(self._s)),
		"%%S", string.format("%.2i", d.sec)), "%%t", "\t"),
		"%%T", string.format("%.2i:%.2i:%.2i", d.hour, d.min, d.sec)),
		"%%w", string.format("%.2i", d.wday)),
		"%%y", string.sub(tostring(d.year), -2)),
		"%%Y", tostring(d.year)
	)

	return str

end


Date.New = Date.new
Date.FromJSON = Date.fromJSON
Date.__tostring = Date.ToString
Date.__metatable = "locked"


function Date.__lt(d1, d2)
	return (d1._s < d2._s)
end


function Date.__le(d1, d2)
	return (d1._s <= d2._s)
end


function Date.__eq(d1, d2)
	return (d1._s == d2._s)
end


function Date.__unm(d)
	return Date.new(-d._s)
end


return Date