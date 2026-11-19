new PlayerAutoTag[MAX_PLAYERS][32];
new PlayerCustomTag[MAX_PLAYERS][32];
#define ZAK_ENTER_PICKUP_ID  97
#define ZAK_EXIT_PICKUP_ID   98

forward WCreate_OnDialog(playerid, dialogid, response, listitem, inputtext[]);
forward CEF_TradeMoneyDialog(playerid, dialogid, response, listitem, const inputtext[]);
forward CEF_TradeOnConnect(playerid);
forward CEF_TradeOnDisconnect(playerid);
forward CEF_FinesPlayerReset(playerid);
forward CEF_InventoryPlayerReset(playerid);
forward CEF_InventoryPickup(playerid, STREAMER_TAG_PICKUP:pickupid);
forward CEF_RadarOnAreaEnter(playerid, areaid);
forward CEF_RadarOnAreaLeave(playerid, areaid);


public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(DS_OnDialog(playerid, dialogid, response, listitem)) return 1;
    if(PT[playerid][pDialogID] != dialogid) Kick(playerid);
    switch(dialogid)
    {
        case dialog_OK: return 1;
        case DIALOG_CEF_PERKS:
            return CEF_PerksDialog(playerid, dialogid, response, listitem);
        case DIALOG_CEF_CASES, DIALOG_CEF_CASES_BUY:
            return CEF_CasesDialog(playerid, dialogid, response, listitem);
        case DIALOG_CEF_SPAWN: return CEF_OpsSpawnResponse(playerid, response, listitem);
        case DIALOG_NEED: return CEF_NeedsDialog(playerid, response, listitem);
        case DIALOG_CEF_TRADE_MONEY: return CEF_TradeMoneyDialog(playerid, dialogid, response, listitem, inputtext);

        #include "../include/dialog_response.pwn"
    }
    WCreate_OnDialog(playerid, dialogid, response, listitem, inputtext);
    MineOnDialog(playerid, dialogid, response, listitem, inputtext);
    Avtobus_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
    FactoryOnDialog(playerid, dialogid, response, listitem, inputtext);
    OnMechanicDialogResponse(playerid, dialogid, response, listitem, inputtext);
    return 1;
}

forward HandleWarehousePickup(playerid, STREAMER_TAG_PICKUP:pickupid);
public OnPlayerPickUpDynamicPickup(playerid, STREAMER_TAG_PICKUP:pickupid)
{
    if(CEF_InventoryPickup(playerid, pickupid)) return 1;
    if(pickupid == ZAK_ENTER_PICKUP_ID) ZakOnEnterLab(playerid);
    if(pickupid == ZAK_EXIT_PICKUP_ID) ZakOnExitLab(playerid);
    HandleWarehousePickup(playerid, pickupid);
    return 1;
}


public OnPlayerClickPlayer(playerid, clickedplayerid, source) return 1;
forward DynWorld_OnAreaEnter(playerid, areaid);

