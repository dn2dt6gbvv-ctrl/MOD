#if defined _cef_progress_included
    #endinput
#endif
#define _cef_progress_included











#define CEF_PERKS_MAX   65
#define CEF_TASKS_MAX   3

enum E_CEF_TASK { taskGoal, taskReward, taskName[128] }

static const gCefTasks[CEF_TASKS_MAX][E_CEF_TASK] = {
    {3,  25000,  "Заработать деньги 3 раза"},
    {5,  35000,  "Проехать 5 маршрутов или заказов"},
    {1,  15000,  "Открыть кейс"}
};

new gCefPerkLevel[MAX_PLAYERS][CEF_PERKS_MAX];
new gCefPerkPrice = 5;
new gCefTaskProgress[MAX_PLAYERS][CEF_TASKS_MAX];
new bool:gCefTaskDone[MAX_PLAYERS][CEF_TASKS_MAX];
new gCefPrizeCount[MAX_PLAYERS];
#define CEF_PRIZE_CATS 10
new gCefPrizeCat[MAX_PLAYERS][CEF_PRIZE_CATS];







forward CEF_NeedsLoad(playerid);
forward CEF_SkinsLoad(playerid);
#define CEF_CUR_AMAZING   3
#define CEF_CUR_CREDIT    4
#define CEF_CUR_VOUCHER   5
#define CEF_CUR_CHIPS     6

new gCefCurrency[MAX_PLAYERS][7];

stock CEF_CurrencyInit()
{
    new q[300];
    format(q, sizeof q, "CREATE TABLE IF NOT EXISTS `player_currency` (`owner_id` INT NOT NULL, `currency` INT NOT NULL, `amount` INT NOT NULL DEFAULT 0, PRIMARY KEY(`owner_id`,`currency`)) DEFAULT CHARSET=utf8");
    mysql_tquery(dbHandle, q);
    return 1;
}

forward OnCefCurrencyLoaded(playerid);
public OnCefCurrencyLoaded(playerid)
{
    new rows = cache_num_rows(), cur, amount;
    if(!IsPlayerConnected(playerid)) return 0;
    for(new i = 0; i < 7; i++) gCefCurrency[playerid][i] = 0;
    for(new i = 0; i < rows; i++)
    {
        cache_get_value_name_int(i, "currency", cur);
        cache_get_value_name_int(i, "amount", amount);
        if(cur >= 0 && cur < 7) gCefCurrency[playerid][cur] = amount;
    }
    if(PI[playerid][pDonate] > gCefCurrency[playerid][CEF_CUR_AMAZING])
        gCefCurrency[playerid][CEF_CUR_AMAZING] = PI[playerid][pDonate];
    CEF_CurrencySend(playerid);
    CEF_NeedsLoad(playerid);
    CEF_SkinsLoad(playerid);
    CEF_SpaOwnLoad(playerid);
    return 1;
}

stock CEF_CurrencyLoad(playerid)
{
    CEF_NeedsReset(playerid);
    gCefFineN[playerid] = 0;
    gCefFineSum[playerid] = 0;
    gCefMilitary[playerid] = 0;
    new q[160];
    mysql_format(dbHandle, q, sizeof q, "SELECT * FROM `player_currency` WHERE `owner_id`=%d", PI[playerid][pID]);
    mysql_tquery(dbHandle, q, "OnCefCurrencyLoaded", "d", playerid);
    return 1;
}

stock CEF_CurrencySend(playerid)
{
    static json[360];
    if(PI[playerid][pDonate] > gCefCurrency[playerid][CEF_CUR_AMAZING])
        gCefCurrency[playerid][CEF_CUR_AMAZING] = PI[playerid][pDonate];

    format(json, sizeof json,
        "{\"money\":%d,\"bank\":%d,\"donate\":%d,\"voucher\":%d}",
        PI[playerid][pCash], PI[playerid][pBank],
        gCefCurrency[playerid][CEF_CUR_AMAZING],
        gCefCurrency[playerid][CEF_CUR_VOUCHER]);
    return CEF_Send(playerid, "cef_account_balances_update", json);
}

