PaycheckLoop = function()
    local Players = VRCore.Functions.GetPlayers()

    for i=1, #Players, 1 do
        local Player = VRCore.Functions.GetPlayer(Players[i])

        if Player.PlayerData.job ~= nil and Player.PlayerData.job.payment > 0 then
            Player.Functions.AddMoney('bank', Player.PlayerData.job.payment)
            TriggerClientEvent('VRCore:Notify', Players[i], "You received your paycheck of $"..Player.PlayerData.job.payment)
        end
    end
    SetTimeout(VRCore.Config.Money.PayCheckTimeOut * (60 * 1000), PaycheckLoop)
end