public OnPlayerEnterDynamicArea(playerid, areaid)
{
    if(DS_OnArea(playerid, areaid)) return 1;
    CEF_RadarOnAreaEnter(playerid, areaid);
    if(DynDoor_OnEnterArea(playerid, areaid)) return 1;
    if(DynWorld_OnAreaEnter(playerid, areaid)) return 1;
    if(StaffRoles_OnEnterPromoArea(playerid, areaid)) return 1;

    for(new i = 0; i < sizeof(SafeZone); i++)
    {
        if(areaid == SafeZone[i][szAreaID])
        {
            PT[playerid][pSafeZoneTemp] = i;
            TogglePlayerGhostMode(playerid, true);
            SCMF(playerid, -1, "   %d", i);
            if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) DisableRemoteVehicleCollisions(playerid, true);
            return 1;
        }
    }
    if(areaid == g_ZakAreaNPC)
    {
        g_ZakNearNPC[playerid] = 1;
        cef_emit_event(playerid, "game:ShowHint", CEFSTR("Y"), CEFINT(2500));
        return 1;
    }
    for(new i = 0; i < sizeof(teleport); i++)
    {
        if(areaid == teleport[i][T_SERVER_AREA_ID] && PT[playerid][pTeleportType] != TELEPORT_TYPE_DEFAULT)
        {
            PT[playerid][pTeleport] = i;
            PT[playerid][pTeleportType] = TELEPORT_TYPE_DEFAULT;

            SCMF(playerid, -1, "OnPlayerEnterDynamicArea(%d, %d)", playerid, areaid);

            cef_emit_event(playerid, "game:fadeScreen", CEFINT(true));
            return 1;
        }
    }

    for(new i = 0; i < sizeof jerkArea; i++)
    {
        if (areaid == jerkArea[i][jerk_area]) return PT[playerid][pJerkAreaTemp] = i;
    }

    for(new i = 0; i < MAX_FRACTIONS; i++)
    {
        if(areaid == Fraction[i][fArmouryPickup] && Fraction[i][fArmouryPickup] != 0)
        {
            if(PI[playerid][pFraction] != i) return SendErr(playerid, "     ");
            if(PT[playerid][pDuty] == false) return SendErr(playerid, "    ().");
            CEF_OpsStorageOpen(playerid);
            return 1;
        }
        if(areaid == Fraction[i][fDressPickup])
        {
            if(PI[playerid][pFraction] != i) return SendErr(playerid, "     ");
            if(PT[playerid][pDuty] == false) ShowPlayerDialogEx(playerid, dialog_FRACTION_WAREHOUSE, DIALOG_STYLE_MSGBOX, " ", "    {db9861} {ffffff}?", "", "");
            else ShowPlayerDialogEx(playerid, dialog_FRACTION_WAREHOUSE, DIALOG_STYLE_MSGBOX, " ", "    {a24243} {ffffff}?", "", "");
            return 1;
        }
    }
    for(new idx; idx < TOTALPORCH; idx++)
    {
        if(areaid == PorchInfo[idx][enter_pickup])
        {
            PT[playerid][pPorch] = idx;
            if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) return 1;
            SetPlayerPos(playerid, PorchInfo[idx][penter_X], PorchInfo[idx][penter_Y], PorchInfo[idx][penter_Z]);
            SetPlayerFacingAngle(playerid,PorchInfo[idx][penter_Fa]);
            SetPlayerVirtualWorld(playerid, idx);
            SetPlayerInterior(playerid, 0);
            SetCameraBehindPlayer(playerid);
            return 1;
        }
        if(areaid == PorchInfo[idx][exit_area])
        {
            SetPlayerPos(playerid, PorchInfo[idx][pEnterX]-1.5, PorchInfo[idx][pEnterY], PorchInfo[idx][pEnterZ]);
            SetPlayerVirtualWorld(playerid, 0);
            SetPlayerInterior(playerid, 0);
            SetCameraBehindPlayer(playerid);
        }
        if(areaid == PorchInfo[idx][menu_area])
        {
            new min_flat = PorchInfo[idx][pFirstFlat];
            new max_flat = PorchInfo[idx][pMaxPorch] + min_flat;
            if(PI[playerid][pPorchHouse] < min_flat || PI[playerid][pPorchHouse] > max_flat) return SendErr(playerid,"      ");
            ShowPlayerDialogEx(playerid, DIALOG_PORCH_MENU, DIALOG_STYLE_LIST, " ", "{e69348}1. {FFFFFF} \n{e69348}2. {FFFFFF} ", "", "");
        }
    }
    for(new idx; idx < totalPorchHouse; idx++)
    {
        if(areaid == PorchHouseInfo[idx][h_area])
        {
            if(PT[playerid][pTimerArea] != 0) return 1;

            PT[playerid][pPorchHouse] = idx;

            if(PorchHouseInfo[idx][hOwnerID] == 0) cef_emit_event(playerid, "game:ShowHint", CEFSTR("B"), CEFINT(2500));
            else cef_emit_event(playerid, "game:ShowHint", CEFSTR("E"), CEFINT(2500));
            ShowPHouseInfo(playerid, idx);
            PT[playerid][pTimerArea] = 7;
            return 1;
        }
        if(areaid == PorchHouseInfo[idx][h_exit_area])
        {
            PT[playerid][pPorchHouse] = idx;
            cef_emit_event(playerid, "game:ShowHint", CEFSTR("E"), CEFINT(2500));
            return 1;
        }
    }
    for(new i = 0; i < MAX_PARKING; i++)
    {
        if(areaid == parking[i][parking_area])
        {
            PT[playerid][pTeleport] = i;
            PT[playerid][pTeleportType] = TELEPORT_TYPE_PARKING_ENTER;

            cef_emit_event(playerid, "game:fadeScreen", CEFINT(true));
            return 1;
        }
        if(areaid == parking[i][parking_e_area])
        {

            new pidx = -1;
            for(new k = 0; k < totalParking; k++)
                if(parking[k][parking_Vw] == GetPlayerVirtualWorld(playerid)) { pidx = k; break; }
            if(pidx < 0) pidx = i;

            PT[playerid][pTeleport] = pidx;
            PT[playerid][pTeleportType] = TELEPORT_TYPE_PARKING_EXIT;

            cef_emit_event(playerid, "game:fadeScreen", CEFINT(true));
            return 1;
        }
        if(areaid == parking[i][parking_e_area_car])
        {
            if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return 1;
            if(GetPlayerHouseID(playerid) != 0) return SendClientMessage(playerid, COLOR_BLUE, "     ,     ");

            PT[playerid][pParkingID] = GetPlayerVirtualWorld(playerid);

            ShowPlayerDialogEx(playerid, dialog_PARKING, DIALOG_STYLE_MSGBOX, " ", ",     {ff9945} \n{FFFFFF}   {ff9945} {FFFFFF}, \
                     \n\
             ,    {99cc00}10.000 ,   {ff9945}   ", "", "");
            return 1;
        }
    }

    for (new c = 1; c < MAX_VEHICLES; ++c)
    {
        if (!IsValidObject(CI[c][vAudioObj]) || areaid != CI[c][vAudioArea]) continue;

        new audioUrl[256];
        format(audioUrl, sizeof audioUrl, "%s?#t=%d", CI[c][vAudioUrl], gettime() - CI[c][vAudioStart]);
        SendClientMessage(playerid, -1, audioUrl);

        cef_create_ext_browser(playerid, c + 1000, "", audioUrl, 10);
        cef_append_to_object(playerid, c + 1000, CI[c][vAudioObj]);
        cef_set_audio_settings(playerid, c + 1000, 25.0, 15.0);
        return 1;
    }

    for(new i = 0; i < totalRent; i++)
    {
        if (areaid == ArendInfo[i][p_area] && GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
        {
            SetPVarInt(playerid, "ArendID", i);

            new zhopa[240];
            format(zhopa, sizeof zhopa, "        \n\
            : {99cc00}%s .\
            \n{ff9945}   ?", SplitInt(ArendInfo[i][p_arenda_price]));
            ShowPlayerDialogEx(playerid, dialog_AREND, DIALOG_STYLE_MSGBOX, " ", zhopa, "", "");
            return 1;
        }
    }
    if(areaid == quest_area[0] && GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
    {
        cef_emit_event(playerid, "game:ShowHint", CEFSTR("E"), CEFINT(2500));
        return 1;
    }
    for(new _h; _h < total_houses; ++_h)
    {
        if(IsPlayerInAnyVehicle(playerid)) return 1;

        if(areaid == House[_h][hAreaExit])
        {
            cef_emit_event(playerid, "game:ShowHint", CEFSTR("E"), CEFINT(2500));
            PT[playerid][pHouseTemp] = _h;
            return 1;
        }

        if(areaid == House[_h][hArea])
        {
            PT[playerid][pHouseTemp] = _h;
            cef_emit_event(playerid, "game:ShowHint", CEFSTR(strcmp(House[_h][hOwner], "None", true) ? "E" : "B"), CEFINT(2500));
            ShowHouseInfo(playerid, _h);
            return 1;
        }
    }
    if(areaid == pickup[0][P_PICKUP_AREA])
    {
        ShowPlayerDialogEx
        (
            playerid, DIALOG_MERIA, DIALOG_STYLE_LIST,
            "",
            "1.   \n\
            2.  \n\
            3.   \n\
            4.  \n\
            5.  \n\
            6.    \n\
            7.    \n\
            8.  ", "", ""
        );
    }
    FactoryOnEnterArea(playerid, areaid);
    Razvoz_OnEnterArea(playerid, areaid);
    MineOnEnterArea(playerid, areaid);
    return 1;
}

public OnPlayerLeaveDynamicArea(playerid, areaid)
{
    if(!PT[playerid][pLogged]) return 0;
    CEF_RadarOnAreaLeave(playerid, areaid);

    for(new i = 0; i < sizeof(SafeZone); i++)
    {
        if(areaid == SafeZone[i][szAreaID])
        {
            PT[playerid][pSafeZoneTemp] = -1;
            TogglePlayerGhostMode(playerid, false);
            return 1;
        }
    }
    if(areaid == g_ZakAreaNPC)
    {
        g_ZakNearNPC[playerid] = 0;
        return 1;
    }
    for(new idx = 1; idx <= totalPorchHouse; idx++)
    {
        if(areaid == PorchHouseInfo[idx][h_area])
        {
            cef_emit_event(playerid, "game:HideBizInfo");
            PT[playerid][pPorchHouse] = 0;
            return 1;
        }
    }
    for (new c = 1; c < MAX_VEHICLES; ++c)
    {
        if (!CI[c][vAudio]) continue;
        if(areaid == CI[c][vAudioArea])
        {
            SCMF(playerid, -1, "       #%d", c);
            cef_destroy_browser(playerid, c+1000);
            return 1;
        }
    }

    for(new _h; _h < total_houses; ++_h)
    {
        if(IsPlayerInAnyVehicle(playerid)) return 1;
        if(areaid == House[_h][hArea] || areaid == House[_h][hAreaExit])
        {
            cef_emit_event(playerid, "game:HideBizInfo");
            PT[playerid][pHouseTemp] = -1;
            return 1;
        }
    }

    for(new i = 0; i < sizeof jerkArea; i++)
    {
        if (areaid == jerkArea[i][jerk_area]) return PT[playerid][pJerkAreaTemp] = -1;
    }
    Avtobus_OnLeaveArea(playerid, areaid);
    MineOnLeaveArea(playerid, areaid);
    return 1;
}

public OnPlayerEditObject(playerid, playerobject, objectid, response, Float:fX, Float:fY, Float:fZ, Float:fRotX, Float:fRotY, Float:fRotZ)
{
    if(response == EDIT_RESPONSE_CANCEL)
    {
        DestroyObject(objectid);
        CancelEdit(playerid);
        
        DeletePVar(playerid, "EditObject");
        DeletePVar(playerid, "EditObjectID");
        DeletePVar(playerid, "EditObjectName");
        
        SendClientMessage(playerid, COLOR_GRAY, "Редактирование отменено.");
        return 1;
    }
    
    if(response == EDIT_RESPONSE_FINAL)
    {
        CancelEdit(playerid);
        
        if(GetPVarInt(playerid, "EditObject"))
        {
            new modelid = GetPVarInt(playerid, "EditObjectID");
            new obj_name[24];
            GetPVarString(playerid, "EditObjectName", obj_name, sizeof(obj_name));

            SetObjectPos(objectid, fX, fY, fZ);
            SetObjectRot(objectid, fRotX, fRotY, fRotZ);

            new query[256];
            mysql_format(dbHandle, query, sizeof(query),
                "INSERT INTO `map_objects` (`model_id`, `pos_x`, `pos_y`, `pos_z`, `rot_x`, `rot_y`, `rot_z`, `name`) \
                 VALUES (%d, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, '%e')",
                modelid, fX, fY, fZ, fRotX, fRotY, fRotZ, obj_name
            );
            mysql_tquery(dbHandle, query, "", "");

            new strf[200];
            format(strf, sizeof(strf), "Объект сохранён: модель %d, координаты (%.2f, %.2f, %.2f), название '%s'",
                modelid, fX, fY, fZ, obj_name);
            SendClientMessage(playerid, COLOR_LIME, strf);
            print(strf);

            DeletePVar(playerid, "EditObject");
            DeletePVar(playerid, "EditObjectID");
            DeletePVar(playerid, "EditObjectName");
        }
        return 1;
    }
    
    return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
    ZakOnCheckpoint(playerid);
    Avtobus_OnPlayerEnterCheckpoint(playerid);
    return 1;
}

public OnPlayerLeaveCheckpoint(playerid) return 1;

public OnPlayerEnterDynamicRaceCP(playerid, STREAMER_TAG_CP:checkpointid)
{
    if(PT[playerid][pUseGPS] == checkpointid)
    {
        SendClientMessage(playerid, COLOR_UNMAZING, "   .");

        DestroyDynamicRaceCP(PT[playerid][pUseGPS]);
        PT[playerid][pUseGPS] = -1;

        RemovePlayerMapIcon(playerid, GPS_MAPICON_ID);
        return 0;
    }
    return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid) return 1;

public OnRconCommand(cmd[]) return 1;

public OnPlayerRequestSpawn(playerid) return 1;

public OnObjectMoved(objectid) return 1;

public OnPlayerObjectMoved(playerid, objectid) return 1;

public OnPlayerPickUpPickup(playerid, pickupid) {
    MineOnPickup(playerid, pickupid);
    return 1;
}


public OnVehicleMod(playerid, vehicleid, componentid) return 1;

public OnVehiclePaintjob(playerid, vehicleid, paintjobid) return 1;

public OnVehicleRespray(playerid, vehicleid, color1, color2) return 1;

public OnPlayerSelectedMenuRow(playerid, row) return 1;

public OnPlayerExitedMenu(playerid) return 1;

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid) return 1;


