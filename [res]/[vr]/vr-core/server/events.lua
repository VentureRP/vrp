-- Player joined
RegisterServerEvent("VRCore:PlayerJoined")
AddEventHandler('VRCore:PlayerJoined', function()
	local src = source
end)

AddEventHandler('playerDropped', function(reason) 
	local src = source
	print("Dropped: "..GetPlayerName(src))
	TriggerEvent("vr-log:server:CreateLog", "joinleave", "Dropped", "red", "**".. GetPlayerName(src) .. "** ("..VRCore.Functions.GetIdentifier(src, 'license')..") left..")
	if reason ~= "Reconnecting" and src > 60000 then return false end
	if(src==nil or (VRCore.Players[src] == nil)) then return false end
	VRCore.Players[src].Functions.Save()
	VRCore.Players[src] = nil
end)

local function OnPlayerConnecting(name, setKickReason, deferrals)
    local player = source
    local license
    local identifiers = GetPlayerIdentifiers(player)
    deferrals.defer()

    -- mandatory wait!
    Wait(0)

    deferrals.update(string.format("Hello %s. Validating Your Rockstar License", name))

    for _, v in pairs(identifiers) do
        if string.find(v, 'license') then
            license = v
            break
        end
    end

    -- mandatory wait!
    Wait(2500)

    deferrals.update(string.format("Hello %s. We are checking if you are banned.", name))
	
    local isBanned, Reason = VRCore.Functions.IsPlayerBanned(player)
    local isLicenseAlreadyInUse = VRCore.Functions.IsLicenseInUse(license)
	
    Wait(2500)
	
    deferrals.update(string.format("Welcome %s to {Server Name}.", name))

    if not license then
        deferrals.done('No Valid Rockstar License Found')
    elseif isBanned then
	    deferrals.done(Reason)
    elseif isLicenseAlreadyInUse then
        deferrals.done('Duplicate Rockstar License Found')
    else
        deferrals.done()
        Wait(1000)
        TriggerEvent("connectqueue:playerConnect", name, setKickReason, deferrals)
    end
    --Add any additional defferals you may need!
end

AddEventHandler("playerConnecting", OnPlayerConnecting)

RegisterServerEvent("VRCore:server:CloseServer")
AddEventHandler('VRCore:server:CloseServer', function(reason)
    local src = source
    local Player = VRCore.Functions.GetPlayer(src)

    if VRCore.Functions.HasPermission(source, "admin") or VRCore.Functions.HasPermission(source, "god") then 
        local reason = reason ~= nil and reason or "No reason specified..."
        VRCore.Config.Server.closed = true
        VRCore.Config.Server.closedReason = reason
        TriggerClientEvent("vradmin:client:SetServerStatus", -1, true)
	else
		VRCore.Functions.Kick(src, "You don't have permissions for this..", nil, nil)
    end
end)

RegisterServerEvent("VRCore:server:OpenServer")
AddEventHandler('VRCore:server:OpenServer', function()
    local src = source
    local Player = VRCore.Functions.GetPlayer(src)
    if VRCore.Functions.HasPermission(source, "admin") or VRCore.Functions.HasPermission(source, "god") then
        VRCore.Config.Server.closed = false
        TriggerClientEvent("vradmin:client:SetServerStatus", -1, false)
    else
        VRCore.Functions.Kick(src, "You don't have permissions for this..", nil, nil)
    end
end)

RegisterServerEvent("VRCore:UpdatePlayer")
AddEventHandler('VRCore:UpdatePlayer', function(data)
	local src = source
	local Player = VRCore.Functions.GetPlayer(src)
	if Player ~= nil then
		Player.PlayerData.position = data.position
		local newHunger = Player.PlayerData.metadata["hunger"] - 4.2
		local newThirst = Player.PlayerData.metadata["thirst"] - 3.8
		if newHunger <= 0 then newHunger = 0 end
		if newThirst <= 0 then newThirst = 0 end
		Player.Functions.SetMetaData("thirst", newThirst)
		Player.Functions.SetMetaData("hunger", newHunger)
		TriggerClientEvent("hud:client:UpdateNeeds", src, newHunger, newThirst)
		Player.Functions.Save()
	end
end)

