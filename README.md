![Logo](/imgs/logo_256.png)

# AeroGameFramework
A powerful game framework for the Roblox platform.

AeroGameFramework is a Roblox game framework that makes development easy and fun. The framework is designed to simplify the communication between modules and seamlessly bridge the gap between the server and client. Never again will you have to touch RemoteFunctions or RemoteEvents.

# Documentation
The [documentation website](https://sleitnick.github.io/AeroGameFramework) is currently under development. Until completion, please refer to [old doc](/doc) files & this readme file.

# Video Tutorial
Learn how to use the framework in the video tutorial series:
https://www.youtube.com/watch?v=8ta0cHX1ceE&index=1&list=PLk3R4TM3pnqv7doCTUHtn-wkydaA08npc

**Note:** This tutorial series does not use the newer VS Code extension workflow. An updated series is in the works.

# Example

Here is an example of a client-side controller invoking a server-side service to respawn the player. Notice that no remote objects have to be explicitly referenced:

```lua
-- Client:
local MyController = {}

function MyController:Start()
	local didRespawn = self.Services.MyService:Respawn()
	if (didRespawn) then
		...
	end
end

return MyController
```

```lua
-- Server:
local MyService = {Client = {}}

function MyService.Client:Respawn(player)

	local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")

	-- Only allow respawning if the player is dead:
	if ((not humanoid) or humanoid.Health == 0) then
		player:LoadCharacter()
		return true
	end

	return false

end

return MyService
```

These are complete code examples. They could be put into the framework and work as-is.