HatHairServerBridge = HatHairServerBridge or {}

local frameworkName = 'standalone'
local frameworkObject = nil
local tempStore = {}

local function DebugPrint(msg)
    if Config.Debug then
        print(('[HatHair:Bridge:Server] %s'):format(msg))
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

local function NormalizeHairData(hairData)
    return {
        drawable = hairData.drawable or 0,
        texture = hairData.texture or 0,
        palette = hairData.palette or 0
    }
end

local function GetPlayerObject(src)
    if frameworkName == 'qbcore' or frameworkName == 'qbox' then
        if not frameworkObject then return nil end
        return frameworkObject.Functions.GetPlayer(src)
    elseif frameworkName == 'esx' then
        if not frameworkObject then return nil end
        return frameworkObject.GetPlayerFromId(src)
    end

    return nil
end

function HatHairServerBridge.Init()
    DetectFramework()
end

function HatHairServerBridge.SaveOriginalHair(src, hairData)
    if type(hairData) ~= 'table' then return end
    hairData = NormalizeHairData(hairData)

    if frameworkName == 'qbcore' or frameworkName == 'qbox' then
        local Player = GetPlayerObject(src)
        if not Player then return end

        local metadata = Player.PlayerData.metadata or {}

        if not metadata.hathair_original then
            Player.Functions.SetMetaData('hathair_original', hairData)
        end

        return
    end

    if not tempStore[src] then
        tempStore[src] = hairData
    end
end

function HatHairServerBridge.LoadOriginalHair(src)
    if frameworkName == 'qbcore' or frameworkName == 'qbox' then
        local Player = GetPlayerObject(src)
        if not Player then return nil end

        local metadata = Player.PlayerData.metadata or {}
        return metadata.hathair_original
    end

    return tempStore[src]
end

function HatHairServerBridge.ClearOriginalHair(src)
    if frameworkName == 'qbcore' or frameworkName == 'qbox' then
        local Player = GetPlayerObject(src)
        if not Player then return end

        Player.Functions.SetMetaData('hathair_original', nil)
        return
    end

    tempStore[src] = nil
end

AddEventHandler('playerDropped', function()
    local src = source
    tempStore[src] = nil
end)

CreateThread(function()
    HatHairServerBridge.Init()
end)
