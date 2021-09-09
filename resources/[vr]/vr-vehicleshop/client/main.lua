local ClosestVehicle, ClosestShopIndex = 1, 1
local inMenu = false
local modelLoaded = true
local testritveh = 0
local fakecar = {model = '', car = nil}
local PlayerJob = {}
local isLoggedIn = false
local buySure = false
local Categories = {}

Citizen.CreateThread(function()
    Wait(1500)
    for i = 1, #VR.VehicleShops do
        for k, v in pairs(VR.VehicleShops[i]["Categories"]) do
            Categories[k] = {
                label = v,
                vehicles = {}
            }
        end
    end

    for k, v in pairs(VRCore.Shared.Vehicles) do
        for cat,_ in pairs(Categories) do
            if VRCore.Shared.Vehicles[k]["category"] == cat then
                table.insert(Categories[cat].vehicles, VRCore.Shared.Vehicles[k])
            end
        end
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Wait(200)
        PlayerJob = VRCore.Functions.GetPlayerData().job
        isLoggedIn = true
    end
end)

RegisterNetEvent('VRCore:Client:OnPlayerLoaded')
AddEventHandler('VRCore:Client:OnPlayerLoaded', function()
    PlayerJob = VRCore.Functions.GetPlayerData().job
    isLoggedIn = true
end)

RegisterNetEvent('VRCore:Client:OnPlayerUnload')
AddEventHandler('VRCore:Client:OnPlayerUnload', function()
    isLoggedIn = false
    PlayerJob = {}
end)

