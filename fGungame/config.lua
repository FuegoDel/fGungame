Config = {}

Config.PlayerBlips = {
	On = true,
	BlipStatus = {
		[false] = 0,
		[1] = 1
	}
}

Config.GunGameSettings = {
	RepsawnTime = 5,
	DamageWhenOutOfZone = 10,
}

Config.Maps = {
	{
		GunGameCenter = vector3(205.67, -908.94, 30.69),
		GunGameRadius = 250.0,
		GunGameRespawns = {
			vector4(218.85, -873.32, 30.69, 150.0),
			vector4(212.35, -866.74, 30.69, 200.0),
			vector4(224.79, -886.14, 30.69, 205.58),
		}
	}
}


Config.Loadouts = {
	{
		loadout = {
			{ weapon = 'WEAPON_ISY', UpdatesAt = 3},
			{ weapon = 'WEAPON_PISTOL', UpdatesAt = 3},
		}
	}
}