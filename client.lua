local QBCore = exports['qb-core']:GetCoreObject()

local keylist = {} ---- DON'T TOUCH THIS!!!
local peds = {} ---- DON'T TOUCH THIS!!!
local tempplates = {} --- DON'T TOUCH!
local IsEngineOn = false
local usingAdvanced
local AlertSend = false

local function HasKey(plate)
	local has = false
	TriggerEvent('MojiaVehicleKeys:client:updateVehicleKey')
	Wait(100)
	for _, v in pairs(keylist) do
		if plate == v then
			has = true
			break
		end
	end
	return has
end

local function HasTemKey(plate)
	has = false
	for _, v in pairs(tempplates) do
		if plate == v then
			has = true
			break
		end
	end
	return has
end

local function CheckHasKey(plate)
	local has = false
	if HasKey(plate) or HasTemKey(plate) then
		has = true
	end
	return has
end

local function AddTempKey(plate)
	if not HasTemKey(plate) then
		tempplates[#tempplates + 1] = plate
	end
end

local function NearPed(model, coords, heading, gender, animDict, animName, scenario)
	RequestModel(GetHashKey(model))
	while not HasModelLoaded(GetHashKey(model)) do
		Wait(1)
	end
	if gender == 'male' then
		genderNum = 4
	elseif gender == 'female' then 
		genderNum = 5
	else
	
	end	
	ped = CreatePed(genderNum, GetHashKey(v.model), coords, heading, false, true)
	SetEntityAlpha(ped, 0, false)
	FreezeEntityPosition(ped, true)
	SetEntityInvincible(ped, true)
	SetBlockingOfNonTemporaryEvents(ped, true)
	if animDict and animName then
		RequestAnimDict(animDict)
		while not HasAnimDictLoaded(animDict) do
			Wait(1)
		end
		TaskPlayAnim(ped, animDict, animName, 8.0, 0, -1, 1, 0, 0, 0)
	end
	if scenario then
		TaskStartScenarioInPlace(ped, scenario, 0, true) 
	end
	for i = 0, 255, 51 do
		Wait(50)
		SetEntityAlpha(ped, i, false)
	end
	return ped
end

local function GetNearbyPed()
    local retval = nil
    local PlayerPeds = {}
    for _, player in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(player)
        PlayerPeds[#PlayerPeds+1] = ped
    end
    local player = PlayerPedId()
    local coords = GetEntityCoords(player)
    local closestPed, closestDistance = QBCore.Functions.GetClosestPed(coords, PlayerPeds)
    if not IsEntityDead(closestPed) and closestDistance < 30.0 then
        retval = closestPed
    end
    return retval
end

local function PoliceCall()
    if not AlertSend then
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local chance = Config.PoliceAlertChance
        if GetClockHours() >= 1 and GetClockHours() <= 6 then
            chance = Config.PoliceNightAlertChance
        end
        if math.random() <= chance then
            local closestPed = GetNearbyPed()
            if closestPed ~= nil then
                local msg = ''
                local s1, s2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z)
                local streetLabel = GetStreetNameFromHashKey(s1)
                local street2 = GetStreetNameFromHashKey(s2)
                if street2 ~= nil and street2 ~= '' then
                    streetLabel = streetLabel .. ' ' .. street2
                end
                local alertTitle = ''
                if IsPedInAnyVehicle(ped) then
                    local vehicle = GetVehiclePedIsIn(ped, false)
                    local modelName = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)):lower()
                    if QBCore.Shared.Vehicles[modelName] ~= nil then
                        Name = QBCore.Shared.Vehicles[modelName]['brand'] .. ' ' .. QBCore.Shared.Vehicles[modelName]['name']
                    else
                        Name = 'Unknown'
                    end
                    local modelPlate = QBCore.Functions.GetPlate(vehicle)
                    local msg = 'Vehicle theft attempt at ' .. streetLabel .. '. Vehicle: ' .. Name .. ', Licenseplate: ' .. modelPlate
                    local alertTitle = 'Vehicle theft attempt at'
                    TriggerServerEvent('police:server:VehicleCall', pos, msg, alertTitle, streetLabel, modelPlate, Name)
                else
                    local vehicle = QBCore.Functions.GetClosestVehicle()
                    local modelName = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)):lower()
                    local modelPlate = QBCore.Functions.GetPlate(vehicle)
                    if QBCore.Shared.Vehicles[modelName] ~= nil then
                        Name = QBCore.Shared.Vehicles[modelName]['brand'] .. ' ' .. QBCore.Shared.Vehicles[modelName]['name']
                    else
                        Name = 'Unknown'
                    end
                    local msg = 'Vehicle theft attempt at ' .. streetLabel .. '. Vehicle: ' .. Name .. ', Licenseplate: ' .. modelPlate
                    local alertTitle = 'Vehicle theft attempt at'
                    TriggerServerEvent('police:server:VehicleCall', pos, msg, alertTitle, streetLabel, modelPlate, Name)
                end
            end
        end
        AlertSend = true
        SetTimeout(Config.AlertCooldown, function()
            AlertSend = false
        end)
    end
