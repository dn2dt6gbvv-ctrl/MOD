

stock bool:StaffRoles_ValidPromoCode(const code[])
{
    new length = strlen(code);
    if(length < 3 || length > 24) return false;
    for(new i; i < length; i++)
    {
        if(!(code[i] >= 'A' && code[i] <= 'Z') && !(code[i] >= 'a' && code[i] <= 'z') && !(code[i] >= '0' && code[i] <= '9') && code[i] != '_' && code[i] != '-') return false;
    }
    return true;
}

stock StaffRoles_SetHelper(playerid, targetid, level)
{
    if(!IsPlayerConnected(targetid) || !PT[targetid][pLogged]) return SendErr(playerid, "Игрок не в сети.");
    if(level < 0 || level > STAFF_HELPER_MAX_LEVEL) return SendErr(playerid, "Уровень helper: от 0 до 3.");

    PI[targetid][pHelper] = level;
    if(level > 0) Iter_Add(StaffHelpers, targetid);
    else Iter_Remove(StaffHelpers, targetid);

    new query[160], msg[144];
    mysql_format(dbHandle, query, sizeof(query), "UPDATE `accounts` SET `helper` = %d WHERE `id` = %d LIMIT 1", level, PI[targetid][pID]);
    mysql_tquery(dbHandle, query, "", "");
    UpdatePlayerTag(targetid);

    format(msg, sizeof(msg), "[STAFF] %s[%d] установил helper-уровень %d игроку %s[%d].", GetName(playerid), playerid, level, GetName(targetid), targetid);
    StaffRoles_SendHelperMessage(COLOR_LIME, msg);
    SendAdminMessage(COLOR_GRAY, msg);
    return 1;
}

stock StaffRoles_SetYouTuber(playerid, targetid, level)
{
    if(!IsPlayerConnected(targetid) || !PT[targetid][pLogged]) return SendErr(playerid, "Игрок не в сети.");
    if(level < 0 || level > STAFF_YOUTUBER_MAX_LEVEL) return SendErr(playerid, "Уровень YouTuber: от 0 до 2.");

    PI[targetid][pYouTuber] = level;
    if(level > 0) Iter_Add(StaffYouTubers, targetid);
    else Iter_Remove(StaffYouTubers, targetid);

    new query[192], msg[144];
    mysql_format(dbHandle, query, sizeof(query), "UPDATE `accounts` SET `youtube` = %d, `youtuber_level` = %d WHERE `id` = %d LIMIT 1", level > 0, level, PI[targetid][pID]);
    mysql_tquery(dbHandle, query, "", "");
    UpdatePlayerTag(targetid);

    format(msg, sizeof(msg), "[STAFF] %s[%d] установил YouTuber-уровень %d игроку %s[%d].", GetName(playerid), playerid, level, GetName(targetid), targetid);
    StaffRoles_SendYouTuberMessage(COLOR_LIME, msg);
    SendAdminMessage(COLOR_GRAY, msg);
    return 1;
}

cmd:sethelper(playerid, params[])
{
    if(!StaffRoles_CanManage(playerid)) return SendErr(playerid, messageUnknownCMD);
    new targetid, level;
    if(sscanf(params, "ui", targetid, level)) return SendErr(playerid, "Используйте: /sethelper [id/ник] [0-3]");
    return StaffRoles_SetHelper(playerid, targetid, level);
}

cmd:sethepler(playerid, params[]) return callcmd::sethelper(playerid, params);

cmd:setyoutuber(playerid, params[])
{
    if(!StaffRoles_CanManage(playerid)) return SendErr(playerid, messageUnknownCMD);
    new targetid, level;
    if(sscanf(params, "ui", targetid, level)) return SendErr(playerid, "Используйте: /setyoutuber [id/ник] [0-2]");
    return StaffRoles_SetYouTuber(playerid, targetid, level);
}

cmd:setyt2(playerid, params[]) return callcmd::setyoutuber(playerid, params);
cmd:setyoutube(playerid, params[]) return callcmd::setyoutuber(playerid, params);

