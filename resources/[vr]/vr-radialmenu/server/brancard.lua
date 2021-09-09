RegisterServerEvent('vr-radialmenu:server:RemoveBrancard')
AddEventHandler('vr-radialmenu:server:RemoveBrancard', function(PlayerPos, BrancardObject)
    TriggerClientEvent('vr-radialmenu:client:RemoveBrancardFromArea', -1, PlayerPos, BrancardObject)
end)

RegisterServerEvent('vr-radialmenu:Brancard:BusyCheck')
AddEventHandler('vr-radialmenu:Brancard:BusyCheck', function(id, type)
    local MyId = source
    TriggerClientEvent('vr-radialmenu:Brancard:client:BusyCheck', id, MyId, type)
end)

RegisterServerEvent('vr-radialmenu:server:BusyResult')
AddEventHandler('vr-radialmenu:server:BusyResult', function(IsBusy, OtherId, type)
    TriggerClientEvent('vr-radialmenu:client:Result', OtherId, IsBusy, type)
end)