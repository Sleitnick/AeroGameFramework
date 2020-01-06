The Thread module allows an alternative to the built-in globals `spawn` and `delay`. The built-in globals are known to throttle unexpectedly. The Thread module will provide the expected behavior for spawning and delayed spawning of new threads.

Please note that the Lua runtime is single-threaded, and any multi-threading applications are simply utilizing the underlying task scheduler to appear multi-threaded.

---------------------------

### `Thread.SpawnNow(Function func [, Variant args...])`
Spawns the given function on a new thread immediately. Internally, this is done by creating, firing, and destroying a BindableEvent. Due to this process, `SpawnNow` is not necessarily a well-performant operation, and thus should not be used when performance needs to be optimal.

```lua
Thread.SpawnNow(function()
	print("Hello from SpawnNow")
end)
```

---------------------------

### `Thread.Spawn(Function func, [, Variant args...])`
Spawns the given function on a new thread. Internally, this is done using RunService's Heartbeat event, which means that the function will be spawned on the next hearbeat step (i.e. next frame).

```lua
Thread.Spawn(function()
	print("Hello from Spawn")
end)
```

---------------------------

### `Thread.Delay(Number waitTime, Function func [, Variant args...])`
Spawns the given function on a new thread after `waitTime` has elapsed. Internally, this is the same as the above `Thread.Spawn` function, except for the delayed start.

Because this function returns the heartbeat connection, the delay can be cancelled by disconnecting the connection.

**Returns:** [Connection](https://developer.roblox.com/en-us/api-reference/datatype/RBXScriptConnection)

```lua
-- Spawn function after 3 seconds:
Thread.Delay(3, function()
	print("Hello from delay")
end)

-- Attempt to spawn after 5 seconds, but cancel it after 1 second:
local delayCon = Thread.Delay(5, function()
	print("This will never print")
end)
wait(1)
delayCon:Disconnect()
```

---------------------------

### `Thread.DelayRepeat(Number tm, Function func [, Variant args...])`
Continuously calls `func` after `tm` seconds on a new thread.

```lua
local inc = 0

Thread.DelayRepeat(3, function()
	inc = inc + 1
	print(inc)
end)
```