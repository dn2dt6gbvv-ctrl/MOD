#if defined _cef_donate_shop_included
    #endinput
#endif
#define _cef_donate_shop_included



#define CEF_SKINS_MAX 32
new gCefSkinOwn[MAX_PLAYERS][CEF_SKINS_MAX];
new gCefSkinCount[MAX_PLAYERS];
new gCefSkinWearId[MAX_PLAYERS];

#define CEF_SPA_OWN_MAX 32
new gCefSpaOwnType[MAX_PLAYERS][CEF_SPA_OWN_MAX];
new gCefSpaOwnAmt[MAX_PLAYERS][CEF_SPA_OWN_MAX];
new gCefSpaOwnN[MAX_PLAYERS];

stock CEF_SpaOwnInit()
{
    new q[320];
    format(q, sizeof q, "CREATE TABLE IF NOT EXISTS `player_spa_items` (`owner_id` INT NOT NULL, `spa_type` INT NOT NULL, `amount` INT NOT NULL DEFAULT 1, PRIMARY KEY(`owner_id`,`spa_type`)) DEFAULT CHARSET=utf8");
    mysql_tquery(dbHandle, q);
    return 1;
}

forward OnCefSpaOwnLoaded(playerid);
public OnCefSpaOwnLoaded(playerid)
{
    new rows, st, am;
    if(!IsPlayerConnected(playerid)) return 0;
    gCefSpaOwnN[playerid] = 0;
    rows = cache_num_rows();
    for(new i = 0; i < rows && gCefSpaOwnN[playerid] < CEF_SPA_OWN_MAX; i++)
    {
        cache_get_value_name_int(i, "spa_type", st);
        cache_get_value_name_int(i, "amount", am);
        if(st <= 0 || am <= 0) continue;
        gCefSpaOwnType[playerid][gCefSpaOwnN[playerid]] = st;
        gCefSpaOwnAmt[playerid][gCefSpaOwnN[playerid]] = am;
        gCefSpaOwnN[playerid]++;
    }
    return 1;
}

stock CEF_SpaOwnLoad(playerid)
{
    new q[160];
    gCefSpaOwnN[playerid] = 0;
    mysql_format(dbHandle, q, sizeof q, "SELECT `spa_type`,`amount` FROM `player_spa_items` WHERE `owner_id`=%d", PI[playerid][pID]);
    mysql_tquery(dbHandle, q, "OnCefSpaOwnLoaded", "d", playerid);
    return 1;
}

stock CEF_SpaOwnSave(playerid, spaType, amount)
{
    new q[220];
    mysql_format(dbHandle, q, sizeof q,
        "INSERT INTO `player_spa_items` (`owner_id`,`spa_type`,`amount`) VALUES (%d,%d,%d) ON DUPLICATE KEY UPDATE `amount`=%d",
        PI[playerid][pID], spaType, amount, amount);
    mysql_tquery(dbHandle, q);
    return 1;
}

stock CEF_SpaOwnGive(playerid, spaType, amount)
{
    if(spaType <= 0 || amount <= 0) return 0;
    for(new i = 0; i < gCefSpaOwnN[playerid]; i++)
    {
        if(gCefSpaOwnType[playerid][i] == spaType)
        {
            gCefSpaOwnAmt[playerid][i] += amount;
            CEF_SpaOwnSave(playerid, spaType, gCefSpaOwnAmt[playerid][i]);
            return 1;
        }
    }
    if(gCefSpaOwnN[playerid] >= CEF_SPA_OWN_MAX) return 0;
    new n = gCefSpaOwnN[playerid]++;
    gCefSpaOwnType[playerid][n] = spaType;
    gCefSpaOwnAmt[playerid][n] = amount;
    CEF_SpaOwnSave(playerid, spaType, amount);
    return 1;
}

