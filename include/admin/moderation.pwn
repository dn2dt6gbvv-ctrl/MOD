
new g_AdminJailTime[MAX_PLAYERS];
new g_AdminJailWorld[MAX_PLAYERS];
new g_AdminJailInterior[MAX_PLAYERS];
new bool:g_AdminJailed[MAX_PLAYERS];

forward AdminModeration_Tick(playerid);
forward AdminModeration_OnConnect(playerid);
forward AdminModeration_Kick(playerid);

stock bool:AdminModeration_CanAffect(playerid, target)
{
    if(!IsPlayerConnected(target) || !PT[target][pLogged]) return SendErr(playerid, "Игрок не в сети или не авторизован."), false;
    if(target == playerid) return SendErr(playerid, "Нельзя применить это действие к себе."), false;
    if(PI[target][pAdmin] >= PI[playerid][pAdmin]) return SendErr(playerid, "Нельзя применить действие к администратору равного или более высокого уровня."), false;
    return true;
}

stock AdminModeration_Broadcast(playerid, const action[], target, const reason[], bool:quiet = false)
{
    new message[192];
    format(message, sizeof(message), "[A] %s %s %s игрока %s[%d]. Причина: %s", GetPrefix(playerid), GetName(playerid), action, GetName(target), target, reason);
    if(quiet) SendAdminMessage(COLOR_GRAY, message);
    else SendClientMessageToAll(COLOR_RED, message);
    return 1;
}

stock AdminModeration_Ban(playerid, target, days, const reason[], bool:quiet = false)
{
    if(days < 1 || days > 365) return SendErr(playerid, "Срок бана — от 1 до 365 дней.");
    new date[16], query[384];
    new year, month, day;
    getdate(year, month, day);
    format(date, sizeof(date), "%02d.%02d.%04d", day, month, year);
    mysql_format(dbHandle, query, sizeof(query), "INSERT INTO `bans` (`name`,`whobanned`,`ip`,`bandate`,`time`,`unbandate`,`reason`) VALUES ('%e','%e','%e','%e',%d,%d,'%e')", GetName(target), GetName(playerid), PI[target][pIP], date, days, gettime() + days * 86400, reason);
    mysql_tquery(dbHandle, query, "", "");
    AdminModeration_Broadcast(playerid, quiet ? ("тихо забанил") : ("забанил"), target, reason, quiet);
    SendClientMessage(target, COLOR_RED, "Вы были забанены администрацией.");
    SetTimerEx("AdminModeration_Kick", 700, false, "i", target);
    return 1;
}

public AdminModeration_Kick(playerid)
{
    if(IsPlayerConnected(playerid)) Kick(playerid);
    return 1;
}

stock AdminModeration_Release(target, bool:notify = true)
{
    if(!g_AdminJailed[target]) return 0;
    g_AdminJailed[target] = false;
    g_AdminJailTime[target] = 0;
    SetPlayerVirtualWorld(target, g_AdminJailWorld[target]);
    SetPlayerInterior(target, g_AdminJailInterior[target]);
    TogglePlayerControllable(target, 1);
    if(notify) SendClientMessage(target, COLOR_LIME, "Срок административной изоляции завершён.");
    return 1;
}

public AdminModeration_OnConnect(playerid)
{
    g_AdminJailed[playerid] = false;
    g_AdminJailTime[playerid] = 0;
    g_AdminJailWorld[playerid] = 0;
    g_AdminJailInterior[playerid] = 0;
    return 1;
}

public AdminModeration_Tick(playerid)
{
    if(PT[playerid][pMuteTime] > 0) PT[playerid][pMuteTime]--;
    if(!g_AdminJailed[playerid]) return 1;
    if(g_AdminJailTime[playerid] > 0) g_AdminJailTime[playerid]--;
    if(g_AdminJailTime[playerid] <= 0) AdminModeration_Release(playerid);
    return 1;
}

CMD:kick(playerid, params[])
{
    if(!GetAdminLevel(playerid, 2)) return SendErr(playerid, messageUnknownCMD);
    new target, reason[96];
    if(sscanf(params, "us[96]", target, reason)) return SendClientMessage(playerid, COLOR_GRAY, "/kick [id] [причина]");
    if(!AdminModeration_CanAffect(playerid, target)) return 1;
    AdminModeration_Broadcast(playerid, "кикнул", target, reason);
    SetTimerEx("AdminModeration_Kick", 700, false, "i", target);
    return 1;
}

