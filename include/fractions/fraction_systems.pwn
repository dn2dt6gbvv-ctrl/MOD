#if defined _FRACTION_SYSTEMS_INCLUDED
    #endinput
#endif
#define _FRACTION_SYSTEMS_INCLUDED

new g_LpanelFrac[MAX_PLAYERS];

stock Surrender_CreatePickup()
{
    CreateDynamicPickup(1239, 23, 1550.2175, 807.8856, 1901.2372);
    CreateDynamicSphere(1550.2175, 807.8856, 1901.2372, 2.0);
}
stock Surrender_Open(playerid)
{
    if(!PT[playerid][pLogged]) return;
    if(PI[playerid][pWanted] <= 0) {
        CEFChat_Send(playerid, "AAAAAA", "У вас нет розыска.");
        return;
    }
    new stars = PI[playerid][pWanted];
    new totalMinutes = stars * SURRENDER_MINUTES_PER_STAR;
    new newMinutes = (stars >= 3) ? (totalMinutes - totalMinutes / 3) : totalMinutes;
    new info[640];
    format(info, sizeof(info),
        "Здесь можно добровольно сообщить о совершённом преступлении.\nЯвка с повинной даёт возможность смягчить наказание. При розыске 3+ уровней снимается {e69348}1/3 времени заключения{FFFFFF}.\n\nРозыск: {e69348}%d зв.{FFFFFF} | Время: {e69348}%d мин.{FFFFFF} | После явки: {e69348}%d мин.{FFFFFF}\n\nЕсли готовы - нажмите ДА",
        stars, totalMinutes, newMinutes);
    ShowPlayerDialogEx(playerid, 4401, DIALOG_STYLE_MSGBOX, "ЯВКА С ПОВИННОЙ", info, "ДА", "ЗАКРЫТЬ");
}

stock Surrender_Handle(playerid, response)
{
    if(!response) return;
    new stars = PI[playerid][pWanted];
    if(stars <= 0) return;
    new totalSec = stars * SURRENDER_MINUTES_PER_STAR * 60;
    new newSec = (stars >= 3) ? (totalSec - totalSec / 3) : totalSec;

    new kpz = random(3);
    SetPlayerPos(playerid, g_KPZPoints[kpz][0], g_KPZPoints[kpz][1], g_KPZPoints[kpz][2]);
    SetPlayerFacingAngle(playerid, g_KPZPoints[kpz][3]);
    SetPlayerVirtualWorld(playerid, 0);
    SetPlayerInterior(playerid, 0);
    SetCameraBehindPlayer(playerid);

    g_ArrestTime[playerid] = newSec;
    g_IsArrested[playerid] = true;
    g_ArrestOfficer[playerid] = -1;

    PI[playerid][pWanted] = 0;
    SetPlayerWantedLevel(playerid, 0);

    new query[128];
    mysql_format(dbHandle, query, sizeof(query),
        "UPDATE `accounts` SET `arrest_time`=%d, `wanted`=0 WHERE `id`=%d",
        newSec, PI[playerid][pID]);
    mysql_tquery(dbHandle, query, "", "");

    new msg[128];
    format(msg, sizeof(msg), "Явка принята. Срок заключения: %d мин.", newSec / 60);
    CEFChat_Send(playerid, "54B367", msg);
}

