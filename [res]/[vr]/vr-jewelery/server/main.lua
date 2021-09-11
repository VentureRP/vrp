local timeOut = false

local alarmTriggered = false

RegisterServerEvent('vr-jewellery:server:setVitrineState')
AddEventHandler('vr-jewellery:server:setVitrineState', function(stateType, state, k)
    Config.Locations[k][stateType] = state
    TriggerClientEvent('vr-jewellery:client:setVitrineState', -1, stateType, state, k)
end)

RegisterServerEvent('vr-jewellery:server:vitrineReward')
AddEventHandler('vr-jewellery:server:vitrineReward', function()
    local src = source
    local Player = VRCore.Functions.GetPlayer(src)
    local otherchance = math.random(1, 4)
    local odd = math.random(1, 4)

    if otherchance == odd then
        local item = math.random(1, #Config.VitrineRewards)
        local amount = math.random(Config.VitrineRewards[item]["amount"]["min"], Config.VitrineRewards[item]["amount"]["max"])
        if Player.Functions.AddItem(Config.VitrineRewards[item]["item"], amount) then
            TriggerClientEvent('inventory:client:ItemBox', src, VRCore.Shared.Items[Config.VitrineRewards[item]["item"]], 'add')
        else
            TriggerClientEvent('VRCore:Notify', src, 'You have to much in your pocket', 'error')
        end
    else
        local amount = math.random(2, 4)
        if Player.Functions.AddItem("10kgoldchain", amount) then
            TriggerClientEvent('inventory:client:ItemBox', src, VRCore.Shared.Items["10kgoldchain"], 'add')
        else
            TriggerClientEvent('VRCore:Notify', src, 'You have to much in your pocket..', 'error')
        end
    end
end)

RegisterServerEvent('vr-jewellery:server:setTimeout')
AddEventHandler('vr-jewellery:server:setTimeout', function()
    if not timeOut then
        timeOut = true
        TriggerEvent('vr-scoreboard:server:SetActivityBusy', "jewellery", true)
        Citizen.CreateThread(function()
            Citizen.Wait(Config.Timeout)

            for k, v in pairs(Config.Locations) do
                Config.Locations[k]["isOpened"] = false
                TriggerClientEvent('vr-jewellery:client:setVitrineState', -1, 'isOpened', false, k)
                TriggerClientEvent('vr-jewellery:client:setAlertState', -1, false)
                TriggerEvent('vr-scoreboard:server:SetActivityBusy', "jewellery", false)
            end
            timeOut = false
            alarmTriggered = false
        end)
    end
end)

RegisterServerEvent('vr-jewellery:server:PoliceAlertMessage')
AddEventHandler('vr-jewellery:server:PoliceAlertMessage', function(title, coords, blip)
    local src = source
    local alertData = {
        title = title,
        coords = {x = coords.x, y = coords.y, z = coords.z},
        description = "Possible robbery going on at Vangelico Jewelry Store<br>Available camera's: 31, 32, 33, 34",
    }

    for k, v in pairs(VRCore.Functions.GetPlayers()) do
        local Player = VRCore.Functions.GetPlayer(v)
        if Player ~= nil then 
            if (Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty) then
                if blip then
                    if not alarmTriggered then
                        TriggerClientEvent("vr-phone:client:addPoliceAlert", v, alertData)
                        TriggerClientEvent("vr-jewellery:client:PoliceAlertMessage", v, title, coords, blip)
                        alarmTriggered = true
                    end
                else
                    TriggerClientEvent("vr-phone:client:addPoliceAlert", v, alertData)
                    TriggerClientEvent("vr-jewellery:client:PoliceAlertMessage", v, title, coords, blip)
                end
            end
        end
    end
end)

VRCore.Functions.CreateCallback('vr-jewellery:server:getCops', function(source, cb)
	local amount = 0
    for k, v in pairs(VRCore.Functions.GetPlayers()) do
        local Player = VRCore.Functions.GetPlayer(v)
        if Player ~= nil then 
            if (Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty) then
                amount = amount + 1
            end
        end
	end
	cb(amount)
end)
