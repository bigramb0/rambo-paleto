PowerOut = 0
local dutycount = 0

RegisterNetEvent('police:SetCopCount', function(amount)
    dutycount = amount
end)

-- Functions

function PowerTimeout()
	CreateThread(function()
		Wait(1000 * 60 * 15)
		PowerOut = 0
	end)
end

function startBlackoutPuzzle()
	local hasitem = QBCore.Functions.HasItem('vpn')
	local hasitem2 = QBCore.Functions.HasItem('electronickit')
	exports["minigames"]:StartMinigame(function(success)
        if success then
			QBCore.Functions.Notify('Success', 'success', 7500)
			TriggerServerEvent('srp-paleto:server:toggleBlackout')
			PowerOut = 1
			PowerTimeout()
        else
			TriggerServerEvent('srp-paleto:server:removeItem')
            QBCore.Functions.Notify('Failed', 'error', 7500)
        end
    end, "spot")
end

function getClosestBox()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    for i = 1, #Config.SmallBoxes do
        local dist = #(pos - Config.SmallBoxes[i].coords)
        if dist < 2.5 then
            --if Config.Debug then print('Box ' .. Config.SmallBoxes[i].box .. ' is closest.') end
            return Config.SmallBoxes[i]
        end
    end
end

function hackSmallBox()
	if dutycount >= Config.MinimumPolice then
		local box = getClosestBox()
		local hasitem = QBCore.Functions.HasItem('screwdriverset')
		local hasitem2 = QBCore.Functions.HasItem('advancedlockpick')
		QBCore.Functions.TriggerCallback('srp-paleto:server:isBoxHit', function(result)
			if not result then
				if hasitem and hasitem2 then
					if box and not box.hit then
						exports["memorygame"]:thermiteminigame(8, 3, 3, 8,
						function() -- success
							QBCore.Functions.Progressbar('hackingsmallpaleto', 'Disabling circuit...', 12000, false, true, { -- Name | Label | Time | useWhileDead | canCancel
								disableMovement = true,
								disableCarMovement = true,
								disableMouse = false,
								disableCombat = true,
							}, {
								animDict = 'anim@gangops@facility@servers@',
								anim = 'hotwire',
								flags = 16,
							}, {}, {}, function() -- Play When Done
								TriggerServerEvent('srp-paleto:server:smallBoxHacked')
							QBCore.Functions.Notify('Success!', 'success', 7500)
							Wait(100)
							QBCore.Functions.TriggerCallback('srp-paleto:server:boxesHit', function(result)
								QBCore.Functions.Notify('Boxes Hit: ' .. result, 'success', 7500)
								if tonumber(result) == 6 then
									QBCore.Functions.Notify('Main unit on standby...', 'error', 15000)
								end
							end)
							TriggerServerEvent('srp-paleto:server:addBoxtoHit', box.id)
							end, function() -- Play When Cancel
								QBCore.Functions.Notify('Cancelled', 'error', 7500)
							end)
						end,
						function() -- failure
							QBCore.Functions.Notify('Failed!', 'error', 7500)
						end)
					else
						QBCore.Functions.Notify('This Box has already been hit!', 'error', 7500)
					end
				else
					QBCore.Functions.Notify('You are missing something.', 'error', 7500)
				end
			else
				QBCore.Functions.Notify('This box has already been re-routed', 'error', 7500)
			end
		end, box.id)
	else
		QBCore.Functions.Notify('Security Lock Active!', 'error', 7500)
	end
end