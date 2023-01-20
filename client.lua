ESX = nil

local recName = GetCurrentResourceName()..':';
local mf = math.floor;
local inGungame = false;
local currentGunGameData = nil;
local closePlayers = {};
local myGunGameData = nil;
local LeaderBoardData = nil;


Citizen.CreateThread(function()

	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(100)
	end

	PlayerData = ESX.GetPlayerData();
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)

    PlayerData = xPlayer;
end)

function SetStats(stats, action, extraData)
	if not stats then
		return;
	end

	myGunGameData = stats;

	if action == 'DEATH' then

		if extraData.killerPed then
			
			CreateCinematicShot(-1096069633, 2000, 0, GetPlayerPed(extraData.killerPed))
		end

		PlaySoundFrontend(-1, "MP_Impact", "WastedSounds", true);
		StartScreenEffect("DeathFailMPDark", 0, 0);
		ShakeGameplayCam("DEATH_FAIL_IN_EFFECT_SHAKE", 1.0);
		ESX.Scaleform.ShowFreemodeMessage('~r~ Wasted',extraData.deathReason, 2)

		Wait(1500);

		StopScreenEffect("DeathFailMPDark");
		StopGameplayCamShaking();
		RespawnAtRandomSpawnPoint();
		if IsCinematicShotActive(-1096069633) then
			StopCinematicShot(-1096069633);
		end	
	end
end

