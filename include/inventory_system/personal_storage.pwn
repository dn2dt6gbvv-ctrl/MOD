#if defined _cef_personal_storage_included
    #endinput
#endif
#define _cef_personal_storage_included

#define CEF_STORAGE_SLOTS 36
#define CEF_INV_AREA_STORAGE 3
#define CEF_STORAGE_AREA_MAIN 1

enum E_CEF_STORAGE_ITEM
{
    cefStorageType,
    cefStorageAmount
}

new gCefPlayerStorage[MAX_PLAYERS][CEF_STORAGE_SLOTS][E_CEF_STORAGE_ITEM];
new gCefStorageLoaded[MAX_PLAYERS];
new gCefStorageLoading[MAX_PLAYERS];
new gCefStorageOpen[MAX_PLAYERS];
new gCefStoragePendingOpen[MAX_PLAYERS];
new gCefStorageLoadSerial[MAX_PLAYERS];

stock CEF_StorageClear(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS) return 0;
    for(new slot = 0; slot < CEF_STORAGE_SLOTS; slot++)
    {
        gCefPlayerStorage[playerid][slot][cefStorageType] = 0;
        gCefPlayerStorage[playerid][slot][cefStorageAmount] = 0;
    }
    return 1;
}

stock CEF_StorageReset(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS) return 0;
    gCefStorageLoadSerial[playerid]++;
    if(gCefStorageLoadSerial[playerid] <= 0) gCefStorageLoadSerial[playerid] = 1;
    gCefStorageLoaded[playerid] = 0;
    gCefStorageLoading[playerid] = 0;
    gCefStorageOpen[playerid] = 0;
    gCefStoragePendingOpen[playerid] = 0;
    CEF_StorageClear(playerid);
    return 1;
}

stock CEF_StorageInit()
{
    mysql_tquery(dbHandle,
        "CREATE TABLE IF NOT EXISTS `cef_player_storage` (`owner_id` INT NOT NULL, `slot_id` TINYINT UNSIGNED NOT NULL, `item_type` SMALLINT UNSIGNED NOT NULL DEFAULT 0, `item_amount` SMALLINT UNSIGNED NOT NULL DEFAULT 0, PRIMARY KEY (`owner_id`,`slot_id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
    return 1;
}

forward CEF_StorageLoad(playerid);
stock CEF_StorageLoad(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) || PI[playerid][pID] <= 0) return 0;
    if(gCefStorageLoaded[playerid] || gCefStorageLoading[playerid]) return 1;
    gCefStorageLoadSerial[playerid]++;
    if(gCefStorageLoadSerial[playerid] <= 0) gCefStorageLoadSerial[playerid] = 1;
    gCefStorageLoading[playerid] = 1;
    CEF_StorageClear(playerid);
    new query[240];
    mysql_format(dbHandle, query, sizeof query,
        "SELECT `slot_id`,`item_type`,`item_amount` FROM `cef_player_storage` WHERE `owner_id`=%d ORDER BY `slot_id` ASC",
        PI[playerid][pID]);
    mysql_tquery(dbHandle, query, "OnCefPlayerStorageLoaded", "iii",
        playerid, PI[playerid][pID], gCefStorageLoadSerial[playerid]);
    return 1;
}

forward OnCefPlayerStorageLoaded(playerid, owner_id, load_serial);
public OnCefPlayerStorageLoaded(playerid, owner_id, load_serial)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid)) return 0;
    if(PI[playerid][pID] != owner_id || gCefStorageLoadSerial[playerid] != load_serial) return 0;
    gCefStorageLoading[playerid] = 0;
    CEF_StorageClear(playerid);
    new rows = cache_num_rows(), slot, type, amount, maxAmount;
    for(new row = 0; row < rows; row++)
    {
        slot = -1;
        type = 0;
        amount = 0;
        cache_get_value_name_int(row, "slot_id", slot);
        cache_get_value_name_int(row, "item_type", type);
        cache_get_value_name_int(row, "item_amount", amount);
        if(slot < 0 || slot >= CEF_STORAGE_SLOTS || type <= 0 || type >= sizeof(Item) || amount <= 0) continue;
        maxAmount = Item[type][itemMaxAmount];
        if(maxAmount <= 0 || amount > maxAmount) continue;
        gCefPlayerStorage[playerid][slot][cefStorageType] = type;
        gCefPlayerStorage[playerid][slot][cefStorageAmount] = amount;
    }
    gCefStorageLoaded[playerid] = 1;
    if(gCefStoragePendingOpen[playerid] && PT[playerid][pLogged])
    {
        gCefStoragePendingOpen[playerid] = 0;
        gCefStorageOpen[playerid] = 1;
        OpenTabCEF(playerid, 2);
        CEF_InvSync(playerid);
    }
    else if(gCefStorageOpen[playerid]) CEF_InvSync(playerid);
    return 1;
}