RegisterNetEvent('VRCore:Client:OnJobUpdate')
AddEventHandler('VRCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

Citizen.CreateThread(function()
    for i = 1, #VR.VehicleShops do
        local Dealer = AddBlipForCoord(VR.VehicleShops[i]["Location"])
        SetBlipSprite (Dealer, 326)
        SetBlipDisplay(Dealer, 4)
        SetBlipScale  (Dealer, 0.75)
        SetBlipAsShortRange(Dealer, true)
        SetBlipColour(Dealer, 3)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(VR.VehicleShops[i]["ShopLabel"])
        EndTextCommandSetBlipName(Dealer)
    end
end)

Citizen.CreateThread(function()
    Citizen.Wait(2000)

    for k, v in pairs(Categories) do
        for i = 1, #VR.VehicleShops do
            local toInsertVehicles = {}
            local vehiclesTable = v.vehicles

            if VR.VehicleShops[i]["Categories"][k] then
                for k, v in pairs(vehiclesTable) do
                    if v["shop"] == VR.VehicleShops[i]["ShopName"] then
                        table.insert(toInsertVehicles, vehiclesTable[k])
                    end
                end

                table.insert(VR.VehicleShops[i]["menu"]["vehicles"]["buttons"], {
                    menu = k,
                    name = v.label,
                    description = {}
                })

                VR.VehicleShops[i]["menu"][k] = {
                    title = k,
                    name = v.label,
                    buttons = toInsertVehicles
                }
            end
        end
    end
end)

Citizen.CreateThread(function()
    Citizen.Wait(1000)
    while true do
        if isLoggedIn and VR.VehicleShops[ClosestShopIndex]["OwnedJob"] then
            local ped = PlayerPedId()
            local bringcoords = VR.VehicleShops[ClosestShopIndex]["ReturnLocation"]
            local pos = GetEntityCoords(ped, false)
            local dist = #(pos - vector3(bringcoords.x, bringcoords.y, bringcoords.z))

            if IsPedInAnyVehicle(ped, false) then
                if dist < 15 then
                    local veh = GetVehiclePedIsIn(ped)
                    DrawMarker(2, bringcoords.x, bringcoords.y, bringcoords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.1, 255, 255, 255, 155, false, false, false, false, false, false, false)

                    if dist < 2 then
                        if veh == testritveh then
                            DrawText3Ds(bringcoords.x, bringcoords.y, bringcoords.z, '~g~E~w~ - Return Vehicle')
                            if IsControlJustPressed(0, 38) then
                                testritveh = 0
                                VRCore.Functions.DeleteVehicle(veh)
                            end
                        end
                    end
                end
            end

            if testritveh == 0 then
                Citizen.Wait(2000)
            end
        end

        Citizen.Wait(3)
    end
end)

Citizen.CreateThread(function()
    Citizen.Wait(1000)
    for d = 1, #VR.VehicleShops do
        for i = 1, #VR.VehicleShops[d]["ShowroomVehicles"] do
            local oldVehicle = GetClosestVehicle(VR.VehicleShops[d]["ShowroomVehicles"][i].coords.x, VR.VehicleShops[d]["ShowroomVehicles"][i].coords.y, VR.VehicleShops[d]["ShowroomVehicles"][i].coords.z, 3.0, 0, 70)
            if oldVehicle ~= 0 then
                VRCore.Functions.DeleteVehicle(oldVehicle)
            end

            local model = GetHashKey(VR.VehicleShops[d]["ShowroomVehicles"][i].chosenVehicle)
            RequestModel(model)
            while not HasModelLoaded(model) do
                Citizen.Wait(0)
            end

            local veh = CreateVehicle(model, VR.VehicleShops[d]["ShowroomVehicles"][i].coords.x, VR.VehicleShops[d]["ShowroomVehicles"][i].coords.y, VR.VehicleShops[d]["ShowroomVehicles"][i].coords.z, VR.VehicleShops[d]["ShowroomVehicles"][i].coords.w, false, false)
            SetModelAsNoLongerNeeded(model)
            SetVehicleOnGroundProperly(veh)
            SetEntityInvincible(veh,true)
            SetVehicleDoorsLocked(veh, 3)
            SetEntityHeading(veh, VR.VehicleShops[d]["ShowroomVehicles"][i].coords.w)
            FreezeEntityPosition(veh,true)
            SetVehicleNumberPlateText(veh, i .. "CARSALE")
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        if isLoggedIn then
            local pos = GetEntityCoords(PlayerPedId(), true)
            for i = 1, #VR.VehicleShops do
                local shopDist = #(pos - VR.VehicleShops[i]["Location"])
                if shopDist <= 20 then
                    ClosestShopIndex = i
                    setClosestShowroomVehicle(i)
                end
            end
        end
        Citizen.Wait(1000)
    end
end)

Citizen.CreateThread(function()
    Citizen.Wait(1000)
    while true do
        
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local dist = #(pos - vector3(VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].coords.x, VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].coords.y, VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].coords.z))
        if ClosestVehicle ~= nil then
            if dist < 2.5 then
                if not VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].inUse then
                    local vehicleHash = GetHashKey(VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].chosenVehicle)
                    local displayName = VRCore.Shared.Vehicles[VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].chosenVehicle]["name"]
                    local vehPrice = VRCore.Shared.Vehicles[VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].chosenVehicle]["price"]

                    if not VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].inUse and not VR.VehicleShops[ClosestShopIndex]["OwnedJob"] then
                        if not VR.VehicleShops[ClosestShopIndex]["opened"] then
                            if not buySure then
                                DrawText3Ds(VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].coords.x, VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].coords.y, VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].coords.z + 1.8, '~g~G~w~ - Change Vehicle (~g~'..displayName..'~w~)')
                            end
                            if not buySure then
                                DrawText3Ds(VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].coords.x, VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].coords.y, VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].coords.z + 1.70, '~g~E~w~ - Purchase Vehicle (~g~$'..vehPrice..'~w~)')
                            elseif buySure then
                                DrawText3Ds(VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].coords.x, VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].coords.y, VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].coords.z + 1.65, 'Are You Sure? | ~g~[7]~w~ Confirm -/- ~r~[8]~w~ Cancel')
                            end
                        elseif VR.VehicleShops[ClosestShopIndex]["opened"] then
                            if modelLoaded then
                                DrawText3Ds(VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].coords.x, VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].coords.y, VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].coords.z + 1.65, 'Choosing A Vehicle')
                            else
                                DrawText3Ds(VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].coords.x, VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].coords.y, VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].coords.z + 1.65, 'Model Loading')
                            end
                        end
                    elseif VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].inUse and not VR.VehicleShops[ClosestShopIndex]["OwnedJob"] then
                        DrawText3Ds(VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].coords.x, VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].coords.y, VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].coords.z + 1.65, 'Currently In Use')
                    else
                        if CheckJob() then
                            DrawText3Ds(VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].coords.x, VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].coords.y, VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].coords.z + 1.9, '~g~G~w~ - Change Vehicle')
                            DrawText3Ds(VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].coords.x, VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].coords.y, VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].coords.z + 1.75, '~b~/sell [id]~w~ - Sell Vehicle ~b~/testdrive~w~ - Test Drive')
                        end

                        if VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].buying then
                            DrawText3Ds(VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].coords.x, VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].coords.y, VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].coords.z + 1.6, '~g~7~w~ - Confirm / ~r~8~w~ - Cancel - ~g~($'..VRCore.Shared.Vehicles[VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].chosenVehicle].price..',-)')
                            
                            if IsDisabledControlJustPressed(0, 161) then
                                TriggerServerEvent('vr-vehicleshop:server:buyShowroomVehicle', VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].chosenVehicle)
                                VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].buying = false
                            end

                            if IsDisabledControlJustPressed(0, 162) then
                                VRCore.Functions.Notify('Purchase Cancelled', 'error')
                                VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].buying = false
                            end
                        end
                    end

                    if not VR.VehicleShops[ClosestShopIndex]["opened"] then
                        if IsControlJustPressed(0, 47) then
                            if VR.VehicleShops[ClosestShopIndex]["opened"] then
                                CloseCreator()
                            else
                                OpenCreator()
                            end
                        end
                    end

                    if VR.VehicleShops[ClosestShopIndex]["opened"] then
                        local ped = PlayerPedId()
                        local menu = VR.VehicleShops[ClosestShopIndex]["menu"][VR.VehicleShops[ClosestShopIndex]["currentmenu"]]
                        local y = VR.VehicleShops[ClosestShopIndex]["menu"]["y"] + 0.12
                        buttoncount = tablelength(menu["buttons"])
                        local selected = false

                        for i,button in pairs(menu["buttons"]) do
                            if i >= VR.VehicleShops[ClosestShopIndex]["menu"]["from"] and i <= VR.VehicleShops[ClosestShopIndex]["menu"]["to"] then

                                if i == VR.VehicleShops[ClosestShopIndex]["selectedbutton"] then
                                    selected = true
                                else
                                    selected = false
                                end
                                drawMenuButton(button,VR.VehicleShops[ClosestShopIndex]["menu"]["x"],y,selected)
                                if button.price ~= nil then

                                    drawMenuRight("$"..button.price,VR.VehicleShops[ClosestShopIndex]["menu"]["x"],y,selected)

                                end
                                y = y + 0.04
                                if isValidMenu(VR.VehicleShops[ClosestShopIndex]["currentmenu"]) then
                                    if selected then
                                        if IsControlJustPressed(1, 18) then
                                            if modelLoaded then
                                                TriggerServerEvent('vr-vehicleshop:server:setShowroomVehicle', button.model, ClosestVehicle, ClosestShopIndex)
                                            end
                                        end
                                    end
                                end
                                if selected and ( IsControlJustPressed(1,38) or IsControlJustPressed(1, 18) ) then
                                    ButtonSelected(button)
                                end
                            end
                        end
                    end

                    if VR.VehicleShops[ClosestShopIndex]["opened"] then
                        if IsControlJustPressed(1,202) then
                            Back()
                        end
                        if IsControlJustReleased(1,202) then
                            backlock = false
                        end
                        if IsControlJustPressed(1,188) then
                            if modelLoaded then
                                if VR.VehicleShops[ClosestShopIndex]["selectedbutton"] > 1 then
                                    VR.VehicleShops[ClosestShopIndex]["selectedbutton"] = VR.VehicleShops[ClosestShopIndex]["selectedbutton"] -1
                                    if buttoncount > 10 and VR.VehicleShops[ClosestShopIndex]["selectedbutton"] < VR.VehicleShops[ClosestShopIndex]["menu"]["from"] then
                                        VR.VehicleShops[ClosestShopIndex]["menu"]["from"] = VR.VehicleShops[ClosestShopIndex]["menu"]["from"] -1
                                        VR.VehicleShops[ClosestShopIndex]["menu"]["to"] = VR.VehicleShops[ClosestShopIndex]["menu"]["to"] - 1
                                    end
                                end
                            end
                        end
                        if IsControlJustPressed(1,187)then
                            if modelLoaded then
                                if VR.VehicleShops[ClosestShopIndex]["selectedbutton"] < buttoncount then
                                    VR.VehicleShops[ClosestShopIndex]["selectedbutton"] = VR.VehicleShops[ClosestShopIndex]["selectedbutton"] +1
                                    if buttoncount > 10 and VR.VehicleShops[ClosestShopIndex]["selectedbutton"] > VR.VehicleShops[ClosestShopIndex]["menu"]["to"] then
                                        VR.VehicleShops[ClosestShopIndex]["menu"]["to"] = VR.VehicleShops[ClosestShopIndex]["menu"]["to"] + 1
                                        VR.VehicleShops[ClosestShopIndex]["menu"]["from"] = VR.VehicleShops[ClosestShopIndex]["menu"]["from"] + 1
                                    end
                                end
                            end
                        end
                    end

                    if GetVehiclePedIsTryingToEnter(PlayerPedId()) ~= nil and GetVehiclePedIsTryingToEnter(PlayerPedId()) ~= 0 then
                        ClearPedTasksImmediately(PlayerPedId())
                    end

                    if IsControlJustPressed(0, 38) then
                        if not VR.VehicleShops[ClosestShopIndex]["opened"] then
                            if not buySure then
                                buySure = true
                            end
                        end
                    end

                    if IsDisabledControlJustPressed(0, 161) then
                        if buySure then
                            local class = VRCore.Shared.Vehicles[VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].chosenVehicle]["category"]
                            TriggerServerEvent('vr-vehicleshop:server:buyShowroomVehicle', VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].chosenVehicle)
                            buySure = false
                        end
                    end
                    if IsDisabledControlJustPressed(0, 162) then
                        VRCore.Functions.Notify('Purchase Cancelled', 'error')
                        buySure = false
                    end
                    DisableControlAction(0, 161, true)
                    DisableControlAction(0, 162, true)
                elseif VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].inUse then
                    DrawText3Ds(VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].coords.x, VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].coords.y, VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].coords.z + 0.5, 'Currently In Use')
                end
            elseif dist > 1.5 then
                if VR.VehicleShops[ClosestShopIndex]["opened"] then
                    CloseCreator()
                end
            end
        end

        Citizen.Wait(3)
    end
