function new()
    local instance = {}

    instance.ItemWrapper = SellableInventoryItem
    instance.tax = 0.2

    -- UI
    instance.soldItemFrames = {}
    instance.soldItemNameLabels = {}
    instance.soldItemPriceLabels = {}
    instance.soldItemMaterialLabels = {}
    instance.soldItemStockLabels = {}
    instance.soldItemButtons = {}
    instance.soldItemIcons = {}

    instance.boughtItemFrames = {}
    instance.boughtItemNameLabels = {}
    instance.boughtItemPriceLabels = {}
    instance.boughtItemMaterialLabels = {}
    instance.boughtItemStockLabels = {}
    instance.boughtItemButtons = {}
    instance.boughtItemIcons = {}

    instance.pageLabel = 0
	instance.pageLabelBuy = 0

    instance.buybackItemFrames = {}
    instance.buybackItemNameLabels = {}
    instance.buybackItemPriceLabels = {}
    instance.buybackItemMaterialLabels = {}
    instance.buybackItemStockLabels = {}
    instance.buybackItemButtons = {}
    instance.buybackItemIcons = {}

    instance.itemsPerPage = 15

    instance.soldItems = {}
    instance.boughtItems = {}
    instance.buybackItems = {}

    instance.boughtItemsPage = 0
	instance.soldItemsPage = 0

    instance.guiInitialized = false

    instance.buyTab = nil
    instance.sellTab = nil
    instance.buyBackTab = nil

    return setmetatable(instance, Shop)
end

-- update the buy tab (the tab where the STATION SELLS)
function Shop:updateSellGui() -- client

    if not self.guiInitialized then return end
	
	local numDifferentItems = #self.soldItems
	
	while self.soldItemsPage * self.itemsPerPage >= numDifferentItems do
		self.soldItemsPage = self.soldItemsPage - 1
	end

    if self.soldItemsPage < 0 then
        self.soldItemsPage = 0
    end

    for i, v in pairs(self.soldItemFrames) do v:hide() end
    for i, v in pairs(self.soldItemNameLabels) do v:hide() end
    for i, v in pairs(self.soldItemPriceLabels) do v:hide() end
    for i, v in pairs(self.soldItemMaterialLabels) do v:hide() end
    for i, v in pairs(self.soldItemStockLabels) do v:hide() end
    for i, v in pairs(self.soldItemButtons) do v:hide() end
    for i, v in pairs(self.soldItemIcons) do v:hide() end

    local faction = Faction()
    local buyer = Player()
    local playerCraft = buyer.craft
    if playerCraft.factionIndex == buyer.allianceIndex then
        buyer = buyer.alliance
    end

	local itemStart = self.soldItemsPage * self.itemsPerPage + 1
    local itemEnd = math.min(numDifferentItems, itemStart + 14)

    local uiIndex = 1

    for index = itemStart, itemEnd do
    -- TODO: Remove existing for index
	--for index, item in pairs(self.soldItems) do
		local item = self.soldItems[index]

        if item == nil then
            break
        end
	
		-- TODO: Remove debug printing.
		print("updateSellGui.index: %i", index)
		-- Index is going out of bounds on 16th call to below. soldItemFrames is an object created in Shop.new. 
		-- It is set in Shop.buildGui. buildGui has only looped 15 times, so the 16th is not created. 
		-- But it looks like pairs(self.soldItems) is higher. Which makes sense since 20+ items are being sold.
		-- Theoretically buildGui is used by both buying and selling, so supports only 15 loops. Does that mean
		-- this loop is assuming only 15 items? Whatever the cause, updateBuyGui can handle more than 15 so theoretically
		-- if I copy that, it'll solve this indexing issue. Problem is the updateBuyGui uses boughtItemsPage and paging
		-- for selling is not in yet. So will try hardcoding it for now.
		--
		-- Paging should now be working dynamically. As evidenced by the fact that the index was originally only looping to 15.
		-- But after pressing the right button, the index then goes up to 16. But it is unfortunately going out of bounds on
		-- soldItemFrames again (and presumably more below). TODO: Remove comments.
        self.soldItemFrames[uiIndex]:show()
        self.soldItemNameLabels[uiIndex]:show()
        self.soldItemPriceLabels[uiIndex]:show()
        self.soldItemMaterialLabels[uiIndex]:show()
        self.soldItemStockLabels[uiIndex]:show()
        self.soldItemButtons[uiIndex]:show()
        self.soldItemIcons[uiIndex]:show()

        self.soldItemNameLabels[uiIndex].caption = item.name
        self.soldItemNameLabels[uiIndex].color = item.rarity.color
        self.soldItemNameLabels[uiIndex].bold = false

        if item.material then
            self.soldItemMaterialLabels[uiIndex].caption = item.material.name
            self.soldItemMaterialLabels[uiIndex].color = item.material.color
        else
            self.soldItemMaterialLabels[uiIndex]:hide()
        end

        if item.icon then
            self.soldItemIcons[uiIndex].picture = item.icon
            self.soldItemIcons[uiIndex].color = item.rarity.color
        end

        local price = self:getSellPriceAndTax(item.price, faction, buyer)
        self.soldItemPriceLabels[uiIndex].caption = createMonetaryString(price)

        self.soldItemStockLabels[uiIndex].caption = item.amount
		
		uiIndex = uiIndex + 1
    end
	
	if itemEnd < itemStart then
        itemEnd = 0
        itemStart = 0
    end
	
	--TODO: Implement paging
	self.pageLabelBuy.caption = itemStart .. " - " .. itemEnd .. " / " .. numDifferentItems
