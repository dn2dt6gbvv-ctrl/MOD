
#if defined _FSBPANEL_INCLUDED
    #endinput
#endif
#define _FSBPANEL_INCLUDED


new g_ListenFrac[MAX_PLAYERS]    = {-1, ...};
new bool:g_IsDisguised[MAX_PLAYERS];
new g_DisguiseAsFrac[MAX_PLAYERS] = {0, ...};
new g_DisguiseRank[MAX_PLAYERS]   = {0, ...};
new g_DisguiseOtdel[MAX_PLAYERS]  = {-1, ...};
new g_DisguiseSkin[MAX_PLAYERS]   = {0, ...};
new g_SuspectPlayer[MAX_PLAYERS]  = {-1, ...};

stock IsNumeric(const str[])
{
    new i = 0;
    if(str[0] == '-') i = 1;
    if(str[i] == '\0') return false;
    while(str[i] != '\0') {
        if(str[i] < '0' || str[i] > '9') return false;
        i++;
    }
    return true;
}

stock IsFSBOnDuty(playerid)
{
    return PI[playerid][pFraction] == FRACTION_FSB && PT[playerid][pDuty];
}

stock FSB_SendListen(sourceFrac, const senderName[], const text[])
{
    new fracName[64];
    format(fracName, sizeof(fracName), "%s", Fraction[sourceFrac][fName]);
    new msg[256];
    format(msg, sizeof(msg), "[ПРОСЛУШКА | %s] %s: %s", fracName, senderName, text);
    foreach(new i : Player) {
        if(!PT[i][pLogged]) continue;
        if(PI[i][pFraction] != FRACTION_FSB) continue;
        if(!PT[i][pDuty]) continue;
        if(g_ListenFrac[i] != sourceFrac) continue;
        CEFChat_Send(i, "FF4444", msg);
    }
}

stock GetDisplayFrac(playerid)
{
    if(g_IsDisguised[playerid]) return g_DisguiseAsFrac[playerid];
    return PI[playerid][pFraction];
}

stock GetDisplayRank(playerid)
{
    if(g_IsDisguised[playerid]) return g_DisguiseRank[playerid];
    return PI[playerid][pFractionRank];
}

stock GetDisplayOtdel(playerid)
{
    if(g_IsDisguised[playerid]) return g_DisguiseOtdel[playerid];
    return PI_Otdel[playerid];
}

cmd:fsb_panel(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;
    if(PI[playerid][pFraction] != FRACTION_FSB)
        return SendErr(playerid, "Только для сотрудников ФСБ.");
    if(!PT[playerid][pDuty])
        return SendErr(playerid, "Вы должны быть на дежурстве.");
    cef_create_browser(playerid, FSBPANEL_BROWSER, FSBPANEL_BROWSER_LINK, false, true);
    cef_focus_browser(playerid, FSBPANEL_BROWSER, true);
    cef_always_listen_keys(playerid, FSBPANEL_BROWSER, true);
    TogglePlayerControllable(playerid, 0);
    return 1;
}

callback::OnFSBPanelReady(playerid, const arguments[])
{
    SetTimerEx("FSBPanel_SendInit", 100, false, "i", playerid);
    return 1;
}

forward FSBPanel_SendInit(playerid);
public FSBPanel_SendInit(playerid)
{
    if(!IsPlayerConnected(playerid)) return 1;
    new buf[16];
    format(buf, sizeof(buf), "%d", g_ListenFrac[playerid]);
    cef_emit_event(playerid, "fsbpanel:listenstate", CEFSTR(buf));
    return 1;
}

forward CloseFSBPanel(playerid);
public CloseFSBPanel(playerid)
{
    if(!IsPlayerConnected(playerid)) return 1;
    cef_focus_browser(playerid, FSBPANEL_BROWSER, false);
    cef_hide_browser(playerid, FSBPANEL_BROWSER, true);
    cef_destroy_browser(playerid, FSBPANEL_BROWSER);
    TogglePlayerControllable(playerid, 1);
    return 1;
}

callback::OnFSBPanelClose(playerid, const arguments[])
{
    CloseFSBPanel(playerid);
    return 1;
}

callback::OnFSBListen(playerid, const arguments[])
{
    new fracid = strval(arguments);
    if(fracid < 1 || fracid > 10) {
        g_ListenFrac[playerid] = -1;
        CEFChat_Send(playerid, "AAAAAA", "Прослушка отключена.");
        return 1;
    }
    g_ListenFrac[playerid] = fracid;
    new msg[128];
    format(msg, sizeof(msg), "Прослушка включена: {e69348}%s{FFFFFF}.", Fraction[fracid][fName]);
    CEFChat_Send(playerid, "AAAAAA", msg);
    return 1;
}

