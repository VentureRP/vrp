VRCore.Functions = {}

VRCore.Functions.GetEntityCoords = function(entity)
    local coords = GetEntityCoords(entity, false)
    local heading = GetEntityHeading(entity)
    return {
        x = coords.x,
        y = coords.y,
        z = coords.z,
        a = heading
    }
end

VRCore.Functions.GetIdentifier = function(source, idtype)
	local idtype = idtype ~=nil and idtype or VRConfig.IdentifierType
	for _, identifier in pairs(GetPlayerIdentifiers(source)) do
		if string.find(identifier, idtype) then
			return identifier
		end
	end
	return nil
end

VRCore.Functions.GetSource = function(identifier)
	for src, player in pairs(VRCore.Players) do
		local idens = GetPlayerIdentifiers(src)
		for _, id in pairs(idens) do
			if identifier == id then
				return src
			end
		end
	end
	return 0
end

VRCore.Functions.GetPlayer = function(source)
	if type(source) == "number" then
		return VRCore.Players[source]
	else
		return VRCore.Players[VRCore.Functions.GetSource(source)]
	end
end

VRCore.Functions.GetPlayerByCitizenId = function(citizenid)
	for src, player in pairs(VRCore.Players) do
		local cid = citizenid
		if VRCore.Players[src].PlayerData.citizenid == cid then
			return VRCore.Players[src]
		end
	end
	return nil
end

VRCore.Functions.GetPlayerByPhone = function(number)
	for src, player in pairs(VRCore.Players) do
		local cid = citizenid
		if VRCore.Players[src].PlayerData.charinfo.phone == number then
			return VRCore.Players[src]
		end
	end
	return nil
end

VRCore.Functions.GetPlayers = function()
	local sources = {}
	for k, v in pairs(VRCore.Players) do
		table.insert(sources, k)
	end
	return sources
end

VRCore.Functions.CreateCallback = function(name, cb)
	VRCore.ServerCallbacks[name] = cb
end

VRCore.Functions.TriggerCallback = function(name, source, cb, ...)
	if VRCore.ServerCallbacks[name] ~= nil then
		VRCore.ServerCallbacks[name](source, cb, ...)
	end
end

VRCore.Functions.CreateUseableItem = function(item, cb)
	VRCore.UseableItems[item] = cb
end

VRCore.Functions.CanUseItem = function(item)
	return VRCore.UseableItems[item] ~= nil
end

VRCore.Functions.UseItem = function(source, item)
	VRCore.UseableItems[item.name](source, item)
end

VRCore.Functions.Kick = function(source, reason, setKickReason, deferrals)
	local src = source
	reason = "\n"..reason.."\n🔸 Check our Discord for further information: "..VRCore.Config.Server.discord
	if(setKickReason ~=nil) then
		setKickReason(reason)
	end
	Citizen.CreateThread(function()
		if(deferrals ~= nil)then
			deferrals.update(reason)
			Citizen.Wait(2500)
		end
		if src ~= nil then
			DropPlayer(src, reason)
		end
		local i = 0
		while (i <= 4) do
			i = i + 1
			while true do
				if src ~= nil then
					if(GetPlayerPing(src) >= 0) then
						break
					end
					Citizen.Wait(100)
					Citizen.CreateThread(function() 
						DropPlayer(src, reason)
					end)
				end
			end
			Citizen.Wait(5000)
		end
	end)
end

VRCore.Functions.IsWhitelisted = function(source)
	local identifiers = GetPlayerIdentifiers(source)
	local rtn = false
	if (VRCore.Config.Server.whitelist) then
		local result = exports['ghmattimysql']:executeSync('SELECT * FROM whitelist WHERE license=@license', {['@license'] = VRCore.Functions.GetIdentifier(source, 'license')})
		local data = result[1]
		if data ~= nil then
			for _, id in pairs(identifiers) do
				if data.license == id then
					rtn = true
				end
			end
		end
	else
		rtn = true
	end
	return rtn
end

