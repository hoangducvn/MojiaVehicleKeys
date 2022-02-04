# MojiaVehicleKeys
🔑 Best VehicleKeys for QB-Core Framework 🔑
## Preview
[Preview - Youtube](https://youtu.be/oR0IcCj9JA0)
## Dependencies:
- [qb-core](https://github.com/qbcore-framework/qb-core) -Main framework
- [qb-target](https://github.com/BerkieBb/qb-target)
- [MojiaGarages](https://github.com/hoangducdt/MojiaGarages)
## Features:
- The vehicle key will now act as an item
- Additional vehicle keys can be purchased at an adjustable price to give to friends (default 10% of vehicle value)
- When you sell your vehicle to someone else, all the keys to the vehicle that were not created by the new owner will be deleted

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
				'<p>Owner : ' + itemData.info.owner +
				'</p><p>Plate: ' + itemData.info.plate +
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
#### qb-hud:
- Change qb-hud\client.lua
```
RegisterCommand('+engine', function()
   TriggerEvent('MojiaVehicleKeys:client:Engine')
end)
```
do the same thing with Lock/Unlock event
```
TriggerEvent('MojiaVehicleKeys:client:lockVehicle')
```
### Event:
- Check vehicles key:
```
if exports['MojiaVehicleKeys']:CheckHasKey(plate) then
```
- Lock/Unlock Vehicles:
```
'MojiaVehicleKeys:client:lockVehicle'
```
- On/Off Engine:
```
'MojiaVehicleKeys:client:Engine'
```
- Add new key:
```
TriggerServerEvent('MojiaVehicleKeys:server:AddVehicleKey', plate, vehicle)
```
- Change owner:
```
TriggerClientEvent('MojiaVehicleKeys:client:AddVehicleKey',target, plate, model)
```
### Note:
- This script is completely free for community, it is strictly forbidden to use this script for commercial purposes.
- If you want to offer me a cup of coffee, you can donate to me through: [https://www.buymeacoffee.com/hoangducdt](https://www.buymeacoffee.com/hoangducdt)
- Follow me on [My Github](https://github.com/hoangducdt) or subscribe to [My Youtube Channel](https://www.youtube.com/channel/UCFIsOgj9zvEWAwFTPRT5mbQ) for latest updates
- My Discord: ✯✯✯✯✯#8386
