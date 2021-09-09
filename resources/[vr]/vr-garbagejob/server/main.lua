local Bail = {}

VRCore.Functions.CreateCallback('vr-garbagejob:server:HasMoney', function(source, cb)
    local Player = VRCore.Functions.GetPlayer(source)
    local CitizenId = Player.PlayerData.citizenid

    -- if Player.PlayerData.money.cash >= Config.BailPrice then
    --     Bail[CitizenId] = "cash"
    --     Player.Functions.RemoveMoney('cash', Config.BailPrice)
    --     cb(true)
    -- else
        if Player.PlayerData.money.bank >= Config.BailPrice then
        Bail[CitizenId] = "bank"
        Player.Functions.RemoveMoney('bank', Config.BailPrice)
        cb(true)
    else
        cb(false)
    end
end)

VRCore.Functions.CreateCallback('vr-garbagejob:server:CheckBail', function(source, cb)
    local Player = VRCore.Functions.GetPlayer(source)
    local CitizenId = Player.PlayerData.citizenid

    if Bail[CitizenId] ~= nil then
        Player.Functions.AddMoney(Bail[CitizenId], Config.BailPrice)
        Bail[CitizenId] = nil
        cb(true)
    else
        cb(false)
    end
end)

local Materials = {
    "metalscrap",
    "plastic",
    "copper",
    "iron",
    "aluminum",
    "steel",
    "glass",
}

RegisterNetEvent('vr-garbagejob:server:nano')
AddEventHandler('vr-garbagejob:server:nano', function()
    local xPlayer = VRCore.Functions.GetPlayer(tonumber(source))

	xPlayer.Functions.AddItem("cryptostick", 1, false)
	TriggerClientEvent('inventory:client:ItemBox', source, VRCore.Shared.Items["cryptostick"], "add")
end)

RegisterServerEvent('vr-garbagejob:server:PayShit')
AddEventHandler('vr-garbagejob:server:PayShit', function(amount, location)
    local src = source
    local Player = VRCore.Functions.GetPlayer(src)

    if amount > 0 then
        Player.Functions.AddMoney('bank', amount)

        if location == #Config.Locations["trashcan"] then
            for i = 1, math.random(3, 5), 1 do
                local item = Materials[math.random(1, #Materials)]
                Player.Functions.AddItem(item, math.random(4, 7))
                TriggerClientEvent('inventory:client:ItemBox', src, VRCore.Shared.Items[item], 'add')
                Citizen.Wait(500)
            end
        end

        TriggerClientEvent('VRCore:Notify', src, "You have $"..amount..",- got paid to your bank account!", "success")
    else
        TriggerClientEvent('VRCore:Notify', src, "You have earned nothing..", "error")
    end
end)