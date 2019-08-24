function EquipmentDock.shop:addItems()

    UpgradeGenerator.initialize()

    local counter = 0
    local systems = {}
    while counter < 24 do

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