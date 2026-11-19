#define SPEC_BROWSER 63
#define SPEC_CEF_LINK "file:///cef/amazing/specmenu/index.html"

new g_SpecTarget[MAX_PLAYERS] = {INVALID_PLAYER_ID, ...};
new bool:g_SpecActive[MAX_PLAYERS];
new g_SpecFilter[MAX_PLAYERS] = {-1, ...};
new bool:g_SpecFrozen[MAX_PLAYERS];
new bool:g_SpecPGMarked[MAX_PLAYERS];
new g_SpecTimer[MAX_PLAYERS] = {-1, ...};

new Float:g_SpecOriginX[MAX_PLAYERS];
new Float:g_SpecOriginY[MAX_PLAYERS];
new Float:g_SpecOriginZ[MAX_PLAYERS];
new g_SpecOriginVW[MAX_PLAYERS];
new g_SpecOriginInterior[MAX_PLAYERS];

new g_SpecMoveTarget[MAX_PLAYERS] = {INVALID_PLAYER_ID, ...};
new g_SpecMoveObject[MAX_PLAYERS] = {INVALID_OBJECT_ID, ...};
new bool:g_SpecMoveWasFrozen[MAX_PLAYERS];

stock Spec_ShowToast(playerid, const text[])
{
    if(!IsPlayerConnected(playerid)) return 0;
    cef_emit_event(playerid, "spec:toast", CEFSTR(text));
    SendClientMessage(playerid, COLOR_GRAY, text);
    return 1;
}

stock Spec_ShowInfo(playerid, const title[], const text[])
{
    if(!IsPlayerConnected(playerid)) return 0;
    cef_emit_event(playerid, "spec:info", CEFSTR(title), CEFSTR(text));
    return 1;
}

stock Spec_IsTargetAllowed(playerid, targetid)
{
    if(!g_SpecActive[playerid]) return 0;
    if(targetid == playerid) return 0;
    if(!IsPlayerConnected(targetid) || !PT[targetid][pLogged]) return 0;
    if(g_SpecFilter[playerid] >= 0 && PI[targetid][pFraction] != g_SpecFilter[playerid]) return 0;
    return 1;
}

stock Spec_SendEmpty(playerid)
{
    cef_emit_event(playerid, "spec:empty", CEFSTR("No online players in this fraction."));
    return 1;
}

stock Spec_CountTargets(playerid)
{
    new count = 0;
    for(new targetid = 0; targetid < MAX_PLAYERS; targetid++)
    {
        if(Spec_IsTargetAllowed(playerid, targetid)) count++;
    }
    return count;
}

stock Spec_SendFilterCount(playerid)
{
    cef_emit_event(playerid, "spec:filter_count", CEFINT(Spec_CountTargets(playerid)));
    return 1;
}

stock Spec_FindPlayer(playerid, start, direction)
{
    new id = start;
    for(new n = 0; n < MAX_PLAYERS; n++)
    {
        id += direction;
        if(id < 0) id = MAX_PLAYERS - 1;
        if(id >= MAX_PLAYERS) id = 0;
        if(Spec_IsTargetAllowed(playerid, id)) return id;
    }
    return INVALID_PLAYER_ID;
}

stock Spec_GetRole(targetid, role[], size)
{
    if(PI[targetid][pAdmin] > 0) format(role, size, "ADMIN");
    else if(PI[targetid][pLeader] > 0) format(role, size, "LEADER");
    else format(role, size, "PLAYER");
    return 1;
}

stock Spec_GetFractionName(targetid, fraction[], size)
{
    new fractionid = PI[targetid][pFraction];
    if(fractionid > 0 && fractionid < MAX_FRACTIONS && Fraction[fractionid][fName][0])
        format(fraction, size, "%s", Fraction[fractionid][fName]);
    else
        format(fraction, size, "No faction");
    return 1;
}

