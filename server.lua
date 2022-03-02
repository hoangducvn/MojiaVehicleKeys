local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateCallback('MojiaVehicleKeys:server:reloadVehicleKey', function(source, cb)
    local src = source
    local retval = {}
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        local items = Player.Functions.GetItemsByName('vehiclekey')
		if items then
			for _, v in pairs(items) do
				retval[#retval +1] = v.info.plate
			end
		end
    end
    cb(retval)
end)

function AddVehicleKey(plate, model)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local info = {}
	info.owner = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
	info.vehname = model
	if QBCore.Shared.Vehicles[model] then
		info.vehname = QBCore.Shared.Vehicles[model].name
	end
	info.plate = plate
	info.citizenid = Player.PlayerData.citizenid
	Player.Functions.AddItem('vehiclekey', 1, nil, info)
	TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['vehiclekey'], 'add')
	TriggerClientEvent('MojiaVehicleKeys:client:DeleteVehicleKey', -1) --Delete unauthorized vehicle keys
end

RegisterNetEvent('MojiaVehicleKeys:server:AddVehicleKey', function(plate, model)
	AddVehicleKey(plate, model)
end)

RegisterNetEvent('MojiaVehicleKeys:server:DeleteVehicleKey', function()
	local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
		local items = Player.Functions.GetItemsByName('vehiclekey')
		if items then
			for _, v in pairs(items) do
				MySQL.Async.fetchAll('SELECT * FROM player_vehicles WHERE plate = ?',
					{
						v.info.plate
					}, function(result)
					if result then
						for k, v1 in pairs(result) do
							if v.info.citizenid ~= v1.citizenid then
								Player.Functions.RemoveItem(v.name, 1, v.slot)
								TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[v.name], 'remove')
							end
						end
					end
				end)
			end
		end
    end
end)

RegisterNetEvent('MojiaVehicleKeys:server:CreateVehiclekey', function(data)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
    local cash = Player.PlayerData.money['cash']
    local bank = Player.PlayerData.money['bank']
	if cash >= data.price then
		AddVehicleKey(data.plate, data.model)
		Player.Functions.RemoveMoney('cash', data.price, 'Create Vehicle key')
	elseif bank >= data.price then
		AddVehicleKey(data.plate, data.model)
		Player.Functions.RemoveMoney('bank', data.price, 'Create Vehicle key')
	else
		TriggerClientEvent('QBCore:Notify', src, Lang:t('error.not_enough_money'), 'error')
	end
end)