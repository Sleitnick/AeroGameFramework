The Date module allows for easy description of time. It is modeled after the JavaScript Date object.

---------------------------

## Constructors

### `Date.new([Number seconds [, Boolean useUTC]])`
### `Date.fromJSON(String jsonString)`

```lua
local date = Date.new() -- Date as of right now
local date = Date.new(1578329690, true) -- Date as of January 6, 2020, 4:55PM
```

---------------------------

## Methods

### `ToJSON()`
Converts the Date object to a JSON string.

```lua
local jsonDate = date:ToJSON()
```

---------------------------

### `ToSeconds()`
Returns the number of seconds representing the object. This is the most practical method to use for saving/serializing the date, since it has the smallest footprint.

```lua
local seconds = date:ToSeconds()
```

---------------------------

### `GetTimezoneHourOffset()`
Get the timezone offset in hours.

```lua
local timezoneHourOffset = date:GetTimezoneHourOffset()
print("Timezone offset in hours:", timezoneHourOffset) --> e.g. 5
```

---------------------------

### `Format(String format)`
Format the date string. See the [GNU Date Commands](https://www.cyberciti.biz/faq/linux-unix-formatting-dates-for-display/) for relevant formats.

```lua
local date = Date.new()
local format = date:Format("%B %d, %Y")
print(format) --> e.g. January 6, 2020
```

---------------------------

### `ToUTC()`
Constructs and returns a new Date object with the time converted to [UTC](https://en.wikipedia.org/wiki/Coordinated_Universal_Time).

```lua
local localTime = Date.new()
local utcTime = localTime:ToUTC()
```

---------------------------

### `ToLocal()`
Constructs and returns a new Date object with the time converted from UTC time into local time.

```lua
local utcTime = Date.new():ToUTC()
local localTime = utcTime:ToLocal()
```

---------------------------

### `ToISOString()`
Returns the ISO string representation of the date.

```lua
print(date:ToISOString()) --> e.g. 2020-01-06T17:08:24.473
```

---------------------------

### `ToDateString()`
Returns a string representing the shorthand date.

```lua
print(date:ToDateString()) --> e.g. Mon Jan 6 2020
```

---------------------------

### `ToTimeString()`
Returns a string representing the time.

```lua
print(date:ToTimeString()) --> e.g. 17:10:28
```

---------------------------

### `ToString()`
Returns a string representing the time and date combined.

```lua
print(date:ToString()) --> e.g. Mon Jan 6 2020 17:10:28

-- Also works with tostring:
print(tostring(date))
```

---------------------------

## Properties

### `Hour`
The hour of the day.

### `Minute`
The minute of the day.

### `Weekday`
The numeric weekday.

### `Day`
The day of the month.

### `Month`
The numeric month.

### `Year`
The year.

### `Second`
The seconds since January 1, 1970.

### `Millisecond`
The milliseconds since January 1, 1970.

### `Yearday`
The day of the year.

### `IsDST`
Whether or not the date represents daylight saving time.

---------------------------

## Operators

Simple comparison operators can be used on dates.

```lua
local date1 = Date.new(0)
local date2 = Date.new(100)
local date3 = Date.new(100)
print(date1 < date2)   --> true
print(date1 >= date2)  --> false
print(date2 == date3)  --> true
```