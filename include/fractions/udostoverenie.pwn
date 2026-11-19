#if defined _UDO_SYSTEM_INCLUDED
    #endinput
#endif
#define _UDO_SYSTEM_INCLUDED

#define UDO_VIEW_RANGE 5.0


new g_UdoOwner[MAX_PLAYERS] = {INVALID_PLAYER_ID, ...};

stock bool:Udo_CanShow(playerid)
{
    new fraction = PI[playerid][pFraction];
    return fraction == FRACTION_FSB
        || fraction == FRACTION_TRAFFIC_PATROL_POLICE
        || fraction == FRACTION_PATROL_POLICE
        || fraction == FRACTION_MILITARY;
}

stock bool:Udo_CanView(viewer, owner)
{
    if(!IsPlayerConnected(viewer) || !IsPlayerConnected(owner)) return false;
    if(!PT[viewer][pLogged] || !PT[owner][pLogged]) return false;
    if(GetPlayerVirtualWorld(viewer) != GetPlayerVirtualWorld(owner)) return false;
    if(GetPlayerInterior(viewer) != GetPlayerInterior(owner)) return false;
    if(GetDistBetweenPlayers(viewer, owner) > UDO_VIEW_RANGE) return false;
    return true;
}

stock Udo_GetRankName(playerid, dest[], size)
{
    new fraction = PI[playerid][pFraction];
    new rankIndex = PI[playerid][pFractionRank] - 1;

    if(rankIndex >= 0 && rankIndex < Fraction[fraction][fMax_ranks])
        format(dest, size, "%s", Fraction_Rank[fraction][rankIndex]);
    else
        format(dest, size, "-");
    return 1;
}

stock Udo_GetDepartmentName(playerid, dest[], size)
{
    GetOtdelName(PI[playerid][pFraction], g_PlayerOtdelID[playerid], dest, size);
    if(!strlen(dest)) format(dest, size, "No department");
    return 1;
}

stock Udo_EscapeJson(dest[], size, const source[])
{
    new writePos = 0;
    for(new readPos = 0; source[readPos] != EOS && writePos < size - 1; readPos++)
    {
        new character = source[readPos];
        if(character == '"' || character == '\\')
        {
            if(writePos >= size - 2) break;
            dest[writePos++] = '\\';
        }
        if(character == '\n' || character == '\r' || character == '\t')
            dest[writePos++] = ' ';
        else
            dest[writePos++] = character;
    }
    dest[writePos] = EOS;
    return 1;
}

stock OpenUdoCEFForOwner(viewer, owner)
{
    if(!IsPlayerConnected(viewer) || !IsPlayerConnected(owner)) return 0;
    if(!Udo_CanShow(owner)) return 0;
    g_UdoOwner[viewer] = owner;
    if(!CEF_LiveUdo(viewer, owner)) return 0;
    return 1;
}

stock CloseUdoCEF(playerid)
{
    if(IsPlayerConnected(playerid))
    {
        cef_focus_browser(playerid, UDO_BROWSER, false);
        cef_hide_browser(playerid, UDO_BROWSER, true);
        cef_always_listen_keys(playerid, UDO_BROWSER, false);
        cef_emit_event(playerid, "game:showCursor", CEFINT(0));
        cef_destroy_browser(playerid, UDO_BROWSER);
        TogglePlayerControllable(playerid, 1);
    }
    g_UdoOwner[playerid] = INVALID_PLAYER_ID;
    return 1;
}