stock CEF_StorageSave(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || PI[playerid][pID] <= 0 || !gCefStorageLoaded[playerid]) return 0;
    new query[3072], part[80], type, amount;
    format(query, sizeof query,
        "INSERT INTO `cef_player_storage` (`owner_id`,`slot_id`,`item_type`,`item_amount`) VALUES");
    for(new slot = 0; slot < CEF_STORAGE_SLOTS; slot++)
    {
        type = gCefPlayerStorage[playerid][slot][cefStorageType];
        amount = gCefPlayerStorage[playerid][slot][cefStorageAmount];
        if(type <= 0 || type >= sizeof(Item) || amount <= 0)
        {
            type = 0;
            amount = 0;
        }
        format(part, sizeof part, "%s(%d,%d,%d,%d)", slot ? "," : "",
            PI[playerid][pID], slot, type, amount);
        strcat(query, part, sizeof query);
    }
    strcat(query,
        " ON DUPLICATE KEY UPDATE `item_type`=VALUES(`item_type`),`item_amount`=VALUES(`item_amount`)",
        sizeof query);
    mysql_tquery(dbHandle, query);
    return 1;
}

stock CEF_StorageIsVisible(playerid)
{
    return (playerid >= 0 && playerid < MAX_PLAYERS && gCefStorageOpen[playerid] && gCefStorageLoaded[playerid]);
}

stock CEF_StorageClose(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS) return 0;
    gCefStorageOpen[playerid] = 0;
    gCefStoragePendingOpen[playerid] = 0;
    CEF_Send(playerid, "cef_inv_update_extra_items", "{\"storageId\":0}");
    return 1;
}

stock CEF_StorageSend(playerid)
{
    if(!CEF_StorageIsVisible(playerid)) return CEF_Send(playerid, "cef_inv_update_extra_items", "{\"storageId\":0}");
    new json[4096], part[112], spaType, type, amount, first = 1;
    format(json, sizeof json,
        "{\"storageId\":%d,\"storageName\":\"Personal storage\",\"maxSlots\":%d,\"items\":[",
        PI[playerid][pID], CEF_STORAGE_SLOTS);
    for(new slot = 0; slot < CEF_STORAGE_SLOTS; slot++)
    {
        type = gCefPlayerStorage[playerid][slot][cefStorageType];
        amount = gCefPlayerStorage[playerid][slot][cefStorageAmount];
        spaType = type > 0 ? CEF_ItemToSpa(type) : 0;
        if(type > 0 && spaType <= 0) continue;
        format(part, sizeof part, "%s{\"slotId\":%d,\"type\":%d,\"value\":%d,\"extraValue\":0}",
            first ? "" : ",", slot, spaType, amount);
        strcat(json, part, sizeof json);
        first = 0;
    }
    strcat(json, "]}", sizeof json);
    return CEF_Send(playerid, "cef_inv_update_extra_items", json);
}

