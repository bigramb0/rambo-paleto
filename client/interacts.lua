for _, v in pairs(Config.SmallBoxes) do
    exports['qb-target']:AddCircleZone("srp-paleto:smallbox_"..v.id, v.coords, 1.0, {
        name = "srp-paleto:smallbox".._,
        useZ = true,
        debugPoly = false,
        minZ = 30.0,
        maxZ = 35.0
    }, {
        options = {
            {
                icon = "fas fa-bolt",
                label = "Open Panel",
				action = function()
					hackSmallBox()
				end,
                
            }
        },
        distance = 1.5
    })
end

exports['qb-target']:AddCircleZone('srp-paleto:bigbox', Config.BigBox.coords, 1.0, {
    name = 'srp-paleto:bigbox',
    useZ = true,
    debugPoly = false,
}, {
    options = {
        {
            icon = "fas fa-bolt",
            label = "Open Panel",
            action = function()
                QBCore.Functions.TriggerCallback('srp-paleto:server:boxesHit', function(result)
                    print(result)
                    if tonumber(result) == 6 then
                        startBlackoutPuzzle()
                    else
                        QBCore.Functions.Notify('You cannot do this yet', 'error', 7500)
                    end
                end)
                
            end,
        }
    },
    distance = 1.5
})

exports['qb-target']:AddBoxZone("cpedpaleto", vector3(Config.NPC.coords.x, Config.NPC.coords.y, Config.NPC.coords.z), 1, 1, {
    name="cpedpaleto",
    heading=Config.NPC.heading,
    debugPoly=false,
    minZ=Config.NPC.coords.z-2,
    maxZ=Config.NPC.coords.z+2 
  },{
    options = {
        {
            type = "client",
            event = "srp-paleto:client:tradeCash",
            label = 'Trade Cash',
            icon = 'fa-solid fa-cash',
            canInteract = function()
                return QBCore.Functions.HasItem('cashstack')
            end,
        }
    },
    distance = 3.0
}) 