stock CEF_SpaOwnInventoryJson(playerid, dest[], size, startSlot, bool:needComma)
{
    static part[96];
    new slot = startSlot, bool:comma = needComma;
    dest[0] = EOS;
    for(new i = 0; i < gCefSpaOwnN[playerid]; i++)
    {
        if(gCefSpaOwnAmt[playerid][i] <= 0) continue;
        if(gCefSpaOwnType[playerid][i] == 9) continue;
        if(gCefSpaOwnType[playerid][i] == GetPlayerSkin(playerid)) continue;
        if(CEF_SkinHas(playerid, gCefSpaOwnType[playerid][i])) continue;
        format(part, sizeof part, "%s{\"slotId\":%d,\"type\":%d,\"value\":%d,\"extraValue\":0}",
            comma ? (",") : (""), slot, gCefSpaOwnType[playerid][i], gCefSpaOwnAmt[playerid][i]);
        if(strlen(dest) + strlen(part) >= size - 2) break;
        strcat(dest, part, size);
        CEF_InvRemember(playerid, slot, gCefSpaOwnType[playerid][i]);
        comma = true;
        slot++;
    }
    return slot;
}

stock CEF_ShopGiveWeapon(playerid, itemId)
{
    new wep, ammo;
    switch(itemId)
    {
        case 533: { wep = 31; ammo = 200; }
        case 248: { wep = 24; ammo = 70; }
        default: return 0;
    }
    GivePlayerWeapon(playerid, wep, ammo);
    return 1;
}

stock CEF_DonateShopInit()
{
    new q[280];
    format(q, sizeof q, "CREATE TABLE IF NOT EXISTS `player_skins` (`owner_id` INT NOT NULL, `skin_id` INT NOT NULL, PRIMARY KEY(`owner_id`,`skin_id`)) DEFAULT CHARSET=utf8");
    mysql_tquery(dbHandle, q);
    CEF_SpaOwnInit();
    print("[CEF-SHOP] таблица player_skins готова");
    return 1;
}

stock CEF_ShopItemId(const src[])
{
    new v, d, p, n, i, c;
    new pat[] = "id";
    v = CEF_EcoFindInt(src, "itemId");
    if(v) return v;
    v = CEF_EcoFindInt(src, "productId");
    if(v) return v;
    v = CEF_EcoFindInt(src, "caseType");
    if(v) return v;
    d = strfind(src, "data", true);
    if(d < 0) return 0;
    p = strfind(src, "id", true, d + 4);
    if(p < 0) return 0;
    while(src[p] && src[p] != ':') p++;
    if(src[p] == ':') p++;
    while(src[p] == ' ' || src[p] == '"') p++;
    n = 0;
    for(i = 0; i < 10; i++)
    {
        c = src[p + i];
        if(c < '0' || c > '9') break;
        n = n * 10 + (c - '0');
    }
    return n;
}

stock CEF_DonatePrice(itemId)
{
    new rub = CEF_CasePriceByType(itemId);
    if(rub > 0)
    {
        new pr = rub / 80;
        if(pr < 50) pr = 50;
        return pr;
    }
    if(itemId == 533) return 399;
    if(itemId == 900) return 149;
    if(itemId == 901) return 449;
    if(itemId >= 1 && itemId <= 311) return 150;
    return 0;
}

stock CEF_DonateSyncAccount(playerid)
{
    new q[160];
    PI[playerid][pDonate] = gCefCurrency[playerid][CEF_CUR_AMAZING];
    mysql_format(dbHandle, q, sizeof q, "UPDATE `accounts` SET `donate`=%d WHERE `id`=%d LIMIT 1", PI[playerid][pDonate], PI[playerid][pID]);
    mysql_tquery(dbHandle, q);
    return 1;
}

stock CEF_SkinHas(playerid, skinId)
{
    for(new i = 0; i < gCefSkinCount[playerid]; i++)
        if(gCefSkinOwn[playerid][i] == skinId) return 1;
    return 0;
}

stock CEF_SkinGive(playerid, skinId)
{
    new q[180], msg[96];
    if(skinId <= 0) return 0;
    if(CEF_SkinHas(playerid, skinId)) return CEFC_Notify(playerid, "Этот скин уже есть.", "hint");
    if(gCefSkinCount[playerid] >= CEF_SKINS_MAX) return CEFC_Notify(playerid, "Лимит скинов.", "error");
    gCefSkinOwn[playerid][gCefSkinCount[playerid]++] = skinId;
    mysql_format(dbHandle, q, sizeof q, "INSERT IGNORE INTO `player_skins` (`owner_id`,`skin_id`) VALUES (%d,%d)", PI[playerid][pID], skinId);
    mysql_tquery(dbHandle, q);
    format(msg, sizeof msg, "Скин %d добавлен в инвентарь.", skinId);
    CEFC_Notify(playerid, msg, "success");
    return 1;
}

