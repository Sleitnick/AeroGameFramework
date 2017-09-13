-- Table Util
-- Crazyman32
-- September 13, 2017

--[[
	
	TableUtil.Copy(tbl)
	TableUtil.Sync(tbl, templateTbl)
	
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


TableUtil.Copy = CopyTable
TableUtil.Sync = Sync


return TableUtil