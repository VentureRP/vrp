if GetCurrentResourceName() == 'vr-core' then 
    function GetSharedObject()
        return VRCore
    end

    exports('GetSharedObject', GetSharedObject)
end

VRCore = exports['vr-core']:GetSharedObject()
