local DrivingSchools = {
    
}

RegisterServerEvent('vr-cityhall:server:requestId')
AddEventHandler('vr-cityhall:server:requestId', function(identityData)
    local src = source
    local Player = VRCore.Functions.GetPlayer(src)
    local info = {}
    if identityData.item == "id_card" then
        info.citizenid = Player.PlayerData.citizenid
        info.firstname = Player.PlayerData.charinfo.firstname
        info.lastname = Player.PlayerData.charinfo.lastname
        info.birthdate = Player.PlayerData.charinfo.birthdate
        info.gender = Player.PlayerData.charinfo.gender
        info.nationality = Player.PlayerData.charinfo.nationality
    elseif identityData.item == "driver_license" then
        info.firstname = Player.PlayerData.charinfo.firstname
        info.lastname = Player.PlayerData.charinfo.lastname
        info.birthdate = Player.PlayerData.charinfo.birthdate
        info.type = "Class C Driver License"
    elseif identityData.item == "weaponlicense" then
        info.firstname = Player.PlayerData.charinfo.firstname
        info.lastname = Player.PlayerData.charinfo.lastname
        info.birthdate = Player.PlayerData.charinfo.birthdate
    end

    Player.Functions.AddItem(identityData.item, 1, nil, info)

    TriggerClientEvent('inventory:client:ItemBox', src, VRCore.Shared.Items[identityData.item], 'add')
end)


RegisterServerEvent('vr-cityhall:server:getIDs')
AddEventHandler('vr-cityhall:server:getIDs', function()
    local src = source
    GiveStarterItems(src)
end)


RegisterServerEvent('vr-cityhall:server:sendDriverTest')
AddEventHandler('vr-cityhall:server:sendDriverTest', function()
    local src = source
    local Player = VRCore.Functions.GetPlayer(src)
    for k, v in pairs(DrivingSchools) do 
        local SchoolPlayer = VRCore.Functions.GetPlayerByCitizenId(v)
        if SchoolPlayer ~= nil then 
            TriggerClientEvent("vr-cityhall:client:sendDriverEmail", SchoolPlayer.PlayerData.source, Player.PlayerData.charinfo)
        else
            local mailData = {
                sender = "Township",
                subject = "Driving lessons request",
                message = "Hello,<br /><br />We have just received a message that someone wants to take driving lessons.<br />If you are willing to teach, please contact us:<br />Naam: <strong>".. Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname .. "<br />Telephone number: <strong>"..Player.PlayerData.charinfo.phone.."</strong><br/><br/>Kind regards,<br />City of Los Santos",
                button = {}
            }
            TriggerEvent("vr-phone:server:sendNewEventMail", v, mailData)
        end
    end
    TriggerClientEvent('VRCore:Notify', src, 'An email has been sent to driving schools, and you will be contacted automatically', "success", 5000)
end)

RegisterServerEvent('vr-cityhall:server:ApplyJob')
AddEventHandler('vr-cityhall:server:ApplyJob', function(job)
    local src = source
    local Player = VRCore.Functions.GetPlayer(src)
    local JobInfo = VRCore.Shared.Jobs[job]

    Player.Functions.SetJob(job, 0)

    TriggerClientEvent('VRCore:Notify', src, 'Congratulations with your new job! ('..JobInfo.label..')')
end)


-- VRCore.Commands.Add("drivinglicense", "Give a driver's license to someone", {{"id", "ID of a person"}}, true, function(source, args)
--     local Player = VRCore.Functions.GetPlayer(source)

--         local SearchedPlayer = VRCore.Functions.GetPlayer(tonumber(args[1]))
--         if SearchedPlayer ~= nil then
--             local driverLicense = SearchedPlayer.PlayerData.metadata["licences"]["driver"]
--             if not driverLicense then
--                 local licenses = {
--                     ["driver"] = true,
--                     ["business"] = SearchedPlayer.PlayerData.metadata["licences"]["business"]
--                 }
--                 SearchedPlayer.Functions.SetMetaData("licences", licenses)
--                 TriggerClientEvent('VRCore:Notify', SearchedPlayer.PlayerData.source, "You have passed! Pick up your driver's license at the town hall", "success", 5000)
--             else
--                 TriggerClientEvent('VRCore:Notify', src, "Can't give driver's license ..", "error")
--             end
--         end

-- end)

function GiveStarterItems(source)
    local src = source
    local Player = VRCore.Functions.GetPlayer(src)

    for k, v in pairs(VRCore.Shared.StarterItems) do
        local info = {}
        if v.item == "id_card" then
            info.citizenid = Player.PlayerData.citizenid
            info.firstname = Player.PlayerData.charinfo.firstname
            info.lastname = Player.PlayerData.charinfo.lastname
            info.birthdate = Player.PlayerData.charinfo.birthdate
            info.gender = Player.PlayerData.charinfo.gender
            info.nationality = Player.PlayerData.charinfo.nationality
        elseif v.item == "driver_license" then
            info.firstname = Player.PlayerData.charinfo.firstname
            info.lastname = Player.PlayerData.charinfo.lastname
            info.birthdate = Player.PlayerData.charinfo.birthdate
            info.type = "Class C Driver License"
        end
        Player.Functions.AddItem(v.item, 1, false, info)
    end
end

function IsWhitelistedSchool(citizenid)
    local retval = false
    for k, v in pairs(DrivingSchools) do 
        if v == citizenid then
            retval = true
        end
    end
    return retval
end

RegisterServerEvent('vr-cityhall:server:banPlayer')
AddEventHandler('vr-cityhall:server:banPlayer', function()
    local src = source
    TriggerClientEvent('chatMessage', -1, "Anti-Cheat", "error", GetPlayerName(src).." has been banned for sending POST Request's ")
    exports.ghmattimysql:execute('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (@name, @license, @discord, @ip, @reason, @expire, @bannedby)', {
        ['@name'] = GetPlayerName(src),
        ['@license'] = VRCore.Functions.GetIdentifier(src, 'license'),
        ['@discord'] = VRCore.Functions.GetIdentifier(src, 'discord'),
        ['@ip'] = VRCore.Functions.GetIdentifier(src, 'ip'),
        ['@reason'] = 'Abuse localhost:13172 For POST Requests',
        ['@expire'] = 2145913200,
        ['@bannedby'] = GetPlayerName(src)
    })
    DropPlayer(src, 'Attempting To Exploit')
end)