stock Spec_GetFamilyName(targetid, family[], size)
{
    if(PI[targetid][pFamily] > 0) format(family, size, "ID %d", PI[targetid][pFamily]);
    else format(family, size, "None");
    return 1;
}

stock Spec_GetVehicleText(targetid, vehicle[], size)
{
    new vehicleid = GetPlayerVehicleID(targetid);
    if(vehicleid > 0 && IsValidVehicle(vehicleid))
    {
        new Float:health;
        GetVehicleHealth(vehicleid, health);
        format(vehicle, size, "ID %d | model %d | %d HP", vehicleid, GetVehicleModel(vehicleid), floatround(health));
    }
    else format(vehicle, size, "None");
    return 1;
}

stock Spec_SendData(playerid)
{
    new targetid = g_SpecTarget[playerid];
    if(!g_SpecActive[playerid] || !Spec_IsTargetAllowed(playerid, targetid)) return 0;

    new Float:hp, Float:arm, Float:vx, Float:vy, Float:vz;
    new speed, role[12], fraction[32], family[32], vehicle[64];
    GetPlayerHealth(targetid, hp);
    GetPlayerArmour(targetid, arm);
    GetPlayerVelocity(targetid, vx, vy, vz);
    speed = floatround(floatsqroot(vx * vx + vy * vy + vz * vz) * 180.0);
    Spec_GetRole(targetid, role, sizeof role);
    Spec_GetFractionName(targetid, fraction, sizeof fraction);
    Spec_GetFamilyName(targetid, family, sizeof family);
    Spec_GetVehicleText(targetid, vehicle, sizeof vehicle);



    cef_emit_event(playerid, "spec:data",
        CEFINT(targetid),
        CEFSTR(PI[targetid][pName]),
        CEFSTR(role),
        CEFINT(floatround(hp)),
        CEFINT(floatround(arm)),
        CEFINT(PI[targetid][pLevel]),
        CEFSTR(fraction),
        CEFINT(PI[targetid][pFractionRank]),
        CEFSTR(family),
        CEFINT(PI[targetid][pWanted]),
        CEFINT(GetPlayerVirtualWorld(targetid)),
        CEFINT(speed),
        CEFINT(GetPlayerPing(targetid))
    );
    cef_emit_event(playerid, "spec:vehicle", CEFSTR(vehicle));
    cef_emit_event(playerid, "spec:freeze", CEFINT(_:g_SpecFrozen[targetid]));
    return 1;
}

forward Spec_SendDataTimer(playerid);
public Spec_SendDataTimer(playerid)
{
    if(!g_SpecActive[playerid]) return 0;
    if(g_SpecTarget[playerid] == INVALID_PLAYER_ID) return 1;
    if(!Spec_IsTargetAllowed(playerid, g_SpecTarget[playerid]))
    {
        new targetid = Spec_FindPlayer(playerid, g_SpecTarget[playerid], 1);
        if(targetid == INVALID_PLAYER_ID)
        {
            g_SpecTarget[playerid] = INVALID_PLAYER_ID;
            Spec_SendEmpty(playerid);
            return 1;
        }
        g_SpecTarget[playerid] = targetid;
        PlayerSpectatePlayer(playerid, targetid);
    }
    Spec_SendData(playerid);
    return 1;
}

stock Spec_CancelMove(playerid, bool:restoreTarget = true)
{
    new targetid = g_SpecMoveTarget[playerid];
    if(g_SpecMoveObject[playerid] != INVALID_OBJECT_ID)
    {
        DestroyObject(g_SpecMoveObject[playerid]);
        g_SpecMoveObject[playerid] = INVALID_OBJECT_ID;
    }
    if(restoreTarget && IsPlayerConnected(targetid))
    {
        if(g_SpecMoveWasFrozen[playerid]) TogglePlayerControllable(targetid, 0);
        else TogglePlayerControllable(targetid, 1);
    }
    g_SpecMoveTarget[playerid] = INVALID_PLAYER_ID;
    g_SpecMoveWasFrozen[playerid] = false;
    return 1;
}

