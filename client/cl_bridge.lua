HatHairBridge = HatHairBridge or {}

local frameworkName = 'standalone'
local frameworkObject = nil
local hasTriggeredLoad = false

local function DebugPrint(msg)
    if Config.Debug then
        print(('[HatHair:Bridge:Client] %s'):format(msg))
    end
end

local function DetectFramework()
    if Config.Framework and Config.Framework ~= 'auto' then
        frameworkName = Config.Framework

        if frameworkName == 'qbcore' or frameworkName == 'qbox' then
            if GetResourceState('qb-core') == 'started' then
                frameworkObject = exports['qb-core']:GetCoreObject()
            end
        elseif frameworkName == 'esx' then
            if GetResourceState('es_extended') == 'started' then
                frameworkObject = exports['es_extended']:getSharedObject()
            end
        end

        DebugPrint(('Framework forced to %s'):format(frameworkName))
        return
    end

    if GetResourceState('qbx_core') == 'started' then
        frameworkName = 'qbox'
        if GetResourceState('qb-core') == 'started' then
            frameworkObject = exports['qb-core']:GetCoreObject()
        end
    elseif GetResourceState('qb-core') == 'started' then
        frameworkName = 'qbcore'
        frameworkObject = exports['qb-core']:GetCoreObject()
    elseif GetResourceState('es_extended') == 'started' then
        frameworkName = 'esx'
        frameworkObject = exports['es_extended']:getSharedObject()
    else
        frameworkName = 'standalone'
    end

    DebugPrint(('Detected framework: %s'):format(frameworkName))
end

local function TriggerLoadedOnce(reason)
    if hasTriggeredLoad then
        DebugPrint(('Skipping duplicate playerLoaded trigger (%s)'):format(reason))
        return
    end

    hasTriggeredLoad = true
    DebugPrint(('Triggering playerLoaded (%s)'):format(reason))
    TriggerEvent('v42-hathair:client:playerLoaded')
end

local function TriggerUnloaded(reason)
    hasTriggeredLoad = false
    DebugPrint(('Triggering playerUnloaded (%s)'):format(reason))
    TriggerEvent('v42-hathair:client:playerUnloaded')
end

function HatHairBridge.GetFramework()
    return frameworkName, frameworkObject
end

function HatHairBridge.IsPersistenceEnabled()
    return Config.UsePersistence and frameworkName ~= 'standalone'
end

function HatHairBridge.RequestSavedHair()
    if not HatHairBridge.IsPersistenceEnabled() then
        TriggerEvent('v42-hathair:client:noSavedHair')
        return
    end

    TriggerServerEvent('v42-hathair:server:requestOriginalHair')
end

function HatHairBridge.SaveOriginalHair(hairData)
    if not HatHairBridge.IsPersistenceEnabled() then return end
    TriggerServerEvent('v42-hathair:server:saveOriginalHair', hairData)
end

function HatHairBridge.ClearSavedHair()
    if not HatHairBridge.IsPersistenceEnabled() then return end
    TriggerServerEvent('v42-hathair:server:clearOriginalHair')
end

function HatHairBridge.Init()
    DetectFramework()
end

CreateThread(function()
    HatHairBridge.Init()

    while not hasTriggeredLoad do
        Wait(1000)

        if frameworkName == 'standalone' then
            local ped = PlayerPedId()
            if ped and ped ~= 0 and DoesEntityExist(ped) then
                TriggerLoadedOnce('standalone fallback loop')
            end
        else
            if LocalPlayer and LocalPlayer.state and LocalPlayer.state.isLoggedIn then
                TriggerLoadedOnce('LocalPlayer.state.isLoggedIn fallback loop')
            end
        end
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    if frameworkName == 'qbcore' or frameworkName == 'qbox' then
        TriggerLoadedOnce('QBCore:Client:OnPlayerLoaded')
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    if frameworkName == 'qbcore' or frameworkName == 'qbox' then
        TriggerUnloaded('QBCore:Client:OnPlayerUnload')
    end
end)

RegisterNetEvent('qbx_core:client:playerLoggedOut', function()
    if frameworkName == 'qbox' then
        TriggerUnloaded('qbx_core:client:playerLoggedOut')
    end
end)

RegisterNetEvent('esx:playerLoaded', function()
    if frameworkName == 'esx' then
        TriggerLoadedOnce('esx:playerLoaded')
    end
end)

RegisterNetEvent('esx:onPlayerLogout', function()
    if frameworkName == 'esx' then
        TriggerUnloaded('esx:onPlayerLogout')
    end
end)

AddEventHandler('playerSpawned', function()
    if frameworkName == 'standalone' then
        TriggerLoadedOnce('playerSpawned')
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    hasTriggeredLoad = false
    HatHairBridge.Init()

    CreateThread(function()
        Wait(2000)

        if frameworkName == 'standalone' then
            local ped = PlayerPedId()
            if ped and ped ~= 0 and DoesEntityExist(ped) then
                TriggerLoadedOnce('onResourceStart standalone fallback')
            end
            return
        end

        if LocalPlayer and LocalPlayer.state and LocalPlayer.state.isLoggedIn then
            TriggerLoadedOnce('onResourceStart LocalPlayer.state.isLoggedIn')
        end
    end)
end)
