#define MAX_ITEMS 25
forward CEF_InvRememberIdx(playerid, slot, idx);
forward CEF_InventoryOnDataReady(playerid);
forward CEF_InventoryLoadWatch(playerid, load_serial);
forward CEF_InventoryOpen(playerid);
forward CEF_InvSync(playerid);
forward CEF_StorageReset(playerid);
forward CEF_StorageLoad(playerid);
forward CEF_StorageSend(playerid);
forward CEF_OpsQuickSlotsLoad(playerid);
enum InventoryStruct
{
    iID,
    iType,
    iAmount
}
new IT[MAX_PLAYERS][MAX_ITEMS][InventoryStruct];
new gCefInvLoadSerial[MAX_PLAYERS];
new bool:gCefInventoryItemsLoaded[MAX_PLAYERS];
new gCefQuickSlotType[MAX_PLAYERS][6];

stock CEF_InventoryClear(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS) return 0;
    gCefInventoryItemsLoaded[playerid] = false;
    for(new i = 0; i < MAX_ITEMS; i++)
    {
        IT[playerid][i][iID] = 0;
        IT[playerid][i][iType] = 0;
        IT[playerid][i][iAmount] = 0;
    }
    PI[playerid][pInventorySlotsUsed] = 0;
    for(new q = 0; q < 6; q++) gCefQuickSlotType[playerid][q] = 0;
    return 1;
}

stock CEF_InvLoadBegin(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS) return 0;
    gCefInvLoadSerial[playerid]++;
    if(gCefInvLoadSerial[playerid] <= 0) gCefInvLoadSerial[playerid] = 1;
    CEF_InventoryClear(playerid);
    CEF_StorageReset(playerid);
    return gCefInvLoadSerial[playerid];
}

enum Items
{
    itemName[30],
    itemMaxAmount
};

new Item[14][Items] =
{
    { "Пусто", 5 },
    { "Предмет 1", 5},
    { "Предмет 2", 10},
    { "Предмет 3", 15},
    { "Предмет 4", 15},
    { "Предмет 5", 20},
    { "Канистра", 5},
    { "Ремкомплект", 10},
    { "Аптечка", 10},
    { "Бензин", 20},
    { "Еда", 10},
    { "Вода", 10},
    { "Броня", 5},
    { "Маска", 5}
};

enum 
{
    ITEM_TYPE_NONE,
    ITEM_TYPE_SKIN,
    ITEM_TYPE_HEAL
}

public CEF_InventoryLoadWatch(playerid, load_serial)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid)) return 1;
    if(gCefInvLoadSerial[playerid] != load_serial) return 1;
    if(gCefInventoryItemsLoaded[playerid]) return 1;
    gCefInventoryItemsLoaded[playerid] = true;
    PI[playerid][pInventorySlotsUsed] = 0;
    printf("[INV] watchdog player=%d serial=%d: MySQL callback not received, unlocking CEF inventory and retrying query", playerid, load_serial);
    new q[256];
    mysql_format(dbHandle, q, sizeof q, "SELECT * FROM `items` WHERE `item_owner_id`=%d AND `item_type`>0 AND `item_amount`>0 AND `item_slot` BETWEEN 0 AND 25 ORDER BY `item_slot` ASC", PI[playerid][pID]);
    mysql_tquery(dbHandle, q, "CEF_LoadPlayerInventory", "iii", playerid, PI[playerid][pID], load_serial);
    CEF_InventoryOnDataReady(playerid);
    return 1;
}

