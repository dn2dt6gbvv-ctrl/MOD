
#if defined _WORKBOOK_INCLUDED
    #endinput
#endif
#define _WORKBOOK_INCLUDED

#define DIALOG_WB_MAIN    4200
#define DIALOG_WB_HISTORY 4201
#define DIALOG_WB_INVITE  4202
#define DIALOG_WB_ORGS    4205

#define WB_ACTION_INVITE   1
#define WB_ACTION_FIRE     2
#define WB_ACTION_RANKUP   3
#define WB_ACTION_RANKDOWN 4
#define WB_ACTION_WARN     5
#define WB_ACTION_UNWARN   6

#define WB_SHOW_RANGE 5.0

new g_MinCmdRank[MAX_FRACTIONS] = {
    0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0
};

new bool:g_CanRankDown[MAX_FRACTIONS] = {
    false, true, false, true, true, true, true, true, true, true, true
};

new g_WBTarget[MAX_PLAYERS]      = {-1, ...};
new g_WBViewTarget[MAX_PLAYERS]  = {-1, ...};
new g_WBViewFracId[MAX_PLAYERS]  = {0, ...};
new g_WarnCount[MAX_PLAYERS]     = {0, ...};

stock CanUseFracCmd(playerid)
{
    new frac = PI[playerid][pFraction];
    if(!frac) return false;
    new minRank = g_MinCmdRank[frac];
    if(minRank == 0) return PI[playerid][pFractionRank] == Fraction[frac][fMax_ranks];
    return PI[playerid][pFractionRank] >= minRank;
}

stock CanViewWorkbook(playerid, targetid)
{
    if(playerid == targetid) return true;
    if(PI[playerid][pAdmin] >= 4) return true;

    if(PI[targetid][pFraction] == FRACTION_FSB) {
        if(PI[playerid][pFraction] == FRACTION_FSB) return true;
        return false;
    }
    return true;
}

stock WB_ShowMain(showToId, subjectId)
{
    g_WBViewTarget[showToId] = subjectId;
    new frac = PI[subjectId][pFraction];
    new fracName[64];
    if(frac) format(fracName, sizeof(fracName), "%s", Fraction[frac][fName]);
    else fracName = "Безработный";
    new rankName[32];
    if(frac && PI[subjectId][pFractionRank] > 0)
        format(rankName, sizeof(rankName), "%s", Fraction_Rank[frac][PI[subjectId][pFractionRank]-1]);
    else rankName = "—";
    new info[256];
    format(info, sizeof(info),
        "Владелец: {e69348}%s{FFFFFF}\nОрганизация: {e69348}%s{FFFFFF}\nДолжность: {e69348}%s{FFFFFF}\n\nНажмите «Просмотр» для истории по организациям.",
        GetName(subjectId), fracName, rankName);
    ShowPlayerDialogEx(showToId, DIALOG_WB_MAIN, DIALOG_STYLE_MSGBOX,
        "Трудовая книга", info, "Просмотр", "Закрыть");
}

stock WB_AddRecord(playerid, action, rankFrom, rankTo, const reason[], const byName[])
{
    new frac = PI[playerid][pFraction];
    new fracName[64];
    format(fracName, sizeof(fracName), "%s", Fraction[frac][fName]);
    new query[320];
    mysql_format(dbHandle, query, sizeof(query),
        "INSERT INTO `work_history` (`player_id`,`fraction_id`,`fraction_name`,`action`,`rank_from`,`rank_to`,`reason`,`by_name`) VALUES (%d,%d,'%e',%d,%d,%d,'%e','%e')",
        PI[playerid][pID], frac, fracName, action, rankFrom, rankTo, reason, byName);
    mysql_tquery(dbHandle, query, "", "");
}

