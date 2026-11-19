#if defined _cef_economy_included
    #endinput
#endif
#define _cef_economy_included
forward CEF_NeedsAdd(playerid, kind, delta);
#define CEF_OPS_CONTRACT 1

#define CEF_SHOP_MAX 16
#define CEF_ITEM_CANISTER 6
#define CEF_ITEM_REPAIR   7
#define CEF_ITEM_MEDKIT   8
#define CEF_ITEM_GAS      9
#define CEF_ITEM_FOOD    10
#define CEF_ITEM_DRINK   11
#define CEF_GAS_PRICE_L   55

enum E_CEF_SHOP {
    sgId,
    sgType,
    sgPrice,
    sgStock,
    sgName[32]
}
new gShopGoods[CEF_SHOP_MAX][E_CEF_SHOP];
new gShopCount;

stock CEF_EcoFindInt(const src[], const key[])
{
    new pat[40], p, n, i, c, neg;
    format(pat, sizeof pat, "\"%s\":", key);
    p = strfind(src, pat, true);
    if(p < 0)
    {
        format(pat, sizeof pat, "%s\":", key);
        p = strfind(src, pat, true);
    }
    if(p < 0) return 0;
    p += strlen(pat);
    while(src[p] == ' ') p++;
    if(src[p] == '-') { neg = 1; p++; }
    n = 0;
    for(i = 0; i < 10; i++)
    {
        c = src[p + i];
        if(c < '0' || c > '9') break;
        n = n * 10 + (c - '0');
    }
    return neg ? -n : n;
}

stock CEF_EcoSaveMoney(playerid)
{
    new query[160];
    mysql_format(dbHandle, query, sizeof query,
        "UPDATE `accounts` SET `cash`=%d, `bank`=%d WHERE `id`=%d",
        PI[playerid][pCash], PI[playerid][pBank], PI[playerid][pID]);
    mysql_tquery(dbHandle, query, "", "");
    UpdatePlayerHUD(playerid);
    return 1;
}

stock CEF_EcoPay(playerid, amount)
{
    if(amount <= 0) return 1;
    new fromCash = amount;
    if(PI[playerid][pCash] < amount)
    {
        new need = amount - PI[playerid][pCash];
        if(PI[playerid][pBank] < need) return 0;
        fromCash = PI[playerid][pCash];
        PI[playerid][pBank] -= need;
        PI[playerid][pCash] = 0;
    }
    else PI[playerid][pCash] -= amount;
    if(fromCash > 0) GivePlayerMoney(playerid, -fromCash);
    CEF_EcoSaveMoney(playerid);
    return 1;
}

stock CEF_EcoSeed()
{
    gShopCount = 8;
    gShopGoods[0][sgId] = 1; gShopGoods[0][sgType] = CEF_ITEM_FOOD; gShopGoods[0][sgPrice] = 5000; gShopGoods[0][sgStock] = 100;
    format(gShopGoods[0][sgName], 32, "Hot-dog");
    gShopGoods[1][sgId] = 2; gShopGoods[1][sgType] = CEF_ITEM_DRINK; gShopGoods[1][sgPrice] = 2000; gShopGoods[1][sgStock] = 100;
    format(gShopGoods[1][sgName], 32, "Voda");
    gShopGoods[2][sgId] = 3; gShopGoods[2][sgType] = CEF_ITEM_DRINK; gShopGoods[2][sgPrice] = 3000; gShopGoods[2][sgStock] = 100;
    format(gShopGoods[2][sgName], 32, "Cola");
    gShopGoods[3][sgId] = 4; gShopGoods[3][sgType] = CEF_ITEM_FOOD; gShopGoods[3][sgPrice] = 8000; gShopGoods[3][sgStock] = 100;
    format(gShopGoods[3][sgName], 32, "Burger");
    gShopGoods[4][sgId] = 5; gShopGoods[4][sgType] = CEF_ITEM_MEDKIT; gShopGoods[4][sgPrice] = 15000; gShopGoods[4][sgStock] = 80;
    format(gShopGoods[4][sgName], 32, "Aptechka");
    gShopGoods[5][sgId] = 6; gShopGoods[5][sgType] = CEF_ITEM_REPAIR; gShopGoods[5][sgPrice] = 50000; gShopGoods[5][sgStock] = 40;
    format(gShopGoods[5][sgName], 32, "Remkomplekt");
    gShopGoods[6][sgId] = 7; gShopGoods[6][sgType] = CEF_ITEM_CANISTER; gShopGoods[6][sgPrice] = 25000; gShopGoods[6][sgStock] = 50;
    format(gShopGoods[6][sgName], 32, "Kanistra 20L");
    gShopGoods[7][sgId] = 8; gShopGoods[7][sgType] = CEF_ITEM_GAS; gShopGoods[7][sgPrice] = 8000; gShopGoods[7][sgStock] = 100;
    format(gShopGoods[7][sgName], 32, "Benzin 10L");
    return 1;
}

