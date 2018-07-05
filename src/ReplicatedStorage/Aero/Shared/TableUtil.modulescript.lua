-- Table Util
-- Crazyman32
-- September 13, 2017

--[[
	
	TableUtil.Copy(tbl)
	TableUtil.Sync(tbl, templateTbl)
	TableUtil.Print(tbl, label, deepPrint)
	TableUtil.FastRemove(tbl, index)
	
--]]



local TableUtil = {}


function CopyTable(t)
	local tCopy = {}
	for k,v in pairs(t) do
		if (type(v) == "table") then
			tCopy[k] = CopyTable(v)
		else
			tCopy[k] = v
		end
	end
	return tCopy
end


function Sync(tbl, templateTbl)
	
	-- If 'tbl' has something 'templateTbl' doesn't, then remove it from 'tbl'
	-- If 'tbl' has something of a different type than 'templateTbl', copy from 'templateTbl'
	-- If 'templateTbl' has something 'tbl' doesn't, then add it to 'tbl'
	for k,v in pairs(tbl) do
		
		local vTemplate = templateTbl[k]
		
		-- Remove keys not within template:
		if (vTemplate == nil) then
			tbl[k] = nil
			
		-- Synchronize data types:
		elseif (type(v) ~= type(vTemplate)) then
			if (type(vTemplate) == "table") then
				tbl[k] = CopyTable(vTemplate)
			else
				tbl[k] = vTemplate
			end
		
		-- Synchronize sub-tables:
		elseif (type(v) == "table") then
			Sync(v, vTemplate)
		end
		
	end
	
	-- Add any missing keys:
	for k,vTemplate in pairs(templateTbl) do
		
		local v = tbl[k]
		
		if (v == nil) then
			if (type(vTemplate) == "table") then
				tbl[k] = CopyTable(vTemplate)
			else
				tbl[k] = vTemplate
			end
		end
		
	end
	
end


function FastRemove(t, i)
	local n = #t
	t[i] = t[n]
	t[n] = nil
end


function Print(tbl, label, deepPrint)
	
	label = (type(label) == "string" and label or "TABLE")
	
	local strTbl = {}
	local indent = " - "
	
	-- Insert(string, indentLevel)
	local function Insert(s, l)
		strTbl[#strTbl + 1] = (indent:rep(l) .. s .. "\n")
	end
	
	local function AlphaKeySort(a, b)
		return (tostring(a.k) < tostring(b.k))
	end
	
	local function PrintTable(t, lvl, lbl)
		Insert(lbl .. ":", lvl - 1)
		local nonTbls = {}
		local tbls = {}
		local keySpaces = 0
		for k,v in pairs(t) do
			if (type(v) == "table") then
				table.insert(tbls, {k = k, v = v})
			else
				table.insert(nonTbls, {k = k, v = "[" .. typeof(v) .. "] " .. tostring(v)})
			end
			local spaces = #tostring(k) + 1
			if (spaces > keySpaces) then
				keySpaces = spaces
			end
		end
		table.sort(nonTbls, AlphaKeySort)
		table.sort(tbls, AlphaKeySort)
		for _,v in pairs(nonTbls) do
			Insert(tostring(v.k) .. ":" .. (" "):rep(keySpaces - #tostring(v.k)) .. v.v, lvl)
		end
		if (deepPrint) then
			for _,v in pairs(tbls) do
				PrintTable(v.v, lvl + 1, tostring(v.k) .. (" "):rep(keySpaces - #tostring(v.k)) .. " [Table]")
			end
		else
			for _,v in pairs(tbls) do
				Insert(tostring(v.k) .. ":" .. (" "):rep(keySpaces - #tostring(v.k)) .. "[Table]", lvl)
			end
		end
	end
	
	PrintTable(tbl, 1, label)
	
	print(table.concat(strTbl, ""))
	
end


TableUtil.Copy = CopyTable
TableUtil.Sync = Sync
TableUtil.FastRemove = FastRemove
TableUtil.Print = Print


return TableUtil