callback::CEF_LoadPlayerInventory(playerid, owner_id, load_serial)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid)) return 0;
    printf("[INV] callback player=%d owner=%d serial=%d current=%d sqlid=%d", playerid, owner_id, load_serial, gCefInvLoadSerial[playerid], PI[playerid][pID]);
    if(PI[playerid][pID] != owner_id) return 0;
    if(gCefInvLoadSerial[playerid] != load_serial) return 0;

    new rows = 0, item_slot, item_type, item_amount, target_slot;
    new used = 0, bool:zero_based = false;
    CEF_InventoryClear(playerid);
    cache_get_row_count(rows);
    for(new row = 0; row < rows; row++)
    {
        item_slot = -1;
        item_type = 0;
        item_amount = 0;
        cache_get_value_name_int(row, "item_slot", item_slot);
        cache_get_value_name_int(row, "item_type", item_type);
        cache_get_value_name_int(row, "item_amount", item_amount);
        if(item_slot == 0 && item_type > 0 && item_amount > 0) zero_based = true;
    }
    for(new row = 0; row < rows; row++)
    {
        item_slot = -1;
        item_type = 0;
        item_amount = 0;
        cache_get_value_name_int(row, "item_slot", item_slot);
        cache_get_value_name_int(row, "item_type", item_type);
        cache_get_value_name_int(row, "item_amount", item_amount);
        if(item_type <= 0 || item_amount <= 0) continue;
        target_slot = zero_based ? item_slot : item_slot - 1;
        if(target_slot < 0 || target_slot >= MAX_ITEMS) continue;
        if(IT[playerid][target_slot][iType] > 0) continue;
        cache_get_value_name_int(row, "id", IT[playerid][target_slot][iID]);
        IT[playerid][target_slot][iType] = item_type;
        IT[playerid][target_slot][iAmount] = item_amount;
        used++;
    }
    PI[playerid][pInventorySlotsUsed] = used;
    gCefInventoryItemsLoaded[playerid] = true;
    CEF_OpsQuickSlotsLoad(playerid);
    CEF_StorageLoad(playerid);
    if(PT[playerid][pLogged]) CEF_InvSync(playerid);
    CEF_InventoryOnDataReady(playerid);
    printf("[INV] loaded owner=%d player=%d stacks=%d", owner_id, playerid, used);
    return 1;
}

cmd:inv(playerid)
{
    ShowPlayerInventory(playerid);
}

cmd:inv1(playerid)
{
    SendClientMessage(playerid, -1, "Вы открыли инвентарь!");
    ShowPlayerInventory(playerid);
}

stock CEF_InvSync(playerid)
{
    new json[CEF_JSON_SIZE], part[160], first = 1, slot = 6, i;
    CEF_MarkPlayerReady(playerid);
    CEF_InvRememberClear(playerid);
    CEF_OpsInventoryIndicators(playerid);
    CEF_OpsQuickSlots(playerid, false);
    format(json, sizeof json, "{\"max_slots\":36,\"current_slots\":%d}", PI[playerid][pInventorySlotsUsed]);
    CEF_Send(playerid, "cef_inv_update_info", json);
    json[0] = '[';
    json[1] = EOS;
    for(i = 0; i < MAX_ITEMS; i++)
    {
        if(IT[playerid][i][iType] <= 0) continue;
        {
            new spaType = CEF_ItemToSpa(IT[playerid][i][iType]);
            if(spaType <= 0) continue;
            if(spaType == 9) continue;
            if(spaType == GetPlayerSkin(playerid)) continue;
            if(CEF_SkinHas(playerid, spaType)) continue;
            format(part, sizeof part, "%s{\"slotId\":%d,\"type\":%d,\"value\":%d,\"extraValue\":0}", first ? ("") : (","), slot, spaType, IT[playerid][i][iAmount]);
            strcat(json, part);
            CEF_InvRemember(playerid, slot, IT[playerid][i][iType]);
            CEF_InvRememberIdx(playerid, slot, i);
            first = 0;
            slot++;
        }
    }

    {
        static casesJson[600];
        slot = CEF_CasesInventoryJson(playerid, casesJson, sizeof casesJson, slot, !first);
        if(strlen(casesJson)) { strcat(json, casesJson); first = 0; }
        {
            static spaJson[700];
            slot = CEF_SpaOwnInventoryJson(playerid, spaJson, sizeof spaJson, slot, !first);
            if(strlen(spaJson)) strcat(json, spaJson);
        }

    }
    strcat(json, "]");
    CEF_Send(playerid, "cef_inv_update_main_items", json);
    {
        static att[64];
        format(att, sizeof att, "{\"pedModel\":%d}", GetPlayerSkin(playerid));
        CEF_Send(playerid, "cef_inv_update_attaches", att);
    }
    CEF_StorageSend(playerid);
    CEFC_AccountStats(playerid);
    return 1;
}

