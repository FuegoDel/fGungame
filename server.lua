ESX = nil;

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local recName = GetCurrentResourceName()..':';
local currentGunGameData = nil;
local inGungame = {};
local gungameActive = false;

Citizen.CreateThread(function()
	Wait(10000)
	RestartGunGame()
end)

function PlayerLoaded(source,xPlayer)

	Wait(3000);

	local src = source;

	local xPlayer = ESX.GetPlayerFromId(src);

	if not xPlayer then
		return;
	end

	if not gungameActive then

		return;
	end

	local xIdentifier = xPlayer.getIdentifier();

	if IsPlayerInGungame(xPlayer.getIdentifier()) then

		RestorePlayerProgress(xPlayer.getIdentifier());
	else

		AddPlayerToGungame(xPlayer.getIdentifier());
	end
end

function AddPlayerToGungame(identifier)
	local xPlayer = ESX.GetPlayerFromIdentifier(identifier);

	if not xPlayer then
		return false;
	end

	if inGungame[identifier] then
		return false;
	end

	local playerData = {
		currentLevel = 1,
		currentKills = 0,
		currentDeaths = 0,
		allKills = 0,
		src = xPlayer.source,
		name = xPlayer.name,
		identifier = xPlayer.identifier,
	}

	inGungame[identifier] = playerData;
	TriggerClientEvent(recName..'EnteredGunGame',xPlayer.source,currentGunGameData,playerData,inGungame);
	return true;
end

function RemovePlayerFromGungame(identifier)
	local xPlayer = ESX.GetPlayerFromIdentifier(identifier);

	inGungame[identifier] = nil;

	if not xPlayer then
		return;
	end
end

function IsPlayerInGungame(identifier)
	
	return inGungame[identifier] and true or false;
end

function RestartGunGame(isRestart)

	if isRestart then
		TriggerClientEvent(recName..'ResetGunGame', -1, inGungame);
		gungameActive = false;

		for k,v in pairs(inGungame)do
            if GetPlayerName(v.src) then
                RemovePlayerFromGungame(k);
            end
        end
		Wait(10000)
	end

	gungameActive = true;
	
	currentGunGameData = {
		['MapsIndex'] = math.random(1,#Config.Maps),
		['LoadoutsIndex'] = math.random(1,#Config.Loadouts)
	}
	
	for k,v in pairs(GetPlayers())do
		local xPlayer = ESX.GetPlayerFromId(v);

		if xPlayer then
			AddPlayerToGungame(xPlayer.getIdentifier());
		end
	end
end

function TriggerGunGameEvent(eventName, ...)
	for k,v in pairs(inGungame) do
		if GetPlayerName(v.src) then
			TriggerClientEvent(eventName, v.src, ...);
		end
	end
end

function OnPlayerDeath(data)
	if not data then
		return;
	end

	if not gungameActive then
		return;
	end

	local src = source;

	local xPlayer = ESX.GetPlayerFromId(src);

	local xkiller = ESX.GetPlayerFromId(data.killerServerId);

	if xkiller and IsPlayerInGungame(xkiller.getIdentifier()) then
		
		local xKillerData = inGungame[xkiller.getIdentifier()];

		xKillerData.currentKills = (xKillerData.currentKills or 0 ) + 1;

		xKillerData.allKills = (xKillerData.allKills or 0 ) + 1;

		local targetGunGame = GetCurrentGungame('Loadouts');

		local isUpdate = false;

		if xKillerData.currentKills == targetGunGame.loadout[xKillerData.currentLevel].UpdatesAt then
			
			isUpdate = true;
			xKillerData.currentKills = 0;
			xKillerData.currentLevel = (xKillerData.currentLevel or 1) + 1;

			if not targetGunGame.loadout[xKillerData.currentLevel] then
				
				RestartGunGame(true);
			end
		else
			TriggerClientEvent(recName..'SetStats',xkiller.source,xKillerData,'KILL')
		end
		TriggerClientEvent(recName..'OnStatsUpdate',-1,inGungame);
		TriggerClientEvent(recName..'OnKillUpdate',xkiller.source,isUpdate,xKillerData);
	end

	if not xPlayer then

		return;
	end

	if not IsPlayerInGungame(xPlayer.getIdentifier()) then

		return;
	end

	local xPlayerData = inGungame[xPlayer.getIdentifier()];

	xPlayerData.currentDeaths = (xPlayerData.currentDeaths or 0) + 1;

	TriggerClientEvent(recName..'SetStats', xPlayer.source, xPlayerData, 'DEATH', {deathReason = (xkiller and 'You have been killed from '..xkiller.name..'!') or 'You have commited suicide', killerPed = data.killerClientId});
end

function RestorePlayerProgress(identifier)

	local previousProgress = inGungame[identifier];

	if not previousProgress then

		return false;
	end

	local xPlayer = ESX.GetPlayerFromIdentifier(identifier);

	if not xPlayer then


		return;
	end

	TriggerClientEvent(recName..'EnteredGunGame',xPlayer.source,currentGunGameData,previousProgress,inGungame);
end

function GetCurrentGungame(key)	
	return Config[key][currentGunGameData[key..'Index']];
end

AddEventHandler("esx:playerLoaded",PlayerLoaded);

RegisterNetEvent('esx:onPlayerDeath',OnPlayerDeath);

