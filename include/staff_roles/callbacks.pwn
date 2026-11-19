

stock StaffRoles_InitSchema()
{

    mysql_tquery(dbHandle, "ALTER TABLE `accounts` ADD COLUMN IF NOT EXISTS `helper` TINYINT NOT NULL DEFAULT 0", "", "");
    mysql_tquery(dbHandle, "ALTER TABLE `accounts` ADD COLUMN IF NOT EXISTS `youtube` TINYINT NOT NULL DEFAULT 0", "", "");
    mysql_tquery(dbHandle, "ALTER TABLE `accounts` ADD COLUMN IF NOT EXISTS `youtuber_level` TINYINT NOT NULL DEFAULT 0", "", "");
    mysql_tquery(dbHandle, "CREATE TABLE IF NOT EXISTS `youtuber_promos` (`id` INT NOT NULL AUTO_INCREMENT, `code` VARCHAR(24) NOT NULL, `owner_id` INT NOT NULL, `owner_name` VARCHAR(24) NOT NULL DEFAULT '', `level` TINYINT NOT NULL DEFAULT 1, `reward5_money` INT NOT NULL DEFAULT 100000, `reward5_credits` INT NOT NULL DEFAULT 10, `reward10_money` INT NOT NULL DEFAULT 250000, `reward10_credits` INT NOT NULL DEFAULT 25, `activations` INT NOT NULL DEFAULT 0, `active` TINYINT NOT NULL DEFAULT 1, `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (`id`), UNIQUE KEY `uq_youtuber_promos_code` (`code`)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", "", "");
    mysql_tquery(dbHandle, "CREATE TABLE IF NOT EXISTS `youtuber_promo_activations` (`id` INT NOT NULL AUTO_INCREMENT, `account_id` INT NOT NULL, `player_name` VARCHAR(24) NOT NULL DEFAULT '', `promo_id` INT NOT NULL, `code` VARCHAR(24) NOT NULL DEFAULT '', `rewarded5` TINYINT NOT NULL DEFAULT 0, `rewarded10` TINYINT NOT NULL DEFAULT 0, `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (`id`), UNIQUE KEY `uq_youtuber_account_promo` (`account_id`,`promo_id`), KEY `idx_youtuber_promo` (`promo_id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", "", "");
    return 1;
}

stock StaffRoles_OnConnect(playerid)
{
    PI[playerid][pHelper] = 0;
    PI[playerid][pYouTuber] = 0;
    Iter_Remove(StaffHelpers, playerid);
    Iter_Remove(StaffYouTubers, playerid);
    return 1;
}

stock StaffRoles_OnDisconnect(playerid)
{
    Iter_Remove(StaffHelpers, playerid);
    Iter_Remove(StaffYouTubers, playerid);
    return 1;
}

stock StaffRoles_LoadPlayer(playerid)
{
    if(!IsPlayerConnected(playerid) || !PT[playerid][pLogged]) return 0;
    new query[192];
    mysql_format(dbHandle, query, sizeof(query), "SELECT `helper`, `youtube`, `youtuber_level` FROM `accounts` WHERE `id` = %d LIMIT 1", PI[playerid][pID]);
    mysql_tquery(dbHandle, query, "StaffRoles_OnPlayerLoaded", "i", playerid);
    return 1;
}

forward StaffRoles_OnPlayerLoaded(playerid);
public StaffRoles_OnPlayerLoaded(playerid)
{
    if(!IsPlayerConnected(playerid) || !PT[playerid][pLogged]) return 0;
    if(cache_num_rows() < 1) return 0;

    cache_get_value_name_int(0, "helper", PI[playerid][pHelper]);
    cache_get_value_name_int(0, "youtuber_level", PI[playerid][pYouTuber]);
    if(PI[playerid][pYouTuber] < 1)
    {
        new legacyYoutube;
        cache_get_value_name_int(0, "youtube", legacyYoutube);
        if(legacyYoutube > 0) PI[playerid][pYouTuber] = 1;
    }

    if(PI[playerid][pHelper] > STAFF_HELPER_MAX_LEVEL) PI[playerid][pHelper] = STAFF_HELPER_MAX_LEVEL;
    if(PI[playerid][pYouTuber] > STAFF_YOUTUBER_MAX_LEVEL) PI[playerid][pYouTuber] = STAFF_YOUTUBER_MAX_LEVEL;

    if(PI[playerid][pHelper] > 0) Iter_Add(StaffHelpers, playerid);
    else Iter_Remove(StaffHelpers, playerid);
    if(PI[playerid][pYouTuber] > 0) Iter_Add(StaffYouTubers, playerid);
    else Iter_Remove(StaffYouTubers, playerid);

    UpdatePlayerTag(playerid);
    StaffRoles_CheckPromoRewards(playerid);
    return 1;
}