stock Spec_Stop(playerid)
{
    if(g_SpecTimer[playerid] != -1)
    {
        KillTimer(g_SpecTimer[playerid]);
        g_SpecTimer[playerid] = -1;
    }
    Spec_CancelMove(playerid);
    if(IsPlayerConnected(playerid))
    {
        cef_focus_browser(playerid, SPEC_BROWSER, false);
        cef_hide_browser(playerid, SPEC_BROWSER, true);
        cef_always_listen_keys(playerid, SPEC_BROWSER, false);
        cef_emit_event(playerid, "game:showCursor", CEFINT(0));
        cef_destroy_browser(playerid, SPEC_BROWSER);
        TogglePlayerSpectating(playerid, false);
    }
    g_SpecActive[playerid] = false;
    g_SpecTarget[playerid] = INVALID_PLAYER_ID;
    g_SpecFilter[playerid] = -1;
    return 1;
}

stock Spec_ResetPlayer(playerid)
{
    if(g_SpecTimer[playerid] != -1)
    {
        KillTimer(g_SpecTimer[playerid]);
        g_SpecTimer[playerid] = -1;
    }
    g_SpecActive[playerid] = false;
    g_SpecTarget[playerid] = INVALID_PLAYER_ID;
    g_SpecFilter[playerid] = -1;
    g_SpecFrozen[playerid] = false;
    g_SpecPGMarked[playerid] = false;
    g_SpecMoveTarget[playerid] = INVALID_PLAYER_ID;
    g_SpecMoveObject[playerid] = INVALID_OBJECT_ID;
    g_SpecMoveWasFrozen[playerid] = false;
    return 1;
}

stock Spec_Start(playerid, targetid)
{
    if(!GetAdminLevel(playerid, 1)) return SendErr(playerid, messageUnknownCMD);
    if(!IsPlayerConnected(targetid) || !PT[targetid][pLogged] || targetid == playerid)
        return SendErr(playerid, "Player is unavailable.");

    if(g_SpecActive[playerid]) Spec_Stop(playerid);

    GetPlayerPos(playerid, g_SpecOriginX[playerid], g_SpecOriginY[playerid], g_SpecOriginZ[playerid]);
    g_SpecOriginVW[playerid] = GetPlayerVirtualWorld(playerid);
    g_SpecOriginInterior[playerid] = GetPlayerInterior(playerid);
    g_SpecTarget[playerid] = targetid;
    g_SpecFilter[playerid] = -1;
    g_SpecActive[playerid] = true;

    TogglePlayerSpectating(playerid, true);
    PlayerSpectatePlayer(playerid, targetid);
    cef_create_browser(playerid, SPEC_BROWSER, SPEC_CEF_LINK, false, true);
    cef_focus_browser(playerid, SPEC_BROWSER, true);
    cef_always_listen_keys(playerid, SPEC_BROWSER, true);
    g_SpecTimer[playerid] = SetTimerEx("Spec_SendDataTimer", 750, true, "i", playerid);
    return 1;
}

CMD:spec(playerid, params[])
{
    new id;
    if(sscanf(params, "i", id)) return SendErr(playerid, "Usage: /spec [playerid]");
    return Spec_Start(playerid, id);
}

CMD:recon(playerid, params[])
{
    new id;
    if(sscanf(params, "i", id)) return SendErr(playerid, "Usage: /recon [playerid]");
    return Spec_Start(playerid, id);
}

CMD:specoff(playerid, params[])
{
    #pragma unused params
    if(!g_SpecActive[playerid]) return SendErr(playerid, "SPEC is not active.");
    return Spec_Stop(playerid);
}

CMD:unspec(playerid, params[])
{
    #pragma unused params
    if(!g_SpecActive[playerid]) return SendErr(playerid, "SPEC is not active.");
    return Spec_Stop(playerid);
}