cmd:invite(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;
    if(!CanUseFracCmd(playerid)) return SendErr(playerid, "У вас нет прав для приглашения.");
    new targetid;
    if(sscanf(params, "u", targetid)) return SendErr(playerid, "Использование: /invite [ID]");
    if(!IsPlayerConnected(targetid)) return SendErr(playerid, "Игрок не в сети.");
    if(PI[targetid][pFraction]) return SendErr(playerid, "Игрок уже состоит в организации.");
    new frac = PI[playerid][pFraction];
    g_WBTarget[targetid] = playerid;
    new msg[128];
    format(msg, sizeof(msg), "Вам поступило приглашение в организацию {e69348}%s{FFFFFF}.\nПримите или откажитесь.", Fraction[frac][fName]);
    ShowPlayerDialogEx(targetid, DIALOG_WB_INVITE, DIALOG_STYLE_MSGBOX, "Приглашение в организацию", msg, "Принять", "Отказать");
    new notif[128];
    format(notif, sizeof(notif), "Вы отправили приглашение игроку %s.", GetName(targetid));
    CEFChat_Send(playerid, "AAAAAA", notif);
    return 1;
}

cmd:uval(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;
    if(!CanUseFracCmd(playerid)) return SendErr(playerid, "У вас нет прав для увольнения.");
    new targetid; new reason[64];
    if(sscanf(params, "us[64]", targetid, reason)) return SendErr(playerid, "Использование: /uval [ID] [причина]");
    if(!IsPlayerConnected(targetid)) return SendErr(playerid, "Игрок не в сети.");
    if(PI[targetid][pFraction] != PI[playerid][pFraction]) return SendErr(playerid, "Игрок не в вашей организации.");
    if(PI[targetid][pFractionRank] >= PI[playerid][pFractionRank]) return SendErr(playerid, "Нельзя уволить игрока равного или выше вас.");
    new oldRank = PI[targetid][pFractionRank];
    WB_AddRecord(targetid, WB_ACTION_FIRE, oldRank, 0, reason, GetName(playerid));
    PI[targetid][pFraction]     = 0;
    PI[targetid][pFractionRank] = 0;
    PI[targetid][pFractionSkin] = 0;
    SetPlayerSkin(targetid, PI[targetid][pSkin]);
    new query[128];
    mysql_format(dbHandle, query, sizeof(query),
        "UPDATE `accounts` SET `fraction`=0,`fraction_rank`=0,`fraction_skin`=0 WHERE `id`=%d", PI[targetid][pID]);
    mysql_tquery(dbHandle, query, "", "");
    new msg[128];
    format(msg, sizeof(msg), "Вы были уволены из организации. Причина: %s", reason);
    CEFChat_Send(targetid, "FF4444", msg);
    format(msg, sizeof(msg), "Вы уволили %s. Причина: %s", GetName(targetid), reason);
    CEFChat_Send(playerid, "AAAAAA", msg);
    new frac_msg[144];
    format(frac_msg, sizeof(frac_msg), "[Орг] %s уволил %s из организации.", GetName(playerid), GetName(targetid));
    new frac = PI[playerid][pFraction];
    foreach(new i : Player) {
        if(PI[i][pFraction] == frac && PT[i][pLogged]) CEFChat_Send(i, "AAAAAA", frac_msg);
    }
    return 1;
}