stock StaffRoles_CheckPromoRewards(playerid)
{
    if(!IsPlayerConnected(playerid) || !PT[playerid][pLogged]) return 0;
    new query[224];
    mysql_format(dbHandle, query, sizeof(query), "SELECT a.`promo_id`, a.`code`, a.`rewarded5`, a.`rewarded10`, p.`reward5_money`, p.`reward5_credits`, p.`reward10_money`, p.`reward10_credits` FROM `youtuber_promo_activations` a INNER JOIN `youtuber_promos` p ON p.`id` = a.`promo_id` WHERE a.`account_id` = %d AND p.`active` = 1 LIMIT 1", PI[playerid][pID]);
    mysql_tquery(dbHandle, query, "StaffRoles_OnPromoRewardsLoaded", "i", playerid);
    return 1;
}

stock StaffRoles_AddDonate(playerid, amount)
{
    if(amount <= 0 || !IsPlayerConnected(playerid)) return 0;
    PI[playerid][pDonate] += amount;
    new query[160];
    mysql_format(dbHandle, query, sizeof(query), "UPDATE `accounts` SET `donate` = %d WHERE `id` = %d LIMIT 1", PI[playerid][pDonate], PI[playerid][pID]);
    mysql_tquery(dbHandle, query, "", "");
    return 1;
}

stock StaffRoles_AddMoney(playerid, amount)
{
    if(amount <= 0 || !IsPlayerConnected(playerid)) return 0;
    PI[playerid][pCash] += amount;
    ResetPlayerMoney(playerid);
    GivePlayerMoney(playerid, PI[playerid][pCash]);
    new query[160];
    mysql_format(dbHandle, query, sizeof(query), "UPDATE `accounts` SET `cash` = %d WHERE `id` = %d LIMIT 1", PI[playerid][pCash], PI[playerid][pID]);
    mysql_tquery(dbHandle, query, "", "");
    return 1;
}

forward StaffRoles_OnPromoRewardsLoaded(playerid);
public StaffRoles_OnPromoRewardsLoaded(playerid)
{
    if(!IsPlayerConnected(playerid) || !PT[playerid][pLogged] || cache_num_rows() < 1) return 0;

    new gave, promoId, code[25], rewarded5, rewarded10, query[256];
    cache_get_value_name_int(0, "promo_id", promoId);
    cache_get_value_name(0, "code", code, sizeof(code));
    cache_get_value_name_int(0, "rewarded5", rewarded5);
    cache_get_value_name_int(0, "rewarded10", rewarded10);

    new reward5Money, reward5Credits, reward10Money, reward10Credits;
    cache_get_value_name_int(0, "reward5_money", reward5Money);
    cache_get_value_name_int(0, "reward5_credits", reward5Credits);
    cache_get_value_name_int(0, "reward10_money", reward10Money);
    cache_get_value_name_int(0, "reward10_credits", reward10Credits);

    if(PI[playerid][pLevel] >= 5 && !rewarded5)
    {
        StaffRoles_AddMoney(playerid, reward5Money);
        StaffRoles_AddDonate(playerid, reward5Credits);
        mysql_format(dbHandle, query, sizeof(query), "UPDATE `youtuber_promo_activations` SET `rewarded5` = 1 WHERE `account_id` = %d AND `promo_id` = %d", PI[playerid][pID], promoId);
        mysql_tquery(dbHandle, query, "", "");
        gave = 1;
    }
    if(PI[playerid][pLevel] >= 10 && !rewarded10)
    {
        StaffRoles_AddMoney(playerid, reward10Money);
        StaffRoles_AddDonate(playerid, reward10Credits);
        mysql_format(dbHandle, query, sizeof(query), "UPDATE `youtuber_promo_activations` SET `rewarded10` = 1 WHERE `account_id` = %d AND `promo_id` = %d", PI[playerid][pID], promoId);
        mysql_tquery(dbHandle, query, "", "");
        gave = 1;
    }
    if(gave)
    {
        new msg[128];
        format(msg, sizeof(msg), "Вы получили награду за промокод %s.", code);
        SendClientMessage(playerid, COLOR_LIME, msg);
    }
    return 1;
}

stock StaffRoles_SendHelperMessage(color, const message[])
{
    foreach(new i : Player)
    {
        if(!PT[i][pLogged]) continue;
        if(PI[i][pHelper] > 0 || PI[i][pAdmin] > 0) SendClientMessage(i, color, message);
    }
    return 1;
}

stock StaffRoles_SendYouTuberMessage(color, const message[])
{
    foreach(new i : Player)
    {
        if(!PT[i][pLogged]) continue;
        if(PI[i][pYouTuber] > 0 || PI[i][pAdmin] > 0) SendClientMessage(i, color, message);
    }
    return 1;
}

stock StaffRoles_GetHelpersOnline()
{
    new count;
    foreach(new i : StaffHelpers) if(PT[i][pLogged] && PI[i][pHelper] > 0) count++;
    return count;
}

stock StaffRoles_GetYouTubersOnline()
{
    new count;
    foreach(new i : StaffYouTubers) if(PT[i][pLogged] && PI[i][pYouTuber] > 0) count++;
    return count;
}