stock Spec_StartMove(playerid, targetid)
{
    new Float:x, Float:y, Float:z;
    Spec_CancelMove(playerid);
    GetPlayerPos(targetid, x, y, z);
    g_SpecMoveTarget[playerid] = targetid;
    g_SpecMoveWasFrozen[playerid] = g_SpecFrozen[targetid];
    g_SpecMoveObject[playerid] = CreateObject(1, x, y, z - 1.0, 0.0, 0.0, 0.0, 0.0);
    if(g_SpecMoveObject[playerid] == INVALID_OBJECT_ID)
    {
        g_SpecMoveTarget[playerid] = INVALID_PLAYER_ID;
        return Spec_ShowToast(playerid, "[SPEC] Could not create the move object.");
    }
    TogglePlayerControllable(targetid, 0);
    cef_focus_browser(playerid, SPEC_BROWSER, false);
    cef_emit_event(playerid, "game:showCursor", CEFINT(0));
    EditObject(playerid, g_SpecMoveObject[playerid]);
    Spec_ShowToast(playerid, "[SPEC] Move target: place the GTA object, then confirm.");
    return 1;
}

stock Spec_HandleEditObject(playerid, objectid, response, Float:fX, Float:fY, Float:fZ, Float:fRotX, Float:fRotY, Float:fRotZ)
{
    #pragma unused fRotX
    #pragma unused fRotY
    #pragma unused fRotZ
    if(objectid != g_SpecMoveObject[playerid]) return 0;

    new targetid = g_SpecMoveTarget[playerid];
    if(response == EDIT_RESPONSE_FINAL && IsPlayerConnected(targetid))
    {
        SetPlayerPos(targetid, fX, fY, fZ + 2.0);
        Spec_ShowToast(playerid, "[SPEC] Target position updated.");
    }
    else if(response == EDIT_RESPONSE_CANCEL)
    {
        Spec_ShowToast(playerid, "[SPEC] Move cancelled.");
    }
    else return 1;

    CancelEdit(playerid);
    Spec_CancelMove(playerid);
    if(g_SpecActive[playerid])
    {
        cef_focus_browser(playerid, SPEC_BROWSER, true);
        cef_always_listen_keys(playerid, SPEC_BROWSER, true);
        Spec_SendData(playerid);
    }
    return 1;
}

stock Spec_LoadNearestVehicle(playerid, targetid)
{
    if(IsPlayerInAnyVehicle(targetid)) return Spec_ShowToast(playerid, "[SPEC] Target is already in a vehicle.");

    new Float:px, Float:py, Float:pz;
    new Float:x, Float:y, Float:z;
    new nearest = INVALID_VEHICLE_ID;
    new Float:distance = 100000.0;
    GetPlayerPos(targetid, px, py, pz);
    for(new vehicleid = 1; vehicleid < MAX_VEHICLES; vehicleid++)
    {
        if(!IsValidVehicle(vehicleid)) continue;
        GetVehiclePos(vehicleid, x, y, z);
        new Float:current = GetDistanceBetweenCoords(px, py, pz, x, y, z);
        if(current < distance)
        {
            distance = current;
            nearest = vehicleid;
        }
    }
    if(nearest == INVALID_VEHICLE_ID) return Spec_ShowToast(playerid, "[SPEC] No vehicle exists for GRUZ.");

    PutPlayerInVehicle(targetid, nearest, 1);
    new text[96];
    format(text, sizeof text, "[SPEC] GRUZ: target placed into vehicle %d.", nearest);
    Spec_ShowToast(playerid, text);
    return 1;
}

