[ProfileService](https://github.com/MadStudioRoblox/ProfileService) is a third-party DataStore management module provided by Mad Studio. As quoted from the GitHub page for ProfileService:

> ProfileService is a stand-alone ModuleScript that specialises in loading and auto-saving DataStore profiles.

> A DataStore Profile (Later referred to as just Profile) is a set of data which is meant to be loaded up only once inside a Roblox server and then written to and read from locally on that server (With no delays associated with talking with the DataStore every time data changes) whilst being periodically auto-saved and saved immediately once after the server finishes working with the Profile.

Please refer to the [official documentation](https://madstudioroblox.github.io/ProfileService/) for more info.

To use ProfileService in AGF, simply reference the module as such:

```lua
function MyService:Start()
	local ProfileService = self.Modules.ProfileService
end
```