RegisterServerEvent("VRCore:UpdatePlayerPosition")
AddEventHandler("VRCore:UpdatePlayerPosition", function(position)
	local src = source
	local Player = VRCore.Functions.GetPlayer(src)
	if Player ~= nil then
		Player.PlayerData.position = position
	end
end)

RegisterServerEvent("VRCore:Server:TriggerCallback")
AddEventHandler('VRCore:Server:TriggerCallback', function(name, ...)
	local src = source
	VRCore.Functions.TriggerCallback(name, src, function(...)
		TriggerClientEvent("VRCore:Client:TriggerCallback", src, name, ...)
	end, ...)
end)

RegisterServerEvent("VRCore:Server:UseItem")
AddEventHandler('VRCore:Server:UseItem', function(item)
	local src = source
	local Player = VRCore.Functions.GetPlayer(src)
	if item ~= nil and item.amount > 0 then
		if VRCore.Functions.CanUseItem(item.name) then
			VRCore.Functions.UseItem(src, item)
		end
	end
end)

RegisterServerEvent("VRCore:Server:RemoveItem")
AddEventHandler('VRCore:Server:RemoveItem', function(itemName, amount, slot)
	local src = source
	local Player = VRCore.Functions.GetPlayer(src)
	Player.Functions.RemoveItem(itemName, amount, slot)
end)

RegisterServerEvent("VRCore:Server:AddItem")
AddEventHandler('VRCore:Server:AddItem', function(itemName, amount, slot, info)
	local src = source
	local Player = VRCore.Functions.GetPlayer(src)
	Player.Functions.AddItem(itemName, amount, slot, info)
end)

RegisterServerEvent('VRCore:Server:SetMetaData')
AddEventHandler('VRCore:Server:SetMetaData', function(meta, data)
    local src = source
	local Player = VRCore.Functions.GetPlayer(src)
	if meta == "hunger" or meta == "thirst" then
		if data > 100 then
			data = 100
		end
	end
	if Player ~= nil then 
		Player.Functions.SetMetaData(meta, data)
	end
	TriggerClientEvent("hud:client:UpdateNeeds", src, Player.PlayerData.metadata["hunger"], Player.PlayerData.metadata["thirst"])
end)

