local doorInfo = {}

RegisterServerEvent('vr-doorlock:server:setupDoors')
AddEventHandler('vr-doorlock:server:setupDoors', function()
	local src = source
	TriggerClientEvent("vr-doorlock:client:setDoors", VR.Doors)
end)

RegisterServerEvent('vr-doorlock:server:updateState')
AddEventHandler('vr-doorlock:server:updateState', function(doorID, state)
	local src = source
	local Player = VRCore.Functions.GetPlayer(src)
	
	VR.Doors[doorID].locked = state

	TriggerClientEvent('vr-doorlock:client:setState', -1, doorID, state)
end)
