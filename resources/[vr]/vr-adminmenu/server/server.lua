-- Variables
local frozen = false
local permissions = {
    ["kill"] = "god",
    ["ban"] = "admin",
    ["noclip"] = "admin",
    ["kickall"] = "admin",
    ["kick"] = "admin"
}

-- Get Dealers
VRCore.Functions.CreateCallback('test:getdealers', function(source, cb)
    cb(exports['vr-drugs']:GetDealers())
end)

-- Get Players
VRCore.Functions.CreateCallback('test:getplayers', function(source, cb) -- WORKS
    local players = {}
    for k, v in pairs(VRCore.Functions.GetPlayers()) do
        local targetped = GetPlayerPed(v)
        local ped = VRCore.Functions.GetPlayer(v)
        table.insert(players, {
            name = ped.PlayerData.charinfo.firstname .. " " .. ped.PlayerData.charinfo.lastname .. " | (" .. GetPlayerName(v) .. ")",
            id = v,
            coords = GetEntityCoords(targetped),
            cid = ped.PlayerData.charinfo.firstname .. " " .. ped.PlayerData.charinfo.lastname,
            citizenid = ped.PlayerData.citizenid,
            sources = GetPlayerPed(ped.PlayerData.source),
            sourceplayer= ped.PlayerData.source

        })
    end
    cb(players)
end)

VRCore.Functions.CreateCallback('vr-admin:server:getrank', function(source, cb)
    if VRCore.Functions.HasPermission(source, "god") then
        cb(true)
    else
        cb(false)
    end
end)

-- Functions

