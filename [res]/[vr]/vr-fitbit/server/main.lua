VRCore.Functions.CreateUseableItem("fitbit", function(source, item)
    local Player = VRCore.Functions.GetPlayer(source)
    TriggerClientEvent('vr-fitbit:use', source)
end)

RegisterServerEvent('vr-fitbit:server:setValue')
AddEventHandler('vr-fitbit:server:setValue', function(type, value)
    local src = source
    local ply = VRCore.Functions.GetPlayer(src)
    local fitbitData = {}

    if type == "thirst" then
        local currentMeta = ply.PlayerData.metadata["fitbit"]
        fitbitData = {
            thirst = value,
            food = currentMeta.food
        }
    elseif type == "food" then
        local currentMeta = ply.PlayerData.metadata["fitbit"]
        fitbitData = {
            thirst = currentMeta.thirst,
            food = value
        }
    end

    ply.Functions.SetMetaData('fitbit', fitbitData)
end)

VRCore.Functions.CreateCallback('vr-fitbit:server:HasFitbit', function(source, cb)
    local Ply = VRCore.Functions.GetPlayer(source)
    local Fitbit = Ply.Functions.GetItemByName("fitbit")

    if Fitbit ~= nil then
        cb(true)
    else
        cb(false)
    end
end)