callback::OnFSBDossier(playerid, const arguments[])
{
    new targetid = -1;
    if(IsNumeric(arguments)) {
        targetid = strval(arguments);
        if(!IsPlayerConnected(targetid)) targetid = -1;
    }
    if(targetid == -1) {
        foreach(new i : Player) {
            if(!PT[i][pLogged]) continue;
            if(!strcmp(PI[i][pName], arguments, true)) { targetid = i; break; }
        }
    }
    if(targetid == -1) {
        cef_emit_event(playerid, "fsbpanel:dossier_result", CEFSTR("{\"error\":\"Игрок не найден\"}"));
        return 1;
    }
    new query[128];
    mysql_format(dbHandle, query, sizeof(query),
        "SELECT * FROM `accounts` WHERE `id`=%d LIMIT 1", PI[targetid][pID]);
    mysql_tquery(dbHandle, query, "OnFSBDossierLoaded", "ii", playerid, targetid);
    return 1;
}

forward OnFSBDossierLoaded(playerid, targetid);
public OnFSBDossierLoaded(playerid, targetid)
{
    if(!IsPlayerConnected(playerid)) return 1;
    if(cache_num_rows() == 0) {
        cef_emit_event(playerid, "fsbpanel:dossier_result", CEFSTR("{\"error\":\"Данные не найдены\"}"));
        return 1;
    }
    new name[32], age[8], law[8], convictions[8];
    new family[32], reg[32], carplate[16];
    cache_get_value_name(0, "name",         name,        sizeof(name));
    cache_get_value_name(0, "age",          age,         sizeof(age));
    cache_get_value_name(0, "lawfulness",   law,         sizeof(law));
    cache_get_value_name(0, "convictions",  convictions, sizeof(convictions));
    cache_get_value_name(0, "family",       family,      sizeof(family));
    cache_get_value_name(0, "registration", reg,         sizeof(reg));
    cache_get_value_name(0, "car_plate",    carplate,    sizeof(carplate));
    new frac = PI[targetid][pFraction];
    new fracName[64], rankName[32];
    if(frac) format(fracName, sizeof(fracName), "%s", Fraction[frac][fName]);
    else fracName = "Безработный";
    if(frac && PI[targetid][pFractionRank] > 0)
        format(rankName, sizeof(rankName), "%s", Fraction_Rank[frac][PI[targetid][pFractionRank]-1]);
    else rankName = "—";
    new json[512];
    format(json, sizeof(json),
        "{\"name\":\"%s\",\"age\":\"%s\",\"law\":\"%s\",\"convictions\":\"%s\",\"job\":\"%s\",\"rank\":\"%s\",\"family\":\"%s\",\"reg\":\"%s\",\"car\":\"%s\"}",
        name, age, law, convictions, fracName, rankName, family, reg, carplate);
    cef_emit_event(playerid, "fsbpanel:dossier_result", CEFSTR(json));
    return 1;
}

callback::OnFSBSuspect(playerid, const arguments[])
{
    new targetid = -1;
    if(IsNumeric(arguments)) {
        targetid = strval(arguments);
        if(!IsPlayerConnected(targetid)) targetid = -1;
    }
    if(targetid == -1) {
        foreach(new i : Player) {
            if(!PT[i][pLogged]) continue;
            if(!strcmp(PI[i][pName], arguments, true)) { targetid = i; break; }
        }
    }
    if(targetid == -1) {
        cef_emit_event(playerid, "fsbpanel:suspect_result", CEFSTR("{\"error\":\"Игрок не найден\"}"));
        return 1;
    }
    if(g_SuspectPlayer[playerid] != -1)
        RemovePlayerMapIcon(playerid, 100 + playerid);
    g_SuspectPlayer[playerid] = targetid;
    new Float:x, Float:y, Float:z;
    GetPlayerPos(targetid, x, y, z);
    SetPlayerMapIcon(playerid, 100 + playerid, x, y, z, 0, 0xFF0000FF, MAPICON_LOCAL);
    new json[128];
    format(json, sizeof(json), "{\"name\":\"%s\",\"id\":%d}", PI[targetid][pName], targetid);
    cef_emit_event(playerid, "fsbpanel:suspect_result", CEFSTR(json));
    new msg[128];
    format(msg, sizeof(msg), "Подозреваемый {e69348}%s{FFFFFF} отмечен на карте.", PI[targetid][pName]);
    CEFChat_Send(playerid, "AAAAAA", msg);
    return 1;
}