forward ShowPlayerInventory(playerid);
public ShowPlayerInventory(playerid)
{
    return CEF_InventoryOpen(playerid);
}


stock GetItemName(itemid)
{
    if(itemid < 0 || itemid >= sizeof(Item)) return Item[0][itemName];
    return Item[itemid][itemName];
}

stock CEF_InventoryCountSlots(playerid)
{
    new used = 0;
    for(new i = 0; i < MAX_ITEMS; i++)
        if(IT[playerid][i][iType] > 0 && IT[playerid][i][iAmount] > 0) used++;
    PI[playerid][pInventorySlotsUsed] = used;
    return used;
}

stock CEF_InventoryFindFreeSlot(playerid)
{
    for(new i = 0; i < MAX_ITEMS; i++)
        if(IT[playerid][i][iType] <= 0 || IT[playerid][i][iAmount] <= 0) return i;
    return -1;
}

stock CEF_InventoryCompact(playerid)
{
    new write = 0;
    for(new read = 0; read < MAX_ITEMS; read++)
    {
        if(IT[playerid][read][iType] <= 0 || IT[playerid][read][iAmount] <= 0) continue;
        if(write != read)
        {
            IT[playerid][write][iID] = IT[playerid][read][iID];
            IT[playerid][write][iType] = IT[playerid][read][iType];
            IT[playerid][write][iAmount] = IT[playerid][read][iAmount];
        }
        write++;
    }
    for(new i = write; i < MAX_ITEMS; i++)
    {
        IT[playerid][i][iID] = 0;
        IT[playerid][i][iType] = 0;
        IT[playerid][i][iAmount] = 0;
    }
    PI[playerid][pInventorySlotsUsed] = write;
    return write;
}

stock CEF_InvCanGive(playerid, type, amount)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || amount <= 0 || type <= 0 || type >= sizeof(Item)) return 0;
    new maxAmount = Item[type][itemMaxAmount], room = 0, remaining, needed, used;
    if(maxAmount <= 0) return 0;
    used = CEF_InventoryCountSlots(playerid);
    for(new i = 0; i < MAX_ITEMS; i++)
    {
        if(IT[playerid][i][iType] == type && IT[playerid][i][iAmount] < maxAmount)
            room += maxAmount - IT[playerid][i][iAmount];
    }
    remaining = amount - room;
    if(remaining <= 0) return 1;
    needed = remaining / maxAmount;
    if(remaining % maxAmount) needed++;
    return (used + needed <= MAX_ITEMS);
}

stock CEF_InvCanGiveBatch(playerid, const types[], const amounts[], count)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || count <= 0 || count > MAX_ITEMS) return 0;
    new batchAmount[sizeof(Item)], room, remaining, maxAmount, needed = 0;
    new used = CEF_InventoryCountSlots(playerid);
    for(new type = 0; type < sizeof(Item); type++) batchAmount[type] = 0;
    for(new i = 0; i < count; i++)
    {
        if(types[i] <= 0 || types[i] >= sizeof(Item) || amounts[i] <= 0) return 0;
        batchAmount[types[i]] += amounts[i];
    }
    for(new type = 1; type < sizeof(Item); type++)
    {
        if(batchAmount[type] <= 0) continue;
        maxAmount = Item[type][itemMaxAmount];
        if(maxAmount <= 0) return 0;
        room = 0;
        for(new slot = 0; slot < MAX_ITEMS; slot++)
        {
            if(IT[playerid][slot][iType] == type && IT[playerid][slot][iAmount] < maxAmount)
                room += maxAmount - IT[playerid][slot][iAmount];
        }
        remaining = batchAmount[type] - room;
        if(remaining <= 0) continue;
        needed += remaining / maxAmount;
        if(remaining % maxAmount) needed++;
    }
    return (used + needed <= MAX_ITEMS);
}