forward CEF_EcoInit();
public CEF_EcoInit()
{
    CEF_EcoSeed();
    mysql_tquery(dbHandle,
        "CREATE TABLE IF NOT EXISTS `shop_goods` (`id` INT NOT NULL AUTO_INCREMENT, `shop_id` INT NOT NULL DEFAULT 1, `item` VARCHAR(64) NOT NULL, `item_type` INT NOT NULL DEFAULT 0, `price` INT NOT NULL, `stock` INT NOT NULL DEFAULT 100, PRIMARY KEY (`id`)) ENGINE=InnoDB DEFAULT CHARSET=cp1251",
        "", "");
    mysql_tquery(dbHandle,
        "INSERT IGNORE INTO `shop_goods` (`id`,`shop_id`,`item`,`item_type`,`price`,`stock`) VALUES (1,1,'Kanistra 20L',6,25000,50),(2,1,'Remkomplekt',7,50000,40),(3,1,'Aptechka',8,15000,80),(4,1,'Benzin 10L',9,8000,100),(5,2,'Benzin 10L',9,8000,100),(6,1,'Hot-dog',10,5000,100),(7,1,'Voda',11,2000,100),(8,1,'Cola',11,3000,100),(9,1,'Burger',10,8000,100)",
        "", "");
    mysql_tquery(dbHandle, "SELECT `id`,`item`,`item_type`,`price`,`stock` FROM `shop_goods` WHERE `shop_id` IN (1,2) ORDER BY `id` LIMIT 16", "OnCefShopGoodsLoaded", "");
    printf("[CEF-ECO] shop seed %d, loading DB", gShopCount);
    return 1;
}

forward OnCefShopGoodsLoaded();
public OnCefShopGoodsLoaded()
{
    new rows = cache_num_rows();
    if(rows <= 0) return 1;
    gShopCount = 0;
    for(new i = 0; i < rows && i < CEF_SHOP_MAX; i++)
    {
        cache_get_value_name_int(i, "id", gShopGoods[gShopCount][sgId]);
        cache_get_value_name_int(i, "item_type", gShopGoods[gShopCount][sgType]);
        cache_get_value_name_int(i, "price", gShopGoods[gShopCount][sgPrice]);
        cache_get_value_name_int(i, "stock", gShopGoods[gShopCount][sgStock]);
        cache_get_value_name(i, "item", gShopGoods[gShopCount][sgName], 32);
        gShopCount++;
    }
    printf("[CEF-ECO] shop_goods loaded %d", gShopCount);
    return 1;
}


stock CEF_ShopItemImage(itemType)
{
    new img[32];
    switch(itemType)
    {
        case CEF_ITEM_CANISTER: img = "canister.png";
        case CEF_ITEM_REPAIR:   img = "repair-kit.png";
        case CEF_ITEM_MEDKIT:   img = "health-kit.png";
        case CEF_ITEM_GAS:      img = "fuel-tank.png";
        case CEF_ITEM_FOOD:     img = "health-kit.png";
        case CEF_ITEM_DRINK:    img = "canister.png";
        default:                img = "rubles.png";
    }
    return img;
}

