Adding realistic camera shaking can be a challenge, but the CameraShaker module makes it easy.

This module, as well as documentation, is also available in the [RbxCameraShaker](https://github.com/Sleitnick/RbxCameraShaker) GitHub repository.


!!! note
	The CameraShaker code was ported from the EZ Camera Shake asset from Unity's asset store, developed by Road Turtle Games. The original developer and asset are no longer around, but originally gave written permission to port the asset to Roblox. There was no licensing information provided.

--------------------

## Constructor

### `new(RenderPriority priority, Function callback)`
Constructs a new CameraShaker instance. The RenderPriority dictates when the callback function will execute (exactly the same as binding a function to RenderStep). Typically this should be placed at a value _after_ the camera will have been updated.

A way to think of the camera shaker is an additional "layer" to the camera system. The shaker adds a new effects layer to the camera.

```lua
local cam = workspace.CurrentCamera
local camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value + 1, function(cframe)
	cam.CFrame = cam.CFrame * cframe
end)
```

!!! tip
	While the CameraShaker is targeted toward shaking the camera, it can be used to make _any_ in-game object shake. For instance, a CameraShaker could be used to shake a model.

--------------------

## Static Properties

### `CameraShakeInstance`

A reference to the CameraShakeInstance class, which is used to construct an individual shake. The CameraShaker can have many CameraShakeInstances applied to it at one time.

--------------------

### `Presets`
A table of preset `CameraShakeInstances`. The presets are:

|Name|Best used as sustained|
|----|---------------------------|
|`Bump`|No|
|`Explosion`|No|
|`Earthquake`|Yes|
|`GentleSway`|Yes|
|`BadTrip`|Yes|
|`HandheldCamera`|Yes|
|`Vibration`|Yes|
|`RoughDriving`|Yes|

--------------------

## Methods

### `Start()`

Starts the CameraShaker.

```lua
camShake:Start()
```

--------------------

### `Stop()`

Stops the CameraShaker.

```lua
camShake:Stop()
```

--------------------

### `StopSustained([Number fadeOutTime])`

Stops any sustained shakes on the shaker instance. If no fade-out time is provided, it will use the fade-out time provided by the shake instance itself.

```lua
camShake:StopSustained()
```

--------------------

### `Shake(ShakeInstance shakeInstance)`

Invokes a single shake instance.

```lua
camShake:Shake(CameraShaker.Presets.Explosion)
```

--------------------

### `ShakeSustain(ShakeInstance shakeInstance)`

Invokes a single shake instance, and sustains the shake indefinitely.

```lua
camShake:ShakeSustain(CameraShaker.Presets.Earthquake)
```

--------------------

## Creating Custom Shakes

Custom shakes can be created by creating new CameraShakeInstance objects:

```lua
local CameraShakeInstance = CameraShaker.CameraShakeInstance

local bump = CameraShakeInstance.new(
	2.5, -- Magnitude (how far the camera can move)
	4,   -- Roughness (how fast the camera can move)
	0.1, -- Fade-in time (how long it takes to reach full magnitude)
	0.75 -- Fade-out time (how long it takes to fade out to no shaking)
)
-- How far the position can moved (but will be multiplied by the magnitude):
bump.PositionInfluence = Vector3.new(0.15, 0.15, 0.15)

-- How much rotation is allowed (in degrees; also multiplied by magnitude):
bump.RotationInfluence = Vector3.new(1, 1, 1)

-- Apply the shake:
camShake:Shake(bump)
```