stock Beacon_OnEdit(playerid, response, objectid, Float:fX, Float:fY, Float:fZ, Float:fRotX, Float:fRotY, Float:fRotZ)
{
    if(!g_BeaconEditing[playerid]) return;
    if(objectid != g_BeaconObject[playerid]) return;
    if(response == EDIT_RESPONSE_CANCEL) {
        g_BeaconEditing[playerid] = false;
        CEFChat_Send(playerid, "FF4444", "Редактирование отменено.");
        return;
    }
    if(response == EDIT_RESPONSE_FINAL) {
        g_BeaconEditing[playerid] = false;
        new vehicleid = g_BeaconCarID[playerid];
        if(vehicleid == -1) return;
        new Float:vx, Float:vy, Float:vz;
        GetVehiclePos(vehicleid, vx, vy, vz);
        g_BeaconPos[playerid][0] = fX - vx;
        g_BeaconPos[playerid][1] = fY - vy;
        g_BeaconPos[playerid][2] = fZ - vz;
        AttachObjectToVehicle(g_BeaconObject[playerid], vehicleid,
            g_BeaconPos[playerid][0], g_BeaconPos[playerid][1], g_BeaconPos[playerid][2],
            fRotX, fRotY, fRotZ);
        new query[192];
        mysql_format(dbHandle, query, sizeof(query),
            "INSERT INTO `beacon_positions` (`player_id`,`ox`,`oy`,`oz`) VALUES (%d,%f,%f,%f) ON DUPLICATE KEY UPDATE `ox`=%f,`oy`=%f,`oz`=%f",
            PI[playerid][pID],
            g_BeaconPos[playerid][0], g_BeaconPos[playerid][1], g_BeaconPos[playerid][2],
            g_BeaconPos[playerid][0], g_BeaconPos[playerid][1], g_BeaconPos[playerid][2]);
        mysql_tquery(dbHandle, query, "", "");
        CEFChat_Send(playerid, "54B367", "Позиция мигалки сохранена.");
    }
}

stock LoadBeaconPos(playerid)
{
    new query[64];
    mysql_format(dbHandle, query, sizeof(query),
        "SELECT `ox`,`oy`,`oz` FROM `beacon_positions` WHERE `player_id`=%d LIMIT 1",
        PI[playerid][pID]);
    mysql_tquery(dbHandle, query, "OnBeaconPosLoaded", "i", playerid);
}

forward OnBeaconPosLoaded(playerid);
public OnBeaconPosLoaded(playerid)
{
    if(!IsPlayerConnected(playerid)) return 1;
    if(!cache_num_rows()) return 1;
    new Float:ox, Float:oy, Float:oz;
    cache_get_value_name_float(0, "ox", ox);
    cache_get_value_name_float(0, "oy", oy);
    cache_get_value_name_float(0, "oz", oz);
    g_BeaconPos[playerid][0] = ox;
    g_BeaconPos[playerid][1] = oy;
    g_BeaconPos[playerid][2] = oz;
    return 1;
}

cmd:beacon(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;
    if(PI[playerid][pFraction] != FRACTION_FSB) return SendErr(playerid, "Только для ФСБ.");
    if(!PT[playerid][pDuty]) return SendErr(playerid, "Вы должны быть на дежурстве.");
    if(!IsPlayerInAnyVehicle(playerid)) return SendErr(playerid, "Вы должны быть в машине.");
    new vehicleid = GetPlayerVehicleID(playerid);
    if(g_BeaconActive[playerid]) {
        if(g_BeaconObject[playerid] != -1) {
            DestroyObject(g_BeaconObject[playerid]);
            g_BeaconObject[playerid] = -1;
        }
        g_BeaconActive[playerid] = false;
        g_BeaconCarID[playerid] = -1;
        CEFChat_Send(playerid, "AAAAAA", "Мигалка выключена.");
        return 1;
    }
    new Float:x, Float:y, Float:z;
    GetVehiclePos(vehicleid, x, y, z);
    new Float:px = (g_BeaconPos[playerid][0] == 0.0) ? 0.0 : g_BeaconPos[playerid][0];
    new Float:py = (g_BeaconPos[playerid][1] == 0.0) ? 0.3 : g_BeaconPos[playerid][1];
    new Float:pz = (g_BeaconPos[playerid][2] == 0.0) ? 0.7 : g_BeaconPos[playerid][2];
    new Float:a;
    GetVehicleZAngle(vehicleid, a);
    g_BeaconObject[playerid] = CreateObject(BEACON_OBJECT_ID, x+px, y+py, z+pz, 0.0, 0.0, a);
    AttachObjectToVehicle(g_BeaconObject[playerid], vehicleid, px, py, pz, 0.0, 0.0, 0.0);
    g_BeaconActive[playerid] = true;
    g_BeaconCarID[playerid] = vehicleid;
    CEFChat_Send(playerid, "54B367", "Мигалка включена. /beacon_edit — настройка позиции.");
    return 1;
}

