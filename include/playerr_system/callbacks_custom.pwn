stock ClearPlayerData(playerid)
{
    if(IsValidVehicle(PI[playerid][pArendID]))
    {
        DestroyVehicle(PI[playerid][pArendID]);
        PI[playerid][pArendTime] = 0;
        PI[playerid][pArendID] = 0;
    }
    if(PI[playerid][pOffer])
    {
        SCMF(PI[playerid][pOfferPlayer], COLOR_RED, "Игрок %s отказался от вашего предложения.", GetName(playerid));
        PI[PI[playerid][pOfferPlayer]][pOffer] = 0;
        PI[PI[playerid][pOfferPlayer]][pOfferTime] = 0;
        PI[PI[playerid][pOfferPlayer]][pOfferPlayer] = INVALID_PLAYER_ID;
        PI[PI[playerid][pOfferPlayer]][pOfferParam] = 0;
        PI[playerid][pOfferPlayer] = -1;
    }
    if (IsValidVehicle(PI[playerid][pCar])) 
    {
        new query[140];
        mysql_format(dbHandle, query, sizeof(query), "SELECT id FROM cars WHERE owner_id = %d", PI[playerid][pID]);
        mysql_tquery(dbHandle, query, "OnCarPrepareToUpdate", "i", playerid);
    }

    FollowBy[playerid] = MAX_PLAYERS;
	SetPVarInt(playerid, "TempFollowBy", -1);

    pCuff[playerid][pCuffer] =
	pCuff[playerid][pCuffee] = INVALID_PLAYER_ID;

    PI[playerid][pName] =
    PI[playerid][pPassword] = 
    PI[playerid][pMail] =
    PI[playerid][pIP] =
    PI[playerid][pRegIP] =
    PI[playerid][pPromocode] =
    PI[playerid][pPrefix] = EOS;

    PI[playerid][pID] = 
    PI[playerid][pPromocodeId] = 
    PI[playerid][pAdmin] = 
    PI[playerid][pHelper] = 
    PI[playerid][pYouTuber] = 
    PI[playerid][pCash] = 
    PI[playerid][pBank] = 
    PI[playerid][pExp] = 
    PI[playerid][pDonate] = 
    PI[playerid][pWanted] = 
    PI[playerid][pLegality] = 
    PI[playerid][pLevel] =
    PI[playerid][pFamily] =
    PI[playerid][pFRang] =   
    PI[playerid][pSex] = 
    PI[playerid][pSkin] = 
    PI[playerid][pQuest] = 
    PI[playerid][pQuestProgress] = 
    PI[playerid][pOffer] = 
    PI[playerid][pOfferTime] = 
    PI[playerid][pOfferParam] =
    PI[playerid][pAFK] = 
    PI[playerid][pJerkAnim] =
    PI[playerid][pJerkTime] =
    PI[playerid][pSpawn] = 
    PI[playerid][pLeader] =
    PI[playerid][pFraction] = 
    PI[playerid][pFractionRank] = 
    PI[playerid][pFractionSkin] =
    PI[playerid][pPorchHouse] =
    PI[playerid][pLicenseA] =
    PI[playerid][pLicenseB] =
    PI[playerid][pLicenseC] =
    PI[playerid][pLicenseWeapon] =
    PI[playerid][pLicenseFlight] =
    PI[playerid][pLicenseBusiness] =
    PI[playerid][pFullAccess] = 0;
    PI[playerid][pBirthDate][0] = EOS;
    PI[playerid][pHasPassport] = false;

    PT[playerid][pCreateVehicleX] = 
    PT[playerid][pCreateVehicleY] = 
    PT[playerid][pCreateVehicleZ] =
    PT[playerid][pCreateVehicleA] =
    PT[playerid][pFloatMapX] = 
    PT[playerid][pFloatMapY] = 
    PT[playerid][pFloatMapZ] = 0.0;

    PI[playerid][pJerk] =
    PI[playerid][pJerkStarted] =
    PI[playerid][pJerkFinished] =

    PT[playerid][pDuty] = 
    PT[playerid][pCefLoaded] = 
    PT[playerid][pSelectorOpened] = 
    PT[playerid][pAlogged] = 
    PT[playerid][pAnimUsed] =
    PT[playerid][pIsPlayerChoosingRegisterSkin] =
    PT[playerid][IsPlayerFlying] =
    PT[playerid][pLogged] = false;

    PT[playerid][pTeleport] =
    PT[playerid][pTeleportType] =
    PT[playerid][pPageDialog] =
    PT[playerid][pLoginAttempts] =
    PT[playerid][pAuthTime] =
    PT[playerid][pCefAuthRetries] =
    PT[playerid][pCefAuthForm] =
    PT[playerid][pAuthStarted] =
    PT[playerid][pAuthLoginPending] =
    PT[playerid][pRegistrationPending] =
    PT[playerid][pAntiFlood] =
    PT[playerid][pAntiFloodF] =
    PT[playerid][pLastEnter] =
    PT[playerid][pCreate] = 
    PT[playerid][pDialogID] = 
    PT[playerid][pSelectedGPSCategory] =
    PT[playerid][pUseTP] =
    PT[playerid][pSubCreate] =
    PT[playerid][pTimerArea] =
    PT[playerid][pPorchHouse] =
    PT[playerid][pTempVehicle] = 0;

    PT[playerid][pCreateVehicleX] = 
    PT[playerid][pCreateVehicleY] = 
    PT[playerid][pCreateVehicleZ] =
    PT[playerid][pCreateVehicleA] =
    PT[playerid][pFloatMapX] = 
    PT[playerid][pFloatMapY] = 
    PT[playerid][pFloatMapZ] = 0.0;

    PT[playerid][pUseGPS] =
    PT[playerid][pTempAdminVehicle] =   
    PT[playerid][pQuestTemp] =
    PT[playerid][pHouseTemp] = 
    PT[playerid][pSafeZoneTemp] = 
    PT[playerid][pJerkAreaTemp] =
    PT[playerid][pPlayer] =
    PT[playerid][pPorch] =
    PT[playerid][pParkingID] = -1;

    PT[playerid][pMovePlayerObj] = INVALID_OBJECT_ID;
}

