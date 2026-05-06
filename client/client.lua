
local ox_lib = exports.ox_lib
local fpsBoostActive = false
local nuiOpen = false
local activeProfile = nil
local activeLocale = nil

local function getPlayerCoords()
    return GetEntityCoords(PlayerPedId())
end

local function getLocaleOverride()
    if Config and Config.Locale == 'auto' and Config.SaveProfileKvp then
        return GetResourceKvpString('fpsboost:locale_override')
    end
    return nil
end

local function resolveLocale()
    if not Config or not Config.Locale then
        return 'en'
    end

    if Config.Locale == 'it' or Config.Locale == 'en' then
        return Config.Locale
    end

    local override = getLocaleOverride()
    if override == 'it' or override == 'en' then
        return override
    end

    local cvar = GetConvar('locale', 'en')
    if type(cvar) == 'string' and string.sub(string.lower(cvar), 1, 2) == 'it' then
        return 'it'
    end

    return 'en'
end

local STRINGS = {
    it = {
        menu_title = 'Menu Boost FPS',
        menu_timecycles = 'Timecycle',
        menu_timecycles_desc = 'Preset Timecycle',
        menu_ultra_low = 'Ultra Low Boost',
        menu_ultra_low_desc = 'Massimo FPS',
        menu_medium = 'Medium Boost',
        menu_medium_desc = 'Bilanciato',
        menu_high = 'High Boost',
        menu_high_desc = 'Minimo impatto',
        menu_graphics = 'Ultra Graphics',
        menu_graphics_desc = 'Qualità massima',
        menu_reset = 'Reset',
        menu_reset_desc = 'Ripristina',
        notify_applied = 'Impostazioni applicate.',
        notify_reset = 'Impostazioni ripristinate.',
        entry_title = 'FPS Boost',
        entry_nui = 'Apri NUI',
        entry_nui_desc = 'Interfaccia premium',
        entry_menu = 'Apri Menu',
        entry_menu_desc = 'Compatibilità',
        tc_title = 'Timecycle',
        tc_tunnel = 'Tunnel (FPS)',
        tc_cinema = 'Cinema (FPS)',
        tc_life = 'Life (FPS)',
        tc_reduce = 'Reduce Distance (FPS)',
        tc_powerplay = 'PowerPlay Blend (Grafica)',
        tc_tunnel_reflection = 'Tunnel + Reflection'
    },
    en = {
        menu_title = 'FPS Boost Menu',
        menu_timecycles = 'Timecycle',
        menu_timecycles_desc = 'Timecycle presets',
        menu_ultra_low = 'Ultra Low Boost',
        menu_ultra_low_desc = 'Max FPS',
        menu_medium = 'Medium Boost',
        menu_medium_desc = 'Balanced',
        menu_high = 'High Boost',
        menu_high_desc = 'Low impact',
        menu_graphics = 'Ultra Graphics',
        menu_graphics_desc = 'Max quality',
        menu_reset = 'Reset',
        menu_reset_desc = 'Restore defaults',
        notify_applied = 'Settings applied.',
        notify_reset = 'Settings restored.',
        entry_title = 'FPS Boost',
        entry_nui = 'Open NUI',
        entry_nui_desc = 'Premium UI',
        entry_menu = 'Open Menu',
        entry_menu_desc = 'Compatibility',
        tc_title = 'Timecycle',
        tc_tunnel = 'Tunnel (FPS)',
        tc_cinema = 'Cinema (FPS)',
        tc_life = 'Life (FPS)',
        tc_reduce = 'Reduce Distance (FPS)',
        tc_powerplay = 'PowerPlay Blend (Graphics)',
        tc_tunnel_reflection = 'Tunnel + Reflection'
    }
}

local function tr(key)
    local lang = activeLocale or resolveLocale()
    local dict = STRINGS[lang] or STRINGS.en
    return dict[key] or key
end

local function getUiMode()
    if Config and (Config.UiMode == 'nui' or Config.UiMode == 'ox' or Config.UiMode == 'both') then
        return Config.UiMode
    end
    return 'ox'
end