end)

RegisterNetEvent('vr-vehicleshop:client:DoTestrit')
AddEventHandler('vr-vehicleshop:client:DoTestrit', function(plate)
    if ClosestVehicle ~= 0 then
        VRCore.Functions.SpawnVehicle(VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].chosenVehicle, function(veh)
            TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
            exports['LegacyFuel']:SetFuel(veh, 100)
            SetVehicleNumberPlateText(veh, plate)
            SetEntityAsMissionEntity(veh, true, true)
            SetEntityHeading(veh, VR.VehicleShops[ClosestShopIndex]["VehicleSpawn"].w)
            TriggerEvent('vehiclekeys:client:SetOwner', GetVehicleNumberPlateText(veh))
            TriggerServerEvent('vr-vehicletuning:server:SaveVehicleProps', VRCore.Functions.GetVehicleProperties(veh))
            testritveh = veh

            VRCore.Functions.Notify("Good luck on the test drive! You have a 3 minute time limit until the vehicle is deleted.")

            SetTimeout(VR.VehicleShops[ClosestShopIndex]["TestDriveTimeLimit"] * 60000, function()
                if testritveh ~= 0 then
                    testritveh = 0
                    VRCore.Functions.DeleteVehicle(veh)
                    VRCore.Functions.Notify("The time limit has been reached, the vehicle has been deleted")
                end
            end)
        end, VR.VehicleShops[ClosestShopIndex]["VehicleSpawn"], false)
    end
