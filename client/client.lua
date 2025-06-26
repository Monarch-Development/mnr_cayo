local island = lib.load("data.island")

for _, ipl in pairs(island) do
    RequestIpl(ipl)
end

SetAudioFlag("DisableFlightMusic", true)
SetAmbientZoneListStatePersistent("AZL_DLC_Hei4_Island_Zones", true, true)
SetAmbientZoneListStatePersistent("AZL_DLC_Hei4_Island_Disabled_Zones", false, true)
SetZoneEnabled(GetZoneFromNameId("PrLog"), false)

lib.points.new({
    coords = vec3(5046, -5106, 6),
    distance = 2500,
    onEnter = function()
        SetAiGlobalPathNodesType(1)
        LoadGlobalWaterType(1)
    end,
    onExit = function()
        SetAiGlobalPathNodesType(0)
        LoadGlobalWaterType(0)
    end,
})

AddEventHandler("onResourceStop", function(resourceName)
    local scriptName = cache.resource or GetCurrentResourceName()
    if resourceName ~= scriptName then return end
    for _, ipl in pairs(island) do
        RemoveIpl(ipl)
    end
end)