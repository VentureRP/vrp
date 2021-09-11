VRCore = {}
VRCore.Config = VRConfig
VRCore.Shared = VRShared
VRCore.ServerCallbacks = {}
VRCore.UseableItems = {}

function GetCoreObject()
	return VRCore
end

RegisterServerEvent('VRCore:GetObject')
AddEventHandler('VRCore:GetObject', function(cb)
	cb(GetCoreObject())
end)