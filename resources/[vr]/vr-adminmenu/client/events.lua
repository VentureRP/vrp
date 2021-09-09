-- Variables

local lastSpectateCoord = nil
local isSpectating = false

-- Events

RegisterNetEvent('vr-admin:client:inventory')
AddEventHandler('vr-admin:client:inventory', function(targetPed)
    TriggerServerEvent("inventory:server:OpenInventory", "otherplayer", targetPed)
end)

RegisterNetEvent('vr-admin:client:spectate')
AddEventHandler('vr-admin:client:spectate', function(targetPed, coords)
    local myPed = PlayerPedId()
    local targetplayer = GetPlayerFromServerId(targetPed)
    local target = GetPlayerPed(targetplayer)
    if not isSpectating then
        isSpectating = true
        SetEntityVisible(myPed, false) -- Set invisible
        SetEntityInvincible(myPed, true) -- set godmode
        lastSpectateCoord = GetEntityCoords(myPed) -- save my last coords
        SetEntityCoords(myPed, coords) -- Teleport To Player
        NetworkSetInSpectatorMode(true, target) -- Enter Spectate Mode
    else
        isSpectating = false
        NetworkSetInSpectatorMode(false, target) -- Remove From Spectate Mode
        SetEntityCoords(myPed, lastSpectateCoord) -- Return Me To My Coords
        SetEntityVisible(myPed, true) -- Remove invisible
        SetEntityInvincible(myPed, false) -- Remove godmode
        lastSpectateCoord = nil -- Reset Last Saved Coords
    end
end)

RegisterNetEvent('vr-admin:client:SendReport')
AddEventHandler('vr-admin:client:SendReport', function(name, src, msg)
    TriggerServerEvent('vr-admin:server:SendReport', name, src, msg)
end)

RegisterNetEvent('vr-admin:client:SendStaffChat')
AddEventHandler('vr-admin:client:SendStaffChat', function(name, msg)
    TriggerServerEvent('vr-admin:server:StaffChatMessage', name, msg)
end)

RegisterNetEvent('vr-admin:client:SaveCar')
AddEventHandler('vr-admin:client:SaveCar', function()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped)

    if veh ~= nil and veh ~= 0 then
        local plate = GetVehicleNumberPlateText(veh)
        local props = VRCore.Functions.GetVehicleProperties(veh)
        local hash = props.model
        local vehname = GetDisplayNameFromVehicleModel(hash):lower()
        if VRCore.Shared.Vehicles[vehname] ~= nil and next(VRCore.Shared.Vehicles[vehname]) ~= nil then
            TriggerServerEvent('vr-admin:server:SaveCar', props, VRCore.Shared.Vehicles[vehname], `veh`, plate)
        else
            VRCore.Functions.Notify('You cant store this vehicle in your garage..', 'error')
        end
    else
        VRCore.Functions.Notify('You are not in a vehicle..', 'error')
    end
end)

RegisterNetEvent('vr-admin:client:SetModel')
AddEventHandler('vr-admin:client:SetModel', function(skin)
    local ped = PlayerPedId()
    local model = GetHashKey(skin)
    SetEntityInvincible(ped, true)

    if IsModelInCdimage(model) and IsModelValid(model) then
        LoadPlayerModel(model)
        SetPlayerModel(PlayerId(), model)

        if isPedAllowedRandom(skin) then
            SetPedRandomComponentVariation(ped, true)
        end
        
		SetModelAsNoLongerNeeded(model)
	end
	SetEntityInvincible(ped, false)
end)

RegisterNetEvent('vr-admin:client:SetSpeed')
AddEventHandler('vr-admin:client:SetSpeed', function(speed)
    local ped = PlayerId()
    if speed == "fast" then
        SetRunSprintMultiplierForPlayer(ped, 1.49)
        SetSwimMultiplierForPlayer(ped, 1.49)
    else
        SetRunSprintMultiplierForPlayer(ped, 1.0)
        SetSwimMultiplierForPlayer(ped, 1.0)
    end
end)

RegisterNetEvent('vr-weapons:client:SetWeaponAmmoManual')
AddEventHandler('vr-weapons:client:SetWeaponAmmoManual', function(weapon, ammo)
    local ped = PlayerPedId()
    if weapon ~= "current" then
        local weapon = weapon:upper()
        SetPedAmmo(ped, GetHashKey(weapon), ammo)
        VRCore.Functions.Notify('+'..ammo..' Ammo for the '..VRCore.Shared.Weapons[GetHashKey(weapon)]["label"], 'success')
    else
        local weapon = GetSelectedPedWeapon(ped)
        if weapon ~= nil then
            SetPedAmmo(ped, weapon, ammo)
            VRCore.Functions.Notify('+'..ammo..' Ammo for the '..VRCore.Shared.Weapons[weapon]["label"], 'success')
        else
            VRCore.Functions.Notify('You dont have a weapon in your hands..', 'error')
        end
    end
end)

RegisterNetEvent('vr-admin:client:GiveNuiFocus')
AddEventHandler('vr-admin:client:GiveNuiFocus', function(focus, mouse)
    SetNuiFocus(focus, mouse)
end)