public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if(PlayerOffer_OnKey(playerid, newkeys)) return 1;
    if(IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
        new vehicleid = GetPlayerVehicleID(playerid);

        if((newkeys & KEY_FIRE) && PlayerNitro[playerid] > 5.0)
        {
            AddVehicleComponent(vehicleid, 1010);
            PlayerPlaySound(playerid, 1132, 0.0, 0.0, 0.0);
        }

        else if((!(newkeys & KEY_FIRE) && (oldkeys & KEY_FIRE)) || (newkeys & KEY_ACTION))
        {
            RemoveVehicleComponent(vehicleid, 1010);
            if(!(newkeys & KEY_ACTION)) PlayerPlaySound(playerid, 1134, 0.0, 0.0, 0.0);
        }
    }
    if(newkeys & KEY_YES)
    {
    ZakInteractWithNPC(playerid);
    }
    if(Razvoz_OnKeyState(playerid, newkeys)) return 1;
    FactoryOnKeyState(playerid, newkeys);
    MineOnKeyState(playerid, newkeys);
    return 1;
}


public OnRconLoginAttempt(ip[], password[], success) return 1;

public OnPlayerUpdate(playerid)
{
    if(PI[playerid][pAFK]) PI[playerid][pAFK] = 0;
    return 1;
}

