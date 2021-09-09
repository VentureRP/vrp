VRCore.Functions.CreateUseableItem("radio", function(source, item)
    TriggerClientEvent('vr-radio:use', source)
end)

VRCore.Functions.CreateCallback('vr-radio:server:GetItem', function(source, cb, item)
    local src = source
    local Player = VRCore.Functions.GetPlayer(src)
    if Player ~= nil then
        local RadioItem = Player.Functions.GetItemByName(item)
        if RadioItem ~= nil and not Player.PlayerData.metadata["isdead"] and
            not Player.PlayerData.metadata["inlaststand"] then
            cb(true)
        else
            cb(false)
        end
    else
        cb(false)
    end
end)