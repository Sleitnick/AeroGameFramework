-- Store Service
-- Crazyman32
-- December 1, 2015

-- Updated: December 31, 2016
-- Updated: March 2, 2017

--[[
	
	Server:
		
		StoreService:HasPurchased(player, productId)
		StoreService:OwnsGamePass(player, gamePassId)
		StoreService:GetNumberPurchased(player, productId)
		
		StoreService.PromptPurchaseFinished(player, receiptInfo)
	
	
	Client:
		
		StoreService:HasPurchased(productId)
		StoreService:OwnsGamePass(gamePassId)
		StoreService:GetNumberPurchased(productId)
	
		StoreService.PromptPurchaseFinished(receiptInfo)
	
--]]



local StoreService = {
	Client = {};
}

local PRODUCT_PURCHASES_KEY = "ProductPurchases"
local PROMPT_PURCHASE_FINISHED_EVENT = "PromptPurchaseFinished"

local marketplaceService = game:GetService("MarketplaceService")

local dataStoreScope = "PlayerReceipts"
local modules


local function IncrementPurchase(player, productId)
	productId = tostring(productId)
	local playerData = modules.Data.ForPlayer(player)
	local productPurchases = playerData:Get(PRODUCT_PURCHASES_KEY, {}):Await()

	local n = productPurchases[productId]
	productPurchases[productId] = (n and (n + 1) or 1)
	playerData:Set(PRODUCT_PURCHASES_KEY, productPurchases)
	playerData:Save(PRODUCT_PURCHASES_KEY)
end


local function ProcessReceipt(receiptInfo)
	
	--[[
		ReceiptInfo:
			PlayerId               [Number]
			PlaceIdWherePurchased  [Number]
			PurchaseId             [String]
			ProductId              [Number]
			CurrencyType           [CurrencyType Enum]
			CurrencySpent          [Number]
	--]]
	
	local player = game:GetService("Players"):GetPlayerByUserId(receiptInfo.PlayerId)
	
	local dataStoreName = tostring(receiptInfo.PlayerId)
	local key = tostring(receiptInfo.PurchaseId)
	
	local playerReceiptsData = modules.Data.new(dataStoreName, dataStoreScope)
	-- Check if unique purchase was already completed:
	local alreadyPurchased = playerReceiptsData:Get(key, false):Await()
	
	if (not alreadyPurchased) then
		-- Mark as purchased and save immediately:
		playerReceiptsData:Set(key, true)
		playerReceiptsData:Save(key)
	end
	
	if (player) then
		IncrementPurchase(player, receiptInfo.ProductId)
		StoreService:FireEvent(PROMPT_PURCHASE_FINISHED_EVENT, player, receiptInfo)
		StoreService:FireClientEvent(PROMPT_PURCHASE_FINISHED_EVENT, player, receiptInfo)
	end
	
	return Enum.ProductPurchaseDecision.PurchaseGranted
	
end


function StoreService:HasPurchased(player, productId)
	local playerData = modules.Data.ForPlayer(player)
	local productPurchases = playerData:Get(PRODUCT_PURCHASES_KEY, {}):Await()
	return (productPurchases and productPurchases[tostring(productId)] ~= nil)
end


function StoreService:OwnsGamePass(player, gamePassId)
	local success, owns = pcall(function()
		return marketplaceService:UserOwnsGamePassAsync(player.UserId, gamePassId)
	end)
	return (success and owns or false)
end


-- Get the number of productId's purchased:
function StoreService:GetNumberPurchased(player, productId)
	local n = 0
	local playerData = modules.Data.ForPlayer(player)
	local productPurchases = playerData:Get(PRODUCT_PURCHASES_KEY, {}):Await()
	if (productPurchases) then
		n = (productPurchases[tostring(productId)] or 0)
	end
	return n
end


-- Get the number of productId's purchased:
function StoreService.Client:GetNumberPurchased(player, productId)
	return self.Server:GetNumberPurchased(player, productId)
end


function StoreService.Client:OwnsGamePass(player, gamePassId)
	return self.Server:OwnsGamePass(player, gamePassId)
end


-- Whether or not the productId has been purchased before:
function StoreService.Client:HasPurchased(player, productId)
	return self.Server:HasPurchased(player, productId)
end


function StoreService:Start()
	marketplaceService.ProcessReceipt = ProcessReceipt
end


function StoreService:Init()
	modules = self.Modules
	self:RegisterEvent(PROMPT_PURCHASE_FINISHED_EVENT)
	self:RegisterClientEvent(PROMPT_PURCHASE_FINISHED_EVENT)
end


return StoreService