stock CEF_StorageTransfer(playerid, fromArea, fromIndex, toArea, toIndex)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !PT[playerid][pLogged] || !CEF_StorageIsVisible(playerid))
        return 0;
    if(fromArea == CEF_INV_AREA_STORAGE && toArea == CEF_INV_AREA_STORAGE)
    {
        if(fromIndex < 0 || fromIndex >= CEF_STORAGE_SLOTS || toIndex < 0 || toIndex >= CEF_STORAGE_SLOTS)
            return CEFC_Notify(playerid, "That storage slot is invalid.", "hint");
        if(fromIndex == toIndex) return 1;
        new sourceType = gCefPlayerStorage[playerid][fromIndex][cefStorageType];
        new sourceAmount = gCefPlayerStorage[playerid][fromIndex][cefStorageAmount];
        new targetType = gCefPlayerStorage[playerid][toIndex][cefStorageType];
        new targetAmount = gCefPlayerStorage[playerid][toIndex][cefStorageAmount];
        if(sourceType <= 0 || sourceAmount <= 0) return 0;
        if(targetType == 0)
        {
            gCefPlayerStorage[playerid][toIndex][cefStorageType] = sourceType;
            gCefPlayerStorage[playerid][toIndex][cefStorageAmount] = sourceAmount;
            gCefPlayerStorage[playerid][fromIndex][cefStorageType] = 0;
            gCefPlayerStorage[playerid][fromIndex][cefStorageAmount] = 0;
        }
        else if(targetType == sourceType && targetAmount + sourceAmount <= Item[sourceType][itemMaxAmount])
        {
            gCefPlayerStorage[playerid][toIndex][cefStorageAmount] = targetAmount + sourceAmount;
            gCefPlayerStorage[playerid][fromIndex][cefStorageType] = 0;
            gCefPlayerStorage[playerid][fromIndex][cefStorageAmount] = 0;
        }
        else if(targetType != sourceType)
        {
            gCefPlayerStorage[playerid][fromIndex][cefStorageType] = targetType;
            gCefPlayerStorage[playerid][fromIndex][cefStorageAmount] = targetAmount;
            gCefPlayerStorage[playerid][toIndex][cefStorageType] = sourceType;
            gCefPlayerStorage[playerid][toIndex][cefStorageAmount] = sourceAmount;
        }
        else return CEFC_Notify(playerid, "The target stack does not have enough room.", "hint");
        CEF_StorageSave(playerid);
        return CEF_StorageSend(playerid);
    }

    if(fromArea == CEF_STORAGE_AREA_MAIN && toArea == CEF_INV_AREA_STORAGE)
    {
        if(fromIndex < 6 || fromIndex >= 64 || toIndex < 0 || toIndex >= CEF_STORAGE_SLOTS)
            return CEFC_Notify(playerid, "That inventory slot is invalid.", "hint");
        CEF_InventoryCompact(playerid);
        CEF_InvSync(playerid);
        new idx = gCefInvIdx[playerid][fromIndex];
        if(idx < 0 || idx >= MAX_ITEMS) return CEFC_Notify(playerid, "There is no transferable item in that slot.", "hint");
        new itemType = IT[playerid][idx][iType];
        new amount = IT[playerid][idx][iAmount];
        if(itemType <= 0 || itemType >= sizeof(Item) || amount <= 0 || CEF_ItemToSpa(itemType) <= 0)
            return CEFC_Notify(playerid, "This item cannot be stored.", "hint");
        new targetType = gCefPlayerStorage[playerid][toIndex][cefStorageType];
        new targetAmount = gCefPlayerStorage[playerid][toIndex][cefStorageAmount];
        if(targetType != 0 && targetType != itemType)
            return CEFC_Notify(playerid, "That storage slot is occupied.", "hint");
        if(targetAmount + amount > Item[itemType][itemMaxAmount])
            return CEFC_Notify(playerid, "The target stack does not have enough room.", "hint");
        if(!RemoveItem(playerid, itemType, amount))
            return CEFC_Notify(playerid, "The item could not be moved.", "error");
        gCefPlayerStorage[playerid][toIndex][cefStorageType] = itemType;
        gCefPlayerStorage[playerid][toIndex][cefStorageAmount] = targetAmount + amount;
        CEF_StorageSave(playerid);
        SavePlayerInventory(playerid);
        CEF_InvSync(playerid);
        return 1;
    }

    if(fromArea == CEF_INV_AREA_STORAGE && toArea == CEF_STORAGE_AREA_MAIN)
    {
        if(fromIndex < 0 || fromIndex >= CEF_STORAGE_SLOTS || toIndex < 6 || toIndex >= 64)
            return CEFC_Notify(playerid, "That inventory or storage slot is invalid.", "hint");
        new itemType = gCefPlayerStorage[playerid][fromIndex][cefStorageType];
        new amount = gCefPlayerStorage[playerid][fromIndex][cefStorageAmount];
        if(itemType <= 0 || itemType >= sizeof(Item) || amount <= 0 || CEF_ItemToSpa(itemType) <= 0)
            return CEFC_Notify(playerid, "There is no transferable item in that storage slot.", "hint");
        CEF_InventoryCompact(playerid);
        CEF_InvSync(playerid);
        new targetIdx = gCefInvIdx[playerid][toIndex];
        new targetSpaType = gCefInvType[playerid][toIndex];
        if(targetIdx >= 0 && IT[playerid][targetIdx][iType] != itemType)
            return CEFC_Notify(playerid, "That inventory slot is occupied.", "hint");
        if(targetIdx < 0 && targetSpaType > 0)
            return CEFC_Notify(playerid, "That inventory slot is occupied.", "hint");
        if(!CEF_InvCanGive(playerid, itemType, amount))
            return CEFC_Notify(playerid, "Your inventory is full.", "error");
        if(!GiveItem(playerid, itemType, amount))
            return CEFC_Notify(playerid, "The item could not be moved.", "error");
        gCefPlayerStorage[playerid][fromIndex][cefStorageType] = 0;
        gCefPlayerStorage[playerid][fromIndex][cefStorageAmount] = 0;
        CEF_StorageSave(playerid);
        SavePlayerInventory(playerid);
        CEF_InvSync(playerid);
        return 1;
    }
    return CEFC_Notify(playerid, "Only inventory and personal storage items can be moved here.", "hint");
}

