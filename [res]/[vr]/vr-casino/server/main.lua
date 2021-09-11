local ItemList = {
    ["casinochips"] = 1,
}

RegisterServerEvent("vr-casino:server:sell")
AddEventHandler("vr-casino:server:sell", function()
    local src = source
    local price = 0
    local Player = VRCore.Functions.GetPlayer(src)
    local xItem = Player.Functions.GetItemByName("casinochips")
    if xItem ~= nil then
        for k, v in pairs(Player.PlayerData.items) do 
            if Player.PlayerData.items[k] ~= nil then 
                if ItemList[Player.PlayerData.items[k].name] ~= nil then 
                    price = price + (ItemList[Player.PlayerData.items[k].name] * Player.PlayerData.items[k].amount)
                    Player.Functions.RemoveItem(Player.PlayerData.items[k].name, Player.PlayerData.items[k].amount, k)
                        
        Player.Functions.AddMoney("cash", price, "sold-casino-chips")
            TriggerClientEvent('VRCore:Notify', src, "You sold your chips for $"..price)
            TriggerEvent("vr-log:server:CreateLog", "casino", "Chips", "blue", "**"..GetPlayerName(src) .. "** got $"..price.." for selling the Chips")
                end
            end
        end
    else
        TriggerClientEvent('VRCore:Notify', src, "You have no chips..")
    end
end)

function SetExports()
exports["vr-blackjack"]:SetGetChipsCallback(function(source)
    local Player = VRCore.Functions.GetPlayer(source)
    local Chips = Player.Functions.GetItemByName("casinochips")

    if Chips ~= nil then 
        Chips = Chips
    end

    return TriggerClientEvent('VRCore:Notify', src, "You have no chips..")
end)

    exports["vr-blackjack"]:SetTakeChipsCallback(function(source, amount)
        local Player = VRCore.Functions.GetPlayer(source)

        if Player ~= nil then
            Player.Functions.RemoveItem("casinochips", amount)
            TriggerClientEvent('inventory:client:ItemBox', source, VRCore.Shared.Items['casinochips'], "remove")
            TriggerEvent("vr-log:server:CreateLog", "casino", "Chips", "yellow", "**"..GetPlayerName(source) .. "** put $"..amount.." in table")
        end
    end)

    exports["vr-blackjack"]:SetGiveChipsCallback(function(source, amount)
        local Player = VRCore.Functions.GetPlayer(source)

        if Player ~= nil then
            Player.Functions.AddItem("casinochips", amount)
            TriggerClientEvent('inventory:client:ItemBox', source, VRCore.Shared.Items['casinochips'], "add")
            TriggerEvent("vr-log:server:CreateLog", "casino", "Chips", "red", "**"..GetPlayerName(source) .. "** got $"..amount.." from table table and he won the double")
        end
    end)
end

AddEventHandler("onResourceStart", function(resourceName)
	if ("vr-blackjack" == resourceName) then
        Citizen.Wait(1000)
        SetExports()
    end
end)

SetExports()
