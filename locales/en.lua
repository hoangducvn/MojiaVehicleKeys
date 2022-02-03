local Translations = {
    error = {
        ['someone_called_the_police'] = 'Someone called the police!',
        ['not_enough_money'] = 'Not enough money!',
        ['you_dont_have_the_keys_of_the_vehicle'] = 'You don\'t have the keys of the vehicle..'
    },
    success = {
        ['successful_hotwire'] = 'Successful hotwire!',

    },
    info = {
        ['close_menu'] = 'Close Menu',
        ['vehicle_locked'] = 'Vehicle locked!',
        ['something_went_wrong_with_the_locking_system'] = 'Something went wrong with the locking system!',
        ['vehicle_unlocked'] = 'vehicle_unlocked',
    },
    menu = {
        ['locksmith'] = 'locksmith',
        ['crafting_keys_for_x'] = 'Crafting keys for %{vehicle}:',
		['crafting_keys_info'] = 'Plate: %{plate}<br>Price: $%{price}',
        ['making_car_keys'] = 'Making Car Keys',
    }
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})