stock GiveItem(playerid, type, amount)
{
    if(!CEF_InvCanGive(playerid, type, amount))
    {
        if(playerid >= 0 && playerid < MAX_PLAYERS)
            SendErr(playerid, "\xc8\xed\xe2\xe5\xed\xf2\xe0\xf0\xfc \xef\xe5\xf0\xe5\xef\xee\xeb\xed\xe5\xed \xe8\xeb\xe8 \xed\xe5\xe4\xee\xef\xf3\xf1\xf2\xe8\xec \xef\xf0\xe5\xe4\xec\xe5\xf2!");
        return 0;
    }
    new maxAmount = Item[type][itemMaxAmount], remaining = amount;
    for(new i = 0; i < MAX_ITEMS && remaining > 0; i++)
    {
        if(IT[playerid][i][iType] != type || IT[playerid][i][iAmount] >= maxAmount) continue;
        new room = maxAmount - IT[playerid][i][iAmount];
        new add = (remaining < room) ? remaining : room;
        IT[playerid][i][iAmount] += add;
        remaining -= add;
    }
    while(remaining > 0)
    {
        new slot = CEF_InventoryFindFreeSlot(playerid);
        if(slot < 0) return 0;
        new add = (remaining < maxAmount) ? remaining : maxAmount;
        IT[playerid][slot][iID] = 0;
        IT[playerid][slot][iType] = type;
        IT[playerid][slot][iAmount] = add;
        remaining -= add;
    }
    CEF_InventoryCountSlots(playerid);
    return 1;
}

stock RemoveItem(playerid, type, amount)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || amount <= 0 || type <= 0) return 0;
    new available = 0;
    for(new i = 0; i < MAX_ITEMS; i++)
        if(IT[playerid][i][iType] == type && IT[playerid][i][iAmount] > 0) available += IT[playerid][i][iAmount];
    if(available < amount)
    {
        SendErr(playerid, "\xd3 \xc2\xe0\xf1 \xed\xe5\xf2 \xf2\xe0\xea\xee\xe3\xee \xef\xf0\xe5\xe4\xec\xe5\xf2\xe0!");
        return 0;
    }

    new left = amount;
    for(new i = 0; i < MAX_ITEMS && left > 0; i++)
    {
        if(IT[playerid][i][iType] != type || IT[playerid][i][iAmount] <= 0) continue;
        if(IT[playerid][i][iAmount] > left)
        {
            IT[playerid][i][iAmount] -= left;
            left = 0;
        }
        else
        {
            left -= IT[playerid][i][iAmount];
            IT[playerid][i][iID] = 0;
            IT[playerid][i][iType] = 0;
            IT[playerid][i][iAmount] = 0;
        }
    }
    CEF_InventoryCompact(playerid);
    return 1;
}

cmd:testadd(playerid)
{
    GiveItem(playerid, 1, 5);
    return 1;
}

cmd:testremove(playerid)
{
    RemoveItem(playerid, 1, 2);
    return 1;
}

stock SavePlayerInventory(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || PI[playerid][pID] <= 0) return 0;
    CEF_InventoryCountSlots(playerid);



    new query[3072], part[96], item_type, item_amount;
    format(query, sizeof query, "INSERT INTO `items` (`item_owner_id`,`item_type`,`item_amount`,`item_slot`) VALUES");
    for(new db_slot = 0; db_slot <= MAX_ITEMS; db_slot++)
    {
        if(db_slot == 0)
        {
            item_type = 0;
            item_amount = 0;
        }
        else
        {
            item_type = IT[playerid][db_slot - 1][iType];
            item_amount = IT[playerid][db_slot - 1][iAmount];
            if(item_type <= 0 || item_amount <= 0) { item_type = 0; item_amount = 0; }
        }
        format(part, sizeof part, "%s(%d,%d,%d,%d)", db_slot ? "," : "", PI[playerid][pID], item_type, item_amount, db_slot);
        strcat(query, part, sizeof query);
    }
    strcat(query, " ON DUPLICATE KEY UPDATE `item_type`=VALUES(`item_type`),`item_amount`=VALUES(`item_amount`)", sizeof query);
    mysql_tquery(dbHandle, query, "", "");
    return 1;
}
