# Execution Model

## Services and Controllers
1. All modules loaded using `require()` at the start of runtime.
2. All modules have properties and methods "injected" via metatable.
3. Each `Init` method on the modules are invoked one-by-one synchronously.
4. Each `Start` method on the modules are invoked asynchronously.
5. The module remains in memory for the remainder of runtime.

## Modules and Shared
1. A module (in Modules or Shared) is loaded using `require()` the first time it is referenced (i.e. lazy-loaded).
2. The module has properties and methods "injected" via metatable.
3. The module's `Init` method is invoked.
4. The module's `Start` method is invoked immediately after the `Init` method is completed.
5. The module remains in memory for the remainder of runtime.

-----------------------------------------

### Notes and Best Practice

- The `Init` and `Start` methods are always optional, but it is good practice to always include them.
- The `Init` method should be used to set up the individual module.
- The `Init` method should _not_ be used to invoke methods from other modules in the framework.
- Events must be registered in the `Init` method.
- Events should _never_ be connected or fired within the `Init` method.
- Because Modules and Shared modules are lazy-loaded, their `Init` methods are executed after other modules have been started.