stock CEF_SkinWear(playerid, skinId)
{
    new msg[96];
    if(!CEF_SkinHas(playerid, skinId)) return 0;
    gCefSkinWearId[playerid] = skinId;
    if(skinId >= 1 && skinId <= 311)
    {
        SetPlayerSkin(playerid, skinId);
        PI[playerid][pSkin] = skinId;
    }
    CEFC_AccountStats(playerid);
    format(msg, sizeof msg, "Скин %d надет.", skinId);
    CEFC_Notify(playerid, msg, "success");
    ShowPlayerInventory(playerid);
    return 1;
}

stock CEF_SkinsInventoryJson(playerid, dest[], size, startSlot, bool:needComma)
{
    static part[96];
    new slot = startSlot, bool:comma = needComma;
    dest[0] = EOS;
    for(new i = 0; i < gCefSkinCount[playerid]; i++)
    {
        format(part, sizeof part, "%s{\"slotId\":%d,\"type\":%d,\"value\":1,\"extraValue\":100}", comma ? (",") : (""), slot, gCefSkinOwn[playerid][i]);
        if(strlen(dest) + strlen(part) >= size - 2) break;
        strcat(dest, part, size);
        comma = true;
        slot++;
    }
    return slot;
}

forward OnCefSkinsLoaded(playerid);
public OnCefSkinsLoaded(playerid)
{
    new rows, sid;
    if(!IsPlayerConnected(playerid)) return 0;
    gCefSkinCount[playerid] = 0;
    gCefSkinWearId[playerid] = 0;
    rows = cache_num_rows();
    for(new i = 0; i < rows && gCefSkinCount[playerid] < CEF_SKINS_MAX; i++)
    {
        cache_get_value_name_int(i, "skin_id", sid);
        gCefSkinOwn[playerid][gCefSkinCount[playerid]++] = sid;
    }
    return 1;
}

stock CEF_SkinsLoad(playerid)
{
    new q[140];
    gCefSkinCount[playerid] = 0;
    mysql_format(dbHandle, q, sizeof q, "SELECT `skin_id` FROM `player_skins` WHERE `owner_id`=%d", PI[playerid][pID]);
    mysql_tquery(dbHandle, q, "OnCefSkinsLoaded", "d", playerid);
    return 1;
}

stock CEF_DonateCanGiveKit(playerid, kit)
{
    if(kit <= 1)
    {
        new kitOneTypes[5] = { 8, 6, 7, 10, 11 };
        new kitOneAmounts[5] = { 1, 1, 1, 1, 1 };
        return CEF_InvCanGiveBatch(playerid, kitOneTypes, kitOneAmounts, 5);
    }
    new kitTwoTypes[1] = { 8 };
    new kitTwoAmounts[1] = { 2 };
    return CEF_InvCanGiveBatch(playerid, kitTwoTypes, kitTwoAmounts, 1);
}

stock CEF_DonateGiveKit(playerid, kit)
{
    if(!CEF_DonateCanGiveKit(playerid, kit))
    {
        CEFC_Notify(playerid, "Inventory is full; reward was not granted.", "error");
        return 0;
    }
    if(kit <= 1)
    {
        GiveItem(playerid, 8, 1);
        GiveItem(playerid, 6, 1);
        GiveItem(playerid, 7, 1);
        GiveItem(playerid, 10, 1);
        GiveItem(playerid, 11, 1);
        SavePlayerInventory(playerid);
        CEFC_Notify(playerid, "Набор: аптечка, канистра, ремкомплект, еда, вода.", "success");
    }
    else
    {
        CEF_SpaOwnGive(playerid, 533, 1);
        CEF_ShopGiveWeapon(playerid, 533);
        GiveItem(playerid, 8, 2);
        SavePlayerInventory(playerid);
        CEFC_Notify(playerid, "Боевой набор: АС Вал и аптечки.", "success");
    }
    CEF_InvSync(playerid);
    return 1;
}