CMD:skick(playerid, params[])
{
    if(!GetAdminLevel(playerid, 2)) return SendErr(playerid, messageUnknownCMD);
    new target, reason[96];
    if(sscanf(params, "us[96]", target, reason)) return SendClientMessage(playerid, COLOR_GRAY, "/skick [id] [причина]");
    if(!AdminModeration_CanAffect(playerid, target)) return 1;
    AdminModeration_Broadcast(playerid, "тихо кикнул", target, reason, true);
    SetTimerEx("AdminModeration_Kick", 700, false, "i", target);
    return 1;
}

CMD:ban(playerid, params[])
{
    if(!GetAdminLevel(playerid, 3)) return SendErr(playerid, messageUnknownCMD);
    new target, days, reason[96];
    if(sscanf(params, "uis[96]", target, days, reason)) return SendClientMessage(playerid, COLOR_GRAY, "/ban [id] [дни] [причина]");
    if(!AdminModeration_CanAffect(playerid, target)) return 1;
    return AdminModeration_Ban(playerid, target, days, reason);
}

CMD:sban(playerid, params[])
{
    if(!GetAdminLevel(playerid, 3)) return SendErr(playerid, messageUnknownCMD);
    new target, days, reason[96];
    if(sscanf(params, "uis[96]", target, days, reason)) return SendClientMessage(playerid, COLOR_GRAY, "/sban [id] [дни] [причина]");
    if(!AdminModeration_CanAffect(playerid, target)) return 1;
    return AdminModeration_Ban(playerid, target, days, reason, true);
}

forward AdminModeration_OnOffBanAccount(playerid, days, reason[], requestedName[]);

CMD:offban(playerid, params[])
{
    if(!GetAdminLevel(playerid, 4)) return SendErr(playerid, messageUnknownCMD);
    new name[MAX_PLAYER_NAME], days, reason[96], query[192];
    if(sscanf(params, "s[24]is[96]", name, days, reason)) return SendClientMessage(playerid, COLOR_GRAY, "/offban [ник] [дни] [причина]");
    if(days < 1 || days > 365) return SendErr(playerid, "Срок бана — от 1 до 365 дней.");
    mysql_format(dbHandle, query, sizeof(query), "SELECT `id`,`name` FROM `accounts` WHERE `name` = '%e' LIMIT 1", name);
    mysql_tquery(dbHandle, query, "AdminModeration_OnOffBanAccount", "iiss", playerid, days, reason, name);
    return 1;
}

public AdminModeration_OnOffBanAccount(playerid, days, reason[], requestedName[])
{
    if(!IsPlayerConnected(playerid) || !GetAdminLevel(playerid, 4)) return 1;
    if(cache_num_rows() < 1) return SendErr(playerid, "Аккаунт с таким ником не найден.");

    new accountName[MAX_PLAYER_NAME];
    cache_get_value_name(0, "name", accountName, sizeof(accountName));
    foreach(new i : Player)
    {
        if(PT[i][pLogged] && !strcmp(PI[i][pName], accountName, true))
            return SendErr(playerid, "Игрок сейчас онлайн. Используйте /ban.");
    }

    new date[16], query[384], year, month, day;
    getdate(year, month, day);
    format(date, sizeof(date), "%02d.%02d.%04d", day, month, year);
    mysql_format(dbHandle, query, sizeof(query), "INSERT INTO `bans` (`name`,`whobanned`,`ip`,`bandate`,`time`,`unbandate`,`reason`) VALUES ('%e','%e','','%e',%d,%d,'%e')", accountName, GetName(playerid), date, days, gettime() + days * 86400, reason);
    mysql_tquery(dbHandle, query, "", "");

    new message[176];
    format(message, sizeof(message), "[A] %s офлайн забанил %s на %d дн. Причина: %s", GetName(playerid), accountName, days, reason);
    SendAdminMessage(COLOR_GRAY, message);
    #pragma unused requestedName
    return 1;
}

