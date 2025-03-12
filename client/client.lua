local ESX = exports['es_extended']:getSharedObject()
local ox_lib = exports.ox_lib
local XPedId = PlayerPedId()
local XPedCords = GetEntityCoords(XPedId)

local entityEnumerator = {
    __gc = function(enum)
        if enum.destructor and enum.handle then
            enum.destructor(enum.handle)
        end
        enum.destructor = nil
        enum.handle = nil
    end
}

local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
    return coroutine.wrap(
        function()
            local iter, id = initFunc()
            if not id or id == 0 then
                disposeFunc(iter)
                return
            end

            local enum = {handle = iter, destructor = disposeFunc}
            setmetatable(enum, entityEnumerator)

            local next = true
            repeat
                coroutine.yield(id)
                next, id = moveFunc(iter)
            until not next

            enum.destructor, enum.handle = nil, nil
            disposeFunc(iter)
        end
    )
end

local function GetWorldObjects()
    return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
end

local function GetWorldPeds()
    return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end

local function GetWorldVehicles()
    return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

local function modifyWorldObjects(alpha, distance)
    for obj in GetWorldObjects() do
        if not IsEntityOnScreen(obj) and #(XPedCords - GetEntityCoords(obj)) > distance then
            SetEntityAlpha(obj, 0)
            if not IsEntityAMissionEntity(obj) then
                SetEntityAsNoLongerNeeded(obj)
            end
        else
            if GetEntityAlpha(obj) ~= alpha then
                SetEntityAlpha(obj, alpha)
            end
        end
        Wait(0)
    end
end

local function modifyWorldPeds(alpha, distance)
    for obj in GetWorldPeds() do
        if not IsEntityOnScreen(obj) and #(XPedCords - GetEntityCoords(obj)) > distance then
            SetEntityAlpha(obj, 0)
            if not IsEntityAMissionEntity(obj) then
                SetEntityAsNoLongerNeeded(obj)
            end
        else
            if GetEntityAlpha(obj) ~= alpha then
                SetEntityAlpha(obj, alpha)
            end
        end
        SetPedAoBlobRendering(obj, false)
        Wait(0)
    end
end

local function modifyWorldVehicles(alpha, distance)
    for obj in GetWorldVehicles() do
        if not IsEntityOnScreen(obj) and #(XPedCords - GetEntityCoords(obj)) > distance then
            SetEntityAlpha(obj, 0)
            if not IsEntityAMissionEntity(obj) then
                SetEntityAsNoLongerNeeded(obj)
            end
        else
            if GetEntityAlpha(obj) ~= alpha then
                SetEntityAlpha(obj, alpha)
            end
        end
        Wait(0)
    end
end

local function applyFPSBoost(level)
    if level == "ultra_low" then
        SetTimecycleModifier("ReduceDrawDistanceMission")
        modifyWorldObjects(210,90)
        modifyWorldPeds(245, 60)
        modifyWorldVehicles(255, 120)
        DisableOcclusionThisFrame()
        SetDisableDecalRenderingThisFrame()
        RopeDrawShadowEnabled(false)
        CascadeShadowsClearShadowSampleType()
        CascadeShadowsSetAircraftMode(false)
        CascadeShadowsEnableEntityTracker(true)
        CascadeShadowsSetDynamicDepthMode(false)
        CascadeShadowsSetEntityTrackerScale(0.0)
        CascadeShadowsSetDynamicDepthValue(0.0)
        CascadeShadowsSetCascadeBoundsScale(0.0)
        SetFlashLightFadeDistance(0.0)
        SetLightsCutoffDistanceTweak(0.0)
        DistantCopCarSirens(false)
        SetArtificialLightsState(true)
        RemoveParticleFxInRange(XPedCords, 10.0)
        OverrideLodscaleThisFrame(0.4)
        fpsBoostActive = true
    elseif level == "medium" then
        SetTimecycleModifier("yell_tunnel_nodirect")
        modifyWorldObjects(210,130)
        modifyWorldPeds(250, 100)
        modifyWorldVehicles(255, 160)
        SetTimecycleModifierStrength(0.5)
        SetArtificialLightsState(false)
        SetReducePedModelBudget(false)
        SetReduceVehicleModelBudget(false)
        SetParticleFxNonLoopedAlpha(0.5)
        OverrideLodscaleThisFrame(0.6)
        fpsBoostActive = true
        fpsBoostnopedandobj = false
    elseif level == "high" then
        ClearTimecycleModifier()
        modifyWorldObjects(245,200)
        modifyWorldPeds(255, 150)
        modifyWorldVehicles(255, 250)
        SetArtificialLightsState(false)
        SetParticleFxNonLoopedAlpha(1.0)
        OverrideLodscaleThisFrame(0.8)
        fpsBoostActive = false
        fpsBoostnopedandobj = false
    end