forward UdoCEFReady(playerid);
public UdoCEFReady(playerid)
{
    if(!IsPlayerConnected(playerid)) return 1;

    new owner = g_UdoOwner[playerid];
    if(!IsPlayerConnected(owner) || !PT[owner][pLogged] || !Udo_CanShow(owner))
    {
        CloseUdoCEF(playerid);
        return 1;
    }
    if(playerid != owner && !Udo_CanView(playerid, owner))
    {
        CloseUdoCEF(playerid);
        return 1;
    }

    new rankName[64];
    new departmentName[64];
    new fractionName[64];
    new safeName[64];
    new safeRank[128];
    new safeDepartment[128];
    new safePosition[128];
    new documentNumber[16];
    new personalNumber[16];
    new position[64];

    Udo_GetRankName(owner, rankName, sizeof(rankName));
    Udo_GetDepartmentName(owner, departmentName, sizeof(departmentName));
    format(fractionName, sizeof(fractionName), "%s", Fraction[PI[owner][pFraction]][fName]);
    format(position, sizeof(position), "%s", fractionName);
    format(documentNumber, sizeof(documentNumber), "%06d", PI[owner][pID]);
    format(personalNumber, sizeof(personalNumber), "%d", PI[owner][pID]);

    Udo_EscapeJson(safeName, sizeof(safeName), PI[owner][pName]);
    Udo_EscapeJson(safeRank, sizeof(safeRank), rankName);
    Udo_EscapeJson(safeDepartment, sizeof(safeDepartment), departmentName);
    Udo_EscapeJson(safePosition, sizeof(safePosition), position);

    new json[768];
    format(json, sizeof(json),
        "{\"fraction\":%d,\"name\":\"%s\",\"documentId\":\"%s\",\"personalId\":\"%s\",\"rank\":\"%s\",\"department\":\"%s\",\"position\":\"%s\",\"skin\":%d,\"expiration\":\"Valid while employed\",\"signature\":\"amz\"}",
        PI[owner][pFraction], safeName, documentNumber, personalNumber,
        safeRank, safeDepartment, safePosition, GetPlayerSkin(owner));
    cef_emit_event(playerid, "udo:show", CEFSTR(json));
    return 1;
}

callback::OnUdoReady(playerid, const arguments[])
{
    #pragma unused arguments
    SetTimerEx("UdoCEFReady", 150, false, "i", playerid);
    return 1;
}

callback::OnUdoClose(playerid, const arguments[])
{
    #pragma unused arguments
    CloseUdoCEF(playerid);
    return 1;
}

stock Udo_OnPlayerConnect(playerid)
{
    g_UdoOwner[playerid] = INVALID_PLAYER_ID;
    return 1;
}

stock Udo_OnPlayerDisconnect(playerid)
{
    for(new viewer = 0; viewer < MAX_PLAYERS; viewer++)
    {
        if(g_UdoOwner[viewer] == playerid)
            CloseUdoCEF(viewer);
    }
    g_UdoOwner[playerid] = INVALID_PLAYER_ID;
    return 1;
}

CMD:udo(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;
    if(!Udo_CanShow(playerid))
        return SendErr(playerid, "Only FSB and MVD officers can show a service ID.");


    if(!strlen(params))
    {
        if(!OpenUdoCEFForOwner(playerid, playerid))
            return SendErr(playerid, "CEF is required to view the service ID.");
        return 1;
    }

    new targetid;
    if(sscanf(params, "u", targetid))
        return SendErr(playerid, "Usage: /udo [playerid]");
    if(!IsPlayerConnected(targetid) || !PT[targetid][pLogged] || targetid == playerid)
        return SendErr(playerid, "Player is unavailable.");
    if(!Udo_CanView(playerid, targetid))
        return SendErr(playerid, "The player is too far away.");
    if(!cef_player_has_plugin(targetid) || !PT[targetid][pCefLoaded])
        return SendErr(playerid, "The player does not have CEF enabled.");
    if(!OpenUdoCEFForOwner(targetid, playerid))
        return SendErr(playerid, "Could not open the service ID for this player.");

    ApplyAnimation(playerid, "PED", "show_docs", 4.1, 0, 0, 0, 0, 0, 1);

    new message[144];
    format(message, sizeof(message), "You showed your service ID to %s[%d].", PI[targetid][pName], targetid);
    SendClientMessage(playerid, COLOR_GRAY, message);
    format(message, sizeof(message), "%s[%d] showed you a service ID.", PI[playerid][pName], playerid);
    SendClientMessage(targetid, COLOR_GRAY, message);
    return 1;
}