stock CEF_DonateBuy(playerid, itemId, amount, spaPrice, dest[], size)
{
    new price, total, idx, msg[144], name[40];
    if(amount < 1) amount = 1;
    if(amount > 20) amount = 20;
    if(itemId <= 0)
    {
        format(dest, size, "{\"ok\":false,\"result\":false}");
        return 0;
    }
    price = CEF_DonatePrice(itemId);
    if(price <= 0 && spaPrice > 0) price = spaPrice;
    if(price <= 0)
    {
        CEFC_Notify(playerid, "Этот товар пока не продаётся. Амазинги не списаны.", "error");
        format(dest, size, "{\"ok\":false,\"result\":false,\"donate\":%d}", gCefCurrency[playerid][CEF_CUR_AMAZING]);
        return 0;
    }
    total = price * amount;
    if((itemId == 900 || itemId == 901) && !CEF_DonateCanGiveKit(playerid, itemId - 899))
    {
        CEFC_Notify(playerid, "Inventory is full; free a slot before buying this kit.", "error");
        format(dest, size, "{\"ok\":false,\"result\":false,\"donate\":%d}", gCefCurrency[playerid][CEF_CUR_AMAZING]);
        return 0;
    }
    if(gCefCurrency[playerid][CEF_CUR_AMAZING] < total)
    {
        CEFC_Notify(playerid, "Недостаточно амазингов.", "error");
        format(dest, size, "{\"ok\":false,\"result\":false,\"donate\":%d}", gCefCurrency[playerid][CEF_CUR_AMAZING]);
        return 0;
    }
    CEF_CurrencyGive(playerid, CEF_CUR_AMAZING, -total);
    CEF_DonateSyncAccount(playerid);
    idx = CEF_CaseIndex(itemId);
    if(idx >= 0)
    {
        CEF_CaseGive(playerid, itemId, amount);
        CEF_CaseName(itemId, name, sizeof name);
        format(msg, sizeof msg, "Куплено: кейс «%s» x%d за %d амазингов.", name, amount, total);
        CEFC_Notify(playerid, msg, "success");
    }
    else if(itemId == 900 || itemId == 901)
    {
        CEF_DonateGiveKit(playerid, itemId - 899);
    }
    else if(itemId >= 1 && itemId <= 311)
    {
        CEF_SkinGive(playerid, itemId);
    }
    else
    {
        CEF_SpaOwnGive(playerid, itemId, amount);
        CEF_ShopGiveWeapon(playerid, itemId);
        if(itemId == 533) format(msg, sizeof msg, "АС Вал получен в инвентарь.");
        else format(msg, sizeof msg, "Товар %d получен в инвентарь.", itemId);
        CEFC_Notify(playerid, msg, "success");
    }
    CEF_CurrencySend(playerid);
    CEF_InvSync(playerid);
    CEF_TabPushData(playerid);
    format(dest, size, "{\"ok\":true,\"result\":true,\"donate\":%d,\"caseType\":%d}", gCefCurrency[playerid][CEF_CUR_AMAZING], itemId);
    return 1;
}

stock CEF_DonateShopCatalog(playerid, dest[], size)
{
    static part[128], cname[40];
    new first = 1, price;
    dest[0] = EOS;
    strcat(dest, "{\"items\":[", size);
    for(new i = 0; i < CEF_CASES_MAX; i++)
    {
        CEF_CaseNameByIndex(i, cname, sizeof cname);
        price = CEF_DonatePrice(CEF_CaseTypeByIndex(i));
        format(part, sizeof part,
            "%s{\"id\":%d,\"itemId\":%d,\"price\":%d,\"name\":\"%s\",\"amount\":1,\"category\":1}",
            first ? ("") : (","), CEF_CaseTypeByIndex(i), CEF_CaseTypeByIndex(i), price, cname);
        if(strlen(dest) + strlen(part) + 80 >= size) break;
        strcat(dest, part, size);
        first = 0;
    }
    format(part, sizeof part, "%s{\"id\":533,\"itemId\":533,\"price\":399,\"name\":\"АС Вал\",\"amount\":1,\"category\":2}", first ? ("") : (","));
    if(strlen(dest) + strlen(part) + 8 < size) { strcat(dest, part, size); first = 0; }
    format(part, sizeof part, "%s{\"id\":900,\"itemId\":900,\"price\":149,\"name\":\"Набор выживания\",\"amount\":1,\"category\":3}", first ? ("") : (","));
    if(strlen(dest) + strlen(part) + 8 < size) { strcat(dest, part, size); first = 0; }
    format(part, sizeof part, "%s{\"id\":901,\"itemId\":901,\"price\":449,\"name\":\"Боевой набор\",\"amount\":1,\"category\":3}", first ? ("") : (","));
    if(strlen(dest) + strlen(part) + 8 < size) strcat(dest, part, size);
    strcat(dest, "]}", size);
    #pragma unused playerid
    return 1;
}

