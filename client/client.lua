local ox_lib = exports.ox_lib

-- Funzione per applicare il boost FPS
local function applyFPSBoost(level)
    if level == "low" then
        -- Impostazioni per il massimo boost (FPS molto alti)
        SetTimecycleModifier("yell_tunnel_nodirect") -- Rimuove effetti visivi complessi
        SetTimecycleModifierStrength(1.0)
        SetArtificialLightsState(true) -- Disabilita luci dinamiche
        SetFlashLightKeepOnWhileMoving(false) -- Disabilita effetti luce dinamici
        SetLightsCutoffDistanceTweak(1.0) -- Riduce la distanza delle luci
        SetPedAoBlobRendering(false) -- Disabilita effetti di ombreggiatura sui ped
        SetDisableDecalRendering(true) -- Disabilita decalcomanie (es. sangue, proiettili)
        SetReducePedModelBudget(true) -- Riduce il dettaglio dei ped
        SetReduceVehicleModelBudget(true) -- Riduce il dettaglio dei veicoli
        SetReduceWeaponModelBudget(true) -- Riduce il dettaglio delle armi

        -- Mantiene gli oggetti vicini visibili
        SetDistantCarsEnabled(false) -- Disabilita auto lontane
        SetDistantPedsEnabled(false) -- Disabilita ped lontani
        SetDistantDecalsEnabled(false) -- Disabilita decalcomanie lontane
        SetDistantLandscapeEnabled(false) -- Disabilita il rendering del paesaggio lontano
        SetDistantOceanEnabled(false) -- Disabilita il rendering dell'oceano lontano
        SetDistantCloudsEnabled(false) -- Disabilita il rendering delle nuvole lontane
        SetDistantFogEnabled(false) -- Disabilita la nebbia lontana
        SetDistantAmbientPedsEnabled(false) -- Disabilita i ped ambientali lontani
        SetDistantAmbientVehiclesEnabled(false) -- Disabilita i veicoli ambientali lontani
        SetDistantAmbientAnimalsEnabled(false) -- Disabilita gli animali lontani
        SetDistantAmbientObjectsEnabled(false) -- Disabilita gli oggetti lontani
        SetDistantAmbientPickupsEnabled(false) -- Disabilita i pickup lontani
        SetDistantAmbientProjectilesEnabled(false) -- Disabilita i proiettili lontani
        SetDistantAmbientEffectsEnabled(false) -- Disabilita gli effetti lontani
        SetDistantAmbientShadowsEnabled(false) -- Disabilita le ombre lontane
        SetDistantAmbientLightsEnabled(false) -- Disabilita le luci lontane
        SetDistantAmbientParticlesEnabled(false) -- Disabilita le particelle lontane
        SetDistantAmbientAudioEnabled(false) -- Disabilita l'audio lontano
        SetDistantAmbientClutterEnabled(false) -- Disabilita il disordine lontano
        SetDistantAmbientVegetationEnabled(false) -- Disabilita la vegetazione lontana
        SetDistantAmbientWaterEnabled(false) -- Disabilita l'acqua lontana
        SetDistantAmbientWeatherEnabled(false) -- Disabilita gli effetti meteorologici lontani
        SetDistantAmbientWindEnabled(false) -- Disabilita gli effetti del vento lontani
        SetDistantAmbientFireEnabled(false) -- Disabilita gli effetti del fuoco lontani
        SetDistantAmbientExplosionsEnabled(false) -- Disabilita gli effetti delle esplosioni lontane
        SetDistantAmbientSmokeEnabled(false) -- Disabilita gli effetti del fumo lontani
        SetDistantAmbientDustEnabled(false) -- Disabilita gli effetti della polvere lontani
        SetDistantAmbientMiscEnabled(false) -- Disabilita effetti vari lontani

        -- Imposta una distanza di rendering minima per gli oggetti vicini
        SetRenderDistance(50.0) -- Distanza di rendering per oggetti vicini
        SetLodScale(0.5) -- Riduce il livello di dettaglio per oggetti lontani
    elseif level == "medium" then
        -- Impostazioni per un boost moderato
        SetTimecycleModifier("yell_tunnel_nodirect")
        SetTimecycleModifierStrength(0.5)
        SetArtificialLightsState(false)
        SetDistantCarsEnabled(true)
        SetDistantPedsEnabled(true)
        SetDistantDecalsEnabled(true)
        SetDistantLandscapeEnabled(true)
        SetDistantOceanEnabled(true)
        SetDistantCloudsEnabled(true)
        SetDistantFogEnabled(true)

        -- Imposta una distanza di rendering media
        SetRenderDistance(100.0)
        SetLodScale(1.0)
    elseif level == "high" then
        -- Impostazioni per un boost minimo
        SetTimecycleModifier("")
        SetTimecycleModifierStrength(0.0)
        SetArtificialLightsState(false)
        SetDistantCarsEnabled(true)
        SetDistantPedsEnabled(true)
        SetDistantDecalsEnabled(true)
        SetDistantLandscapeEnabled(true)
        SetDistantOceanEnabled(true)
        SetDistantCloudsEnabled(true)
        SetDistantFogEnabled(true)

        -- Imposta una distanza di rendering massima
        SetRenderDistance(200.0)
        SetLodScale(2.0)
    end