end

local function lockpickFinish(success)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local vehicle = QBCore.Functions.GetClosestVehicle(pos)
    local chance = math.random()
    if success then
        TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
        QBCore.Functions.Notify('Opened Door!', 'success')
        SetVehicleDoorsLocked(vehicle, 1)
    else
        PoliceCall()
        TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
        QBCore.Functions.Notify('Someone Called The Police!', 'error')
    end
    if usingAdvanced then
        if chance <= Config.RemoveLockpickAdvanced then
            TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items['advancedlockpick'], 'remove')
            TriggerServerEvent('QBCore:Server:RemoveItem', 'advancedlockpick', 1)
        end
    else
        if chance <= Config.RemoveLockpickNormal then
            TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items['lockpick'], 'remove')
            TriggerServerEvent('QBCore:Server:RemoveItem', 'lockpick', 1)
        end
    end
end

local function hotwireFinish(success)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local vehicle = QBCore.Functions.GetClosestVehicle(pos)
    local chance = math.random()
    if success then
        TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
        QBCore.Functions.Notify(Lang:t('success.successful_hotwire'), 'success')
        SetVehicleDoorsLocked(vehicle, 1)
        local plate = QBCore.Functions.GetPlate(vehicle)
		AddTempKey(plate)
    else
        PoliceCall()
        TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
        QBCore.Functions.Notify(Lang:t('error.someone_called_the_police'), 'error')
    end
    if usingAdvanced then
        if chance <= Config.RemoveLockpickAdvanced then
            TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items['advancedlockpick'], 'remove')
            TriggerServerEvent('QBCore:Server:RemoveItem', 'advancedlockpick', 1)
        end
    else
        if chance <= Config.RemoveLockpickNormal then
            TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items['lockpick'], 'remove')
            TriggerServerEvent('QBCore:Server:RemoveItem', 'lockpick', 1)
        end
    end
end

local function UseLockpick(isAdvanced)
    local ped = PlayerPedId()
	local pos = GetEntityCoords(ped)
	if IsPedInAnyVehicle(ped, false) then
		local veh = GetVehiclePedIsIn(ped)
		local plate = QBCore.Functions.GetPlate(veh)
		local driver = GetPedInVehicleSeat(veh, -1)
		if driver == ped then
			if not CheckHasKey(plate) then
				usingAdvanced = isAdvanced
				TriggerEvent('qb-lockpick:client:openLockpick', hotwireFinish)
			end
		end
	else
		local veh = QBCore.Functions.GetClosestVehicle(pos)
		local plate = QBCore.Functions.GetPlate(veh)
		if veh ~= nil and veh ~= 0 and not CheckHasKey(plate) then
			local vehpos = GetEntityCoords(veh)
			if #(pos - vehpos) < 2.5 then
				local vehLockStatus = GetVehicleDoorLockStatus(veh)
				if (vehLockStatus > 0) then
					usingAdvanced = isAdvanced
					TriggerEvent('qb-lockpick:client:openLockpick', lockpickFinish)
				end
			end
		end
	end
end

local function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Wait(0)
    end
end

--Event:
RegisterNetEvent('MojiaVehicleKeys:client:updateVehicleKey', function()
	QBCore.Functions.TriggerCallback('MojiaVehicleKeys:server:reloadVehicleKey', function(keys)
		if keys then
			keylist = keys
		end
	end)
end)