function tablelength(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

-- Events

RegisterServerEvent('vr-admin:server:GetPlayersForBlips')       
AddEventHandler('vr-admin:server:GetPlayersForBlips', function()
    local src = source					                        
    local players = {}                                          
    for k, v in pairs(VRCore.Functions.GetPlayers()) do         
        local targetped = GetPlayerPed(v)                       
        local ped = VRCore.Functions.GetPlayer(v)             
        table.insert(players, {                             
            name = ped.PlayerData.charinfo.firstname .. " " .. ped.PlayerData.charinfo.lastname .. " | (" .. GetPlayerName(v) .. ")",
            id = v,                                      
            coords = GetEntityCoords(targetped),             
            cid = ped.PlayerData.charinfo.firstname .. " " .. ped.PlayerData.charinfo.lastname,
            citizenid = ped.PlayerData.citizenid,            
            sources = GetPlayerPed(ped.PlayerData.source),    
            sourceplayer= ped.PlayerData.source              
        })                                                  
    end                                                  
    TriggerClientEvent('vr-admin:client:Show', src, players)  
end)

RegisterNetEvent("vr-admin:server:kill")
AddEventHandler("vr-admin:server:kill", function(player)
    TriggerClientEvent('hospital:client:KillPlayer', player.id)
end)

RegisterNetEvent("vr-admin:server:revive")
AddEventHandler("vr-admin:server:revive", function(player)
    TriggerClientEvent('hospital:client:Revive', player.id)
end)

RegisterNetEvent("vr-admin:server:kick")
AddEventHandler("vr-admin:server:kick", function(player, reason)
    local src = source
    if VRCore.Functions.HasPermission(src, permissions["kick"]) then
        TriggerEvent("vr-log:server:CreateLog", "bans", "Player Kicked", "red", string.format('%s was kicked by %s for %s', GetPlayerName(player.id), GetPlayerName(src), reason), true)
        DropPlayer(player.id, "You have been kicked from the server:\n" .. reason .. "\n\n🔸 Check our Discord for more information: " .. VRCore.Config.Server.discord)
    end
end)

RegisterNetEvent("vr-admin:server:ban")
AddEventHandler("vr-admin:server:ban", function(player, time, reason)
    local src = source
    if VRCore.Functions.HasPermission(src, permissions["ban"]) then
        local time = tonumber(time)
        local banTime = tonumber(os.time() + time)
        if banTime > 2147483647 then
            banTime = 2147483647
        end
        local timeTable = os.date("*t", banTime)
        exports.ghmattimysql:execute('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (@name, @license, @discord, @ip, @reason, @expire, @bannedby)', {
            ['@name'] = GetPlayerName(player.id),
            ['@license'] = VRCore.Functions.GetIdentifier(player.id, 'license'),
            ['@discord'] = VRCore.Functions.GetIdentifier(player.id, 'discord'),
            ['@ip'] = VRCore.Functions.GetIdentifier(player.id, 'ip'),
            ['@reason'] = reason,
            ['@expire'] = banTime,
            ['@bannedby'] = GetPlayerName(src)
        })
        TriggerClientEvent('chat:addMessage', -1, {
            template = '<div class="chat-message server"><strong>ANNOUNCEMENT | {0} has been banned:</strong> {1}</div>',
            args = {GetPlayerName(player.id), reason}
        })
        TriggerEvent("vr-log:server:CreateLog", "bans", "Player Banned", "red", string.format('%s was banned by %s for %s', GetPlayerName(player.id), GetPlayerName(src), reason), true)
        if banTime >= 2147483647 then
            DropPlayer(player.id, "You have been banned:\n" .. reason .. "\n\nYour ban is permanent.\n🔸 Check our Discord for more information: " .. VRCore.Config.Server.discord)
        else
            DropPlayer(player.id, "You have been banned:\n" .. reason .. "\n\nBan expires: " .. timeTable["day"] .. "/" .. timeTable["month"] .. "/" .. timeTable["year"] .. " " .. timeTable["hour"] .. ":" .. timeTable["min"] .. "\n🔸 Check our Discord for more information: " .. VRCore.Config.Server.discord)
        end
    end
end)

RegisterNetEvent("vr-admin:server:spectate")
AddEventHandler("vr-admin:server:spectate", function(player)
    local src = source
    local targetped = GetPlayerPed(player.id)
    local coords = GetEntityCoords(targetped)
    TriggerClientEvent('vr-admin:client:spectate', src, player.id, coords)
end)

RegisterNetEvent("vr-admin:server:freeze")
AddEventHandler("vr-admin:server:freeze", function(player)
    local target = GetPlayerPed(player.id)
    if not frozen then
        frozen = true
        FreezeEntityPosition(target, true)
    else
        frozen = false
        FreezeEntityPosition(target, false)
    end
end)

RegisterNetEvent('vr-admin:server:goto')
AddEventHandler('vr-admin:server:goto', function(player)
    local src = source
    local admin = GetPlayerPed(src)
    local coords = GetEntityCoords(GetPlayerPed(player.id))
    SetEntityCoords(admin, coords)
end)

RegisterNetEvent('vr-admin:server:intovehicle')
AddEventHandler('vr-admin:server:intovehicle', function(player)
    local src = source
    local admin = GetPlayerPed(src)
    -- local coords = GetEntityCoords(GetPlayerPed(player.id))
    local targetPed = GetPlayerPed(player.id)
    local vehicle = GetVehiclePedIsIn(targetPed,false)
    local seat = -1
    if vehicle ~= 0 then
        for i=0,8,1 do
            if GetPedInVehicleSeat(vehicle,i) == 0 then
                seat = i
                break
            end
        end
        if seat ~= -1 then
            SetPedIntoVehicle(admin,vehicle,seat)
            TriggerClientEvent('VRCore:Notify', src, 'Entered vehicle', 'success', 5000)
        else
            TriggerClientEvent('VRCore:Notify', src, 'The vehicle has no free seats!', 'danger', 5000)
        end
    end
end)


RegisterNetEvent('vr-admin:server:bring')
AddEventHandler('vr-admin:server:bring', function(player)
    local src = source
    local admin = GetPlayerPed(src)
    local coords = GetEntityCoords(admin)
    local target = GetPlayerPed(player.id)
    SetEntityCoords(target, coords)
end)

RegisterNetEvent("vr-admin:server:inventory")
AddEventHandler("vr-admin:server:inventory", function(player)
    local src = source
    TriggerClientEvent('vr-admin:client:inventory', src, player.id)
end)

RegisterNetEvent("vr-admin:server:cloth")
AddEventHandler("vr-admin:server:cloth", function(player)
    TriggerClientEvent("vr-clothing:client:openMenu", player.id)
end)

RegisterServerEvent('vr-admin:server:setPermissions')
AddEventHandler('vr-admin:server:setPermissions', function(targetId, group)
    local src = source
    if VRCore.Functions.HasPermission(src, "god") then
        VRCore.Functions.AddPermission(targetId, group[1].rank)
        TriggerClientEvent('VRCore:Notify', targetId, 'Your Permission Level Is Now '..group[1].label)
    end
end)

RegisterServerEvent('vr-admin:server:SendReport')
AddEventHandler('vr-admin:server:SendReport', function(name, targetSrc, msg)
    local src = source
    local Players = VRCore.Functions.GetPlayers()

    if VRCore.Functions.HasPermission(src, "admin") then
        if VRCore.Functions.IsOptin(src) then
            TriggerClientEvent('chatMessage', src, "REPORT - "..name.." ("..targetSrc..")", "report", msg)
        end
    end
end)

RegisterServerEvent('vr-admin:server:StaffChatMessage')
AddEventHandler('vr-admin:server:StaffChatMessage', function(name, msg)
    local src = source
    local Players = VRCore.Functions.GetPlayers()

    if VRCore.Functions.HasPermission(src, "admin") then
        if VRCore.Functions.IsOptin(src) then
            TriggerClientEvent('chatMessage', src, "STAFFCHAT - "..name, "error", msg)
        end
    end
end)

RegisterServerEvent('vr-admin:server:SaveCar')
AddEventHandler('vr-admin:server:SaveCar', function(mods, vehicle, hash, plate)
    local src = source
    local Player = VRCore.Functions.GetPlayer(src)
    local result = exports.ghmattimysql:executeSync('SELECT plate FROM player_vehicles WHERE plate=@plate', {['@plate'] = plate})
    if result[1] == nil then
        exports.ghmattimysql:execute('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state) VALUES (@license, @citizenid, @vehicle, @hash, @mods, @plate, @state)', {
            ['@license'] = Player.PlayerData.license,
            ['@citizenid'] = Player.PlayerData.citizenid,
            ['@vehicle'] = vehicle.model,
            ['@hash'] = vehicle.hash,
            ['@mods'] = json.encode(mods),
            ['@plate'] = plate,
            ['@state'] = 0
        })
        TriggerClientEvent('VRCore:Notify', src, 'The vehicle is now yours!', 'success', 5000)
    else
        TriggerClientEvent('VRCore:Notify', src, 'This vehicle is already yours..', 'error', 3000)
    end
end)

-- Commands

VRCore.Commands.Add("blips", "Show blips for players (Admin Only)", {}, false, function(source, args)
    TriggerClientEvent('vr-admin:client:toggleBlips', source)
end, "admin")

VRCore.Commands.Add("names", "Show player name overhead (Admin Only)", {}, false, function(source, args)
    TriggerClientEvent('vr-admin:client:toggleNames', source)
end, "admin")

VRCore.Commands.Add("coords", "Enable coord display for development stuff (Admin Only)", {}, false, function(source, args)
    TriggerClientEvent('vr-admin:client:ToggleCoords', source)
end, "admin")

VRCore.Commands.Add("admincar", "Save Vehicle To Your Garage (Admin Only)", {}, false, function(source, args)
    local ply = VRCore.Functions.GetPlayer(source)
    TriggerClientEvent('vr-admin:client:SaveCar', source)
end, "admin")

VRCore.Commands.Add("announce", "Make An Announcement (Admin Only)", {}, false, function(source, args)
    local msg = table.concat(args, " ")
    for i = 1, 3, 1 do
        TriggerClientEvent('chatMessage', -1, "SYSTEM", "error", msg)
    end
end, "admin")

VRCore.Commands.Add("admin", "Open Admin Menu (Admin Only)", {}, false, function(source, args)
    TriggerClientEvent('vr-admin:client:openMenu', source)
end, "admin")

VRCore.Commands.Add("report", "Admin Report", {{name="message", help="Message"}}, true, function(source, args)
    local msg = table.concat(args, " ")
    local Player = VRCore.Functions.GetPlayer(source)
    TriggerClientEvent('vr-admin:client:SendReport', -1, GetPlayerName(source), source, msg)
    TriggerClientEvent('chatMessage', source, "REPORT Send", "normal", msg)
    TriggerEvent("vr-log:server:CreateLog", "report", "Report", "green", "**"..GetPlayerName(source).."** (CitizenID: "..Player.PlayerData.citizenid.." | ID: "..source..") **Report:** " ..msg, false)
end)

VRCore.Commands.Add("staffchat", "Send A Message To All Staff (Admin Only)", {{name="message", help="Message"}}, true, function(source, args)
    local msg = table.concat(args, " ")
    TriggerClientEvent('vr-admin:client:SendStaffChat', -1, GetPlayerName(source), msg)
end, "admin")

VRCore.Commands.Add("givenuifocus", "Give A Player NUI Focus (Admin Only)", {{name="id", help="Player id"}, {name="focus", help="Set focus on/off"}, {name="mouse", help="Set mouse on/off"}}, true, function(source, args)
    local playerid = tonumber(args[1])
    local focus = args[2]
    local mouse = args[3]
    TriggerClientEvent('vr-admin:client:GiveNuiFocus', playerid, focus, mouse)
end, "admin")

VRCore.Commands.Add("warn", "Warn A Player (Admin Only)", {{name="ID", help="Player"}, {name="Reason", help="Mention a reason"}}, true, function(source, args)
    local targetPlayer = VRCore.Functions.GetPlayer(tonumber(args[1]))
    local senderPlayer = VRCore.Functions.GetPlayer(source)
    table.remove(args, 1)
    local msg = table.concat(args, " ")
    local myName = senderPlayer.PlayerData.name
    local warnId = "WARN-"..math.random(1111, 9999)
    if targetPlayer ~= nil then
        TriggerClientEvent('chatMessage', targetPlayer.PlayerData.source, "SYSTEM", "error", "You have been warned by: "..GetPlayerName(source)..", Reason: "..msg)
        TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "You have warned "..GetPlayerName(targetPlayer.PlayerData.source).." for: "..msg)
        exports.ghmattimysql:execute('INSERT INTO player_warns (senderIdentifier, targetIdentifier, reason, warnId) VALUES (@senderIdentifier, @targetIdentifier, @reason, @warnId)', {
            ['@senderIdentifier'] = senderPlayer.PlayerData.license,
            ['@targetIdentifier'] = targetPlayer.PlayerData.license,
            ['@reason'] = msg,
            ['@warnId'] = warnId
        })
    else
        TriggerClientEvent('VRCore:Notify', source, 'This player is not online', 'error')
    end
end, "admin")

