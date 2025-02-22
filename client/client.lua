-- // FPS Booster for FiveM

ESX = exports["es_extended"]:getSharedObject()

TriggerEvent('chat:addSuggestion', '/fps', 'Open fps boost menu')

--Menu
RegisterNetEvent('Hel1best:fpsmenu') 
AddEventHandler('Hel1best:fpsmenu', function()
  lib.showContext('hel1bestfpsmenu')
end)

--FPS Boost #1
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
  
  -- Attiva la gestione di entità e rendering solo quando FPS Boost è attivo
  fpsBoostActive = true
end)

--Lights Mode
RegisterNetEvent('Hel1best:fps2') 
AddEventHandler('Hel1best:fps2', function()
  SetTimecycleModifier('tunnel')
  lib.notify({title = '',description = 'Lights Mode',type = 'success'})
end)

--Graphics
RegisterNetEvent('Hel1best:fps3') 
AddEventHandler('Hel1best:fps3', function()
  SetTimecycleModifier('MP_Powerplay_blend')
  SetExtraTimecycleModifier('reflection_correct_ambient')
  lib.notify({title = '',description = 'Graphics',type = 'success'})
end)

--Simple/Reset
RegisterNetEvent('Hel1best:fps4') 
AddEventHandler('Hel1best:fps4', function()
  SetTimecycleModifier()
  ClearTimecycleModifier()
  ClearExtraTimecycleModifier()
  lib.notify({title = '',description = 'Reseted to default',type = 'success'})
  
  -- Disattiva la gestione di entità e rendering quando FPS Boost viene disattivato
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
          description = 'Helps best with boosting fps',
          icon = 'fas fa-keyboard',
          event = 'Hel1best:fps1',
      },
      {
        title = 'Lights Mode',
        description = 'Still looks good and boost your fps',
        icon = 'far fa-lightbulb',
        event = 'Hel1best:fps2',
    },
    {
      title = 'Graphics',
      description = 'Looks decent and boost fps',
      icon = 'far fa-newspaper',
      event = 'Hel1best:fps3',
  },
      {
          title = 'Reset',
          description = '',
          icon = 'fa fa-remove',
          event = 'Hel1best:fps4',
      },
  },
})

function GetWorldPeds()
    return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end

-- // Distance rendering and entity handler
Citizen.CreateThread(function()
    while true do
        if fpsBoostActive then
            for ped in GetWorldPeds() do
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
                Citizen.Wait(1)
            end

            for obj in GetWorldObjects() do
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
                Citizen.Wait(1)
            end

            DisableOcclusionThisFrame()
            SetDisableDecalRenderingThisFrame()
            RemoveParticleFxInRange(GetEntityCoords(PlayerPedId()), 10.0)
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

-- // Entity Enumerator
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
    return coroutine.wrap(function()
        local iter, id = initFunc()
        if not id or id == 0 then
            disposeFunc(iter)
            return
        end
        local enum = {handle = iter, destructor = disposeFunc}
        setmetatable(enum, entityEnumerator)
        repeat
            coroutine.yield(id)
            next, id = moveFunc(iter)
        until not next
        enum.destructor, enum.handle = nil, nil
        disposeFunc(iter)
    end)
end

function GetWorldObjects()
    return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
end