cmd:helpers(playerid)
{
    new text[1024], line[80], count;
    format(text, sizeof(text), "Онлайн helpers: %d\n\n", StaffRoles_GetHelpersOnline());
    foreach(new i : StaffHelpers)
    {
        if(!PT[i][pLogged] || PI[i][pHelper] < 1) continue;
        format(line, sizeof(line), "%s [%d] — уровень %d\n", GetName(i), i, PI[i][pHelper]);
        strcat(text, line, sizeof(text));
        count++;
    }
    if(!count) strcat(text, "Сейчас нет helpers онлайн.", sizeof(text));
    ShowPlayerDialogEx(playerid, dialog_OK, DIALOG_STYLE_MSGBOX, "АГЕНТЫ ПОДДЕРЖКИ", text, "Закрыть", "");
    return 1;
}

cmd:youtubers(playerid)
{
    new text[1024], line[80], count;
    format(text, sizeof(text), "Онлайн YouTubers: %d\n\n", StaffRoles_GetYouTubersOnline());
    foreach(new i : StaffYouTubers)
    {
        if(!PT[i][pLogged] || PI[i][pYouTuber] < 1) continue;
        format(line, sizeof(line), "%s [%d] — уровень %d\n", GetName(i), i, PI[i][pYouTuber]);
        strcat(text, line, sizeof(text));
        count++;
    }
    if(!count) strcat(text, "Сейчас нет YouTubers онлайн.", sizeof(text));
    ShowPlayerDialogEx(playerid, dialog_OK, DIALOG_STYLE_MSGBOX, "YOUTUBERS", text, "Закрыть", "");
    return 1;
}

cmd:hc(playerid, params[])
{
    if(!StaffRoles_IsHelper(playerid) && !GetAdminLevel(playerid, 1)) return SendErr(playerid, messageUnknownCMD);
    if(isnull(params)) return SendErr(playerid, "Используйте: /hc [текст]");
    new msg[192];
    format(msg, sizeof(msg), "[HELPER] %s[%d]: %s", GetName(playerid), playerid, params);
    return StaffRoles_SendHelperMessage(0xF6D55CFF, msg);
}

cmd:hchat(playerid, params[]) return callcmd::hc(playerid, params);

cmd:y(playerid, params[])
{
    if(!StaffRoles_IsYouTuber(playerid) && !GetAdminLevel(playerid, 1)) return SendErr(playerid, messageUnknownCMD);
    if(isnull(params)) return SendErr(playerid, "Используйте: /y [текст]");
    new msg[192];
    format(msg, sizeof(msg), "[YOUTUBE] %s[%d]: %s", GetName(playerid), playerid, params);
    return StaffRoles_SendYouTuberMessage(0xFF5555FF, msg);
}

cmd:yc(playerid, params[])
{
    if(!StaffRoles_IsYouTuber(playerid) && !GetAdminLevel(playerid, 1)) return SendErr(playerid, messageUnknownCMD);
    if(isnull(params)) return SendErr(playerid, "Используйте: /yc [текст]");
    new msg[192];
    format(msg, sizeof(msg), "[YOUTUBE-ADMIN] %s[%d]: %s", GetName(playerid), playerid, params);
    SendAdminMessage(0xFF7777FF, msg);
    return StaffRoles_SendYouTuberMessage(0xFF7777FF, msg);
}

cmd:ychat(playerid, params[]) return callcmd::yc(playerid, params);

cmd:ypanel(playerid, params[])
{
    if(!StaffRoles_IsYouTuber(playerid) && !GetAdminLevel(playerid, 1)) return SendErr(playerid, messageUnknownCMD);
    new text[768];
    format(text, sizeof(text), "Ваш уровень YouTuber: %d\n\n/y [текст] — чат YouTubers\n/yc [текст] — чат с администрацией\n/promo create [код] — создать промокод\n/promo [код] — активировать промокод\n/promoinfo [код] — информация о промокоде\n/delpromo [код] — отключить свой промокод\n\nНаграда уровня 1: 100 000 / 10 donate на 5 уровне и 250 000 / 25 donate на 10 уровне.\nНаграда уровня 2: 200 000 / 20 donate и 500 000 / 50 donate.", PI[playerid][pYouTuber]);
    ShowPlayerDialogEx(playerid, dialog_OK, DIALOG_STYLE_MSGBOX, "ПАНЕЛЬ YOUTUBER", text, "Закрыть", "");
    return 1;
}
cmd:youtube(playerid, params[]) return callcmd::ypanel(playerid, params);
cmd:youtuber(playerid, params[]) return callcmd::ypanel(playerid, params);

