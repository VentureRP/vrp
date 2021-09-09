-- Get permissions --

VRCore.Functions.CreateCallback('vr-anticheat:server:GetPermissions', function(source, cb)
    local group = VRCore.Functions.GetPermission(source)
    cb(group)
end)

-- Execute ban --

RegisterServerEvent('vr-anticheat:server:banPlayer')
AddEventHandler('vr-anticheat:server:banPlayer', function(reason)
    local src = source
    TriggerEvent("vr-log:server:CreateLog", "anticheat", "Anti-Cheat", "white", GetPlayerName(src).." has been banned for "..reason, false)
    exports.ghmattimysql:execute('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (@name, @license, @discord, @ip, @reason, @expire, @bannedby)', {
        ['@name'] = GetPlayerName(src),
        ['@license'] = VRCore.Functions.GetIdentifier(src, 'license'),
        ['@discord'] = VRCore.Functions.GetIdentifier(src, 'discord'),
        ['@ip'] = VRCore.Functions.GetIdentifier(src, 'ip'),
        ['@reason'] = reason,
        ['@expire'] = 2145913200,
        ['@bannedby'] = 'Anti-Cheat'
    })
    DropPlayer(src, "You have been banned for cheating. Check our Discord for more information: " .. VRCore.Config.Server.discord)
end)

-- Fake events --
function NonRegisteredEventCalled(CalledEvent, source)
    TriggerClientEvent("vr-anticheat:client:NonRegisteredEventCalled", source, "Cheating", CalledEvent)
end


for x, v in pairs(Config.BlacklistedEvents) do
    RegisterServerEvent(v)
    AddEventHandler(v, function(source)
        NonRegisteredEventCalled(v, source)
    end)
end



-- RegisterServerEvent('banking:withdraw')
-- AddEventHandler('banking:withdraw', function(source)
--     NonRegisteredEventCalled('bank:withdraw', source)
-- end)

VRCore.Functions.CreateCallback('vr-anticheat:server:HasWeaponInInventory', function(source, cb, WeaponInfo)
    local src = source
    local Player = VRCore.Functions.GetPlayer(src)
    local PlayerInventory = Player.PlayerData.items
    local retval = false

    for k, v in pairs(PlayerInventory) do
        if v.name == WeaponInfo["name"] then
            retval = true
        end
    end
    cb(retval)
end)
