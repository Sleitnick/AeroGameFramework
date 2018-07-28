-- Aero Install
-- Stephen Leitnick
-- July 22, 2017



local FILELIST_URL = "https://raw.githubusercontent.com/Sleitnick/AeroGameFramework/master/filelist.json"
local VERSION_URL = "https://raw.githubusercontent.com/Sleitnick/AeroGameFramework/master/version.txt"
local VERSION_OBJ_NAME = "__version__"

if (_G._INSTALLING_AEROGAMEFRAMEWORK_) then
	warn("Installation already in progress")
	return
end
_G._INSTALLING_AEROGAMEFRAMEWORK_ = true

local http = game:GetService("HttpService")
local httpEnabled = http.HttpEnabled
http.HttpEnabled = true

workspace.FilteringEnabled = true


function BuildUI()

	local partsWithId = {}
	local awaitRef = {}

	local root = {
		ID = 0;
		Type = "ScreenGui";
		Properties = {
			ResetOnSpawn = false;
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
			Name = "AeroInstallGui";
			DisplayOrder = 10;
		};
		Children = {
			{
				ID = 1;
				Type = "Frame";
				Properties = {
					AnchorPoint = Vector2.new(0.5,0.5);
					Name = "InstallerStatus";
					Position = UDim2.new(0.5,0,0.5,0);
					Size = UDim2.new(0,250,0,100);
					BorderSizePixel = 0;
					BackgroundColor3 = Color3.new(0.29019609093666,0.29019609093666,0.29019609093666);
				};
				Children = {
					{
						ID = 2;
						Type = "UIPadding";
						Properties = {
							PaddingBottom = UDim.new(0,5);
							PaddingTop = UDim.new(0,5);
							PaddingLeft = UDim.new(0,5);
							PaddingRight = UDim.new(0,5);
						};
						Children = {};
					};
					{
						ID = 3;
						Type = "TextLabel";
						Properties = {
							FontSize = Enum.FontSize.Size24;
							TextColor3 = Color3.new(0.94117653369904,0.94117653369904,0.94117653369904);
							Text = "AeroGameFramework";
							Font = Enum.Font.SourceSansBold;
							Name = "Title";
							BackgroundTransparency = 1;
							Size = UDim2.new(1,0,0,30);
							TextSize = 24;
							BackgroundColor3 = Color3.new(1,1,1);
						};
						Children = {};
					};
					{
						ID = 4;
						Type = "Frame";
						Properties = {
							AnchorPoint = Vector2.new(0,1);
							Name = "ProgressBar";
							Position = UDim2.new(0,0,1,0);
							Size = UDim2.new(1,0,0,20);
							BorderSizePixel = 0;
							BackgroundColor3 = Color3.new(0.94117653369904,0.94117653369904,0.94117653369904);
						};
						Children = {
							{
								ID = 5;
								Type = "Frame";
								Properties = {
									Size = UDim2.new(0.25,0,1,0);
									Name = "Progress";
									BorderSizePixel = 0;
									BackgroundColor3 = Color3.new(0.21568629145622,0.66666668653488,0.49411767721176);
								};
								Children = {};
							};
							{
								ID = 6;
								Type = "TextLabel";
								Properties = {
									FontSize = Enum.FontSize.Size14;
									TextColor3 = Color3.new(0.94117653369904,0.94117653369904,0.94117653369904);
									Text = "Item";
									Font = Enum.Font.SourceSans;
									Name = "Label";
									TextXAlignment = Enum.TextXAlignment.Left;
									BackgroundTransparency = 1;
									Size = UDim2.new(1,0,0,-25);
									TextSize = 14;
									BackgroundColor3 = Color3.new(1,1,1);
								};
								Children = {};
							};
							{
								ID = 7;
								Type = "TextLabel";
								Properties = {
									FontSize = Enum.FontSize.Size14;
									TextColor3 = Color3.new(0.94117653369904,0.94117653369904,0.94117653369904);
									Text = "0%";
									Font = Enum.Font.SourceSans;
									Name = "Percent";
									TextXAlignment = Enum.TextXAlignment.Right;
									BackgroundTransparency = 1;
									Size = UDim2.new(1,0,0,-25);
									TextSize = 14;
									BackgroundColor3 = Color3.new(1,1,1);
								};
								Children = {};
							};
						};
					};
				};
			};
		};
	};

	local function Scan(item, parent)
		local obj = Instance.new(item.Type)
		if (item.ID) then
			local awaiting = awaitRef[item.ID]
			if (awaiting) then
				awaiting[1][awaiting[2]] = obj
				awaitRef[item.ID] = nil
			else
				partsWithId[item.ID] = obj
			end
		end
		for p,v in pairs(item.Properties) do
			if (type(v) == "string") then
				local id = tonumber(v:match("^_R:(%w+)_$"))
				if (id) then
					if (partsWithId[id]) then
						v = partsWithId[id]
					else
						awaitRef[id] = {obj, p}
						v = nil
					end
				end
			end
			obj[p] = v
		end
		for _,c in pairs(item.Children) do
			Scan(c, obj)
		end
		obj.Parent = parent
		return obj
	end

	return Scan(root, nil)

