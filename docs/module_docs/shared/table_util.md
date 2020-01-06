The TableUtil module provides utility functions for Lua tables.

--------------------

### `Copy(Table tbl)`
Creates and returns a deep copy of the given table.

```lua
local tbl = {"a", "b", "c", {"x", "y", "z"}}
local tblCopy = TableUtil.Copy(tbl)
```

--------------------

### `CopyShallow(Table tbl)`
Creates and returns a shallow copy of the given table.

```lua
local tbl = {"a", "b", "c"}
local tblCopy = TableUtil.Copy(tbl)
```

--------------------

### `Sync(Table tbl, Table templateTbl)`
Synchronizes a table to the template table. If the table does not have an item that exists within the template, it gets added. If the table has something that the template doesn't have, it gets removed.

```lua
local tbl1 = {kills = 0; deaths = 0; points = 0}
local tbl2 = {points = 0}
TableUtil.Sync(tbl2, tbl1)  -- Synchronize table2 to table1
print(tbl2.deaths)
```

--------------------

### `Print(Table tbl, String label, Boolean deepPrint)`
Prints the table to the output. This is useful for debugging tables.

```lua
local tbl = {a = 32; b = 64; c = 128; d = {x = 0; y = 1; z = 2}}
TableUtil.Print(tbl, "My Table", true)
```

!!! warning
	This method does not detect cyclical tables. Passing a cyclical table will result in a stackoverflow.

--------------------

### `FastRemove(Table tbl, Number index)`
Removes an item at `index` in the table `tbl`. Instead of using `table.remove`, this simply grabs the last item in the table and places it at the given index and trims off the last item. This is significantly faster than `table.remove` because it runs in `O(1)`, whereas `table.remove` is `O(N)`.

```lua
local tbl = {"hello", "there", "this", "is", "a", "test"}
TableUtil.FastRemove(tbl, 2)   -- Remove "there" in the array
print(table.concat(tbl, " "))  -- > hello test this is a
```

!!! warning
	The order of the table is _not_ preserved using this function. **Do not** use this if the ordering of your table needs to be maintained.

--------------------

### `FastRemoveFirstValue(Table tbl, Variant value)`
Performs the `FastRemove` operation on the first index that contains `value`.

```lua
local tbl = {"hello", "there", "this", "is", "a", "test"}
TableUtil.FastRemoveFirstValue(tbl, "there")   -- Remove "there" in the array
print(table.concat(tbl, " "))  -- > hello test this is a
```

--------------------

### `Map(Table tbl, Function callback)`
Constructs a new table by populating it with the results of calling a function on every item in the `tbl` table. Useful for restructuring an existing table.

```lua
local peopleData = {
	{firstName = "Bob"; lastName = "Smith"};
	{firstName = "John"; lastName = "Doe"};
	{firstName = "Jane"; lastName = "Doe"};
}

local people = TableUtil.Map(peopleData, function(item)
	return {Name = item.firstName .. " " .. item.lastName}
end)

-- 'people' is now an array that looks like: { {Name = "Bob Smith"}; ... }
```

--------------------

### `Filter(Table tbl, Function callback)`
Constructs a new table based on `tbl` where it will only include items allowed by the `callback` function. Each item in the `tbl` table are passed to the callback.

```lua
local people = {
	{Name = "Bob Smith"; Age = 42};
	{Name = "John Doe"; Age = 34};
	{Name = "Jane Doe"; Age = 37};
}

local peopleUnderForty = TableUtil.Filter(people, function(item)
	return item.Age < 40
end)
```

--------------------

### `Reduce(Table tbl, Function callback)`
Reduces the `tbl` table to a single number. This is useful for tasks such as summing up a table's values. Each item is passed to the callback, as well as an accumulator.

```lua
local tbl = {40, 32, 9, 5, 44}
local tblSum = TableUtil.Reduce(tbl, function(accumulator, value)
	return accumulator + value
end)
print(tblSum)  -- > 130
```

--------------------

### `Assign(Table target, Table sources...)`
Allows the assigning of values from multiple tables into one. The `Assign` function is similar to JavaScript's `Object.Assign()` function and is useful for things such as composition-designed systems.

```lua
local function Driver()
	return {
		Drive = function(self) self.Speed = 10 end;
	}
end

local function Teleporter()
	return {
		Teleport = function(self, pos) self.Position = pos end;
	}
end

local function CreateCar()
	local state = {
		Speed = 0;
		Position = Vector3.new();
	}
	-- Assign the Driver and Teleporter components to the car:
	return TableUtil.Assign({}, Driver(), Teleporter())
end

local car = CreateCar()
car:Drive()
car:Teleport(Vector3.new(0, 10, 0))
```

--------------------

### `IndexOf(Table tbl, Variant item [, Number start])`
Returns the index of the given `item` in the table. If no item is found, this will return `nil`. Optionally, a `start` index can be provided.

```lua
local tbl = {"Hello", 32, true, "abc"}
local abcIndex = TableUtil.IndexOf(tbl, "abc")        -- > 4
local helloIndex = TableUtil.IndexOf(tbl, "Hello")    -- > 1
local helloIndex = TableUtil.IndexOf(tbl, "Hello", 3) -- > nil
local numberIndex = TableUtil.IndexOf(tbl, 64)        -- > nil
```

!!! note
	`table.find` does the exact same operation, but was introduced after this method was written. For backwards compatibility, this method will continue to exist, but simply points to the `table.find` function instead.

--------------------

### `Reverse(Table tbl)`
Creates a reversed version of the table.

```lua
local tbl = {2, 4, 6, 8}
local rblReversed = TableUtil.Reverse(tbl)  -- > {8, 6, 4, 2}
```

!!! warning
	This is a shallow copy.

--------------------

### `Shuffle(Table tbl)`
Shuffles the array. Internally, this is using the [Fisher-Yates algorithm](https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle) to shuffle around the items.

```lua
local tbl = {1, 2, 3, 4, 5, 6, 7, 8, 9}
TableUtil.Shuffle(tbl)
print(table.concat(tbl, ", "))  -- e.g. > 3, 6, 9, 2, 8, 4, 1, 7, 5
```

!!! warning
	This mutates the table.

--------------------

### `IsEmpty(Table tbl)`

Returns `true` if the table is empty.

```lua
local t1 = {}
local t2 = {"Hello"}
local t3 = {X = 32}
print(TableUtil.IsEmpty(t1)) --> true
print(TableUtil.IsEmpty(t2)) --> false
print(TableUtil.IsEmpty(t3)) --> false
```

--------------------

### `EncodeJSON(Table tbl)`

Shortcut for [`HttpService:JSONEncode()`](https://developer.roblox.com/en-us/api-reference/function/HttpService/JSONEncode)

```lua
local plrData = {Points = 32; Cash = 100; Balloons = 540}
local plrDataJson = TableUtil.EncodeJSON(plrData)
print(plrDataJson) --> {"Points": 32, "Cash": 100, "Balloons": 540}
```

--------------------

### `DecodeJSON(String json)`

Shortcut for [`HttpService:JSONDecode()`](https://developer.roblox.com/en-us/api-reference/function/HttpService/JSONDecode)

```lua
local plrDataJson = "{\"Points\": 32, \"Cash\": 100, \"Balloons\": 540}"
local plrData = TableUtil.DecodeJSON(plrDataJson)
print("Points", plrData.Points)
print("Cash", plrData.Cash)
print("Balloons", plrData.Balloons)
```