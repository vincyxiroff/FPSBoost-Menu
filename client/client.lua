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
        SetReduceWeaponModelBudget(true)
        SetParticleFxNonLoopedAlpha(0.0) -- Disabilita effetti particellari
        SetLodScale(0.7) -- Mantiene oggetti vicini visibili riducendo il dettaglio degli oggetti lontani
        SetRenderDistance(100.0) -- Limita la distanza di rendering per mantenere stabilità
        SetShadowQuality(0) -- Disabilita le ombre per massimizzare gli FPS
        SetWeatherTypePersist("CLEAR") -- Forza meteo chiaro per meno effetti
    elseif level == "medium" then
        SetTimecycleModifier("yell_tunnel_nodirect")
        SetTimecycleModifierStrength(0.5)
        SetArtificialLightsState(false)
        SetReducePedModelBudget(false)
        SetReduceVehicleModelBudget(false)
        SetReduceWeaponModelBudget(false)
        SetParticleFxNonLoopedAlpha(0.5)
        SetLodScale(1.0)
        SetRenderDistance(150.0)
    elseif level == "high" then
        ClearTimecycleModifier()
        SetArtificialLightsState(false)
        SetParticleFxNonLoopedAlpha(1.0)
        SetLodScale(2.0)
        SetRenderDistance(300.0)
    end
end

local function setUltraGraphics()
    ClearTimecycleModifier()
    SetArtificialLightsState(false)
    SetParticleFxNonLoopedAlpha(1.0)
    SetLodScale(3.0)
    SetRenderDistance(500.0)
    SetShadowQuality(3) -- Massima qualità delle ombre
    SetTextureQuality(3) -- Migliore qualità delle texture
    SetWaterQuality(3) -- Migliore qualità dell'acqua
end

local function resetSettings()
    ClearTimecycleModifier()
    SetArtificialLightsState(false)
    SetParticleFxNonLoopedAlpha(1.0)
    SetLodScale(1.5)
    SetRenderDistance(200.0)
    SetShadowQuality(2) -- Qualità predefinita delle ombre
    SetTextureQuality(2) -- Qualità predefinita delle texture
    SetWaterQuality(2) -- Qualità predefinita dell'acqua
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

RegisterCommand('fpsboost', function()
    lib.showContext('fps_boost_menu')
end, false)

RegisterNetEvent('fpsboost:openMenu')
AddEventHandler('fpsboost:openMenu', function()
    lib.showContext('fps_boost_menu')
end)