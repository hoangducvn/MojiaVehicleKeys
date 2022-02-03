local Translations = {
    error = {
        ['someone_called_the_police'] = 'Có ai đó đã gọi cho cảnh sát!',
        ['not_enough_money'] = 'Bạn không có đủ tiền',
        ['you_dont_have_the_keys_of_the_vehicle'] = 'Bạn không có chìa khóa của chiếc xe này...'
    },
    success = {
        ['successful_hotwire'] = 'Đấu nóng thành công!',

    },
    info = {
        ['close_menu'] = 'Đóng',
        ['vehicle_locked'] = 'Đã khóa xe!',
        ['something_went_wrong_with_the_locking_system'] = 'Đã có lỗi với hệ thống khóa xe!',
        ['vehicle_unlocked'] = 'Đã mở khóa xe!',
    },
    menu = {
        ['locksmith'] = 'Thợ Khóa',
        ['crafting_keys_for_x'] = 'Tạo chìa khóa cho %{vehicle}:',
		['crafting_keys_info'] = 'Biển số: %{plate}<br>Giá tiền: $%{price}',
        ['making_car_keys'] = 'Tạo Chìa Khóa',
    }
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})