stock CEF_EcoBuildShopJson(playerid, dest[], size)
{
    new part[192], i, first = 1;
    format(dest, size, "{\"shopId\":1,\"title\":\"24/7\",\"money\":%d,\"bank\":%d,\"items\":[", PI[playerid][pCash], PI[playerid][pBank]);
    for(i = 0; i < gShopCount; i++)
    {
        if(gShopGoods[i][sgType] == CEF_ITEM_GAS || gShopGoods[i][sgType] == CEF_ITEM_CANISTER) continue;
        format(part, sizeof part,
            "%s{\"id\":%d,\"slotId\":%d,\"type\":%d,\"name\":\"%s\",\"image\":\"%s\",\"price\":%d,\"count\":%d,\"quantity\":%d,\"maxBuyQuantity\":%d,\"stock\":%d}",
            first ? ("") : (","),
            gShopGoods[i][sgId], i + 1, CEF_ItemToSpa(gShopGoods[i][sgType]), gShopGoods[i][sgName],
            CEF_ShopItemImage(gShopGoods[i][sgType]),
            gShopGoods[i][sgPrice], 1, gShopGoods[i][sgStock],
            (gShopGoods[i][sgStock] > 10) ? 10 : gShopGoods[i][sgStock],
            gShopGoods[i][sgStock]);
        strcat(dest, part, size);
        first = 0;
    }
    strcat(dest, "]}", size);
    return 1;
}

forward CEF_EcoShopOpen(playerid);
public CEF_EcoShopOpen(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;
    if(gShopCount <= 0) CEF_EcoSeed();
    new json[CEF_JSON_SIZE];
    CEF_EcoBuildShopJson(playerid, json, sizeof json);
    CEF_MarkPlayerReady(playerid);
    CEF_OpenScreen(playerid, "cef_shop_menu_show", json);
    CEF_Focus(playerid, true);
    return 1;
}

stock CEF_EcoFindGood(id)
{
    for(new i = 0; i < gShopCount; i++) if(gShopGoods[i][sgId] == id) return i;
    return -1;
}