CMD:unban(playerid, params[])
{
    if(!GetAdminLevel(playerid, 4)) return SendErr(playerid, messageUnknownCMD);
    new name[MAX_PLAYER_NAME], query[128];
    if(sscanf(params, "s[24]", name)) return SendClientMessage(playerid, COLOR_GRAY, "/unban [ник]");
    mysql_format(dbHandle, query, sizeof(query), "DELETE FROM `bans` WHERE `name` = '%e'", name);
    mysql_tquery(dbHandle, query, "", "");
    new message[100]; format(message, sizeof(message), "[A] %s снял бан с %s", GetName(playerid), name); SendAdminMessage(COLOR_GRAY, message);
    return 1;
}

CMD:banip(playerid, params[])
{
    if(!GetAdminLevel(playerid, 5)) return SendErr(playerid, messageUnknownCMD);
    new ip[24], days, reason[96], date[16], query[384], year, month, day;
    if(sscanf(params, "s[24]is[96]", ip, days, reason)) return SendClientMessage(playerid, COLOR_GRAY, "/banip [ip] [дни] [причина]");
    if(days < 1 || days > 365) return SendErr(playerid, "Срок бана — от 1 до 365 дней.");
    getdate(year, month, day); format(date, sizeof(date), "%02d.%02d.%04d", day, month, year);
    mysql_format(dbHandle, query, sizeof(query), "INSERT INTO `bans` (`name`,`whobanned`,`ip`,`bandate`,`time`,`unbandate`,`reason`) VALUES ('','%e','%e','%e',%d,%d,'%e')", GetName(playerid), ip, date, days, gettime() + days * 86400, reason);
    mysql_tquery(dbHandle, query, "", "");
    new message[176]; format(message, sizeof(message), "[A] %s забанил IP %s на %d дн. Причина: %s", GetName(playerid), ip, days, reason); SendAdminMessage(COLOR_GRAY, message);
    return 1;
}

CMD:unbanip(playerid, params[])
{
    if(!GetAdminLevel(playerid, 5)) return SendErr(playerid, messageUnknownCMD);
    new ip[24], query[128];
    if(sscanf(params, "s[24]", ip)) return SendClientMessage(playerid, COLOR_GRAY, "/unbanip [ip]");
    mysql_format(dbHandle, query, sizeof(query), "DELETE FROM `bans` WHERE `ip` = '%e'", ip);
    mysql_tquery(dbHandle, query, "", "");
    new message[100]; format(message, sizeof(message), "[A] %s снял бан IP %s", GetName(playerid), ip); SendAdminMessage(COLOR_GRAY, message);
    return 1;
}

CMD:mute(playerid, params[])
{
    if(!GetAdminLevel(playerid, 2)) return SendErr(playerid, messageUnknownCMD);
    new target, minutes, reason[96];
    if(sscanf(params, "uis[96]", target, minutes, reason)) return SendClientMessage(playerid, COLOR_GRAY, "/mute [id] [минуты] [причина]");
    if(!AdminModeration_CanAffect(playerid, target)) return 1;
    if(minutes < 1 || minutes > 1440) return SendErr(playerid, "Срок мута — от 1 до 1440 минут.");
    PT[target][pMuteTime] = minutes * 60;
    AdminModeration_Broadcast(playerid, "заблокировал чат", target, reason);
    return 1;
}

CMD:unmute(playerid, params[])
{
    if(!GetAdminLevel(playerid, 2)) return SendErr(playerid, messageUnknownCMD);
    new target;
    if(sscanf(params, "u", target)) return SendClientMessage(playerid, COLOR_GRAY, "/unmute [id]");
    if(!AdminModeration_CanAffect(playerid, target)) return 1;
    PT[target][pMuteTime] = 0;
    new message[128]; format(message, sizeof(message), "[A] %s снял блокировку чата с %s[%d]", GetName(playerid), GetName(target), target); SendAdminMessage(COLOR_GRAY, message);
    SendClientMessage(target, COLOR_LIME, "Администратор снял блокировку чата.");
    return 1;
}

CMD:warn(playerid, params[])
{
    if(!GetAdminLevel(playerid, 2)) return SendErr(playerid, messageUnknownCMD);
    new target, reason[96], query[160];
    if(sscanf(params, "us[96]", target, reason)) return SendClientMessage(playerid, COLOR_GRAY, "/warn [id] [причина]");
    if(!AdminModeration_CanAffect(playerid, target)) return 1;
    PI[target][pWarns]++;
    mysql_format(dbHandle, query, sizeof(query), "UPDATE `accounts` SET `warns` = %d WHERE `id` = %d", PI[target][pWarns], PI[target][pID]);
    mysql_tquery(dbHandle, query, "", "");
    AdminModeration_Broadcast(playerid, "выдал предупреждение", target, reason);
    return 1;
}