callback:: PlayerTimer(playerid)
{
    gettime(global_hour, global_minute, global_second);
    
    AdminModeration_Tick(playerid);
    DynDoor_HintTick(playerid);
    if(global_minute == 00 && global_second == 00)
    {
        if(!PT[playerid][pLogged]) SendClientMessage(playerid, -1, "Вы не авторизированы для получения зарплаты.");
        SendClientMessage(playerid, -1, "payday");
        

    }
    PT[playerid][pTimerArea]--;
    if(PT[playerid][pTimerArea] <= 0)
    {
        PT[playerid][pTimerArea] = 0;
    }
    if(PI[playerid][pArendTime] > 0)
	{
		if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER || GetPlayerVehicleID(playerid) != PI[playerid][pArendID])
		{
			PI[playerid][pArendTime]--;
            UpdateBHint(playerid, PI[playerid][pArendTime]);
			if(PI[playerid][pArendTime] == 0)
			{	
				SendErr(playerid, "Ваш арендованный транспорт был отправлен на стоянку.");
				DestroyVehicle(PI[playerid][pArendID]);
				PI[playerid][pArendID] = 0;
				PI[playerid][pArendTime] = 0;
				HideBHint(playerid);
			}
		}
	}
    SaveAccount(playerid);
    PI[playerid][pAFK]++;
    if(PI[playerid][pAFK] >= 3)
    {
        new temp[64];
        format(temp, sizeof(temp), "Игрок на паузе: %s", Converts(PI[playerid][pAFK]));
        SetPlayerChatBubble(playerid, temp, -1, 10.0, 1600);
    }

    if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
        new vehicleid = GetPlayerVehicleID(playerid);
        new Float:x, Float:y, Float:z;
        GetVehiclePos(vehicleid, x, y, z);

        new Float:dist = floatsqroot(
            floatpower(x - CI[vehicleid][vLastPosX], 2.0) +
            floatpower(y - CI[vehicleid][vLastPosY], 2.0) +
            floatpower(z - CI[vehicleid][vLastPosZ], 2.0)
        );

        if(dist >= 1000.0)
        {
            CI[vehicleid][vMileage] += 1;

            CI[vehicleid][vLastPosX] = x;
            CI[vehicleid][vLastPosY] = y;
            CI[vehicleid][vLastPosZ] = z;
        }
        
        new Float:hp, Float:a, cefhp;
        GetVehicleHealth(vehicleid, hp);

        if(hp <= 270.0)
        {
            SetVehicleHealth(vehicleid, 300.0), hp = 300.0;
            GetVehicleZAngle(vehicleid, a);
            SetVehicleZAngle(vehicleid, a);
            GetVehicleParamsEx(vehicleid, CI[vehicleid][Engine], CI[vehicleid][Lights], CI[vehicleid][Alarm], CI[vehicleid][Doors], CI[vehicleid][Bonnet], CI[vehicleid][Boot], CI[vehicleid][Objective]);
            CI[vehicleid][Engine] = false;
            SetVehicleParamsEx(vehicleid, CI[vehicleid][Engine], CI[vehicleid][Lights], CI[vehicleid][Alarm], CI[vehicleid][Doors], CI[vehicleid][Bonnet], CI[vehicleid][Boot], CI[vehicleid][Objective]);
        }

        cefhp = floatround(hp);
        SetSpeedometerIndicatorValue(playerid, 1, CI[vehicleid][Fuel]);
        SetSpeedometerIndicatorValue(playerid, 2, cefhp);
        SetSpeedometerIndicatorValue(playerid, 3, CI[vehicleid][vMileage]);
    }
    if(PI[playerid][pOfferTime])
    {
        PI[playerid][pOfferTime]--;
        if(!PI[playerid][pOfferTime])
        {
            SendClientMessage(playerid, COLOR_RED, "Вы не успели принять решение.");
            new offerPeer = PI[playerid][pOfferPlayer];
            PI[playerid][pOffer] = 0;
            PI[playerid][pOfferTime] = 0;
            PI[playerid][pOfferPlayer] = INVALID_PLAYER_ID;
            PI[playerid][pOfferParam] = 0;

            if(offerPeer != INVALID_PLAYER_ID && IsPlayerConnected(offerPeer))
            {
                PI[offerPeer][pOffer] = 0;
                PI[offerPeer][pOfferTime] = 0;
                PI[offerPeer][pOfferPlayer] = INVALID_PLAYER_ID;
                PI[offerPeer][pOfferParam] = 0;
            }
        }
    }
    if(PI[playerid][pJerkTime])
    {
        PI[playerid][pJerkTime]--;
        if(!PI[playerid][pJerkTime])
        {
            SendClientMessage(playerid, COLOR_BLUE, "Отнесите стакан на ресепшен.");

            TogglePlayerControllable(playerid, 1);
            ApplyAnimation(playerid, "CARRY", "crry_prtial", 4.0, 0, 0, 0, 0, 0, 1);


            PI[playerid][pJerkAnim] = 0;
            PI[playerid][pJerkFinished] = true;
        }
    }
    if(PT[playerid][pAuthTime] > 0 && PT[playerid][pLogged] == false && PT[playerid][pCefLoaded] == true)
    {
        PT[playerid][pAuthTime]--;
        if(PT[playerid][pAuthTime] <= 0)
        {
            SendClientMessage(playerid, COLOR_RED, "Время авторизации истекло.");
            Kick(playerid);
        }
    }
    CheckTrainBoxAreas(playerid);
    CheckTrainDeliverArea(playerid);
    TickArrestTimer(playerid);
    UpdateTimeWidget(playerid);
}