stock CEF_CurrencyGive(playerid, currency, amount)
{
    new q[220], msg[128];
    if(currency < 0 || currency > 6 || !amount) return 0;
    gCefCurrency[playerid][currency] += amount;
    if(gCefCurrency[playerid][currency] < 0) gCefCurrency[playerid][currency] = 0;
    mysql_format(dbHandle, q, sizeof q,
        "INSERT INTO `player_currency` (`owner_id`,`currency`,`amount`) VALUES (%d,%d,%d) ON DUPLICATE KEY UPDATE `amount`=%d",
        PI[playerid][pID], currency, gCefCurrency[playerid][currency], gCefCurrency[playerid][currency]);
    mysql_tquery(dbHandle, q);
    CEF_CurrencySend(playerid);
    if(currency == CEF_CUR_AMAZING)
    {
        PI[playerid][pDonate] = gCefCurrency[playerid][currency];
        if(amount > 0)
        {
            format(msg, sizeof msg, "Амазинги: +%d (всего %d)", amount, gCefCurrency[playerid][currency]);
            CEFC_Notify(playerid, msg, "success");
        }
    }
    return 1;
}

CMD:balance(playerid, params[])
{
    #pragma unused params
    static msg[160];
    CEF_CurrencySend(playerid);
    format(msg, sizeof msg, "Наличные %d | Банк %d | Амазинги %d | Кредиты %d | Ваучеры %d | Фишки %d",
        PI[playerid][pCash], PI[playerid][pBank], gCefCurrency[playerid][CEF_CUR_AMAZING],
        gCefCurrency[playerid][CEF_CUR_CREDIT], gCefCurrency[playerid][CEF_CUR_VOUCHER],
        gCefCurrency[playerid][CEF_CUR_CHIPS]);
    SendClientMessage(playerid, 0x54B367FF, msg);
    return 1;
}

CMD:givecur(playerid, params[])
{
    new spec[] = "ddd", target, cur, amount, err[64];
    if(PI[playerid][pAdmin] < 6)
    {
        err = "Нужен админ 6+";
        return SendErr(playerid, err);
    }
    if(sscanf(params, spec, target, cur, amount))
    {
        err = "/givecur [id] [валюта 3-6] [кол-во]";
        return SendErr(playerid, err);
    }
    if(!IsPlayerConnected(target))
    {
        err = "Игрок не найден.";
        return SendErr(playerid, err);
    }
    CEF_CurrencyGive(target, cur, amount);
    return 1;
}





stock CEF_ProgressInit()
{
    new q[400];
    format(q, sizeof q, "CREATE TABLE IF NOT EXISTS `player_perks` (`owner_id` INT NOT NULL, `perk_id` INT NOT NULL, `level` INT NOT NULL DEFAULT 0, PRIMARY KEY(`owner_id`,`perk_id`)) DEFAULT CHARSET=utf8");
    mysql_tquery(dbHandle, q);
    format(q, sizeof q, "CREATE TABLE IF NOT EXISTS `player_tasks` (`owner_id` INT NOT NULL, `task_id` INT NOT NULL, `progress` INT NOT NULL DEFAULT 0, `done` INT NOT NULL DEFAULT 0, `day` INT NOT NULL DEFAULT 0, PRIMARY KEY(`owner_id`,`task_id`)) DEFAULT CHARSET=utf8");
    mysql_tquery(dbHandle, q);
    format(q, sizeof q, "CREATE TABLE IF NOT EXISTS `player_prizes` (`owner_id` INT NOT NULL, `cat` INT NOT NULL, `amount` INT NOT NULL DEFAULT 0, PRIMARY KEY(`owner_id`,`cat`)) DEFAULT CHARSET=utf8");
    mysql_tquery(dbHandle, q);
    print("[CEF-PROGRESS] таблицы player_perks, player_tasks, player_prizes готовы");
    return 1;
}

forward OnCefPerksLoaded(playerid);
public OnCefPerksLoaded(playerid)
{
    new rows = cache_num_rows(), pid, lvl;
    if(!IsPlayerConnected(playerid)) return 0;
    for(new i = 0; i < CEF_PERKS_MAX; i++) gCefPerkLevel[playerid][i] = 0;
    for(new i = 0; i < rows; i++)
    {
        cache_get_value_name_int(i, "perk_id", pid);
        cache_get_value_name_int(i, "level", lvl);
        if(pid >= 0 && pid < CEF_PERKS_MAX) gCefPerkLevel[playerid][pid] = lvl;
    }
    CEF_PerksSend(playerid);
    return 1;
}

