local ResetStress = false

VRCore.Commands.Add('cash', 'Check Cash Balance', {}, false, function(source, args)
    local Player = VRCore.Functions.GetPlayer(source)
    local cashamount = Player.PlayerData.money.cash
	TriggerClientEvent('hud:client:ShowAccounts', source, 'cash', cashamount)
end)

VRCore.Commands.Add('bank', 'Check Bank Balance', {}, false, function(source, args)
    local Player = VRCore.Functions.GetPlayer(source)
    local bankamount = Player.PlayerData.money.bank
	TriggerClientEvent('hud:client:ShowAccounts', source, 'bank', bankamount)
end)

RegisterServerEvent('hud:server:GainStress')
AddEventHandler('hud:server:GainStress', function(amount)
    local src = source
    local Player = VRCore.Functions.GetPlayer(src)
    local newStress
    if Player ~= nil and Player.PlayerData.job.name ~= 'police' then
        if not ResetStress then
            if Player.PlayerData.metadata['stress'] == nil then
                Player.PlayerData.metadata['stress'] = 0
            end
            newStress = Player.PlayerData.metadata['stress'] + amount
            if newStress <= 0 then newStress = 0 end
        else
            newStress = 0
        end
        if newStress > 100 then
            newStress = 100
        end
        Player.Functions.SetMetaData('stress', newStress)
        TriggerClientEvent('hud:client:UpdateStress', src, newStress)
        TriggerClientEvent('VRCore:Notify', src, 'Getting Stressed', 'error', 1500)
	end
end)

RegisterServerEvent('hud:server:RelieveStress')
AddEventHandler('hud:server:RelieveStress', function(amount)
    local src = source
    local Player = VRCore.Functions.GetPlayer(src)
    local newStress
    if Player ~= nil then
        if not ResetStress then
            if Player.PlayerData.metadata['stress'] == nil then
                Player.PlayerData.metadata['stress'] = 0
            end
            newStress = Player.PlayerData.metadata['stress'] - amount
            if newStress <= 0 then newStress = 0 end
        else
            newStress = 0
        end
        if newStress > 100 then
            newStress = 100
        end
        Player.Functions.SetMetaData('stress', newStress)
        TriggerClientEvent('hud:client:UpdateStress', src, newStress)
        TriggerClientEvent('VRCore:Notify', src, 'You Are Relaxing')
	end
end)