forward CEF_EcoShopResponse(playerid, const arguments[]);
public CEF_EcoShopResponse(playerid, const arguments[])
{

    new spaKey = CEF_EcoFindInt(arguments, "key");
    if(strfind(arguments, "\"key\"", true) != -1)
    {
        if(spaKey == 0)
        {
            CEF_SendEmpty(playerid, "cef_shop_menu_hide");
            CEF_Hide(playerid);
            return 1;
        }
        if(spaKey == 2) return 1;
    }

    new action[32], id, qty, idx, cost;
    CEF_Arg(arguments, 0, action);
    id = CEF_ArgInt(arguments, 1);
    qty = CEF_ArgInt(arguments, 2);
    if(!id) id = CEF_EcoFindInt(arguments, "id");
    if(!id) id = CEF_EcoFindInt(arguments, "itemId");
    if(!qty) qty = CEF_EcoFindInt(arguments, "count");
    if(!qty) qty = CEF_EcoFindInt(arguments, "amount");
    if(!qty) qty = 1;
    if(!strcmp(action, "close", true) || !strcmp(action, "hide", true))
    {
        CEF_SendEmpty(playerid, "cef_shop_menu_hide");
        CEF_Hide(playerid);
        return 1;
    }
    if(id <= 0) id = CEF_ArgInt(arguments, 0);
    idx = CEF_EcoFindGood(id);
    if(idx < 0) return 1;
    if(qty < 1) qty = 1;
    if(qty > 10) qty = 10;
    if(gShopGoods[idx][sgStock] < qty)
    {
        SendErr(playerid, "Net v nalichii");
        return 1;
    }
    if(gShopGoods[idx][sgType] != CEF_ITEM_FOOD && gShopGoods[idx][sgType] != CEF_ITEM_DRINK &&
        !CEF_InvCanGive(playerid, gShopGoods[idx][sgType], qty))
    {
        SendErr(playerid, "Inventory is full.");
        return 1;
    }
    cost = gShopGoods[idx][sgPrice] * qty;
    if(!CEF_EcoPay(playerid, cost))
    {
        SendErr(playerid, "Ne hvataet deneg (cash/bank)");
        return 1;
    }
    gShopGoods[idx][sgStock] -= qty;
    if(gShopGoods[idx][sgType] == CEF_ITEM_FOOD)
    {
        CEF_NeedsAdd(playerid, 0, 40 * qty);
        CEFC_Notify(playerid, "Вы перекусили.", "success");
    }
    else if(gShopGoods[idx][sgType] == CEF_ITEM_DRINK)
    {
        CEF_NeedsAdd(playerid, 1, 45 * qty);
        CEF_NeedsAdd(playerid, 2, -10 * qty);
        CEFC_Notify(playerid, "Вы попили.", "success");
    }
    else GiveItem(playerid, gShopGoods[idx][sgType], qty);
    if(gShopGoods[idx][sgType] == CEF_ITEM_MEDKIT) SetPlayerHealth(playerid, 100.0);
    if(gShopGoods[idx][sgType] == CEF_ITEM_REPAIR)
    {
        new vid = GetPlayerVehicleID(playerid);
        if(vid) RepairVehicle(vid);
    }
    new q[160];
    mysql_format(dbHandle, q, sizeof q, "UPDATE `shop_goods` SET `stock`=%d WHERE `id`=%d", gShopGoods[idx][sgStock], gShopGoods[idx][sgId]);
    mysql_tquery(dbHandle, q, "", "");
    SavePlayerInventory(playerid);
    CEF_EcoShopOpen(playerid);
    return 1;
}

stock CEF_EcoBuildGasJson(playerid, dest[], size)
{
    new vid = GetPlayerVehicleID(playerid), fuel;
    if(vid) fuel = CI[vid][Fuel];

    format(dest, size,
        "{\"recommendedFuelType\":2,\"maxFuelValue\":%d,\"currentFuel\":%d,\"fuelPrices\":[%d,%d,%d,%d,%d],\"money\":%d,\"bank\":%d}",
        (CEF_GAS_MAX - fuel) > 0 ? (CEF_GAS_MAX - fuel) : 0, fuel,
        CEF_GAS_PRICE_L - 5, CEF_GAS_PRICE_L, CEF_GAS_PRICE_L + 8, CEF_GAS_PRICE_L - 3, CEF_GAS_PRICE_L * 2,
        PI[playerid][pCash], PI[playerid][pBank]);
    return 1;
}

forward CEF_EcoGasOpen(playerid);
public CEF_EcoGasOpen(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;
    if(gShopCount <= 0) CEF_EcoSeed();
    new json[CEF_JSON_SIZE];
    CEF_EcoBuildGasJson(playerid, json, sizeof json);
    CEF_MarkPlayerReady(playerid);
    CEF_OpenScreen(playerid, "cef_gs_fueling_menu_open", json);
    CEF_Focus(playerid, true);
    return 1;
}