stock Spec_ShowStats(playerid, targetid)
{
    new Float:hp, Float:arm;
    new vehicle[64], text[384];
    GetPlayerHealth(targetid, hp);
    GetPlayerArmour(targetid, arm);
    Spec_GetVehicleText(targetid, vehicle, sizeof vehicle);
    format(text, sizeof text,
        "ID: %d\nName: %s\nLevel: %d\nHealth: %d\nArmour: %d\nMoney: $%d\nBank: $%d\nVehicle: %s\nPing: %d ms",
        targetid, PI[targetid][pName], PI[targetid][pLevel], floatround(hp), floatround(arm),
        PI[targetid][pCash], PI[targetid][pBank], vehicle, GetPlayerPing(targetid));
    Spec_ShowInfo(playerid, "SPEC / STATS", text);
    return 1;
}

stock Spec_ShowGetInfo(playerid, targetid)
{
    new fraction[32], family[32], text[512];
    Spec_GetFractionName(targetid, fraction, sizeof fraction);
    Spec_GetFamilyName(targetid, family, sizeof family);
    format(text, sizeof text,
        "ID: %d\nName: %s\nAccount ID: %d\nAdmin level: %d\nLeader: %d\nFraction: %s\nRank: %d\nFamily: %s\nSkin: %d\nLegality: %d\nAFK: %d sec",
        targetid, PI[targetid][pName], PI[targetid][pID], PI[targetid][pAdmin], PI[targetid][pLeader],
        fraction, PI[targetid][pFractionRank], family, GetPlayerSkin(targetid), PI[targetid][pLegality], PI[targetid][pAFK]);
    Spec_ShowInfo(playerid, "SPEC / GETINFO", text);
    return 1;
}

stock Spec_ShowPunishInfo(playerid, targetid)
{
    new muted[16], frozen[4], pgmark[4], text[384];
    if(PT[targetid][pMuteTime] > 0) format(muted, sizeof muted, "%d sec", PT[targetid][pMuteTime]);
    else format(muted, sizeof muted, "No");
    if(g_SpecFrozen[targetid]) format(frozen, sizeof frozen, "Yes");
    else format(frozen, sizeof frozen, "No");
    if(g_SpecPGMarked[targetid]) format(pgmark, sizeof pgmark, "Yes");
    else format(pgmark, sizeof pgmark, "No");
    format(text, sizeof text,
        "ID: %d\nName: %s\nWarnings: %d\nSuspended: %d\nWanted level: %d\nMuted: %s\nFrozen by SPEC: %s\nPG mark: %s",
        targetid, PI[targetid][pName], PI[targetid][pWarns], PI[targetid][pSuspended], PI[targetid][pWanted], muted,
        frozen, pgmark);
    Spec_ShowInfo(playerid, "SPEC / INFOPUNISH", text);
    return 1;
}

stock Spec_ShowTime(playerid, targetid)
{
    new hour, minute, second, year, month, day, text[256];
    gettime(hour, minute, second);
    getdate(year, month, day);
    format(text, sizeof text,
        "Server date: %02d.%02d.%d\nServer time: %02d:%02d:%02d\nTarget AFK: %d sec\nPing: %d ms",
        day, month, year, hour, minute, second, PI[targetid][pAFK], GetPlayerPing(targetid));
    Spec_ShowInfo(playerid, "SPEC / TIME", text);
    return 1;
}

stock Spec_OnPlayerDisconnect(leaverid)
{
    if(g_SpecMoveTarget[leaverid] != INVALID_PLAYER_ID) Spec_CancelMove(leaverid);
    if(g_SpecTimer[leaverid] != -1)
    {
        KillTimer(g_SpecTimer[leaverid]);
        g_SpecTimer[leaverid] = -1;
    }
    g_SpecActive[leaverid] = false;
    g_SpecTarget[leaverid] = INVALID_PLAYER_ID;
    g_SpecMoveTarget[leaverid] = INVALID_PLAYER_ID;
    g_SpecMoveObject[leaverid] = INVALID_OBJECT_ID;
    g_SpecFrozen[leaverid] = false;
    g_SpecPGMarked[leaverid] = false;

    for(new playerid = 0; playerid < MAX_PLAYERS; playerid++)
    {
        if(!IsPlayerConnected(playerid) || playerid == leaverid) continue;
        if(g_SpecMoveTarget[playerid] == leaverid) Spec_CancelMove(playerid, false);
        if(g_SpecActive[playerid] && g_SpecTarget[playerid] == leaverid)
        {
            Spec_ShowToast(playerid, "[SPEC] Target disconnected. Spectate closed.");
            Spec_Stop(playerid);
        }
    }
    return 1;
}