VRCore.Commands.Add("checkwarns", "Check Player Warnings (Admin Only)", {{name="ID", help="Player"}, {name="Warning", help="Number of warning, (1, 2 or 3 etc..)"}}, false, function(source, args)
    if args[2] == nil then
        local targetPlayer = VRCore.Functions.GetPlayer(tonumber(args[1]))
        local result = exports.ghmattimysql:executeSync('SELECT * FROM player_warns WHERE targetIdentifier=@targetIdentifier', {['@targetIdentifier'] = targetPlayer.PlayerData.license})
        TriggerClientEvent('chatMessage', source, "SYSTEM", "warning", targetPlayer.PlayerData.name.." has "..tablelength(result).." warnings!")
    else
        local targetPlayer = VRCore.Functions.GetPlayer(tonumber(args[1]))
        local warnings = exports.ghmattimysql:executeSync('SELECT * FROM player_warns WHERE targetIdentifier=@targetIdentifier', {['@targetIdentifier'] = targetPlayer.PlayerData.license})
        local selectedWarning = tonumber(args[2])
        if warnings[selectedWarning] ~= nil then
            local sender = VRCore.Functions.GetPlayer(warnings[selectedWarning].senderIdentifier)
            TriggerClientEvent('chatMessage', source, "SYSTEM", "warning", targetPlayer.PlayerData.name.." has been warned by "..sender.PlayerData.name..", Reason: "..warnings[selectedWarning].reason)
        end
    end
end, "admin")

