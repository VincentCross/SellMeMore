-- update the buy tab (the tab where the STATION SELLS)
function Shop:updateSellGui() -- client

    if not self.guiInitialized then return end
	
	local numDifferentItems = #self.soldItems
	self.soldItemsPage = 0 -- TODO: Remove hardcoding of soldItemsPage
	
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
    --for index, item in pairs(self.soldItems) do
		local item = self.soldItems[index]

        if item == nil then
            break
        end
	
		print("updateSellGui.index")
		print(index)
		-- Index is going out of bounds on 16th call to below. soldItemFrames is an object created in Shop.new. 
		-- It is set in Shop.buildGui. buildGui has only looped 15 times, so the 16th is not created. 
		-- But it looks like pairs(self.soldItems) is higher. Which makes sense since 20+ items are being sold.
		-- Theoretically buildGui is used by both buying and selling, so supports only 15 loops. Does that mean
		-- this loop is assuming only 15 items? Whatever the cause, updateBuyGui can handle more than 15 so theoretically
		-- if I copy that, it'll solve this indexing issue. Problem is the updateBuyGui uses boughtItemsPage and paging
		-- for selling is not in yet. So will try hardcoding it for now.		
        self.soldItemFrames[index]:show()
        self.soldItemNameLabels[index]:show()
        self.soldItemPriceLabels[index]:show()
        self.soldItemMaterialLabels[index]:show()
        self.soldItemStockLabels[index]:show()
        self.soldItemButtons[index]:show()
        self.soldItemIcons[index]:show()

        self.soldItemNameLabels[index].caption = item.name
        self.soldItemNameLabels[index].color = item.rarity.color
        self.soldItemNameLabels[index].bold = false

        if item.material then
            self.soldItemMaterialLabels[index].caption = item.material.name
            self.soldItemMaterialLabels[index].color = item.material.color
        else
            self.soldItemMaterialLabels[index]:hide()
        end

        if item.icon then
            self.soldItemIcons[index].picture = item.icon
            self.soldItemIcons[index].color = item.rarity.color
        end

        local price = self:getSellPriceAndTax(item.price, faction, buyer)
        self.soldItemPriceLabels[index].caption = createMonetaryString(price)

        self.soldItemStockLabels[index].caption = item.amount
		
		uiIndex = uiIndex + 1
    end
	
	if itemEnd < itemStart then
        itemEnd = 0
        itemStart = 0
    end
	
	--TODO: Implement paging
	--self.pageLabel.caption = itemStart .. " - " .. itemEnd .. " / " .. numDifferentItems
end