VRCore = {}
VRCore.PlayerData = {}
VRCore.Config = VRConfig
VRCore.Shared = VRShared
VRCore.ServerCallbacks = {}

isLoggedIn = false

function GetCoreObject()
	return VRCore
end

RegisterNetEvent('VRCore:GetObject')
AddEventHandler('VRCore:GetObject', function(cb)
	cb(GetCoreObject())
end)

RegisterNetEvent('VRCore:Client:OnPlayerLoaded')
AddEventHandler('VRCore:Client:OnPlayerLoaded', function()
	ShutdownLoadingScreenNui()
	isLoggedIn = true
    	SetCanAttackFriendly(PlayerPedId(), true, false)
    	NetworkSetFriendlyFireOption(true)
end)

RegisterNetEvent('VRCore:Client:OnPlayerUnload')
AddEventHandler('VRCore:Client:OnPlayerUnload', function()
    isLoggedIn = false
end)