end)

RegisterNetEvent('vr-vehicleshop:client:SellCustomVehicle')
AddEventHandler('vr-vehicleshop:client:SellCustomVehicle', function(TargetId)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)

    local VehicleDist = #(pos - vector3(VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].coords.x, VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].coords.y, VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].coords.z))
    if VehicleDist < 2.5 then
        TriggerServerEvent('vr-vehicleshop:server:SellCustomVehicle', TargetId, ClosestVehicle)
    else
        VRCore.Functions.Notify('Not Near The Vehicle', 'error')
    end
end)

RegisterNetEvent('vr-vehicleshop:client:SetVehicleBuying')
AddEventHandler('vr-vehicleshop:client:SetVehicleBuying', function(slot)
    VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][slot].buying = true
    SetTimeout((60 * 1000) * 5, function()
        VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][slot].buying = false
    end)
end)

RegisterNetEvent('vr-vehicleshop:client:setShowroomCarInUse')
AddEventHandler('vr-vehicleshop:client:setShowroomCarInUse', function(showroomVehicle, inUse)
    VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][showroomVehicle].inUse = inUse
end)

RegisterNetEvent('vr-vehicleshop:client:setShowroomVehicle')
AddEventHandler('vr-vehicleshop:client:setShowroomVehicle', function(showroomVehicle, k)
    if VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][k].chosenVehicle ~= showroomVehicle then
        VRCore.Functions.DeleteVehicle(GetClosestVehicle(VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][k].coords.x, VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][k].coords.y, VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][k].coords.z, 3.0, 0, 70))
        modelLoaded = false
        Wait(250)
        local model = GetHashKey(showroomVehicle)
        RequestModel(model)
        while not HasModelLoaded(model) do
            Citizen.Wait(250)
        end
        local veh = CreateVehicle(model, VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][k].coords.x, VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][k].coords.y, VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][k].coords.z, false, false)
        SetModelAsNoLongerNeeded(model)
        SetVehicleOnGroundProperly(veh)
        SetEntityInvincible(veh,true)
        SetEntityHeading(veh, VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][k].coords.w)
        SetVehicleDoorsLocked(veh, 3)
        FreezeEntityPosition(veh, true)
        SetVehicleNumberPlateText(veh, k .. "CARSALE")
        modelLoaded = true
        VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][k].chosenVehicle = showroomVehicle
    end
