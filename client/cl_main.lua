local originalHair = nil
local hairOverrideActive = false
local lastHatDrawable = -999
local lastHatTexture = -999
local playerLoaded = false
local HandleHatHair

local function DebugPrint(msg)
    if Config.Debug then
        print(('[HatHair] %s'):format(msg))
    end
end

local function GetGenderKey(ped)
    return IsPedMale(ped) and 'male' or 'female'
end

local function GetCurrentHairData(ped)
    return {
        drawable = GetPedDrawableVariation(ped, 2),
        texture = GetPedTextureVariation(ped, 2),
        palette = GetPedPaletteVariation(ped, 2)
    }
end

local function ApplyHair(ped, hairData)
    if not hairData then return end

    SetPedComponentVariation(
        ped,
        2,
        hairData.drawable or 0,
        hairData.texture or 0,
        hairData.palette or 0
    )
end

local function SaveOriginalHairIfNeeded(ped)
    if originalHair then return end

    originalHair = GetCurrentHairData(ped)
    HatHairBridge.SaveOriginalHair(originalHair)

    DebugPrint(('Saved original hair: drawable=%s texture=%s palette=%s'):format(
        originalHair.drawable,
        originalHair.texture,
        originalHair.palette
    ))
end

local function RestoreOriginalHair(ped)
    if not originalHair then return end

    ApplyHair(ped, originalHair)
    hairOverrideActive = false

    DebugPrint('Restored original hair')
end

local function GetConfiguredHairForHat(ped, hatDrawable, hatTexture)
    local genderKey = GetGenderKey(ped)
    local genderConfig = Config.HatHair[genderKey]

    if not genderConfig then return nil end

    local hatConfig = genderConfig[hatDrawable]
    if not hatConfig then return nil end

    if hatConfig.textures and hatConfig.textures[hatTexture] then
        return hatConfig.textures[hatTexture]
    end

    return hatConfig.default
end

local function RunPostLoadHatChecks()
    CreateThread(function()
        for i = 1, 10 do
            if not playerLoaded then return end

            lastHatDrawable = -999
            lastHatTexture = -999

            DebugPrint(('Post-load hat check #%s'):format(i))
            HandleHatHair(true)

            Wait(1000)
        end
    end)
end

local function ApplyDamagePropProtection(ped)
    if not DoesEntityExist(ped) then return end

    -- false = do not lose props on damage
    if Config.KeepHatOnHit then
        SetPedCanLosePropsOnDamage(ped, false, 0)
    else
        SetPedCanLosePropsOnDamage(ped, true, 0)
    end
end

HandleHatHair = function(force)
    DebugPrint(('HandleHatHair called: force=%s playerLoaded=%s'):format(tostring(force), tostring(playerLoaded)))

    if not playerLoaded then return end

    local ped = PlayerPedId()
    if not DoesEntityExist(ped) or IsEntityDead(ped) then return end

    local hatDrawable = GetPedPropIndex(ped, 0)
    local hatTexture = GetPedPropTextureIndex(ped, 0)

    if not force and hatDrawable == lastHatDrawable and hatTexture == lastHatTexture then
        return
    end

    lastHatDrawable = hatDrawable
    lastHatTexture = hatTexture

    local mappedHair = nil
    if hatDrawable ~= -1 then
        mappedHair = GetConfiguredHairForHat(ped, hatDrawable, hatTexture)
    end

    DebugPrint(('Hat change detected: drawable=%s texture=%s mappedHair=%s override=%s original=%s'):format(
        hatDrawable,
        hatTexture,
        tostring(mappedHair),
        tostring(hairOverrideActive),
        originalHair and tostring(originalHair.drawable) or 'nil'
    ))

    if not mappedHair then
        if hairOverrideActive and Config.RestoreWhenNoMatch then
            RestoreOriginalHair(ped)
        end
        return
    end

    SaveOriginalHairIfNeeded(ped)

    local newHair = {
        drawable = mappedHair,
        texture = originalHair and originalHair.texture or 0,
        palette = originalHair and originalHair.palette or 0
    }

    ApplyHair(ped, newHair)
    hairOverrideActive = true

    DebugPrint(('Applied configured hair %s for hat %s texture %s'):format(
        mappedHair,
        hatDrawable,
        hatTexture
    ))
end

local function ResetState()
    originalHair = nil
    hairOverrideActive = false
    lastHatDrawable = -999
    lastHatTexture = -999
end

local function OnPlayerLoaded()
    playerLoaded = true
    lastHatDrawable = -999
    lastHatTexture = -999
    hairOverrideActive = false

    local ped = PlayerPedId()
    ApplyDamagePropProtection(ped)

    DebugPrint('Player loaded, requesting saved hair')

    Wait(2000)
    HatHairBridge.RequestSavedHair()

    RunPostLoadHatChecks()
end

local function OnPlayerUnloaded()
    local ped = PlayerPedId()

    if DoesEntityExist(ped) and originalHair then
        ApplyHair(ped, originalHair)
        DebugPrint('Restored original hair on unload')
    end

    playerLoaded = false
    ResetState()
end

RegisterNetEvent('v42-hathair:client:playerLoaded', function()
    OnPlayerLoaded()
end)

RegisterNetEvent('v42-hathair:client:playerUnloaded', function()
    OnPlayerUnloaded()
end)

RegisterNetEvent('v42-hathair:client:noSavedHair', function()
    originalHair = nil
    hairOverrideActive = false
    lastHatDrawable = -999
    lastHatTexture = -999

    Wait(1000)
    HandleHatHair(true)

    RunPostLoadHatChecks()
end)

RegisterNetEvent('v42-hathair:client:receiveOriginalHair', function(savedHair)
    if savedHair and savedHair.drawable ~= nil then
        originalHair = savedHair
        ApplyHair(PlayerPedId(), originalHair)
        HatHairBridge.ClearSavedHair()

        DebugPrint('Restored original hair from saved state on login')
    else
        originalHair = nil
    end

    hairOverrideActive = false
    lastHatDrawable = -999
    lastHatTexture = -999

    Wait(1000)
    HandleHatHair(true)

    RunPostLoadHatChecks()
end)

RegisterNetEvent('v42-hathair:client:refresh', function()
    Wait(200)
    lastHatDrawable = -999
    lastHatTexture = -999
    HandleHatHair(true)
end)

CreateThread(function()
    while true do
        Wait(Config.CheckInterval)

        if playerLoaded then
            ApplyDamagePropProtection(PlayerPedId())
        end

        HandleHatHair(false)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    if playerLoaded and originalHair then
        ApplyHair(PlayerPedId(), originalHair)
    end
end)
