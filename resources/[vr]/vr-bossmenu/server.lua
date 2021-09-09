Accounts = {}

CreateThread(function()
    Wait(500)
    local result = json.decode(LoadResourceFile(GetCurrentResourceName(), "./accounts.json"))
    if not result then
        return
    end
    for k,v in pairs(result) do
        local k = tostring(k)
        local v = tonumber(v)
        if k and v then
            Accounts[k] = v
        end
    end
end)

VRCore.Functions.CreateCallback('vr-bossmenu:server:GetAccount', function(source, cb, jobname)
    local result = GetAccount(jobname)
    cb(result)
end)

-- Export
function GetAccount(account)
    return Accounts[account] or 0
end

-- Withdraw Money
RegisterServerEvent("vr-bossmenu:server:withdrawMoney")
AddEventHandler("vr-bossmenu:server:withdrawMoney", function(amount)
    local src = source
    local Player = VRCore.Functions.GetPlayer(src)
    local job = Player.PlayerData.job.name

    if not Accounts[job] then
        Accounts[job] = 0
    end

    if Accounts[job] >= amount and amount > 0 then
        Accounts[job] = Accounts[job] - amount
        Player.Functions.AddMoney("cash", amount)
    else
        TriggerClientEvent('VRCore:Notify', src, 'Not Enough Money', 'error')
        return
    end
    SaveResourceFile(GetCurrentResourceName(), "./accounts.json", json.encode(Accounts), -1)
    TriggerEvent('vr-log:server:CreateLog', 'bossmenu', 'Withdraw Money', "Successfully withdrawn $" .. amount .. ' (' .. job .. ')', src)
end)

-- Deposit Money
RegisterServerEvent("vr-bossmenu:server:depositMoney")
AddEventHandler("vr-bossmenu:server:depositMoney", function(amount)
    local src = source
    local Player = VRCore.Functions.GetPlayer(src)
    local job = Player.PlayerData.job.name

    if not Accounts[job] then
        Accounts[job] = 0
    end

    if Player.Functions.RemoveMoney("cash", amount) then
        Accounts[job] = Accounts[job] + amount
    else
        TriggerClientEvent('VRCore:Notify', src, 'Not Enough Money', "error")
        return
    end
    SaveResourceFile(GetCurrentResourceName(), "./accounts.json", json.encode(Accounts), -1)
    TriggerEvent('vr-log:server:CreateLog', 'bossmenu', 'Deposit Money', "Successfully deposited $" .. amount .. ' (' .. job .. ')', src)
end)

RegisterServerEvent("vr-bossmenu:server:addAccountMoney")
AddEventHandler("vr-bossmenu:server:addAccountMoney", function(account, amount)
    if not Accounts[account] then
        Accounts[account] = 0
    end
    
    Accounts[account] = Accounts[account] + amount
    TriggerClientEvent('vr-bossmenu:client:refreshSociety', -1, account, Accounts[account])
    SaveResourceFile(GetCurrentResourceName(), "./accounts.json", json.encode(Accounts), -1)
end)

RegisterServerEvent("vr-bossmenu:server:removeAccountMoney")
AddEventHandler("vr-bossmenu:server:removeAccountMoney", function(account, amount)
    if not Accounts[account] then
        Accounts[account] = 0
    end

    if Accounts[account] >= amount then
        Accounts[account] = Accounts[account] - amount
    end

    TriggerClientEvent('vr-bossmenu:client:refreshSociety', -1, account, Accounts[account])
    SaveResourceFile(GetCurrentResourceName(), "./accounts.json", json.encode(Accounts), -1)
end)

-- Get Employees
VRCore.Functions.CreateCallback('vr-bossmenu:server:GetEmployees', function(source, cb, jobname)
    local employees = {}
    if not Accounts[jobname] then
        Accounts[jobname] = 0
    end
    local players = exports.ghmattimysql:executeSync("SELECT * FROM `players` WHERE `job` LIKE '%".. jobname .."%'")
    if players[1] ~= nil then
        for key, value in pairs(players) do
            local isOnline = VRCore.Functions.GetPlayerByCitizenId(value.citizenid)

            if isOnline then
                table.insert(employees, {
                    source = isOnline.PlayerData.citizenid, 
                    grade = isOnline.PlayerData.job.grade,
                    isboss = isOnline.PlayerData.job.isboss,
                    name = isOnline.PlayerData.charinfo.firstname .. ' ' .. isOnline.PlayerData.charinfo.lastname
                })
            else
                table.insert(employees, {
                    source = value.citizenid, 
                    grade =  json.decode(value.job).grade,
                    isboss = json.decode(value.job).isboss,
                    name = json.decode(value.charinfo).firstname .. ' ' .. json.decode(value.charinfo).lastname
                })
            end
        end
    end
    cb(employees)
end)