callback::OnFSBDisguiseSkin(playerid, const arguments[])
{
    new frac, rank, otdel, skin;
    new tmp[256];
    format(tmp, sizeof(tmp), "%s", arguments);
    new pos = strfind(tmp, "\"frac\":");
    if(pos == -1) return 1;
    frac = strval(tmp[pos+7]);
    pos = strfind(tmp, "\"rank\":");
    if(pos != -1) rank = strval(tmp[pos+7]);
    pos = strfind(tmp, "\"otdel\":");
    if(pos != -1) otdel = strval(tmp[pos+8]);
    pos = strfind(tmp, "\"skin\":");
    if(pos != -1) skin = strval(tmp[pos+7]);
    if(frac < 1 || frac > 10) return 1;
    g_IsDisguised[playerid]    = true;
    g_DisguiseAsFrac[playerid] = frac;
    g_DisguiseRank[playerid]   = rank;
    g_DisguiseOtdel[playerid]  = otdel;
    g_DisguiseSkin[playerid]   = skin;
    SetPlayerSkin(playerid, skin);
    new msg[128];
    format(msg, sizeof(msg), "Вы замаскированы под {e69348}%s{FFFFFF}.", Fraction[frac][fName]);
    CEFChat_Send(playerid, "AAAAAA", msg);
    return 1;
}

callback::OnFSBDisguiseCivilian(playerid, const arguments[])
{
    new skin = strval(arguments);
    g_IsDisguised[playerid]    = true;
    g_DisguiseAsFrac[playerid] = 0;
    g_DisguiseRank[playerid]   = 0;
    g_DisguiseOtdel[playerid]  = -1;
    g_DisguiseSkin[playerid]   = skin;
    SetPlayerSkin(playerid, skin);
    CEFChat_Send(playerid, "AAAAAA", "Вы переоделись в гражданскую одежду.");
    return 1;
}

callback::OnFSBDisguiseRemove(playerid, const arguments[])
{
    g_IsDisguised[playerid]    = false;
    g_DisguiseAsFrac[playerid] = 0;
    g_DisguiseRank[playerid]   = 0;
    g_DisguiseOtdel[playerid]  = -1;
    g_DisguiseSkin[playerid]   = 0;
    SetPlayerSkin(playerid, PI[playerid][pFractionSkin]);
    CEFChat_Send(playerid, "AAAAAA", "Маскировка снята.");
    return 1;
}

callback::OnFSBFire(playerid, const arguments[])
{
    new tmp[256];
    format(tmp, sizeof(tmp), "%s", arguments);
    new targetName[32], reason[64];
    new pos = strfind(tmp, "\"name\":\"");
    if(pos == -1) return 1;
    pos += 8;
    new end = strfind(tmp, "\"", false, pos);
    if(end == -1) return 1;
    strmid(targetName, tmp, pos, end, sizeof(targetName));
    pos = strfind(tmp, "\"reason\":\"");
    if(pos != -1) {
        pos += 10;
        end = strfind(tmp, "\"", false, pos);
        if(end != -1) strmid(reason, tmp, pos, end, sizeof(reason));
    }
    new targetid = -1;
    foreach(new i : Player) {
        if(!PT[i][pLogged]) continue;
        if(!strcmp(PI[i][pName], targetName, true)) { targetid = i; break; }
    }
    if(targetid == -1) {
        cef_emit_event(playerid, "fsbpanel:fire_result", CEFSTR("{\"error\":\"Игрок не найден или не онлайн\"}"));
        return 1;
    }
    if(!PI[targetid][pFraction]) {
        cef_emit_event(playerid, "fsbpanel:fire_result", CEFSTR("{\"error\":\"Игрок не в организации\"}"));
        return 1;
    }
    new targetFrac = PI[targetid][pFraction];
    new oldRank = PI[targetid][pFractionRank];
    WB_AddRecord(targetid, WB_ACTION_FIRE, oldRank, 0, reason, GetName(playerid));
    Otdel_RemovePlayerSilent(targetid);
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
    format(msg, sizeof(msg), "Вас уволили из организации. Причина: %s", reason);
    CEFChat_Send(targetid, "FF4444", msg);
    format(msg, sizeof(msg), "Вы уволили %s из организации. Причина: %s", GetName(targetid), reason);
    CEFChat_Send(playerid, "AAAAAA", msg);

    new radio[128];
    format(radio, sizeof(radio), "[R] %s уволен агентом ФСБ. Причина: %s", GetName(targetid), reason);
    foreach(new i : Player) {
        if(!PT[i][pLogged] || !PT[i][pDuty]) continue;
        if(PI[i][pFraction] != targetFrac) continue;
        CEFChat_Send(i, "FF4444", radio);
    }
    cef_emit_event(playerid, "fsbpanel:fire_result", CEFSTR("{\"ok\":1}"));
    return 1;
}