end

local function setUltraGraphics()
    ClearTimecycleModifier()
    ClearExtraTimecycleModifier()
    SetArtificialLightsState(false)
    SetParticleFxNonLoopedAlpha(1.0)
    OverrideLodscaleThisFrame(2.0) 
    SetFlashLightFadeDistance(100.0) 
    SetLightsCutoffDistanceTweak(100.0) 
    CascadeShadowsSetCascadeBoundsScale(1.5) 
    CascadeShadowsSetDynamicDepthValue(1.0) 
    CascadeShadowsSetEntityTrackerScale(1.0)
    DistantCopCarSirens(true) 
    RopeDrawShadowEnabled(true)
    SetTimecycleModifier('v_torture')
    SetExtraTimecycleModifier('reflection_correct_ambient')
    fpsBoostActive = false
    fpsBoostnopedandobj = false
end


local function resetSettings()
    OverrideLodscaleThisFrame(1.0)
    DisableVehicleDistantlights(false)
    ClearTimecycleModifier()
    ClearExtraTimecycleModifier()
    SetArtificialLightsState(false)
    SetParticleFxNonLoopedAlpha(1.0)
    fpsBoostActive = false
    fpsBoostnopedandobj = false
    for obj in GetWorldObjects() do
        if GetEntityAlpha(obj) ~= 255 then
            SetEntityAlpha(obj, 255)
        end
        Wait(0)
    end
    for obj in GetWorldPeds() do
        if GetEntityAlpha(obj) ~= 255 then
            SetEntityAlpha(obj, 255)
        end
        SetPedAoBlobRendering(obj, true)
        Wait(0)
    end
    for obj in GetWorldVehicles() do
        if GetEntityAlpha(obj) ~= 255 then
            SetEntityAlpha(obj, 255)
        end
        Wait(0)
    end
end

local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
    return coroutine.wrap(function()
        local iter, id = initFunc()
        if not id or id == 0 then
            disposeFunc(iter)
            return
        end
        repeat
            coroutine.yield(id)
            local next
            next, id = moveFunc(iter)
        until not next
        disposeFunc(iter)
    end)
end

function fpsmenu()
    lib.registerContext({
        id = 'fps_boost_menu',
        title = 'FPS Boost Menu',
        options = {
            { title = 'TimeCycles', description = 'Several Time Cycle', icon = 'audio-description', onSelect = function() menutimecycle() end},
            { title = 'Ultra Low Boost', description = 'Max FPS Boost', icon = 'rocket', onSelect = function() applyFPSBoost("ultra_low") lib.notify({ title = 'Ultra Low Boost', description = 'Boost FPS applicato.', type = 'success' }) end },
            { title = 'Medium Boost', description = 'Medium Boost', icon = 'tachometer-alt', onSelect = function() applyFPSBoost("medium") lib.notify({ title = 'Medium Boost', description = 'Boost FPS applicato.', type = 'success' }) end },
            { title = 'High Boost', description = 'Low Boost', icon = 'tachometer-alt', onSelect = function() applyFPSBoost("high") lib.notify({ title = 'High Boost', description = 'Boost FPS applicato.', type = 'success' }) end },
            { title = 'Graphics', description = 'Best Graphics', icon = 'star', onSelect = function() setUltraGraphics() lib.notify({ title = 'Graphics', description = 'Qualità grafica impostata al massimo.', type = 'success' }) end },
            { title = 'Reset', description = 'Reset', icon = 'undo', onSelect = function() resetSettings() lib.notify({ title = 'Reset', description = 'Impostazioni ripristinate.', type = 'success' }) end }
        }
    })
    lib.showContext('fps_boost_menu')
end

function menutimecycle()
    lib.registerContext({
        id = 'timecyclemenu',
        title = 'TimeCycles Menu',
        options = {
            {
                title = 'Tunnel',
                description = 'FPS BOOST',
                icon = 'star',
                onSelect = function()
                    ClearTimecycleModifier()
                    SetTimecycleModifier("yell_tunnel_nodirect")
                end,
            },
            {
                title = 'Cinema',
                description = 'FPS BOOST',
                icon = 'face-smile',
                onSelect = function()
                    ClearExtraTimecycleModifier()
                    ClearTimecycleModifier()
                    SetTimecycleModifier("cinema")
                end,
            },
            {
                title = 'Life',
                description = 'FPS BOOST',
                icon = 'web-awesome',
                onSelect = function()
                    ClearExtraTimecycleModifier()
                    ClearTimecycleModifier()
                    SetTimecycleModifier("LifeInvaderLOD")
                end,
            },
            {
                title = 'Reduce Distance',
                description = 'FPS BOOST',
                icon = 'circle',
                onSelect = function()
                    ClearExtraTimecycleModifier()
                    ClearTimecycleModifier()
                    SetTimecycleModifier("ReduceDrawDistanceMission")
                end,
            },
            {
                title = 'PowerPlay Blend',
                description = 'GRAPHIC',
                icon = 'circle',
                onSelect = function()
                    ClearExtraTimecycleModifier()
                    ClearTimecycleModifier()
                    SetTimecycleModifier("MP_Powerplay_blend")
                end,
            },
            {
                title = 'Tunnel',
                description = 'Improved light',
                icon = 'circle',
                onSelect = function()
                    ClearExtraTimecycleModifier()
                    ClearTimecycleModifier()
                    SetTimecycleModifier("tunnel")
                    SetExtraTimecycleModifier("reflection_correct_ambient")
                end,
            }
        }
    })

    lib.showContext('timecyclemenu')
