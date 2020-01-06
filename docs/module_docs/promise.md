AGF uses [evaera's Promise implementation](https://github.com/evaera/roblox-lua-promise). See the [documentation](https://eryn.io/roblox-lua-promise/lib/) for that implementation.

A few modifications have been made to the Promise object for AGF. Most notably, PascalCase mappings have been added for all public methods, as well as simplified versions. For instance, the `andThen` method has a mapping to both `AndThen` as well as `Then`. This has been done to match the PascalCase styling of AGF.

The below documentation favors the PascalCase methods. However, the original camelCase methods still exist.

--------------------

## Static Methods

### [`Promise.new(Function callback)`](https://eryn.io/roblox-lua-promise/lib/#new)
Create a new promise object. The callback receives a 'resolve' and 'reject' function that can then be called within the function.

```lua
local promise = Promise.new(function(resolve, reject)
	if thisThingWorked() then
		resolve()
	else
		reject("It didn't work")
	end
end)
```

--------------------

### [`Promise.Async(Function callback)`](https://eryn.io/roblox-lua-promise/lib/#async)
This is the same as `Promise.new`, except that it allows yielding, and thus should be used if the promise body needs to yield at all.

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

### [`Promise.Some(Table promises, Number amount)`](https://eryn.io/roblox-lua-promise/lib/#some)

--------------------

### [`Promise.Any(Table promises)`](https://eryn.io/roblox-lua-promise/lib/#any)

--------------------

### [`Promise.AllSettled(Table promises)`](https://eryn.io/roblox-lua-promise/lib/#allsettled)

--------------------

### [`Promise.Race(Table promises)`](https://eryn.io/roblox-lua-promise/lib/#race)

--------------------

### [`Promise.Is(Table object)`](https://eryn.io/roblox-lua-promise/lib/#is)

--------------------

### [`Promise.Delay(Number seconds)`](https://eryn.io/roblox-lua-promise/lib/#delay)

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

### [`ThenCall(Funciton callback, ...)`](https://eryn.io/roblox-lua-promise/lib/#andthen)

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