callback::OnFSBUnwarn(playerid, const arguments[])
{
    new tmp[256];
    format(tmp, sizeof(tmp), "%s", arguments);
    new targetName[32], reason[64];
    new pos = strfind(tmp, "\"name\":\"");
    if(pos == -1) return 1;
    pos += 8;
    new end = strfind(tmp, "\"", false, pos);
    if(end == -1) return 1;
    strmid(targetName, tmp, pos, end, sizeof(targetName));
    pos = strfind(tmp, "\"reason\":\"");
    if(pos != -1) {
        pos += 10;
        end = strfind(tmp, "\"", false, pos);
        if(end != -1) strmid(reason, tmp, pos, end, sizeof(reason));
    }
    new targetid = -1;
    foreach(new i : Player) {
        if(!PT[i][pLogged]) continue;
        if(!strcmp(PI[i][pName], targetName, true)) { targetid = i; break; }
    }
    if(targetid == -1) {
        cef_emit_event(playerid, "fsbpanel:unwarn_result", CEFSTR("{\"error\":\"Игрок не найден или не онлайн\"}"));
        return 1;
    }
    if(g_WarnCount[targetid] <= 0) {
        cef_emit_event(playerid, "fsbpanel:unwarn_result", CEFSTR("{\"error\":\"У игрока нет выговоров\"}"));
        return 1;
    }
    g_WarnCount[targetid]--;
    WB_AddRecord(targetid, WB_ACTION_UNWARN, 0, 0, reason, GetName(playerid));
    new query[128];
    mysql_format(dbHandle, query, sizeof(query),
        "UPDATE `accounts` SET `warn_count`=%d WHERE `id`=%d",
        g_WarnCount[targetid], PI[targetid][pID]);
    mysql_tquery(dbHandle, query, "", "");
    new msg[128];
    format(msg, sizeof(msg), "С вас снят выговор агентом ФСБ. Причина: %s (Выговоры: %d)", reason, g_WarnCount[targetid]);
    CEFChat_Send(targetid, "54B367", msg);
    format(msg, sizeof(msg), "Выговор снят с %s.", GetName(targetid));
    CEFChat_Send(playerid, "AAAAAA", msg);
    cef_emit_event(playerid, "fsbpanel:unwarn_result", CEFSTR("{\"ok\":1}"));
    return 1;
}

callback::OnFSBWorkbook(playerid, const arguments[])
{
    new targetid = -1;
    foreach(new i : Player) {
        if(!PT[i][pLogged]) continue;
        if(!strcmp(PI[i][pName], arguments, true)) { targetid = i; break; }
    }
    if(targetid == -1) {
        cef_emit_event(playerid, "fsbpanel:wb_result", CEFSTR("{\"error\":\"Игрок не найден или не онлайн\"}"));
        return 1;
    }
    CloseFSBPanel(playerid);
    SetTimerEx("FSBOpenWorkbook", 200, false, "ii", playerid, targetid);
    return 1;
}

forward FSBOpenWorkbook(playerid, targetid);
public FSBOpenWorkbook(playerid, targetid)
{
    if(!IsPlayerConnected(playerid) || !IsPlayerConnected(targetid)) return 1;
    g_WBViewTarget[playerid] = targetid;
    new frac = PI[targetid][pFraction];
    new fracName[64], rankName[32];
    if(frac) format(fracName, sizeof(fracName), "%s", Fraction[frac][fName]);
    else fracName = "Безработный";
    if(frac && PI[targetid][pFractionRank] > 0)
        format(rankName, sizeof(rankName), "%s", Fraction_Rank[frac][PI[targetid][pFractionRank]-1]);
    else rankName = "—";
    new info[256];
    format(info, sizeof(info),
        "Владелец: {e69348}%s{FFFFFF}\nОрганизация: {e69348}%s{FFFFFF}\nДолжность: {e69348}%s{FFFFFF}\n\nНажмите «Просмотр» для истории по организациям.",
        GetName(targetid), fracName, rankName);
    ShowPlayerDialogEx(playerid, DIALOG_WB_MAIN, DIALOG_STYLE_MSGBOX,
        "Трудовая книга", info, "Просмотр", "Закрыть");
    return 1;
}