forward StaffRoles_OnPromoCreateCheck(playerid, code[], level);
public StaffRoles_OnPromoCreateCheck(playerid, code[], level)
{
    if(!IsPlayerConnected(playerid) || !PT[playerid][pLogged]) return 0;
    if(cache_num_rows()) return SendErr(playerid, "Такой промокод уже существует.");
    new r5money = 100000, r5donate = 10, r10money = 250000, r10donate = 25, query[512];
    if(level >= 2) { r5money = 200000; r5donate = 20; r10money = 500000; r10donate = 50; }
    mysql_format(dbHandle, query, sizeof(query), "INSERT INTO `youtuber_promos` (`code`,`owner_id`,`owner_name`,`level`,`reward5_money`,`reward5_credits`,`reward10_money`,`reward10_credits`) VALUES ('%e',%d,'%e',%d,%d,%d,%d,%d)", code, PI[playerid][pID], GetName(playerid), level, r5money, r5donate, r10money, r10donate);
    mysql_tquery(dbHandle, query, "", "");
    SendClientMessage(playerid, COLOR_LIME, "Промокод создан.");
    return 1;
}

forward StaffRoles_OnPromoUseLoaded(playerid, code[]);
public StaffRoles_OnPromoUseLoaded(playerid, code[])
{
    if(!IsPlayerConnected(playerid) || !PT[playerid][pLogged]) return 0;
    if(cache_num_rows() < 1) return SendErr(playerid, "Промокод не найден.");
    new active, ownerId, promoId, query[320];
    cache_get_value_name_int(0, "active", active);
    cache_get_value_name_int(0, "owner_id", ownerId);
    cache_get_value_name_int(0, "id", promoId);
    if(!active) return SendErr(playerid, "Промокод отключён.");
    if(ownerId == PI[playerid][pID]) return SendErr(playerid, "Нельзя активировать свой промокод.");

    mysql_format(dbHandle, query, sizeof(query), "INSERT IGNORE INTO `youtuber_promo_activations` (`account_id`,`player_name`,`promo_id`,`code`) VALUES (%d,'%e',%d,'%e')", PI[playerid][pID], GetName(playerid), promoId, code);
    mysql_tquery(dbHandle, query, "", "");
    mysql_format(dbHandle, query, sizeof(query), "UPDATE `youtuber_promos` SET `activations` = (SELECT COUNT(*) FROM `youtuber_promo_activations` WHERE `promo_id` = %d) WHERE `id` = %d", promoId, promoId);
    mysql_tquery(dbHandle, query, "", "");
    SendClientMessage(playerid, COLOR_LIME, "Промокод активирован. Награды будут выданы на 5 и 10 уровнях.");
    SetTimerEx("StaffRoles_CheckPromoRewards", 200, false, "i", playerid);
    return 1;
}

forward StaffRoles_OnPromoInfoLoaded(playerid, code[]);
public StaffRoles_OnPromoInfoLoaded(playerid, code[])
{
    if(!IsPlayerConnected(playerid) || cache_num_rows() < 1) return SendErr(playerid, "Промокод не найден.");
    new owner[25], text[512], level, activations, active, reward5Money, reward5Credits, reward10Money, reward10Credits;
    cache_get_value_name(0, "owner_name", owner, sizeof(owner));
    cache_get_value_name_int(0, "level", level);
    cache_get_value_name_int(0, "activations", activations);
    cache_get_value_name_int(0, "active", active);
    cache_get_value_name_int(0, "reward5_money", reward5Money);
    cache_get_value_name_int(0, "reward5_credits", reward5Credits);
    cache_get_value_name_int(0, "reward10_money", reward10Money);
    cache_get_value_name_int(0, "reward10_credits", reward10Credits);
    format(text, sizeof(text), "Код: %s\nYouTuber: %s\nУровень: %d\nАктиваций: %d\nСтатус: %s\n\n5 уровень: %d руб. + %d donate\n10 уровень: %d руб. + %d donate", code, owner, level, activations, active ? ("активен") : ("выключен"), reward5Money, reward5Credits, reward10Money, reward10Credits);
    ShowPlayerDialogEx(playerid, dialog_OK, DIALOG_STYLE_MSGBOX, "ИНФОРМАЦИЯ О ПРОМОКОДЕ", text, "Закрыть", "");
    return 1;
}

