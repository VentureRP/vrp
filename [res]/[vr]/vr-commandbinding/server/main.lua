VRCore.Commands.Add("binds", "Open commandbinding menu", {}, false, function(source, args)
    local Player = VRCore.Functions.GetPlayer(source)
	TriggerClientEvent("vr-commandbinding:client:openUI", source)
end)

RegisterServerEvent('vr-commandbinding:server:setKeyMeta')
AddEventHandler('vr-commandbinding:server:setKeyMeta', function(keyMeta)
    local src = source
    local ply = VRCore.Functions.GetPlayer(src)

    ply.Functions.SetMetaData("commandbinds", keyMeta)
end)