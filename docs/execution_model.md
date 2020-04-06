# Execution Model

## Services and Controllers

Services and Controllers act as singletons. In other words, only one instance exists per service or controller in a given environment.

1. All modules are loaded using `require()` at the start of runtime.
1. All modules have properties and methods exposed via metamethods.
1. Each `Init` method on the modules are invoked one-by-one synchronously.
1. Each `Start` method on the modules are invoked asynchronously.
1. The module remains in memory for the remainder of runtime.

--------------------------

## Modules and Shared

1. A module (in Modules or Shared) is loaded using `require()` the first time it is referenced (e.g. lazy-loaded).
1. The module has properties and methods exposed via metatable (using `WrapTable`)
1. The module's `Init` method is invoked synchronously.
1. The module's `Start` method is invoked immediately and asynchronously after the `Init` method is completed.

--------------------------

## Forcing `Init` Order

The order of which `Init` is invoked for services and controllers can be explicitly set. This is done through the `__aeroOrder` field.

Simply set the service or controller `__aeroOrder` field to a number. The `Init` process will execute based on ascending order. Services and controllers without an `__aeroOrder` field set will be executed last (technically, the default order is set to `math.huge`).

!!! note
	The `__aeroOrder` field can be any valid number, including negatives and non-whole numbers. See the examples under the [Services](services.md#forcing-init-order) and [Controllers](controllers.md#forcing-init-order) page.

--------------------------

## Preventing `Init` or `Start`

There might be times where it is not desired for the framework to invoke either the `Start` or the `Init` method on a module, service, or controller. In such an instance, a flag can be added to indicate that the method should not be invoked by the framework.

The two flags are:

- `__aeroPreventInit`
- `__aeroPreventStart`

!!! note
	Set the flag to a truthy value (preferrably just `true`). See the example under the [Modules](modules.md#prevent-init-or-start) page.

--------------------------

## External Use

It is possible (but not recommended) to use AGF outside of the framework environment. In other words, a script within the workspace can access modules within the framework. This is useful if an existing script or system cannot be included into the framework, but needs to access items within the framework. In order to do this the `_G.Aero` global is exposed on both the server and the client.

Accessing `_G.Aero` from the server will allow access to server-side services and modules, as well as shared modules.

Accessing `_G.Aero` from the client will allow access to client-side controllers and modules, as well as shared modules.

### Wait for External Aero
Because `_G.Aero` is not assigned until the framework has fully initialized, external scripts must first check and wait for the global to be assigned before attempting to use it:
```lua
while (not _G.Aero) do wait() end
local aero = _G.Aero
```

### Use External Aero from Server
Once `aero` is referenced, it can be used the same way you would use `self` within a controller or service. For example, using `_G.Aero` from the server:
```lua
while (not _G.Aero) do wait() end
local aero = _G.Aero

aero.Services.MyService:Hello()
local maid = aero.Shared.Maid.new()
```

### Use External Aero from Client
Using `aero` from the client is the same as the server, except access will be granted to client-side modules:
```lua
while (not _G.Aero) do wait() end
local aero = _G.Aero

aero.Controllers.Fade:Out()
local date = aero.Shared.Date.new()
```

!!! warning
	Using AGF externally using `_G.Aero` is considered bad practice. The global is only provided so that edge-cases can be filled where it is not possible to include a script or system into the framework.

--------------------------

## Notes and Best Practices

- The `Init` and `Start` methods are always optional, but it is good practice to always include them.
- The `Init` method should be used to set up the individual module and register events.
- The `Init` method should try to do as minimal work as possible, as other modules are blocked until it is completed.
- The `Init` method should not be used to invoke methods from other modules in the framework (that should be done in or after `Start`)
- Events must be registered in the `Init` method.
- Events should never be connected or fired within the `Init` method. Do this within the `Start` method.
- Because Modules and Shared modules are lazy-loaded, their `Init` methods are invoked the first time they are referenced.