stock StaffRoles_ShowPromoDialog(playerid)
{
    return ShowPlayerDialogEx(playerid, DIALOG_YT_PROMO, DIALOG_STYLE_INPUT, "ПРОМОКОД UNMAZING", "Введите промокод YouTuber. Награды выдаются на 5 и 10 уровне.", "Активировать", "Закрыть");
}

stock StaffRoles_ActivatePromo(playerid, const code[])
{
    if(!StaffRoles_ValidPromoCode(code)) return SendErr(playerid, "Код: от 3 до 24 символов A-Z, 0-9, _ или -.");
    new query[360];
    mysql_format(dbHandle, query, sizeof(query), "SELECT * FROM `youtuber_promos` WHERE `code` = '%e' LIMIT 1", code);
    mysql_tquery(dbHandle, query, "StaffRoles_OnPromoUseLoaded", "is", playerid, code);
    return 1;
}

cmd:promo(playerid, params[])
{
    if(isnull(params)) return StaffRoles_ShowPromoDialog(playerid);
    new action[16], code[25], query[360];
    sscanf(params, "s[16]s[24]", action, code);
    if(!strcmp(action, "create", true))
    {
        if(!StaffRoles_IsYouTuber(playerid)) return SendErr(playerid, "Промокоды могут создавать только YouTubers.");
        if(!StaffRoles_ValidPromoCode(code)) return SendErr(playerid, "Код: 3-24 символа A-Z, 0-9, _ или -.");
        mysql_format(dbHandle, query, sizeof(query), "SELECT `id` FROM `youtuber_promos` WHERE `code` = '%e' LIMIT 1", code);
        mysql_tquery(dbHandle, query, "StaffRoles_OnPromoCreateCheck", "isi", playerid, code, PI[playerid][pYouTuber]);
        return 1;
    }
    return StaffRoles_ActivatePromo(playerid, action);
}

cmd:promocode(playerid, params[]) return callcmd::promo(playerid, params);

cmd:promoexit(playerid, params[])
{
    #pragma unused params
    if(GetPlayerInterior(playerid) != 1) return SendErr(playerid, "Вы не находитесь в промоцентре.");
    StaffRoles_LeavePromoInterior(playerid);
    return SendClientMessage(playerid, COLOR_UNMAZING, "Вы вышли из промоцентра Unmazing.");
}

cmd:promoinfo(playerid, params[])
{
    if(!StaffRoles_ValidPromoCode(params)) return SendErr(playerid, "Используйте: /promoinfo [код]");
    new query[192];
    mysql_format(dbHandle, query, sizeof(query), "SELECT * FROM `youtuber_promos` WHERE `code` = '%e' LIMIT 1", params);
    mysql_tquery(dbHandle, query, "StaffRoles_OnPromoInfoLoaded", "is", playerid, params);
    return 1;
}

cmd:delpromo(playerid, params[])
{
    if(!StaffRoles_ValidPromoCode(params)) return SendErr(playerid, "Используйте: /delpromo [код]");
    if(!StaffRoles_IsYouTuber(playerid) && !StaffRoles_CanManage(playerid)) return SendErr(playerid, messageUnknownCMD);
    new query[256];
    if(StaffRoles_CanManage(playerid)) mysql_format(dbHandle, query, sizeof(query), "UPDATE `youtuber_promos` SET `active` = 0 WHERE `code` = '%e'", params);
    else mysql_format(dbHandle, query, sizeof(query), "UPDATE `youtuber_promos` SET `active` = 0 WHERE `code` = '%e' AND `owner_id` = %d", params, PI[playerid][pID]);
    mysql_tquery(dbHandle, query, "", "");
    SendClientMessage(playerid, COLOR_LIME, "Промокод отключён, если он принадлежал Вам.");
    return 1;
}
