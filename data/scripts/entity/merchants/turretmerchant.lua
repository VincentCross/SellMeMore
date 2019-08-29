package.path = package.path .. ";data/config/?.lua"

include ("sellMeMoreConfig")

function TurretMerchant.shop:addItems()

    -- simply init with a 'random' seed
    local station = Entity()

    -- create all turrets
    local turrets = {}
	
	if randomSoldEquipmentBool then
		if randomSoldEquipmentMin >= 1 and randomSoldEquipmentMin < randomSoldEquipmentMax then
			--Overwrites the flat value in the config
			amountTurretsSold = math.random(randomSoldEquipmentMin, randomSoldEquipmentMax)
		else
			eprint("SellMeMore.equipmentdock ERROR: randomSoldEquipmentMin must be greater than one and less than randomSoldEquipmentMax")
			eprint("SellMeMore.equipmentdock ERROR: Using flat value of %i", amountTurretsSold)
		end
	end

    for i = 1, amountTurretsSold do
        local turret = InventoryTurret(TurretGenerator.generate(Sector():getCoordinates()))

        local pair = {}
        pair.turret = turret
        pair.amount = 1

        if turret.rarity.value == 1 then -- uncommon weapons may be more than one
            if math.random() < 0.3 then
                pair.amount = pair.amount + 1
            end
        elseif turret.rarity.value == 0 then -- common weapons may be some more than one
            if math.random() < 0.5 then
                pair.amount = pair.amount + 1
            end
            if math.random() < 0.5 then
                pair.amount = pair.amount + 1
            end
        end

        table.insert(turrets, pair)
    end

    table.sort(turrets, comp)

    for _, pair in pairs(turrets) do
        TurretMerchant.shop:add(pair.turret, pair.amount)
    end

end