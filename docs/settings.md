# Settings

In some scenarios, it is useful to override the default AGF behavior on modules, such as preventing the framework from invoking `Start` or `Init`. This can be done by creating a `.settings` ModuleScript alongside the service, controller, or module.

--------------------------

## Settings Module

For instance, if there is a controller named `MyController`, its accompanying settings file would be named `MyController.settings`.

Each settings file should return a table like shown:

```lua
return {
	Order = 1000;
	PreventInit = false;
	PreventStart = false;
	Standalone = false;
}
```

The fields above are defined as such:

| Field | Default | Description |
| ----- | ------- | ----------- |
| Order | `1000` | The `Init` execution order for services and controllers |
| PreventInit | `false` | Will prevent calling `Init` on any module with this field as `true` (does not apply to services/controllers) |
| PreventStart | `false` | Will prevent calling `Start` on any module with this field as `true` (does not apply to services/controllers) |
| Standalone | `false` | Will treat a module as a plain standalone module and won't inject any AGF information (useful for third-party modules) |

!!! note
	Each field is optional. If the field is not provided, or if no `.settings` module is found, then the default values will be used instead.

--------------------------

## Third-Party Modules
When using third-party modules within AGF, it is recommended to use `Standalone` mode. To do this, make an accompanying `.settings` file (e.g. `DataStore2.settings` or `Roact.settings`) with the following configuration:

```lua
return {Standalone = true}
```

--------------------------

## In-Depth

### Order
The execution order for `Init` within services and controllers. By default, this is set to `1000`. This number is simply utilized to sort the services/controllers before invoking each `Init` method, so any valid number within Lua can be used. In most scenarios, the execution order will not matter and this setting can be ignored. In some other edge-cases, it's crucial for certain modules to be initialized before others. In such edge-cases, this setting should be used to guarantee order.

### PreventInit
This flag will allow the `Init` method to be skipped within modules. This will _not_ work for services or controllers. The purpose of this flag is to allow third-party modules to tie into AGF that might already have an `Init` method for other purposes. This value should be either `true` or `false`. The default value is `false`.

### PreventStart
This flag will allow the `Start` method to be skipped within modules. This will _not_ work for services or controllers. The purpose of this flag is to allow third-party modules to tie into AGF that might already have an `Start` method for other purposes. This value should be either `true` or `false`. The default value is `false`.

### Standalone
This flag will prevent AGF from wrapping the module with the AGF metatable. This should be used when using third-party modules such as DataStore2 and Roact.