end


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
				newParent = Instance.new("Folder")
				newParent.Name = parentName
				newParent.Parent = parent
			end
			parent = newParent
		end
	end
	return parent, parentCreated
end


function Install()

	local gui = BuildUI()
	local uiProgress = gui.InstallerStatus.ProgressBar.Progress
	local uiLabel = gui.InstallerStatus.ProgressBar.Label
	local uiPercent = gui.InstallerStatus.ProgressBar.Percent
	gui.Parent = game:GetService("CoreGui")
	gui.Archivable = false

	local numPaths = 1
	local version

	-- Update local version in-game:
	local function UpdateVersion()
		local aero = game:GetService("ServerStorage"):FindFirstChild("Aero")
		if (aero) then
			local versionObj = aero:FindFirstChild(VERSION_OBJ_NAME)
			if ((not versionObj) or (not versionObj:IsA("StringValue"))) then
				versionObj = Instance.new("StringValue")
				versionObj.Name = VERSION_OBJ_NAME
				versionObj.Parent = aero
			end
			versionObj.Value = version
		end
	end

	-- Update installer UI:
	local function UpdateUI(numCompleted, item)
		uiProgress.Size = UDim2.new((numCompleted / numPaths), 0, 1, 0)
		uiLabel.Text = (numCompleted == numPaths and "Installation completed" or (item or ""))
		uiPercent.Text = ("%i%%"):format((numCompleted / numPaths) * 100)
	end
	UpdateUI(0, "Fetching framework metadata...")

	-- Main installation process:
	local success, err = pcall(function()

		version = http:GetAsync(VERSION_URL, true)

		local filelist = http:JSONDecode(http:GetAsync(FILELIST_URL, true))
		numPaths = #filelist.paths

		-- Fetch and construct each file:
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
					scriptObj = Instance.new(className)
					scriptObj.Name = scriptName
					scriptObj.Source = source
					scriptObj.Parent = parent
				elseif (obj and obj.ClassName == className) then
					scriptObj = obj
					if (scriptObj.Source ~= source && obj.Name ~= "AeroLoad") then
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
			UpdateUI(i, printPrefix .. " " .. (scriptObj or parent).Name)
		end

	end)

	if (success) then
		UpdateUI(numPaths)
		UpdateVersion()
	else
		uiProgress.BackgroundColor3 = Color3.fromRGB(255, 85, 127)
		uiProgress.Size = UDim2.new(1, 0, 1, 0)
		uiLabel.Text = "Installation failed (see output for error)"
		uiPercent.Text = ""
		warn("AeroGameFramework failed to install: " .. tostring(err))
		wait(5)
	end

	delay(3, function()
		gui:Destroy()
	end)

end


Install()
http.HttpEnabled = httpEnabled
_G._INSTALLING_AEROGAMEFRAMEWORK_ = nil