stock CEF_DonateBalanceJson(playerid, dest[], size)
{
    new amz = gCefCurrency[playerid][CEF_CUR_AMAZING];
    if(PI[playerid][pDonate] > amz) amz = PI[playerid][pDonate];
    format(dest, size,
        "{\"ok\":true,\"result\":true,\"donate\":%d,\"balance\":%d,\"money\":%d,\"cash\":%d,\"rate\":1900}",
        amz, amz, PI[playerid][pCash], PI[playerid][pCash]);
    return 1;
}

stock CEF_DonateExchange(playerid, amount, dest[], size)
{
    new rub, msg[128];
    if(amount < 1) amount = 1;
    if(gCefCurrency[playerid][CEF_CUR_AMAZING] < amount)
    {
        CEFC_Notify(playerid, "Недостаточно амазингов для обмена.", "error");
        CEF_DonateBalanceJson(playerid, dest, size);
        return 0;
    }
    CEF_CurrencyGive(playerid, CEF_CUR_AMAZING, -amount);
    CEF_DonateSyncAccount(playerid);
    rub = amount * 1900;
    PI[playerid][pCash] += rub;
    GivePlayerMoney(playerid, rub);
    CEF_EcoSaveMoney(playerid);
    format(msg, sizeof msg, "Обмен: %d амазингов -> %d руб.", amount, rub);
    CEFC_Notify(playerid, msg, "success");
    CEF_CurrencySend(playerid);
    CEFC_AccountStats(playerid);
    CEF_DonateBalanceJson(playerid, dest, size);
    return 1;
}

stock CEF_DonateBuyPlus(playerid, dest[], size)
{
    new price = 999;
    if(gCefCurrency[playerid][CEF_CUR_AMAZING] < price)
    {
        CEFC_Notify(playerid, "Недостаточно амазингов на PLUS.", "error");
        CEF_DonateBalanceJson(playerid, dest, size);
        return 0;
    }
    CEF_CurrencyGive(playerid, CEF_CUR_AMAZING, -price);
    CEF_DonateSyncAccount(playerid);
    PI[playerid][pVip] = 1;
    PI[playerid][pVipExpire] = gettime() + 30 * 24 * 3600;
    CEFC_Notify(playerid, "Подписка AMAZING PLUS активирована.", "success");
    CEF_CurrencySend(playerid);
    CEFC_AccountStats(playerid);
    CEF_DonateBalanceJson(playerid, dest, size);
    return 1;
}

stock CEF_DonateBuyFamily(playerid, dest[], size)
{
    new price = 199;
    new familyTypes[3] = { 8, 10, 11 };
    new familyAmounts[3] = { 2, 2, 2 };
    if(!CEF_InvCanGiveBatch(playerid, familyTypes, familyAmounts, 3))
    {
        CEFC_Notify(playerid, "Inventory is full; free a slot before buying the family reward.", "error");
        CEF_DonateBalanceJson(playerid, dest, size);
        return 0;
    }
    if(gCefCurrency[playerid][CEF_CUR_AMAZING] < price)
    {
        CEFC_Notify(playerid, "Недостаточно амазингов.", "error");
        CEF_DonateBalanceJson(playerid, dest, size);
        return 0;
    }
    CEF_CurrencyGive(playerid, CEF_CUR_AMAZING, -price);
    CEF_DonateSyncAccount(playerid);
    GiveItem(playerid, 8, 2);
    GiveItem(playerid, 10, 2);
    GiveItem(playerid, 11, 2);
    SavePlayerInventory(playerid);
    CEFC_Notify(playerid, "Семейный набор куплен. Предметы в инвентаре.", "success");
    CEF_CurrencySend(playerid);
    CEF_InvSync(playerid);
    CEFC_AccountStats(playerid);
    CEF_DonateBalanceJson(playerid, dest, size);
    return 1;
}

