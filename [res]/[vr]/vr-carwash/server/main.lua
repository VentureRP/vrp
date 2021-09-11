RegisterServerEvent('vr-carwash:server:washCar')
AddEventHandler('vr-carwash:server:washCar', function()
    local src = source
    local Player = VRCore.Functions.GetPlayer(src)

    if Player.Functions.RemoveMoney('cash', Config.DefaultPrice, "car-washed") then
        TriggerClientEvent('vr-carwash:client:washCar', src)
    elseif Player.Functions.RemoveMoney('bank', Config.DefaultPrice, "car-washed") then
        TriggerClientEvent('vr-carwash:client:washCar', src)
    else
        TriggerClientEvent('VRCore:Notify', src, 'You dont have enough money..', 'error')
    end
end)