-- Aero Install
-- Crazyman32
-- July 22, 2017



local FILELIST_URL = "https://raw.githubusercontent.com/Sleitnick/AeroGameFramework/master/filelist.json"

print("Installing AeroGameFramework...")

local http = game:GetService("HttpService")
local httpEnabled = http.HttpEnabled
http.HttpEnabled = true

workspace.FilteringEnabled = true

local filelist = http:JSONDecode(http:GetAsync(FILELIST_URL, true))

function BuildParent(path)
	local parent = game
	for parentName in path:gmatch("[^/]+") do
		if (parentName == "EMPTY") then
			break
		end
		if (parentName:match(".lua$")) then
			local name = parentName:match("(.+)%..+%.lua")
			local subItems = {}
			for itemName in name:gmatch("[^%.]+") do
				table.insert(subItems, itemName)
			end
			table.remove(subItems, #subItems)
			for _,subItem in pairs(subItems) do
				parent = parent[subItem]
			end
			break
		end
		if (parent == game) then
			parent = game:GetService(parentName)
		else
			local newParent = parent:FindFirstChild(parentName)
			if (not newParent) then
				newParent = Instance.new("Folder", parent)
				newParent.Name = parentName
			end
			parent = newParent
		end
	end
	return parent
end

local numPaths = #filelist.paths
for i,path in pairs(filelist.paths) do
	local sourceUrl = (filelist.url .. path)
	local isEmpty = (path:match("/EMPTY$") ~= nil)
	local parent = BuildParent(path)
	local scriptObj
	if (not isEmpty) then
		local source = http:GetAsync(sourceUrl, true)
		local scriptName, scriptType = path:match(".+[/%.](.+)%.(.+)%.lua$")
		if (scriptType == "script") then
			scriptObj = Instance.new("Script", parent)
		elseif (scriptType == "localscript") then
			scriptObj = Instance.new("LocalScript", parent)
		elseif (scriptType == "modulescript") then
			scriptObj = Instance.new("ModuleScript", parent)
		end
		scriptObj.Name = scriptName
		scriptObj.Source = source
	end
	print(("[%i/%i]"):format(i, numPaths), (scriptObj or parent):GetFullName())
end

http.HttpEnabled = httpEnabled

print("AeroGameFramework installed")