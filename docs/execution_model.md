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

## Preventing `Init` or `Start`

There might be times where it is not desired for the framework to invoke either the `Start` or the `Init` method on a module, service, or controller. In such an instance, a flag can be added to indicate that the method should not be invoked by the framework.

The two flags are:

- `__aeroPreventInit`
- `__aeroPreventStart`

!!! note
	Set the flag to a truthy value (preferrably just `true`). See the example under the [Modules](modules.md#prevent-init-or-start) page.

--------------------------

## Notes and Best Practices

- The `Init` and `Start` methods are always optional, but it is good practice to always include them.
- The `Init` method should be used to set up the individual module and register events.
- The `Init` method should try to do as minimal work as possible, as other modules are blocked until it is completed.
- The `Init` method should not be used to invoke methods from other modules in the framework (that should be done in or after `Start`)
- Events must be registered in the `Init` method.
- Events should never be connected or fired within the `Init` method. Do this within the `Start` method.
- Because Modules and Shared modules are lazy-loaded, their `Init` methods are invoked the first time they are referenced.