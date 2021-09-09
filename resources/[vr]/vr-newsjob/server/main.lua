VRCore.Commands.Add("newscam", "Grab a news camera", {}, false, function(source, args)
    local Player = VRCore.Functions.GetPlayer(source)
    if Player.PlayerData.job.name == "reporter" then
        TriggerClientEvent("Cam:ToggleCam", source)
    end
end)

VRCore.Commands.Add("newsmic", "Grab a news microphone", {}, false, function(source, args)
    local Player = VRCore.Functions.GetPlayer(source)
    if Player.PlayerData.job.name == "reporter" then
        TriggerClientEvent("Mic:ToggleMic", source)
    end
end)