callback::OnSpecReady(playerid, const arguments[])
{
    #pragma unused arguments
    Spec_SendData(playerid);
    Spec_SendFilterCount(playerid);
    return 1;
}

callback::OnSpecNavigate(playerid, const arguments[])
{
    new direction = strval(arguments);
    if(direction != -1 && direction != 1) return 1;
    if(!g_SpecActive[playerid]) return 1;

    new targetid = Spec_FindPlayer(playerid, g_SpecTarget[playerid], direction);
    if(targetid == INVALID_PLAYER_ID)
    {
        Spec_ShowToast(playerid, "[SPEC] No available players in this filter.");
        return 1;
    }
    g_SpecTarget[playerid] = targetid;
    PlayerSpectatePlayer(playerid, targetid);
    Spec_SendData(playerid);
    return 1;
}

callback::OnSpecFilter(playerid, const arguments[])
{
    new filterid = strval(arguments);
    if(!g_SpecActive[playerid]) return 1;
    if(filterid < -1 || filterid >= MAX_FRACTIONS) return 1;

    g_SpecFilter[playerid] = filterid;
    Spec_SendFilterCount(playerid);
    if(Spec_IsTargetAllowed(playerid, g_SpecTarget[playerid]))
    {
        Spec_SendData(playerid);
        return 1;
    }

    new targetid = Spec_FindPlayer(playerid, g_SpecTarget[playerid], 1);
    if(targetid == INVALID_PLAYER_ID)
    {
        g_SpecTarget[playerid] = INVALID_PLAYER_ID;
        Spec_ShowToast(playerid, "[SPEC] No online players in this fraction.");
        Spec_SendEmpty(playerid);
        return 1;
    }
    g_SpecTarget[playerid] = targetid;
    PlayerSpectatePlayer(playerid, targetid);
    Spec_SendData(playerid);
    return 1;
}