local function setActiveProfile(profile)
    activeProfile = profile
    if Config and Config.SaveProfileKvp then
        local key = Config.ProfileKvpKey or 'fpsboost:profile'
        SetResourceKvp(key, profile or '')
    end
end

local function getSavedProfile()
    if not Config or not Config.SaveProfileKvp then
        return nil
    end
    local key = Config.ProfileKvpKey or 'fpsboost:profile'
    local v = GetResourceKvpString(key)
    if v == nil or v == '' then
        return nil
    end
    return v
end

local function getUiPayload()
    local locale = resolveLocale()
    activeLocale = locale
    return {
        resourceName = GetCurrentResourceName(),
        activeProfile = activeProfile,
        boostActive = fpsBoostActive,
        locale = locale,
        config = {
            uiMode = getUiMode(),
            commandName = (Config and Config.CommandName) or 'fps',
            saveProfileKvp = (Config and Config.SaveProfileKvp) and true or false
        }
    }
end

local function sendUiState()
    SendNUIMessage({ type = 'fpsboost:state', payload = getUiPayload() })
end

local function openNui()
    if nuiOpen then
        sendUiState()
        return
    end
    nuiOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ type = 'fpsboost:open', payload = getUiPayload() })
end

local function closeNui()
    if not nuiOpen then
        return
    end
    nuiOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ type = 'fpsboost:close' })
end

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

local cullingToken = 0

local function cancelCulling()
    cullingToken = cullingToken + 1
end

local function getCullingPreset(level)
    local culling = Config and Config.Culling
    if not (culling and culling.enabled) then
        return nil
    end

    local profile = Config and Config.CullingProfiles and Config.CullingProfiles[level]
    if type(profile) ~= 'table' then
        return nil
    end

    return {
        aggressive = culling.aggressive and true or false,
        objects = profile.objects or {},
        peds = profile.peds or {},
        vehicles = profile.vehicles or {}
    }
end

local function modifyWorldObjects(alpha, distance, aggressive)
    local playerCoords = getPlayerCoords()
    for obj in GetWorldObjects() do
        if not IsEntityOnScreen(obj) and #(playerCoords - GetEntityCoords(obj)) > distance then
            SetEntityAlpha(obj, 0, false)
            if aggressive and not IsEntityAMissionEntity(obj) then
                SetEntityAsNoLongerNeeded(obj)
            end
        else
            if GetEntityAlpha(obj) ~= alpha then
                SetEntityAlpha(obj, alpha, false)
            end
        end
        Wait(0)
    end
end

local function modifyWorldPeds(alpha, distance, aggressive, aoBlob)
    local playerPed = PlayerPedId()
    local playerCoords = getPlayerCoords()
    for obj in GetWorldPeds() do
        if obj ~= playerPed and not IsPedAPlayer(obj) then
            if not IsEntityOnScreen(obj) and #(playerCoords - GetEntityCoords(obj)) > distance then
                SetEntityAlpha(obj, 0, false)
                if aggressive and not IsEntityAMissionEntity(obj) then
                    SetEntityAsNoLongerNeeded(obj)
                end
            else
                if GetEntityAlpha(obj) ~= alpha then
                    SetEntityAlpha(obj, alpha, false)
                end
            end
            SetPedAoBlobRendering(obj, aoBlob and true or false)
        end
        Wait(0)
    end
end

local function modifyWorldVehicles(alpha, distance, aggressive)
    local playerPed = PlayerPedId()
    local myVeh = GetVehiclePedIsIn(playerPed, false)
    local playerCoords = getPlayerCoords()
    for obj in GetWorldVehicles() do
        if obj ~= myVeh then
            if not IsEntityOnScreen(obj) and #(playerCoords - GetEntityCoords(obj)) > distance then
                SetEntityAlpha(obj, 0, false)
                if aggressive and not IsEntityAMissionEntity(obj) then
                    SetEntityAsNoLongerNeeded(obj)
                end
            else
                if GetEntityAlpha(obj) ~= alpha then
                    SetEntityAlpha(obj, alpha, false)
                end
            end
        end
        Wait(0)
    end
end