cmd:beacon_edit(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;
    if(PI[playerid][pFraction] != FRACTION_FSB) return SendErr(playerid, "Только для ФСБ.");
    if(!g_BeaconActive[playerid] || g_BeaconObject[playerid] == -1)
        return SendErr(playerid, "Сначала включите мигалку: /beacon");


    new vehicleid = g_BeaconCarID[playerid];
    new Float:vx, Float:vy, Float:vz;
    GetVehiclePos(vehicleid, vx, vy, vz);
    SetObjectPos(g_BeaconObject[playerid],
        vx + g_BeaconPos[playerid][0],
        vy + g_BeaconPos[playerid][1],
        vz + g_BeaconPos[playerid][2]);

    EditObject(playerid, g_BeaconObject[playerid]);
    g_BeaconEditing[playerid] = true;
    CEFChat_Send(playerid, "AAAAAA", "Настройте позицию. ENTER — сохранить, ESC — отмена.");
    return 1;
}

cmd:leadergift(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;
    if(PI[playerid][pFraction] != FRACTION_GOVERMENT)
        return SendErr(playerid, "Только для Правительства области.");
    if(PI[playerid][pLeader] != 1)
        return SendErr(playerid, "Только для губернатора.");
    new name[32], reason[64];
    if(sscanf(params, "s[32]s[64]", name, reason))
        return SendErr(playerid, "Использование: /leadergift [ник] [название премии]");
    new targetid = -1;
    foreach(new i : Player) {
        if(!PT[i][pLogged]) continue;
        if(!strcmp(PI[i][pName], name, true)) { targetid = i; break; }
    }
    if(targetid == -1) return SendErr(playerid, "Игрок не найден или не онлайн.");
    PI[targetid][pCash] += LEADER_GIFT_AMOUNT;
    new query[96];
    mysql_format(dbHandle, query, sizeof(query),
        "UPDATE `accounts` SET `cash`=%d WHERE `id`=%d",
        PI[targetid][pCash], PI[targetid][pID]);
    mysql_tquery(dbHandle, query, "", "");
    new announce[256];
    format(announce, sizeof(announce),
        "Губернатор %s наградил(а) %s премией «%s».",
        GetName(playerid), name, reason, LEADER_GIFT_AMOUNT);
    foreach(new i : Player) {
        if(PT[i][pLogged]) SendClientMessage(i, GOV_COLOR, announce);
    }
    return 1;
}

cmd:gov(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;
    new frac = PI[playerid][pFraction];
    if(frac < 1 || frac > 6)
        return SendErr(playerid, "Команда доступна только государственным организациям.");
    if(isnull(params))
        return SendErr(playerid, "Использование: /gov [текст]");
    new msg[256];
    format(msg, sizeof(msg), "%s: %s", GetName(playerid), params);
    foreach(new i : Player) {
        if(PT[i][pLogged]) CEFChat_Send(i, "1A237E", msg);
    }
    return 1;
}

cmd:get(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;
    new frac = PI[playerid][pFraction];
    if(frac < 2 || frac > 6)
        return SendErr(playerid, "{F8FAFA}Команда не обнаружена! {F8FAFA}Используйте {FF9900}/menu{F8FAFA} для просмотра команд.");
    if(!PT[playerid][pDuty])
        return SendErr(playerid, "Вы должны быть на дежурстве.");
    if(!IsPlayerInAnyVehicle(playerid))
        return SendErr(playerid, "Вы должны быть в машине.");
    new targetid;
    if(sscanf(params, "u", targetid))
        return SendErr(playerid, "Использование: /get [ID]");
    if(!IsPlayerConnected(targetid))
        return SendErr(playerid, "Игрок не найден.");
    if(!ProxDetectorS(10.0, playerid, targetid))
        return SendErr(playerid, "Игрок слишком далеко.");
    new vehicleid = GetPlayerVehicleID(playerid);
    new seat = 1;
    for(new s = 1; s <= 3; s++) {
        new bool:taken = false;
        foreach(new p : Player) {
            if(GetPlayerVehicleID(p) == vehicleid && GetPlayerVehicleSeat(p) == s) {
                taken = true;
                break;
            }
        }
        if(!taken) { seat = s; break; }
    }
    PutPlayerInVehicle(targetid, vehicleid, seat);
    new msg[64];
    format(msg, sizeof(msg), "Вас посадили в машину сотрудника %s.", GetName(playerid));
    CEFChat_Send(targetid, "FF8C00", msg);
    format(msg, sizeof(msg), "Вы посадили %s в машину.", GetName(targetid));
    CEFChat_Send(playerid, "AAAAAA", msg);
    return 1;
}

