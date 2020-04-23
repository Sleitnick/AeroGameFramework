The VectorUtil module provides utility functions for Roblox vectors.

--------------------

### `ClampMagnitude(vector, maxMagnitude)`
Clamps the magnitude of a vector so it is only a certain length.

```lua
VectorUtil.ClampMagnitude(Vector3.new(100, 0, 0), 15) == Vector3.new(15, 0, 0)
VectorUtil.ClampMagnitude(Vector3.new(10, 0, 0), 20)  == Vector3.new(10, 0, 0)
```

--------------------

### `AngleBetween(vector1, vector2)`
Finds the angle (in radians) between two vectors.

```lua
local v1 = Vector3.new(10, 0, 0)
local v2 = Vector3.new(0, 10, 0)
AngleBetween(v1, v2) == math.rad(90)
```