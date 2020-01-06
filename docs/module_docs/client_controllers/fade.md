The Fade controller allows for easy and simple fade-in and fade-out effects on the screen.

For most cases, using just the `In` and `Out` methods is enough.

## Methods

### `In([Number duration [, Boolean async]])`
Fade in from black.

```lua
Fade:In() -- Fade in over 0.5 seconds
Fade:In(1.5) -- Fade in over 1.5 seconds)
Fade:In(1.5, true) -- Fade in asynchronously over 1.5 seconds
```

---------------------------

### `Out([Number duration [, Boolean async]])`
Fade out to black.

```lua
Fade:Out() -- Fade out over 0.5 seconds
Fade:Out(1.5) -- Fade out over 1.5 seconds)
Fade:Out(1.5, true) -- Fade out asynchronously over 1.5 seconds
```

---------------------------

### `To(Number transparency [, Number duration [, Boolean async]])`
Fade to the given transparency, starting at whatever the current fade transparency is set.

```lua
Fade:To(0.75) -- Fade to a transparency of 0.75 (75%)
```

---------------------------

### `FromTo(Number from, Number to [, Number dur [, Boolean async]])`
Fade from one transparency level to another. This is also used internally by the `In` and `Out` fade methods.

```lua
Fade:FromTo(0.75, 0.25) -- Fade from 0.75 to 0.25
```

---------------------------

### `SetText(String text)`
Set the text that will show up in the center of the screen when the fade screen is visible.

```lua
Fade:SetText("Hello world")
```

---------------------------

### `ClearText()`
Clear the text on the fade screen.

```lua
Fade:ClearText()
```

---------------------------

### `SetTextSize(Number textSize)`
Set the text size for the fade screen label.

```lua
Fade:SetTextSize(24)
```

---------------------------

### `SetFont(Font font)`
Set the font for the fade screen label.

```lua
Fade:SetFont(Enum.Font.Highway)
```

---------------------------

### `SetBackgroundColor(Color3 color)`
Sets the background color of the fade frame.

```lua
Fade:SetBackgroundColor(Color3.new(0.5, 0.5, 0.5))
```

---------------------------

### `SetTextColor(Color3 color)`
Sets the text color of the fade text label.

```lua
Fade:SetBackgroundColor(Color3.new(1, 0, 0))
```

---------------------------

### `SetEasingStyle(EasingStyle easingStyle)`
Sets the tween easing style for the fading effect. Defaults to Quad.

```lua
Fade:SetEasingStyle(Enum.EasingStyle.Quint)
```

---------------------------

### `GetScreenGui()`
Returns the ScreenGui used by the Fade controller.

```lua
local gui = Fade:GetScreenGui()
```

---------------------------

### `GetFrame()`
Returns the Frame used by the Fade controller.

```lua
local gui = Fade:GetFrame()
```

---------------------------

### `GetLabel()`
Returns the TextLabel used by the Fade controller.

```lua
local gui = Fade:GetLabel()
```