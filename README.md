# MojiaVehicleKeys
🔑 Best VehicleKeys for QB-Core Framework 🔑
## Dependencies:
- [qb-core](https://github.com/qbcore-framework/qb-core) -Main framework
- [qb-target](https://github.com/BerkieBb/qb-target)
- [MojiaGarages](https://github.com/hoangducdt/MojiaGarages)
## Features:
- The vehicle key will now act as an item
- Additional vehicle keys can be purchased at an adjustable price to give to friends (default 10% of vehicle value)
## Installation:
#### qb-vehicleshop:
- Edit qb-vehicleshop\client.lua:
```
RegisterNetEvent('qb-vehicleshop:client:buyShowroomVehicle', function(vehicle, plate)
    QBCore.Functions.SpawnVehicle(vehicle, function(veh)
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        exports['LegacyFuel']:SetFuel(veh, 100)
        SetVehicleNumberPlateText(veh, plate)
        SetEntityHeading(veh, Config.Shops[getShopInsideOf()]["VehicleSpawn"].w)
        SetEntityAsMissionEntity(veh, true, true)
        TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
        TriggerServerEvent('MojiaVehicleKeys:server:AddVehicleKey', QBCore.Functions.GetPlate(veh), vehicle)
        TriggerServerEvent("qb-vehicletuning:server:SaveVehicleProps", QBCore.Functions.GetVehicleProperties(veh))
    end, Config.Shops[getShopInsideOf()]["VehicleSpawn"], true)
end)
```
#### qb-inventory:
Add item info to qb-inventory\html\js\app.js
```
} else if (itemData.name == "vehiclekey") {
            $(".item-info-title").html(
				'<p>' + itemData.info.vehname + '</p>'
			);
            $(".item-info-description").html(
				'<p>' + MultiLang.owner + ': ' + itemData.info.owner +
				'</p><p>' + MultiLang.license_plate + ': ' + itemData.info.plate +
				'</p>'
			);
        }
```
Add img to qb-inventory\html\images with name carkeys.png:

![carkeys](https://i.imgur.com/JmRS6v9.png)
#### qb-core:
Add to qb-core\shared\items.lua:
```
['vehiclekey'] = {
		['name'] = 'vehiclekey',
		['label'] = 'Vehicle Key',
		['weight'] = 0,
		['type'] = 'item',
		['image'] = 'carkeys.png',
		['unique'] = true,
		['useable'] = false,
		['shouldClose'] = false,
		['combinable'] = nil,
		['description'] = 'This is a car key, take good care of it, if you lose it you probably won\'t be able to use your car'
	},
```

### Event:
- Check vehicles key:
```
if exports['MojiaVehicleKeys']:CheckHasKey(plate) then
```
- Change owner:
```
TriggerClientEvent('MojiaVehicleKeys:client:AddVehicleKey',target, plate, model)
```
