RegisterServerEvent("KickForAFK")
AddEventHandler("KickForAFK", function()
	DropPlayer(source, "You Have Been Kicked For Being AFK")
end)

VRCore.Functions.CreateCallback('vr-afkkick:server:GetPermissions', function(source, cb)
    local group = VRCore.Functions.GetPermission(source)
    cb(group)
end)