CMD:unwarn(playerid, params[])
{
    if(!GetAdminLevel(playerid, 2)) return SendErr(playerid, messageUnknownCMD);
    new target, query[160];
    if(sscanf(params, "u", target)) return SendClientMessage(playerid, COLOR_GRAY, "/unwarn [id]");
    if(!AdminModeration_CanAffect(playerid, target)) return 1;
    if(PI[target][pWarns] <= 0) return SendErr(playerid, "У игрока нет предупреждений.");
    PI[target][pWarns]--;
    mysql_format(dbHandle, query, sizeof(query), "UPDATE `accounts` SET `warns` = %d WHERE `id` = %d", PI[target][pWarns], PI[target][pID]);
    mysql_tquery(dbHandle, query, "", "");
    new message[128]; format(message, sizeof(message), "[A] %s снял предупреждение с %s[%d]", GetName(playerid), GetName(target), target); SendAdminMessage(COLOR_GRAY, message);
    return 1;
}

CMD:jail(playerid, params[])
{
    if(!GetAdminLevel(playerid, 3)) return SendErr(playerid, messageUnknownCMD);
    new target, minutes, reason[96];
    if(sscanf(params, "uis[96]", target, minutes, reason)) return SendClientMessage(playerid, COLOR_GRAY, "/jail [id] [минуты] [причина]");
    if(!AdminModeration_CanAffect(playerid, target)) return 1;
    if(minutes < 1 || minutes > 240) return SendErr(playerid, "Срок изоляции — от 1 до 240 минут.");
    if(g_AdminJailed[target]) return SendErr(playerid, "Игрок уже находится в административной изоляции.");
    g_AdminJailed[target] = true;
    g_AdminJailTime[target] = minutes * 60;
    g_AdminJailWorld[target] = GetPlayerVirtualWorld(target);
    g_AdminJailInterior[target] = GetPlayerInterior(target);
    SetPlayerVirtualWorld(target, 7000 + target);
    TogglePlayerControllable(target, 0);
    AdminModeration_Broadcast(playerid, "поместил в изоляцию", target, reason);
    SendClientMessage(target, COLOR_RED, "Вы помещены в административную изоляцию. Дождитесь окончания срока.");
    return 1;
}

CMD:unjail(playerid, params[])
{
    if(!GetAdminLevel(playerid, 3)) return SendErr(playerid, messageUnknownCMD);
    new target;
    if(sscanf(params, "u", target)) return SendClientMessage(playerid, COLOR_GRAY, "/unjail [id]");
    if(!AdminModeration_CanAffect(playerid, target)) return 1;
    if(!g_AdminJailed[target]) return SendErr(playerid, "Игрок не находится в административной изоляции.");
    AdminModeration_Release(target, false);
    new message[128]; format(message, sizeof(message), "[A] %s выпустил %s[%d] из административной изоляции", GetName(playerid), GetName(target), target); SendAdminMessage(COLOR_GRAY, message);
    SendClientMessage(target, COLOR_LIME, "Администратор снял административную изоляцию.");
    return 1;
}

CMD:ahelp(playerid, params[])
{
    if(!GetAdminLevel(playerid, 1)) return SendErr(playerid, messageUnknownCMD);
    SendClientMessage(playerid, COLOR_LIME, "Админ-команды: /kick /skick /ban /sban /offban /unban /banip /unbanip /mute /unmute /warn /unwarn /jail /unjail");
    SendClientMessage(playerid, COLOR_LIME, "Также: /goto /gethere /freeze /slap /spec /specoff /apanel /admins.");
    return 1;
}


CMD:g(playerid, params[]) return callcmd::goto(playerid, params);
CMD:sp(playerid, params[]) return callcmd::spec(playerid, params);
CMD:re(playerid, params[]) return callcmd::spec(playerid, params);
CMD:spoff(playerid, params[]) return callcmd::specoff(playerid, params);