VRCore.Commands.Add("delwarn", "Delete Players Warnings (Admin Only)", {{name="ID", help="Player"}, {name="Warning", help="Number of warning, (1, 2 or 3 etc..)"}}, true, function(source, args)
    local targetPlayer = VRCore.Functions.GetPlayer(tonumber(args[1]))
    local warnings = exports.ghmattimysql:executeSync('SELECT * FROM player_warns WHERE targetIdentifier=@targetIdentifier', {['@targetIdentifier'] = targetPlayer.PlayerData.license})
    local selectedWarning = tonumber(args[2])
    if warnings[selectedWarning] ~= nil then
        local sender = VRCore.Functions.GetPlayer(warnings[selectedWarning].senderIdentifier)
        TriggerClientEvent('chatMessage', source, "SYSTEM", "warning", "You have deleted warning ("..selectedWarning..") , Reason: "..warnings[selectedWarning].reason)
        exports.ghmattimysql:execute('DELETE FROM player_warns WHERE warnId=@warnId', {['@warnId'] = warnings[selectedWarning].warnId})
    end
end, "admin")

VRCore.Commands.Add("reportr", "Reply To A Report (Admin Only)", {}, false, function(source, args)
    local playerId = tonumber(args[1])
    table.remove(args, 1)
    local msg = table.concat(args, " ")
    local OtherPlayer = VRCore.Functions.GetPlayer(playerId)
    local Player = VRCore.Functions.GetPlayer(source)
    if OtherPlayer ~= nil then
        TriggerClientEvent('chatMessage', playerId, "ADMIN - "..GetPlayerName(source), "warning", msg)
        TriggerClientEvent('VRCore:Notify', source, "Sent reply")
        for k, v in pairs(VRCore.Functions.GetPlayers()) do
            if VRCore.Functions.HasPermission(v, "admin") then
                if VRCore.Functions.IsOptin(v) then
                    TriggerClientEvent('chatMessage', v, "REPORT REPLY ("..source..") - "..GetPlayerName(source), "warning", msg)
                    TriggerEvent("vr-log:server:CreateLog", "report", "Report Reply", "red", "**"..GetPlayerName(source).."** replied on: **"..OtherPlayer.PlayerData.name.. " **(ID: "..OtherPlayer.PlayerData.source..") **Message:** " ..msg, false)
                end
            end
        end
    else
        TriggerClientEvent('VRCore:Notify', source, "Player is not online", "error")
    end
end, "admin")

