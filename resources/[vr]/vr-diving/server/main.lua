local CoralTypes = {
    ["dendrogyra_coral"] = math.random(70, 100),
    ["antipatharia_coral"] = math.random(50, 70),
}

-- Code

RegisterServerEvent('vr-diving:server:SetBerthVehicle')
AddEventHandler('vr-diving:server:SetBerthVehicle', function(BerthId, vehicleModel)
    TriggerClientEvent('vr-diving:client:SetBerthVehicle', -1, BerthId, vehicleModel)
    
    VRBoatshop.Locations["berths"][BerthId]["boatModel"] = boatModel
end)

RegisterServerEvent('vr-diving:server:SetDockInUse')
AddEventHandler('vr-diving:server:SetDockInUse', function(BerthId, InUse)
    VRBoatshop.Locations["berths"][BerthId]["inUse"] = InUse
    TriggerClientEvent('vr-diving:client:SetDockInUse', -1, BerthId, InUse)
end)

VRCore.Functions.CreateCallback('vr-diving:server:GetBusyDocks', function(source, cb)
    cb(VRBoatshop.Locations["berths"])
end)

RegisterServerEvent('vr-diving:server:BuyBoat')
AddEventHandler('vr-diving:server:BuyBoat', function(boatModel, BerthId)
    local BoatPrice = VRBoatshop.ShopBoats[boatModel]["price"]
    local src = source
    local Player = VRCore.Functions.GetPlayer(src)
    local PlayerMoney = {
        cash = Player.PlayerData.money.cash,
        bank = Player.PlayerData.money.bank,
    }
    local missingMoney = 0
    local plate = "VR"..math.random(1000, 9999)

    if PlayerMoney.cash >= BoatPrice then
        Player.Functions.RemoveMoney('cash', BoatPrice, "bought-boat")
        TriggerClientEvent('vr-diving:client:BuyBoat', src, boatModel, plate)
        InsertBoat(boatModel, Player, plate)
    elseif PlayerMoney.bank >= BoatPrice then
        Player.Functions.RemoveMoney('bank', BoatPrice, "bought-boat")
        TriggerClientEvent('vr-diving:client:BuyBoat', src, boatModel, plate)
        InsertBoat(boatModel, Player, plate)
    else
        if PlayerMoney.bank > PlayerMoney.cash then
            missingMoney = (BoatPrice - PlayerMoney.bank)
        else
            missingMoney = (BoatPrice - PlayerMoney.cash)
        end
        TriggerClientEvent('VRCore:Notify', src, 'Not Enough Money, You Are Missing $'..missingMoney..'', 'error')
    end
end)

function InsertBoat(boatModel, Player, plate)
    exports.ghmattimysql:execute('INSERT INTO player_boats (citizenid, model, plate) VALUES (@citizenid, @model, @plate)', {
        ['@citizenid'] = Player.PlayerData.citizenid,
        ['@model'] = boatModel,
        ['@plate'] = plate
    })
end

VRCore.Functions.CreateUseableItem("jerry_can", function(source, item)
    local Player = VRCore.Functions.GetPlayer(source)

    TriggerClientEvent("vr-diving:client:UseJerrycan", source)
end)

VRCore.Functions.CreateUseableItem("diving_gear", function(source, item)
    local Player = VRCore.Functions.GetPlayer(source)

    TriggerClientEvent("vr-diving:client:UseGear", source, true)
end)

RegisterServerEvent('vr-diving:server:RemoveItem')
AddEventHandler('vr-diving:server:RemoveItem', function(item, amount)
    local src = source
    local Player = VRCore.Functions.GetPlayer(src)

    Player.Functions.RemoveItem(item, amount)
end)

VRCore.Functions.CreateCallback('vr-diving:server:GetMyBoats', function(source, cb, dock)
    local src = source
    local Player = VRCore.Functions.GetPlayer(src)
    local result = exports.ghmattimysql:executeSync('SELECT * FROM player_boats WHERE citizenid=@citizenid AND boathouse=@boathouse', {['@citizenid'] = Player.PlayerData.citizenid, ['@boathouse'] = dock})
    if result[1] ~= nil then
        cb(result)
    else
        cb(nil)
    end
end)