forward OnFSBWBHistory(playerid);
public OnFSBWBHistory(playerid)
{
    if(!IsPlayerConnected(playerid)) return 1;
    new rows = cache_num_rows();
    if(rows == 0) {
        cef_emit_event(playerid, "fsbpanel:wb_history", CEFSTR("[]"));
        return 1;
    }
    new result[2048];
    strcat(result, "[");
    new actionNames[][] = {"","Принят","Уволен","Повышен","Понижен","Выговор","Снят выговор"};
    for(new i = 0; i < rows; i++) {
        new action, reason[64], byName[32], date[20], fracName[64];
        cache_get_value_name_int(i, "action", action);
        cache_get_value_name(i, "reason",        reason,   sizeof(reason));
        cache_get_value_name(i, "by_name",       byName,   sizeof(byName));
        cache_get_value_name(i, "date",          date,     sizeof(date));
        cache_get_value_name(i, "fraction_name", fracName, sizeof(fracName));
        new actionStr[32];
        if(action >= 1 && action <= 6) format(actionStr, sizeof(actionStr), "%s", actionNames[action]);
        new entry[256];
        format(entry, sizeof(entry),
            "{\"date\":\"%s\",\"action\":\"%s\",\"frac\":\"%s\",\"reason\":\"%s\",\"by\":\"%s\"}",
            date, actionStr, fracName, reason, byName);
        strcat(result, entry);
        if(i < rows - 1) strcat(result, ",");
    }
    strcat(result, "]");
    cef_emit_event(playerid, "fsbpanel:wb_history", CEFSTR(result));
    return 1;
}

callback::OnFSBOrgStats(playerid, const arguments[])
{
    new counts[11];
    foreach(new i : Player) {
        if(!PT[i][pLogged]) continue;
        new f = PI[i][pFraction];
        if(f >= 1 && f <= 10) counts[f]++;
    }
    new total = 0;
    for(new f = 1; f <= 10; f++) total += counts[f];
    new result[1024];
    format(result, sizeof(result), "{\"total\":%d,\"fracs\":[", total);
    for(new f = 1; f <= 10; f++) {
        new entry[128];
        format(entry, sizeof(entry), "{\"id\":%d,\"name\":\"%s\",\"count\":%d}", f, Fraction[f][fName], counts[f]);
        strcat(result, entry);
        if(f < 10) strcat(result, ",");
    }
    strcat(result, "]}");
    cef_emit_event(playerid, "fsbpanel:org_stats_result", CEFSTR(result));
    return 1;
}

callback::OnFSBOrgMembers(playerid, const arguments[])
{
    new fractionid = strval(arguments);
    if(fractionid < 1 || fractionid > 10) return 1;
    new statsTotal = 0, statsActive = 0, statsVacation = 0, statsSuspended = 0;
    foreach(new i : Player) {
        if(GetDisplayFrac(i) != fractionid) continue;
        statsTotal++;
        if(PI[i][pSuspended] > 0) statsSuspended++;
        else if(PT[i][pDuty]) statsActive++;
        else statsVacation++;
    }
    new statsJson[256];
    format(statsJson, sizeof(statsJson),
        "{\"fractionName\":\"%s\",\"stats\":{\"total\":%d,\"active\":%d,\"vacation\":%d,\"suspended\":%d}}",
        Fraction[fractionid][fName], statsTotal, statsActive, statsVacation, statsSuspended);
    cef_emit_event(playerid, "fsbpanel:find_stats", CEFSTR(statsJson));
    for(new i = 0; i < Fraction[fractionid][fMax_ranks]; i++)
        cef_emit_event(playerid, "fsbpanel:find_rank", CEFSTR(Fraction_Rank[fractionid][i]));
    for(new i = 0; i < g_OtdelCount[fractionid]; i++)
        cef_emit_event(playerid, "fsbpanel:find_dept", CEFSTR(g_Otdel[fractionid][i][otdel_Name]));
    foreach(new i : Player) {
        if(GetDisplayFrac(i) != fractionid) continue;
        new rankIdx = GetDisplayRank(i) - 1;
        new rankName[32];
        if(rankIdx >= 0 && rankIdx < Fraction[fractionid][fMax_ranks])
            format(rankName, sizeof(rankName), "%s", Fraction_Rank[fractionid][rankIdx]);
        else format(rankName, sizeof(rankName), "Ранг %d", rankIdx + 1);
        new otdelName[32];
        GetOtdelName(fractionid, GetDisplayOtdel(i), otdelName, sizeof(otdelName));
        new status[16];
        if(PI[i][pSuspended] > 0) format(status, sizeof(status), "Отстранен");
        else if(PT[i][pDuty]) format(status, sizeof(status), "На работе");
        else format(status, sizeof(status), "На выходном");
        new memberJson[256];
        format(memberJson, sizeof(memberJson),
            "{\"id\":%d,\"name\":\"%s\",\"rank\":\"%s\",\"status\":\"%s\",\"dept\":\"%s\",\"afk\":%d}",
            i, PI[i][pName], rankName, status, otdelName, PI[i][pAFK]);
        cef_emit_event(playerid, "fsbpanel:find_member", CEFSTR(memberJson));
    }
    cef_emit_event(playerid, "fsbpanel:find_done", CEFINT(1));
    return 1;
}

