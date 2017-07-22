# AeroGameFramework
A game framework for the ROBLOX game platform.

AeroGameFramework makes ROBLOX game development easy and fun. The framework is designed to alleviate the strain of communication between your code and to simplify communication between the server/client model.

AeroGameFramework is structured into three categories: Server, Client, and Shared.

## Server
`ServerStorage.Services` & `ServerStorage.Objects`

#### Services
Services are modules that are initialized and ran at runtime. All services are exposed to each other. Services can also expose functions and events to the client.

#### Objects
Objects are lazy-loaded modules that services can access as needed.

## Client
`StarterPlayerScripts.Modules` & `StarterPlayerScripts.Objects`

#### Modules
Client modules work similarly to server-side services, whereas all the modules are initialized and started at runtime and all modules are exposed to each other. Services that expose client-side methods and events can be accessed with these modules.

#### Objects
Client-side objects have the exact functionality as server-side objects, except that they are ran on the client.

# Install & Update
Run the following code snippet in the Command Line within ROBLOX Studio to install or update the framework:
```lua
require(932606289)()
```