callback::OnSpecAction(playerid, const arguments[])
{
    new action[24], targetid;
    if(sscanf(arguments, "s[24]i", action, targetid)) return 1;
    if(!GetAdminLevel(playerid, 1) || !g_SpecActive[playerid]) return 1;

    if(!strcmp(action, "EXIT", true)) return Spec_Stop(playerid);
    if(targetid != g_SpecTarget[playerid] || !Spec_IsTargetAllowed(playerid, targetid)) return 1;

    new Float:x, Float:y, Float:z;
    if(!strcmp(action, "MOVE", true)) Spec_StartMove(playerid, targetid);
    else if(!strcmp(action, "FLIP", true))
    {
        new vehicleid = GetPlayerVehicleID(targetid);
        if(vehicleid > 0 && IsValidVehicle(vehicleid))
        {
            GetVehiclePos(vehicleid, x, y, z);
            SetVehiclePos(vehicleid, x, y, z + 0.5);
            SetVehicleZAngle(vehicleid, 0.0);
            Spec_ShowToast(playerid, "[SPEC] Vehicle flipped upright.");
        }
        else Spec_ShowToast(playerid, "[SPEC] Target is not in a vehicle.");
    }
    else if(!strcmp(action, "GRUZ", true)) Spec_LoadNearestVehicle(playerid, targetid);
    else if(!strcmp(action, "FIXVEH", true))
    {
        new vehicleid = GetPlayerVehicleID(targetid);
        if(vehicleid > 0 && IsValidVehicle(vehicleid))
        {
            RepairVehicle(vehicleid);
            Spec_ShowToast(playerid, "[SPEC] Vehicle repaired.");
        }
        else Spec_ShowToast(playerid, "[SPEC] Target is not in a vehicle.");
    }
    else if(!strcmp(action, "STATS", true)) Spec_ShowStats(playerid, targetid);
    else if(!strcmp(action, "GETINFO", true)) Spec_ShowGetInfo(playerid, targetid);
    else if(!strcmp(action, "INFOPUNISH", true)) Spec_ShowPunishInfo(playerid, targetid);
    else if(!strcmp(action, "TIME", true)) Spec_ShowTime(playerid, targetid);
    else if(!strcmp(action, "GET", true))
    {
        SetPlayerVirtualWorld(targetid, g_SpecOriginVW[playerid]);
        SetPlayerInterior(targetid, g_SpecOriginInterior[playerid]);
        SetPlayerPos(targetid, g_SpecOriginX[playerid] + 1.0, g_SpecOriginY[playerid], g_SpecOriginZ[playerid]);
        Spec_ShowToast(playerid, "[SPEC] Target moved to your pre-spectate position.");
    }
    else if(!strcmp(action, "UP", true))
    {
        GetPlayerPos(targetid, x, y, z);
        SetPlayerPos(targetid, x, y, z + 2.0);
        Spec_ShowToast(playerid, "[SPEC] Target moved up by 2 meters.");
    }
    else if(!strcmp(action, "DOWN", true))
    {
        GetPlayerPos(targetid, x, y, z);
        SetPlayerPos(targetid, x, y, z - 2.0);
        Spec_ShowToast(playerid, "[SPEC] Target moved down by 2 meters.");
    }
    else if(!strcmp(action, "GOTO", true))
    {
        GetPlayerPos(targetid, x, y, z);
        new worldid = GetPlayerVirtualWorld(targetid);
        new interiorid = GetPlayerInterior(targetid);
        Spec_Stop(playerid);
        SetPlayerVirtualWorld(playerid, worldid);
        SetPlayerInterior(playerid, interiorid);
        SetPlayerPos(playerid, x + 1.0, y, z);
        return 1;
    }
    else if(!strcmp(action, "SPAWN", true))
    {
        SpawnPlayerEx(targetid);
        UpdatePlayerTag(targetid);
        SyncTagPanelAccess(targetid);
        g_SpecFrozen[targetid] = false;
        Spec_ShowToast(playerid, "[SPEC] Target spawned.");
    }
    else if(!strcmp(action, "FREEZE", true))
    {
        TogglePlayerControllable(targetid, 0);
        g_SpecFrozen[targetid] = true;
        cef_emit_event(playerid, "spec:freeze", CEFINT(1));
        Spec_ShowToast(playerid, "[SPEC] Target frozen.");
    }
    else if(!strcmp(action, "UNFREEZE", true))
    {
        TogglePlayerControllable(targetid, 1);
        g_SpecFrozen[targetid] = false;
        cef_emit_event(playerid, "spec:freeze", CEFINT(0));
        Spec_ShowToast(playerid, "[SPEC] Target unfrozen.");
    }
    else if(!strcmp(action, "NICK", true))
    {
        new text[160];
        format(text, sizeof text, "Nickname: %s | ID: %d", PI[targetid][pName], targetid);
        Spec_ShowInfo(playerid, "SPEC / NICK", text);
    }
    else if(!strcmp(action, "DELGUN", true))
    {
        ResetPlayerWeapons(targetid);
        Spec_ShowToast(playerid, "[SPEC] Target weapons removed.");
    }
    else if(!strcmp(action, "PG", true))
    {
        g_SpecPGMarked[targetid] = !g_SpecPGMarked[targetid];
        if(g_SpecPGMarked[targetid]) Spec_ShowToast(playerid, "[SPEC] PG review mark enabled.");
        else Spec_ShowToast(playerid, "[SPEC] PG review mark removed.");
    }
    else return 1;

    Spec_SendData(playerid);
    return 1;
}