stock CEF_StorageMoveBySlots(playerid, fromArea, fromSlot, toArea, toSlot)
{
    if(fromArea != CEF_INV_AREA_STORAGE && toArea != CEF_INV_AREA_STORAGE) return 0;
    return CEF_StorageTransfer(playerid, fromArea, fromSlot, toArea, toSlot);
}

stock CEF_StorageFastMove(playerid, area, slotId)
{
    if(!CEF_StorageIsVisible(playerid))
        return CEFC_Notify(playerid, "Open personal storage before moving items.", "hint");
    if(area == CEF_INV_AREA_STORAGE)
    {
        if(slotId < 0 || slotId >= CEF_STORAGE_SLOTS) return 0;
        new type = gCefPlayerStorage[playerid][slotId][cefStorageType];
        new amount = gCefPlayerStorage[playerid][slotId][cefStorageAmount];
        if(type <= 0 || amount <= 0) return 0;
        CEF_InventoryCompact(playerid);
        CEF_InvSync(playerid);
        new target = -1;
        for(new slot = 6; slot < 48; slot++)
        {
            new idx = gCefInvIdx[playerid][slot];
            if(idx < 0 && gCefInvType[playerid][slot] == 0) { target = slot; break; }
            if(idx >= 0 && IT[playerid][idx][iType] == type) { target = slot; break; }
        }
        if(target < 0 || !CEF_InvCanGive(playerid, type, amount))
            return CEFC_Notify(playerid, "Your inventory has no room for that item.", "error");
        return CEF_StorageTransfer(playerid, CEF_INV_AREA_STORAGE, slotId, CEF_STORAGE_AREA_MAIN, target);
    }
    if(area == CEF_STORAGE_AREA_MAIN)
    {
        if(slotId < 6 || slotId >= 64) return 0;
        CEF_InventoryCompact(playerid);
        CEF_InvSync(playerid);
        new idx = gCefInvIdx[playerid][slotId];
        if(idx < 0 || idx >= MAX_ITEMS) return 0;
        new type = IT[playerid][idx][iType];
        new amount = IT[playerid][idx][iAmount];
        if(type <= 0 || amount <= 0) return 0;
        new target = -1;
        for(new slot = 0; slot < CEF_STORAGE_SLOTS; slot++)
        {
            new storedType = gCefPlayerStorage[playerid][slot][cefStorageType];
            new storedAmount = gCefPlayerStorage[playerid][slot][cefStorageAmount];
            if(storedType == type && storedAmount + amount <= Item[type][itemMaxAmount]) { target = slot; break; }
            if(storedType == 0 && target < 0) target = slot;
        }
        if(target < 0) return CEFC_Notify(playerid, "Personal storage is full.", "error");
        return CEF_StorageTransfer(playerid, CEF_STORAGE_AREA_MAIN, slotId, CEF_INV_AREA_STORAGE, target);
    }
    return CEFC_Notify(playerid, "That item area cannot be moved to storage.", "hint");
}

stock CEF_StorageOpen(playerid)
{
    if(!IsPlayerConnected(playerid) || !PT[playerid][pLogged]) return 1;
    if(!gCefStorageLoaded[playerid])
    {
        gCefStoragePendingOpen[playerid] = 1;
        CEF_StorageLoad(playerid);
        return CEFC_Notify(playerid, "Personal storage is loading; it will open when ready.", "info");
    }
    gCefStorageOpen[playerid] = 1;
    OpenTabCEF(playerid, 2);
    CEF_InvSync(playerid);
    return 1;
}

CMD:storage(playerid, params[])
{
    #pragma unused params
    return CEF_StorageOpen(playerid);
}