callback::OnFSBGetRanks(playerid, const arguments[])
{
    new frac = strval(arguments);
    if(frac < 1 || frac > 10) return 1;
    new result[512];
    strcat(result, "[");
    for(new i = 0; i < Fraction[frac][fMax_ranks]; i++) {
        new entry[64];
        format(entry, sizeof(entry), "{\"name\":\"%s\"}", Fraction_Rank[frac][i]);
        strcat(result, entry);
        if(i < Fraction[frac][fMax_ranks] - 1) strcat(result, ",");
    }
    strcat(result, "]");
    cef_emit_event(playerid, "fsbpanel:ranks", CEFSTR(result));
    return 1;
}

callback::OnFSBGetDepts(playerid, const arguments[])
{
    new frac = strval(arguments);
    if(frac < 1 || frac > 10) return 1;
    new result[512];
    strcat(result, "[");
    for(new i = 0; i < g_OtdelCount[frac]; i++) {
        new entry[64];
        format(entry, sizeof(entry), "{\"name\":\"%s\"}", g_Otdel[frac][i][otdel_Name]);
        strcat(result, entry);
        if(i < g_OtdelCount[frac] - 1) strcat(result, ",");
    }
    strcat(result, "]");
    cef_emit_event(playerid, "fsbpanel:depts", CEFSTR(result));
    return 1;
}

callback::OnFSBGetSkins(playerid, const arguments[])
{
    new frac = strval(arguments);
    if(frac < 1 || frac > 10) return 1;
    new result[128];
    strcat(result, "[");
    new added = 0;
    for(new i = 0; i < 10; i++) {
        new sk = LeaderSkins[frac][i];
        if(!sk) break;
        if(added) strcat(result, ",");
        new tmp[8];
        format(tmp, sizeof(tmp), "%d", sk);
        strcat(result, tmp);
        added++;
    }
    strcat(result, "]");
    cef_emit_event(playerid, "fsbpanel:skins", CEFSTR(result));
    return 1;
}

callback::OnFSBWarn(playerid, const arguments[])
{
    new tmp[256];
    format(tmp, sizeof(tmp), "%s", arguments);
    new targetName[32], reason[64];
    new pos = strfind(tmp, "\"name\":\"");
    if(pos == -1) return 1;
    pos += 8;
    new end = strfind(tmp, "\"", false, pos);
    if(end == -1) return 1;
    strmid(targetName, tmp, pos, end, sizeof(targetName));
    pos = strfind(tmp, "\"reason\":\"");
    if(pos != -1) {
        pos += 10;
        end = strfind(tmp, "\"", false, pos);
        if(end != -1) strmid(reason, tmp, pos, end, sizeof(reason));
    }
    new targetid = -1;
    foreach(new i : Player) {
        if(!PT[i][pLogged]) continue;
        if(!strcmp(PI[i][pName], targetName, true)) { targetid = i; break; }
    }
    if(targetid == -1) {
        cef_emit_event(playerid, "fsbpanel:warn_result", CEFSTR("{\"error\":\"Игрок не найден или не онлайн\"}"));
        return 1;
    }
    if(!PI[targetid][pFraction]) {
        cef_emit_event(playerid, "fsbpanel:warn_result", CEFSTR("{\"error\":\"Игрок не в организации\"}"));
        return 1;
    }
    new targetFrac = PI[targetid][pFraction];
    g_WarnCount[targetid]++;
    WB_AddRecord(targetid, WB_ACTION_WARN, 0, 0, reason, GetName(playerid));
    new query[128];
    mysql_format(dbHandle, query, sizeof(query),
        "UPDATE `accounts` SET `warn_count`=%d WHERE `id`=%d",
        g_WarnCount[targetid], PI[targetid][pID]);
    mysql_tquery(dbHandle, query, "", "");
    new msg[128];
    format(msg, sizeof(msg), "Вам выдан выговор агентом ФСБ. Причина: %s (Выговоры: %d/3)", reason, g_WarnCount[targetid]);
    CEFChat_Send(targetid, "FF8C00", msg);
    format(msg, sizeof(msg), "Выговор выдан %s. (%d/3)", GetName(targetid), g_WarnCount[targetid]);
    CEFChat_Send(playerid, "AAAAAA", msg);
    new radio[128];
    format(radio, sizeof(radio), "[R] %s получил выговор от ФСБ. Причина: %s (%d/3)", GetName(targetid), reason, g_WarnCount[targetid]);
    foreach(new i : Player) {
        if(!PT[i][pLogged] || !PT[i][pDuty]) continue;
        if(PI[i][pFraction] != targetFrac) continue;
        CEFChat_Send(i, "FF8C00", radio);
    }
    if(g_WarnCount[targetid] >= 3) {
        WB_AddRecord(targetid, WB_ACTION_FIRE, PI[targetid][pFractionRank], 0, "3 выговора", GetName(playerid));
        Otdel_RemovePlayerSilent(targetid);
        PI[targetid][pFraction]     = 0;
        PI[targetid][pFractionRank] = 0;
        PI[targetid][pFractionSkin] = 0;
        g_WarnCount[targetid]       = 0;
        SetPlayerSkin(targetid, PI[targetid][pSkin]);
        mysql_format(dbHandle, query, sizeof(query),
            "UPDATE `accounts` SET `fraction`=0,`fraction_rank`=0,`fraction_skin`=0,`warn_count`=0 WHERE `id`=%d",
            PI[targetid][pID]);
        mysql_tquery(dbHandle, query, "", "");
        CEFChat_Send(targetid, "FF4444", "Вы уволены автоматически за 3 выговора.");
        new auto_msg[144];
        format(auto_msg, sizeof(auto_msg), "[R] %s уволен автоматически за 3 выговора.", GetName(targetid));
        foreach(new i : Player) {
            if(!PT[i][pLogged] || !PT[i][pDuty]) continue;
            if(PI[i][pFraction] != targetFrac) continue;
            CEFChat_Send(i, "FF4444", auto_msg);
        }
    }
    cef_emit_event(playerid, "fsbpanel:warn_result", CEFSTR("{\"ok\":1}"));
    return 1;
}