end

RegisterCommand('fps', function()
    fpsmenu()
end)

RegisterNetEvent('fpsboost:openMenu')
AddEventHandler('fpsboost:openMenu', function()
    fpsmenu()
end)

/*Citizen.CreateThread(function()
    while true do
        if Config.clearpedandobj then
            if fpsBoostActive then
                local playerCoords = GetEntityCoords(PlayerPedId())
                for ped in EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed) do
                    local pedCoords = GetEntityCoords(ped)
                    local distance = #(playerCoords - pedCoords)
                    if distance > 100.0 then
                        SetEntityAlpha(ped, 0)
                        SetEntityAsNoLongerNeeded(ped)
                    elseif distance > 50.0 then
                        if not IsEntityOnScreen(ped) then
                            SetEntityAlpha(ped, 0)
                            SetEntityAsNoLongerNeeded(ped)
                        else
                            SetEntityAlpha(ped, 210)
                        end
                        SetPedAoBlobRendering(ped, false)
                    end
                    Citizen.Wait(1)
                end
                for obj in EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject) do
                    local objCoords = GetEntityCoords(obj)
                    local distance = #(playerCoords - objCoords)
                    if distance > 100.0 then
                        SetEntityAlpha(obj, 0)
                        SetEntityAsNoLongerNeeded(obj)
                        SetModelAsNoLongerNeeded(GetEntityModel(obj))
                    elseif distance > 50.0 then
                        if not IsEntityOnScreen(obj) then
                            SetEntityAlpha(obj, 0)
                            SetEntityAsNoLongerNeeded(obj)
                            SetModelAsNoLongerNeeded(GetEntityModel(obj))
                        else
                            SetEntityAlpha(obj, 170)
                        end
                    end
                    Citizen.Wait(1)
                end
                DisableOcclusionThisFrame()
                SetDisableDecalRenderingThisFrame()
                RemoveParticleFxInRange(playerCoords, 10.0)
                OverrideLodscaleThisFrame(0.1)
                SetStreamedTextureDictAsNoLongerNeeded("all")
                SetArtificialLightsState(true)
            end
        end
        Citizen.Wait(8)
    end
end)*/

Citizen.CreateThread(function()
    while true do
        if fpsBoostActive then
            local ped = PlayerPedId()
            ClearAllBrokenGlass()
            ClearAllHelpMessages()
            LeaderboardsReadClearAll()
            ClearBrief()
            ClearGpsFlags()
            ClearPrints()
            ClearSmallPrints()
            ClearReplayStats()
            LeaderboardsClearCacheData()
            ClearFocus()
            ClearHdArea()
            ClearPedBloodDamage(ped)
            ClearPedWetness(ped)
            ClearPedEnvDirt(ped)
            ResetPedVisibleDamage(ped)
            ClearOverrideWeather()
            DisableVehicleDistantlights(false)
            DisableScreenblurFade()
            SetRainLevel(0.0)
            SetWindSpeed(0.0)
            Citizen.Wait(300)
        else
            Citizen.Wait(1500)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        if fpsBoostnopedandobj then
            local ped = PlayerPedId()
            ClearAllBrokenGlass()
            ClearAllHelpMessages()
            LeaderboardsReadClearAll()
            ClearBrief()
            ClearGpsFlags()
            ClearPrints()
            ClearSmallPrints()
            ClearReplayStats()
            LeaderboardsClearCacheData()
            ClearFocus()
            ClearHdArea()
            ClearPedBloodDamage(ped)
            ClearPedWetness(ped)
            ClearPedEnvDirt(ped)
            ResetPedVisibleDamage(ped)
            ClearOverrideWeather()
            DisableVehicleDistantlights(false)
            DisableScreenblurFade()
            SetRainLevel(0.0)
            SetWindSpeed(0.0)
            Citizen.Wait(300)
        else
            Citizen.Wait(1500)
        end
    end
end)
