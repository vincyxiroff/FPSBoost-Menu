-- // FPS Booster for FiveM

ESX = exports["es_extended"]:getSharedObject()

TriggerEvent('chat:addSuggestion', '/fps', 'Open fps boost menu')

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

-- Menu
RegisterNetEvent('Hel1best:fpsmenu') 
AddEventHandler('Hel1best:fpsmenu', function()
  lib.showContext('hel1bestfpsmenu')
end)

-- FPS Boost #1
RegisterNetEvent('Hel1best:fps1') 
AddEventHandler('Hel1best:fps1', function()
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
  SetTimecycleModifier('yell_tunnel_nodirect')
  lib.notify({title = '',description = 'FPS Boost',type = 'success'})
  
  fpsBoostActive = true
end)

-- Lights Mode
RegisterNetEvent('Hel1best:fps2') 
AddEventHandler('Hel1best:fps2', function()
  SetTimecycleModifier('tunnel')
  lib.notify({title = '',description = 'Lights Mode',type = 'success'})
end)

-- Graphics (Migliorata)
RegisterNetEvent('Hel1best:fps3') 
AddEventHandler('Hel1best:fps3', function()
  SetTimecycleModifier('MP_Powerplay_blend')
  SetExtraTimecycleModifier('reflection_correct_ambient')
  SetArtificialLightsState(true)
  CascadeShadowsSetAircraftMode(true)
  CascadeShadowsEnableEntityTracker(true)
  CascadeShadowsSetDynamicDepthMode(true)
  CascadeShadowsSetEntityTrackerScale(5.0)
  CascadeShadowsSetDynamicDepthValue(5.0)
  CascadeShadowsSetCascadeBoundsScale(5.0)
  SetFlashLightFadeDistance(10.0)
  SetLightsCutoffDistanceTweak(10.0)
  DistantCopCarSirens(true)
  OverrideLodscaleThisFrame(1.0)
  lib.notify({title = '',description = 'Graphics migliorate attivate',type = 'success'})
end)

-- Simple/Reset
RegisterNetEvent('Hel1best:fps4') 
AddEventHandler('Hel1best:fps4', function()
  SetTimecycleModifier()
  ClearTimecycleModifier()
  ClearExtraTimecycleModifier()
  RopeDrawShadowEnabled(true)
  CascadeShadowsSetAircraftMode(true)
  CascadeShadowsEnableEntityTracker(true)
  CascadeShadowsSetDynamicDepthMode(true)
  CascadeShadowsSetEntityTrackerScale(5.0)
  CascadeShadowsSetDynamicDepthValue(5.0)
  CascadeShadowsSetCascadeBoundsScale(5.0)
  SetFlashLightFadeDistance(10.0)
  SetLightsCutoffDistanceTweak(10.0)
  DistantCopCarSirens(true)
  OverrideLodscaleThisFrame(1.0)
  lib.notify({title = '',description = 'Resettato alle impostazioni predefinite',type = 'success'})
  
  fpsBoostActive = false
end)

lib.registerContext({
  id = 'hel1bestfpsmenu',
  title =  'FPS Menu',
  onExit = function()
  end,
  options = {
      {
          title = 'FPS Boost',
          description = 'Aiuta a migliorare le prestazioni FPS',
          icon = 'fas fa-keyboard',
          event = 'Hel1best:fps1',
      },
      {
        title = 'Lights Mode',
        description = 'Mantiene una buona grafica e migliora le prestazioni',
        icon = 'far fa-lightbulb',
        event = 'Hel1best:fps2',
    },
    {
      title = 'Graphics',
      description = 'Attiva la migliore qualità grafica',
      icon = 'far fa-newspaper',
      event = 'Hel1best:fps3',
  },
      {
          title = 'Reset',
          description = 'Ripristina le impostazioni predefinite',
          icon = 'fa fa-remove',
          event = 'Hel1best:fps4',
      },
  },
})

-- // Distance rendering and entity handler
Citizen.CreateThread(function()
    while true do
        if fpsBoostActive then
            local playerCoords = GetEntityCoords(PlayerPedId())

            for ped in EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed) do
                local pedCoords = GetEntityCoords(ped)
                local distance = #(playerCoords - pedCoords)

                if distance > 50.0 then  -- Modifica questa distanza a tuo piacimento
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

                if distance > 50.0 then  -- Modifica questa distanza a tuo piacimento
                    if not IsEntityOnScreen(obj) then
                        SetEntityAlpha(obj, 0)
                        SetEntityAsNoLongerNeeded(obj)
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
            OverrideLodscaleThisFrame(0.4)
            SetArtificialLightsState(true)
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
            ClearExtraTimecycleModifier()
            ClearTimecycleModifier()
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
