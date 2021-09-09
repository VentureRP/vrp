local trunkBusy = {}

RegisterServerEvent('vr-trunk:server:setTrunkBusy')
AddEventHandler('vr-trunk:server:setTrunkBusy', function(plate, busy)
    trunkBusy[plate] = busy
end)

VRCore.Functions.CreateCallback('vr-trunk:server:getTrunkBusy', function(source, cb, plate)
    if trunkBusy[plate] then
        cb(true)
    end
    cb(false)
end)

RegisterServerEvent('vr-trunk:server:KidnapTrunk')
AddEventHandler('vr-trunk:server:KidnapTrunk', function(targetId, closestVehicle)
    TriggerClientEvent('vr-trunk:client:KidnapGetIn', targetId, closestVehicle)
end)

VRCore.Commands.Add("getintrunk", "Get In Trunk", {}, false, function(source, args)
    TriggerClientEvent('vr-trunk:client:GetIn', source)
end)

VRCore.Commands.Add("putintrunk", "Put Player In Trunk", {}, false, function(source, args)
    TriggerClientEvent('vr-trunk:server:KidnapTrunk', source)
end)