end


function Shop:buildGui(window, guiType) -- client

    local buttonCaption = ""
    local buttonCallback = ""

    local size = window.size
    local pos = window.lower

--    window:createFrame(Rect(size))

    if guiType == 0 then
        buttonCaption = "Buy"%_t
        buttonCallback = "onBuyButtonPressed"
		
		window:createButton(Rect(0, 50 + 35 * 15, 70, 80 + 35 * 15), "<", "onLeftButtonPressedBuy")
        window:createButton(Rect(size.x - 70, 50 + 35 * 15, 60 + size.x - 60, 80 + 35 * 15), ">", "onRightButtonPressedBuy")

        self.pageLabelBuy = window:createLabel(vec2(10, 50 + 35 * 15), "", 20)
        self.pageLabelBuy.lower = vec2(pos.x + 10, pos.y + 50 + 35 * 15)
        self.pageLabelBuy.upper = vec2(pos.x + size.x - 70, pos.y + 75)
        self.pageLabelBuy.centered = 1
    elseif guiType == 1 then
        buttonCaption = "Sell"%_t
        buttonCallback = "onSellButtonPressed"

        window:createButton(Rect(0, 50 + 35 * 15, 70, 80 + 35 * 15), "<", "onLeftButtonPressed")
        window:createButton(Rect(size.x - 70, 50 + 35 * 15, 60 + size.x - 60, 80 + 35 * 15), ">", "onRightButtonPressed")

        self.pageLabel = window:createLabel(vec2(10, 50 + 35 * 15), "", 20)
        self.pageLabel.lower = vec2(pos.x + 10, pos.y + 50 + 35 * 15)
        self.pageLabel.upper = vec2(pos.x + size.x - 70, pos.y + 75)
        self.pageLabel.centered = 1
    else
        buttonCaption = "Buy"%_t
        buttonCallback = "onBuybackButtonPressed"
    end

    local pictureX = 20
    local nameX = 60
    local materialX = 480
    local stockX = 560
    local priceX = 600
    local buttonX = 720

    -- header
    window:createLabel(vec2(nameX, 0), "Name"%_t, 15)
    window:createLabel(vec2(materialX, 0), "Mat"%_t, 15)
    window:createLabel(vec2(priceX, 0), "Cr"%_t, 15)
    window:createLabel(vec2(stockX, 0), "#"%_t, 15)

    local y = 35

    if guiType == 1 then
        local button = window:createButton(Rect(buttonX, 0, 160 + buttonX, 30), "Sell Trash"%_t, "onSellTrashButtonPressed")
        button.maxTextSize = 15
    end

    for i = 1, self.itemsPerPage do

        local yText = y + 6

        local frame = window:createFrame(Rect(0, y, buttonX - 10, 30 + y))

        local nameLabel = window:createLabel(vec2(nameX, yText), "", 15)
        local priceLabel = window:createLabel(vec2(priceX, yText), "", 15)
        local materialLabel = window:createLabel(vec2(materialX, yText), "", 15)
        local stockLabel = window:createLabel(vec2(stockX, yText), "", 15)
        local button = window:createButton(Rect(buttonX, y, 160 + buttonX, 30 + y), buttonCaption, buttonCallback)
        local icon = window:createPicture(Rect(pictureX, yText - 5, 29 + pictureX, 29 + yText - 5), "")

        button.maxTextSize = 15
        icon.isIcon = 1

        if guiType == 0 then
            table.insert(self.soldItemFrames, frame)
            table.insert(self.soldItemNameLabels, nameLabel)
            table.insert(self.soldItemPriceLabels, priceLabel)
            table.insert(self.soldItemMaterialLabels, materialLabel)
            table.insert(self.soldItemStockLabels, stockLabel)
            table.insert(self.soldItemButtons, button)
            table.insert(self.soldItemIcons, icon)
        elseif guiType == 1 then
            table.insert(self.boughtItemFrames, frame)
            table.insert(self.boughtItemNameLabels, nameLabel)
            table.insert(self.boughtItemPriceLabels, priceLabel)
            table.insert(self.boughtItemMaterialLabels, materialLabel)
            table.insert(self.boughtItemStockLabels, stockLabel)
            table.insert(self.boughtItemButtons, button)
            table.insert(self.boughtItemIcons, icon)
        elseif guiType == 2 then
            table.insert(self.buybackItemFrames, frame)
            table.insert(self.buybackItemNameLabels, nameLabel)
            table.insert(self.buybackItemPriceLabels, priceLabel)
            table.insert(self.buybackItemMaterialLabels, materialLabel)
            table.insert(self.buybackItemStockLabels, stockLabel)
            table.insert(self.buybackItemButtons, button)
            table.insert(self.buybackItemIcons, icon)
        end

        frame:hide();
        nameLabel:hide();
        priceLabel:hide();
        materialLabel:hide();
        stockLabel:hide();
        button:hide();
        icon:hide();

        y = y + 35
    end