VRCore.Functions.CreateCallback('vr-diving:server:GetDepotBoats', function(source, cb, dock)
    local src = source
    local Player = VRCore.Functions.GetPlayer(src)
    local result = exports.ghmattimysql:executeSync('SELECT * FROM player_boats WHERE citizenid=@citizenid AND state=@state', {['@citizenid'] = Player.PlayerData.citizenid, ['@state'] = 0})
    if result[1] ~= nil then
        cb(result)
    else
        cb(nil)
    end
end)

RegisterServerEvent('vr-diving:server:SetBoatState')
AddEventHandler('vr-diving:server:SetBoatState', function(plate, state, boathouse, fuel)
    local src = source
    local Player = VRCore.Functions.GetPlayer(src)
    local result = exports.ghmattimysql:scalarSync('SELECT 1 FROM player_boats WHERE plate=@plate', {['@plate'] = plate})
    if result ~= nil then
        exports.ghmattimysql:execute('UPDATE player_boats SET state=@state, boathouse=@boathouse, fuel=@fuel WHERE plate=@plate AND citizenid=@citizenid', {
            ['@state'] = state,
            ['@boathouse'] = boathouse,
            ['@fuel'] = fuel,
            ['@plate'] = plate,
            ['@citizenid'] = Player.PlayerData.citizenid
        })
    end
end)

RegisterServerEvent('vr-diving:server:CallCops')
AddEventHandler('vr-diving:server:CallCops', function(Coords)
    local src = source
    for k, v in pairs(VRCore.Functions.GetPlayers()) do
        local Player = VRCore.Functions.GetPlayer(v)
        if Player ~= nil then
            if (Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty) then
                local msg = "This coral may be stolen"
                TriggerClientEvent('vr-diving:client:CallCops', Player.PlayerData.source, Coords, msg)
                local alertData = {
                    title = "Illegal diving",
                    coords = {x = Coords.x, y = Coords.y, z = Coords.z},
                    description = msg,
                }
                TriggerClientEvent("vr-phone:client:addPoliceAlert", -1, alertData)
            end
        end
	end
end)

local AvailableCoral = {}

VRCore.Commands.Add("divingsuit", "Take off your diving suit", {}, false, function(source, args)
    local Player = VRCore.Functions.GetPlayer(source)
    TriggerClientEvent("vr-diving:client:UseGear", source, false)
end)

RegisterServerEvent('vr-diving:server:SellCoral')
AddEventHandler('vr-diving:server:SellCoral', function()
    local src = source
    local Player = VRCore.Functions.GetPlayer(src)

    if HasCoral(src) then
        for k, v in pairs(AvailableCoral) do
            local Item = Player.Functions.GetItemByName(v.item)
            local price = (Item.amount * v.price)
            local Reward = math.ceil(GetItemPrice(Item, price))

            if Item.amount > 1 then
                for i = 1, Item.amount, 1 do
                    Player.Functions.RemoveItem(Item.name, 1)
                    TriggerClientEvent('inventory:client:ItemBox', src, VRCore.Shared.Items[Item.name], "remove")
                    Player.Functions.AddMoney('cash', math.ceil((Reward / Item.amount)), "sold-coral")
                    Citizen.Wait(250)
                end
            else
                Player.Functions.RemoveItem(Item.name, 1)
                Player.Functions.AddMoney('cash', Reward, "sold-coral")
                TriggerClientEvent('inventory:client:ItemBox', src, VRCore.Shared.Items[Item.name], "remove")
            end
        end
    else
        TriggerClientEvent('VRCore:Notify', src, 'You don\'t have any coral to sell..', 'error')
    end
end)


function GetItemPrice(Item, price)
    if Item.amount > 5 then
        price = price / 100 * 80
    elseif Item.amount > 10 then
        price = price / 100 * 70
    elseif Item.amount > 15 then
        price = price / 100 * 50
    end
    return price
end

function HasCoral(src)
    local Player = VRCore.Functions.GetPlayer(src)
    local retval = false
    AvailableCoral = {}

    for k, v in pairs(VRDiving.CoralTypes) do
        local Item = Player.Functions.GetItemByName(v.item)
        if Item ~= nil then
            table.insert(AvailableCoral, v)
            retval = true
        end
    end
    return retval
end