cmd:fwarn(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;
    if(!CanUseFracCmd(playerid)) return SendErr(playerid, "У вас нет прав для выдачи выговора.");
    new targetid; new reason[64];
    if(sscanf(params, "us[64]", targetid, reason)) return SendErr(playerid, "Использование: /fwarn [ID] [причина]");
    if(!IsPlayerConnected(targetid)) return SendErr(playerid, "Игрок не в сети.");
    if(PI[targetid][pFraction] != PI[playerid][pFraction]) return SendErr(playerid, "Игрок не в вашей организации.");
    if(PI[targetid][pFractionRank] >= PI[playerid][pFractionRank]) return SendErr(playerid, "Нельзя выдать выговор игроку равного или выше вас.");
    new frac = PI[playerid][pFraction];
    g_WarnCount[targetid]++;
    WB_AddRecord(targetid, WB_ACTION_WARN, 0, 0, reason, GetName(playerid));
    new msg[128];
    format(msg, sizeof(msg), "Вам выдан выговор. Причина: %s (Выговоры: %d/3)", reason, g_WarnCount[targetid]);
    CEFChat_Send(targetid, "FF8C00", msg);
    format(msg, sizeof(msg), "Вы выдали выговор %s. Причина: %s (%d/3)", GetName(targetid), reason, g_WarnCount[targetid]);
    CEFChat_Send(playerid, "AAAAAA", msg);
    new frac_msg[144];
    format(frac_msg, sizeof(frac_msg), "[Орг] %s получил выговор. Причина: %s (%d/3)", GetName(targetid), reason, g_WarnCount[targetid]);
    foreach(new i : Player) {
        if(PI[i][pFraction] == frac && PT[i][pLogged]) CEFChat_Send(i, "AAAAAA", frac_msg);
    }
    if(g_WarnCount[targetid] >= 3) {
        WB_AddRecord(targetid, WB_ACTION_FIRE, PI[targetid][pFractionRank], 0, "3 выговора", GetName(playerid));
        Otdel_RemovePlayerSilent(targetid);
        PI[targetid][pFraction]     = 0;
        PI[targetid][pFractionRank] = 0;
        PI[targetid][pFractionSkin] = 0;
        g_WarnCount[targetid]       = 0;
        SetPlayerSkin(targetid, PI[targetid][pSkin]);
        new query[128];
        mysql_format(dbHandle, query, sizeof(query),
            "UPDATE `accounts` SET `fraction`=0,`fraction_rank`=0,`fraction_skin`=0,`warn_count`=0 WHERE `id`=%d",
            PI[targetid][pID]);
        mysql_tquery(dbHandle, query, "", "");
        CEFChat_Send(targetid, "FF4444", "Вы автоматически уволены из организации за 3 выговора.");
        new auto_msg[144];
        format(auto_msg, sizeof(auto_msg), "[Орг] %s уволен автоматически за 3 выговора.", GetName(targetid));
        foreach(new i : Player) {
            if(PI[i][pFraction] == frac && PT[i][pLogged]) CEFChat_Send(i, "FF4444", auto_msg);
        }
    }
    return 1;
}

cmd:unfwarn(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;
    if(!CanUseFracCmd(playerid)) return SendErr(playerid, "У вас нет прав для снятия выговора.");
    new targetid; new reason[64];
    if(sscanf(params, "us[64]", targetid, reason)) return SendErr(playerid, "Использование: /unfwarn [ID] [причина]");
    if(!IsPlayerConnected(targetid)) return SendErr(playerid, "Игрок не в сети.");
    if(PI[targetid][pFraction] != PI[playerid][pFraction]) return SendErr(playerid, "Игрок не в вашей организации.");
    if(g_WarnCount[targetid] <= 0) return SendErr(playerid, "У игрока нет выговоров.");
    g_WarnCount[targetid]--;
    WB_AddRecord(targetid, WB_ACTION_UNWARN, 0, 0, reason, GetName(playerid));
    new msg[128];
    format(msg, sizeof(msg), "С вас снят выговор. Причина: %s (Выговоры: %d)", reason, g_WarnCount[targetid]);
    CEFChat_Send(targetid, "54B367", msg);
    format(msg, sizeof(msg), "Вы сняли выговор с %s.", GetName(targetid));
    CEFChat_Send(playerid, "AAAAAA", msg);
    return 1;
}

