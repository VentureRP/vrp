local ClosestBerth = 1
local BoatsSpawned = false
local ModelLoaded = true
local SpawnedBoats = {}
local Buying = false

-- Berth's Boatshop Loop

Citizen.CreateThread(function()
    while true do
        local pos = GetEntityCoords(PlayerPedId(), true)
        local BerthDist = #(pos - vector3(VRBoatshop.Locations["berths"][1]["coords"]["boat"]["x"], VRBoatshop.Locations["berths"][1]["coords"]["boat"]["y"], VRBoatshop.Locations["berths"][1]["coords"]["boat"]["z"]))

        if BerthDist < 100 then
            SetClosestBerthBoat()
            if not BoatsSpawned then
                SpawnBerthBoats()
            end
        elseif BerthDist > 110 then
            if BoatsSpawned then
                BoatsSpawned = false
            end
        end

        Citizen.Wait(1000)
    end
end)

function SpawnBerthBoats()
    for loc,_ in pairs(VRBoatshop.Locations["berths"]) do
        if SpawnedBoats[loc] ~= nil then
            VRCore.Functions.DeleteVehicle(SpawnedBoats[loc])
        end
		local model = GetHashKey(VRBoatshop.Locations["berths"][loc]["boatModel"])
		RequestModel(model)
		while not HasModelLoaded(model) do
			Citizen.Wait(0)
		end

		local veh = CreateVehicle(model, VRBoatshop.Locations["berths"][loc]["coords"]["boat"]["x"], VRBoatshop.Locations["berths"][loc]["coords"]["boat"]["y"], VRBoatshop.Locations["berths"][loc]["coords"]["boat"]["z"], false, false)

        SetModelAsNoLongerNeeded(model)
		SetVehicleOnGroundProperly(veh)
		SetEntityInvincible(veh,true)
        SetEntityHeading(veh, VRBoatshop.Locations["berths"][loc]["coords"]["boat"]["w"])
        SetVehicleDoorsLocked(veh, 3)

		FreezeEntityPosition(veh,true)     
        SpawnedBoats[loc] = veh
    end
    BoatsSpawned = true
end

function SetClosestBerthBoat()
    local pos = GetEntityCoords(PlayerPedId(), true)
    local current = nil
    local dist = nil

    for id, veh in pairs(VRBoatshop.Locations["berths"]) do
        if current ~= nil then
            if #(pos - vector3(VRBoatshop.Locations["berths"][id]["coords"]["buy"]["x"], VRBoatshop.Locations["berths"][id]["coords"]["buy"]["y"], VRBoatshop.Locations["berths"][id]["coords"]["buy"]["z"])) < dist then
                current = id
                dist = #(pos - vector3(VRBoatshop.Locations["berths"][id]["coords"]["buy"]["x"], VRBoatshop.Locations["berths"][id]["coords"]["buy"]["y"], VRBoatshop.Locations["berths"][id]["coords"]["buy"]["z"]))
            end
        else
            dist = #(pos - vector3(VRBoatshop.Locations["berths"][id]["coords"]["buy"]["x"], VRBoatshop.Locations["berths"][id]["coords"]["buy"]["y"], VRBoatshop.Locations["berths"][id]["coords"]["buy"]["z"]))
            current = id
        end
    end
    if current ~= ClosestBerth then
        ClosestBerth = current
    end
end

Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)

        local inRange = false

        local distance = #(pos - vector3(VRBoatshop.Locations["berths"][ClosestBerth]["coords"]["boat"]["x"], VRBoatshop.Locations["berths"][ClosestBerth]["coords"]["boat"]["y"], VRBoatshop.Locations["berths"][ClosestBerth]["coords"]["boat"]["z"]))

        if distance < 15 then
            local BuyLocation = {
                x = VRBoatshop.Locations["berths"][ClosestBerth]["coords"]["buy"]["x"],
                y = VRBoatshop.Locations["berths"][ClosestBerth]["coords"]["buy"]["y"],
                z = VRBoatshop.Locations["berths"][ClosestBerth]["coords"]["buy"]["z"]
            }

            DrawMarker(2, BuyLocation.x, BuyLocation.y, BuyLocation.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.5, 0.15, 255, 55, 15, 255, false, false, false, true, false, false, false)
            local BuyDistance = #(pos - vector3(BuyLocation.x, BuyLocation.y, BuyLocation.z))

            if BuyDistance < 2 then                
                local currentBoat = VRBoatshop.Locations["berths"][ClosestBerth]["boatModel"]

                DrawMarker(2, VRBoatshop.Locations["berths"][ClosestBerth]["coords"]["boat"]["x"], VRBoatshop.Locations["berths"][ClosestBerth]["coords"]["boat"]["y"], VRBoatshop.Locations["berths"][ClosestBerth]["coords"]["boat"]["z"] + 1.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 0.5, -0.30, 15, 255, 55, 255, false, false, false, true, false, false, false)

                if not Buying then
                    DrawText3D(BuyLocation.x, BuyLocation.y, BuyLocation.z + 0.3, '~g~E~w~ - '..VRBoatshop.ShopBoats[currentBoat]["label"]..' buy for ~b~$'..VRBoatshop.ShopBoats[currentBoat]["price"])
                    if IsControlJustPressed(0, 38) then
                        Buying = true
                    end
                else
                    DrawText3D(BuyLocation.x, BuyLocation.y, BuyLocation.z + 0.3, 'Are you sure ~g~7~w~ Yes / ~r~8~w~ No ~b~($'..VRBoatshop.ShopBoats[currentBoat]["price"]..',-)')
                    if IsControlJustPressed(0, 161) or IsDisabledControlJustReleased(0, 161) then
                        TriggerServerEvent('vr-diving:server:BuyBoat', VRBoatshop.Locations["berths"][ClosestBerth]["boatModel"], ClosestBerth)
                        Buying = false
                    elseif IsControlJustPressed(0, 162) or IsDisabledControlJustReleased(0, 162) then
                        Buying = false
                    end
                end
            elseif BuyDistance > 2.5 then
                if Buying then
                    Buying = false
                end
            end
        end

        Citizen.Wait(3)
    end
end)

RegisterNetEvent('vr-diving:client:BuyBoat')
AddEventHandler('vr-diving:client:BuyBoat', function(boatModel, plate)
    DoScreenFadeOut(250)
    Citizen.Wait(250)
    VRCore.Functions.SpawnVehicle(boatModel, function(veh)
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        exports['LegacyFuel']:SetFuel(veh, 100)
        SetVehicleNumberPlateText(veh, plate)
        SetEntityHeading(veh, VRBoatshop.SpawnVehicle.w)
        TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(veh))
    end, VRBoatshop.SpawnVehicle, false)
    SetTimeout(1000, function()
        DoScreenFadeIn(250)
    end)
end)

Citizen.CreateThread(function()
    BoatShop = AddBlipForCoord(VRBoatshop.Locations["berths"][1]["coords"]["boat"]["x"], VRBoatshop.Locations["berths"][1]["coords"]["boat"]["y"], VRBoatshop.Locations["berths"][1]["coords"]["boat"]["z"])

    SetBlipSprite (BoatShop, 410)
    SetBlipDisplay(BoatShop, 4)
    SetBlipScale  (BoatShop, 0.8)
    SetBlipAsShortRange(BoatShop, true)
    SetBlipColour(BoatShop, 3)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("LSYMC Haven")
    EndTextCommandSetBlipName(BoatShop)
end)
