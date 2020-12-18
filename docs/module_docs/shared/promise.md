AGF uses [evaera's Promise implementation](https://github.com/evaera/roblox-lua-promise). See the [documentation](https://eryn.io/roblox-lua-promise/lib/) for that implementation.

A few modifications have been made to the Promise object for AGF. Most notably, PascalCase mappings have been added for all public methods, as well as simplified versions. For instance, the `andThen` method has a mapping to both `AndThen` as well as `Then`. This has been done to match the PascalCase styling of AGF.

The below documentation favors the PascalCase methods. However, the original camelCase methods still exist.

--------------------

## Static Methods

### [`Promise.new(Function callback)`](https://eryn.io/roblox-lua-promise/lib/#new)
Create a new promise object. The callback receives a 'resolve', 'reject', and `onCancel` function that can then be called within the function. Call `resolve` when the task has completed successfully. Call `reject` if something went wrong.

Optionally, pass an cancellation handler to the `onCancel` function, which will be called if the promise gets cancelled. This can be used to stop whatever task is occurring within the promise. Read the [official documentation](https://eryn.io/roblox-lua-promise/lib/#new) for more information.

```lua
local promise = Promise.new(function(resolve, reject, onCancel)
	if thisThingWorked() then
		resolve()
	else
		reject("It didn't work")
	end
end)
```

--------------------

### [`Promise.Defer(Function callback)`](https://eryn.io/roblox-lua-promise/lib/#promisify)
Same as `Promise.new`, but will begin execution after a `Heartbeat` event.

--------------------

### [`Promise.Promisify(Function callback)`](https://eryn.io/roblox-lua-promise/lib/#promisify)
Creates a promise wrapper for a yielding function.

--------------------

### [`Promise.Resolve(...)`](https://eryn.io/roblox-lua-promise/lib/#resolve)
Creates an immediately-resolved promise with the given value.

--------------------

### [`Promise.Reject(...)`](https://eryn.io/roblox-lua-promise/lib/#reject)
Creates an immediately-rejected promise with the given value.

--------------------

### [`Promise.Try(...)`](https://eryn.io/roblox-lua-promise/lib/#try)
Starts a promise chain and turns synchronous errors into rejections.

--------------------

### [`Promise.All(Table promises)`](https://eryn.io/roblox-lua-promise/lib/#all)
Creates a new promise with a list of other promises. It is resolved once all promises in the table are resolved, and is rejected if even one of the promises is rejected. This is a great method when multiple requests need to be made at the same time but do not depend on each other.

--------------------

### [`Promise.AllSettled(Table promises)`](https://eryn.io/roblox-lua-promise/lib/#allsettled)
Creates a new promise with a list of other promises. It is resolved once all promises in the table are settled (i.e. after all `Finally` calls on each promise have been made).

--------------------

### [`Promise.Race(Table promises)`](https://eryn.io/roblox-lua-promise/lib/#race)
Resolves or rejects on the first promise to resolve or reject. All other promises will be cancelled.

--------------------

### [`Promise.Some(Table promises, Number amount)`](https://eryn.io/roblox-lua-promise/lib/#some)
Resolves once the `amount` number of promises have resolved. All other promises will be cancelled.

--------------------

### [`Promise.Any(Table promises)`](https://eryn.io/roblox-lua-promise/lib/#any)
Resolves if any of the promises resolve, and will reject if all promises are rejected. All other promises will be cancelled.

--------------------

### [`Promise.Delay(Number seconds)`](https://eryn.io/roblox-lua-promise/lib/#delay)
Creates a promise that resolves after the number of seconds has elapsed.

--------------------

### [`Promise.Each(Table promises, Function predicate)`](https://eryn.io/roblox-lua-promise/lib/#each)

--------------------

### [`Promise.Retry(callback, numRetries)`](https://eryn.io/roblox-lua-promise/lib/#retry)
The callback is a function that returns a Promise. It will continue to call the callback `numRetries` times until the promise resolves. If the amount of times exceeds `numRetries`, then the last rejected promise will be returned.

--------------------

### [`Promise.FromEvent(event [, predicate])`](https://eryn.io/roblox-lua-promise/lib/#fromevent)
Wraps an event with a Promise which is resolved the next time the event is fired.

--------------------

### [`Promise.Is(Any object)`](https://eryn.io/roblox-lua-promise/lib/#is)
Checks to see if the passed object is a Promise.

--------------------

## Object Methods

### [`Then(Function success, Function failure)`](https://eryn.io/roblox-lua-promise/lib/#andthen)

--------------------

### [`Catch(Function failure)`](https://eryn.io/roblox-lua-promise/lib/#catch)

--------------------

### [`Tap(Function tap)`](https://eryn.io/roblox-lua-promise/lib/#tap)

--------------------

### [`Finally(Function finally)`](https://eryn.io/roblox-lua-promise/lib/#finally)

--------------------

### [`Done(Function done)`](https://eryn.io/roblox-lua-promise/lib/#done)

--------------------

### [`ThenCall(Function callback, ...)`](https://eryn.io/roblox-lua-promise/lib/#andthen)

--------------------

### [`FinallyCall(Function callback, ...)`](https://eryn.io/roblox-lua-promise/lib/#finallycall)

--------------------

### [`DoneCall(Function callback, ...)`](https://eryn.io/roblox-lua-promise/lib/#donecall)

--------------------

### [`ThenReturn(...)`](https://eryn.io/roblox-lua-promise/lib/#thenreturn)

--------------------

### [`FinallyReturn(...)`](https://eryn.io/roblox-lua-promise/lib/#finallyreturn)

--------------------

### [`DoneReturn(...)`](https://eryn.io/roblox-lua-promise/lib/#donereturn)

--------------------

### [`Timeout(Number seconds, Variant timeoutValue)`](https://eryn.io/roblox-lua-promise/lib/#timeout)

--------------------

### [`Cancel()`](https://eryn.io/roblox-lua-promise/lib/#cancel)

--------------------

### [`Await()`](https://eryn.io/roblox-lua-promise/lib/#await)

--------------------

### [`AwaitStatus()`](https://eryn.io/roblox-lua-promise/lib/#awaitstatus)

--------------------

### [`Expect(...)`](https://eryn.io/roblox-lua-promise/lib/#expect)

--------------------

### [`GetStatus()`](https://eryn.io/roblox-lua-promise/lib/#getstatus)

--------------------

## Properties

### [Status](https://eryn.io/roblox-lua-promise/lib/#status)
The PromiseStatus of the promise

## Types

### [PromiseStatus](https://eryn.io/roblox-lua-promise/lib/#promisestatus)
Possible values: Started, Resolved, Rejected, Cancelled