stock SaveAccount(playerid)
{
	if(!PT[playerid][pLogged]) return 1;
	new src[90], query[2024];

	format(query,sizeof(query),"UPDATE accounts SET ");

	format(src,sizeof(src),"ip='%e',",PI[playerid][pIP]);
	strcat(query, src,sizeof(query));
	format(src,sizeof(src),"level=%d,",PI[playerid][pLevel]);
	strcat(query,src,sizeof(query));
	format(src,sizeof(src),"exp=%d,",PI[playerid][pExp]);
	strcat(query,src,sizeof(query));
	format(src,sizeof(src),"skin=%d,",PI[playerid][pSkin]);
	strcat(query,src,sizeof(query));

	if(-2147483647 > PI[playerid][pCash] > 2147483647) PI[playerid][pCash] = 0;
	format(src,sizeof(src),"cash=%d,",PI[playerid][pCash]);
	strcat(query,src,sizeof(query));

	if(-2147483647 > PI[playerid][pBank] > 2147483647) PI[playerid][pBank] = 0;
	format(src,sizeof(src),"bank=%d,",PI[playerid][pBank]);
	strcat(query,src,sizeof(query));

	format(src,sizeof(src),"donate=%d,",PI[playerid][pDonate]);
	strcat(query,src,sizeof(query));
	format(src,sizeof(src),"quest=%d,",PI[playerid][pQuest]);
	strcat(query,src,sizeof(query));
	format(src,sizeof(src),"quest_progress=%d,",PI[playerid][pQuestProgress]);
	strcat(query,src,sizeof(query));
	format(src,sizeof(src),"spawn=%d,",PI[playerid][pSpawn]);
	strcat(query,src,sizeof(query));
	format(src,sizeof(src),"wanted=%d,",PI[playerid][pWanted]);
	strcat(query,src,sizeof(query));
	format(src,sizeof(src),"drug_addiction=%d,",PI[playerid][pDrugAddiction]);
	strcat(query,src,sizeof(query));
	format(src,sizeof(src),"legality=%d,",PI[playerid][pLegality]);
	strcat(query,src,sizeof(query));
	format(src,sizeof(src),"license_a=%d,",PI[playerid][pLicenseA]);
	strcat(query,src,sizeof(query));
	format(src,sizeof(src),"license_b=%d,",PI[playerid][pLicenseB]);
	strcat(query,src,sizeof(query));
	format(src,sizeof(src),"license_c=%d,",PI[playerid][pLicenseC]);
	strcat(query,src,sizeof(query));
	format(src,sizeof(src),"license_weapon=%d,",PI[playerid][pLicenseWeapon]);
	strcat(query,src,sizeof(query));
	format(src,sizeof(src),"license_flight=%d,",PI[playerid][pLicenseFlight]);
	strcat(query,src,sizeof(query));
	format(src,sizeof(src),"license_business=%d,",PI[playerid][pLicenseBusiness]);
	strcat(query,src,sizeof(query));

    
	format(src,sizeof(src),"jerk=%d,", PI[playerid][pJerk]);
	strcat(query,src,sizeof(query));

    format(src,sizeof(src),"family=%d,",PI[playerid][pFamily]);
	strcat(query,src,sizeof(query));
    format(src,sizeof(src),"family_rang=%d,",PI[playerid][pFRang]);
	strcat(query,src,sizeof(query));

    format(src,sizeof(src),"leader=%d,",PI[playerid][pLeader]);
	strcat(query,src,sizeof(query));
    format(src,sizeof(src),"fraction=%d,",PI[playerid][pFraction]);
	strcat(query,src,sizeof(query));
    format(src,sizeof(src),"fraction_skin=%d,",PI[playerid][pFractionSkin]);
	strcat(query,src,sizeof(query));
    format(src,sizeof(src),"fraction_rank=%d,",PI[playerid][pFractionRank]);
	strcat(query,src,sizeof(query));
    format(src,sizeof(src),"porch_house=%d,",PI[playerid][pPorchHouse]);
    strcat(query,src,sizeof(query));
    format(src,sizeof(src),"has_mask=%d,",PI[playerid][pHasMask]);
    strcat(query,src,sizeof(query));
    format(src,sizeof(src),"vip=%d,",PI[playerid][pVip]);
    strcat(query,src,sizeof(query));
    format(src,sizeof(src),"vip_expire=%d",PI[playerid][pVipExpire]);
    strcat(query,src,sizeof(query));

    format(src,sizeof(src)," WHERE id=%d LIMIT 1", PI[playerid][pID]);
	strcat(query,src,sizeof(query));
	mysql_tquery(dbHandle, query, "", "");
    
    mysql_format(dbHandle, query, sizeof(query), "UPDATE `accounts` SET `podtdel` = %d WHERE `id` = %d", PI[playerid][pPodtdel], PI[playerid][pID]);
    mysql_tquery(dbHandle, query);
	return 1;
}