public OnPlayerStreamIn(playerid, forplayerid) return 1;

public OnPlayerStreamOut(playerid, forplayerid) return 1;

public OnVehicleStreamIn(vehicleid, forplayerid) return 1;

public OnVehicleStreamOut(vehicleid, forplayerid) return 1;

public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
    if(!PT[playerid][pLogged]) return 0;

    if(issuerid != INVALID_PLAYER_ID && PT[issuerid][pSafeZoneTemp] != INVALID_STREAMER_ID)
    {
        ShowPlayerDialogEx(issuerid, dialog_OK, DIALOG_STYLE_MSGBOX, "      ", "    ,    ,  .", "", "");

        if(PT[playerid][pSafeZoneTemp] != INVALID_STREAMER_ID)
        {
            new Float:hp; GetPlayerHealth(playerid, hp);
            if(hp + amount > 100.0) SetPlayerHealth(playerid, 100.0);
        }
        return 0;
    }
    return 0;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
    if(newstate == PLAYER_STATE_DRIVER && !DS_CanDrive(playerid, GetPlayerVehicleID(playerid))) {
        RemovePlayerFromVehicle(playerid);
        return 1;
    }
    Avtobus_OnPlayerStateChange(playerid, newstate, oldstate);
    Mechanic_OnPlayerStateChange(playerid, newstate, oldstate);
    Razvoz_OnPlayerStateChange(playerid, newstate, oldstate);
    switch(newstate)
    {
        case 1:
        {
            new vehicleid = PT[playerid][pTempVehicle];
            if(vehicleid == PT[playerid][pSubCreate] && PT[playerid][pSubCreate])
            {
                SendClientMessage(playerid, COLOR_GRAY, "  !");
                PT[playerid][pCreate] = 0;
                DestroyVehicle(PT[playerid][pSubCreate]);
            }

            if(PI[playerid][pArendID] && vehicleid == PI[playerid][pArendID])
			{
				PI[playerid][pArendTime] = 90;
                ShowBHint(playerid, "", "    ", " :", PI[playerid][pArendTime], PI[playerid][pArendTime], "   ,       \n /unrent,   ", "#e46007", "#4602bf");
			}
            HideSpeedometer(playerid);
            PT[playerid][pTempVehicle] = 0;
        }
        case 2:
        {
            new vehicleid = GetPlayerVehicleID(playerid);
            PT[playerid][pTempVehicle] = vehicleid;
            if(GetPlayerRentID(vehicleid) != INVALID_PLAYER_ID)
            {
                if(vehicleid == PI[playerid][pArendID])
                {
                    PI[playerid][pArendTime] = 0;
                    HideBHint(playerid);
                }
                else
                {
                    SendErr(playerid, "    .    ");
                    RemovePlayerFromVehicle(playerid);
                }
            }
            SendClientMessage(playerid, COLOR_BLUE, "  ,  {FFFFFF}[. CTRL]{1e90ff}     {FFFFFF}/en");
            ShowSpeedometer(playerid);
        }
    }
    return 1;
}

public OnVehicleDeath(vehicleid, killerid) { DS_OnVehicleDeath(vehicleid); return 1; }

