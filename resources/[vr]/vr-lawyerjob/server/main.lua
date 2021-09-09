VRCore.Commands.Add("setlawyer", "Register someone as a lawyer", {{name="id", help="Id of the player"}}, true, function(source, args)
    local Player = VRCore.Functions.GetPlayer(source)
    local playerId = tonumber(args[1])
    local OtherPlayer = VRCore.Functions.GetPlayer(playerId)
    if Player.PlayerData.job.name == "judge" then
        if OtherPlayer ~= nil then 
            local lawyerInfo = {
                id = math.random(100000, 999999),
                firstname = OtherPlayer.PlayerData.charinfo.firstname,
                lastname = OtherPlayer.PlayerData.charinfo.lastname,
                citizenid = OtherPlayer.PlayerData.citizenid,
            }
            OtherPlayer.Functions.SetJob("lawyer", 0)
            OtherPlayer.Functions.AddItem("lawyerpass", 1, false, lawyerInfo)
            TriggerClientEvent("VRCore:Notify", source, "You have " .. OtherPlayer.PlayerData.charinfo.firstname .. " " .. OtherPlayer.PlayerData.charinfo.lastname .. " hired as a lawyer")
            TriggerClientEvent("VRCore:Notify", OtherPlayer.PlayerData.source, "You are now a lawyer")
            TriggerClientEvent('inventory:client:ItemBox', OtherPlayer.PlayerData.source, VRCore.Shared.Items["lawyerpass"], "add")
        else
            TriggerClientEvent("VRCore:Notify", source, "Person is present", "error")
        end
    else
        TriggerClientEvent("VRCore:Notify", source, "You are not a judge.", "error")
    end
end)

VRCore.Commands.Add("removelawyer", "Remove someone as a lawyer", {{name="id", help="ID of the player"}}, true, function(source, args)
    local Player = VRCore.Functions.GetPlayer(source)
    local playerId = tonumber(args[1])
    local OtherPlayer = VRCore.Functions.GetPlayer(playerId)
    if Player.PlayerData.job.name == "judge" then
        if OtherPlayer ~= nil then
	    OtherPlayer.Functions.SetJob("unemployed", 0)
            TriggerClientEvent("VRCore:Notify", OtherPlayer.PlayerData.source, "You are now unemployed")
            TriggerClientEvent("VRCore:Notify", source, "You have " .. OtherPlayer.PlayerData.charinfo.firstname .. " " .. OtherPlayer.PlayerData.charinfo.lastname .. "dismiss as a lawyer")
        else
            TriggerClientEvent("VRCore:Notify", source, "Person is not present", "error")
        end
    else
        TriggerClientEvent("VRCore:Notify", source, "Youre not a judge..", "error")
    end
end)

VRCore.Functions.CreateUseableItem("lawyerpass", function(source, item)
    local Player = VRCore.Functions.GetPlayer(source)
	if Player.Functions.GetItemBySlot(item.slot) ~= nil then
        TriggerClientEvent("vr-justice:client:showLawyerLicense", -1, source, item.info)
    end
end)
