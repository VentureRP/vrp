VRCore.Functions.CreateCallback('vr-scoreboard:server:GetCurrentPlayers', function(source, cb)
    local TotalPlayers = 0
    for k, v in pairs(VRCore.Functions.GetPlayers()) do
        TotalPlayers = TotalPlayers + 1
    end
    cb(TotalPlayers)
end)

VRCore.Functions.CreateCallback('vr-scoreboard:server:GetActivity', function(source, cb)
    local PoliceCount = 0
    local AmbulanceCount = 0
    
    for k, v in pairs(VRCore.Functions.GetPlayers()) do
        local Player = VRCore.Functions.GetPlayer(v)
        if Player ~= nil then
            if (Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty) then
                PoliceCount = PoliceCount + 1
            end

            if ((Player.PlayerData.job.name == "ambulance" or Player.PlayerData.job.name == "doctor") and Player.PlayerData.job.onduty) then
                AmbulanceCount = AmbulanceCount + 1
            end
        end
    end

    cb(PoliceCount, AmbulanceCount)
end)

VRCore.Functions.CreateCallback('vr-scoreboard:server:GetConfig', function(source, cb)
    cb(Config.IllegalActions)
end)

VRCore.Functions.CreateCallback('vr-scoreboard:server:GetPlayersArrays', function(source, cb)
    local players = {}
    for k, v in pairs(VRCore.Functions.GetPlayers()) do
        local Player = VRCore.Functions.GetPlayer(v)
        if Player ~= nil then 
            players[Player.PlayerData.source] = {}
            players[Player.PlayerData.source].permission = VRCore.Functions.IsOptin(Player.PlayerData.source)
        end
    end
    cb(players)
end)

RegisterServerEvent('vr-scoreboard:server:SetActivityBusy')
AddEventHandler('vr-scoreboard:server:SetActivityBusy', function(activity, bool)
    Config.IllegalActions[activity].busy = bool
    TriggerClientEvent('vr-scoreboard:client:SetActivityBusy', -1, activity, bool)
end)