public OnPlayerText(playerid, text[])
{
    new caps_count = 0, sym_count = 0, len = strlen(text);
    if(len > 0)
    {
        for(new i = 0; i < len; i++)
        {
            if(('A' <= text[i] <= 'Z') || ((text[i] >= 0xC0 && text[i] <= 0xDF) || text[i] == 0xA8)) caps_count++;
            if(text[i] == '$' || text[i] == '%' || text[i] == '^' || text[i] == '<' || text[i] == '>') sym_count++;
        }

        if(len > 4 && (caps_count * 100 / len) > 50)
        {
            new warn_str[144];
            format(warn_str, sizeof(warn_str), "[Caps-Warning] %s[%d]: %s", GetName(playerid), playerid, text);
            foreach(new i : Player)
            {
                if(PI[i][pAdmin] >= 1 && PT[i][pAdminCapsLog]) SendClientMessage(i, 0xFF9900AA, warn_str);
            }
        }

        if(sym_count >= 3)
        {
            new warn_str[144];
            format(warn_str, sizeof(warn_str), "[Symbol-Warning] %s[%d]   : %s", GetName(playerid), playerid, text);
            foreach(new i : Player)
            {
                if(PI[i][pAdmin] >= 1 && PT[i][pAdminSymLog]) SendClientMessage(i, 0xCC3333AA, warn_str);
            }
        }
    }

    if(PT[playerid][pLogged] == false) return 0;


    if(PT[playerid][pMuteTime] > 0)
    {
        new mute_str[128];
        format(mute_str, sizeof(mute_str), "{FF0000}   !   : %d .", PT[playerid][pMuteTime]);
        SendClientMessage(playerid, -1, mute_str);
        return 0;
    }

    new string[256];
    format(string, sizeof(string), "%s [%d]: %s", GetName(playerid), playerid, text);
    SendClientMessageToAll(-1, string);

    return 0;
}
public OnPlayerCommandText(playerid, cmdtext[])
{
    if(!PT[playerid][pLogged]) return 0;
    return 0;
}

public OnPlayerCommandPerformed(playerid, cmd[], params[], result, flags)
{
    if(result == -1) return SendClientMessage(playerid,0xFFFFFFAA,"{F8FAFA}  ! {F8FAFA} {FF9900}/menu{F8FAFA}   .");
    return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger) {
    if(!ispassenger && !DS_CanDrive(playerid, vehicleid)) {
        SendClientMessage(playerid, 0xE8C17AFF, "Этот транспорт принадлежит другой семье.");
        new Float:dx, Float:dy, Float:dz; GetPlayerPos(playerid, dx, dy, dz);
        SetPlayerPos(playerid, dx, dy, dz+0.1);
        return 0;
    }

    if(CI[vehicleid][vOwnerType] == VEHICLE_OWNER_FRACTION && PI[playerid][pFraction] != CI[vehicleid][vOwnerID] && !ispassenger)
    {
        SendErr(playerid, "    .");

        new Float:x, Float: y, Float: z;
        GetPlayerPos(playerid, x, y, z);
        SetPlayerPos(playerid, x, y, z + 0.1);
        return 0;
    }
    return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid) return 1;