forward CEF_EcoGasResponse(playerid, const arguments[]);
public CEF_EcoGasResponse(playerid, const arguments[])
{

    if(strfind(arguments, "fuelType", true) != -1)
    {
        new ftype = CEF_EcoFindInt(arguments, "fuelType");
        new litres = CEF_EcoFindInt(arguments, "value");
        new car = GetPlayerVehicleID(playerid), cost, pricePerL;
        if(!car) return SendErr(playerid, "Нужно находиться в транспорте.");
        if(litres < 1) litres = 1;
        if(CI[car][Fuel] + litres > CEF_GAS_MAX) litres = CEF_GAS_MAX - CI[car][Fuel];
        if(litres <= 0) return SendErr(playerid, "Бак полон.");
        switch(ftype)
        {
            case 1: pricePerL = CEF_GAS_PRICE_L - 5;
            case 3: pricePerL = CEF_GAS_PRICE_L + 8;
            case 4: pricePerL = CEF_GAS_PRICE_L - 3;
            case 5: pricePerL = CEF_GAS_PRICE_L * 2;
            default: pricePerL = CEF_GAS_PRICE_L;
        }
        cost = litres * pricePerL;
        if(!CEF_EcoPay(playerid, cost)) return SendErr(playerid, "Недостаточно средств.");
        CI[car][Fuel] += litres;
        CEFC_SpeedometerRefresh(playerid);
        CEF_SendEmpty(playerid, "cef_gs_fueling_menu_close");
        CEF_Hide(playerid);
        CEFC_Notify(playerid, "Заправка выполнена.", "success");
        CEFC_HudUpdate(playerid);
        return 1;
    }
    if(!strlen(arguments) || !strcmp(arguments, "null", true) || !strcmp(arguments, "{}", true))
    {
        CEF_SendEmpty(playerid, "cef_gs_fueling_menu_close");
        CEF_Hide(playerid);
        return 1;
    }

    new action[32], liters, id, idx, cost, add, vid;
    CEF_Arg(arguments, 0, action);
    liters = CEF_ArgInt(arguments, 1);
    id = CEF_EcoFindInt(arguments, "id");
    if(!liters) liters = CEF_EcoFindInt(arguments, "liters");
    if(!liters) liters = CEF_EcoFindInt(arguments, "count");
    if(!strcmp(action, "close", true) || !strcmp(action, "hide", true))
    {
        CEF_SendEmpty(playerid, "cef_gs_fueling_menu_close");
        CEF_Hide(playerid);
        return 1;
    }
    vid = GetPlayerVehicleID(playerid);
    if(id > 0)
    {
        idx = CEF_EcoFindGood(id);
        if(idx < 0) return 1;
        if(!vid && !CEF_InvCanGive(playerid, gShopGoods[idx][sgType], 1))
        {
            SendErr(playerid, "Inventory is full.");
            return 1;
        }
        cost = gShopGoods[idx][sgPrice];
        if(!CEF_EcoPay(playerid, cost))
        {
            SendErr(playerid, "Ne hvataet deneg (cash/bank)");
            return 1;
        }
        add = (gShopGoods[idx][sgType] == CEF_ITEM_CANISTER) ? 20 : 10;
        if(vid)
        {
            CI[vid][Fuel] += add;
            if(CI[vid][Fuel] > CEF_GAS_MAX) CI[vid][Fuel] = CEF_GAS_MAX;
            SetSpeedometerIndicatorValue(playerid, 1, CI[vid][Fuel]);
        }
        else GiveItem(playerid, gShopGoods[idx][sgType], 1);
        if(gShopGoods[idx][sgStock] > 0) gShopGoods[idx][sgStock]--;
        CEF_EcoGasOpen(playerid);
        return 1;
    }
    if(liters < 1) liters = 1;
    if(liters > 60) liters = 60;
    if(!vid)
    {
        SendErr(playerid, "Sadtes v mashinu");
        return 1;
    }
    if(CI[vid][Fuel] + liters > CEF_GAS_MAX) liters = CEF_GAS_MAX - CI[vid][Fuel];
    if(liters <= 0)
    {
        SendErr(playerid, "Bak polon");
        return 1;
    }
    cost = liters * CEF_GAS_PRICE_L;
    if(!CEF_EcoPay(playerid, cost))
    {
        SendErr(playerid, "Ne hvataet deneg (cash/bank)");
        return 1;
    }
    CI[vid][Fuel] += liters;
    SetSpeedometerIndicatorValue(playerid, 1, CI[vid][Fuel]);
    CEF_EcoGasOpen(playerid);
    return 1;
}

