The StringUtil module provides utility functions for Lua strings.

--------------------

### `Trim(String str)`
Trims whitespace from the start and end of the string.

```lua
StringUtil.Trim("  hello world  ") == "hello world"
```

--------------------

### `TrimStart(String str)`
The same as Trim, but only trims the start of the string.

```lua
StringUtil.TrimStart("  hello world  ") == "hello world  "
```

--------------------

### `TrimEnd(String str)`
The same as Trim, but only trims the end of the string.

```lua
StringUtil.TrimEnd("  hello world  ") == "  hello world"
```

--------------------

### `EqualsIgnoreCase(String str, String compare)`
Checks if two strings are equal, but ignores their case.

```lua
StringUtil.EqualsIgnoreCase("HELLo woRLD", "hEllo wORLd") == true
```

--------------------

### `RemoveWhitespace(String str)`
Removes all whitespace from a string.

```lua
StringUtil.RemoveWhitespace("  hello World!\n") == "helloWorld!"
```

--------------------

### `RemoveExcessWhitespace(String str)`
Replaces all whitespace with a single space. This does not trim the string.

```lua
StringUtil.RemoveExcessWhitespace("This     is    a   \n  test") == "This is a test"
```

--------------------

### `EndsWith(String str, String endsWith)`
Checks if a string ends with a certain string.

```lua
StringUtil.EndsWith("Hello world", "rld") == true
```

--------------------

### `StartsWith(String str, String startsWith)`
Checks if a string starts with a certain string.

```lua
StringUtil.StartsWith("Hello world", "He") == true
```

--------------------

### `Contains(String str, String contains)`
Checks if a string contains another string.

```lua
StringUtil.Contains("Hello world", "lo wor") == true
```

--------------------

### `ToCharArray(String str)`
Returns a table of all the characters in the string.

```lua
StringUtil.ToCharArray("Hello") >>> {"H","e","l","l","o"}
```

--------------------

### `ToByteArray(String str)`
Returns a table of all the bytes of each character in the string.

```lua
StringUtil.ToByteArray("Hello") >>> {72,101,108,108,111}
```

--------------------

### `ByteArrayToString(Table bytes)`
Transforms an array of bytes into a string.

```lua
StringUtil.ByteArrayToString({97, 98, 99}) == "abc"
```

--------------------

### `ToCamelCase(String str)`
Returns a string in camelCase.

```lua
StringUtil.ToCamelCase("Hello_world-abc") == "helloWorldAbc"
```

--------------------

### `ToPascalCase(String str)`
Returns a string in PascalCase.

```lua
StringUtil.ToPascalCase("Hello_world-abc") == "HelloWorldAbc"
```

--------------------

### `ToSnakeCase(String str [, uppercase])`
Returns a string in snake_case or SNAKE_CASE.

```lua
StringUtil.ToPascalCase("Hello_world-abc") == "hello_world_abc"
StringUtil.ToPascalCase("Hello_world-abc", true) == "HELLO_WORLD_ABC"
```

--------------------

### `ToKebabCase(String str [, uppercase])`
Returns a string in kebab-case or KEBAB-CASE.

```lua
StringUtil.ToKebabCase("Hello_world-abc") == "hello-world-abc"
StringUtil.ToKebabCase("Hello_world-abc", true) == "HELLO-WORLD-ABC"
```

--------------------

### `Escape(str)`
Escapes a string from pattern characters. In other words, it prefixes
any special pattern characters with a %. For example, the dollar
sign $ would become %$. See the example below.

```lua
StringUtil.Escape("Hello. World$ ^-^") == "Hello%. World%$ %^%-%^"
```

--------------------

### `StringBuilder()`
Creates a StringBuilder object that can be used to build a string. This
is useful when a large string needs to be concatenated. Traditional
concatenation of a string using ".." can be a performance issue, and thus
StringBuilders can be used to store the pieces of the string in a table
and then concatenate them all at once.

```lua
local builder = StringUtil.StringBuilder()

builder:Append("world")
builder:Prepend("Hello ")
builder:ToString() == "Hello world"
tostring(builder)  == "Hello world"
```