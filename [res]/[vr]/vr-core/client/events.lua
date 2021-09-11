-- VRCore Command Events
RegisterNetEvent('VRCore:Command:TeleportToPlayer')
AddEventHandler('VRCore:Command:TeleportToPlayer', function(coords)
	local ped = PlayerPedId()
	SetPedCoordsKeepVehicle(ped, coords.x, coords.y, coords.z)
end)

RegisterNetEvent('VRCore:Command:TeleportToCoords')
AddEventHandler('VRCore:Command:TeleportToCoords', function(x, y, z)
	local ped = PlayerPedId()
	SetPedCoordsKeepVehicle(ped, x, y, z)
end)

RegisterNetEvent('VRCore:Command:SpawnVehicle')
AddEventHandler('VRCore:Command:SpawnVehicle', function(model)
	VRCore.Functions.SpawnVehicle(model, function(vehicle)
		TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
		TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(vehicle))
	end)
end)

RegisterNetEvent('VRCore:Command:DeleteVehicle')
AddEventHandler('VRCore:Command:DeleteVehicle', function()
	local vehicle = VRCore.Functions.GetClosestVehicle()
	if IsPedInAnyVehicle(PlayerPedId()) then vehicle = GetVehiclePedIsIn(PlayerPedId(), false) else vehicle = VRCore.Functions.GetClosestVehicle() end
	-- TriggerServerEvent('VRCore:Command:CheckOwnedVehicle', GetVehicleNumberPlateText(vehicle))
	VRCore.Functions.DeleteVehicle(vehicle)
end)

RegisterNetEvent('VRCore:Command:Revive')
AddEventHandler('VRCore:Command:Revive', function()
	local coords = VRCore.Functions.GetCoords(PlayerPedId())
	NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z+0.2, coords.a, true, false)
	SetPlayerInvincible(PlayerPedId(), false)
	ClearPedBloodDamage(PlayerPedId())
end)

RegisterNetEvent('VRCore:Command:GoToMarker')
AddEventHandler('VRCore:Command:GoToMarker', function()
	Citizen.CreateThread(function()
		local entity = PlayerPedId()
		if IsPedInAnyVehicle(entity, false) then
			entity = GetVehiclePedIsUsing(entity)
		end
		local success = false
		local blipFound = false
		local blipIterator = GetBlipInfoIdIterator()
		local blip = GetFirstBlipInfoId(8)

		while DoesBlipExist(blip) do
			if GetBlipInfoIdType(blip) == 4 then
				cx, cy, cz = table.unpack(Citizen.InvokeNative(0xFA7C7F0AADF25D09, blip, Citizen.ReturnResultAnyway(), Citizen.ResultAsVector())) --GetBlipInfoIdCoord(blip)
				blipFound = true
				break
			end
			blip = GetNextBlipInfoId(blipIterator)
		end

		if blipFound then
			DoScreenFadeOut(250)
			while IsScreenFadedOut() do
				Citizen.Wait(250)
			end
			local groundFound = false
			local yaw = GetEntityHeading(entity)
			
			for i = 0, 1000, 1 do
				SetEntityCoordsNoOffset(entity, cx, cy, ToFloat(i), false, false, false)
				SetEntityRotation(entity, 0, 0, 0, 0 ,0)
				SetEntityHeading(entity, yaw)
				SetGameplayCamRelativeHeading(0)
				Citizen.Wait(0)
				--groundFound = true
				if GetGroundZFor_3dCoord(cx, cy, ToFloat(i), cz, false) then --GetGroundZFor3dCoord(cx, cy, i, 0, 0) GetGroundZFor_3dCoord(cx, cy, i)
					cz = ToFloat(i)
					groundFound = true
					break
				end
			end
			if not groundFound then
				cz = -300.0
			end
			success = true
		end

		if success then
			SetEntityCoordsNoOffset(entity, cx, cy, cz, false, false, true)
			SetGameplayCamRelativeHeading(0)
			if IsPedSittingInAnyVehicle(PlayerPedId()) then
				if GetPedInVehicleSeat(GetVehiclePedIsUsing(PlayerPedId()), -1) == PlayerPedId() then
					SetVehicleOnGroundProperly(GetVehiclePedIsUsing(PlayerPedId()))
				end
			end
			--HideLoadingPromt()
			DoScreenFadeIn(250)
		end
	end)
end)

-- Other stuff
RegisterNetEvent('VRCore:Player:SetPlayerData')
AddEventHandler('VRCore:Player:SetPlayerData', function(val)
	VRCore.PlayerData = val
end)

RegisterNetEvent('VRCore:Player:UpdatePlayerData')
AddEventHandler('VRCore:Player:UpdatePlayerData', function()
	local data = {}
	data.position = VRCore.Functions.GetCoords(PlayerPedId())
	TriggerServerEvent('VRCore:UpdatePlayer', data)
end)

RegisterNetEvent('VRCore:Player:UpdatePlayerPosition')
AddEventHandler('VRCore:Player:UpdatePlayerPosition', function()
	local position = VRCore.Functions.GetCoords(PlayerPedId())
	TriggerServerEvent('VRCore:UpdatePlayerPosition', position)
end)

RegisterNetEvent('VRCore:Notify')
AddEventHandler('VRCore:Notify', function(text, type, length)
	VRCore.Functions.Notify(text, type, length)
end)

RegisterNetEvent('VRCore:Client:TriggerCallback') -- VRCore:Client:TriggerCallback falls under GPL License here: [esxlicense]/LICENSE
AddEventHandler('VRCore:Client:TriggerCallback', function(name, ...)
	if VRCore.ServerCallbacks[name] ~= nil then
		VRCore.ServerCallbacks[name](...)
		VRCore.ServerCallbacks[name] = nil
	end
end)

RegisterNetEvent("VRCore:Client:UseItem") -- VRCore:Client:UseItem falls under GPL License here: [esxlicense]/LICENSE
AddEventHandler('VRCore:Client:UseItem', function(item)
	TriggerServerEvent("VRCore:Server:UseItem", item)
end)