local function startCullingPass(level)
    local preset = getCullingPreset(level)
    if preset == nil then
        return
    end

    local batch = Config and Config.CullingBatch
    if not (batch and batch.enabled) then
        modifyWorldObjects(preset.objects.alpha or 255, preset.objects.distance or 120, preset.aggressive)
        modifyWorldPeds(preset.peds.alpha or 255, preset.peds.distance or 120, preset.aggressive, preset.peds.aoBlob)
        modifyWorldVehicles(preset.vehicles.alpha or 255, preset.vehicles.distance or 120, preset.aggressive)
        return
    end

    cancelCulling()
    local token = cullingToken
    local maxPerTick = tonumber(batch.maxPerTick) or 120
    if maxPerTick < 1 then
        maxPerTick = 1
    end
    local tickWaitMs = tonumber(batch.tickWaitMs) or 0
    if tickWaitMs < 0 then
        tickWaitMs = 0
    end

    Citizen.CreateThread(function()
        local function processEntities(iterFn, handler)
            local n = 0
            local playerPed = PlayerPedId()
            local myVeh = GetVehiclePedIsIn(playerPed, false)
            local playerCoords = getPlayerCoords()

            for ent in iterFn() do
                if cullingToken ~= token then
                    return false
                end

                if n == 0 then
                    playerPed = PlayerPedId()
                    myVeh = GetVehiclePedIsIn(playerPed, false)
                    playerCoords = getPlayerCoords()
                end

                handler(ent, playerCoords, playerPed, myVeh)

                n = n + 1
                if n >= maxPerTick then
                    n = 0
                    if tickWaitMs > 0 then
                        Citizen.Wait(tickWaitMs)
                    else
                        Citizen.Wait(0)
                    end
                end
            end

            return true
        end

        local objAlpha = preset.objects.alpha or 255
        local objDist = preset.objects.distance or 120
        local pedAlpha = preset.peds.alpha or 255
        local pedDist = preset.peds.distance or 120
        local pedAoBlob = preset.peds.aoBlob and true or false
        local vehAlpha = preset.vehicles.alpha or 255
        local vehDist = preset.vehicles.distance or 120

        local function handleEntity(ent, playerCoords, alpha, dist, aggressive)
            if not IsEntityOnScreen(ent) and #(playerCoords - GetEntityCoords(ent)) > dist then
                SetEntityAlpha(ent, 0, false)
                if aggressive and not IsEntityAMissionEntity(ent) then
                    SetEntityAsNoLongerNeeded(ent)
                end
            else
                if GetEntityAlpha(ent) ~= alpha then
                    SetEntityAlpha(ent, alpha, false)
                end
            end
        end

        processEntities(GetWorldObjects, function(ent, playerCoords)
            handleEntity(ent, playerCoords, objAlpha, objDist, preset.aggressive)
        end)

        processEntities(GetWorldPeds, function(ent, playerCoords, playerPed)
            if ent == playerPed or IsPedAPlayer(ent) then
                return
            end
            handleEntity(ent, playerCoords, pedAlpha, pedDist, preset.aggressive)
            SetPedAoBlobRendering(ent, pedAoBlob)
        end)

        processEntities(GetWorldVehicles, function(ent, playerCoords, _, myVeh)
            if ent == myVeh then
                return
            end
            handleEntity(ent, playerCoords, vehAlpha, vehDist, preset.aggressive)
        end)
    end)
end

local function applyFPSBoost(level)
    if level == "ultra_low" then
        SetTimecycleModifier("ReduceDrawDistanceMission")
        startCullingPass('ultra_low')
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
        RemoveParticleFxInRange(getPlayerCoords(), 10.0)
        OverrideLodscaleThisFrame(0.4)
        fpsBoostActive = true
    elseif level == "medium" then
        SetTimecycleModifier("yell_tunnel_nodirect")
        startCullingPass('medium')
        SetTimecycleModifierStrength(0.5)
        SetArtificialLightsState(false)
        SetReducePedModelBudget(false)
        SetReduceVehicleModelBudget(false)
        SetParticleFxNonLoopedAlpha(0.5)
        OverrideLodscaleThisFrame(0.6)
        fpsBoostActive = true
    elseif level == "high" then
        ClearTimecycleModifier()
        startCullingPass('high')
        SetArtificialLightsState(false)
        SetParticleFxNonLoopedAlpha(1.0)
        OverrideLodscaleThisFrame(0.8)
        fpsBoostActive = false
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
end


