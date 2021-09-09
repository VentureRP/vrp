RegisterServerEvent('json:dataStructure')
AddEventHandler('json:dataStructure', function(data)
    -- ??
end)

RegisterServerEvent('vr-radialmenu:trunk:server:Door')
AddEventHandler('vr-radialmenu:trunk:server:Door', function(open, plate, door)
    TriggerClientEvent('vr-radialmenu:trunk:client:Door', -1, plate, door, open)
end)