end)

RegisterNetEvent('vr-vehicleshop:client:buyShowroomVehicle')
AddEventHandler('vr-vehicleshop:client:buyShowroomVehicle', function(vehicle, plate)
    VRCore.Functions.SpawnVehicle(vehicle, function(veh)
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        exports['LegacyFuel']:SetFuel(veh, 100)
        SetVehicleNumberPlateText(veh, plate)
        SetEntityHeading(veh, VR.VehicleShops[ClosestShopIndex]["VehicleSpawn"].w)
        SetEntityAsMissionEntity(veh, true, true)
        TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(veh))
        TriggerServerEvent("vr-vehicletuning:server:SaveVehicleProps", VRCore.Functions.GetVehicleProperties(veh))
    end, VR.VehicleShops[ClosestShopIndex]["VehicleSpawn"], true)
end)

function setClosestShowroomVehicle(i)
    local pos = GetEntityCoords(PlayerPedId(), true)
    local current = nil
    local dist = nil

    for id, veh in pairs(VR.VehicleShops[i]["ShowroomVehicles"]) do
        local dist2 = #(pos - vector3(VR.VehicleShops[i]["ShowroomVehicles"][id].coords.x, VR.VehicleShops[i]["ShowroomVehicles"][id].coords.y, VR.VehicleShops[i]["ShowroomVehicles"][id].coords.z))
        if current ~= nil then
            if dist2 < dist then
                current = id
                dist = dist2
            end
        else
            dist = dist2
            current = id
        end
    end
    if current ~= ClosestVehicle then
        ClosestVehicle = current
    end
end


function isValidMenu(menu)
    local retval = false
    for k, v in pairs(VR.VehicleShops[ClosestShopIndex]["menu"]["vehicles"]["buttons"]) do
        if menu == v.menu then
            retval = true
        end
    end
    return retval
end

function OpenCreator()
	VR.VehicleShops[ClosestShopIndex]["currentmenu"] = "main"
	VR.VehicleShops[ClosestShopIndex]["opened"] = true
    VR.VehicleShops[ClosestShopIndex]["selectedbutton"] = 1
    TriggerServerEvent('vr-vehicleshop:server:setShowroomCarInUse', ClosestVehicle, false, ClosestShopIndex)
end

function CloseCreator(name, veh, price, financed)
    VR.VehicleShops[ClosestShopIndex]["opened"] = false
    VR.VehicleShops[ClosestShopIndex]["menu"]["from"] = 1
    VR.VehicleShops[ClosestShopIndex]["menu"]["to"] = 10
    VR.VehicleShops[ClosestShopIndex]["ShowroomVehicles"][ClosestVehicle].inUse = false
    TriggerServerEvent('vr-vehicleshop:server:setShowroomCarInUse', ClosestVehicle, false, ClosestShopIndex)
