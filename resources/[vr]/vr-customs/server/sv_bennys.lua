local chicken = vehicleBaseRepairCost

RegisterServerEvent('vr-customs:attemptPurchase')
AddEventHandler('vr-customs:attemptPurchase', function(type, upgradeLevel)
    local source = source
    local Player = VRCore.Functions.GetPlayer(source)
    local balance = exports['vr-bossmenu']:GetAccount(Player.PlayerData.job.name)
    if type == "repair" then
        if balance >= chicken then
            TriggerEvent('vr-bossmenu:server:removeAccountMoney', Player.PlayerData.job.name, chicken)
            TriggerClientEvent('vr-customs:purchaseSuccessful', source)
        else
            TriggerClientEvent('vr-customs:purchaseFailed', source)
        end
    elseif type == "performance" then
        if balance >= vehicleCustomisationPrices[type].prices[upgradeLevel] then
            TriggerClientEvent('vr-customs:purchaseSuccessful', source)
            TriggerEvent('vr-bossmenu:server:removeAccountMoney', Player.PlayerData.job.name, vehicleCustomisationPrices[type].prices[upgradeLevel])
        else
            TriggerClientEvent('vr-customs:purchaseFailed', source)
        end
    else
        if balance >= vehicleCustomisationPrices[type].price then
            TriggerClientEvent('vr-customs:purchaseSuccessful', source)
            TriggerEvent('vr-bossmenu:server:removeAccountMoney', Player.PlayerData.job.name, vehicleCustomisationPrices[type].price)
        else
            TriggerClientEvent('vr-customs:purchaseFailed', source)
        end
    end
end)

RegisterServerEvent('vr-customs:updateRepairCost')
AddEventHandler('vr-customs:updateRepairCost', function(cost)
    chicken = cost
end)

RegisterServerEvent("updateVehicle")
AddEventHandler("updateVehicle", function(myCar)
	local src = source
    if IsVehicleOwned(myCar.plate) then
        exports.ghmattimysql:execute('UPDATE player_vehicles SET mods=@mods WHERE plate=@plate', {['@mods'] = json.encode(myCar), ['@plate'] = myCar.plate})
    end
end)

function IsVehicleOwned(plate)
    local retval = false
    local result = exports.ghmattimysql:scalarSync('SELECT plate FROM player_vehicles WHERE plate=@plate', {['@plate'] = plate})
    if result then
        retval = true
    end
    return retval
end