cmd:rangp(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;
    if(!CanUseFracCmd(playerid)) return SendErr(playerid, "У вас нет прав для повышения.");
    new targetid;
    if(sscanf(params, "u", targetid)) return SendErr(playerid, "Использование: /rang+ [ID]");
    if(!IsPlayerConnected(targetid)) return SendErr(playerid, "Игрок не в сети.");
    new frac = PI[playerid][pFraction];
    if(PI[targetid][pFraction] != frac) return SendErr(playerid, "Игрок не в вашей организации.");
    new myRank = PI[playerid][pFractionRank];
    new targetRank = PI[targetid][pFractionRank];
    if(targetRank >= myRank - 1) return SendErr(playerid, "Нельзя повысить до своего ранга или выше.");
    if(targetRank >= Fraction[frac][fMax_ranks]) return SendErr(playerid, "Игрок уже на максимальном ранге.");
    new newRank = targetRank + 1;
    WB_AddRecord(targetid, WB_ACTION_RANKUP, targetRank, newRank, "", GetName(playerid));
    PI[targetid][pFractionRank] = newRank;
    new query[96];
    mysql_format(dbHandle, query, sizeof(query),
        "UPDATE `accounts` SET `fraction_rank`=%d WHERE `id`=%d", newRank, PI[targetid][pID]);
    mysql_tquery(dbHandle, query, "", "");
    new rankName[32];
    format(rankName, sizeof(rankName), "%s", Fraction_Rank[frac][newRank-1]);
    new msg[128];
    format(msg, sizeof(msg), "Вы повышены до звания {e69348}%s{FFFFFF}.", rankName);
    CEFChat_Send(targetid, "54B367", msg);
    format(msg, sizeof(msg), "Вы повысили %s до звания %s.", GetName(targetid), rankName);
    CEFChat_Send(playerid, "AAAAAA", msg);
    new frac_msg[144];
    format(frac_msg, sizeof(frac_msg), "[Орг] %s повышен до звания %s.", GetName(targetid), rankName);
    foreach(new i : Player) {
        if(PI[i][pFraction] == frac && PT[i][pLogged]) CEFChat_Send(i, "AAAAAA", frac_msg);
    }
    return 1;
}
cmd:rangm(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;
    if(!CanUseFracCmd(playerid)) return SendErr(playerid, "У вас нет прав для понижения.");
    new frac = PI[playerid][pFraction];
    if(!g_CanRankDown[frac]) return SendErr(playerid, "Понижение в вашей организации запрещено.");
    new targetid;
    if(sscanf(params, "u", targetid)) return SendErr(playerid, "Использование: /rang- [ID]");
    if(!IsPlayerConnected(targetid)) return SendErr(playerid, "Игрок не в сети.");
    if(PI[targetid][pFraction] != frac) return SendErr(playerid, "Игрок не в вашей организации.");
    new myRank = PI[playerid][pFractionRank];
    new targetRank = PI[targetid][pFractionRank];
    if(targetRank >= myRank) return SendErr(playerid, "Нельзя понизить игрока равного или выше вас.");
    if(targetRank <= 1) return SendErr(playerid, "Игрок уже на минимальном ранге.");
    new newRank = targetRank - 1;
    WB_AddRecord(targetid, WB_ACTION_RANKDOWN, targetRank, newRank, "", GetName(playerid));
    PI[targetid][pFractionRank] = newRank;
    new query[96];
    mysql_format(dbHandle, query, sizeof(query),
        "UPDATE `accounts` SET `fraction_rank`=%d WHERE `id`=%d", newRank, PI[targetid][pID]);
    mysql_tquery(dbHandle, query, "", "");
    new rankName[32];
    format(rankName, sizeof(rankName), "%s", Fraction_Rank[frac][newRank-1]);
    new msg[128];
    format(msg, sizeof(msg), "Вы понижены до звания {FF4444}%s{FFFFFF}.", rankName);
    CEFChat_Send(targetid, "FF4444", msg);
    format(msg, sizeof(msg), "Вы понизили %s до звания %s.", GetName(targetid), rankName);
    CEFChat_Send(playerid, "AAAAAA", msg);
    return 1;
}
cmd:mytk(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;

    if(isnull(params))
    {
        WB_ShowMain(playerid, playerid);
        return 1;
    }

    new viewerid;
    if(sscanf(params, "u", viewerid)) return SendErr(playerid, "Использование: /mytk [ID игрока рядом]");
    if(!IsPlayerConnected(viewerid) || !PT[viewerid][pLogged]) return SendErr(playerid, "Игрок не в сети.");
    if(viewerid == playerid) return SendErr(playerid, "Нельзя показать книгу самому себе.");

    new Float:px, Float:py, Float:pz;
    GetPlayerPos(playerid, px, py, pz);
    if(!IsPlayerInRangeOfPoint(viewerid, WB_SHOW_RANGE, px, py, pz))
        return SendErr(playerid, "Игрок должен находиться рядом (5 метров).");

    WB_ShowMain(viewerid, playerid);

    new msg[128];
    format(msg, sizeof(msg), "Вы показали свою трудовую книгу игроку %s.", GetName(viewerid));
    CEFChat_Send(playerid, "AAAAAA", msg);
    return 1;
}