-- Grade Change
RegisterServerEvent('vr-bossmenu:server:updateGrade')
AddEventHandler('vr-bossmenu:server:updateGrade', function(target, grade)
    local src = source
    local Player = VRCore.Functions.GetPlayer(src)
    local Employee = VRCore.Functions.GetPlayerByCitizenId(target)
    if Employee then
        if Employee.Functions.SetJob(Player.PlayerData.job.name, grade) then
            TriggerClientEvent('VRCore:Notify', src, "Grade Changed Successfully!", "success")
            TriggerClientEvent('VRCore:Notify', Employee.PlayerData.source, "Your Job Grade Is Now [" ..grade.."].", "success")
        else
            TriggerClientEvent('VRCore:Notify', src, "Grade Does Not Exist", "error")
        end
    else
        local player = exports.ghmattimysql:executeSync('SELECT * FROM players WHERE citizenid=@citizenid LIMIT 1', {['@citizenid'] = target})
        if player[1] ~= nil then
            Employee = player[1]
            local job = VRCore.Shared.Jobs[Player.PlayerData.job.name]
            local employeejob = json.decode(Employee.job)
            employeejob.grade = job.grades[data.grade]
            exports.ghmattimysql:execute('UPDATE players SET job=@job WHERE citizenid=@citizenid', {['@job'] = json.encode(employeejob), ['@citizenid'] = target})
            TriggerClientEvent('VRCore:Notify', src, "Grade Changed Successfully!", "success")
        else
            TriggerClientEvent('VRCore:Notify', src, "Player Does Not Exist", "error")
        end
    end
end)

-- Fire Employee
RegisterServerEvent('vr-bossmenu:server:fireEmployee')
AddEventHandler('vr-bossmenu:server:fireEmployee', function(target)
    local src = source
    local Player = VRCore.Functions.GetPlayer(src)
    local Employee = VRCore.Functions.GetPlayerByCitizenId(target)
    if Employee then
        if Employee.Functions.SetJob("unemployed", '0') then
            TriggerEvent('vr-log:server:CreateLog', 'bossmenu', 'Job Fire', "Successfully fired " .. GetPlayerName(Employee.PlayerData.source) .. ' (' .. Player.PlayerData.job.name .. ')', src)
            TriggerClientEvent('VRCore:Notify', src, "Fired successfully!", "success")
            TriggerClientEvent('VRCore:Notify', Employee.PlayerData.source , "You Were Fired", "error")
        else
            TriggerClientEvent('VRCore:Notify', src, "Contact Server Developer", "error")
        end
    else
        local player = exports.ghmattimysql:executeSync('SELECT * FROM players WHERE citizenid=@citizenid LIMIT 1', {['@citizenid'] = target})
        if player[1] ~= nil then
            Employee = player[1]
            local job = {}
            job.name = "unemployed"
            job.label = "Unemployed"
            job.payment = 10
            job.onduty = true
            job.isboss = false
            job.grade = {}
            job.grade.name = nil
            job.grade.level = 0
            exports.ghmattimysql:execute('UPDATE players SET job=@job WHERE citizenid=@citizenid', {['@job'] = json.encode(job), ['@citizenid'] = target})
            TriggerClientEvent('VRCore:Notify', src, "Fired successfully!", "success")
            TriggerEvent('vr-log:server:CreateLog', 'bossmenu', 'Fire', "Successfully fired " .. data.source .. ' (' .. Player.PlayerData.job.name .. ')', src)
        else
            TriggerClientEvent('VRCore:Notify', src, "Player Does Not Exist", "error")
        end
    end
end)

-- Recruit Player
RegisterServerEvent('vr-bossmenu:server:giveJob')
AddEventHandler('vr-bossmenu:server:giveJob', function(recruit)
    local src = source
    local Player = VRCore.Functions.GetPlayer(src)
    local Target = VRCore.Functions.GetPlayer(recruit)
    if Player.PlayerData.job.isboss == true then
        if Target and Target.Functions.SetJob(Player.PlayerData.job.name, 0) then
            TriggerClientEvent('VRCore:Notify', src, "You Recruited " .. (Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname) .. " To " .. Player.PlayerData.job.label .. "", "success")
            TriggerClientEvent('VRCore:Notify', Target.PlayerData.source , "You've Been Recruited To " .. Player.PlayerData.job.label .. "", "success")
            TriggerEvent('vr-log:server:CreateLog', 'bossmenu', 'Recruit', "Successfully recruited " .. (Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname) .. ' (' .. Player.PlayerData.job.name .. ')', src)
        end
    end
end)
