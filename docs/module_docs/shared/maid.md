The Maid class lets you easily watch and clean up objects, events, and other tasks. Written by [Quenty](https://github.com/Quenty), this class has proven itself worthy in some of Roblox's most successful games.

--------------------

## Constructor

### `Maid.new()`
Creates a new Maid instance.
```lua
local maid = Maid.new()
```

--------------------

## Methods

### `GiveTask(task)`
Stores a task. The task can be an event connection, an instance or table with a `Destroy` method, or a function. When the maid's `DoCleaning` or `Destroy` method is invoked, these tasks will be cleaned up. Events will be disconnected, instances will be destroyed, and functions will be called.
```lua
maid:GiveTask(myModel)
maid:GiveTask(workspace.ChildAdded:Connect(function(obj) end))
maid:GiveTask(function() end)
```

**Returns:** `number` index of the task.

--------------------

### `GivePromise(promise)`
Stores a promise. If the maid is cleaned up and the promise is not completed, the promise will be cancelled.
```lua
maid:GivePromise(Promise.Async(function(resolve, reject)
	wait(5)
	resolve()
end))
```

**Returns:** Promise

--------------------

### `DoCleaning()`
Cleans up all the tasks. Event connections will be disconnected, instances will be destroyed, and functions will be called.
```lua
maid:DoCleaning()
```

--------------------

### `Destroy()`
Alias for `DoCleaning`.
```lua
maid:Destroy()
```