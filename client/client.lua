local ESX = exports['es_extended']:getSharedObject()
local ox_lib = exports.ox_lib

local function applyFPSBoost(level)
    if level == "ultra_low" then
        SetTimecycleModifier("yell_tunnel_nodirect") -- Rimuove effetti visivi complessi
        SetTimecycleModifierStrength(1.0)
        SetArtificialLightsState(true) -- Disabilita alcune luci dinamiche
        SetFlashLightKeepOnWhileMoving(false)
        SetReducePedModelBudget(true)
        SetReduceVehicleModelBudget(true)
        SetParticleFxNonLoopedAlpha(0.0) -- Disabilita effetti particellari
        SetWeatherTypePersist("CLEAR") -- Forza meteo chiaro per meno effetti
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
        fpsBoostActive = true
    elseif level == "medium" then
        SetTimecycleModifier("yell_tunnel_nodirect")
        SetTimecycleModifierStrength(0.5)
        SetArtificialLightsState(false)
        SetReducePedModelBudget(false)
        SetReduceVehicleModelBudget(false)
        SetParticleFxNonLoopedAlpha(0.5)
        fpsBoostActive = true
    elseif level == "high" then
        ClearTimecycleModifier()
        SetArtificialLightsState(false)
        SetParticleFxNonLoopedAlpha(1.0)
        fpsBoostActive = false
    end
end

local function setUltraGraphics()
    ClearTimecycleModifier()
    SetArtificialLightsState(false)
    SetParticleFxNonLoopedAlpha(1.0)
    fpsBoostActive = false
end

local function resetSettings()
    ClearTimecycleModifier()
    SetArtificialLightsState(false)
    SetParticleFxNonLoopedAlpha(1.0)
    SetLodScale(1.5)
    fpsBoostActive = false
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

lib.registerContext({
    id = 'fps_boost_menu',
    title = 'FPS Boost Menu',
    options = {
        {
            title = 'Ultra Low Boost',
            description = 'Massimo boost FPS (50-60+ FPS)',
            icon = 'rocket',
            onSelect = function()
                applyFPSBoost("ultra_low")
                lib.notify({ title = 'Ultra Low Boost', description = 'Boost FPS applicato.', type = 'success' })
            end
        },
        {
            title = 'Medium Boost',
            description = 'Boost moderato (30-40 FPS)',
            icon = 'tachometer-alt',
            onSelect = function()
                applyFPSBoost("medium")
                lib.notify({ title = 'Medium Boost', description = 'Boost FPS applicato.', type = 'success' })
            end
        },
        {
            title = 'High Boost',
            description = 'Boost minimo (10-20 FPS)',
            icon = 'tachometer-alt',
            onSelect = function()
                applyFPSBoost("high")
                lib.notify({ title = 'High Boost', description = 'Boost FPS applicato.', type = 'success' })
            end
        },
        {
            title = 'Graphics',
            description = 'Migliore qualità grafica possibile',
            icon = 'star',
            onSelect = function()
                setUltraGraphics()
                lib.notify({ title = 'Graphics', description = 'Qualità grafica impostata al massimo.', type = 'success' })
            end
        },
        {
            title = 'Reset',
            description = 'Resetta tutte le impostazioni',
            icon = 'undo',
            onSelect = function()
                resetSettings()
                lib.notify({ title = 'Reset', description = 'Impostazioni ripristinate.', type = 'success' })
            end
        }
    }
})

RegisterCommand('fps', function()
    lib.showContext('fps_boost_menu')
end, false)

RegisterNetEvent('fpsboost:openMenu')
AddEventHandler('fpsboost:openMenu', function()
    lib.showContext('fps_boost_menu')
end)

Citizen.CreateThread(function()
    while true do
        if fpsBoostActive then
            local playerCoords = GetEntityCoords(PlayerPedId())

            for ped in EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed) do
                local pedCoords = GetEntityCoords(ped)
                local distance = #(playerCoords - pedCoords)

                if distance > 100.0 then
                    SetEntityAlpha(obj, 255) -- Assicura che l'oggetto sia visibile
                    SetEntityRenderScorched(obj, true) -- Applica una texture bruciata/nera
                elseif distance > 50.0 then  -- Modifica questa distanza a tuo piacimento
                    if not IsEntityOnScreen(ped) then
                        SetEntityAlpha(ped, 0)
                        SetEntityAsNoLongerNeeded(ped)
                    else
                        if GetEntityAlpha(ped) == 0 then
                            SetEntityAlpha(ped, 255)
                        elseif GetEntityAlpha(ped) ~= 210 then
                            SetEntityAlpha(ped, 210)
                        end
                    end
                    SetPedAoBlobRendering(ped, false)
                end
                Citizen.Wait(1)
            end

            for obj in EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject) do
                local objCoords = GetEntityCoords(obj)
                local distance = #(playerCoords - objCoords)

                if distance > 100.0 then
                    SetEntityAlpha(obj, 255) -- Assicura che l'oggetto sia visibile
                    SetEntityRenderScorched(obj, true) -- Applica una texture bruciata/nera
                elseif distance > 50.0 then  -- Modifica questa distanza a tuo piacimento
                    if not IsEntityOnScreen(obj) then
                        SetEntityAlpha(obj, 0)
                        SetEntityAsNoLongerNeeded(obj)
                        SetModelAsNoLongerNeeded(GetEntityModel(obj))
                    else
                        if GetEntityAlpha(obj) == 0 then
                            SetEntityAlpha(obj, 255)
                        elseif GetEntityAlpha(obj) ~= 170 then
                            SetEntityAlpha(obj, 170)
                        end
                    end
                end
                Citizen.Wait(1)
            end

            DisableOcclusionThisFrame()
            SetDisableDecalRenderingThisFrame()
            RemoveParticleFxInRange(playerCoords, 10.0)
            OverrideLodscaleThisFrame(0.1) -- Riduce drasticamente il dettaglio degli oggetti lontani
            SetStreamedTextureDictAsNoLongerNeeded("all") -- Rilascia texture non necessarie
            SetArtificialLightsState(true)

            -- Disabilita texture avanzate e dettagli lontani
            SetReduceVehicleModelBudget(true)
            SetReducePedModelBudget(true)
            SetFlashLightFadeDistance(0.0) -- Evita effetti di luce su texture distanti
            SetLightsCutoffDistanceTweak(0.0) -- Evita illuminazione su oggetti lontani
        end
        Citizen.Wait(8)
    end
end)

Citizen.CreateThread(function()
    while true do
        if fpsBoostActive then
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
            ClearPedBloodDamage(PlayerPedId())
            ClearPedWetness(PlayerPedId())
            ClearPedEnvDirt(PlayerPedId())
            ResetPedVisibleDamage(PlayerPedId())
            ClearOverrideWeather()
            ClearHdArea()
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