public OnPlayerDeath(playerid, killerid, reason)
{
    DS_OnDeath(playerid);
    new GotPVar = GetPVarInt(playerid, "TempFollowBy");
	if(FollowBy[playerid] != MAX_PLAYERS)
	{
		SetPVarInt(FollowBy[playerid], "TempFollowBy", -1);
		KillTimer(TimerForPlayer[playerid]);
		SendClientMessage(FollowBy[playerid], -1, "  ");
		TimerForPlayer[playerid] = FollowBy[playerid] = MAX_PLAYERS;
	}
	else if(GotPVar != -1)
	{
		SetPVarInt(playerid, "TempFollowBy", -1);
		KillTimer(TimerForPlayer[GotPVar]);
		SendClientMessage(FollowBy[playerid], -1, "  .");
		TimerForPlayer[GotPVar] = FollowBy[GotPVar] = MAX_PLAYERS;
	}
    if(pCuff[playerid][pCuffee] == playerid)
	{
		new idx = playerid;
		new to_player = pCuff[idx][pCuffer];
		SetPlayerSpecialAction(idx, SPECIAL_ACTION_NONE);
		RemovePlayerAttachedObject(idx, 0);
		pCuff[idx][pCuffer] = pCuff[idx][pCuffee] = pCuff[to_player][pCuffee] = pCuff[to_player][pCuffer] = INVALID_PLAYER_ID;
		SendClientMessage(to_player, -1, " ");
	}
    if(killerid != INVALID_PLAYER_ID)
    {
        new death_str[144];
        format(death_str, sizeof(death_str), "[KillLog] %s[%d]  %s[%d]. /: %d", GetName(killerid), killerid, GetName(playerid), playerid, reason);

        foreach(new i : Player)
        {
            if(PI[i][pAdmin] >= 1 && PT[i][pAdminKillLog])
                SendClientMessage(i, COLOR_RED, death_str);
        }
    }
    return 1;
}
public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
    if(PI[playerid][pAdmin] >= 1 && PT[playerid][pAdminAutoMarkTp])
    {
        if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
        {
            new veh = GetPlayerVehicleID(playerid);
            SetVehiclePos(veh, fX, fY, fZ);
            SetPlayerPos(playerid, fX, fY, fZ + 2.0);
        }
        else
        {
            SetPlayerPos(playerid, fX, fY, fZ);
        }
        SCMF(playerid, COLOR_GRAY, "[A]       (fX: %.2f, fY: %.2f)", fX, fY);
    }
    return 1;
}
stock SyncMasksForPlayer(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;

    new str[64];

    foreach(new i : Player)
    {
        if(!IsPlayerConnected(i)) continue;
        if(!PI[i][pMasked]) continue;

        format(str, sizeof str, "{SMASK}SYNC:%d:%d", i, PI[i][pID]);
        SendClientMessage(playerid, -1, str);

        format(str, sizeof str, "{PTAG}SET:%d:MASK", i);
        SendClientMessage(playerid, -1, str);
    }

    return 1;
}
public OnPlayerSpawn(playerid)
{

    if(!PT[playerid][pLogged]) return Kick(playerid);

    switch(PI[playerid][pSpawn])
    {
        case 0:
        {
            SetPlayerPos(playerid, 1933.0570, 2140.2629, 16.0413);
            SetPlayerFacingAngle(playerid, 90.0000);
            SetPlayerVirtualWorld(playerid, 0);
        }
        case 1:
        {
            new h = GetPlayerHouseID(playerid);
            SetPlayerPos(playerid, House_Interiors[House[h][hClass]][hIPos_EX], House_Interiors[House[h][hClass]][hIPos_EY], House_Interiors[House[h][hClass]][hIPos_EZ]);
            SetPlayerVirtualWorld(playerid, House[h][hID]);
            SetPlayerFacingAngle(playerid, House_Interiors[House[h][hClass]][hIPos_EA]);
        }
        case 2:
        {
            new frac = PI[playerid][pFraction];
            SetPlayerPos(playerid, Fractions_Spawn[frac][0], Fractions_Spawn[frac][1], Fractions_Spawn[frac][2]);
            SetPlayerFacingAngle(playerid, Fractions_Spawn[frac][3]);
            SetPlayerVirtualWorld(playerid, frac);
        }
    }

    if((1 <= PI[playerid][pFractionSkin] <= 299))
    {
        new frac = PI[playerid][pFraction];
        new frac_rank = PI[playerid][pFractionRank],
            frac_skin = PI[playerid][pSex] == 1 ? Fraction[frac][fSkinMale][frac_rank - 1] : Fraction[frac][fSkinFemale][frac_rank - 1];

        SetPlayerSkin(playerid, frac_skin);
    }
    else
    {
        SetPlayerSkin(playerid, PI[playerid][pSkin]);
    }


    TogglePlayerSpectating(playerid, 0);
    SetCameraBehindPlayer(playerid);
    SetTimerEx("CEF_ForceCamBehind", 100, false, "i", playerid);
    SetTimerEx("CEF_ForceCamBehind", 500, false, "i", playerid);
    SetTimerEx("CEFC_TabWarm", 1200, false, "i", playerid);
    SetPlayerHUDActive(playerid, true);
    UpdatePlayerHUD(playerid);
	UpdatePlayerTag(playerid);
	SyncAllTagsForPlayer(playerid);
	SyncTagPanelAccess(playerid);
    CheckVipExpire(playerid);
    InitBatonTaser(playerid);

    if(PI[playerid][pMasked])
    {
    PI[playerid][pMasked] = 0;
    new str[32];
    format(str, sizeof str, "{SMASK}CLR:%d", playerid);
    SendClientMessageToAll(-1, str);
    UpdatePlayerTag(playerid);
    SendClientMessage(playerid, -1, "  .");
    }

    SyncMasksForPlayer(playerid);

    if(PI[playerid][pAdmin] > 0 && !PT[playerid][pAlogged]) {
        PT[playerid][pAlogged] = true;
        UpdatePlayerTag(playerid);
        SyncTagPanelAccess(playerid);
    }
    if(g_IsArrested[playerid]) {
        SetTimerEx("ApplyArrestSpawn", 100, false, "i", playerid);
    }
    DS_OnSpawn(playerid);
    return 1;
}

