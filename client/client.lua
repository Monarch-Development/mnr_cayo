local island = lib.load("data.island")

for _, ipl in pairs(island) do
    RequestIpl(ipl)
end

SetAudioFlag("DisableFlightMusic", true)
SetAmbientZoneListStatePersistent("AZL_DLC_Hei4_Island_Zones", true, true)
SetAmbientZoneListStatePersistent("AZL_DLC_Hei4_Island_Disabled_Zones", false, true)
SetZoneEnabled(GetZoneFromNameId("PrLog"), false)

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

AddEventHandler("onResourceStop", function(resourceName)
    local scriptName = cache.resource or GetCurrentResourceName()
    if resourceName ~= scriptName then return end
    for _, ipl in pairs(island) do
        RemoveIpl(ipl)
    end
    toggleIslandFix(false)
end)