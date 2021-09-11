local CurrentDivingArea = math.random(1, #VRDiving.Locations)

VRCore.Functions.CreateCallback('vr-diving:server:GetDivingConfig', function(source, cb)
    cb(VRDiving.Locations, CurrentDivingArea)
end)

RegisterServerEvent('vr-diving:server:TakeCoral')
AddEventHandler('vr-diving:server:TakeCoral', function(Area, Coral, Bool)
    local src = source
    local Player = VRCore.Functions.GetPlayer(src)
    local CoralType = math.random(1, #VRDiving.CoralTypes)
    local Amount = math.random(1, VRDiving.CoralTypes[CoralType].maxAmount)
    local ItemData = VRCore.Shared.Items[VRDiving.CoralTypes[CoralType].item]

    if Amount > 1 then
        for i = 1, Amount, 1 do
            Player.Functions.AddItem(ItemData["name"], 1)
            TriggerClientEvent('inventory:client:ItemBox', src, ItemData, "add")
            Citizen.Wait(250)
        end
    else
        Player.Functions.AddItem(ItemData["name"], Amount)
        TriggerClientEvent('inventory:client:ItemBox', src, ItemData, "add")
    end

    if (VRDiving.Locations[Area].TotalCoral - 1) == 0 then
        for k, v in pairs(VRDiving.Locations[CurrentDivingArea].coords.Coral) do
            v.PickedUp = false
        end
        VRDiving.Locations[CurrentDivingArea].TotalCoral = VRDiving.Locations[CurrentDivingArea].DefaultCoral

        local newLocation = math.random(1, #VRDiving.Locations)
        while (newLocation == CurrentDivingArea) do
            Citizen.Wait(3)
            newLocation = math.random(1, #VRDiving.Locations)
        end
        CurrentDivingArea = newLocation
        
        TriggerClientEvent('vr-diving:client:NewLocations', -1)
    else
        VRDiving.Locations[Area].coords.Coral[Coral].PickedUp = Bool
        VRDiving.Locations[Area].TotalCoral = VRDiving.Locations[Area].TotalCoral - 1
    end

    TriggerClientEvent('vr-diving:server:UpdateCoral', -1, Area, Coral, Bool)
end)

RegisterServerEvent('vr-diving:server:RemoveGear')
AddEventHandler('vr-diving:server:RemoveGear', function()
    local src = source
    local Player = VRCore.Functions.GetPlayer(src)

    Player.Functions.RemoveItem("diving_gear", 1)
    TriggerClientEvent('inventory:client:ItemBox', src, VRCore.Shared.Items["diving_gear"], "remove")
end)

RegisterServerEvent('vr-diving:server:GiveBackGear')
AddEventHandler('vr-diving:server:GiveBackGear', function()
    local src = source
    local Player = VRCore.Functions.GetPlayer(src)
    
    Player.Functions.AddItem("diving_gear", 1)
    TriggerClientEvent('inventory:client:ItemBox', src, VRCore.Shared.Items["diving_gear"], "add")
end)