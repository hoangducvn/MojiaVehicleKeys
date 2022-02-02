Config = {}
Config.UnlockedChance = 0
Config.RemoveLockpickNormal = 0.5 -- Chance to remove lockpick on fail
Config.RemoveLockpickAdvanced = 0.2 -- Chance to remove advanced lockpick on fail
Config.AlertCooldown = 10000 -- 10 seconds
Config.PoliceAlertChance = 0.5 -- Chance of alerting police during the day
Config.PoliceNightAlertChance = 0.25 -- Chance of alerting police at night (times:01-06)
Config.PercentageWithVehicleValue = 10
Config.PedList = { -- Peds that will be spawned in (if you change a ped model here you need to also change the ped model in client/addons.lua qb-target exports)
	{
		model = "s_m_m_highsec_04",
		coords = vector3(215.45, -808.71, 29.76),               
		heading = 235.06,
		gender = "male",
        scenario = "WORLD_HUMAN_AA_SMOKE"
	},
}