forward OnCefTasksLoaded(playerid);
public OnCefTasksLoaded(playerid)
{
    new rows = cache_num_rows(), tid, prog, done, day, today = getdate();
    if(!IsPlayerConnected(playerid)) return 0;
    for(new i = 0; i < CEF_TASKS_MAX; i++)
    {
        gCefTaskProgress[playerid][i] = 0;
        gCefTaskDone[playerid][i] = false;
    }
    for(new i = 0; i < rows; i++)
    {
        cache_get_value_name_int(i, "task_id", tid);
        cache_get_value_name_int(i, "progress", prog);
        cache_get_value_name_int(i, "done", done);
        cache_get_value_name_int(i, "day", day);
        if(tid < 0 || tid >= CEF_TASKS_MAX) continue;
        if(day != today) continue;
        gCefTaskProgress[playerid][tid] = prog;
        gCefTaskDone[playerid][tid] = (done != 0);
    }
    CEF_TasksSend(playerid);
    return 1;
}

stock CEF_ProgressLoad(playerid)
{
    new q[160];
    for(new i = 0; i < CEF_PRIZE_CATS; i++) gCefPrizeCat[playerid][i] = 0;
    mysql_format(dbHandle, q, sizeof q, "SELECT * FROM `player_perks` WHERE `owner_id`=%d", PI[playerid][pID]);
    mysql_tquery(dbHandle, q, "OnCefPerksLoaded", "d", playerid);
    mysql_format(dbHandle, q, sizeof q, "SELECT * FROM `player_tasks` WHERE `owner_id`=%d", PI[playerid][pID]);
    mysql_tquery(dbHandle, q, "OnCefTasksLoaded", "d", playerid);
    mysql_format(dbHandle, q, sizeof q, "SELECT `cat`,`amount` FROM `player_prizes` WHERE `owner_id`=%d", PI[playerid][pID]);
    mysql_tquery(dbHandle, q, "OnCefPrizesLoaded", "d", playerid);
    return 1;
}

forward OnCefPrizesLoaded(playerid);
public OnCefPrizesLoaded(playerid)
{
    new rows, cat, amt;
    if(!IsPlayerConnected(playerid)) return 0;
    for(new i = 0; i < CEF_PRIZE_CATS; i++) gCefPrizeCat[playerid][i] = 0;
    rows = cache_num_rows();
    for(new i = 0; i < rows; i++)
    {
        cache_get_value_name_int(i, "cat", cat);
        cache_get_value_name_int(i, "amount", amt);
        if(cat >= 0 && cat < CEF_PRIZE_CATS && amt > 0) gCefPrizeCat[playerid][cat] = amt;
    }
    return 1;
}




stock CEF_PerkPoints(playerid)
{
    new spent = 0;
    for(new i = 0; i < CEF_PERKS_MAX; i++) spent += gCefPerkLevel[playerid][i];
    new total = PI[playerid][pLevel] / 2;
    return (total > spent) ? (total - spent) : 0;
}

stock CEF_PerksSend(playerid)
{



    static json[6500], part[80];
    new first = 1;
    json = "{\"perks\":[";
    for(new i = 0; i < CEF_PERKS_MAX; i++)
    {
        format(part, sizeof part, "%s{\"id\":%d,\"level\":%d,\"maxLevel\":1,\"isActive\":%s,\"priceCoins\":%d}",
            first ? ("") : (","), i, gCefPerkLevel[playerid][i],
            (gCefPerkLevel[playerid][i] > 0) ? ("true") : ("false"), gCefPerkPrice);
        strcat(json, part);
        first = 0;
    }
    format(part, sizeof part, "],\"myQuestCoins\":%d,\"points\":%d,\"availablePoints\":%d,",
        gCefCurrency[playerid][CEF_CUR_VOUCHER], CEF_PerkPoints(playerid), CEF_PerkPoints(playerid));
    strcat(json, part);
    strcat(json, "\"extraSlotInfo\":{\"used\":0,\"total\":3,\"priceCoins\":1000,\"priceMoney\":5000000}}");
    return CEF_Send(playerid, "perks_update", json);
}