VRCore.Commands.Add("setmodel", "Change Ped Model (Admin Only)", {{name="model", help="Name of the model"}, {name="id", help="Id of the Player (empty for yourself)"}}, false, function(source, args)
    local model = args[1]
    local target = tonumber(args[2])
    if model ~= nil or model ~= "" then
        if target == nil then
            TriggerClientEvent('vr-admin:client:SetModel', source, tostring(model))
        else
            local Trgt = VRCore.Functions.GetPlayer(target)
            if Trgt ~= nil then
                TriggerClientEvent('vr-admin:client:SetModel', target, tostring(model))
            else
                TriggerClientEvent('VRCore:Notify', source, "This person is not online..", "error")
            end
        end
    else
        TriggerClientEvent('VRCore:Notify', source, "You did not set a model..", "error")
    end
end, "admin")

VRCore.Commands.Add("setspeed", "Set Player Foot Speed (Admin Only)", {}, false, function(source, args)
    local speed = args[1]
    if speed ~= nil then
        TriggerClientEvent('vr-admin:client:SetSpeed', source, tostring(speed))
    else
        TriggerClientEvent('VRCore:Notify', source, "You did not set a speed.. (`fast` for super-run, `normal` for normal)", "error")
    end
end, "admin")

VRCore.Commands.Add("reporttoggle", "Toggle Incoming Reports (Admin Only)", {}, false, function(source, args)
    VRCore.Functions.ToggleOptin(source)
    if VRCore.Functions.IsOptin(source) then
        TriggerClientEvent('VRCore:Notify', source, "You are receiving reports", "success")
    else
        TriggerClientEvent('VRCore:Notify', source, "You are not receiving reports", "error")
    end
end, "admin")

RegisterCommand("kickall", function(source, args, rawCommand)
    local src = source
    if src > 0 then
        local reason = table.concat(args, ' ')
        local Player = VRCore.Functions.GetPlayer(src)

        if VRCore.Functions.HasPermission(src, "god") then
            if args[1] ~= nil then
                for k, v in pairs(VRCore.Functions.GetPlayers()) do
                    local Player = VRCore.Functions.GetPlayer(v)
                    if Player ~= nil then
                        DropPlayer(Player.PlayerData.source, reason)
                    end
                end
            else
                TriggerClientEvent('chatMessage', src, 'SYSTEM', 'error', 'Mention a reason..')
            end
        else
            TriggerClientEvent('chatMessage', src, 'SYSTEM', 'error', 'You can\'t do this..')
        end
    else
        for k, v in pairs(VRCore.Functions.GetPlayers()) do
            local Player = VRCore.Functions.GetPlayer(v)
            if Player ~= nil then
                DropPlayer(Player.PlayerData.source, "Server restart, check our Discord for more information: " .. VRCore.Config.Server.discord)
            end
        end
    end
end, false)

VRCore.Commands.Add("setammo", "Set Your Ammo Amount (Admin Only)", {{name="amount", help="Amount of bullets, for example: 20"}, {name="weapon", help="Name of the weapen, for example: WEAPON_VINTAGEPISTOL"}}, false, function(source, args)
    local src = source
    local weapon = args[2]
    local amount = tonumber(args[1])

    if weapon ~= nil then
        TriggerClientEvent('vr-weapons:client:SetWeaponAmmoManual', src, weapon, amount)
    else
        TriggerClientEvent('vr-weapons:client:SetWeaponAmmoManual', src, "current", amount)
    end
end, 'admin')
