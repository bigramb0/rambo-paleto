local QBCore = exports['qb-core']:GetCoreObject()
local DrillSpeed = 0
local DrillProgress = 0
local Overheat = 0
local Drilling = false
local particleDictionary = "core"
local particleName = "exp_grd_flare"
DrillPlaced = false

assets = {}
particles = {}

RegisterNetEvent('srp-paleto:client:attachDrillToDoor', function()
    QBCore.Functions.TriggerCallback('srp-paleto:server:isDrilling', function(result)
        if not result then
            if PowerOut == 0 then QBCore.Functions.Notify('Magnetic sensors active! Try disabling the power.', 'error', 7500) return end
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
            local PaletoDist = #(pos - Config.Paleto.coords)
            local hasitem = QBCore.Functions.HasItem('thermaldrill')

            if hasitem then
                if PaletoDist < 15 then
                    exports['ps-dispatch']:PaletoBankRobbery(camId)
                    QBCore.Functions.Progressbar('attachdrillpaleto', 'Attaching Magnetic Drill', 10000, false, true, { -- Name | Label | Time | useWhileDead | canCancel
                        disableMovement = true,
                        disableCarMovement = true,
                        disableMouse = false,
                        disableCombat = true,
                    }, {
                        animDict = 'anim@gangops@facility@servers@',
                        anim = 'hotwire',
                        flags = 16,
                    }, {}, {}, function() -- Play When Done
                        local object = GetClosestObjectOfType(Config.Paleto.coords.x, Config.Paleto.coords.y, Config.Paleto.coords.z, 5.0, Config.Paleto.object, false, false, false)
                        local object = GetClosestObjectOfType(Config.Paleto.coords.x, Config.Paleto.coords.y, Config.Paleto.coords.z, 5.0, Config.Paleto.object, false, false, false)
                        if object ~= 0 then
                            drill = CreateObject(`k4mb1_prop_thermaldrill`, GetEntityCoords(object), true)
                            SetEntityCoords(drill, -101.73, 6463.72, 32.0, false, false, false, false)
                            SetEntityRotation(drill, 0.0, 90.0, 45.0, 2, true)
                            FreezeEntityPosition(drill, true)
                            exports['qb-target']:AddTargetEntity(drill, {
                                options = {
                                    {
                                        event = "srp-paleto:client:takeDrill",
                                        icon = "fas fa-hand-holding",
                                        label = "Take Drill",
                                    },
                                    {
                                        event = "srp-paleto:client:setDrillSpeed",
                                        icon = "fas fa-cog",
                                        label = "Set Heat Intensity",
                                    },
                                    {
                                        event = "srp-paleto:client:startDrill",
                                        icon = "fas fa-play",
                                        label = "Start Drill",
                                    },
                                },
                                distance = 1.5
                            })
                        end
                        DrillPlaced = true
                        TriggerServerEvent('srp-paleto:server:removeDrill')
                    end, function() -- Play When Cancel
                        QBCore.Functions.Notify('Cancelled', 'error', 7500)
                    end)
                end
            end	
        else
            QBCore.Functions.Notify('Magnetic Sensors active, you need to disable power!', 'error', 7500)
        end
    end)
end)

RegisterNetEvent("srp-paleto:client:setDrillSpeed", function()
    local input = lib.inputDialog('Set Heat Intensity', {
        {type = 'number', label = 'Heat Intensity', description = 'Set the heat intensity of the thermal drill', icon = 'hashtag'},
    })
    if input then
        if input[1] ~= nil then
            if input[1] > 0 and input[1] <= 100 then
                DrillSpeed = math.floor(input[1])
                QBCore.Functions.Notify('Heat intensity set to ' .. input[1] .. '%', 'success', 7500)
                if Config.Debug then print(DrillSpeed) end
            else
                QBCore.Functions.Notify('Heat intensity must be between 1 and 100', 'error', 7500)
            end
        end
    end
end)

RegisterNetEvent("srp-paleto:client:startDrill", function()
    if Drilling then return end
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local PaletoDist = #(pos - Config.Paleto.coords)
    if PaletoDist > 15 then return end
    if DrillSpeed == 0 then QBCore.Functions.Notify('You must set the heat intensity of the drill first!', 'error', 7500) return end
    Drilling = true
    CreateThread(function()
        QBCore.Functions.Notify('Drilling Started...', 'success', 7500)
        TriggerServerEvent('srp-paleto:server:startSyncedParticleLoop')
        while Drilling do
            QBCore.Functions.Notify('Drilling Progress: '..DrillProgress..'% Complete', 'inform', 7500)
            if DrillSpeed >= 60 then 
                Overheat = Overheat + 1
                DrillProgress = DrillProgress + 0.75
            elseif DrillSpeed <= 25 then
                DrillProgress = DrillProgress + 0.55
            elseif DrillSpeed > 25 and DrillSpeed < 60 then
                DrillProgress = DrillProgress + 1
            end
            if Overheat == 5 then 
                QBCore.Functions.Notify('Drill Overheated! Incorrect heat will affect performance!', 'error', 7500)
                TriggerServerEvent('srp-paleto:server:stopSyncedParticleLoop')
                Drilling = false
                Overheat = 0
            end

            if DrillProgress > 100 then
                TriggerServerEvent('nui_doorlock:server:updateState', "paletovault", false, false, true, true)
                QBCore.Functions.Notify('Drilling Complete!', 'success', 7500)
                SpawnCarts()
                TriggerServerEvent('srp-paleto:server:stopSyncedParticleLoop')
                Drilling = false
                OverHeat = 0
                DrillProgress = 0
                DrillSpeed = 0
            end
            Wait(5000)
        end
    end)
end)

RegisterNetEvent('srp-paleto:client:startParticleLoop', function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local PaletoDist = #(pos - Config.Paleto.coords)
    if PaletoDist > 50 then return end 
    for i=1, 10 do 
        Wait(1)
        RequestNamedPtfxAsset(particleDictionary)
        bone = GetPedBoneIndex(PlayerPed, 11816)
        while not HasNamedPtfxAssetLoaded(particleDictionary) do
            Wait(0)
        end
        asset1 = UseParticleFxAssetNextCall(particleDictionary)
        particle = StartParticleFxLoopedAtCoord(particleName, vector3(-101.42, 6463.33, 32.0), 90.0, 50.0, 0.0, 0.7, false, false, false, false)
        table.insert(particles, particle)
        table.insert(assets, asset1)
    end
end)

RegisterNetEvent('srp-paleto:client:stopParticleLoop', function()
    for i = 1, #assets do
        RemoveNamedPtfxAsset(assets[i])
    end
    for i=1, #particles do
        StopParticleFxLooped(particles[i], 0)
    end
    PowerOut = 0 
end)

RegisterNetEvent('srp-paleto:client:takeDrill', function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local PaletoDist = #(pos - Config.Paleto.coords)
    if PaletoDist < 15 then
        local drill = GetClosestObjectOfType(Config.Paleto.coords.x, Config.Paleto.coords.y, Config.Paleto.coords.z, 5.0, `k4mb1_prop_thermaldrill`, false, false, false)
        if drill ~= 0 then
            if not Drilling then
                exports['qb-target']:RemoveTargetEntity(drill)
                SetEntityAsMissionEntity(drill, true, true)
                DeleteEntity(drill)
                QBCore.Functions.Notify('You took the drill', 'success', 7500)
                local key = math.random(1, 100)
                TriggerServerEvent('srp-paleto:server:giveDrill', key)
                DrillPlaced = false
            end
        end
    end
end)