forward OnWBOrgsLoaded(playerid);
public OnWBOrgsLoaded(playerid)
{
    if(!IsPlayerConnected(playerid)) return 1;
    new rows = cache_num_rows();
    if(rows == 0) {
        ShowPlayerDialogEx(playerid, DIALOG_WB_ORGS, DIALOG_STYLE_MSGBOX,
            "История работы", "История работы пуста.", "Закрыть", "");
        return 1;
    }
    new list[1024], line[64];
    new targetid = g_WBViewTarget[playerid];
    new fracIds[10], fracNames[10][64], fracCount = 0;
    for(new i = 0; i < rows && fracCount < 10; i++) {
        new fid; new fname[64];
        cache_get_value_name_int(i, "fraction_id", fid);
        cache_get_value_name(i, "fraction_name", fname, sizeof(fname));
        new isDup = 0;
        for(new j = 0; j < fracCount; j++)
            if(fracIds[j] == fid) { isDup = 1; break; }
        if(isDup) continue;
        if(fid == FRACTION_FSB && !CanViewWorkbook(playerid, targetid)) continue;
        fracIds[fracCount] = fid;
        format(fracNames[fracCount], 64, "%s", fname);
        fracCount++;
    }
    if(fracCount == 0) {
        ShowPlayerDialogEx(playerid, DIALOG_WB_ORGS, DIALOG_STYLE_MSGBOX,
            "История работы", "Нет доступных записей.", "Закрыть", "");
        return 1;
    }
    for(new i = 0; i < fracCount; i++) {
        format(line, sizeof(line), "%s\n", fracNames[i]);
        strcat(list, line);
    }
    new title[64];
    format(title, sizeof(title), "История — %s", GetName(targetid));
    ShowPlayerDialogEx(playerid, DIALOG_WB_ORGS, DIALOG_STYLE_LIST, title, list, "Просмотр", "Назад");
    return 1;
}

forward OnWBOrgSelected(playerid);
public OnWBOrgSelected(playerid)
{
    if(!IsPlayerConnected(playerid)) return 1;
    new rows = cache_num_rows();
    new selectedIdx = g_WBViewFracId[playerid];
    new targetid = g_WBViewTarget[playerid];
    new fracId = 0, count = 0;
    for(new i = 0; i < rows; i++) {
        new fid; cache_get_value_name_int(i, "fraction_id", fid);
        if(fid == FRACTION_FSB && !CanViewWorkbook(playerid, targetid)) continue;
        new isDup = 0;
        for(new j = 0; j < i; j++) {
            new fid2; cache_get_value_name_int(j, "fraction_id", fid2);
            if(fid2 == fid) { isDup = 1; break; }
        }
        if(isDup) continue;
        if(count == selectedIdx) { fracId = fid; break; }
        count++;
    }
    if(!fracId) return 1;
    new query[160];
    mysql_format(dbHandle, query, sizeof(query),
        "SELECT * FROM `work_history` WHERE `player_id`=%d AND `fraction_id`=%d ORDER BY `id` DESC",
        PI[targetid][pID], fracId);
    mysql_tquery(dbHandle, query, "OnWBHistoryLoaded", "i", playerid);
    return 1;
}

forward OnWBHistoryLoaded(playerid);
public OnWBHistoryLoaded(playerid)
{
    if(!IsPlayerConnected(playerid)) return 1;
    new rows = cache_num_rows();
    if(rows == 0) {
        ShowPlayerDialogEx(playerid, DIALOG_WB_HISTORY, DIALOG_STYLE_MSGBOX,
            "История работы", "Записей нет.", "Назад", "");
        return 1;
    }
    new result[2048], line[256];
    new actionNames[][] = {"","Принят","Уволен","Повышен","Понижен","Выговор","Снят выговор"};
    for(new i = 0; i < rows; i++) {
        new action; new reason[128]; new byName[32]; new date[20];
        cache_get_value_name_int(i, "action", action);
        cache_get_value_name(i, "reason",  reason, sizeof(reason));
        cache_get_value_name(i, "by_name", byName, sizeof(byName));
        cache_get_value_name(i, "date",    date,   sizeof(date));
        new actionStr[32];
        if(action >= 1 && action <= 6) format(actionStr, sizeof(actionStr), "%s", actionNames[action]);
        if(strlen(reason))
            format(line, sizeof(line), "[%s] %s | %s | %s\n", date, actionStr, reason, byName);
        else
            format(line, sizeof(line), "[%s] %s | %s\n", date, actionStr, byName);
        strcat(result, line);
    }
    new title[64];
    format(title, sizeof(title), "История — %s", GetName(g_WBViewTarget[playerid]));
    ShowPlayerDialogEx(playerid, DIALOG_WB_HISTORY, DIALOG_STYLE_MSGBOX, title, result, "Назад", "Закрыть");
    return 1;
}
