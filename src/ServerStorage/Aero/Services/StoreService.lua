-- Store Service
-- Stephen Leitnick
-- December 1, 2015

-- Updated: December 31, 2016
-- Updated: March 2, 2017
-- Updated: December 29, 2019

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



local StoreService = {Client = {}}

local PRODUCT_PURCHASES_KEY = "ProductPurchases"
local PROMPT_PURCHASE_FINISHED_EVENT = "PromptPurchaseFinished"

local marketplaceService = game:GetService("MarketplaceService")
local dataStoreScope = "PlayerReceipts"

local Data


local function IncrementPurchase(player, productId)
	productId = tostring(productId)
	local playerData = Data.ForPlayer(player)
	return playerData:Get(PRODUCT_PURCHASES_KEY, {}):Then(function(productPurchases)
		local n = productPurchases[productId]
		productPurchases[productId] = (n and (n + 1) or 1)
		playerData:MarkDirty(PRODUCT_PURCHASES_KEY)
		return playerData:Save(PRODUCT_PURCHASES_KEY)
	end)
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

	local notProcessed = Enum.ProductPurchaseDecision.NotProcessedYet
	
	-- Check if unique purchase was already completed:
	local data = Data.new(dataStoreName, dataStoreScope)
	local alreadyPurchasedSuccess, alreadyPurchased = data:Get(key):Await()
	if (not alreadyPurchasedSuccess) then return notProcessed end

	if (not alreadyPurchased) then
		-- Mark as purchased and save immediately:
		local success = data:Set(key, true):Then(function() return data:Save(key) end):Await()
		if (not success) then return notProcessed end
	end
	
	if (player) then
		local incSuccess = IncrementPurchase(player, receiptInfo.ProductId):Await()
		if (not incSuccess) then return notProcessed end
		StoreService:FireEvent(PROMPT_PURCHASE_FINISHED_EVENT, player, receiptInfo)
		StoreService:FireClientEvent(PROMPT_PURCHASE_FINISHED_EVENT, player, receiptInfo)
	end
	
	return Enum.ProductPurchaseDecision.PurchaseGranted
	
end


function StoreService:HasPurchased(player, productId)
	local success, productPurchases = Data.ForPlayer(player):Get(PRODUCT_PURCHASES_KEY, {}):Await()
	return (success and productPurchases[tostring(productId)] ~= nil)
end


function StoreService:OwnsGamePass(player, gamePassId)
	local success, owns = pcall(marketplaceService.UserOwnsGamePassAsync, marketplaceService, player.UserId, gamePassId)
	return (success and owns or false)
end


-- Get the number of productId's purchased:
function StoreService:GetNumberPurchased(player, productId)
	local n = 0
	local success, productPurchases = Data.ForPlayer(player):Get(PRODUCT_PURCHASES_KEY, {}):Await()
	if (success) then
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
	Data = self.Modules.Data
	self:RegisterEvent(PROMPT_PURCHASE_FINISHED_EVENT)
	self:RegisterClientEvent(PROMPT_PURCHASE_FINISHED_EVENT)
end


return StoreService