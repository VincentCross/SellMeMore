package.path = package.path .. ";data/config/?.lua"

include ("sellMeMoreConfig")

function TurretMerchant.shop:addItems()

    -- simply init with a 'random' seed
    local station = Entity()

    -- create all turrets
    local turrets = {}

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