local function resetSettings()
    cancelCulling()
    OverrideLodscaleThisFrame(1.0)
    DisableVehicleDistantlights(false)
    ClearTimecycleModifier()
    ClearExtraTimecycleModifier()
    SetArtificialLightsState(false)
    SetParticleFxNonLoopedAlpha(1.0)
    fpsBoostActive = false
    for obj in GetWorldObjects() do
        if GetEntityAlpha(obj) ~= 255 then
            SetEntityAlpha(obj, 255, false)
        end
        Wait(0)
    end
    for obj in GetWorldPeds() do
        if GetEntityAlpha(obj) ~= 255 then
            SetEntityAlpha(obj, 255, false)
        end
        SetPedAoBlobRendering(obj, true)
        Wait(0)
    end
    for obj in GetWorldVehicles() do
        if GetEntityAlpha(obj) ~= 255 then
            SetEntityAlpha(obj, 255, false)
        end
        Wait(0)
    end
end

function fpsmenu()
    lib.registerContext({
        id = 'fps_boost_menu',
        title = tr('menu_title'),
        options = {
            { title = tr('menu_timecycles'), description = tr('menu_timecycles_desc'), icon = 'audio-description', onSelect = function() menutimecycle() end},
            { title = tr('menu_ultra_low'), description = tr('menu_ultra_low_desc'), icon = 'rocket', onSelect = function() applyFPSBoost("ultra_low") setActiveProfile('ultra_low') sendUiState() lib.notify({ title = tr('menu_ultra_low'), description = tr('notify_applied'), type = 'success' }) end },
            { title = tr('menu_medium'), description = tr('menu_medium_desc'), icon = 'tachometer-alt', onSelect = function() applyFPSBoost("medium") setActiveProfile('medium') sendUiState() lib.notify({ title = tr('menu_medium'), description = tr('notify_applied'), type = 'success' }) end },
            { title = tr('menu_high'), description = tr('menu_high_desc'), icon = 'tachometer-alt', onSelect = function() applyFPSBoost("high") setActiveProfile('high') sendUiState() lib.notify({ title = tr('menu_high'), description = tr('notify_applied'), type = 'success' }) end },
            { title = tr('menu_graphics'), description = tr('menu_graphics_desc'), icon = 'star', onSelect = function() setUltraGraphics() setActiveProfile('ultra_graphics') sendUiState() lib.notify({ title = tr('menu_graphics'), description = tr('notify_applied'), type = 'success' }) end },
            { title = tr('menu_reset'), description = tr('menu_reset_desc'), icon = 'undo', onSelect = function() resetSettings() setActiveProfile('reset') sendUiState() lib.notify({ title = tr('menu_reset'), description = tr('notify_reset'), type = 'success' }) end }
        }
    })
    lib.showContext('fps_boost_menu')
end

