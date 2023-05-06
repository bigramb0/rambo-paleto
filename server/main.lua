local QBCore = exports['qb-core']:GetCoreObject()
Drilling = false
BoxesHit = 0
local HitBoxes = {}

local ItemList = {
    ['cashstack'] = math.random(2500, 2900)
}

QBCore.Commands.Add('hit6', 'Help Text', {}, false, function(source, args)
    local src = source
    BoxesHit = 6
end)

-- Events
RegisterNetEvent('srp-paleto:server:toggleBlackout', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local coords = GetEntityCoords(GetPlayerPed(src))
    local dist = #(coords - Config.BigBox.coords)
    if dist < 10.0 then
        BoxesHit = 0
        HitBoxes = {}
        TriggerEvent('qb-weathersync:server:toggleBlackout')
        TriggerClientEvent('QBCore:Notify', -1, 'ATTENTION: We are currently experiencing issues with the load on our electrical systems. San Andreas Light & Power are currently working to restore power as soon as possible.', 'success', 25000)
        Wait(600000)
        TriggerEvent('qb-weathersync:server:toggleBlackout')
        TriggerClientEvent('QBCore:Notify', -1, 'ATTENTION: Power has been restored to the city. Thank you for your patience.', 'success', 7500)
    else
        TriggerEvent('srp-paleto:server:ban', src)
    end
end)

RegisterNetEvent('srp-paleto:server:removeDrill', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    Player.Functions.RemoveItem('thermaldrill', 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['thermaldrill'], 'remove')
end)

RegisterNetEvent('srp-paleto:server:giveDrill', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local coords = GetEntityCoords(GetPlayerPed(src))
    local dist = #(coords - Config.Paleto.coords)
    if dist < 10.0 then
        Drilling = false
        TriggerEvent('srp-paleto:server:stopSyncedParticleLoop')
        Player.Functions.AddItem('thermaldrill', 1, false)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['thermaldrill'], 'add')
    else
        TriggerEvent('srp-paleto:server:ban', src)
    end
end)

RegisterNetEvent('srp-paleto:server:startSyncedParticleLoop', function()
    TriggerClientEvent('srp-paleto:client:startParticleLoop', -1)
end)

RegisterNetEvent('srp-paleto:server:stopSyncedParticleLoop', function()
    Drilling = false
    TriggerClientEvent('srp-paleto:client:stopParticleLoop', -1)
end)

RegisterNetEvent('srp-paleto:server:giveCash', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local coords = GetEntityCoords(GetPlayerPed(src))
    local dist = #(coords - Config.Paleto.coords)
    if dist > 10.0 then 
        TriggerEvent('srp-paleto:server:ban', src)
        return 
    else
        Player.Functions.AddItem('cashstack', 44, false)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['cashstack'], 'add', 44)
    end
end)

RegisterNetEvent('srp-paleto:server:ban', function(source)
    local id = source
    local reason = "Exploiting Paleto Bank. Open a ticket."
    MySQL.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
		GetPlayerName(id),
		QBCore.Functions.GetIdentifier(id, 'license'),
		QBCore.Functions.GetIdentifier(id, 'discord'),
		QBCore.Functions.GetIdentifier(id, 'ip'),
		reason,
		2147483647,
		'srp-paleto'
	})
	TriggerEvent('qb-log:server:CreateLog', 'bans', 'Player Banned', 'red', string.format('%s was banned by %s for %s', GetPlayerName(id), 'Paleto Bank', reason), true)
	DropPlayer(id, 'You have been banned for '..reason..'.\n\nPlease open a ticket on our discord: https://discord.gg/solorp\n\nThank you.')
end)

RegisterNetEvent('srp-paleto:server:tradeCash', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local coords = GetEntityCoords(GetPlayerPed(src))
    local dist = #(coords - Config.NPC.coords)
    if dist < 10 then
        local price = 0
        if Player.PlayerData.items ~= nil and next(Player.PlayerData.items) ~= nil then
            for k, v in pairs(Player.PlayerData.items) do
                if Player.PlayerData.items[k] ~= nil then
                    if ItemList[Player.PlayerData.items[k].name] ~= nil then
                        price = price + (ItemList[Player.PlayerData.items[k].name] * Player.PlayerData.items[k].amount)
                        Player.Functions.RemoveItem(Player.PlayerData.items[k].name, Player.PlayerData.items[k].amount, k)
                        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[Player.PlayerData.items[k].name], "remove", Player.PlayerData.items[k].amount)
                    end
                end
            end
            Player.Functions.AddMoney("cash", price, "traded cashstack")
            TriggerClientEvent('QBCore:Notify', src, "You have traded your cash stacks for $"..price, "success")
        end
    else
        TriggerEvent('srp-paleto:server:ban', src)
    end
end)

RegisterNetEvent('srp-paleto:server:setDrilling', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local coords = GetEntityCoords(GetPlayerPed(src))
    local dist = #(coords - Config.BigBox.coords)
    if dist < 10.0 then
        Drilling = true
    else
        TriggerEvent('srp-paleto:server:ban', src)
    end
end)

RegisterNetEvent('srp-paleto:server:smallBoxHacked', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    BoxesHit = BoxesHit + 1
end)

RegisterNetEvent('srp-paleto:server:addBoxtoHit', function(box)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    table.insert(HitBoxes, box)
end)

RegisterNetEvent('srp-paleto:server:removeItem', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    Player.Functions.RemoveItem('electronickit', 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['electronickit'], 'remove')
end)

-- Callbacks
QBCore.Functions.CreateCallback('srp-paleto:server:isDrilling', function(source, cb)
    cb(Drilling)
end)

QBCore.Functions.CreateCallback('srp-paleto:server:boxesHit', function(source, cb)
    cb(BoxesHit)
end)

QBCore.Functions.CreateCallback('srp-paleto:server:isBoxHit', function(source, cb, box)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if table_contains(HitBoxes, box) then
        cb(true)
    else
        cb(false)
    end
end)

QBCore.Functions.CreateUseableItem('paletomap' , function(source, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    TriggerClientEvent('srp-paleto:client:openMap', src)
end)

function table_contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end