stock CEF_DonateShopRpc(playerid, const arguments[], dest[], size)
{
    new key = CEF_EcoFindInt(arguments, "key");
    new itemId = CEF_ShopItemId(arguments);
    new amount = CEF_EcoFindInt(arguments, "amount");
    new spaPrice = CEF_EcoFindInt(arguments, "price");
    if(!spaPrice) spaPrice = CEF_EcoFindInt(arguments, "cost");
    if(!amount) amount = CEF_EcoFindInt(arguments, "count");
    if(!amount) amount = CEF_EcoFindInt(arguments, "quantity");
    if(!amount) amount = 1;
    printf("[CEF-SHOP] %d key=%d item=%d amount=%d price=%d args=%s", playerid, key, itemId, amount, spaPrice, arguments);
    if(key == 0)
    {
        static extra[1600];
        CEF_DonateShopCatalog(playerid, extra, sizeof extra);
        CEF_Send(playerid, "cef_shop_set_extra_items", extra);
        return CEF_DonateBalanceJson(playerid, dest, size);
    }
    if(key == 3 || strfind(arguments, "exchange", true) != -1 || strfind(arguments, "convert", true) != -1)
        return CEF_DonateExchange(playerid, amount, dest, size);
    if(key == 5 || key == 6 || strfind(arguments, "plus", true) != -1 || strfind(arguments, "subscribe", true) != -1)
        return CEF_DonateBuyPlus(playerid, dest, size);
    if(strfind(arguments, "familyName", true) != -1 || strfind(arguments, "family", true) != -1)
        return CEF_DonateBuyFamily(playerid, dest, size);
    if(strfind(arguments, "nick", true) != -1 || strfind(arguments, "nickname", true) != -1)
        return CEF_DonateBuyNick(playerid, arguments, dest, size);
    if(strfind(arguments, "military", true) != -1 || strfind(arguments, "voenbilet", true) != -1)
        return CEF_DonateBuyMilitary(playerid, dest, size);
    if(strfind(arguments, "kit", true) != -1 || strfind(arguments, "nabor", true) != -1)
    {
        if(!CEF_DonateCanGiveKit(playerid, 1))
        {
            CEFC_Notify(playerid, "Inventory is full; free a slot before buying this kit.", "error");
            return CEF_DonateBalanceJson(playerid, dest, size);
        }
        if(gCefCurrency[playerid][CEF_CUR_AMAZING] < 149)
        {
            CEFC_Notify(playerid, "Недостаточно амазингов.", "error");
            return CEF_DonateBalanceJson(playerid, dest, size);
        }
        CEF_CurrencyGive(playerid, CEF_CUR_AMAZING, -149);
        CEF_DonateSyncAccount(playerid);
        CEF_DonateGiveKit(playerid, 1);
        CEF_CurrencySend(playerid);
        return CEF_DonateBalanceJson(playerid, dest, size);
    }
    if(strfind(arguments, "blueprint", true) != -1 || strfind(arguments, "chertezh", true) != -1)
    {
        if(!itemId) itemId = 800;
        if(!spaPrice) spaPrice = 80;
        return CEF_DonateBuy(playerid, itemId, amount, spaPrice, dest, size);
    }
    if(strfind(arguments, "topup", true) != -1 || strfind(arguments, "replenish", true) != -1)
    {
        CEFC_NotifyFull(playerid, "Пополнить счёт", "Пополнение амазингов: /givedonate (админ) или донат на сайте.", 7000);
        return CEF_DonateBalanceJson(playerid, dest, size);
    }
    if(key == 1 || key == 2 || key == 4)
    {
        if(itemId <= 0)
        {
            CEFC_Notify(playerid, "Этот товар пока не продаётся. Амазинги не списаны.", "error");
            format(dest, size, "{\"ok\":false,\"result\":false,\"donate\":%d}", gCefCurrency[playerid][CEF_CUR_AMAZING]);
            return 0;
        }
        return CEF_DonateBuy(playerid, itemId, amount, spaPrice, dest, size);
    }
    if(itemId > 0)
        return CEF_DonateBuy(playerid, itemId, amount, spaPrice, dest, size);
    CEF_DonateBalanceJson(playerid, dest, size);
    CEF_CurrencySend(playerid);
    CEFC_AccountStats(playerid);
    return 1;
}

