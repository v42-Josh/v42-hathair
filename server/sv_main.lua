RegisterNetEvent('v42-hathair:server:saveOriginalHair', function(hairData)
    local src = source
    HatHairServerBridge.SaveOriginalHair(src, hairData)
end)

RegisterNetEvent('v42-hathair:server:requestOriginalHair', function()
    local src = source
    local hairData = HatHairServerBridge.LoadOriginalHair(src)
    TriggerClientEvent('v42-hathair:client:receiveOriginalHair', src, hairData)
end)

RegisterNetEvent('v42-hathair:server:clearOriginalHair', function()
    local src = source
    HatHairServerBridge.ClearOriginalHair(src)
end)
