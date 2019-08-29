package.path = package.path .. ";data/config/?.lua"

include ("sellMeMoreConfig")

function EquipmentDock.shop:addItems()

    UpgradeGenerator.initialize()

    local counter = 0
    local systems = {}
	
	if randomSoldEquipmentBool then
		if randomSoldEquipmentMin >= 1 and randomSoldEquipmentMin < randomSoldEquipmentMax then
			--Overwrites the flat value in the config
			amountSystemsSold = math.random(randomSoldEquipmentMin, randomSoldEquipmentMax)
		else
			eprint("SellMeMore.equipmentdock ERROR: randomSoldEquipmentMin must be greater than one and less than randomSoldEquipmentMax")
			eprint("SellMeMore.equipmentdock ERROR: Using flat value of %i", amountSystemsSold)
		end
	end
	
    while counter < amountSystemsSold do

        local x, y = Sector():getCoordinates()
        local rarities, weights = UpgradeGenerator.getSectorProbabilities(x, y)

        weights[6] = weights[6] * 0.25 -- strongly reduced probability for normal high rarity equipment
        weights[7] = 0 -- no legendaries in equipment dock

        local system = UpgradeGenerator.generateSystem(nil, weights)

        if system.rarity.value >= 0 or math.random() < 0.25 then
            table.insert(systems, system)
            counter = counter + 1
        end
    end

    table.sort(systems, sortSystems)

    for _, system in pairs(systems) do
        EquipmentDock.shop:add(system, getInt(1, 2))
    end

end