AddEventHandler('chatMessage', function(source, n, message)
	if string.sub(message, 1, 1) == "/" then
		local args = VRCore.Shared.SplitStr(message, " ")
		local command = string.gsub(args[1]:lower(), "/", "")
		CancelEvent()
		if VRCore.Commands.List[command] ~= nil then
			local Player = VRCore.Functions.GetPlayer(tonumber(source))
			if Player ~= nil then
				table.remove(args, 1)
				if (VRCore.Functions.HasPermission(source, "god") or VRCore.Functions.HasPermission(source, VRCore.Commands.List[command].permission)) then
					if (VRCore.Commands.List[command].argsrequired and #VRCore.Commands.List[command].arguments ~= 0 and args[#VRCore.Commands.List[command].arguments] == nil) then
					    TriggerClientEvent('VRCore:Notify', source, "All arguments must be filled out!", "error")
					    local agus = ""
					    for name, help in pairs(VRCore.Commands.List[command].arguments) do
					    	agus = agus .. " ["..help.name.."]"
					    end
				        TriggerClientEvent('chatMessage', source, "/"..command, false, agus)
					else
						VRCore.Commands.List[command].callback(source, args)
					end
				else
					TriggerClientEvent('VRCore:Notify', source, "No Access To This Command", "error")
				end
			end
		end
	end
end)

RegisterServerEvent('VRCore:CallCommand')
AddEventHandler('VRCore:CallCommand', function(command, args)
	if VRCore.Commands.List[command] ~= nil then
		local Player = VRCore.Functions.GetPlayer(tonumber(source))
		if Player ~= nil then
			if (VRCore.Functions.HasPermission(source, "god")) or (VRCore.Functions.HasPermission(source, VRCore.Commands.List[command].permission)) or (VRCore.Commands.List[command].permission == Player.PlayerData.job.name) then
				if (VRCore.Commands.List[command].argsrequired and #VRCore.Commands.List[command].arguments ~= 0 and args[#VRCore.Commands.List[command].arguments] == nil) then
					TriggerClientEvent('VRCore:Notify', source, "All arguments must be filled out!", "error")
					local agus = ""
					for name, help in pairs(VRCore.Commands.List[command].arguments) do
						agus = agus .. " ["..help.name.."]"
					end
					TriggerClientEvent('chatMessage', source, "/"..command, false, agus)
				else
					VRCore.Commands.List[command].callback(source, args)
				end
			else
				TriggerClientEvent('VRCore:Notify', source, "No Access To This Command", "error")
			end
		end
	end
end)

RegisterServerEvent("VRCore:AddCommand")
AddEventHandler('VRCore:AddCommand', function(name, help, arguments, argsrequired, callback, persmission)
	VRCore.Commands.Add(name, help, arguments, argsrequired, callback, persmission)
end)

RegisterServerEvent("VRCore:ToggleDuty")
AddEventHandler('VRCore:ToggleDuty', function()
	local src = source
	local Player = VRCore.Functions.GetPlayer(src)
	if Player.PlayerData.job.onduty then
		Player.Functions.SetJobDuty(false)
		TriggerClientEvent('VRCore:Notify', src, "You are now off duty!")
	else
		Player.Functions.SetJobDuty(true)
		TriggerClientEvent('VRCore:Notify', src, "You are now on duty!")
	end
	TriggerClientEvent("VRCore:Client:SetDuty", src, Player.PlayerData.job.onduty)
end)

Citizen.CreateThread(function()
	local result = exports['ghmattimysql']:executeSync('SELECT * FROM permissions')
	if result[1] ~= nil then
		for k, v in pairs(result) do
			VRCore.Config.Server.PermissionList[v.license] = {
				license = v.license,
				permission = v.permission,
				optin = true,
			}
		end
	end
end)

VRCore.Functions.CreateCallback('VRCore:HasItem', function(source, cb, items, amount)
	local retval = false
	local Player = VRCore.Functions.GetPlayer(source)
	if Player ~= nil then
		if type(items) == 'table' then
			local count = 0
            		local finalcount = 0
			for k, v in pairs(items) do
				if type(k) == 'string' then
                    			finalcount = 0
                    			for i, _ in pairs(items) do
                        			if i then finalcount = finalcount + 1 end
                    			end
					local item = Player.Functions.GetItemByName(k)
					if item ~= nil then
						if item.amount >= v then
							count = count + 1
							if count == finalcount then
								retval = true
							end
						end
					end
				else
                    			finalcount = #items
					local item = Player.Functions.GetItemByName(v)
					if item ~= nil then
						if amount ~= nil then
							if item.amount >= amount then
								count = count + 1
								if count == finalcount then
									retval = true
								end
							end
						else
							count = count + 1
							if count == finalcount then
								retval = true
							end
						end
					end
				end
			end
		else
			local item = Player.Functions.GetItemByName(items)
			if item ~= nil then
				if amount ~= nil then
					if item.amount >= amount then
						retval = true
					end
				else
					retval = true
				end
			end
		end
	end

	cb(retval)
end)

RegisterServerEvent('VRCore:Command:CheckOwnedVehicle')
AddEventHandler('VRCore:Command:CheckOwnedVehicle', function(VehiclePlate)
	if VehiclePlate ~= nil then
		local result = exports['ghmattimysql']:executeSync('SELECT * FROM player_vehicles WHERE plate=@plate', {['@plate'] = VehiclePlate})
		if result[1] ~= nil then
			exports.ghmattimysql:execute('UPDATE player_vehicles SET state=@state WHERE citizenid=@citizenid', {['@state'] = 1, ['@citizenid'] = result[1].citizenid})
			TriggerEvent('vr-garages:server:RemoveVehicle', result[1].citizenid, VehiclePlate)
		end
	end
end)