stock CEF_PerkBuy(playerid, perkId)
{
    new q[200], msg[144];
    if(perkId < 0 || perkId >= CEF_PERKS_MAX) return CEFC_Notify(playerid, "Такого навыка нет.", "error");
    if(gCefPerkLevel[playerid][perkId] > 0) return CEFC_Notify(playerid, "Навык уже изучен.", "hint");
    if(gCefCurrency[playerid][CEF_CUR_VOUCHER] < gCefPerkPrice)
    {
        format(msg, sizeof msg, "Нужно %d спец. очков. Их дают за задания и кейсы.", gCefPerkPrice);
        return CEFC_Notify(playerid, msg, "error");
    }
    CEF_CurrencyGive(playerid, CEF_CUR_VOUCHER, -gCefPerkPrice);
    gCefPerkLevel[playerid][perkId] = 1;
    mysql_format(dbHandle, q, sizeof q,
        "INSERT INTO `player_perks` (`owner_id`,`perk_id`,`level`) VALUES (%d,%d,1) ON DUPLICATE KEY UPDATE `level`=1",
        PI[playerid][pID], perkId);
    mysql_tquery(dbHandle, q);
    CEFC_Notify(playerid, "Навык изучен.", "success");
    CEF_PerksSend(playerid);
    CEFC_HudUpdate(playerid);
    return 1;
}




stock CEF_PerkBonusHealth(playerid)  return gCefPerkLevel[playerid][5] * 15;
stock CEF_PerkBonusArmour(playerid)  return gCefPerkLevel[playerid][6] * 15;
stock CEF_PerkBonusSalary(playerid, base) return base + (base * gCefPerkLevel[playerid][8] * 10) / 100;
stock CEF_PerkShopDiscount(playerid, price) return price - (price * gCefPerkLevel[playerid][8] * 7) / 100;
stock CEF_PerkRepairDiscount(playerid, price) return price - (price * (gCefPerkLevel[playerid][9] + gCefPerkLevel[playerid][13]) * 10) / 100;
stock CEF_PerkFuelBonus(playerid) return gCefPerkLevel[playerid][14] * 10;




new gCefTaskDay[MAX_PLAYERS];

stock CEF_TasksDailyReset(playerid)
{
    new day = gettime() / 86400;
    if(gCefTaskDay[playerid] == day) return 0;
    gCefTaskDay[playerid] = day;
    for(new i = 0; i < CEF_TASKS_MAX; i++)
    {
        gCefTaskProgress[playerid][i] = 0;
        gCefTaskDone[playerid][i] = false;
    }
    return 1;
}

stock CEF_TasksSend(playerid)
{
    CEF_TasksDailyReset(playerid);





    static json[2048], part[260], award[64];
    new first = 1, done = 0;
    json = "{\"private\":{\"tasks\":[";
    for(new i = 0; i < CEF_TASKS_MAX; i++)
    {
        format(part, sizeof part,
            "%s{\"id\":%d,\"title\":\"%s\",\"description\":\"Награда %d руб.\",\"progress\":{\"current\":%d,\"max\":%d}}",
            first ? ("") : (","), i, gCefTasks[i][taskName], gCefTasks[i][taskReward],
            gCefTaskProgress[playerid][i], gCefTasks[i][taskGoal]);
        strcat(json, part);
        first = 0;
        if(gCefTaskDone[playerid][i]) done++;
    }
    format(award, sizeof award, "%d руб. за все задания", gCefTasks[0][taskReward] + gCefTasks[1][taskReward] + gCefTasks[2][taskReward]);
    format(part, sizeof part, "],\"mission\":{\"progress\":{\"current\":%d,\"max\":%d},\"award\":\"%s\"}},\"organization\":null}",
        done, CEF_TASKS_MAX, award);
    strcat(json, part);
    return CEF_Send(playerid, "daily_tasks_update", json);
}

