local NumberCharset = {}
local Charset = {}

for i = 48,  57 do table.insert(NumberCharset, string.char(i)) end
for i = 65,  90 do table.insert(Charset, string.char(i)) end
for i = 97, 122 do table.insert(Charset, string.char(i)) end

-- code

RegisterNetEvent('vr-vehicleshop:server:buyShowroomVehicle')
AddEventHandler('vr-vehicleshop:server:buyShowroomVehicle', function(vehicle)
    local src = source
    local pData = VRCore.Functions.GetPlayer(src)
    local cid = pData.PlayerData.citizenid
    local cash = pData.PlayerData.money["cash"]
    local bank = pData.PlayerData.money["bank"]
    local vehiclePrice = VRCore.Shared.Vehicles[vehicle]["price"]
    local plate = GeneratePlate()

    if (cash - vehiclePrice) >= 0 then
        exports.ghmattimysql:execute('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state) VALUES (@license, @citizenid, @vehicle, @hash, @mods, @plate, @state)', {
            ['@license'] = pData.PlayerData.license,
            ['@citizenid'] = cid,
            ['@vehicle'] = vehicle,
            ['@hash'] = GetHashKey(vehicle),
            ['@mods'] = '{}',
            ['@plate'] = plate,
            ['@state'] = 0
        })
        TriggerClientEvent("VRCore:Notify", src, "Success! Your vehicle will be waiting for you outside", "success", 5000)
        TriggerClientEvent('vr-vehicleshop:client:buyShowroomVehicle', src, vehicle, plate)
        pData.Functions.RemoveMoney('cash', vehiclePrice, "vehicle-bought-in-showroom")
        TriggerEvent("vr-log:server:CreateLog", "vehicleshop", "Vehicle purchased (showroom)", "green", "**"..GetPlayerName(src) .. "** bought a " .. VRCore.Shared.Vehicles[vehicle]["name"] .. " for $" .. vehiclePrice .. " with cash")
    elseif (bank - vehiclePrice) >= 0 then
        exports.ghmattimysql:execute('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state) VALUES (@license, @citizenid, @vehicle, @hash, @mods, @plate, @state)', {
            ['@license'] = pData.PlayerData.license,
            ['@citizenid'] = cid,
            ['@vehicle'] = vehicle,
            ['@hash'] = GetHashKey(vehicle),
            ['@mods'] = '{}',
            ['@plate'] = plate,
            ['@state'] = 0
        })
        TriggerClientEvent("VRCore:Notify", src, "Success! Your vehicle will be waiting for you outside", "success", 5000)
        TriggerClientEvent('vr-vehicleshop:client:buyShowroomVehicle', src, vehicle, plate)
        pData.Functions.RemoveMoney('bank', vehiclePrice, "vehicle-bought-in-showroom")
        TriggerEvent("vr-log:server:CreateLog", "vehicleshop", "Vehicle purchased (showroom)", "green", "**"..GetPlayerName(src) .. "** bought a " .. VRCore.Shared.Vehicles[vehicle]["name"] .. " for $" .. vehiclePrice .. " from the bank")
    elseif (cash - vehiclePrice) < 0 then
        TriggerClientEvent("VRCore:Notify", src, "You don't have enough money, you're missing $"..format_thousand(vehiclePrice - cash).." cash", "error", 5000)
    elseif (bank - vehiclePrice) < 0 then
        TriggerClientEvent("VRCore:Notify", src, "You don't have enough money, you're missing $"..format_thousand(vehiclePrice - bank).." in the bank", "error", 5000)
    end
end)

function format_thousand(v)
    local s = string.format("%d", math.floor(v))
    local pos = string.len(s) % 3
    if pos == 0 then pos = 3 end
    return string.sub(s, 1, pos)
            .. string.gsub(string.sub(s, pos+1), "(...)", ".%1")
end

