VRCore.Commands.Add("fix", "Repair your vehicle (Admin Only)", {}, false, function(source, args)
    TriggerClientEvent('iens:repaira', source)
    TriggerClientEvent('vehiclemod:client:fixEverything', source)
end, "admin")

VRCore.Functions.CreateUseableItem("repairkit", function(source, item)
    local Player = VRCore.Functions.GetPlayer(source)
	if Player.Functions.GetItemBySlot(item.slot) ~= nil then
        TriggerClientEvent("vr-vehiclefailure:client:RepairVehicle", source)
    end
end)

VRCore.Functions.CreateUseableItem("cleaningkit", function(source, item)
    local Player = VRCore.Functions.GetPlayer(source)
	if Player.Functions.GetItemBySlot(item.slot) ~= nil then
        TriggerClientEvent("vr-vehiclefailure:client:CleanVehicle", source)
    end
end)

VRCore.Functions.CreateUseableItem("advancedrepairkit", function(source, item)
    local Player = VRCore.Functions.GetPlayer(source)
	if Player.Functions.GetItemBySlot(item.slot) ~= nil then
        TriggerClientEvent("vr-vehiclefailure:client:RepairVehicleFull", source)
    end
end)

RegisterServerEvent('vr-vehiclefailure:removeItem')
AddEventHandler('vr-vehiclefailure:removeItem', function(item)
    local src = source
    local ply = VRCore.Functions.GetPlayer(src)
    ply.Functions.RemoveItem(item, 1)
end)

RegisterServerEvent('vr-vehiclefailure:server:removewashingkit')
AddEventHandler('vr-vehiclefailure:server:removewashingkit', function(veh)
    local src = source
    local ply = VRCore.Functions.GetPlayer(src)
    ply.Functions.RemoveItem("cleaningkit", 1)
    TriggerClientEvent('vr-vehiclefailure:client:SyncWash', -1, veh)
end)

