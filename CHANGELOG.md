# AeroGameFramework Change Log

The following are updates that have been implemented into the framework, so you can understand the impact of upgrading the plugin or framework as changes are made.

Understand that the framework may change frequently, so upcoming changes may break compatibility with previous versions. Before upgrading, it is recommended that you read this `CHANGELOG.md` to see if there are BC Breaks, otherwise known as backwards-compatibility breaks, which may have an impact on your implementation against the framework working.

Anything noted with a ==[BC Break]== you should be cautious about upgrading until you understand what refactoring you may have to do in order to support the framework version.

If a version has a backwards-compatibility break, and you are not ready to upgrade to that version, you can always look at our version tags in Github and checkout to use a previous version. Although, this would be a manual process for you to copy the scripts for the particular version and should not upgrade using the auto updater, since that will always provide the latest version.

As always, you can also check the commit history for a given version as well, and examine the specific lines of code changed to understand how this may impact your project.

## Version Changes

| Version | Date | Description |
| ---|---|--- |
| [1.7.2]($1.7.2) | 2020-11-23 | <ul><li>Fix ProfileService so that it will work properly within the AGF environment</li><li>Replace `tick()` with appropriate replacements (e.g. `time()` and `os.time()`)</li><li>Fix linter</li></ul>
| [1.7.1](#1.7.1) | 2020-08-25 | <ul><li>Remove StoreService</li><li>Remove old Event module</li><li>Add new Signal module (replaces Event module)</li><li>Add new raycasting methods</li><li>Add ProfileService module</li><li>Upgrade Promise to 3.0.1</li><li>Implement new `.settings` file for configuring module behavior within the framework</li><li>Updated VS Code extension to allow for creating settings files (v0.0.23)</li><li>New PID implementation</li></ul> |
| [1.6.1](#1.6.1) | 2020-05-21 | <ul><li>Switch to Selene for linting</li><li>Include GitHub Action to run Selene for new pull requests</li><li>Less verbose method names for firing events</li><li>Various bug fixes and performance improvements</li></ul> |
| [1.6.0](#1.6.0) | 2020-04-23 | <ul><li>Add NumberUtil and VectorUtil libraries under Shared</li></ul> |
| [1.5.2](#1.5.2) | 2020-04-14 | <ul><li>Fix a breaking issue with back-to-back calls to a RemoteFunction incorrectly caching</li></ul> |
| [1.5.1](#1.5.1) | 2020-04-06 | <ul><li>Added Maid class</li></ul> |
| [1.5.0](#1.5.0) | 2020-01-05 | <ul><li>Added Data module</li><li><b>==[BC Break]==</b> Removed DataStoreService and its dependencies</li><li>Added Thread module</li></ul> |
| [1.4.1](#1.4.1) | 2019-12-15 | <ul><li>Fixed execution order for modules to respect init/start lifecycle</li><li>Add ability to force `Init` execution order using `__aeroOrder` field</li></ul> |
| [1.4.0](#1.4.0) | 2019-10-17 | <ul><li>Added `service:FireAllClientsEventExcept(eventName, player, ...)`</li><li>Dropped Roblox Studio plugin support in favor of VS Code extension</li><li>New documentation site</li></ul> |
| [1.3.0](#1.3.0) | 2018-12-19 | <ul><li>Restructured source directory and installer to be compatible with Rojo</li></ul> |
| [1.2.6](#1.2.6) | 2018-11-12 | <ul><li>Expanded TableUtil library</li></ul> |
| [1.2.5](#1.2.5) | 2018-09-20 | <ul><li>Added `__aeroPreventStart` flag for modules that already implement a Start method.</li><li>Added `__aeroPreventInit` flag for modules that already implement an Init method.</li><li>Flagged `__aeroPreventStart` for CameraShaker module.</li></ul> |
| [1.2.4](#1.2.4) | 2018-09-20 | <ul><li>Using `coroutine` yielding/resuming where applicable</li><li>Cleaned up deprecated code in TaskScheduler</li></ul> |
| [1.2.3](#1.2.3) | 2018-08-15 | <ul><li>Added `WrapModule` method to Server and Client main scripts.</li></ul> |
| [1.2.2](#1.2.2) | 2018-08-15 | <ul><li>Added Failed events for DataService.</li><li>Added Failed event for DataStoreCache.</li><li>Added Failed event for SafeDataStore.</li></ul> |

### Version History Notes

#### <a name="1.7.2"></a> Version 1.7.2
Fixes ProfileService so that it properly works within the AGF environment.

Use proper time functions within the code. `tick()` is no longer considered acceptable, and most cases can be swapped with `time()`. See [DevForum thread](https://devforum.roblox.com/t/luau-recap-june-2020/632346) on this topic.

[AGF Development] Fixed automated Selene linter by switching to Foreman for tool installations.

#### <a name="1.7.1"></a> Version 1.7.1
<b>==[BC Break]==</b> Removed StoreService, as it was not very good and pigeonholed developers into a specific pattern for product purchases.

<b>==[BC Break]==</b> Added new Signal module to replace the older Event module. The API is the same, but the implementation is more robust.

<b>==[BC Break]==</b> New PID implementation.

Replaced older raycasting methods with the newer ones within the Mouse and Mobile input modules.

Added MadStudio's ProfileService module for datastore use. This module is much more robust than the existing Data module.

Added a new `.settings` module feature to configure the behavior of modules within the framework. For instance, a controller named `MyController` can now have a `MyController.settings` module that contains specific configuration details for the module. See [Settings](https://sleitnick.github.io/AeroGameFramework/settings/) documentation. The VS Code extension for AGF has also been updated to support this feature (v0.0.22).

#### <a name="1.6.1"></a> Version 1.6.1
Added support for Selene. All pull requests are now required to pass through the Selene check before being merged into master.

Implemented less verbose method names for firing events and deprecated the old versions.

Modules are no longer wrapped with the Aero metatable if they already have a metatable and a `__call` metamethod. This adds easier support of third-party modules such as DataStore2.

The mouse is no longer enabled/disabled by default based on user input. If developers wish to hide the mouse automatically when a gamepad is used, `UserInput.HideMouse` must be set to `true`.

There were also various bug fixes and performance enhancements thanks to the implementation of Selene.

#### <a name="1.6.0"></a> Version 1.6.0
Added NumberUtil and VectorUtil libraries. These libraries contain functions that are commonly used in game development but are not available out-of-the-box in Roblox's API.

#### <a name="1.5.2"></a> Version 1.5.2
Fix a breaking issue regarding back-to-back invocations of RemoteFunctions within the internal client script. This issue was caused by an incorrect design decision that subsequent calls to a pending RemoteFunction should return the result of the first pending invocation. In other words, if a RemoteFunction was invoked 5 times at the exact same time, each invocation would return the result of the _first_ invocation.

This faulty design has been reverted to the old behavior from before v1.5.1, which guarantees that each invocation of a RemoteFunction is unique.

#### <a name="1.5.1"></a> Version 1.5.1
Added [Quenty's](https://github.com/Quenty) Maid class. This class allows for easy cleanup of tasks.

Also fixed many small bugs and made minor improvements throughout the framework.

#### <a name="1.5.0"></a> Version 1.5.0
Added a new Data module, which replaces the older DataStoreService. The new Data module gives developers more robust control over data, including improved error handling due to the module using promises.

<b>==[BC Break]==</b> The DataStoreService and its dependencies have been removed. The Data module is the official replacement. The DataStoreService had many flaws and could introduce developers into tricky situations that caused data losses due to unknown data failures.

Added a Thread module under Shared. This module should be used instead of the built-in global functions `spawn` and `delay`. Both the `spawn` and `delay` functions are known to throttle unexpectedly. Such behavior is unacceptable, and thus the Thread module aims at giving alternatives to both functions. The use of the Thread's `Thread.Spawn` and `Thread.Delay` functions can easily be dropped in to replace any existing `spawn` and `delay` code. The module also contains a `Thread.SpawnNow` function, which will spawn a new thread immediately, as opposed to the next frame. In addition, the `Thread.Delay` returns the heartbeat connection, which means that the delay can be cancelled by disconnecting the connection.

#### <a name="1.4.1"></a> Version 1.4.1
Fixed an issue with lazy-loaded modules. Before, lazy-loaded modules could break the execution lifecycle rule if loaded within the `Init` method of a service or controller. When this happened, the `Init` _and_ `Start` method would execute within the loaded module. This is a problem, since `Start` should not be executed yet. This is now fixed. The `Start` method will be held off from execution until the proper time within the framework lifecycle.

A new optional field has been added called `__aeroOrder`. Setting this field to a number will define the `Init` execution order for the service or controller. The order is interpreted in ascending order. In other words, a service with an order of `1` will be guaranteed to initialize before a service with the order of `2`. Services and controllers that don't define `__aeroOrder` will default to an order of `math.huge`, which simply makes them executed last, but in no particular order otherwise.

#### <a name="1.4.0"></a> Version 1.4.0
Added `service:FireAllClientsEventExcept(eventName, player, ...)`, which allows firing client events for all clients except the given player. One use-case for this is to implement custom replication, where a player's action needs to be communicated to the other players.

The origin AGF plugin for Roblox Studio is now deprecated in favor of the VS Code extension.

The documentation site has been rebuilt using MkDocs, which will enable easier additions, edits, and contributions.

#### <a name="1.3.0"></a> Version 1.3.0
Restructured source directory and installer to be compatible with Rojo. For compatibility, please be sure to update the plugin as well. The older versions of the plugin are not compatible with the new directory structure, and thus will fail to install or update the framework.

#### <a name="1.2.6"></a> Version 1.2.6
Expanded the TableUtil library. Specifically, the following functions have been added:

- `TableUtil.Map(Table tbl, Function callback)`
- `TableUtil.Filter(Table tbl, Function callback)`
- `TableUtil.Reduce(Table tbl, Function callback [, Number initialValue])`
- `TableUtil.IndexOf(Table tbl, Variant item)`
- `TableUtil.Reverse(Table tbl)`
- `TableUtil.Shuffle(Table tbl)`
- `TableUtil.IsEmpty(Table tbl)`
- `TableUtil.EncodeJSON(Table tbl)`
- `TableUtil.DecodeJSON(String json)`

Examples have been added within the source code of the TableUtil module.

#### <a name="1.2.5"></a> Version 1.2.5
Added `__aeroPreventStart` and `__aeroPreventInit` flags for modules (both server and client). If the `__aeroPreventStart` flag is present for a module, then the framework will not invoke the `Start` method for that module when first loaded. Similarly, `__aeroPreventInit` will prevent the framework from invoking the `Init` method when first loaded. In summary, the two flags will prevent the default behavior of the framework calling the associated `Start` and `Init` methods. This is useful if an existing module is added to the framework that has already implemented these methods for other uses.

This change will also apply to any modules using the `WrapModule` method on either the server or client.

The above flags were added to address a bug with the `CameraShaker` module, which already had a `Start` method built into the module. This caused issues when the module was loaded. The `__aeroPreventStart` flag has been added to prevent this.

Example:
```lua
local MyModule = {}

-- Flagging to prevent the Start method:
MyModule.__aeroPreventStart = true

function MyModule:Start()
	print("The framework will not invoke this method when first loaded")
end

function MyModule:Init()
	print("Still invoked from the framework")
end
```

#### <a name="1.2.4"></a> Version 1.2.4
Instead of using `while` loops to wait for code to complete, proper usage of `coroutine.yield` and `coroutine.resume` have been implemented. This change reflects best practices on Roblox. Doing this was not possible before a recent Roblox update. The overall behavior of the code remains entirely the same.

Some deprecated code has also been fixed in the TaskScheduler. The functionality remains entirely the same.

#### <a name="1.2.3"></a> Version 1.2.3
Added the `WrapModule` method to both the AeroServer and AeroClient scripts. This method takes a `table` and will set its metatable to the same metatable used by other Aero-based modules/controllers/services. This allows you to easily integrate custom modules into the framework if needed.

Internally, this sets the metatable of the given table, and also calls the associated `Start` and `Init` methods if available.

Client example:
```lua
while (not _G.Aero) do wait() end

local Test = {}
local fade

function Test:Start()
  fade:SetText("Hello world")
  fade:Out()
  fade:In()
end

function Test:Init()
  fade = self.Controllers.Fade
end

-- Set up the table to integrate with the framework:
_G.Aero:WrapModule(Test)
```

#### <a name="1.2.2"></a> Version 1.2.2
Added Failed events for DataService. The DataService has always retried requests if DataStore calls have failed; however, it used to silently fail with a simple `warn()` if the maximum retry limit was reached. In this update, the service will now call an appropriated Failed event corresponding to the type of data call.

In order to make this function, there are also Failed events added to the internal modules used by the DataService module. This includes the DataStoreCache and SafeDataStore.

- If setting player data, then the `PlayerFailed(player, method, key, errMsg)` event will be fired, as well as the client `Failed(method, key, errMsg)` event.
- If setting global data, then the `GlobalFailed(method, key, errMsg)` event will be fired.
- If setting custom data, then the `CustomFailed(name, scope, method, key, errMsg)` event will be fired.
