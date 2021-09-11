local config = {
    versionCheck = false, -- enables version checking (if this is enabled and there is no new version it won't display a message anyways)
    text = {
        -- Formatted using Lua strings, http://www.lua.org/pil/20.html
        format = '~y~Nearest Postal~w~: %s (~g~%.2fm~w~)',
        -- ScriptHook PLD Position
        --posX = 0.225,
        --posY = 0.963,
        -- vMenu PLD Position
        posX = 0.22,
        posY = 0.963
    },
    blip = {
        blipText = 'Postal Route %s', -- The text to display in chat when setting a new route.
        sprite = 8, -- The sprite ID to display, the list is available here:
        color = 3, -- The color ID to use (default is 3, light blue)
        distToDelete = 100.0, -- the blip will be removed at this distance (in meters)
        deleteText = 'Route deleted', -- The text to display in chat when a route is deleted
        drawRouteText = 'Drawing a route to %s', -- The text to display in chat when drawing a new route
        notExistText = "That postal doesn't exist" -- The text to display when a postal is not found.
    },
    updateDelay = nil, -- How often in milliseconds the postal code is updated on each client. I wouldn't recommend anything lower than 50ms for performance reasons
}
-- optimizations
local vec = vec
local format = string.format
--local IsHudHidden = IsHudHidden
--local SetTextFont = SetTextFont
--local SetTextScale = SetTextScale
--local SetTextOutline = SetTextOutline
local GetEntityCoords = GetEntityCoords
--local EndTextCommandDisplayText = EndTextCommandDisplayText
--local BeginTextCommandDisplayText = BeginTextCommandDisplayText
local AddTextComponentSubstringPlayerName = AddTextComponentSubstringPlayerName
-- end optimizations


postals = nil
nearest = nil
pBlip = nil

CreateThread(function()
    postals = LoadResourceFile(GetCurrentResourceName(), GetResourceMetadata(GetCurrentResourceName(), 'postal_file'))
    postals = json.decode(postals)
    for i, postal in ipairs(postals) do postals[i] = {
        vec(postal.x, postal.y), code = postal.code
    } end
end)

exports('GetPostal', function() return nearest and nearest.code or nil end)

TriggerEvent('chat:addSuggestion', '/postal', 'Set the GPS to a specific postal', { { name = 'Postal Code', help = 'The postal code you would like to go to' } })

RegisterCommand('postal', function(_, args)
    if #args < 1 then
        if pBlip then
            RemoveBlip(pBlip.hndl)
            pBlip = nil
            TriggerEvent('chat:addMessage', { color = { 255, 0, 0 }, args = { 'Postals', config.blip.deleteText } })
        end
        return
    end

    local userPostal = string.upper(args[1])
    local foundPostal

    for _, p in ipairs(postals) do
        if string.upper(p.code) == userPostal then
            foundPostal = p
            break
        end
    end

    if foundPostal then
        if pBlip then RemoveBlip(pBlip.hndl) end
        local blip = AddBlipForCoord(foundPostal[1][1], foundPostal[1][2], 0.0)
        pBlip = { hndl = blip, p = foundPostal }
        SetBlipRoute(blip, true)
        SetBlipSprite(blip, config.blip.sprite)
        SetBlipColour(blip, config.blip.color)
        SetBlipRouteColour(blip, config.blip.color)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(format(config.blip.blipText, pBlip.p.code))
        EndTextCommandSetBlipName(blip)

        TriggerEvent('chat:addMessage', { color = { 255, 0, 0 }, args = { 'Postals', format(config.blip.drawRouteText, foundPostal.code) } })
    else
        TriggerEvent('chat:addMessage', { color = { 255, 0, 0 }, args = { 'Postals', config.blip.notExistText } })
    end
end)


--local nearestPostalText = ""

CreateThread(function()
    while postals == nil do Wait(1) end

    local delay = math.max(config.updateDelay and tonumber(config.updateDelay) or 300, 50)
    if not delay or tonumber(delay) <= 0 then
        error("Invalid render delay provided, it must be a number > 0")
    end

    local postals = postals
    local deleteDist = config.blip.distToDelete
    --local formatTemplate = config.text.format
    local _total = #postals

    while true do
        local coords = GetEntityCoords(PlayerPedId())
        local _nearestIndex, _nearestD
        coords = vec(coords[1], coords[2])

        for i = 1, _total do
            local D = #(coords - postals[i][1])
            if not _nearestD or D < _nearestD then
                _nearestIndex = i
                _nearestD = D
            end
        end

        if pBlip and #(pBlip.p[1] - coords) < deleteDist then
            TriggerEvent('chat:addMessage', { color = { 255, 0, 0 }, args = { 'Postals', "You've reached your postal destination!" } })
            RemoveBlip(pBlip.hndl)
            pBlip = nil
        end

        local _code = postals[_nearestIndex].code
        nearest = { code = _code, dist = _nearestD }
        --nearestPostalText = format(formatTemplate, _code, _nearestD)
        Wait(delay)
    end
end)

-- text display thread
--[[ -- Currently handled by hud but changes should be made (remove other comments if enabling)
Citizen.CreateThread(function()
    local posX = config.text.posX
    local posY = config.text.posY
    local _string = "STRING"
    local _scale = 0.42
    local _font = 4
    while true do
        if nearest and not IsHudHidden() then
            SetTextScale(_scale, _scale)
            SetTextFont(_font)
            SetTextOutline()
            BeginTextCommandDisplayText(_string)
            AddTextComponentSubstringPlayerName(nearestPostalText)
            EndTextCommandDisplayText(posX, posY)
        end
        Wait(0)
    end
end)
]]