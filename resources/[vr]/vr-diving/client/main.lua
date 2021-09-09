isLoggedIn = false
PlayerJob = {}

RegisterNetEvent("VRCore:Client:OnPlayerLoaded")
AddEventHandler("VRCore:Client:OnPlayerLoaded", function()
    VRCore.Functions.TriggerCallback('vr-diving:server:GetBusyDocks', function(Docks)
        VRBoatshop.Locations["berths"] = Docks
    end)

    VRCore.Functions.TriggerCallback('vr-diving:server:GetDivingConfig', function(Config, Area)
        VRDiving.Locations = Config
        TriggerEvent('vr-diving:client:SetDivingLocation', Area)
    end)

    PlayerJob = VRCore.Functions.GetPlayerData().job

    isLoggedIn = true

    if PlayerJob.name == "police" then
        if PoliceBlip ~= nil then
            RemoveBlip(PoliceBlip)
        end
        PoliceBlip = AddBlipForCoord(VRBoatshop.PoliceBoat.x, VRBoatshop.PoliceBoat.y, VRBoatshop.PoliceBoat.z)
        SetBlipSprite(PoliceBlip, 410)
        SetBlipDisplay(PoliceBlip, 4)
        SetBlipScale(PoliceBlip, 0.8)
        SetBlipAsShortRange(PoliceBlip, true)
        SetBlipColour(PoliceBlip, 29)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName("Police boat")
        EndTextCommandSetBlipName(PoliceBlip)
        PoliceBlip = AddBlipForCoord(VRBoatshop.PoliceBoat2.x, VRBoatshop.PoliceBoat2.y, VRBoatshop.PoliceBoat2.z)
        SetBlipSprite(PoliceBlip, 410)
        SetBlipDisplay(PoliceBlip, 4)
        SetBlipScale(PoliceBlip, 0.8)
        SetBlipAsShortRange(PoliceBlip, true)
        SetBlipColour(PoliceBlip, 29)
    
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName("Police boat")
        EndTextCommandSetBlipName(PoliceBlip)
    end
end)

-- Code

DrawText3D = function(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

RegisterNetEvent('vr-diving:client:UseJerrycan')
AddEventHandler('vr-diving:client:UseJerrycan', function()
    local ped = PlayerPedId()
    local boat = IsPedInAnyBoat(ped)
    if boat then
        local curVeh = GetVehiclePedIsIn(ped, false)
        VRCore.Functions.Progressbar("reful_boat", "Refueling boat ..", 20000, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, function() -- Done
            exports['LegacyFuel']:SetFuel(curVeh, 100)
            VRCore.Functions.Notify('The boat has been refueled', 'success')
            TriggerServerEvent('vr-diving:server:RemoveItem', 'jerry_can', 1)
            TriggerEvent('inventory:client:ItemBox', VRCore.Shared.Items['jerry_can'], "remove")
        end, function() -- Cancel
            VRCore.Functions.Notify('Refueling has been canceled!', 'error')
        end)
    else
        VRCore.Functions.Notify('You are not in a boat', 'error')
    end
end)