public OnPlayerConnect(playerid)
{
    DS_Reset(playerid);
    CEF_FinesPlayerReset(playerid);
    CEF_InventoryPlayerReset(playerid);
    gCefCasinoFormOpen[playerid] = false;
    gCefCasinoLoaded[playerid] = false;
    gCefCasinoChips[playerid] = 0;
    CEF_TradeOnConnect(playerid);
    CEFC_Reset(playerid);
    CEF_MarkPlayerReset(playerid);
    PT[playerid][pAuthSession]++;
    if(PT[playerid][pAuthSession] <= 0) PT[playerid][pAuthSession] = 1;
    PT[playerid][pAuthStarted] = false;
    PT[playerid][pAuthLoginPending] = false;
    PT[playerid][pRegistrationPending] = false;
    PT[playerid][pCefAuthRetries] = 0;
    PT[playerid][pCefAuthForm] = 0;
    StaffRoles_OnConnect(playerid);
    PlayerOffer_OnConnect(playerid);
    AdminModeration_OnConnect(playerid);
    Document_OnPlayerConnect(playerid);
    Udo_OnPlayerConnect(playerid);
    DynDoor_OnPlayerConnect(playerid);
    new query[128];
    mysql_format(dbHandle, query, sizeof(query), "SELECT * FROM `bans` WHERE `name` = '%e' OR (`ip` != '' AND `ip` = '%e') ORDER BY `id` DESC LIMIT 1", GetName(playerid), PI[playerid][pIP]);
    mysql_tquery(dbHandle, query, "CheckPlayerBan", "i", playerid);
    UpdatePlayerTag(playerid);
    SyncTagPanelAccess(playerid);
    format(PlayerAutoTag[playerid], 32, "PLAYER");
    format(PlayerCustomTag[playerid], 32, "PLAYER");
    if(IsServerRestarting == true)
    {
        SendClientMessage(playerid, COLOR_RED, " . , .");
        return Kick(playerid);
    }
    PT[playerid][pAdminShowIP] = false;
    PT[playerid][pAdminKillLog] = false;
    PT[playerid][pAdminCapsLog] = false;
    PT[playerid][pAdminSymLog] = false;
    PT[playerid][pAdminJoinLog] = false;
    PT[playerid][pAdminSmsSpy] = false;
    PT[playerid][pAdminAutoMarkTp] = false;
    PT[playerid][pAdminJobSpy] = false;
    PT[playerid][pAdminSubSpy] = false;
    PT[playerid][pAdminFamSpy] = false;
    PT[playerid][pAdminComSpy] = false;
    PT[playerid][pAdminIllegalSpy] = false;
    PT[playerid][pTempAdminVehicle] = -1;
    PI[playerid][pMasked] = 0;
    PI[playerid][pHasMask] = 0;
    PI[playerid][pPodtdel] = -1;
    pCuff[playerid][pCuffer] = INVALID_PLAYER_ID;
    pCuff[playerid][pCuffee] = INVALID_PLAYER_ID;

    g_SelectedAdminSetting[playerid] = 0;

    GetPlayerName(playerid, PI[playerid][pName], MAX_PLAYER_NAME);

    player_timer[playerid] = SetTimerEx("PlayerTimer", 1000, true, "d", playerid);

    TogglePlayerSpectating(playerid, true);
    SetTimerEx("DebugPosTick", 100, false, "ii", playerid, 0);
    printf("[DEBUGPOS] OnPlayerConnect tick=%d", GetTickCount());
    GetPlayerIp(playerid, PI[playerid][pIP], 15);
    InitBatonTaser(playerid);

    SetPlayerMapIcon(playerid, 1, -402.779, 1009.8, 13.2477, 63, 0, MAPICON_LOCAL);
    SetPlayerMapIcon(playerid, 2, -1611.46, 1544.69, 36.2602, 63, 0, MAPICON_LOCAL);
    SetPlayerMapIcon(playerid, 3, -2147.51, -94.3456, 26.2668, 63, 0, MAPICON_LOCAL);

    return 1;
}
public OnPlayerDisconnect(playerid, reason)
{
    DS_OnDisconnect(playerid);
    CEF_TradeOnDisconnect(playerid);
    CEF_FinesPlayerReset(playerid);
    CEF_InventoryPlayerReset(playerid);
    gCefCasinoFormOpen[playerid] = false;
    gCefCasinoLoaded[playerid] = false;
    gCefCasinoChips[playerid] = 0;
    CEF_MarkPlayerReset(playerid);
    CEFC_Reset(playerid);
    CEF_OpsPlayerLeft(playerid);
    StaffRoles_OnDisconnect(playerid);
    PlayerOffer_OnDisconnect(playerid);
    Document_OnPlayerDisconnect(playerid);
    Udo_OnPlayerDisconnect(playerid);
    if(g_IsChased[playerid])
    {
        new msg[128];
        format(msg, sizeof(msg), "%s ()     () !", GetName(playerid));
        SendClientMessageToAll(COLOR_RED, msg);
        SendAdminMessage(COLOR_GRAY, msg);
        StopChase(playerid, false);
    }

    ResetCuffState(playerid);
    ResetBagState(playerid);

    SaveAccount(playerid);
    KillTimer(player_timer[playerid]);
    ClearPlayerData(playerid);
    format(PlayerAutoTag[playerid], 32, "PLAYER");
    format(PlayerCustomTag[playerid], 32, "PLAYER");
    ResetTimeWidget(playerid);
    ZakResetPlayer(playerid);
    MineResetPlayer(playerid);
    Avtobus_OnDisconnect(playerid);
    FactoryOnDisconnect(playerid);
    if(Razvoz_IsWorking(playerid)) Razvoz_StopWork(playerid, true);
    if(Mechanic_IsWorking(playerid)) Mechanic_StopWork(playerid);
    Skill_OnPlayerDisconnect(playerid);
    DestroyJobWidget(playerid);
    return 1;
}
public OnPlayerRequestClass(playerid, classid)
{
    if(PT[playerid][pLogged])
    {
        SetSpawnInfo(playerid, 0, 166, 1133.0504,-2038.4034,69.0935, 269.15, 0,0,0,0,0,0);
        SpawnPlayerEx(playerid);
        return 1;
    }
    else
    {
        TogglePlayerSpectating(playerid, false);
        SetPlayerPos(playerid, -890.1702, -382.2885, 1103.6927);
        SetPlayerFacingAngle(playerid, 272.4342);
        SetPlayerVirtualWorld(playerid, playerid + 1000);
        SetPlayerCameraPos(playerid, -887.808959, -382.165618, 1104.483276);
        SetPlayerCameraLookAt(playerid, -892.762634, -382.178314, 1103.804443);
        TogglePlayerControllable(playerid, 0);
        SetTimerEx("ApplyRegisterRoom", 1500, false, "ii", playerid, PT[playerid][pAuthSession]);
    }
    return 1;
}


#define RPC_ScrDisplayGameText 73

stock HideSampChatAndHud(playerid)
{
    #pragma unused playerid
    return 1;
}
stock SyncTagPanelAccess(playerid)
{
    new str[32];

    if(!IsPlayerConnected(playerid)) return 0;

    if(PI[playerid][pAdmin] >= 7) format(str, sizeof(str), "{PTAGUI}ACCESS:1");
    else format(str, sizeof(str), "{PTAGUI}ACCESS:0");

    SendClientMessage(playerid, -1, str);
    return 1;
}

