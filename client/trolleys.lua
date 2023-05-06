function SpawnCarts()
    local model = "hei_prop_hei_cash_trolly_01"
	if Config.Debug then print('spawning carts'..model) end
    RequestModel(model)
    while not HasModelLoaded(model) do RequestModel(model) Wait(100) if Config.Debug then print('loading model') end end
    for i = 1, #Config.Trolleys do
		local x, y, z = Config.Trolleys[i].x, Config.Trolleys[i].y, Config.Trolleys[i].z
		if Config.Debug then print('creating object') end
        local trolley = CreateObject(model, x, y, z, true, true, false)
		if Config.Debug then print('setting heading') end
		SetEntityHeading(trolley, Config.Trolleys[i].h)
		exports['qb-target']:AddTargetEntity(trolley, {
			options = {
				{
					icon = "fas fa-shopping-cart",
					label = "Grab Cash",
					action = function()
						StartGrab()
					end
				},
			},
			distance = 1.5
		})
    end
end

function StartGrab()
    LocalPlayer.state:set("inv_busy", true, true)
    local ped = PlayerPedId()
	SetEntityCanBeDamaged(ped, false)
	FreezeEntityPosition(ped, true)
	SetBlockingOfNonTemporaryEvents(ped, true)
	DisableControlAction(0, 73, true)

    local model = "hei_prop_heist_cash_pile"

    Trolley = GetClosestObjectOfType(GetEntityCoords(ped), 1.0, `hei_prop_hei_cash_trolly_01`, false, false, false)
    local CashAppear = function()
	    local pedCoords = GetEntityCoords(ped)
        local grabmodel = GetHashKey(model)

        RequestModel(grabmodel)
        while not HasModelLoaded(grabmodel) do
            Wait(100)
        end
	    local grabobj = CreateObject(grabmodel, pedCoords, true)

	    FreezeEntityPosition(grabobj, true)
	    SetEntityInvincible(grabobj, true)
	    SetEntityNoCollisionEntity(grabobj, ped)
	    SetEntityVisible(grabobj, false, false)
	    AttachEntityToEntity(grabobj, ped, GetPedBoneIndex(ped, 60309), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 0, true)
	    local startedGrabbing = GetGameTimer()

	    Citizen.CreateThread(function()
		    while GetGameTimer() - startedGrabbing < 37000 do
			    Wait(1)
			    DisableControlAction(0, 73, true)
			    if HasAnimEventFired(ped, `CASH_APPEAR`) then
				    if not IsEntityVisible(grabobj) then
					    SetEntityVisible(grabobj, true, false)
				    end
			    end
			    if HasAnimEventFired(ped, `RELEASE_CASH_DESTROY`) then
				    if IsEntityVisible(grabobj) then
                        SetEntityVisible(grabobj, false, false)
				    end
			    end
		    end
		    DeleteObject(grabobj)
	    end)
    end
	local trollyobj = Trolley
    local emptyobj = `hei_prop_hei_cash_trolly_03`

	if IsEntityPlayingAnim(trollyobj, "anim@heists@ornate_bank@grab_cash", "cart_cash_dissapear", 3) then
		return
    end
    local baghash = `ch_p_m_bag_var03_arm_s`

    RequestAnimDict("anim@heists@ornate_bank@grab_cash")
    RequestModel(baghash)
    RequestModel(emptyobj)
    while not HasAnimDictLoaded("anim@heists@ornate_bank@grab_cash") and not HasModelLoaded(emptyobj) and not HasModelLoaded(baghash) do
        Wait(100)
    end
	while not NetworkHasControlOfEntity(trollyobj) do
		Wait(1)
		NetworkRequestControlOfEntity(trollyobj)
	end
	local bag = CreateObject(`ch_p_m_bag_var03_arm_s`, GetEntityCoords(PlayerPedId()), true, false, false)
    local scene1 = NetworkCreateSynchronisedScene(GetEntityCoords(trollyobj), GetEntityRotation(trollyobj), 2, false, false, 1065353216, 0, 1.3)

	NetworkAddPedToSynchronisedScene(ped, scene1, "anim@heists@ornate_bank@grab_cash", "intro", 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(bag, scene1, "anim@heists@ornate_bank@grab_cash", "bag_intro", 4.0, -8.0, 1)
    SetPedComponentVariation(ped, 5, 0, 0, 0)
	NetworkStartSynchronisedScene(scene1)
	Wait(1500)
	CashAppear()
	local scene2 = NetworkCreateSynchronisedScene(GetEntityCoords(trollyobj), GetEntityRotation(trollyobj), 2, false, false, 1065353216, 0, 1.3)

	NetworkAddPedToSynchronisedScene(ped, scene2, "anim@heists@ornate_bank@grab_cash", "grab", 1.5, -4.0, 1, 16, 1148846080, 0)
	NetworkAddEntityToSynchronisedScene(bag, scene2, "anim@heists@ornate_bank@grab_cash", "bag_grab", 4.0, -8.0, 1)
	NetworkAddEntityToSynchronisedScene(trollyobj, scene2, "anim@heists@ornate_bank@grab_cash", "cart_cash_dissapear", 4.0, -8.0, 1)
	NetworkStartSynchronisedScene(scene2)
	Wait(37000)
	local scene3 = NetworkCreateSynchronisedScene(GetEntityCoords(trollyobj), GetEntityRotation(trollyobj), 2, false, false, 1065353216, 0, 1.3)

	NetworkAddPedToSynchronisedScene(ped, scene3, "anim@heists@ornate_bank@grab_cash", "exit", 1.5, -4.0, 1, 16, 1148846080, 0)
	NetworkAddEntityToSynchronisedScene(bag, scene3, "anim@heists@ornate_bank@grab_cash", "bag_exit", 4.0, -8.0, 1)
	NetworkStartSynchronisedScene(scene3)
    NewTrolley = CreateObject(emptyobj, GetEntityCoords(trollyobj) + vector3(0.0, 0.0, - 0.985), true)
    SetEntityRotation(NewTrolley, GetEntityRotation(trollyobj))
	while not NetworkHasControlOfEntity(trollyobj) do
		Wait(1)
		NetworkRequestControlOfEntity(trollyobj)
	end
	DeleteObject(trollyobj)
    DeleteEntity(trollyobj)
    Wait(10)
    PlaceObjectOnGroundProperly(NewTrolley)
	Wait(1800)
	DeleteObject(bag)
    SetPedComponentVariation(ped, 5, 82, 3, 0)
	RemoveAnimDict("anim@heists@ornate_bank@grab_cash")
	SetModelAsNoLongerNeeded(emptyobj)
    SetModelAsNoLongerNeeded(`ch_p_m_bag_var03_arm_s`)
    LocalPlayer.state:set("inv_busy", false, true)
	SetEntityCanBeDamaged(ped, true)
	FreezeEntityPosition(ped, false)
	SetBlockingOfNonTemporaryEvents(ped, false)
	EnableControlAction(0, 73, true)
	TriggerServerEvent('srp-paleto:server:giveCash')
	exports['qb-target']:RemoveTargetEntity(Trolley)
	trolleyTimeout()
end

function trolleyTimeout()
	Wait(1000 * 60 * 15)
	for i = 1, #Config.Trolleys do
		local trolley = GetClosestObjectOfType(Config.Trolleys[i].coords, 1.0, 'hei_prop_hei_cash_trolly_03', false, false, false)
		if trolley ~= 0 then
			SetEntityAsMissionEntity(trolley, true, true)
			while DoesEntityExist(trolley) do
				Wait(1)
				DeleteObject(trolley)
			end
		end
	end
end

--on resrource stop delete all trolleys
AddEventHandler('onResourceStop', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
		return
	end
	for i = 1, #Config.Trolleys do
		local trolley = GetClosestObjectOfType(Config.Trolleys[i].coords, 1.0, 'hei_prop_hei_cash_trolly_03', false, false, false)
		if trolley ~= 0 then
			SetEntityAsMissionEntity(trolley, true, true)
			while DoesEntityExist(trolley) do
				Wait(1)
				DeleteObject(trolley)
			end
		end
	end
end)