#if defined _cef_needs_included
    #endinput
#endif
#define _cef_needs_included




#define NEED_EAT      0
#define NEED_WATER    1
#define NEED_WC       2
#define NEED_HYGIENE  3
#define NEED_PSYCHO   4

new gNeedSec;
new gNeedSaveTick[MAX_PLAYERS];
new bool:gNeedReady[MAX_PLAYERS];

stock CEF_NeedsFeed(playerid, eatAdd, waterAdd)
{
    gNeedEat[playerid] += eatAdd;
    gNeedWater[playerid] += waterAdd;
    if(gNeedEat[playerid] < 0) gNeedEat[playerid] = 0;
    if(gNeedEat[playerid] > 100) gNeedEat[playerid] = 100;
    if(gNeedWater[playerid] < 0) gNeedWater[playerid] = 0;
    if(gNeedWater[playerid] > 100) gNeedWater[playerid] = 100;
    return 1;
}

stock CEF_NeedsInit()
{
    new q[360];
    format(q, sizeof q,
        "CREATE TABLE IF NOT EXISTS `player_needs` (`owner_id` INT NOT NULL PRIMARY KEY, `eat` INT NOT NULL DEFAULT 100, `water` INT NOT NULL DEFAULT 100, `wc` INT NOT NULL DEFAULT 100, `hygiene` INT NOT NULL DEFAULT 100, `psycho` INT NOT NULL DEFAULT 100) DEFAULT CHARSET=utf8");
    mysql_tquery(dbHandle, q);
    print("[CEF-NEED] таблица player_needs готова");
    return 1;
}

stock CEF_NeedsReset(playerid)
{
    gNeedEat[playerid] = 100;
    gNeedWater[playerid] = 100;
    gNeedWC[playerid] = 100;
    gNeedHygiene[playerid] = 100;
    gNeedPsycho[playerid] = 100;
    gNeedSaveTick[playerid] = 0;
    gNeedReady[playerid] = false;
    return 1;
}

stock CEF_NeedsClamp(playerid)
{
    if(gNeedEat[playerid] < 0) gNeedEat[playerid] = 0;
    if(gNeedEat[playerid] > 100) gNeedEat[playerid] = 100;
    if(gNeedWater[playerid] < 0) gNeedWater[playerid] = 0;
    if(gNeedWater[playerid] > 100) gNeedWater[playerid] = 100;
    if(gNeedWC[playerid] < 0) gNeedWC[playerid] = 0;
    if(gNeedWC[playerid] > 100) gNeedWC[playerid] = 100;
    if(gNeedHygiene[playerid] < 0) gNeedHygiene[playerid] = 0;
    if(gNeedHygiene[playerid] > 100) gNeedHygiene[playerid] = 100;
    if(gNeedPsycho[playerid] < 0) gNeedPsycho[playerid] = 0;
    if(gNeedPsycho[playerid] > 100) gNeedPsycho[playerid] = 100;
    return 1;
}

stock CEF_NeedsSave(playerid)
{
    new q[280];
    if(!gNeedReady[playerid]) return 0;
    if(PI[playerid][pID] <= 0) return 0;
    mysql_format(dbHandle, q, sizeof q,
        "INSERT INTO `player_needs` (`owner_id`,`eat`,`water`,`wc`,`hygiene`,`psycho`) VALUES (%d,%d,%d,%d,%d,%d) ON DUPLICATE KEY UPDATE `eat`=%d,`water`=%d,`wc`=%d,`hygiene`=%d,`psycho`=%d",
        PI[playerid][pID],
        gNeedEat[playerid], gNeedWater[playerid], gNeedWC[playerid], gNeedHygiene[playerid], gNeedPsycho[playerid],
        gNeedEat[playerid], gNeedWater[playerid], gNeedWC[playerid], gNeedHygiene[playerid], gNeedPsycho[playerid]);
    mysql_tquery(dbHandle, q);
    return 1;
}

