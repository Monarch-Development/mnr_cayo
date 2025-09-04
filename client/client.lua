local ipls = lib.load('data.ipls')

for _, name in pairs(ipls) do
    RequestIpl(name)
end

local islandZoneId = GetZoneFromNameId('PrLog')
SetAudioFlag('DisableFlightMusic', true)
SetAmbientZoneListStatePersistent('AZL_DLC_Hei4_Island_Zones', true, true)
SetAmbientZoneListStatePersistent('AZL_DLC_Hei4_Island_Disabled_Zones', false, true)
SetZoneEnabled(islandZoneId, false)

local function toggleIslandFix(toggle)
    local status = toggle and 1 or 0
    SetAiGlobalPathNodesType(status)
    LoadGlobalWaterType(status)
end

lib.points.new({
    coords = vec3(5046, -5106, 6),
    distance = 2500,
    onEnter = function()
        toggleIslandFix(true)
    end,
    onExit = function()
        toggleIslandFix(false)
    end,
})

AddEventHandler('onResourceStop', function(resourceName)
    local scriptName = cache.resource or GetCurrentResourceName()
    if resourceName ~= scriptName then return end
    for _, name in pairs(ipls) do
        RemoveIpl(name)
    end
    toggleIslandFix(false)
end)