RegisterNetEvent('MojiaVehicleKeys:client:OpenVehiclesList', function()
	QBCore.Functions.TriggerCallback('MojiaGarages:server:GetUserVehicles', function(result)
		if result then
			local VehicleList = {
				{
					header = Lang:t('menu.locksmith'),
					isMenuHeader = true
				},
			}
			VehicleList[#VehicleList + 1] = {
				header = Lang:t('info.close_menu'),
				txt = '',
				params = {
					event = 'qb-menu:closeMenu',
				}
			}
			for i, v in pairs(result) do
				local price = (QBCore.Shared.Vehicles[v.vehicle].price*Config.PercentageWithVehicleValue)/100
				VehicleList[#VehicleList + 1] = {
					header = Lang:t('menu.crafting_keys_for_x', {vehicle = QBCore.Shared.Vehicles[v.vehicle].name}),
					txt = Lang:t('menu.crafting_keys_info', {plate = v.plate, price = price}),
					params = {
						event = 'MojiaVehicleKeys:client:CreateVehiclekey',
						args = {
							model = v.vehicle,
							plate = v.plate,
							price = price
						}
					}
				}
			end				
			exports['qb-menu']:openMenu(VehicleList)
		end
	end)
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function() -- Event when player has successfully loaded
    TriggerEvent('MojiaVehicleKeys:client:DeleteVehicleKey') --Delete unauthorized vehicle keys
end)

RegisterNetEvent('MojiaVehicleKeys:client:AddVehicleKey', function(plate, model)
	TriggerServerEvent('MojiaVehicleKeys:server:AddVehicleKey', plate, model)
end)

RegisterNetEvent('MojiaVehicleKeys:client:CreateVehiclekey', function(data)
	TriggerServerEvent('MojiaVehicleKeys:server:CreateVehiclekey', data)
end)

RegisterNetEvent('MojiaVehicleKeys:client:DeleteVehicleKey', function() --Delete unauthorized vehicle keys
    TriggerServerEvent('MojiaVehicleKeys:server:DeleteVehicleKey')
end)

RegisterNetEvent('vehiclekeys:client:SetOwner', function(plate) --Event of qb-vehiclekeys
    AddTempKey(plate)
end)

RegisterNetEvent('MojiaVehicleKeys:client:Engine', function()
	local ped = PlayerPedId()
	if IsPedInAnyVehicle(ped, false) then
		local veh = GetVehiclePedIsIn(ped)
		local plate = QBCore.Functions.GetPlate(veh)
		if CheckHasKey(plate) then
			IsEngineOn = not IsEngineOn
		else
			QBCore.Functions.Notify(Lang:t('error.you_dont_have_the_keys_of_the_vehicle'), 'error')
		end
	end
end)

RegisterNetEvent('MojiaVehicleKeys:client:lockVehicle',function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local veh = QBCore.Functions.GetClosestVehicle(pos)
	if IsPedInAnyVehicle(ped) then
        veh = GetVehiclePedIsIn(ped)
    end
    local plate = QBCore.Functions.GetPlate(veh)
    local vehpos = GetEntityCoords(veh)    
    if veh ~= nil and #(pos - vehpos) < 7.5 then
		if CheckHasKey(plate) then
			local vehLockStatus = GetVehicleDoorLockStatus(veh)
			loadAnimDict('anim@mp_player_intmenu@key_fob@')
			TaskPlayAnim(ped, 'anim@mp_player_intmenu@key_fob@', 'fob_click', 3.0, 3.0, -1, 49, 0, false, false,
				false)
			if vehLockStatus == 1 then
				Wait(750)
				ClearPedTasks(ped)
				TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 5, 'lock', 0.3)
				SetVehicleDoorsLocked(veh, 2)
				if (GetVehicleDoorLockStatus(veh) == 2) then
					SetVehicleLights(veh, 2)
					Wait(250)
					SetVehicleLights(veh, 1)
					Wait(200)
					SetVehicleLights(veh, 0)
					QBCore.Functions.Notify(Lang:t('info.vehicle_locked'))
				else
					QBCore.Functions.Notify(Lang:t('info.something_went_wrong_with_the_locking_system'))
				end
			else
				Wait(750)
				ClearPedTasks(ped)
				TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 5, 'unlock', 0.3)
				SetVehicleDoorsLocked(veh, 1)
				if (GetVehicleDoorLockStatus(veh) == 1) then
					SetVehicleLights(veh, 2)
					Wait(250)
					SetVehicleLights(veh, 1)
					Wait(200)
					SetVehicleLights(veh, 0)
					QBCore.Functions.Notify(Lang:t('info.vehicle_unlocked'))
				else
					QBCore.Functions.Notify(Lang:t('info.something_went_wrong_with_the_locking_system'))
				end
			end
		else
			QBCore.Functions.Notify(Lang:t('error.you_dont_have_the_keys_of_the_vehicle'), 'error')
		end
    end
end)