stock CEF_DonateBuyNick(playerid, const arguments[], dest[], size)
{
    new nick[MAX_PLAYER_NAME], q[220], price = 400;
    CEF_JsonStr(arguments, "nickname", nick, sizeof nick);
    if(!nick[0]) CEF_JsonStr(arguments, "name", nick, sizeof nick);
    if(!nick[0]) CEF_JsonStr(arguments, "value", nick, sizeof nick);
    if(!nick[0] || strlen(nick) < 3 || strlen(nick) > 20)
    {
        CEFC_Notify(playerid, "Укажите новый ник 3-20 символов.", "error");
        CEF_DonateBalanceJson(playerid, dest, size);
        return 0;
    }
    if(gCefCurrency[playerid][CEF_CUR_AMAZING] < price)
    {
        CEFC_Notify(playerid, "Недостаточно амазингов на смену ника.", "error");
        CEF_DonateBalanceJson(playerid, dest, size);
        return 0;
    }
    if(SetPlayerName(playerid, nick) != 1)
    {
        CEFC_Notify(playerid, "Ник занят или недопустим.", "error");
        CEF_DonateBalanceJson(playerid, dest, size);
        return 0;
    }
    CEF_CurrencyGive(playerid, CEF_CUR_AMAZING, -price);
    CEF_DonateSyncAccount(playerid);
    format(PI[playerid][pName], MAX_PLAYER_NAME, "%s", nick);
    mysql_format(dbHandle, q, sizeof q, "UPDATE `accounts` SET `name`='%e' WHERE `id`=%d LIMIT 1", nick, PI[playerid][pID]);
    mysql_tquery(dbHandle, q);
    CEFC_Notify(playerid, "Ник изменён.", "success");
    CEF_CurrencySend(playerid);
    CEFC_AccountStats(playerid);
    CEF_DonateBalanceJson(playerid, dest, size);
    return 1;
}

stock CEF_DonateBuyMilitary(playerid, dest[], size)
{
    new price = 200;
    if(gCefMilitary[playerid])
    {
        CEFC_Notify(playerid, "Военный билет уже есть.", "hint");
        CEF_DonateBalanceJson(playerid, dest, size);
        return 0;
    }
    if(gCefCurrency[playerid][CEF_CUR_AMAZING] < price)
    {
        CEFC_Notify(playerid, "Недостаточно амазингов на военный билет.", "error");
        CEF_DonateBalanceJson(playerid, dest, size);
        return 0;
    }
    CEF_CurrencyGive(playerid, CEF_CUR_AMAZING, -price);
    CEF_DonateSyncAccount(playerid);
    gCefMilitary[playerid] = 1;
    CEFC_Notify(playerid, "Военный билет получен.", "success");
    CEF_CurrencySend(playerid);
    CEFC_AccountStats(playerid);
    CEF_DonateBalanceJson(playerid, dest, size);
    return 1;
}

CMD:givedonate(playerid, params[])
{
    new spec[] = "ud", target, amount, err[48];
    if(PI[playerid][pAdmin] < 6)
    {
        err = "Нужен админ 6+";
        return SendErr(playerid, err);
    }
    if(sscanf(params, spec, target, amount))
    {
        err = "/givedonate [id] [амазинги]";
        return SendErr(playerid, err);
    }
    if(!IsPlayerConnected(target))
    {
        err = "Игрок не найден";
        return SendErr(playerid, err);
    }
    CEF_CurrencyGive(target, CEF_CUR_AMAZING, amount);
    CEF_DonateSyncAccount(target);
    return 1;
}

CMD:giveskin(playerid, params[])
{
    new spec[] = "ud", target, skinId, err[48];
    if(PI[playerid][pAdmin] < 6)
    {
        err = "Нужен админ 6+";
        return SendErr(playerid, err);
    }
    if(sscanf(params, spec, target, skinId))
    {
        err = "/giveskin [id] [skinId]";
        return SendErr(playerid, err);
    }
    if(!IsPlayerConnected(target))
    {
        err = "Игрок не найден";
        return SendErr(playerid, err);
    }
    CEF_SkinGive(target, skinId);
    return 1;
}

CMD:myskins(playerid, params[])
{
    #pragma unused params
    static msg[144];
    format(msg, sizeof msg, "Скинов: %d. Надет: %d. Амазинги: %d", gCefSkinCount[playerid], gCefSkinWearId[playerid], gCefCurrency[playerid][CEF_CUR_AMAZING]);
    CEFC_Notify(playerid, msg, "info");
    return 1;
}