end

function Shop:onLeftButtonPressedBuy()
    --TODO: Remove printing.
	print("onLeftButtonPressed soldItemsPage before: %i", self.soldItemsPage)
	self.soldItemsPage = self.soldItemsPage - 1
	print("onLeftButtonPressed soldItemsPage after: %i", self.soldItemsPage)
    self:updateSellGui()
end

function Shop:onRightButtonPressedBuy()
	--TODO: Remove printing.
    print("onRightButtonPressed soldItemsPage before: %i", self.soldItemsPage)
	self.soldItemsPage = self.soldItemsPage + 1
	print("onRightButtonPressed soldItemsPage after: %i", self.soldItemsPage)
    self:updateSellGui()
end

function Shop:onShowWindow()

    self.boughtItemsPage = 0
	self.soldItemsPage = 0
	
	--TODO: Remove printing.
	print("onShowWindow: %i", self.soldItemsPage)

    self:updatePlayerItems()
    self:updateBuyGui()
    self:updateBuybackGui()
	self:updateSellGui()

    self.tabbedWindow:selectTab(self.buyTab)
end

function PublicNamespace.CreateNamespace()
    local result = {}

    local shop = PublicNamespace.CreateShop()

    shop.shared = PublicNamespace
    result.shop = shop
    result.onShowWindow = function(...) return shop:onShowWindow(...) end
    result.sendItems = function(...) return shop:sendItems(...) end
    result.receiveSoldItems = function(...) return shop:receiveSoldItems(...) end
    result.sellToPlayer = function(...) return shop:sellToPlayer(...) end
    result.buyFromPlayer = function(...) return shop:buyFromPlayer(...) end
    result.buyTrashFromPlayer = function(...) return shop:buyTrashFromPlayer(...) end
    result.sellBackToPlayer = function(...) return shop:sellBackToPlayer(...) end
    result.updateBoughtItem = function(...) return shop:updateBoughtItem(...) end
    result.onLeftButtonPressed = function(...) return shop:onLeftButtonPressed(...) end
    result.onRightButtonPressed = function(...) return shop:onRightButtonPressed(...) end
	result.onLeftButtonPressedBuy = function(...) return shop:onLeftButtonPressedBuy(...) end
    result.onRightButtonPressedBuy = function(...) return shop:onRightButtonPressedBuy(...) end
    result.onBuyButtonPressed = function(...) return shop:onBuyButtonPressed(...) end
    result.onSellButtonPressed = function(...) return shop:onSellButtonPressed(...) end
    result.onSellTrashButtonPressed = function(...) return shop:onSellTrashButtonPressed(...) end
    result.onBuybackButtonPressed = function(...) return shop:onBuybackButtonPressed(...) end
    result.renderUI = function(...) return shop:renderUI(...) end
    result.onMouseEvent = function(...) return shop:onMouseEvent(...) end
    result.onKeyboardEvent = function(...) return shop:onKeyboardEvent(...) end
    result.add = function(...) return shop:add(...) end
    result.addFront = function(...) return shop:addFront(...) end
    result.getBuyPrice = function(...) return shop.getBuyPrice(...) end
    result.getNumSoldItems = function() return shop:getNumSoldItems() end
    result.getNumBuybackItems = function() return shop:getNumBuybackItems() end
    result.getSoldItemPrice = function(...) return shop:getSoldItemPrice(...) end
    result.getBoughtItemPrice = function(...) return shop:getBoughtItemPrice(...) end
    result.getTax = function() return shop:getTax() end

    -- Dynamic Namespace result
    callable(result, "buyFromPlayer")
    callable(result, "buyTrashFromPlayer")
    callable(result, "sellBackToPlayer")
    callable(result, "sellToPlayer")
    callable(result, "sendItems")

    return result
end