RegisterNetEvent('lockpicks:UseLockpick', function(isAdvanced)
    UseLockpick(isAdvanced)
end)

--Thread:

CreateThread(function()
    while true do        
        local ped = PlayerPedId()
		if IsPedInAnyVehicle(ped, false) then
			if GetPedInVehicleSeat(GetVehiclePedIsIn(ped, false), 0) == ped then
				if GetIsTaskActive(ped, 165) then
					SetPedIntoVehicle(ped, GetVehiclePedIsIn(ped, false), 0)
				end
			end
		end
		Wait(1000)
	end
end)

CreateThread(function() --Lock all vehicle on the map
    while true do 
		if DoesEntityExist(GetVehiclePedIsTryingToEnter(PlayerPedId())) then
            local ped = PlayerPedId()			
			local veh = GetVehiclePedIsTryingToEnter(PlayerPedId())
            local lock = GetVehicleDoorLockStatus(veh)
            local luck = math.random(1, 100)
			local driver = GetPedInVehicleSeat(veh, -1)
            if CheckHasKey(plate) then
				SetVehicleDoorsLocked(veh, 1)
				SetVehicleDoorsLockedForAllPlayers(veh, false)
			end			
			if driver then
                SetPedCanBeDraggedOut(driver, false)
            end
            if Config.UnlockedChance >= 100 then
                Config.UnlockedChance = 100
            elseif Config.UnlockedChance <= 0 then
                Config.UnlockedChance = 0
            end
            if (Config.UnlockedChance >= luck) then
                SetVehicleDoorsLocked(veh, 1)
            elseif (GetConvertibleRoofState(veh) == 1) or (GetConvertibleRoofState(veh) == 2) then
                SetVehicleDoorsLocked(veh, 1)
            elseif (IsVehicleDoorFullyOpen(veh, 0)) or (IsVehicleDoorFullyOpen(veh, 1)) or (IsVehicleDoorFullyOpen(veh, 2)) or (IsVehicleDoorFullyOpen(veh, 3)) or not DoesVehicleHaveDoor(veh, 0) then
                SetVehicleDoorsLocked(veh, 1)
            elseif lock == 0 or lock == 7 or lock == 3 then
                SetVehicleDoorsLocked(veh, 2)
            end
        end
        Wait(500)
    end
end)

CreateThread(function()
    while true do
        local ped = PlayerPedId()
		if IsPedInAnyVehicle(ped, false) then
			local veh = GetVehiclePedIsIn(ped)
			local plate = QBCore.Functions.GetPlate(veh)
			local driver = GetPedInVehicleSeat(veh, -1)
			if driver == ped then					
				if CheckHasKey(plate) then
					--Có chìa khóa:
					if not IsEngineOn then
						--Chưa nổ máy thì tắt máy
						SetVehicleEngineOn(veh, false, false, true)
					else
						--Đã nổ máy thì có thể lái
						SetVehicleEngineOn(veh, true, false, true)
						SetVehicleUndriveable(veh, false)
						SetVehicleJetEngineOn(veh, true)
					end
				else
					--Không có chìa khóa:
					--Luôn luôn tắt máy
					SetVehicleEngineOn(veh, false, false, true)
					IsEngineOn = false
				end
			end
		else
			local veh1 = GetVehiclePedIsTryingToEnter(ped)
			IsEngineOn = GetIsVehicleEngineRunning(veh1)
		end
		Wait(1000)
    end
end)

CreateThread(function() --Spawn Ped
	while true do
		Wait(500)
		for k = 1, #Config.PedList, 1 do
			v = Config.PedList[k]
			local playerCoords = GetEntityCoords(PlayerPedId())
			local dist = #(playerCoords - v.coords)
			if dist < 50.0 and not peds[k] then
				local ped = NearPed(v.model, v.coords, v.heading, v.gender, v.animDict, v.animName, v.scenario)
				peds[k] = {ped = ped}
			end
			if dist >= 50.0 and peds[k] then
				for i = 255, 0, -51 do
					Wait(50)
					SetEntityAlpha(peds[k].ped, i, false)
				end
				DeletePed(peds[k].ped)
				peds[k] = nil
			end
		end
	end
end)

exports['qb-target']:AddTargetModel(`s_m_m_highsec_04`, {
    options = {
        {
            event = 'MojiaVehicleKeys:client:OpenVehiclesList',
            icon = 'fas fa-key',
            label = Lang:t('menu.making_car_keys'),
        }
    },
    distance = 10.0
})

exports('CheckHasKey', CheckHasKey)