VRCore.Functions.AddPermission = function(source, permission)
	local Player = VRCore.Functions.GetPlayer(source)
	if Player ~= nil then 
		VRCore.Config.Server.PermissionList[VRCore.Functions.GetIdentifier(source, 'license')] = {
			license = VRCore.Functions.GetIdentifier(source, 'license'),
			permission = permission:lower(),
		}
		exports['ghmattimysql']:execute('DELETE FROM permissions WHERE license=@license', {['@license'] = VRCore.Functions.GetIdentifier(source, 'license')})

		exports['ghmattimysql']:execute('INSERT INTO permissions (name, license, permission) VALUES (@name, @license, @permission)', {
			['@name'] = GetPlayerName(source),
			['@license'] = VRCore.Functions.GetIdentifier(source, 'license'),
			['@permission'] = permission:lower()
		})

		Player.Functions.UpdatePlayerData()
		TriggerClientEvent('VRCore:Client:OnPermissionUpdate', source, permission)
	end
end

VRCore.Functions.RemovePermission = function(source)
	local Player = VRCore.Functions.GetPlayer(source)
	if Player ~= nil then 
		VRCore.Config.Server.PermissionList[VRCore.Functions.GetIdentifier(source, 'license')] = nil	
		exports['ghmattimysql']:execute('DELETE FROM permissions WHERE license=@license', {['@license'] = VRCore.Functions.GetIdentifier(source, 'license')})
		Player.Functions.UpdatePlayerData()
	end
end

VRCore.Functions.HasPermission = function(source, permission)
	local retval = false
	local license = VRCore.Functions.GetIdentifier(source, 'license')
	local permission = tostring(permission:lower())
	if permission == "user" then
		retval = true
	else
		if VRCore.Config.Server.PermissionList[license] ~= nil then 
			if VRCore.Config.Server.PermissionList[license].license == license then
				if VRCore.Config.Server.PermissionList[license].permission == permission or VRCore.Config.Server.PermissionList[license].permission == "god" then
					retval = true
				end
			end
		end
	end
	return retval
end

VRCore.Functions.GetPermission = function(source)
	local retval = "user"
	Player = VRCore.Functions.GetPlayer(source)
	local license = VRCore.Functions.GetIdentifier(source, 'license')
	if Player ~= nil then
		if VRCore.Config.Server.PermissionList[Player.PlayerData.license] ~= nil then 
			if VRCore.Config.Server.PermissionList[Player.PlayerData.license].license == license then
				retval = VRCore.Config.Server.PermissionList[Player.PlayerData.license].permission
			end
		end
	end
	return retval
end

VRCore.Functions.IsOptin = function(source)
	local retval = false
	local license = VRCore.Functions.GetIdentifier(source, 'license')
	if VRCore.Functions.HasPermission(source, "admin") then
		retval = VRCore.Config.Server.PermissionList[license].optin
	end
	return retval
end

VRCore.Functions.ToggleOptin = function(source)
	local license = VRCore.Functions.GetIdentifier(source, 'license')
	if VRCore.Functions.HasPermission(source, "admin") then
		VRCore.Config.Server.PermissionList[license].optin = not VRCore.Config.Server.PermissionList[license].optin
	end
end

VRCore.Functions.IsPlayerBanned = function (source)
	local retval = false
	local message = ""
    local result = exports.ghmattimysql:executeSync('SELECT * FROM bans WHERE license=@license', {['@license'] = VRCore.Functions.GetIdentifier(source, 'license')})
    if result[1] ~= nil then
        if os.time() < result[1].expire then
            retval = true
            local timeTable = os.date("*t", tonumber(result.expire))
            message = "You have been banned from the server:\n"..result[1].reason.."\nYour ban expires "..timeTable.day.. "/" .. timeTable.month .. "/" .. timeTable.year .. " " .. timeTable.hour.. ":" .. timeTable.min .. "\n"
        else
            exports['ghmattimysql']:execute('DELETE FROM bans WHERE id=@id', {['@id'] = result[1].id})
        end
    end
	return retval, message
end

VRCore.Functions.IsLicenseInUse = function(license)
    local players = GetPlayers()
    for _, player in pairs(players) do
        local identifiers = GetPlayerIdentifiers(player)
        for _, id in pairs(identifiers) do
            if string.find(id, 'license') then
                local playerLicense = id
                if playerLicense == license then
                    return true
                end
            end
        end
    end
    return false
end