stock SendErr(playerid, err[])
    return SendClientMessage(playerid, COLOR_RED, err);





stock TransferMoney(playerid, toplayerid, money, const reason[])
{
    new bool:hasFrom = (playerid >= 0 && playerid < MAX_PLAYERS && IsPlayerConnected(playerid));
    new bool:hasTo   = (toplayerid >= 0 && toplayerid < MAX_PLAYERS && IsPlayerConnected(toplayerid));
    if(!hasFrom && !hasTo) return 0;

    new fmt_sql[244];

    if(hasFrom)
    {
        PI[playerid][pCash] -= money;
        if(PI[playerid][pCash] < 0) PI[playerid][pCash] = 0;
        if(PI[playerid][pCash] > 2000000000) PI[playerid][pCash] = 2000000000;
        UpdatePlayerHUD(playerid);

        format(fmt_sql,sizeof(fmt_sql),"UPDATE `accounts` SET `cash`=%d WHERE `id`=%d LIMIT 1", PI[playerid][pCash], PI[playerid][pID]);
        mysql_tquery(dbHandle, fmt_sql, "", "");
    }

    if(hasTo)
    {
        PI[toplayerid][pCash] += money;
        if(PI[toplayerid][pCash] < 0) PI[toplayerid][pCash] = 0;
        if(PI[toplayerid][pCash] > 2000000000) PI[toplayerid][pCash] = 2000000000;
        UpdatePlayerHUD(toplayerid);

        format(fmt_sql,sizeof(fmt_sql),"UPDATE `accounts` SET `cash`=%d WHERE `id`=%d LIMIT 1", PI[toplayerid][pCash], PI[toplayerid][pID]);
        mysql_tquery(dbHandle, fmt_sql, "", "");
    }

    Log(hasFrom ? playerid : -1, hasTo ? toplayerid : -1, LOG_TYPES:LOG_TYPE_MONEY, 0, money, reason);
    return 1;
}