stock CEF_TaskProgress(playerid, taskId, amount = 1)
{
    new idx = taskId, q[220], msg[160];
    if(idx < 0 || idx >= CEF_TASKS_MAX) return 0;
    if(gCefTaskDone[playerid][idx]) return 0;

    gCefTaskProgress[playerid][idx] += amount;
    if(gCefTaskProgress[playerid][idx] >= gCefTasks[idx][taskGoal])
    {
        gCefTaskProgress[playerid][idx] = gCefTasks[idx][taskGoal];
        gCefTaskDone[playerid][idx] = true;
        PI[playerid][pBank] += gCefTasks[idx][taskReward];
        CEF_EcoSaveMoney(playerid);
        CEF_CurrencyGive(playerid, CEF_CUR_AMAZING, 5);
        CEF_CurrencyGive(playerid, CEF_CUR_VOUCHER, 2);
        format(msg, sizeof msg, "Задание выполнено: %s. Награда %d руб. и 5 амазингов.",
            gCefTasks[idx][taskName], gCefTasks[idx][taskReward]);
        CEFC_Notify(playerid, msg, "congratulate", 7000);
        CEFC_AccountStats(playerid);
    }
    mysql_format(dbHandle, q, sizeof q,
        "INSERT INTO `player_tasks` (`owner_id`,`task_id`,`progress`,`done`,`day`) VALUES (%d,%d,%d,%d,%d) ON DUPLICATE KEY UPDATE `progress`=%d,`done`=%d,`day`=%d",
        PI[playerid][pID], idx, gCefTaskProgress[playerid][idx], gCefTaskDone[playerid][idx] ? 1 : 0, getdate(),
        gCefTaskProgress[playerid][idx], gCefTaskDone[playerid][idx] ? 1 : 0, getdate());
    mysql_tquery(dbHandle, q);
    CEF_TasksSend(playerid);
    return 1;
}






stock CEF_PrizeTitle(cat, dest[], size)
{
    dest[0] = EOS;
    switch(cat)
    {
        case 0: strcat(dest, "Infernus", size);
        case 1: strcat(dest, "Маска", size);
        case 2: strcat(dest, "100000 рублей", size);
        case 3: strcat(dest, "Набор тюнинга", size);
        case 4: strcat(dest, "+1 уровень", size);
        case 5: strcat(dest, "PLUS 30 дней", size);
        case 6: strcat(dest, "Скин", size);
        case 7: strcat(dest, "Все лицензии", size);
        case 8: strcat(dest, "10 спец. очков", size);
        case 9: strcat(dest, "50 амазингов", size);
        default: strcat(dest, "Приз", size);
    }
    return 1;
}

stock CEF_PrizeSave(playerid, cat)
{
    new q[220];
    if(cat < 0 || cat >= CEF_PRIZE_CATS) return 0;
    mysql_format(dbHandle, q, sizeof q,
        "INSERT INTO `player_prizes` (`owner_id`,`cat`,`amount`) VALUES (%d,%d,%d) ON DUPLICATE KEY UPDATE `amount`=%d",
        PI[playerid][pID], cat, gCefPrizeCat[playerid][cat], gCefPrizeCat[playerid][cat]);
    mysql_tquery(dbHandle, q);
    return 1;
}

stock CEF_PrizeGive(playerid, cat, amount)
{
    if(cat < 0 || cat >= CEF_PRIZE_CATS) return 0;
    if(amount < 1) amount = 1;
    gCefPrizeCat[playerid][cat] += amount;
    CEF_PrizeSave(playerid, cat);
    CEF_PrizesSend(playerid, false);
    return 1;
}

stock CEF_PrizeApply(playerid, cat)
{
    new Float:x, Float:y, Float:z, Float:a, vid, msg[144], title[40];
    CEF_PrizeTitle(cat, title, sizeof title);
    switch(cat)
    {
        case 0:
        {
            GetPlayerPos(playerid, x, y, z);
            GetPlayerFacingAngle(playerid, a);
            vid = CreateVehicle(411, x + 3.0, y, z, a, 1, 1, 600);
            SetVehicleVirtualWorld(vid, GetPlayerVirtualWorld(playerid));
            LinkVehicleToInterior(vid, GetPlayerInterior(playerid));
        }
        case 1: GiveItem(playerid, 13, 1);
        case 2:
        {
            PI[playerid][pCash] += 100000;
            CEF_EcoSaveMoney(playerid);
        }
        case 3:
        {
            PI[playerid][pCash] += 50000;
            CEF_EcoSaveMoney(playerid);
        }
        case 4:
        {
            PI[playerid][pLevel] += 1;
            SetPlayerScore(playerid, PI[playerid][pLevel]);
        }
        case 5:
        {
            PI[playerid][pVip] = 1;
            PI[playerid][pVipExpire] = gettime() + 30 * 24 * 3600;
        }
        case 6: CEF_SkinGive(playerid, 214);
        case 7:
        {
            PI[playerid][pLicenseA] = 1;
            PI[playerid][pLicenseB] = 1;
            PI[playerid][pLicenseC] = 1;
            PI[playerid][pLicenseWeapon] = 1;
            PI[playerid][pLicenseFlight] = 1;
            PI[playerid][pLicenseBusiness] = 1;
        }
        case 8: CEF_CurrencyGive(playerid, CEF_CUR_VOUCHER, 10);
        case 9: CEF_CurrencyGive(playerid, CEF_CUR_AMAZING, 50);
    }
    SavePlayerInventory(playerid);
    CEF_InvSync(playerid);
    CEFC_AccountStats(playerid);
    format(msg, sizeof msg, "Получен приз: %s", title);
    CEFC_Notify(playerid, msg, "congratulate", 6000);
    return 1;
}