callback::OnFSBOpenFind(playerid, const arguments[])
{
    new fractionid = strval(arguments);
    if(fractionid < 1 || fractionid > 10) return 1;
    CloseFSBPanel(playerid);
    SetTimerEx("FSBOpenFindDelayed", 200, false, "ii", playerid, fractionid);
    return 1;
}

forward FSBOpenFindDelayed(playerid, fractionid);
public FSBOpenFindDelayed(playerid, fractionid)
{
    if(!IsPlayerConnected(playerid)) return 1;
    cef_create_browser(playerid, FIND_BROWSER, FIND_BROWSER_LINK, false, true);
    cef_focus_browser(playerid, FIND_BROWSER, true);
    cef_always_listen_keys(playerid, FIND_BROWSER, true);
    TogglePlayerControllable(playerid, 0);
    SetTimerEx("FSBSendFindData", 500, false, "ii", playerid, fractionid);
    return 1;
}

forward FSBSendFindData(playerid, fractionid);
public FSBSendFindData(playerid, fractionid)
{
    if(!IsPlayerConnected(playerid)) return 1;
    new statsTotal = 0, statsActive = 0, statsVacation = 0, statsSuspended = 0;
    foreach(new i : Player) {
        if(GetDisplayFrac(i) != fractionid) continue;
        statsTotal++;
        if(PI[i][pSuspended] > 0) statsSuspended++;
        else if(PT[i][pDuty]) statsActive++;
        else statsVacation++;
    }
    new statsJson[256];
    format(statsJson, sizeof(statsJson),
        "{\"fractionName\":\"%s\",\"stats\":{\"total\":%d,\"active\":%d,\"vacation\":%d,\"suspended\":%d}}",
        Fraction[fractionid][fName], statsTotal, statsActive, statsVacation, statsSuspended);
    cef_emit_event(playerid, "find:stats", CEFSTR(statsJson));
    for(new i = 0; i < Fraction[fractionid][fMax_ranks]; i++)
        cef_emit_event(playerid, "find:addrank", CEFSTR(Fraction_Rank[fractionid][i]));
    for(new i = 0; i < g_OtdelCount[fractionid]; i++)
        cef_emit_event(playerid, "find:adddept", CEFSTR(g_Otdel[fractionid][i][otdel_Name]));
    foreach(new i : Player) {
        if(GetDisplayFrac(i) != fractionid) continue;
        new rankIdx = GetDisplayRank(i) - 1;
        new rankName[32];
        if(rankIdx >= 0 && rankIdx < Fraction[fractionid][fMax_ranks])
            format(rankName, sizeof(rankName), "%s", Fraction_Rank[fractionid][rankIdx]);
        else format(rankName, sizeof(rankName), "Ранг %d", rankIdx + 1);
        new otdelName[32];
        GetOtdelName(fractionid, GetDisplayOtdel(i), otdelName, sizeof(otdelName));
        new status[16];
        if(PI[i][pSuspended] > 0) format(status, sizeof(status), "Отстранен");
        else if(PT[i][pDuty]) format(status, sizeof(status), "На работе");
        else format(status, sizeof(status), "На выходном");
        new memberJson[256];
        format(memberJson, sizeof(memberJson),
            "{\"id\":%d,\"name\":\"%s\",\"rank\":\"%s\",\"status\":\"%s\",\"dept\":\"%s\",\"afk\":%d}",
            i, PI[i][pName], rankName, status, otdelName, PI[i][pAFK]);
        cef_emit_event(playerid, "find:addmember", CEFSTR(memberJson));
    }
    cef_emit_event(playerid, "find:done", CEFINT(1));
    return 1;
}

