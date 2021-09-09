VRCore.Functions.CreateUseableItem("joint", function(source, item)
    local Player = VRCore.Functions.GetPlayer(source)
	if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent("consumables:client:UseJoint", source)
    end
end)

VRCore.Functions.CreateUseableItem("armor", function(source, item)
    local Player = VRCore.Functions.GetPlayer(source)
    TriggerClientEvent("consumables:client:UseArmor", source)
end)

VRCore.Functions.CreateUseableItem("heavyarmor", function(source, item)
    local Player = VRCore.Functions.GetPlayer(source)
    TriggerClientEvent("consumables:client:UseHeavyArmor", source)
end)

-- VRCore.Functions.CreateUseableItem("smoketrailred", function(source, item)
--     local Player = VRCore.Functions.GetPlayer(source)
-- 	if Player.Functions.RemoveItem(item.name, 1, item.slot) then
--         TriggerClientEvent("consumables:client:UseRedSmoke", source)
--     end
-- end)

VRCore.Functions.CreateUseableItem("parachute", function(source, item)
    local Player = VRCore.Functions.GetPlayer(source)
	if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent("consumables:client:UseParachute", source)
    end
end)

VRCore.Commands.Add("resetparachute", "Resets Parachute", {}, false, function(source, args)
    local Player = VRCore.Functions.GetPlayer(source)
        TriggerClientEvent("consumables:client:ResetParachute", source)
end)

RegisterServerEvent("vr-smallpenis:server:AddParachute")
AddEventHandler("vr-smallpenis:server:AddParachute", function()
    local src = source
    local Ply = VRCore.Functions.GetPlayer(src)

    Ply.Functions.AddItem("parachute", 1)
end)

VRCore.Functions.CreateUseableItem("water_bottle", function(source, item)
    local Player = VRCore.Functions.GetPlayer(source)
	if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent("consumables:client:Drink", source, item.name)
    end
end)

VRCore.Functions.CreateUseableItem("vodka", function(source, item)
    local Player = VRCore.Functions.GetPlayer(source)
    TriggerClientEvent("consumables:client:DrinkAlcohol", source, item.name)
end)

VRCore.Functions.CreateUseableItem("beer", function(source, item)
    local Player = VRCore.Functions.GetPlayer(source)
    TriggerClientEvent("consumables:client:DrinkAlcohol", source, item.name)
end)

VRCore.Functions.CreateUseableItem("whiskey", function(source, item)
    local Player = VRCore.Functions.GetPlayer(source)
    TriggerClientEvent("consumables:client:DrinkAlcohol", source, item.name)
end)

VRCore.Functions.CreateUseableItem("coffee", function(source, item)
    local Player = VRCore.Functions.GetPlayer(source)
	if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent("consumables:client:Drink", source, item.name)
    end
end)

VRCore.Functions.CreateUseableItem("kurkakola", function(source, item)
    local Player = VRCore.Functions.GetPlayer(source)
	if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent("consumables:client:Drink", source, item.name)
    end
end)

VRCore.Functions.CreateUseableItem("sandwich", function(source, item)
    local Player = VRCore.Functions.GetPlayer(source)
	if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent("consumables:client:Eat", source, item.name)
    end
end)

VRCore.Functions.CreateUseableItem("twerks_candy", function(source, item)
    local Player = VRCore.Functions.GetPlayer(source)
	if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent("consumables:client:Eat", source, item.name)
    end
end)

VRCore.Functions.CreateUseableItem("snikkel_candy", function(source, item)
    local Player = VRCore.Functions.GetPlayer(source)
	if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent("consumables:client:Eat", source, item.name)
    end
end)

VRCore.Functions.CreateUseableItem("tosti", function(source, item)
    local Player = VRCore.Functions.GetPlayer(source)
	if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent("consumables:client:Eat", source, item.name)
    end
end)

VRCore.Functions.CreateUseableItem("binoculars", function(source, item)
    local Player = VRCore.Functions.GetPlayer(source)
    TriggerClientEvent("binoculars:Toggle", source)
end)

VRCore.Functions.CreateUseableItem("cokebaggy", function(source, item)
    local Player = VRCore.Functions.GetPlayer(source)
    TriggerClientEvent("consumables:client:Cokebaggy", source)
end)

VRCore.Functions.CreateUseableItem("crack_baggy", function(source, item)
    local Player = VRCore.Functions.GetPlayer(source)
    TriggerClientEvent("consumables:client:Crackbaggy", source)
end)

VRCore.Functions.CreateUseableItem("xtcbaggy", function(source, item)
    local Player = VRCore.Functions.GetPlayer(source)
    TriggerClientEvent("consumables:client:EcstasyBaggy", source)
end)

VRCore.Functions.CreateUseableItem("firework1", function(source, item)
    local Player = VRCore.Functions.GetPlayer(source)
    TriggerClientEvent("fireworks:client:UseFirework", source, item.name, "proj_indep_firework")
end)

VRCore.Functions.CreateUseableItem("firework2", function(source, item)
    local Player = VRCore.Functions.GetPlayer(source)
    TriggerClientEvent("fireworks:client:UseFirework", source, item.name, "proj_indep_firework_v2")
end)

VRCore.Functions.CreateUseableItem("firework3", function(source, item)
    local Player = VRCore.Functions.GetPlayer(source)
    TriggerClientEvent("fireworks:client:UseFirework", source, item.name, "proj_xmas_firework")
end)

VRCore.Functions.CreateUseableItem("firework4", function(source, item)
    local Player = VRCore.Functions.GetPlayer(source)
    TriggerClientEvent("fireworks:client:UseFirework", source, item.name, "scr_indep_fireworks")
end)

VRCore.Commands.Add("resetarmor", "Resets Vest (Police Only)", {}, false, function(source, args)
    local Player = VRCore.Functions.GetPlayer(source)
    if Player.PlayerData.job.name == "police" then
        TriggerClientEvent("consumables:client:ResetArmor", source)
    else
        TriggerClientEvent('VRCore:Notify', source,  "For Emergency Service Only", "error")
    end
end)