stock CEF_PrizeClaim(playerid, cat)
{
    if(cat < 0 || cat >= CEF_PRIZE_CATS) return 0;
    if(cat == 1 && !CEF_InvCanGive(playerid, 13, 1))
        return CEFC_Notify(playerid, "Inventory is full; free a slot before claiming this reward.", "error");
    if(gCefPrizeCat[playerid][cat] <= 0) return 0;
    gCefPrizeCat[playerid][cat]--;
    CEF_PrizeSave(playerid, cat);
    CEF_PrizeApply(playerid, cat);
    CEF_PrizesSend(playerid, false);
    return 1;
}

stock CEF_PrizeSendCat(playerid, cat)
{
    static json[360], title[40];
    new n;
    if(cat < 0 || cat >= CEF_PRIZE_CATS) return 0;
    n = gCefPrizeCat[playerid][cat];
    CEF_PrizeTitle(cat, title, sizeof title);
    format(json, sizeof json,
        "{\"id\":%d,\"available\":%d,\"count\":%d,\"prizes\":[{\"id\":%d,\"category\":%d,\"title\":\"%s\",\"name\":\"%s\",\"amount\":%d,\"count\":%d}]}",
        cat, n, n, 100 + cat, cat, title, title, n, n);
    CEF_Send(playerid, "cef_prize_menu_upd_category", json);
    return 1;
}

stock CEF_PrizesSend(playerid, bool:openTab = true)
{
    static json[1400], part[180], title[40];
    new i, n, total;
    json = "{\"categories\":[";
    for(i = 0; i < CEF_PRIZE_CATS; i++)
    {
        n = gCefPrizeCat[playerid][i];
        total += n;
        CEF_PrizeTitle(i, title, sizeof title);
        format(part, sizeof part,
            "%s{\"id\":%d,\"available\":%d,\"count\":%d,\"amount\":%d}",
            (i == 0) ? ("") : (","), i, n, n, n);
        strcat(json, part, sizeof json);
    }
    strcat(json, "],\"prizes\":[", sizeof json);
    new first = 1;
    for(i = 0; i < CEF_PRIZE_CATS; i++)
    {
        n = gCefPrizeCat[playerid][i];
        if(n <= 0) continue;
        CEF_PrizeTitle(i, title, sizeof title);
        format(part, sizeof part,
            "%s{\"id\":%d,\"category\":%d,\"title\":\"%s\",\"name\":\"%s\",\"amount\":%d,\"count\":%d}",
            first ? ("") : (","), 100 + i, i, title, title, n, n);
        strcat(json, part, sizeof json);
        first = 0;
    }
    strcat(json, "]}", sizeof json);
    gCefPrizeCount[playerid] = total;
    CEF_MarkPlayerReady(playerid);
    if(openTab) CEF_Send(playerid, "menu_open", "{\"tab\":11}");
    CEF_Send(playerid, "cef_prize_menu_show", json);
    for(i = 0; i < CEF_PRIZE_CATS; i++)
    {
        n = gCefPrizeCat[playerid][i];
        CEF_PrizeTitle(i, title, sizeof title);
        format(part, sizeof part,
            "{\"id\":%d,\"available\":%d,\"count\":%d,\"prizes\":[{\"id\":%d,\"category\":%d,\"title\":\"%s\",\"name\":\"%s\",\"amount\":%d}]}",
            i, n, n, 100 + i, i, title, title, n);
        CEF_Send(playerid, "cef_prize_menu_upd_category", part);
    }
    if(openTab) CEF_Focus(playerid, true);
    return 1;
}

