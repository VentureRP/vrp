VRCore.Functions.CreateCallback('vr-drugs:server:cornerselling:getAvailableDrugs', function(source, cb)
    local AvailableDrugs = {}
    local src = source
    local Player = VRCore.Functions.GetPlayer(src)

    for i = 1, #Config.CornerSellingDrugsList, 1 do
        local item = Player.Functions.GetItemByName(Config.CornerSellingDrugsList[i])

        if item ~= nil then
            table.insert(AvailableDrugs, {
                item = item.name,
                amount = item.amount,
                label = VRCore.Shared.Items[item.name]["label"]
            })
        end
    end

    if next(AvailableDrugs) ~= nil then
        cb(AvailableDrugs)
    else
        cb(nil)
    end
end)

RegisterServerEvent('vr-drugs:server:sellCornerDrugs')
AddEventHandler('vr-drugs:server:sellCornerDrugs', function(item, amount, price)
    local src = source
    local Player = VRCore.Functions.GetPlayer(src)
    local hasItem = Player.Functions.GetItemByName(item)
    local AvailableDrugs = {}
    if hasItem.amount >= amount then
        
        TriggerClientEvent('VRCore:Notify', src, 'Offer accepted!', 'success')
        Player.Functions.RemoveItem(item, amount)
        Player.Functions.AddMoney('cash', price, "sold-cornerdrugs")
        TriggerClientEvent('inventory:client:ItemBox', src, VRCore.Shared.Items[item], "remove")

        for i = 1, #Config.CornerSellingDrugsList, 1 do
            local item = Player.Functions.GetItemByName(Config.CornerSellingDrugsList[i])

            if item ~= nil then
                table.insert(AvailableDrugs, {
                    item = item.name,
                    amount = item.amount,
                    label = VRCore.Shared.Items[item.name]["label"]
                })
            end
        end

        TriggerClientEvent('vr-drugs:client:refreshAvailableDrugs', src, AvailableDrugs)
    else
        TriggerClientEvent('vr-drugs:client:cornerselling', src)
    end
end)

RegisterServerEvent('vr-drugs:server:robCornerDrugs')
AddEventHandler('vr-drugs:server:robCornerDrugs', function(item, amount, price)
    local src = source
    local Player = VRCore.Functions.GetPlayer(src)
    local AvailableDrugs = {}

    Player.Functions.RemoveItem(item, amount)

    TriggerClientEvent('inventory:client:ItemBox', src, VRCore.Shared.Items[item], "remove")

    for i = 1, #Config.CornerSellingDrugsList, 1 do
        local item = Player.Functions.GetItemByName(Config.CornerSellingDrugsList[i])

        if item ~= nil then
            table.insert(AvailableDrugs, {
                item = item.name,
                amount = item.amount,
                label = VRCore.Shared.Items[item.name]["label"]
            })
        end
    end

    TriggerClientEvent('vr-drugs:client:refreshAvailableDrugs', src, AvailableDrugs)
end)