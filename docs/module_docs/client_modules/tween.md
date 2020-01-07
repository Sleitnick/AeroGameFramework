The Tween module is an abstraction of the built-in Tween object. The benefit of this module is that a function can be bound to the tweening process, thus allowing developers to easily customize how a tween will work (e.g. tweening multiple objects instead of just one).

--------------------

## Constructors

### `FromService(Instance object, TweenInfo info, Table properties)`
Simply a shortcut for [`TweenService:Create()`](https://developer.roblox.com/en-us/api-reference/function/TweenService/Create).

--------------------

### `new(TweenInfo info, Function callback)`
Creates a new custom Tween object. While the returned tween object is custom-built, it reflects the same methods and events as the default Tween object. Therefore, refer to the documentation for that object for using the tween.

When the tween is played, the callback function will be called for every frame (using RenderStep internally), and will pass along the tween value to the function. The value is typically a value between 0 and 1, but can be outside that range for particular easing functions.

**Returns:** [Tween](https://developer.roblox.com/en-us/api-reference/class/Tween)

```lua
local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tween = Tween.new(info, function(n)
	print(n)
end)
```

--------------------

## Methods

### `Play()`
Start or resume the tween.

```lua
tween:Play()
```

--------------------

### `Pause()`
Pause the tween.

```lua
tween:Pause()
```

--------------------

### `Cancel()`
Cancel the tween.

```lua
tween:Cancel()
```

--------------------

## Events

### `Completed(PlaybackState state)`
Fired when the tween is completed and passes along the [PlaybackState](https://developer.roblox.com/en-us/api-reference/enum/PlaybackState).

### `PlaybackStateChanged(PlaybackState state)`
Fired when the [PlaybackState](https://developer.roblox.com/en-us/api-reference/enum/PlaybackState) changes.

--------------------

## Properties

### `TweenInfo`
The [TweenInfo](https://developer.roblox.com/en-us/api-reference/property/Tween/TweenInfo) assigned to this tween.

--------------------

### `Callback`
The callback function assigned to this tween.

--------------------

### `PlaybackState`
The current [PlaybackState](https://developer.roblox.com/en-us/api-reference/enum/PlaybackState) of this tween.