# AeroGameFramework

## About

AeroGameFramework is a Roblox game framework that makes development easy and fun. The framework is designed to simplify the communication between modules and seamlessly bridge the gap between the server and client. Never again will you have to touch RemoteFunctions or RemoteEvents.

## Learning

This is the main documentation page for AGF and is the single point of information for using the framework. There is also a [YouTube tutorial](https://www.youtube.com/watch?v=0T-slvWfYkc&list=PLk3R4TM3pnqvde1cqOIH_bGnCWwMKDqKL) series available.

## Collaborate
AeroGameFramework is an open-source project, and your support is much appreciated. Feel free to report bugs, suggest features, and make pull requests. Please visit the [GitHub repository](https://github.com/Sleitnick/AeroGameFramework) for more information.

The framework was built and is supported primary by [Stephen Leitnick](https://github.com/Sleitnick).


--------------------------

## Example

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