end

-- Funzione per impostare la qualità grafica
local function setGraphicsQuality(quality)
    if quality == "ultra" then
        -- Migliore qualità grafica possibile
        SetGraphicsSetting("grassQuality", 3)
        SetGraphicsSetting("shadowQuality", 3)
        SetGraphicsSetting("textureQuality", 3)
        SetGraphicsSetting("waterQuality", 3)
        SetRenderDistance(300.0) -- Massima distanza di rendering
        SetLodScale(3.0) -- Massimo livello di dettaglio
    elseif quality == "high" then
        SetGraphicsSetting("grassQuality", 2)
        SetGraphicsSetting("shadowQuality", 2)
        SetGraphicsSetting("textureQuality", 2)
        SetGraphicsSetting("waterQuality", 2)
        SetRenderDistance(200.0)
        SetLodScale(2.0)
    elseif quality == "medium" then
        SetGraphicsSetting("grassQuality", 1)
        SetGraphicsSetting("shadowQuality", 1)
        SetGraphicsSetting("textureQuality", 1)
        SetGraphicsSetting("waterQuality", 1)
        SetRenderDistance(100.0)
        SetLodScale(1.0)
    elseif quality == "low" then
        SetGraphicsSetting("grassQuality", 0)
        SetGraphicsSetting("shadowQuality", 0)
        SetGraphicsSetting("textureQuality", 0)
        SetGraphicsSetting("waterQuality", 0)
        SetRenderDistance(50.0)
        SetLodScale(0.5)
    end
end

-- Funzione per resettare le impostazioni
local function resetSettings()
    SetTimecycleModifier("")
    SetTimecycleModifierStrength(0.0)
    SetArtificialLightsState(false)
    SetGraphicsSetting("grassQuality", 2)
    SetGraphicsSetting("shadowQuality", 2)
    SetGraphicsSetting("textureQuality", 2)
    SetGraphicsSetting("waterQuality", 2)
    SetDistantCarsEnabled(true)
    SetDistantPedsEnabled(true)
    SetDistantDecalsEnabled(true)
    SetDistantLandscapeEnabled(true)
    SetDistantOceanEnabled(true)
    SetDistantCloudsEnabled(true)
    SetDistantFogEnabled(true)
    SetRenderDistance(150.0) -- Distanza di rendering predefinita
    SetLodScale(1.5) -- Livello di dettaglio predefinito
end

-- Registrazione del menu principale
lib.registerContext({
    id = 'fps_boost_menu',
    title = 'FPS Boost Menu',
    options = {
        {
            title = 'FPS Boost',
            description = 'Aumenta i FPS',
            menu = 'fps_boost_submenu',
            icon = 'rocket',
            arrow = true
        },
        {
            title = 'Graphics',
            description = 'Imposta la qualità grafica',
            menu = 'graphics_submenu',
            icon = 'image',
            arrow = true
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

-- Registrazione del submenu per FPS Boost
lib.registerContext({
    id = 'fps_boost_submenu',
    title = 'FPS Boost Submenu',
    menu = 'fps_boost_menu',
    onBack = function()
        print('Tornato al menu principale.')
    end,
    options = {
        {
            title = 'Ultra Boost',
            description = 'Massimo boost FPS (50-60+ FPS)',
            icon = 'tachometer-alt',
            onSelect = function()
                applyFPSBoost("low")
                lib.notify({ title = 'Ultra Boost', description = 'Boost FPS applicato.', type = 'success' })
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
        }
    }
})

-- Registrazione del submenu per Graphics
lib.registerContext({
    id = 'graphics_submenu',
    title = 'Graphics Submenu',
    menu = 'fps_boost_menu',
    onBack = function()
        print('Tornato al menu principale.')
    end,
    options = {
        {
            title = 'Ultra',
            description = 'Migliore qualità grafica possibile',
            icon = 'star',
            onSelect = function()
                setGraphicsQuality("ultra")
                lib.notify({ title = 'Ultra', description = 'Qualità grafica impostata.', type = 'success' })
            end
        },
        {
            title = 'High',
            description = 'Qualità grafica alta',
            icon = 'star-half-alt',
            onSelect = function()
                setGraphicsQuality("high")
                lib.notify({ title = 'High', description = 'Qualità grafica impostata.', type = 'success' })
            end
        },
        {
            title = 'Medium',
            description = 'Qualità grafica media',
            icon = 'star-half-alt',
            onSelect = function()
                setGraphicsQuality("medium")
                lib.notify({ title = 'Medium', description = 'Qualità grafica impostata.', type = 'success' })
            end
        },
        {
            title = 'Low',
            description = 'Qualità grafica bassa',
            icon = 'star-half-alt',
            onSelect = function()
                setGraphicsQuality("low")
                lib.notify({ title = 'Low', description = 'Qualità grafica impostata.', type = 'success' })
            end
        }
    }
})

-- Comando per aprire il menu
RegisterCommand('fpsboost', function()
    lib.showContext('fps_boost_menu')
end, false)