stock UpdateAutoTag(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;

    if(PI[playerid][pAdmin] >= 10) format(PlayerAutoTag[playerid], 32, "OWNER");
    else if(PI[playerid][pAdmin] >= 1) format(PlayerAutoTag[playerid], 32, "ADMIN");
    else if(PI[playerid][pHelper] > 0) format(PlayerAutoTag[playerid], 32, "HELPER");
    else if(PI[playerid][pYouTuber] > 0) format(PlayerAutoTag[playerid], 32, "YOUTUBER");
    else format(PlayerAutoTag[playerid], 32, "NONE");

    return 1;
}

stock GetVisibleTag(playerid, dest[], size)
{
    if(!IsPlayerConnected(playerid)) return 0;

    if(strlen(PlayerCustomTag[playerid]) && strcmp(PlayerCustomTag[playerid], "NONE", true))
    {
        format(dest, size, "%s", PlayerCustomTag[playerid]);
        return 1;
    }

    if(strlen(PlayerAutoTag[playerid]) && strcmp(PlayerAutoTag[playerid], "NONE", true))
    {
        format(dest, size, "%s", PlayerAutoTag[playerid]);
        return 1;
    }

    format(dest, size, "NONE");
    return 1;
}

stock SyncPlayerTag(playerid)
{
    new visibleTag[32], str[80];

    if(!IsPlayerConnected(playerid)) return 0;

    GetVisibleTag(playerid, visibleTag, sizeof(visibleTag));

    if(!strcmp(visibleTag, "NONE", true))
    {
        format(str, sizeof(str), "{PTAG}CLR:%d", playerid);
        SendClientMessageToAll(-1, str);
    }
    else
    {
        format(str, sizeof(str), "{PTAG}SET:%d:%s", playerid, visibleTag);
        SendClientMessageToAll(-1, str);
    }
    return 1;
}

stock UpdatePlayerTag(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;

    UpdateAutoTag(playerid);
    SyncPlayerTag(playerid);
    return 1;
}

stock SyncAllTagsForPlayer(playerid)
{
    new i, visibleTag[32], str[80];

    if(!IsPlayerConnected(playerid)) return 0;

    for(i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i)) continue;

        GetVisibleTag(i, visibleTag, sizeof(visibleTag));

        if(!strcmp(visibleTag, "NONE", true)) format(str, sizeof(str), "{PTAG}CLR:%d", i);
        else format(str, sizeof(str), "{PTAG}SET:%d:%s", i, visibleTag);

        SendClientMessage(playerid, -1, str);
    }

    SyncTagPanelAccess(playerid);
    return 1;
}

CMD:givetag(playerid, params[])
{
    new targetid, tagname[32], msg[128];

    if(PI[playerid][pAdmin] < 4) return 1;

    if(sscanf(params, "us[32]", targetid, tagname))
        return SendClientMessage(playerid, -1, "Usage: /givetag [playerid] [ADMIN/VIP/ELITE/etc]");

    if(!IsPlayerConnected(targetid))
        return SendClientMessage(playerid, -1, "Player not connected.");

    format(PlayerCustomTag[targetid], 32, "%s", tagname);
    SyncPlayerTag(targetid);

    format(msg, sizeof(msg), "You set tag %s for player %d.", tagname, targetid);
    SendClientMessage(playerid, -1, msg);
    return 1;
}

CMD:givetagcustom(playerid, params[])
{
    new targetid, tagname[32], msg[144];

    if(PI[playerid][pAdmin] < 7) return 1;

    if(sscanf(params, "us[32]", targetid, tagname))
        return SendClientMessage(playerid, -1, "Usage: /givetagcustom [playerid] [custom tag]");

    if(!IsPlayerConnected(targetid))
        return SendClientMessage(playerid, -1, "Player not connected.");

    format(PlayerCustomTag[targetid], 32, "%s", tagname);
    SyncPlayerTag(targetid);

    format(msg, sizeof(msg), "You set custom tag %s for player %d.", tagname, targetid);
    SendClientMessage(playerid, -1, msg);
    return 1;
}

CMD:removetag(playerid, params[])
{
    new targetid;

    if(PI[playerid][pAdmin] < 7) return 1;

    if(sscanf(params, "u", targetid))
        return SendClientMessage(playerid, -1, "Usage: /removetag [playerid]");

    if(!IsPlayerConnected(targetid))
        return SendClientMessage(playerid, -1, "Player not connected.");

    format(PlayerCustomTag[targetid], 32, "NONE");
    UpdatePlayerTag(targetid);

    SendClientMessage(playerid, -1, "Custom tag removed.");
    return 1;
}

CMD:checktag(playerid, params[])
{
    new targetid, msg[180], visibleTag[32];

    if(PI[playerid][pAdmin] < 7) return 1;

    if(sscanf(params, "u", targetid))
        return SendClientMessage(playerid, -1, "Usage: /checktag [playerid]");

    if(!IsPlayerConnected(targetid))
        return SendClientMessage(playerid, -1, "Player not connected.");

    GetVisibleTag(targetid, visibleTag, sizeof(visibleTag));

    format(msg, sizeof(msg), "Player %d | Auto: %s | Custom: %s | Visible: %s",
        targetid,
        PlayerAutoTag[targetid],
        PlayerCustomTag[targetid],
        visibleTag
    );
    SendClientMessage(playerid, -1, msg);
    return 1;
}

CMD:syncptags(playerid, params[])
{
    if(PI[playerid][pAdmin] < 7) return 1;

    SyncAllTagsForPlayer(playerid);
    SendClientMessage(playerid, -1, "Patchik tags synced.");
    return 1;
}