forward OnCefNeedsLoaded(playerid);
public OnCefNeedsLoaded(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;
    if(cache_num_rows() <= 0)
    {
        CEF_NeedsReset(playerid);
        gNeedReady[playerid] = true;
        CEF_NeedsSave(playerid);
        if(gCefcAppReady[playerid]) CEF_OpsInventoryIndicators(playerid);
        return 1;
    }
    cache_get_value_name_int(0, "eat", gNeedEat[playerid]);
    cache_get_value_name_int(0, "water", gNeedWater[playerid]);
    cache_get_value_name_int(0, "wc", gNeedWC[playerid]);
    cache_get_value_name_int(0, "hygiene", gNeedHygiene[playerid]);
    cache_get_value_name_int(0, "psycho", gNeedPsycho[playerid]);
    CEF_NeedsClamp(playerid);
    if(gNeedEat[playerid] < 5 && gNeedWater[playerid] < 5 && gNeedWC[playerid] < 5 && gNeedHygiene[playerid] < 5 && gNeedPsycho[playerid] < 5)
    {
        CEF_NeedsReset(playerid);
    }
    gNeedReady[playerid] = true;
    if(gCefcAppReady[playerid]) CEF_OpsInventoryIndicators(playerid);
    return 1;
}

stock CEF_NeedsLoad(playerid)
{
    new q[140];
    CEF_NeedsReset(playerid);
    mysql_format(dbHandle, q, sizeof q, "SELECT * FROM `player_needs` WHERE `owner_id`=%d", PI[playerid][pID]);
    mysql_tquery(dbHandle, q, "OnCefNeedsLoaded", "d", playerid);
    return 1;
}

stock CEF_NeedsAdd(playerid, kind, delta)
{
    switch(kind)
    {
        case NEED_EAT: gNeedEat[playerid] += delta;
        case NEED_WATER: gNeedWater[playerid] += delta;
        case NEED_WC: gNeedWC[playerid] += delta;
        case NEED_HYGIENE: gNeedHygiene[playerid] += delta;
        case NEED_PSYCHO: gNeedPsycho[playerid] += delta;
    }
    CEF_NeedsClamp(playerid);
    if(gCefcAppReady[playerid]) CEF_OpsInventoryIndicators(playerid);
    return 1;
}

stock CEF_NeedsShow(playerid)
{
    static info[420];
    format(info, sizeof info,
        "Еда:\t\t%d%%\nВода:\t\t%d%%\nТуалет:\t\t%d%%\nГигиена:\t%d%%\nПсихика:\t%d%%\n \nСходить в туалет\nУмыться",
        gNeedEat[playerid], gNeedWater[playerid], gNeedWC[playerid],
        gNeedHygiene[playerid], gNeedPsycho[playerid]);
    ShowPlayerDialogEx(playerid, DIALOG_NEED, DIALOG_STYLE_LIST, "Нужды", info, "Выбрать", "Закрыть");
    CEF_OpsInventoryIndicators(playerid);
    return 1;
}

stock CEF_NeedsDialog(playerid, response, listitem)
{
    if(!response) return 1;
    if(listitem == 6) return CEF_NeedsUseToilet(playerid);
    if(listitem == 7) return CEF_NeedsUseWash(playerid);
    return CEF_NeedsShow(playerid);
}

stock Float:CEF_NeedDist(playerid, Float:x, Float:y, Float:z)
{
    new Float:px, Float:py, Float:pz;
    GetPlayerPos(playerid, px, py, pz);
    return floatsqroot((px-x)*(px-x) + (py-y)*(py-y) + (pz-z)*(pz-z));
}

stock CEF_NeedsNearestToilet(playerid)
{

    static Float:pt[][3] = {
        {1480.91, -1740.22, 15.44},
        {1553.39, -1675.59, 16.19},
        {1172.56, -1324.54, 15.40},
        {2495.21, -1687.14, 13.51},
        {1315.45, -898.62, 39.57},
        {1833.61, -1843.19, 13.57},
        {1000.54, -919.81, 42.32}
    };
    new best = -1, i;
    new Float:d, Float:bd = 9999.0;
    for(i = 0; i < sizeof pt; i++)
    {
        d = CEF_NeedDist(playerid, pt[i][0], pt[i][1], pt[i][2]);
        if(d < bd) { bd = d; best = i; }
    }
    if(bd > 12.0) return -1;
    return best;
}