function GeneratePlate()
    local plate = tostring(GetRandomNumber(1)) .. GetRandomLetter(2) .. tostring(GetRandomNumber(3)) .. GetRandomLetter(2)
    local result = exports.ghmattimysql:scalarSync('SELECT plate FROM player_vehicles WHERE plate=@plate', {['@plate'] = plate})
    if result then
        plate = tostring(GetRandomNumber(1)) .. GetRandomLetter(2) .. tostring(GetRandomNumber(3)) .. GetRandomLetter(2)
    end
    return plate:upper()
end

function GetRandomNumber(length)
	Citizen.Wait(1)
	math.randomseed(GetGameTimer())
	if length > 0 then
		return GetRandomNumber(length - 1) .. NumberCharset[math.random(1, #NumberCharset)]
	else
		return ''
	end
end

function GetRandomLetter(length)
	Citizen.Wait(1)
	math.randomseed(GetGameTimer())
	if length > 0 then
		return GetRandomLetter(length - 1) .. Charset[math.random(1, #Charset)]
	else
		return ''
	end
end

RegisterServerEvent('vr-vehicleshop:server:setShowroomCarInUse')
AddEventHandler('vr-vehicleshop:server:setShowroomCarInUse', function(showroomVehicle, bool, currentindex)
    VR.VehicleShops[currentindex]["ShowroomVehicles"][showroomVehicle].inUse = bool
    TriggerClientEvent('vr-vehicleshop:client:setShowroomCarInUse', -1, showroomVehicle, bool)
end)

RegisterServerEvent('vr-vehicleshop:server:setShowroomVehicle')
AddEventHandler('vr-vehicleshop:server:setShowroomVehicle', function(vData, k, currentindex)
    VR.VehicleShops[currentindex]["ShowroomVehicles"][k].chosenVehicle = vData
    TriggerClientEvent('vr-vehicleshop:client:setShowroomVehicle', -1, vData, k)
end)

function CheckOwnedJob(source, grade)
    local ownedjob = false
    local Player = VRCore.Functions.GetPlayer(source)

    for k, v in pairs(VR.VehicleShops) do
        if v["OwnedJob"] then
            if v["OwnedJob"] == Player.PlayerData.job.name then
                if grade ~= nil and grade == Player.PlayerData.job.grade.level then
                    ownedjob = true
                elseif grade == nil then
                    ownedjob = true
                end
                break
            end
        end
    end

    return ownedjob
end

VRCore.Commands.Add("sell", "Sell Vehicle (Car Dealer Only)", {{name="ID", help="ID of Player to sell to"}}, true, function(source, args)
    local TargetId = tonumber(args[1])

    if CheckOwnedJob(source) then
        if TargetId ~= nil then
            if #(GetEntityCoords(GetPlayerPed(source)) - GetEntityCoords(GetPlayerPed(TargetId))) < 3.0 then
                TriggerClientEvent('vr-vehicleshop:client:SellCustomVehicle', source, TargetId)
            else
                TriggerClientEvent('VRCore:Notify', source, 'The provided Player with ID '..TargetId..' is not nearby', 'error')
            end
        else
            TriggerClientEvent('VRCore:Notify', source, 'You must provide a Player ID!', 'error')
        end
    else
        TriggerClientEvent('VRCore:Notify', source, "You don't have access to this command", 'error')
    end
end)

VRCore.Commands.Add("testdrive", "Test Drive Vehicle (Car Dealer Only)", {}, false, function(source, args)
    if CheckOwnedJob(source) then
        TriggerClientEvent('vr-vehicleshop:client:DoTestrit', source, GeneratePlate())
    else
        TriggerClientEvent('VRCore:Notify', source, "You don't have access to this command", 'error')
    end
end)

RegisterServerEvent('vr-vehicleshop:server:SellCustomVehicle')
AddEventHandler('vr-vehicleshop:server:SellCustomVehicle', function(TargetId, ShowroomSlot)
    TriggerClientEvent('vr-vehicleshop:client:SetVehicleBuying', TargetId, ShowroomSlot)
end)