stock CEF_PrizesResponse(playerid, const arguments[])
{
    new key = CEF_EcoFindInt(arguments, "key");
    new id = CEF_EcoFindInt(arguments, "id");
    new sel = CEF_EcoFindInt(arguments, "selected");
    new prize = CEF_EcoFindInt(arguments, "prizeId");
    new cat = CEF_EcoFindInt(arguments, "category");
    new dataid = CEF_EcoFindInt(arguments, "data");
    if(strfind(arguments, "category", true) == -1) cat = -1;
    if(cat < 0) cat = CEF_EcoFindInt(arguments, "categoryId");
    if(!id) id = sel;
    if(!id) id = prize;
    if(!id) id = dataid;
    printf("[CEF-PRIZE] %d key=%d id=%d cat=%d args=%s", playerid, key, id, cat, arguments);

    if(key == 1 && id <= 0 && prize <= 0)
        return 1;

    if(prize >= 100 && prize < 100 + CEF_PRIZE_CATS) cat = prize - 100;
    if(id >= 100 && id < 100 + CEF_PRIZE_CATS) cat = id - 100;
    if(cat < 0 && id >= 0 && id < CEF_PRIZE_CATS) cat = id;

    if(cat >= 0 && cat < CEF_PRIZE_CATS)
    {
        if(key == 3 || prize >= 100 || strfind(arguments, "take", true) != -1 || strfind(arguments, "claim", true) != -1)
            return CEF_PrizeClaim(playerid, cat);
        if(gCefPrizeCat[playerid][cat] > 0 && (key == 2 || key == 4 || key == 0))
        {
            CEF_PrizeSendCat(playerid, cat);
            if(key == 4) return CEF_PrizeClaim(playerid, cat);
            return 1;
        }
        if(gCefPrizeCat[playerid][cat] > 0)
            return CEF_PrizeClaim(playerid, cat);
        return CEF_PrizeSendCat(playerid, cat);
    }
    CEF_PrizesSend(playerid, false);
    return 1;
}

stock CEF_PerksResponse(playerid, const arguments[])
{
    new id = CEF_EcoFindInt(arguments, "selected");
    if(strfind(arguments, "selected", true) == -1) return CEF_PerksSend(playerid);
    return CEF_PerkBuy(playerid, id);
}

stock CEF_TasksResponse(playerid, const arguments[])
{
    #pragma unused arguments
    if(CEF_TasksDailyReset(playerid))
        CEFC_Notify(playerid, "Ежедневные задания обновлены.", "success");
    else
        CEFC_Notify(playerid, "Задания обновляются раз в сутки (00:00).", "hint");
    return CEF_TasksSend(playerid);
}




CMD:perks(playerid, params[])
{
    static msg[160];
    new spec[] = "d", id;
    CEF_PerksSend(playerid);
    CEF_Send(playerid, "menu_open", "{\"tab\":8}");
    CEF_Focus(playerid, true);
    if(!sscanf(params, spec, id)) return CEF_PerkBuy(playerid, id);
    format(msg, sizeof msg, "Навыки открыты. Спец. очков: %d (за задания и кейсы). Покупка: клик по навыку или /perks [id]",
        gCefCurrency[playerid][CEF_CUR_VOUCHER]);
    SendClientMessage(playerid, 0x54B367FF, msg);
    return 1;
}

CMD:tasks(playerid, params[])
{
    #pragma unused params
    static msg[160];
    CEFC_MenuBegin(playerid);
    CEF_TasksSend(playerid);
    CEF_Send(playerid, "menu_open", "{\"tab\":7}");
    CEF_Focus(playerid, true);
    for(new i = 0; i < CEF_TASKS_MAX; i++)
    {
        format(msg, sizeof msg, "%s: %d/%d%s", gCefTasks[i][taskName],
            gCefTaskProgress[playerid][i], gCefTasks[i][taskGoal],
            gCefTaskDone[playerid][i] ? (" - выполнено") : (""));
        SendClientMessage(playerid, 0x54B367FF, msg);
    }
    return 1;
}

CMD:prizes(playerid, params[])
{
    #pragma unused params
    return CEF_PrizesSend(playerid);
}

stock CEF_PerksDialog(playerid, dialogid, response, listitem)
{

    if(dialogid != DIALOG_CEF_PERKS) return 0;
    if(!response) return 1;
    return CEF_PerkBuy(playerid, listitem);
}