stock CEF_NeedsUseToilet(playerid)
{
    if(CEF_NeedsNearestToilet(playerid) < 0)
        return CEFC_Notify(playerid, "Рядом нет туалета. GPS: больница, ППС, мэрия, 24/7.", "hint");
    gNeedWC[playerid] = 100;
    gNeedHygiene[playerid] += 10;
    CEF_NeedsClamp(playerid);
    CEF_NeedsSave(playerid);
    ApplyAnimation(playerid, "PAULNMAC", "Piss_in", 4.1, 0, 0, 0, 0, 4000, 1);
    CEFC_Notify(playerid, "Нужда справлена. Туалет + гигиена.", "success");
    CEF_OpsInventoryIndicators(playerid);
    return 1;
}

stock CEF_NeedsUseWash(playerid)
{
    if(CEF_NeedsNearestToilet(playerid) < 0)
        return CEFC_Notify(playerid, "Рядом нет умывальника (больница, ППС, мэрия, 24/7).", "hint");
    gNeedHygiene[playerid] = 100;
    gNeedPsycho[playerid] += 15;
    CEF_NeedsClamp(playerid);
    CEF_NeedsSave(playerid);
    ApplyAnimation(playerid, "INT_HOUSE", "wash_up", 4.1, 0, 0, 0, 0, 3000, 1);
    CEFC_Notify(playerid, "Вы умылись. Гигиена восстановлена.", "success");
    CEF_OpsInventoryIndicators(playerid);
    return 1;
}

public CEF_NeedsOnSecond()
{
    new i;
    gNeedSec++;
    foreach(i : Player)
    {
        if(!PT[i][pLogged] || !gNeedReady[i]) continue;
        if(gNeedSec % 60 == 0)
        {
            gNeedEat[i] -= 1;
            gNeedWater[i] -= 1;
            if(gNeedSec % 120 == 0) gNeedWC[i] -= 1;
            gNeedHygiene[i] -= 1;
            if(gNeedSec % 180 == 0) gNeedPsycho[i] -= 1;
            CEF_NeedsClamp(i);
            gNeedSaveTick[i]++;
            if(gNeedSaveTick[i] >= 5)
            {
                gNeedSaveTick[i] = 0;
                CEF_NeedsSave(i);
            }
            if(gCefcAppReady[i]) CEF_OpsInventoryIndicators(i);
        }
        if(gNeedSec % 10 == 0)
        {
            new Float:hp;
            GetPlayerHealth(i, hp);
            if(gNeedEat[i] < 10 || gNeedWater[i] < 10 || gNeedWC[i] < 8 || gNeedHygiene[i] < 8)
            {
                if(hp > 10.0)
                {
                    SetPlayerHealth(i, hp - 2.0);
                    if(gNeedSec % 60 == 0)
                        CEFC_Notify(i, "Нужды на нуле: здоровье падает. /need, 24/7, /toilet, /wash", "error");
                }
            }
        }
    }
    return 1;
}

CMD:need(playerid, params[])
{
    #pragma unused params
    return CEF_NeedsShow(playerid);
}

CMD:toilet(playerid, params[])
{
    #pragma unused params
    return CEF_NeedsUseToilet(playerid);
}

CMD:wash(playerid, params[])
{
    #pragma unused params
    return CEF_NeedsUseWash(playerid);
}

CMD:setneed(playerid, params[])
{
    new spec[] = "udd", target, kind, val, err[48];
    if(PI[playerid][pAdmin] < 4)
    {
        err = "Нужен админ 4+";
        return SendErr(playerid, err);
    }
    if(sscanf(params, spec, target, kind, val))
    {
        err = "/setneed [id] [0-4] [0-100]";
        return SendErr(playerid, err);
    }
    if(!IsPlayerConnected(target))
    {
        err = "Игрок не найден";
        return SendErr(playerid, err);
    }
    new cur;
    switch(kind)
    {
        case 0: cur = gNeedEat[target];
        case 1: cur = gNeedWater[target];
        case 2: cur = gNeedWC[target];
        case 3: cur = gNeedHygiene[target];
        default: cur = gNeedPsycho[target];
    }
    CEF_NeedsAdd(target, kind, val - cur);
    CEF_NeedsSave(target);
    CEF_NeedsShow(target);
    return 1;
}
