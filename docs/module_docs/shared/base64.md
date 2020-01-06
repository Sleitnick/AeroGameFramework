The Base64 module allows for easy encoding and decoding of [Base64](https://en.wikipedia.org/wiki/Base64) values.

--------------------

## Constructor

### `Base64.new()`
Constructs a new Base64 object.
```lua
local b64 = Base64.new()
```

--------------------

## Methods

### `Encode(String str)`
Encodes the string into Base64 format.
```lua
local encoded = b64:Encode("Hello world")
print(encoded) --> SGVsbG8gd29ybGQ=
```

--------------------

### `Decode(String encodedStr)`
Decodes the string from Base64 format.
```lua
local decoded = b64:Decode("SGVsbG8gd29ybGQ=")
print(decoded) --> Hello world
```