stock CanLpanel(playerid)
{
    if(PI[playerid][pLeader] == 1) return true;
    new frac = PI[playerid][pFraction];
    if(frac == FRACTION_FSB && PI[playerid][pFractionRank] >= 4) return true;
    if(frac == FRACTION_GOVERMENT && PI[playerid][pFractionRank] >= 7) return true;
    return false;
}

stock OpenLPanel(playerid)
{
    if(!cef_player_has_plugin(playerid)) return;
    if(!PT[playerid][pCefLoaded]) return;
    g_LpanelFrac[playerid] = PI[playerid][pFraction];
    cef_create_browser(playerid, LPANEL_BROWSER, LPANEL_CEF_LINK, false, true);
    cef_focus_browser(playerid, LPANEL_BROWSER, true);
    cef_always_listen_keys(playerid, LPANEL_BROWSER, true);
    TogglePlayerControllable(playerid, 0);
    SetTimerEx("LPanelReady", 400, false, "i", playerid);
}

stock CloseLPanel(playerid)
{
    cef_focus_browser(playerid, LPANEL_BROWSER, false);
    cef_hide_browser(playerid, LPANEL_BROWSER, true);
    cef_destroy_browser(playerid, LPANEL_BROWSER);
    TogglePlayerControllable(playerid, 1);
}

forward LPanelReady(playerid);
public LPanelReady(playerid)
{
    if(!IsPlayerConnected(playerid)) return 1;
    new frac = g_LpanelFrac[playerid];
    new json[64];
    format(json, sizeof(json), "{\"frac\":%d}", frac);
    cef_emit_event(playerid, "lpanel:open", CEFSTR(json));
    return 1;
}

cmd:lpanel(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;
    if(!CanLpanel(playerid))
        return SendErr(playerid, "У вас нет доступа к панели лидера.");
    OpenLPanel(playerid);
    return 1;
}

callback::OnLPanelClose(playerid, const arguments[])
{
    CloseLPanel(playerid);
    return 1;
}

callback::OnLPanelFire(playerid, const arguments[])
{
    new tmp[256];
    format(tmp, sizeof(tmp), "%s", arguments);
    new name[32], reason[64];
    new pos = strfind(tmp, "\"name\":\"");
    if(pos == -1) return 1;
    pos += 8;
    new end = strfind(tmp, "\"", false, pos);
    if(end == -1) return 1;
    strmid(name, tmp, pos, end, sizeof(name));
    pos = strfind(tmp, "\"reason\":\"");
    if(pos != -1) {
        pos += 10;
        end = strfind(tmp, "\"", false, pos);
        if(end != -1) strmid(reason, tmp, pos, end, sizeof(reason));
    }
    new targetid = -1;
    foreach(new i : Player) {
        if(!PT[i][pLogged]) continue;
        if(!strcmp(PI[i][pName], name, true)) { targetid = i; break; }
    }
    if(targetid == -1) {
        cef_emit_event(playerid, "lpanel:result", CEFSTR("{\"error\":\"Игрок не найден или не онлайн\"}"));
        return 1;
    }
    new frac = PI[playerid][pFraction];
    if(PI[targetid][pFraction] != frac) {
        cef_emit_event(playerid, "lpanel:result", CEFSTR("{\"error\":\"Игрок не в вашей организации\"}"));
        return 1;
    }
    if(PI[targetid][pFractionRank] >= PI[playerid][pFractionRank] && PI[playerid][pLeader] != 1) {
        cef_emit_event(playerid, "lpanel:result", CEFSTR("{\"error\":\"Нельзя уволить равного или выше\"}"));
        return 1;
    }
    new oldRank = PI[targetid][pFractionRank];
    WB_AddRecord(targetid, WB_ACTION_FIRE, oldRank, 0, reason, GetName(playerid));
    PI[targetid][pFraction]     = 0;
    PI[targetid][pFractionRank] = 0;
    PI[targetid][pFractionSkin] = 0;
    SetPlayerSkin(targetid, PI[targetid][pSkin]);
    new query[128];
    mysql_format(dbHandle, query, sizeof(query),
        "UPDATE `accounts` SET `fraction`=0,`fraction_rank`=0,`fraction_skin`=0 WHERE `id`=%d",
        PI[targetid][pID]);
    mysql_tquery(dbHandle, query, "", "");
    new msg[128];
    format(msg, sizeof(msg), "Вас уволили. Причина: %s", reason);
    CEFChat_Send(targetid, "FF4444", msg);
    cef_emit_event(playerid, "lpanel:result", CEFSTR("{\"ok\":1}"));
    return 1;
}

