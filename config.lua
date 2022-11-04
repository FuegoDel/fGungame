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
			vector3(224.91,-956.82,28.32),
			vector3(188.16,-992.83,29.1),
			vector3(157.48,-980.24,29.1),
			vector3(154.84,-978.89,29.1),
			vector3(148.06,-952.93,28.75),
			vector3(161.15,-915.21,29.19),
			vector3(179.17,-886.3,30.13),
			vector3(185.11,-855.44,30.15),
			vector3(254.52,-865.85,28.4),
			vector3(201.23,-927.14,29.7),
			vector3(188.01,-953.29,29.1)
		}
	},
	{
		GunGameCenter = vector3(1432.97,1116.02,113.24),
		GunGameRadius = 250.0,
		GunGameRespawns = {
			vector3(1432.62,1096.12,113.23)
		}
	}
}


Config.Loadouts = {
	{
		loadout = {
			{ weapon = 'WEAPON_ISY', UpdatesAt = 1},
			{ weapon = 'WEAPON_PISTOL', UpdatesAt = 1},
		}
	}
}