stock SpawnPlayerEx(playerid)
{
    new skin = PI[playerid][pSkin];
    if(skin < 1 || skin > 311) skin = 26;
    SetSpawnInfo(playerid, 0, skin, 1933.0570, 2140.2629, 16.0413, 90.0, 0, 0, 0, 0, 0, 0);
    TogglePlayerSpectating(playerid, 0);
    SpawnPlayer(playerid);
    TogglePlayerControllable(playerid, 1);
    OFFHud_Int(playerid);
    SetTimerEx("CEF_ForceCamBehind", 50, false, "i", playerid);
    SetTimerEx("CEF_ForceCamBehind", 200, false, "i", playerid);
    SetTimerEx("CEF_ForceCamBehind", 600, false, "i", playerid);
    SetTimerEx("CEF_ForceCamBehind", 1200, false, "i", playerid);
    SetTimerEx("CEF_ForceCamBehind", 2500, false, "i", playerid);
}

stock GetPlayerID(name[])
{

    if(name[0] >= '0' && name[0] <= '9')
    {
        new id = strval(name);
        if(IsPlayerConnected(id)) return id;
        return INVALID_PLAYER_ID;
    }

    foreach(new i: Player) if(!strcmp(name, GetName(i), true)) return i;
    return INVALID_PLAYER_ID;
}

stock GetPlayerHouseID(playerid)
{
    for(new h = 0; h < total_houses; h++)
    {
        if(House[h][hOwnerID] == PI[playerid][pID]) return h;
    }
    return 0;
}

stock ClearOffer(playerid)
{
    PI[playerid][pOffer] = 0;
    PI[playerid][pOfferTime] = 0;
    PI[playerid][pOfferPlayer] = INVALID_PLAYER_ID;
    PI[playerid][pOfferParam] = 0;
}

static const whitelist[] = {
    "nazik_squad",
};

stock IsPlayerInWhiteList(playerid)
{
    new player_name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, player_name, sizeof(player_name));

    for(new i = 0; i < sizeof(whitelist); i++)
    {
        if(strcmp(player_name, whitelist[i], true) == 0)
            return true;
    }
    return false;
}

stock SetPlayerFacingPoint(playerid, Float:x, Float:y)
{
	new Float:pos[3];
	GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
 
	new Float:angle;
 
	if( y > pos[1] ) angle = (-acos((x - pos[0]) / floatsqroot((x - pos[0])*(x - pos[0]) + (y - pos[1])*(y - pos[1]))) - 90.0);
	else if( y < pos[1] && x < pos[0] ) angle = (acos((x - pos[0]) / floatsqroot((x - pos[0])*(x - pos[0]) + (y - pos[1])*(y - pos[1]))) - 450.0);
	else if( y < pos[1] ) angle = (acos((x - pos[0]) / floatsqroot((x - pos[0])*(x - pos[0]) + (y - pos[1])*(y - pos[1]))) - 90.0);
 
	if(x > pos[0]) angle = (floatabs(floatabs(angle) + 180.0));
	else angle = (floatabs(angle) - 180.0);
 
	return SetPlayerFacingAngle(playerid, angle);
}
 
stock static IsAngleInRangeOfAngle(Float:a1, Float:a2, Float:range = 10.0)
{
	a1 -= a2;
	if((a1 < range) && (a1 > -range)) return true;
	return false;
}
 