stock InitFsbWarehouse()
{
    fsb_warehouse_pickup = CreateDynamicPickup(347, 2, 1629.5416, 1185.2831, 1664.0236, -1, -1, -1, 10.0);
    CreateDynamic3DTextLabel("Склад ФСБ", 0xFFFFFFFF, 1629.5416, 1185.2831, 1664.0236 + 0.5, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, -1, -1, -1, 10.0);
    return 1;
}

cmd:fsbs(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1; 

    if(PI[playerid][pFraction] != 2)
    {
        return SendErr(playerid, "Вы не являетесь сотрудником ФСБ!");
    }

    if(!PT[playerid][pDuty])
    {
        return SendErr(playerid, "Вы должны начать рабочий день, чтобы открыть склад!");
    }

    if(!IsPlayerInRangeOfPoint(playerid, 3.0, 1629.5416, 1185.2831, 1664.0236))
    {
        return SendErr(playerid, "Вы должны находиться у оружейного склада ФСБ!");
    }

    CEF_OpsStorageOpen(playerid);
    cef_focus_browser(playerid, WAREHOUSE_FSB_BROWSER, true);
    TogglePlayerControllable(playerid, 0);
    return 1;
}

forward CloseFsbWarehouse(playerid);
public CloseFsbWarehouse(playerid)
{
    cef_focus_browser(playerid, WAREHOUSE_FSB_BROWSER, false);
    cef_hide_browser(playerid, WAREHOUSE_FSB_BROWSER, true);
    cef_destroy_browser(playerid, WAREHOUSE_FSB_BROWSER);
    TogglePlayerControllable(playerid, 1);
    cef_emit_event(playerid, "game:showCursor", CEFINT(0));
    return 1;
}

forward OnFsbWarehouseTake(playerid, const item[]);
public OnFsbWarehouseTake(playerid, const item[])
{
    if(PI[playerid][pFraction] != 2) return 1;

    if(!strcmp(item, "svd", true))
    {
        GivePlayerWeapon(playerid, 34, 50);
        SendWarehouseRadio(playerid, "СВД ПСО");
    }
    else if(!strcmp(item, "aks74u", true))
    {
        GivePlayerWeapon(playerid, 29, 150);
        SendWarehouseRadio(playerid, "АКС-74У");
    }
    else if(!strcmp(item, "saiga", true))
    {
        GivePlayerWeapon(playerid, 27, 60);
        SendWarehouseRadio(playerid, "Сайга");
    }
    else if(!strcmp(item, "armor", true))
    {
        SetPlayerArmour(playerid, 100.0);
        SendWarehouseRadio(playerid, "Бронежилет");
    }
    else if(!strcmp(item, "ap_stechkina", true))
    {
        GivePlayerWeapon(playerid, 22, 40);
        SendWarehouseRadio(playerid, "АП Стечкина");
    }
    else if(!strcmp(item, "as_val", true))
    {
        GivePlayerWeapon(playerid, 31, 100);
        SendWarehouseRadio(playerid, "АС ВАЛ");
    }
    else if(!strcmp(item, "vss_vintorez", true))
    {
        GivePlayerWeapon(playerid, 33, 120);
        SendWarehouseRadio(playerid, "ВСС ВИНТОРЕЗ");
    }
    else if(!strcmp(item, "tt_pistol", true))
    {
        GivePlayerWeapon(playerid, 24, 35);
        SendWarehouseRadio(playerid, "Пистолет ТТ");
    }
    else if(!strcmp(item, "baton", true))
    {
        GivePlayerWeapon(playerid, 3, 1);
        SendWarehouseRadio(playerid, "Резиновая дубинка");
    }
    else if(!strcmp(item, "adric", true) || !strcmp(item, "energy_drink", true) || !strcmp(item, "repkit", true) || !strcmp(item, "medkit", true))
    {
        SendWarehouseRadio(playerid, "Расходники");
    }
    return 1;
}
