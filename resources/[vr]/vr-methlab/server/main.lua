Citizen.CreateThread(function()
    Config.CurrentLab = math.random(1, #Config.Locations["laboratories"])
    --print('Lab entry has been set to location: '..Config.CurrentLab)
end)

VRCore.Functions.CreateCallback('vr-methlab:server:GetData', function(source, cb)
    local LabData = {
        CurrentLab = Config.CurrentLab
    }
    cb(LabData)
end)

VRCore.Functions.CreateUseableItem("labkey", function(source, item)
    local Player = VRCore.Functions.GetPlayer(source)
    local LabKey = item.info.lab ~= nil and item.info.lab or 1

    TriggerClientEvent('vr-methlab:client:UseLabKey', source, LabKey)
end)

function GenerateRandomLab()
    local Lab = math.random(1, #Config.Locations["laboratories"])
    return Lab
end

RegisterServerEvent('vr-methlab:server:loadIngredients')
AddEventHandler('vr-methlab:server:loadIngredients', function()
	local Player = VRCore.Functions.GetPlayer(tonumber(source))
    local hydrochloricacid = Player.Functions.GetItemByName('hydrochloricacid')
    local ephedrine = Player.Functions.GetItemByName('ephedrine')
    local acetone = Player.Functions.GetItemByName('acetone')
	if Player.PlayerData.items ~= nil then 
        if (hydrochloricacid ~= nil and ephedrine ~= nil and acetone ~= nil) then
            if hydrochloricacid.amount >= 0 and ephedrine.amount >= 0 and acetone.amount >= 0 then 
                Player.Functions.RemoveItem("hydrochloricacid", 3, false)
                TriggerClientEvent('inventory:client:ItemBox', source, VRCore.Shared.Items['hydrochloricacid'], "remove")
                Player.Functions.RemoveItem("ephedrine", 3, false)
                TriggerClientEvent('inventory:client:ItemBox', source, VRCore.Shared.Items['ephedrine'], "remove")
                Player.Functions.RemoveItem("acetone", 3, false)
                TriggerClientEvent('inventory:client:ItemBox', source, VRCore.Shared.Items['acetone'], "remove")
            end
        end
	end
end)

RegisterServerEvent('vr-methlab:server:CheckIngredients')
AddEventHandler('vr-methlab:server:CheckIngredients', function()
	local Player = VRCore.Functions.GetPlayer(tonumber(source))
    local hydrochloricacid = Player.Functions.GetItemByName('hydrochloricacid')
    local ephedrine = Player.Functions.GetItemByName('ephedrine')
    local acetone = Player.Functions.GetItemByName('acetone')
	if Player.PlayerData.items ~= nil then 
        if (hydrochloricacid ~= nil and ephedrine ~= nil and acetone ~= nil) then 
            if hydrochloricacid.amount >= 3 and ephedrine.amount >= 3 and acetone.amount >= 3 then 
                TriggerClientEvent("vr-methlab:client:loadIngredients", source)
            else
                TriggerClientEvent('VRCore:Notify', source, "You do not have the correct items", 'error')
            end
        else
            TriggerClientEvent('VRCore:Notify', source, "You do not have the correct items", 'error')
        end
	else
		TriggerClientEvent('VRCore:Notify', source, "You Have Nothing...", "error")
	end
end)

RegisterServerEvent('vr-methlab:server:breakMeth')
AddEventHandler('vr-methlab:server:breakMeth', function()
	local Player = VRCore.Functions.GetPlayer(tonumber(source))
    local meth = Player.Functions.GetItemByName('methtray')
    local puremethtray = Player.Functions.GetItemByName('puremethtray')

	if Player.PlayerData.items ~= nil then 
        if (meth ~= nil or puremethtray ~= nil) then 
                TriggerClientEvent("vr-methlab:client:breakMeth", source)
        else
            TriggerClientEvent('VRCore:Notify', source, "You do not have the correct items", 'error')   
        end
	else
		TriggerClientEvent('VRCore:Notify', source, "You Have Nothing...", "error")
	end
end)

RegisterServerEvent('vr-methlab:server:getmethtray')
AddEventHandler('vr-methlab:server:getmethtray', function(amount)
    local Player = VRCore.Functions.GetPlayer(tonumber(source))
    
    local methtray = Player.Functions.GetItemByName('methtray')
    local puremethtray = Player.Functions.GetItemByName('puremethtray')

    if puremethtray ~= nil then 
        if puremethtray.amount >= 1 then 
            Player.Functions.AddItem("puremeth", amount, false)
            TriggerClientEvent('inventory:client:ItemBox', source, VRCore.Shared.Items['puremeth'], "add")

            Player.Functions.RemoveItem("puremethtray", 1, false)
            TriggerClientEvent('inventory:client:ItemBox', source, VRCore.Shared.Items['puremethtray'], "remove")
        end
    elseif methtray ~= nil then 
        if methtray.amount >= 1 then 
            Player.Functions.AddItem("meth", amount, false)
            TriggerClientEvent('inventory:client:ItemBox', source, VRCore.Shared.Items['meth'], "add")

            Player.Functions.RemoveItem("methtray", 1, false)
            TriggerClientEvent('inventory:client:ItemBox', source, VRCore.Shared.Items['methtray'], "remove")
        end
    else
        TriggerClientEvent('VRCore:Notify', source, "You do not have the correct items", 'error')   
    end
end)

RegisterServerEvent('vr-methlab:server:receivemethtray')
AddEventHandler('vr-methlab:server:receivemethtray', function()
    local chance = math.random(1, 100)
    print(chance)
    if chance >= 90 then
        local Player = VRCore.Functions.GetPlayer(tonumber(source))
        Player.Functions.AddItem("puremethtray", 3, false)
        TriggerClientEvent('inventory:client:ItemBox', source, VRCore.Shared.Items['puremethtray'], "add")
    else
        local Player = VRCore.Functions.GetPlayer(tonumber(source))
        Player.Functions.AddItem("methtray", 3, false)
        TriggerClientEvent('inventory:client:ItemBox', source, VRCore.Shared.Items['methtray'], "add")
    end
end)
