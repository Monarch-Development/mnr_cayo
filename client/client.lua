---@class cayo
local cayo = {}
cayo.__index = cayo

cayo.coords = vec3(5046.0, -5106.0, 6.0)
cayo.radius = 1500.0
cayo.active = false

function cayo:toggleIpls(toggle)
    local toggleIpl = toggle and RequestIpl or RemoveIpl
    for _, name in ipairs(config.ipls) do
        toggleIpl(name)
    end
end

function cayo:adapt()
    local islandZoneId = GetZoneFromNameId('PrLog')
    SetAudioFlag('DisableFlightMusic', true)
    SetAmbientZoneListStatePersistent('AZL_DLC_Hei4_Island_Zones', true, true)
    SetAmbientZoneListStatePersistent('AZL_DLC_Hei4_Island_Disabled_Zones', false, true)
    SetZoneEnabled(islandZoneId, false)
end

function cayo:toggleState(toggle)
    if toggle then
        SetDeepOceanScaler(0.0)
    end

    if self.active == toggle then return end

    local status = toggle and 1 or 0
    SetAiGlobalPathNodesType(status)
    self.active = toggle
end

function cayo:update()
    local playerPed = PlayerPedId()
    local distance = #(GetEntityCoords(playerPed) - self.coords)

    self:toggleState(distance < self.radius)
end

CreateThread(function()
    cayo:toggleIpls(true)
    cayo:adapt()
    while true do
        cayo:update()
        Wait(2000)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    cayo:toggleIpls(false)
    cayo:toggleState(false)
end)