local IslandParts = lib.load("data.island")

local function ActiveCayo()
    for _, part in pairs(IslandParts) do
        RequestIpl(part)
    end
end

local function SetupAmbient()
    SetAudioFlag("DisableFlightMusic", true)
    SetAmbientZoneListStatePersistent("AZL_DLC_Hei4_Island_Zones", true, true)
    SetAmbientZoneListStatePersistent("AZL_DLC_Hei4_Island_Disabled_Zones", false, true)
    SetZoneEnabled(GetZoneFromNameId("PrLog"), false)
end

local function ActiveCayoPoint()
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
end

AddEventHandler("onClientResourceStart", function(resourceName)
    local scriptName = cache.resource or GetCurrentResourceName()
    if resourceName ~= scriptName then return end
    ActiveCayo()
    SetupAmbient()
    ActiveCayoPoint()
end)