forward CEF_EcoJobOpen(playerid);
public CEF_EcoJobOpen(playerid)
{
    new json[CEF_JSON_SIZE], fready, rload, freward, rreward, idx;
    fready = 0;
    if(g_FactoryPlayer[playerid][fp_Working])
    {
        fready = g_FactoryPlayer[playerid][fp_ItemReady] ? 1 : 0;
        if(!fready)
        {
            fready = 1;
            for(new j = 0; j < 4; j++) if(g_FactoryPlayer[playerid][fp_Materials][j] == 0) fready = 0;
        }
    }
    rload = g_RazvozLoaded[playerid] + g_RazvozWoodLoaded[playerid] + g_RazvozMetalLoaded[playerid];
    freward = Skill_GetRewardBonus(playerid, SKILL_FACTORY, FACTORY_REWARD, 20000);
    rreward = 0;
    idx = g_RazvozSelectedOrder[playerid];
    if(idx >= 0 && idx < g_RazvozOrderCount && g_RazvozLoaded[playerid] > 0)
        rreward = g_RazvozLoaded[playerid] * g_RazvozOrders[idx][rzPrice];
    else if(g_RazvozWoodLoaded[playerid] + g_RazvozMetalLoaded[playerid] > 0)
        rreward = g_RazvozWoodLoaded[playerid] * RAZVOZ_PRICE_WOOD_SELL + g_RazvozMetalLoaded[playerid] * RAZVOZ_PRICE_METAL_SELL;
    format(json, sizeof json,
        "{\"gameCategory\":5,\"money\":%d,\"factoryWorking\":%d,\"factoryReady\":%d,\"factoryReward\":%d,\"razvozWorking\":%d,\"razvozLoaded\":%d,\"razvozReward\":%d}",
        PI[playerid][pCash],
        g_FactoryPlayer[playerid][fp_Working] ? 1 : 0,
        fready, freward,
        Razvoz_IsWorking(playerid) ? 1 : 0,
        rload, rreward);
    CEF_MarkPlayerReady(playerid);
    CEF_OpenScreen(playerid, "cef_job_crafting_show", json);
    CEF_Focus(playerid, true);
    return 1;
}

forward CEF_EcoJobResponse(playerid, const arguments[]);
public CEF_EcoJobResponse(playerid, const arguments[])
{
    new action[32], act, paid;
    CEF_Arg(arguments, 0, action);
    act = CEF_ArgInt(arguments, 0);
    if(!act) act = CEF_EcoFindInt(arguments, "action");
    if(!act) act = CEF_EcoFindInt(arguments, "id");
    if(!strcmp(action, "close", true) || !strcmp(action, "hide", true))
    {
        CEF_SendEmpty(playerid, "cef_job_crafting_hide");
        CEF_Hide(playerid);
        return 1;
    }
    if(!strcmp(action, "factory", true) || act == 1)
    {
        paid = Factory_PayCraft(playerid);
        if(paid > 0) format(action, sizeof action, "OK factory +%d", paid);
        else if(paid == 0) format(action, sizeof action, "not on factory job");
        else format(action, sizeof action, "need 4 materials / detail");
        SendClientMessage(playerid, 0x54B367FF, action);
        CEF_EcoJobOpen(playerid);
        return 1;
    }
    if(!strcmp(action, "razvoz", true) || act == 2)
    {
        paid = Razvoz_PayCraft(playerid);
        if(paid > 0) format(action, sizeof action, "OK razvoz +%d", paid);
        else if(paid == -2) format(action, sizeof action, "go to order point");
        else if(paid == 0) format(action, sizeof action, "not on razvoz job");
        else format(action, sizeof action, "nothing to unload");
        SendClientMessage(playerid, 0x54B367FF, action);
        CEF_EcoJobOpen(playerid);
        return 1;
    }
    paid = Factory_PayCraft(playerid);
    if(paid <= 0) paid = Razvoz_PayCraft(playerid);
    if(paid > 0)
    {
        format(action, sizeof action, "OK job +%d", paid);
        SendClientMessage(playerid, 0x54B367FF, action);
    }
    CEF_EcoJobOpen(playerid);
    return 1;
}
