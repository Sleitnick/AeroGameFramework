## :warning: Project is archived :warning:

AeroGameFramework is no longer maintained and should not be used in future projects. [Knit](https://github.com/Sleitnick/Knit) is the successor to AGF. Over time, it has become clear that AGF forces bad design decisions on developers and leads to a messy and fragmented code-base.

------------------

![Logo](/imgs/logo_github_readme.png)

![Lint](https://github.com/Sleitnick/AeroGameFramework/workflows/Lint/badge.svg?branch=master)

# AeroGameFramework
A powerful game framework for the Roblox platform.

AeroGameFramework is a Roblox game framework that makes development easy and fun. The framework is designed to simplify the communication between modules and seamlessly bridge the gap between the server and client. Never again will you have to touch RemoteFunctions or RemoteEvents.

Join the [Discord server](https://discord.gg/GUdNjJs) for further discussion about the framework.

# Documentation
Visit the [documentation site](https://sleitnick.github.io/AeroGameFramework).

# Video Tutorial
Visit the [AGF Tutorial](https://www.youtube.com/watch?v=0T-slvWfYkc&list=PLk3R4TM3pnqvde1cqOIH_bGnCWwMKDqKL) playlist.

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

# Support

Support AGF by [buying me a coffee](https://www.buymeacoffee.com/sleitnick) and keeping me energized to keep up the work on this project! Any support is very much appreciated.
<link href="https://fonts.googleapis.com/css?family=Lato&subset=latin,latin-ext" rel="stylesheet"><a class="bmc-button" target="_blank" href="https://www.buymeacoffee.com/sleitnick"><img src="https://cdn.buymeacoffee.com/buttons/bmc-new-btn-logo.svg" alt="Buy me a coffee"><span style="margin-left:15px;font-size:19px !important;">Buy me a coffee</span></a>