stock IsPlayerFacingPoint(playerid, Float:x, Float:y, Float:range = 10.0)
{
	new Float:pos[3];
	GetPlayerPos(pedid, pos[0], pos[1], pos[2]);
 
	new Float:facing;
	GetPlayerFacingAngle(playerid, facing);
 
	new Float:angle;
 
	if( pos[1] > y ) angle = (-acos((pos[0] - x) / floatsqroot((pos[0] - x)*(pos[0] - x) + (pos[1] - y)*(pos[1] - y))) - 90.0);
	else if( pos[1] < y && pos[0] < x ) angle = (acos((pos[0] - x) / floatsqroot((pos[0] - x)*(pos[0] - x) + (pos[1] - y)*(pos[1] - y))) - 450.0);
	else if( pos[1] < y ) angle = (acos((pos[0] - x) / floatsqroot((pos[0] - x)*(pos[0] - x) + (pos[1] - y)*(pos[1] - y))) - 90.0);
 
	return (IsAngleInRangeOfAngle(-angle, facing, range));
}
 
stock SetPlayerFacingPlayer(playerid, targetid)
{
	new Float:pos[3];
	GetPlayerPos(targetid, pos[0], pos[1], pos[2]);
 
	return SetPlayerFacingAngle(playerid, pos[0], pos[1]);
}
 
stock IsPlayerFacingPlayer(playerid, targetid, Float:range =  10.0)
{
	new Float:pos[3];
	GetPlayerPos(targetid, pos[0], pos[1], pos[2]);
 
	return IsPlayerFacingPoint(playerid, pos[0], pos[1], range);
}

stock ShowPlayerMenuDialog(playerid)
{
    return ShowPlayerDialogEx(playerid, dialog_MENU, DIALOG_STYLE_LIST, "Меню игрока", 
    "{e69348}1.{FFFFFF} Статистика персонажа\n\
    {e69348}2.{FFFFFF} Команды сервера\n\
    {e69348}3 {FFFFFF} Защита аккаунта\n\
    {e69348}4.{FFFFFF} Изменение NonRP никнейма\n\
    {e69348}5.{FFFFFF} Правила сервера\n\
    {e69348}6.{99cc00} Промокод\n\
    {e69348}7.{FFFFFF} Дополнительные средства", "Выбрать", "Закрыть");
}
stock MeAction(playerid, action[], Float:distance = 13.0)
{
	new string[128];
	format(string, sizeof(string), "%s %s", GetName(playerid), action);
	foreach(new i: Player)
	{
		if(!IsPlayerConnected(i) || GetPlayerDistanceToPlayer(playerid,i) > distance || GetPlayerVirtualWorld(i) != GetPlayerVirtualWorld(playerid)) continue;
		SendClientMessage(i, 0xc2a2daFF, string);
	}
	return 1;
}
stock ProxDetectorS(Float:radi, playerid, targetid)
{
    new Float:p[3];
    if(!IsPlayerConnected(playerid)) return 0;
    if(!IsPlayerConnected(targetid)) return 0;
    if(!GetPlayerPos(targetid, p[0], p[1], p[2])) return 0;
	if(!IsPlayerInRangeOfPoint(playerid, radi, p[0], p[1], p[2])) return 0;
	return 1;
}
stock SetPlayerToFacePlayer(playerid, targetid)
{
    new
            Float:PlayerX,
            Float:PlayerY,
            Float:PlayerZ,
            Float:X,
            Float:Y,
            Float:Z,
            Float:ang;
    if(!IsPlayerConnected(playerid) || !IsPlayerConnected(targetid)) return 0;
    GetPlayerPos(targetid, X, Y, Z);
    GetPlayerPos(playerid, PlayerX, PlayerY, PlayerZ);
    if( Y > PlayerY ) ang = (-acos((X - PlayerX) / floatsqroot((X - PlayerX)*(X - PlayerX) + (Y - PlayerY)*(Y - PlayerY))) - 90.0);
    else if( Y < PlayerY && X < PlayerX ) ang = (acos((X - PlayerX) / floatsqroot((X - PlayerX)*(X - PlayerX) + (Y - PlayerY)*(Y - PlayerY))) - 450.0);
    else if( Y < PlayerY ) ang = (acos((X - PlayerX) / floatsqroot((X - PlayerX)*(X - PlayerX) + (Y - PlayerY)*(Y - PlayerY))) - 90.0);
    if(X > PlayerX) ang = (floatabs(floatabs(ang) + 180.0));
    else ang = (floatabs(ang) - 180.0);
    SetPlayerFacingAngle(playerid, ang);
    return 0;
}
