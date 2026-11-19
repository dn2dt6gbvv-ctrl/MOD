stock GetAdminLevel(playerid, level) return PI[playerid][pAdmin] >= level && PT[playerid][pAlogged];
stock IsPlayerGrandAdmin(playerid) return PI[playerid][pFullAccess] && PT[playerid][pAlogged];
stock SendAdminMessage(color, message[]) foreach(new i : Player) if(PI[i][pAdmin] >= 1) SendClientMessage(i, color, message);

callback::CheckPlayerAdmin(playerid, target_lvl, target_name[])
{
    if(cache_num_rows() <= 0) return SendErr(playerid, "Такого игрока не существует!");
    
    new targetid, lvl;
    cache_get_value_name_int(0, "id", targetid);
    cache_get_value_name_int(0, "level", lvl);

    if(lvl >= 1) return SendErr(playerid, "Игрок уже администратор.");
    
    new password[8];
    GeneratePassword(password, sizeof(password));

    new query[] = "INSERT INTO `admin` (`admin_id`, `level`, `password`, `fullaccess`, `prefix`) VALUES (%d, %d, '%e', 0, '%e') ON DUPLICATE KEY UPDATE `level` = %d, `password` = '%e'";
    new fmt_query[sizeof(query) + 10 + 10 + sizeof(password) + 10 + 10 + sizeof(password) + 10 + sizeof(password)];

    mysql_format(dbHandle, fmt_query, sizeof(fmt_query), query, targetid, target_lvl, password, Admin_Prefixes[target_lvl], target_lvl, password);
    mysql_tquery(dbHandle, fmt_query, "", "");

    new admin_string[144];
    SCMF(playerid, -1, "Вы назначили игрока %s на должность администратора %d уровня. Админ пароль: %s", target_name, target_lvl, password);

    format(admin_string, sizeof admin_string, "Вы были назначены на должность администратора %d уровня игроком %s. Ваш админ пароль: %s", target_lvl, GetName(playerid), password);
    SendMessage(targetid, admin_string, 1);

    admin_string[0] = EOS;
    format(admin_string, sizeof admin_string, "[A] %s %s [%d] назначил игрока %s администратором в офлайне", GetPrefix(playerid), GetName(playerid), playerid, target_name);
    SendAdminMessage(COLOR_GRAY, admin_string);
    return 1;
}
forward CheckPlayerBan(playerid);
forward CheckPlayerBanKick(playerid);
public CheckPlayerBan(playerid)
{
    if(cache_num_rows() <= 0) return 1;

    new banId, unbanTime, reason[96], admin[24];
    cache_get_value_name_int(0, "id", banId);
    cache_get_value_name_int(0, "unbandate", unbanTime);
    cache_get_value_name(0, "reason", reason, sizeof(reason));
    cache_get_value_name(0, "whobanned", admin, sizeof(admin));

    if(unbanTime > gettime())
    {
        new banStr[512];
        format(banStr, sizeof(banStr),
            "{D24D4D}Ваш аккаунт заблокирован.\n\n" \
            "{FFFFFF}Ник администратора: {FF9945}%s\n" \
            "{FFFFFF}Причина: {FF9945}%s\n" \
            "{FFFFFF}Разблокировка: {FF9945}%d\n\n" \
            "{FFFFFF}Если Вы не согласны с наказанием, напишите в поддержку:\n" \
            "{33A9FF}@Unmazingsupport {FFFFFF}(https://t.me/Unmazingsupport)",
            admin, reason, unbanTime);
        ShowPlayerDialogEx(playerid, dialog_OK, DIALOG_STYLE_MSGBOX, "{FF9945}БЛОКИРОВКА", banStr, "Закрыть", "");
        SetTimerEx("CheckPlayerBanKick", 750, false, "i", playerid);
        return 1;
    }

    new delQ[96];
    mysql_format(dbHandle, delQ, sizeof(delQ), "DELETE FROM `bans` WHERE `id` = %d", banId);
    mysql_tquery(dbHandle, delQ, "", "");
    return 1;
}

public CheckPlayerBanKick(playerid)
{
    if(IsPlayerConnected(playerid)) Kick(playerid);
    return 1;
}
stock CheckVipExpire(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;
    if(PI[playerid][pVip] <= 0) return 0;

    if(PI[playerid][pVipExpire] > 0 && gettime() >= PI[playerid][pVipExpire])
    {
        PI[playerid][pVip] = 0;
        PI[playerid][pVipExpire] = 0;

        new query[128];
        mysql_format(dbHandle, query, sizeof(query),
            "UPDATE `accounts` SET `vip` = 0, `vip_expire` = 0 WHERE `id` = %d",
            PI[playerid][pID]);
        mysql_tquery(dbHandle, query, "", "");

        SendClientMessage(playerid, COLOR_RED,
            "Ваш {FFD700}VIP{FFFFFF} статус истёк. Спасибо за поддержку сервера!");

        UpdatePlayerTag(playerid);
    }
    return 1;
}
