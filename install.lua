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
	local parentCreated = false
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
			parentCreated = false
		else
			local newParent = parent:FindFirstChild(parentName)
			if (newParent) then
				parentCreated = false
			else
				parentCreated = true
				newParent = Instance.new("Folder", parent)
				newParent.Name = parentName
			end
			parent = newParent
		end
	end
	return parent, parentCreated
end

local numPaths = #filelist.paths
for i,path in pairs(filelist.paths) do
	local sourceUrl = (filelist.url .. path)
	local isEmpty = (path:match("/EMPTY$") ~= nil)
	local parent, parentCreated = BuildParent(path)
	local scriptObj
	local wasUpdated = false
	local wasAlreadyExistent = false
	local printPrefix = "[NEW]"
	if (not isEmpty) then
		local source = http:GetAsync(sourceUrl, true)
		local scriptName, scriptType = path:match(".+[/%.](.+)%.(.+)%.lua$")
		local className = (scriptType == "localscript" and "LocalScript" or scriptType == "modulescript" and "ModuleScript" or "Script")
		local obj = parent:FindFirstChild(scriptName)
		if ((not obj) or (obj.ClassName ~= className)) then
			scriptObj = Instance.new(className, parent)
			scriptObj.Name = scriptName
			scriptObj.Source = source
		elseif (obj and obj.ClassName == className) then
			scriptObj = obj
			if (scriptObj.Source ~= source) then
				scriptObj.Source = source
				wasUpdated = true
			else
				wasAlreadyExistent = true
			end
		end
		printPrefix = (wasUpdated and "[UPDATED]" or wasAlreadyExistent and "[EXISTED]" or "[NEW]")
	else
		if (not parentCreated) then
			printPrefix = "[EXISTED]"
		end
	end
	print(("[%i/%i]"):format(i, numPaths), printPrefix, (scriptObj or parent):GetFullName())
end

http.HttpEnabled = httpEnabled

print("AeroGameFramework installed")