function OnKillUpdate(isUpdate,data,isStart)
	PlaySoundFrontend(-1, "RACE_PLACED", "HUD_AWARDS", 1);
	local currentGunGame = GetCurrentGungame('Loadouts');

	if isUpdate then
		if currentGunGame.loadout[data.currentLevel] then
			RemoveAllPedWeapons(PlayerPedId());

			GiveWeaponToPed(PlayerPedId(),GetHashKey(currentGunGame.loadout[data.currentLevel].weapon),9999,false,true);

			SetPedAmmo(PlayerPedId(),GetHashKey(currentGunGame.loadout[data.currentLevel].weapon),9999);

			SetCurrentPedWeapon(PlayerPedId(),GetHashKey(currentGunGame.loadout[data.currentLevel].weapon),true);

			if isStart then

				ESX.Scaleform.ShowFreemodeMessage('~y~ GUNGAME','First player to get '..currentGunGame.loadout[#currentGunGame.loadout].UpdatesAt..' kills with a '..ESX.GetWeaponLabel(currentGunGame.loadout[#currentGunGame.loadout].weapon)..' wins!', 1);
			else

				ESX.Scaleform.ShowFreemodeMessage('~y~ UPGRADE','You have upgraded to  '..ESX.GetWeaponLabel(currentGunGame.loadout[data.currentLevel].weapon)..'!', 1);
			end
		end
	else
		if not isStart then
			
			ESX.ShowNotification('You need '..currentGunGame.loadout[data.currentLevel].UpdatesAt - data.currentKills..' more kills to upgrade')
		end
	end
end

function TransformVector3(vec)
   return vector3(vec.x, vec.y, vec.z);
end

function HandleGungameBlips()
	Citizen.CreateThread(function ()
		while inGungame do
		
			Wait(2000)
	
			for k,v in pairs(GetActivePlayers())do
				local targetPlayer = v;
				local targetPlayerSource = GetPlayerServerId(v);
	
				if not closePlayers[targetPlayerSource] then
	
					closePlayers[targetPlayerSource] = {};
				end
	
				if closePlayers[targetPlayerSource].playerBlip then
	
					if not DoesBlipExist(closePlayers[targetPlayerSource].playerBlip) then
	
						closePlayers[targetPlayerSource].playerBlip = AddBlipForEntity(GetPlayerPed(v));
						BeginTextCommandSetBlipName("STRING");
						AddTextComponentString(GetPlayerName(v));
						EndTextCommandSetBlipName(closePlayers[targetPlayerSource].playerBlip);
					end
	
				else
	
					closePlayers[targetPlayerSource].playerBlip = AddBlipForEntity(GetPlayerPed(v));
					BeginTextCommandSetBlipName("STRING");
					AddTextComponentString(GetPlayerName(v));
					EndTextCommandSetBlipName(closePlayers[targetPlayerSource].playerBlip);
				end
	
				if GetBlipColour(closePlayers[targetPlayerSource].playerBlip) ~= Config.PlayerBlips.BlipStatus[IsEntityDead(GetPlayerPed(v))] then

					SetBlipColour(closePlayers[targetPlayerSource].playerBlip,Config.PlayerBlips.BlipStatus[IsEntityDead(GetPlayerPed(v))]);
				end
			end
		end
	end)
end

function HandleZone()
	local targetGungame = GetCurrentGungame('Maps');

	currentGunGameData.blip = CreateRadiusBlip(targetGungame.GunGameCenter,targetGungame.GunGameRadius);

	Citizen.CreateThread(function ()
		while inGungame do
			Wait(300);
			local dist = #(GetEntityCoords(PlayerPedId()) - targetGungame.GunGameCenter);
			if dist > targetGungame.GunGameRadius then
				
				ESX.Scaleform.ShowFreemodeMessage('~r~WARNING','You are getting out of zone', 1);
				ApplyDamageToPed(PlayerPedId(),Config.GunGameSettings.DamageWhenOutOfZone);
			end
		end
	end)
end

function RespawnAtRandomSpawnPoint(isStart)
	local currentGunGame = GetCurrentGungame('Maps');
	local SpawnPoint = currentGunGame.GunGameRespawns[math.random(1,#currentGunGame.GunGameRespawns)];


	NetworkResurrectLocalPlayer(SpawnPoint.x, SpawnPoint.y, SpawnPoint.z, SpawnPoint.w, true, false); 
	SetEntityHeading(PlayerPedId(),SpawnPoint.w);

	if isStart then
		FreezeEntityPosition(PlayerPedId(),true);
		for i = 3,1,-1 do
			PlaySoundFrontend(-1, "RACE_PLACED", "HUD_AWARDS", 1);
			ESX.Scaleform.ShowFreemodeMessage('~y~Game Starts In '..i..'','', 1)
		end

		FreezeEntityPosition(PlayerPedId(),false);

	else	
		local timer = GetGameTimer() + 1000;

		SetEntityVisible(PlayerPedId(),false);
		SetPlayerInvincible(PlayerPedId(),true);

		
		while timer > GetGameTimer() do
			DisablePlayerFiring(PlayerId(),true)
			Wait(0)
		end

		SetEntityVisible(PlayerPedId(),true);
		SetPlayerInvincible(PlayerPedId(),false);

		RemoveAllPedWeapons(PlayerPedId());
		local mainLoadout = GetCurrentGungame('Loadouts');
		--print(ESX.DumpTable(nigger))
		GiveWeaponToPed(PlayerPedId(),GetHashKey(mainLoadout.loadout[myGunGameData.currentLevel].weapon),9999,false,true);

		SetPedAmmo(PlayerPedId(),GetHashKey(mainLoadout.loadout[myGunGameData.currentLevel].weapon),9999);

		SetCurrentPedWeapon(PlayerPedId(),GetHashKey(mainLoadout.loadout[myGunGameData.currentLevel].weapon),true);
	end
end


function EnteredGunGame(data, mydata,lbdata)

	currentGunGameData = data;

	myGunGameData = mydata;

	inGungame = true;
	LeaderBoardData = {}
	for k,v in pairs(lbdata) do
		table.insert(LeaderBoardData, v)
	end
	--LeaderBoardData = lbdata;
	
	-- table.sort(LeaderBoardData, function (a, b)
	-- 	return a.c > b;
	-- end)
	
	SendNUIMessage({
		action = 'open-lb',
		myindex = lbdata[myGunGameData.identifier],
		leaderboard = LeaderBoardData
	})

	RespawnAtRandomSpawnPoint(true);

	HandleGungameBlips();

	HandleZone();

	OnKillUpdate(true,myGunGameData,true);
end

function CreateRadiusBlip(coords,radius)

	local blip = AddBlipForRadius(coords, radius);

	SetBlipHighDetail(blip, true);

	SetBlipColour(blip, 1);

	SetBlipAlpha(blip, math.floor(128));

	return blip;
end

function GetCurrentGungame(key)
	return Config[key][currentGunGameData[key..'Index']];
end

function ResetGunGame(data)

	if currentGunGameData then
		RemoveBlip(currentGunGameData.blip);
	end

	inGungame = false;
	closePlayers = {};
	myGunGameData = nil;

	local test123 = {}
	for k,v in pairs(data) do
		table.insert(test123, v)
	end

	table.sort(test123,function (a, b)
		return a.currentLevel > b.currentLevel
	end)
	SendNUIMessage({
		action = 'hide-lb'
	})
	Citizen.CreateThread(function()
		while not inGungame do
			Wait(0)
			DisableAllControlActions(true)
		end
	end)
	ESX.Scaleform.ShowFreemodeMessage('~y~GUNGAME ENDED', 'Winner Is '..test123[1].name..' with ' ..(test123[1].allKills or 0)..' Kills', 3)
	ESX.ShowNotification('Please wait 5 seconds')
end

function HideDefaultHud()
	HideHudComponentThisFrame(mf(7));

	HideHudComponentThisFrame(mf(8));

	HideHudComponentThisFrame(mf(9));

	HideHudComponentThisFrame(mf(6));

	HideHudComponentThisFrame(mf(19));

	HideHudAndRadarThisFrame();
end

function OnStatsUpdate(data)
	if not data then
		return;
	end
	
	LeaderBoardData = {}
	
	for k,v in pairs(data) do
		table.insert(LeaderBoardData, v)
	end
	
	table.sort(LeaderBoardData, function (a, b)
		return a.currentLevel > b.currentLevel;
	end)
	-- LeaderBoardData = data;
		
	SendNUIMessage({
		action = 'update-lb',
		myindex = data[myGunGameData.identifier],
		leaderboard = LeaderBoardData
	})
	--print(ESX.DumpTable(data))
end


RegisterNetEvent(recName..'ResetGunGame',ResetGunGame);

RegisterNetEvent(recName..'EnteredGunGame',EnteredGunGame);

RegisterNetEvent(recName..'SetStats',SetStats);

RegisterNetEvent(recName..'OnKillUpdate',OnKillUpdate);

RegisterNetEvent(recName..'OnStatsUpdate',OnStatsUpdate);
