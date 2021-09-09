local alarmTriggered = false
local certificateAmount = 43

RegisterServerEvent('vr-ifruitstore:server:LoadLocationList')
AddEventHandler('vr-ifruitstore:server:LoadLocationList', function()
    local src = source 
    TriggerClientEvent("vr-ifruitstore:server:LoadLocationList", src, Config.Locations)
end)

RegisterServerEvent('vr-ifruitstore:server:setSpotState')
AddEventHandler('vr-ifruitstore:server:setSpotState', function(stateType, state, spot)
    if stateType == "isBusy" then
        Config.Locations["takeables"][spot].isBusy = state
    elseif stateType == "isDone" then
        Config.Locations["takeables"][spot].isDone = state
    end
    TriggerClientEvent('vr-ifruitstore:client:setSpotState', -1, stateType, state, spot)
end)

RegisterServerEvent('vr-ifruitstore:server:SetThermiteStatus')
AddEventHandler('vr-ifruitstore:server:SetThermiteStatus', function(stateType, state)
    if stateType == "isBusy" then
        Config.Locations["thermite"].isBusy = state
    elseif stateType == "isDone" then
        Config.Locations["thermite"].isDone = state
    end
    TriggerClientEvent('vr-ifruitstore:client:SetThermiteStatus', -1, stateType, state)
end)

RegisterServerEvent('vr-ifruitstore:server:SafeReward')
AddEventHandler('vr-ifruitstore:server:SafeReward', function()
    local src = source
    local Player = VRCore.Functions.GetPlayer(src)
    Player.Functions.AddMoney('cash', math.random(1500, 2000), "robbery-ifruit")
    Player.Functions.AddItem("certificate", certificateAmount)
    TriggerClientEvent('inventory:client:ItemBox', src, VRCore.Shared.Items["certificate"], "add")
    Citizen.Wait(500)
    local luck = math.random(1, 100)
    if luck <= 10 then
        Player.Functions.AddItem("goldbar", math.random(1, 2))
        TriggerClientEvent('inventory:client:ItemBox', src, VRCore.Shared.Items["goldbar"], "add")
    end
end)

RegisterServerEvent('vr-ifruitstore:server:SetSafeStatus')
AddEventHandler('vr-ifruitstore:server:SetSafeStatus', function(stateType, state)
    if stateType == "isBusy" then
        Config.Locations["safe"].isBusy = state
    elseif stateType == "isDone" then
        Config.Locations["safe"].isDone = state
    end
    TriggerClientEvent('vr-ifruitstore:client:SetSafeStatus', -1, stateType, state)
end)

RegisterServerEvent('vr-ifruitstore:server:itemReward')
AddEventHandler('vr-ifruitstore:server:itemReward', function(spot)
    local src = source
    local Player = VRCore.Functions.GetPlayer(src)
    local item = Config.Locations["takeables"][spot].reward

    if Player.Functions.AddItem(item.name, item.amount) then
        TriggerClientEvent('inventory:client:ItemBox', src, VRCore.Shared.Items[item.name], 'add')
    else
        TriggerClientEvent('VRCore:Notify', src, 'You have to much in your pocket ..', 'error')
    end    
end)

RegisterServerEvent('vr-ifruitstore:server:PoliceAlertMessage')
AddEventHandler('vr-ifruitstore:server:PoliceAlertMessage', function(msg, coords, blip)
    local src = source
    for k, v in pairs(VRCore.Functions.GetPlayers()) do
        local Player = VRCore.Functions.GetPlayer(v)
        if Player ~= nil then 
            if (Player.PlayerData.job.name == "police") then  
                TriggerClientEvent("vr-ifruitstore:client:PoliceAlertMessage", v, msg, coords, blip) 
            end
        end
    end
end)

RegisterServerEvent('vr-ifruitstore:server:callCops')
AddEventHandler('vr-ifruitstore:server:callCops', function(streetLabel, coords)
    local place = "iFruitStore"
    local msg = "The Alram has been activated at the "..place.. " at " ..streetLabel

    TriggerClientEvent("vr-ifruitstore:client:robberyCall", -1, streetLabel, coords)

end)