callback::OnLPanelWarn(playerid, const arguments[])
{
    new tmp[256];
    format(tmp, sizeof(tmp), "%s", arguments);
    new name[32], reason[64];
    new pos = strfind(tmp, "\"name\":\"");
    if(pos == -1) return 1;
    pos += 8;
    new end = strfind(tmp, "\"", false, pos);
    if(end == -1) return 1;
    strmid(name, tmp, pos, end, sizeof(name));
    pos = strfind(tmp, "\"reason\":\"");
    if(pos != -1) {
        pos += 10;
        end = strfind(tmp, "\"", false, pos);
        if(end != -1) strmid(reason, tmp, pos, end, sizeof(reason));
    }
    new targetid = -1;
    foreach(new i : Player) {
        if(!PT[i][pLogged]) continue;
        if(!strcmp(PI[i][pName], name, true)) { targetid = i; break; }
    }
    if(targetid == -1) {
        cef_emit_event(playerid, "lpanel:result", CEFSTR("{\"error\":\"Игрок не найден\"}"));
        return 1;
    }
    if(PI[targetid][pFraction] != PI[playerid][pFraction]) {
        cef_emit_event(playerid, "lpanel:result", CEFSTR("{\"error\":\"Игрок не в вашей организации\"}"));
        return 1;
    }
    g_WarnCount[targetid]++;
    WB_AddRecord(targetid, WB_ACTION_WARN, 0, 0, reason, GetName(playerid));
    new query[96];
    mysql_format(dbHandle, query, sizeof(query),
        "UPDATE `accounts` SET `warns`=%d WHERE `id`=%d",
        g_WarnCount[targetid], PI[targetid][pID]);
    mysql_tquery(dbHandle, query, "", "");
    new msg[128];
    format(msg, sizeof(msg), "Вам выдан выговор. Причина: %s (Выговоры: %d/3)", reason, g_WarnCount[targetid]);
    CEFChat_Send(targetid, "FF8C00", msg);


    if(g_WarnCount[targetid] >= 3)
    {
        new frac = PI[targetid][pFraction];
        new oldRank = PI[targetid][pFractionRank];
        WB_AddRecord(targetid, WB_ACTION_FIRE, oldRank, 0, "3 выговора", GetName(playerid));
        Otdel_RemovePlayerSilent(targetid);
        PI[targetid][pFraction]     = 0;
        PI[targetid][pFractionRank] = 0;
        PI[targetid][pFractionSkin] = 0;
        g_WarnCount[targetid]       = 0;
        SetPlayerSkin(targetid, PI[targetid][pSkin]);
        mysql_format(dbHandle, query, sizeof(query),
            "UPDATE `accounts` SET `fraction`=0,`fraction_rank`=0,`fraction_skin`=0,`warns`=0 WHERE `id`=%d",
            PI[targetid][pID]);
        mysql_tquery(dbHandle, query, "", "");
        CEFChat_Send(targetid, "FF4444", "Вы автоматически уволены из организации за 3 выговора.");
        new auto_msg[144];
        format(auto_msg, sizeof(auto_msg), "[Орг] %s уволен автоматически за 3 выговора.", GetName(targetid));
        foreach(new i : Player) {
            if(PI[i][pFraction] == frac && PT[i][pLogged]) CEFChat_Send(i, "FF4444", auto_msg);
        }
    }

    cef_emit_event(playerid, "lpanel:result", CEFSTR("{\"ok\":1}"));
    return 1;
}

