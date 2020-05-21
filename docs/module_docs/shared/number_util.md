The NumberUtil module provides utility functions for Lua numbers.

--------------------

### `E`
The irrational number e.

```lua
NumberUtil.E == 2.7182818284590
```

--------------------

### `Tau`
Equal to `2π`.

```lua
NumberUtil.Tau == 6.2831853071796
```

--------------------

### `Lerp(min, max, alpha)`
Interpolate between two numbers by a certain alpha/percentage. The name "lerp" comes from combining _**l**inear int**erp**olation_.

Visually, think of a number line ranging from 'min' to 'max' and then move along that line by 'alpha' percent.

```lua
NumberUtil.Lerp(5, 15, 0.5) == 10
NumberUtil.Lerp(5, 15, 0)   == 5
NumberUtil.Lerp(5, 15, 0.7) == 12
NumberUtil.Lerp(5, 15, 2)   == 25
```

--------------------

### `LerpClamp(min, max, alpha)`
The same as Lerp, except `alpha` is clamped between the range of `[0, 1]`. This helps avoid the resultant number being out of the input range of `[min, max]`.

```lua
NumberUtil.LerpClamp(5, 15, 0.5) == 10
NumberUtil.LerpClamp(5, 15, 2)   == 15  -- 'alpha' clamped to 1.
```

--------------------

### `InverseLerp(min, max, num)`

The inverse of the Lerp function. It returns the `alpha` value between the range of `[min, max]` given the `num`.

```lua
NumberUtil.InverseLerp(5, 15, 10) == 0.5
NumberUtil.InverseLerp(5, 15, 12) == 0.7
```

--------------------

### `Map(n, inMin, inMax, outMin, outMax)`
Remaps the range of 'num' from its old range of `[inMin, inMax]` to a new range of `[outMin, outMax]`. This is useful when needing to convert a range of inputs to a different output. For instance, remapping gamepad stick input to a larger range controlling a vehicle steering wheel.

Mathematically, this is done by doing an inverse lerp with `n` on `[inMin, inMax]` to get the correct alpha value, and then lerping that alpha value with the range of `[outMin, outMax]`.

```lua
NumberUtil.Map(0.5, 0, 1, -10, 10) == 0
NumberUtil.Map(1, -1, 1, 0, 5)     == 5
```

--------------------

### `Round(num)`
Rounds a number to the nearest whole number.

Internally, this uses the `math.floor` and `math.ceil` Lua math functions to round the number.

```lua
NumberUtil.Round(1.5)  == 2
NumberUtil.Round(3.2)  == 3
NumberUtil.Round(-0.5) == -1
```

--------------------

### `RoundTo(num, multiple)`
Rounds a number to the nearest given multiple. An example would be locking world positions onto a larger grid.

```lua
NumberUtil.RoundTo(3.4, 5) == 5
NumberUtil.RoundTo(12, 5)  == 10
```