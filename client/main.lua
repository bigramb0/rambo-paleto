QBCore = exports['qb-core']:GetCoreObject()

-- threads

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local PaletoDist = #(pos - Config.Paleto.coords)
        if PaletoDist < 25 then
			local object = GetClosestObjectOfType(Config.Paleto.coords.x, Config.Paleto.coords.y, Config.Paleto.coords.z, 5.0, Config.Paleto.object, false, false, false)
			
			exports['qb-target']:AddTargetEntity(object, {
				options = {
					{
						event = "srp-paleto:client:attachDrillToDoor",
						icon = "fas fa-link",
						label = "Attach Magnetic Drill"
					}
				},
				distance = 1.5
			})
        end
		Wait(1000)
	end
end)

CreateThread(function()
    local hash = GetHashKey('u_f_y_bikerchic')

    -- Loads model
    RequestModel(hash)
    while not HasModelLoaded(hash) do
      Wait(1)
    end
    -- Creates ped when everything is loaded
    cped = CreatePed(0, hash, Config.NPC.coords.x, Config.NPC.coords.y, Config.NPC.coords.z, true, false)
    SetEntityHeading(cped, Config.NPC.heading)
    Wait(1000)
    FreezeEntityPosition(cped, true)
    SetEntityInvincible(cped, true)
    SetBlockingOfNonTemporaryEvents(cped, true)
end)

-- events
RegisterNetEvent('srp-paleto:client:tradeCash', function()
	QBCore.Functions.Progressbar('tradecashpaleto', 'Negotiating...', 15000, false, true, { -- Name | Label | Time | useWhileDead | canCancel
		disableMovement = true,
		disableCarMovement = true,
		disableMouse = false,
		disableCombat = true,
	}, {}, {}, {}, function() -- Play When Done
		TriggerServerEvent('srp-paleto:server:tradeCash')

	end, function() -- Play When Cancel
		QBCore.Functions.Notify('Canceled', 'error')
	end)
end)

RegisterNetEvent('srp-paleto:client:openMap', function()
	local ped = PlayerPedId()
	exports['ps-ui']:ShowImage('https://cdn.discordapp.com/attachments/1051680995545452555/1079635340001820712/treasure_map.png')

end)
-- NOTE: This polyzone fixes the interior flag of the vault, do not remove it.

PaletoBank = BoxZone:Create(vector3(-104.72, 6469.24, 32.08), 16.2, 15.0, {
	name = "PaletoBank",
	heading = 315,
	debugPoly = false
})

local inPaletoBank = false

-- Updates portalflag if player enters the polyzone
PaletoBank:onPlayerInOut(function(isInside)
	local coords = GetEntityCoords(PlayerPedId())
	local interiorId = GetInteriorFromEntity(PlayerPedId())
	local portalFlag = GetInteriorPortalFlag(interiorId, 2)
	
	if isInside and portalFlag == 64 then
		SetInteriorPortalFlag(interiorId, 2, 0)
		RefreshInterior(interiorId)
		inPaletoBank = true
	elseif isInside and portalFlag == 0 then
	else end  

end)