function menutimecycle()
    lib.registerContext({
        id = 'timecyclemenu',
        title = tr('tc_title'),
        options = {
            {
                title = tr('tc_tunnel'),
                description = 'FPS BOOST',
                icon = 'star',
                onSelect = function()
                    ClearTimecycleModifier()
                    SetTimecycleModifier("yell_tunnel_nodirect")
                end,
            },
            {
                title = tr('tc_cinema'),
                description = 'FPS BOOST',
                icon = 'face-smile',
                onSelect = function()
                    ClearExtraTimecycleModifier()
                    ClearTimecycleModifier()
                    SetTimecycleModifier("cinema")
                end,
            },
            {
                title = tr('tc_life'),
                description = 'FPS BOOST',
                icon = 'web-awesome',
                onSelect = function()
                    ClearExtraTimecycleModifier()
                    ClearTimecycleModifier()
                    SetTimecycleModifier("LifeInvaderLOD")
                end,
            },
            {
                title = tr('tc_reduce'),
                description = 'FPS BOOST',
                icon = 'circle',
                onSelect = function()
                    ClearExtraTimecycleModifier()
                    ClearTimecycleModifier()
                    SetTimecycleModifier("ReduceDrawDistanceMission")
                end,
            },
            {
                title = tr('tc_powerplay'),
                description = 'GRAPHIC',
                icon = 'circle',
                onSelect = function()
                    ClearExtraTimecycleModifier()
                    ClearTimecycleModifier()
                    SetTimecycleModifier("MP_Powerplay_blend")
                end,
            },
            {
                title = tr('tc_tunnel_reflection'),
                description = 'GRAPHIC',
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

local function openMenu()
    local mode = getUiMode()
    if mode == 'nui' then
        openNui()
        return
    end

    if mode == 'ox' then
        fpsmenu()
        return
    end

    lib.registerContext({
        id = 'fps_boost_entry',
        title = tr('entry_title'),
        options = {
            { title = tr('entry_nui'), description = tr('entry_nui_desc'), icon = 'star', onSelect = function() openNui() end },
            { title = tr('entry_menu'), description = tr('entry_menu_desc'), icon = 'bars', onSelect = function() fpsmenu() end }
        }
    })
    lib.showContext('fps_boost_entry')
end

RegisterCommand((Config and Config.CommandName) or 'fps', function()
    openMenu()
end)

RegisterNetEvent('fpsboost:openMenu')
AddEventHandler('fpsboost:openMenu', function()
    openMenu()
end)

if Config and Config.EnableKeybind then
    RegisterCommand('fpsboost:open', function()
        openMenu()
    end)
    RegisterKeyMapping('fpsboost:open', 'FPS Boost Menu', 'keyboard', Config.Keybind or 'F7')
end

RegisterNUICallback('close', function(_, cb)
    closeNui()
    cb({})
end)

RegisterNUICallback('applyProfile', function(data, cb)
    local profile = data and data.profile
    if profile == 'ultra_low' or profile == 'medium' or profile == 'high' then
        applyFPSBoost(profile)
        setActiveProfile(profile)
        sendUiState()
        cb({ ok = true })
        return
    end

    if profile == 'ultra_graphics' then
        setUltraGraphics()
        setActiveProfile(profile)
        sendUiState()
        cb({ ok = true })
        return
    end

    cb({ ok = false })
end)

RegisterNUICallback('resetAll', function(_, cb)
    resetSettings()
    setActiveProfile('reset')
    sendUiState()
    cb({ ok = true })
end)

RegisterNUICallback('applyTimecycle', function(data, cb)
    if type(data) ~= 'table' or type(data.name) ~= 'string' then
        cb({ ok = false })
        return
    end

    ClearExtraTimecycleModifier()
    ClearTimecycleModifier()
    SetTimecycleModifier(data.name)

    if type(data.strength) == 'number' then
        SetTimecycleModifierStrength(data.strength)
    end

    if type(data.extra) == 'table' and type(data.extra.extra) == 'string' then
        SetExtraTimecycleModifier(data.extra.extra)
    end

    cb({ ok = true })
end)

RegisterNUICallback('resetTimecycle', function(_, cb)
    ClearExtraTimecycleModifier()
    ClearTimecycleModifier()
    cb({ ok = true })
end)

RegisterNUICallback('setLocale', function(data, cb)
    if Config and Config.Locale == 'auto' and Config.SaveProfileKvp and type(data) == 'table' then
        if data.locale == 'it' or data.locale == 'en' then
            SetResourceKvp('fpsboost:locale_override', data.locale)
        end
    end
    sendUiState()
    cb({ ok = true })
end)

AddEventHandler('onClientResourceStart', function(resName)
    if resName ~= GetCurrentResourceName() then
        return
    end

    activeLocale = resolveLocale()
    local saved = getSavedProfile()
    if saved == nil then
        return
    end

    Citizen.CreateThread(function()
        Citizen.Wait(1200)
        if saved == 'ultra_low' or saved == 'medium' or saved == 'high' then
            applyFPSBoost(saved)
            setActiveProfile(saved)
            return
        end
        if saved == 'ultra_graphics' then
            setUltraGraphics()
            setActiveProfile(saved)
        end
    end)
end)

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