end

function OpenMenu(menu)
    VR.VehicleShops[ClosestShopIndex]["lastmenu"] = VR.VehicleShops[ClosestShopIndex]["currentmenu"]
    fakecar = {model = '', car = nil}
	if menu == "vehicles" then
		VR.VehicleShops[ClosestShopIndex]["lastmenu"] = "main"
	end
	VR.VehicleShops[ClosestShopIndex]["menu"]["from"] = 1
	VR.VehicleShops[ClosestShopIndex]["menu"]["to"] = 10
	VR.VehicleShops[ClosestShopIndex]["selectedbutton"] = 1
	VR.VehicleShops[ClosestShopIndex]["currentmenu"] = menu
end

function Back()
	if backlock then
		return
	end
	backlock = true
	if VR.VehicleShops[ClosestShopIndex]["currentmenu"] == "main" then
		CloseCreator()
	elseif isValidMenu(VR.VehicleShops[ClosestShopIndex]["currentmenu"]) then
		if DoesEntityExist(fakecar.car) then
			Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(fakecar.car))
		end
		fakecar = {model = '', car = nil}
		OpenMenu(VR.VehicleShops[ClosestShopIndex]["lastmenu"])
	else
		OpenMenu(VR.VehicleShops[ClosestShopIndex]["lastmenu"])
	end
end

function ButtonSelected(button)
	local ped = PlayerPedId()
	local this = VR.VehicleShops[ClosestShopIndex]["currentmenu"]
    local btn = button["name"]
    local btnindex = nil

    for k, v in pairs(VR.VehicleShops[ClosestShopIndex]["Categories"]) do
        if btn == VR.VehicleShops[ClosestShopIndex]["Categories"][k] then
            btnindex = k
            break
        end
    end

	if this == "main" then
		if btn == "Categories" then
			OpenMenu('vehicles')
		end
	elseif this == "vehicles" then
        if btn == VR.VehicleShops[ClosestShopIndex]["Categories"][btnindex] then
            OpenMenu(btnindex)
        end
	end
end

function CheckJob()
    if PlayerJob ~= nil then
        if type(VR.VehicleShops[ClosestShopIndex]["OwnedJob"]) == "table" then
            for k, v in pairs(VR.VehicleShops[ClosestShopIndex]["OwnedJob"]) do
                if PlayerJob.name == v then
                    return true
                end
            end
        else
            if PlayerJob.name == VR.VehicleShops[ClosestShopIndex]["OwnedJob"] then
                return true
            end
        end
    end
    return false
end

function drawMenuButton(button,x,y,selected)
	local menu = VR.VehicleShops[ClosestShopIndex]["menu"]
	SetTextFont(menu["font"])
	SetTextProportional(0)
	SetTextScale(0.25, 0.25)
	if selected then
		SetTextColour(0, 0, 0, 255)
	else
		SetTextColour(255, 255, 255, 255)
	end
	SetTextCentre(0)
	SetTextEntry("STRING")
	AddTextComponentString(button["name"])
	if selected then
		DrawRect(x,y,menu["width"],menu["height"],255,255,255,255)
	else
		DrawRect(x,y,menu["width"],menu["height"],0, 0, 0,220)
	end
	DrawText(x - menu["width"]/2 + 0.005, y - menu["height"]/2 + 0.0028)
end

function drawMenuRight(txt,x,y,selected)
	local menu = VR.VehicleShops[ClosestShopIndex]["menu"]
	SetTextFont(menu["font"])
	SetTextProportional(0)
	SetTextScale(0.2, 0.2)
	if selected then
		SetTextColour(0,0,0, 255)
	else
		SetTextColour(255, 255, 255, 255)
		
	end
	SetTextCentre(1)
	SetTextEntry("STRING")
	AddTextComponentString(txt)
	DrawText(x + menu["width"]/2 + 0.025, y - menu["height"]/3 + 0.0002)

	if selected then
		DrawRect(x + menu["width"]/2 + 0.025, y,menu["width"] / 3,menu["height"],255, 255, 255,250)
	else
		DrawRect(x + menu["width"]/2 + 0.025, y,menu["width"] / 3,menu["height"],0, 0, 0,250) 
	end
end

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function DrawText3Ds(x, y, z, text)
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