callback::OnLPanelUnwarn(playerid, const arguments[])
{
    new tmp[256];
    format(tmp, sizeof(tmp), "%s", arguments);
    new name[32], reason[64];
    new pos = strfind(tmp, "\"name\":\"");
    if(pos == -1) return 1;
    pos += 8;
    new end = strfind(tmp, "\"", false, pos);
    if(end == -1) return 1;
    strmid(name, tmp, pos, end, sizeof(name));
    pos = strfind(tmp, "\"reason\":\"");
    if(pos != -1) {
        pos += 10;
        end = strfind(tmp, "\"", false, pos);
        if(end != -1) strmid(reason, tmp, pos, end, sizeof(reason));
    }
    new targetid = -1;
    foreach(new i : Player) {
        if(!PT[i][pLogged]) continue;
        if(!strcmp(PI[i][pName], name, true)) { targetid = i; break; }
    }
    if(targetid == -1) {
        cef_emit_event(playerid, "lpanel:result", CEFSTR("{\"error\":\"Игрок не найден\"}"));
        return 1;
    }
    if(g_WarnCount[targetid] <= 0) {
        cef_emit_event(playerid, "lpanel:result", CEFSTR("{\"error\":\"У игрока нет выговоров\"}"));
        return 1;
    }
    g_WarnCount[targetid]--;
    WB_AddRecord(targetid, WB_ACTION_UNWARN, 0, 0, reason, GetName(playerid));
    new query[96];
    mysql_format(dbHandle, query, sizeof(query),
        "UPDATE `accounts` SET `warns`=%d WHERE `id`=%d",
        g_WarnCount[targetid], PI[targetid][pID]);
    mysql_tquery(dbHandle, query, "", "");
    new msg[128];
    format(msg, sizeof(msg), "С вас снят выговор. Причина: %s", reason);
    CEFChat_Send(targetid, "54B367", msg);
    cef_emit_event(playerid, "lpanel:result", CEFSTR("{\"ok\":1}"));
    return 1;
}

callback::OnLPanelList(playerid, const arguments[])
{
    new frac = g_LpanelFrac[playerid];
    new query[192];
    mysql_format(dbHandle, query, sizeof(query),
        "SELECT `name`,`level`,`fraction_rank`,`warns`,`last_login` FROM `accounts` WHERE `fraction`=%d ORDER BY `fraction_rank` DESC LIMIT 50",
        frac);
    mysql_tquery(dbHandle, query, "OnLPanelListLoaded", "i", playerid);
    return 1;
}

forward OnLPanelListLoaded(playerid);
public OnLPanelListLoaded(playerid)
{
    if(!IsPlayerConnected(playerid)) return 1;
    new rows = cache_num_rows();
    if(rows == 0) {
        cef_emit_event(playerid, "lpanel:list_result", CEFSTR("[]"));
        return 1;
    }
    new frac = g_LpanelFrac[playerid];
    new result[4096];
    strcat(result, "[");
    for(new i = 0; i < rows; i++) {
        new name[32], level, rank, warns;
        new lastlogin[32];
        cache_get_value_name(i, "name", name, sizeof(name));
        cache_get_value_name_int(i, "level", level);
        cache_get_value_name_int(i, "fraction_rank", rank);
        cache_get_value_name_int(i, "warns", warns);
        cache_get_value_name(i, "last_login", lastlogin, sizeof(lastlogin));
        new rankName[32];
        if(rank > 0 && rank <= Fraction[frac][fMax_ranks])
            format(rankName, sizeof(rankName), "%s", Fraction_Rank[frac][rank-1]);
        else format(rankName, sizeof(rankName), "Ранг %d", rank);
        new isonline = 0;
        foreach(new p : Player) {
            if(PT[p][pLogged] && !strcmp(PI[p][pName], name, true)) { isonline = 1; break; }
        }
        new entry[256];
        format(entry, sizeof(entry),
            "{\"name\":\"%s\",\"level\":%d,\"rank\":\"%s\",\"rankNum\":%d,\"warns\":%d,\"online\":%d,\"lastlogin\":\"%s\"}",
            name, level, rankName, rank, warns, isonline, lastlogin);
        strcat(result, entry);
        if(i < rows - 1) strcat(result, ",");
    }
    strcat(result, "]");
    cef_emit_event(playerid, "lpanel:list_result", CEFSTR(result));
    return 1;
}

forward LPanelPickupCheck();
public LPanelPickupCheck()
{
    return 1;
}

forward OnSurrenderPickup(playerid);
public OnSurrenderPickup(playerid)
{
    Surrender_Open(playerid);
    return 1;
}
