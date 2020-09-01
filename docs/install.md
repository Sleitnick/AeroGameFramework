# Install & Setup

The preferred editor for the AeroGameFramework is [Visual Studio Code](https://code.visualstudio.com/). AeroGameFramework includes a VS Code extension, and ties in with other useful extensions & plugins (such as Rojo and Selene).

--------------------------

## Requirements

| Name | Description | Required |
| ---- | ----------- | -------- |
| [AeroGameFramework](https://marketplace.visualstudio.com/items?itemName=aerogameframework-vsce.aerogameframework) | Main VS Code extension | Yes |
| [Rojo](https://rojo.space/docs/installation/) | Sync files between VS Code and Roblox Studio | Yes |
| [Rojo for VS Code](https://marketplace.visualstudio.com/items?itemName=evaera.vscode-rojo) | Use and manage Rojo directly from VS Code | No |
| [Selene](https://kampfkarren.github.io/selene/) | Static analyzer and linter for Lua | No |
| [Selene for VS Code](https://marketplace.visualstudio.com/items?itemName=Kampfkarren.selene-vscode) | Static analyzer and linter for Lua | No |

--------------------------

## Project Setup

1. Created a new directory for your project
1. Open the directory within VS Code (`File > Open Folder...`)
1. From the command panel (`Ctrl+Shift+P`), run `AeroGameFramework: Init`
1. If using the Rojo VS Code extension, restart VS Code
1. Enable HTTP requests within your Roblox game settings
1. Start Rojo and run the Rojo plugin within Roblox Studio
	- If not using the Rojo VS Code extension, run `rojo serve`

--------------------------

## Directory Structure

- `src`: Source files
	- `Client`: Client-side code
		- `Controllers`: Client-side singleton controllers
		- `Modules`: Lazy-loaded plain modules
	- `Server`: Server-side code
		- `Services`: Server-side singleton services
		- `Modules`: Lazy-loaded plain modules
	- `Shared`: Lazy-loaded plain modules shared between the client and server
- `_framework`: Internal framework source files (Hidden within VS Code by default)

!!! note
	The `rojo.json` and `default.project.json` files are specifically configured to work with the directory structure described above. Changing the structure may break Rojo from properly syncing changes into Roblox Studio.

--------------------------

## AGF Treeview

The VS Code extension for AeroGameFramework provides a simplified directory hierarchy that will only show the source files that should be edited. In other words, it hides all of the files that you do not need to worry about. This view can be selected from the "AGF" icon on the left-hand panel in VS Code.

--------------------------

## Creating new source files (Services, Controllers, and Modules)

1. Right-click within the AGF Treeview and click on `AeroGameFramework: Create` from the context menu, _or_ click the Script Add button at the top
1. Select whether the source file should exist within the Server, Client, or Shared environment
1. Select the source type (e.g. Service, Controller, or Module)
1. Type in the name and press Enter

!!! tip
	If you right-click within given directories, the extension will automatically assume the desired file type. For instance, if you right-click on Services and click Create, the extension will immediately prompt for a new service name.

!!! tip
	If you right-click and click Create on an existing source file, you can create nested modules within the existing file. This will automatically create the necessary Rojo structure. Please note that nested modules do not get consumed by the framework and must be required manually.

!!! note
	When creating a Module, a prompt will show up to choose between a Plain Module and a Class Module. A Plain Module is just a typical ModuleScript with an empty table defined. A Class Module contains the necessary boilerplate code for basic OOP modules.

--------------------------

## Roblox Structure

AeroGameFramework is structured into three major categories: Server, Client, and Shared.

| Environment | Location                    | Description                                  |
| ----------- | --------------------------- | -------------------------------------------- |
| Server      | `ServerStorage.Aero`        | Server-side code                             |
| Client      | `StarterPlayerScripts.Aero` | Client-side code                             |
| Shared      | `ReplicatedStorage.Aero`    | Shared modules between the server and client |

!!! note
	If developing within Visual Studio Code, these folders should be left untouched within Roblox Studio to prevent any unexpected data loss due to Rojo syncing.