CMD:unfreeze(playerid, params[])
{
    if(!GetAdminLevel(playerid, 2)) return SendErr(playerid, messageUnknownCMD);
    new target;
    if(sscanf(params, "u", target)) return SendClientMessage(playerid, COLOR_GRAY, "/unfreeze [id]");
    if(!AdminModeration_CanAffect(playerid, target)) return 1;
    TogglePlayerControllable(target, 1);
    new msg[128];
    format(msg, sizeof(msg), "[A] %s снял заморозку с %s[%d]", GetName(playerid), GetName(target), target);
    SendAdminMessage(COLOR_GRAY, msg);
    SendClientMessage(target, COLOR_LIME, "Администратор снял с вас заморозку.");
    return 1;
}

CMD:resguns(playerid, params[])
{
    if(!GetAdminLevel(playerid, 2)) return SendErr(playerid, messageUnknownCMD);
    new target;
    if(sscanf(params, "u", target)) return SendClientMessage(playerid, COLOR_GRAY, "/resguns [id]");
    if(!AdminModeration_CanAffect(playerid, target)) return 1;
    ResetPlayerWeapons(target);
    new msg[128];
    format(msg, sizeof(msg), "[A] %s изъял оружие у %s[%d]", GetName(playerid), GetName(target), target);
    SendAdminMessage(COLOR_GRAY, msg);
    return 1;
}

CMD:allheal(playerid, params[])
{
    #pragma unused params
    if(!GetAdminLevel(playerid, 3)) return SendErr(playerid, messageUnknownCMD);
    foreach(new i : Player) if(PT[i][pLogged]) SetPlayerHealth(i, 100.0);
    new msg[112];
    format(msg, sizeof(msg), "[A] %s восстановил здоровье всем игрокам онлайн", GetName(playerid));
    SendAdminMessage(COLOR_GRAY, msg);
    return 1;
}

CMD:getip(playerid, params[])
{
    if(!GetAdminLevel(playerid, 3)) return SendErr(playerid, messageUnknownCMD);
    new target;
    if(sscanf(params, "u", target)) return SendClientMessage(playerid, COLOR_GRAY, "/getip [id]");
    if(!IsPlayerConnected(target) || !PT[target][pLogged]) return SendErr(playerid, "Игрок не в сети или не авторизован.");
    new msg[112];
    format(msg, sizeof(msg), "%s[%d] | IP: %s | RegIP: %s", GetName(target), target, PI[target][pIP], PI[target][pRegIP]);
    SendClientMessage(playerid, COLOR_LIME, msg);
    return 1;
}

CMD:getpos(playerid, params[])
{
    #pragma unused params
    if(!GetAdminLevel(playerid, 1)) return SendErr(playerid, messageUnknownCMD);
    new Float:x, Float:y, Float:z, Float:a, msg[160];
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);
    format(msg, sizeof(msg), "Pos: %.4f, %.4f, %.4f | angle %.2f | interior %d | world %d", x, y, z, a, GetPlayerInterior(playerid), GetPlayerVirtualWorld(playerid));
    SendClientMessage(playerid, COLOR_LIME, msg);
    return 1;
}

CMD:stat(playerid, params[])
{
    if(!GetAdminLevel(playerid, 1)) return SendErr(playerid, messageUnknownCMD);
    new target;
    if(sscanf(params, "u", target)) return SendClientMessage(playerid, COLOR_GRAY, "/stat [id]");
    if(!IsPlayerConnected(target) || !PT[target][pLogged]) return SendErr(playerid, "Игрок не в сети или не авторизован.");
    new info[512], fractionName[MAX_FRACTIONS_NAME];
    if(PI[target][pFraction] > 0) format(fractionName, sizeof(fractionName), "%s", Fraction[PI[target][pFraction]][fName]);
    else format(fractionName, sizeof(fractionName), "Нет");
    format(info, sizeof(info), "Имя: %s [%d]\nУровень: %d\nДеньги: %s руб.\nБанк: %s руб.\nОрганизация: %s\nРанг: %d\nWarn: %d\nРозыск: %d\nIP: %s", GetName(target), target, PI[target][pLevel], SplitInt(PI[target][pCash]), SplitInt(PI[target][pBank]), fractionName, PI[target][pFractionRank], PI[target][pWarns], PI[target][pWanted], PI[target][pIP]);
    ShowPlayerDialogEx(playerid, dialog_OK, DIALOG_STYLE_MSGBOX, "СТАТИСТИКА ИГРОКА", info, "Закрыть", "");
    return 1;
}
