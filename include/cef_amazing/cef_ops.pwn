#if defined _cef_ops_included
    #endinput
#endif
#define _cef_ops_included

new gCefQuickSlotLoadSerial[MAX_PLAYERS];
forward CEF_ItemToSpa(modType);
forward CEF_StorageClose(playerid);
forward OnCefQuickSlotsLoaded(playerid, owner_id, load_serial);























#define CEF_BANK_TRANSFER_FEE_PCT 1
#define CEF_SERVICE_REPAIR_PRICE  15000
#define CEF_SERVICE_WASH_PRICE    2000


#define ATM_KEY_EXIT        1
#define ATM_KEY_WITHDRAW    2
#define ATM_KEY_DEPOSIT     3
#define ATM_KEY_SHOW_FINES  4
#define ATM_KEY_PAY_FINE    5
#define ATM_KEY_PAY_FINES   6
#define ATM_KEY_TOP_UP      7


#define BANK_RPC_GET_PAGE      1
#define BANK_RPC_RESOLVE       2
#define BANK_PAGE_ACCOUNT      1
#define BANK_ACT_DEPOSIT       1
#define BANK_ACT_WITHDRAW      2
#define BANK_ACT_TRANSFER      3
#define BANK_ACT_PAYMENT       4


#define SHOP_KEY_EXIT       0
#define SHOP_KEY_BUY        1
#define SHOP_KEY_ITEM_INFO  2

new gCefBankTransferTarget[MAX_PLAYERS];
new gCefSpawnOpt[MAX_PLAYERS][3];
new gCefSpawnCount[MAX_PLAYERS];

stock CEF_OpsMoneyJson(playerid, dest[], size)
{
    return format(dest, size, "{\"balance\":%d,\"cash\":%d,\"money\":%d,\"bank\":%d,\"id\":%d}",
        PI[playerid][pBank], PI[playerid][pCash], PI[playerid][pCash], PI[playerid][pBank], PI[playerid][pID]);
}




stock CEF_OpsAtmOpen(playerid)
{
    static json[256];
    CEF_MarkPlayerReady(playerid);
    CEFC_AccountStats(playerid);
    format(json, sizeof json,
        "{\"fines\":{\"totalCount\":%d,\"totalAmount\":%d,\"discountedCount\":0,\"discountedAmount\":0}}",
        gCefFineN[playerid], gCefFineSum[playerid]);
    CEF_OpenScreen(playerid, "cef_atm_open", json);
    CEF_Focus(playerid, true);
    return 1;
}

stock CEF_OpsAtmRefresh(playerid)
{
    CEFC_AccountStats(playerid);
    CEFC_HudUpdate(playerid);
    return 1;
}

stock CEF_OpsAtmResponse(playerid, const arguments[])
{
    new key = CEF_EcoFindInt(arguments, "key");
    new amount = CEF_EcoFindInt(arguments, "amount");
    new action[32];


    if(!key)
    {
        CEF_Arg(arguments, 0, action);
        if(!strcmp(action, "withdraw", true)) key = ATM_KEY_WITHDRAW;
        else if(!strcmp(action, "deposit", true)) key = ATM_KEY_DEPOSIT;
        else if(!strcmp(action, "close", true) || !strcmp(action, "exit", true)) key = ATM_KEY_EXIT;
        else if(!strcmp(action, "fines", true) || !strcmp(action, "tickets", true)) key = ATM_KEY_SHOW_FINES;
        else if(!strcmp(action, "payfines", true) || !strcmp(action, "pay", true)) key = ATM_KEY_PAY_FINES;
        if(!amount) amount = CEF_ArgInt(arguments, 1);
    }

    switch(key)
    {
        case ATM_KEY_EXIT:
        {
            CEF_SendEmpty(playerid, "cef_atm_close");
            CEF_Hide(playerid);
            return 1;
        }
        case ATM_KEY_WITHDRAW:
        {
            if(amount <= 0) return CEFC_Notify(playerid, "Укажите сумму больше нуля.", "error");
            if(PI[playerid][pBank] < amount) return CEFC_Notify(playerid, "На счету недостаточно средств.", "error");
            PI[playerid][pBank] -= amount;
            PI[playerid][pCash] += amount;
            GivePlayerMoney(playerid, amount);
            CEF_EcoSaveMoney(playerid);
            CEFC_Notify(playerid, "Снятие выполнено.", "success");
            return CEF_OpsAtmRefresh(playerid);
        }
        case ATM_KEY_DEPOSIT:
        {
            if(amount <= 0) return CEFC_Notify(playerid, "Укажите сумму больше нуля.", "error");
            if(PI[playerid][pCash] < amount) return CEFC_Notify(playerid, "Недостаточно наличных.", "error");
            PI[playerid][pCash] -= amount;
            PI[playerid][pBank] += amount;
            GivePlayerMoney(playerid, -amount);
            CEF_EcoSaveMoney(playerid);
            CEFC_Notify(playerid, "Средства зачислены на счёт.", "success");
            return CEF_OpsAtmRefresh(playerid);
        }
        case ATM_KEY_SHOW_FINES:
            return CEF_FineShow(playerid);
        case ATM_KEY_PAY_FINE, ATM_KEY_PAY_FINES:
            return CEF_FinePay(playerid);
        case ATM_KEY_TOP_UP:
            return CEFC_Notify(playerid, "Пополнение телефона недоступно: системы телефона нет.", "hint");
    }
    return CEF_OpsAtmRefresh(playerid);
}




stock CEF_OpsBankOpen(playerid, bool:atm = false)
{
    if(atm) return CEF_OpsAtmOpen(playerid);
    static json[400];
    CEF_MarkPlayerReady(playerid);
    CEFC_AccountStats(playerid);
    format(json, sizeof json,
        "{\"houseAccount\":null,\"businessAccount\":null,\"familyAccount\":null,\"companyAccount\":null}");
    CEF_OpenScreen(playerid, "cef_bank_open", json);
    CEF_Focus(playerid, true);
    return 1;
}


stock CEF_OpsBankResponse(playerid, const arguments[], bool:atm)
{
    if(atm) return CEF_OpsAtmResponse(playerid, arguments);
    CEF_SendEmpty(playerid, "cef_bank_close");
    CEF_Hide(playerid);
    return 1;
}

stock CEF_OpsFindPlayerById(dbid)
{
    foreach(new i : Player)
    {
        if(PI[i][pID] == dbid) return i;
    }
    return INVALID_PLAYER_ID;
}

stock CEF_OpsBankTransfer(playerid, target, amount)
{
    new fee = amount * CEF_BANK_TRANSFER_FEE_PCT / 100, tid;
    if(target <= 0) return CEFC_Notify(playerid, "Не указан счёт получателя.", "error");
    if(target == PI[playerid][pID]) return CEFC_Notify(playerid, "Нельзя перевести самому себе.", "error");
    if(PI[playerid][pBank] < amount + fee) return CEFC_Notify(playerid, "Недостаточно средств с учётом комиссии.", "error");

    PI[playerid][pBank] -= (amount + fee);
    CEF_EcoSaveMoney(playerid);

    tid = CEF_OpsFindPlayerById(target);
    if(tid != INVALID_PLAYER_ID)
    {
        new msg[144];
        PI[tid][pBank] += amount;
        CEF_EcoSaveMoney(tid);
        format(msg, sizeof msg, "Перевод от %s: %d руб.", PI[playerid][pName], amount);
        CEFC_Notify(tid, msg, "success");
        CEFC_HudUpdate(tid);
    }
    else
    {
        new q[196];
        mysql_format(dbHandle, q, sizeof q, "UPDATE `accounts` SET `bank`=`bank`+%d WHERE `id`=%d", amount, target);
        mysql_tquery(dbHandle, q, "OnCefBankTransferDone", "dd", playerid, amount + fee);
    }
    CEFC_Notify(playerid, "Перевод отправлен.", "success");
    CEFC_AccountStats(playerid);
    CEFC_HudUpdate(playerid);
    return 1;
}

forward OnCefBankTransferDone(playerid, sumWithFee);
public OnCefBankTransferDone(playerid, sumWithFee)
{
    if(!IsPlayerConnected(playerid)) return 0;
    if(cache_affected_rows() <= 0)
    {
        PI[playerid][pBank] += sumWithFee;
        CEF_EcoSaveMoney(playerid);
        CEFC_Notify(playerid, "Счёт получателя не найден, средства и комиссия возвращены.", "error");
        CEFC_AccountStats(playerid);
    }
    return 1;
}


stock CEF_OpsBankRpc(playerid, const arguments[], dest[], size)
{
    new key = CEF_EcoFindInt(arguments, "key");
    new page = CEF_EcoFindInt(arguments, "page");
    new action = CEF_EcoFindInt(arguments, "action");
    new amount = CEF_EcoFindInt(arguments, "amount");
    new target = CEF_EcoFindInt(arguments, "target");

    if(key == BANK_RPC_GET_PAGE)
    {
        if(page == BANK_PAGE_ACCOUNT)
        {
            format(dest, size, "{\"balance\":%d,\"cash\":%d,\"number\":%d,\"owner\":\"%s\",\"transactions\":[]}",
                PI[playerid][pBank], PI[playerid][pCash], PI[playerid][pID], PI[playerid][pName]);
            return 1;
        }

        format(dest, size, "null");
        return 1;
    }

    if(key == BANK_RPC_RESOLVE)
    {
        if(page != BANK_PAGE_ACCOUNT)
        {
            CEFC_Notify(playerid, "Этот раздел банка недоступен в сборке.", "hint");
            format(dest, size, "null");
            return 1;
        }
        if(amount <= 0)
        {
            CEFC_Notify(playerid, "Укажите сумму больше нуля.", "error");
            format(dest, size, "null");
            return 1;
        }
        switch(action)
        {
            case BANK_ACT_DEPOSIT:
            {
                if(PI[playerid][pCash] < amount) CEFC_Notify(playerid, "Недостаточно наличных.", "error");
                else
                {
                    PI[playerid][pCash] -= amount;
                    PI[playerid][pBank] += amount;
                    GivePlayerMoney(playerid, -amount);
                    CEF_EcoSaveMoney(playerid);
                    CEFC_Notify(playerid, "Средства зачислены на счёт.", "success");
                }
            }
            case BANK_ACT_WITHDRAW:
            {
                if(PI[playerid][pBank] < amount) CEFC_Notify(playerid, "На счету недостаточно средств.", "error");
                else
                {
                    PI[playerid][pBank] -= amount;
                    PI[playerid][pCash] += amount;
                    GivePlayerMoney(playerid, amount);
                    CEF_EcoSaveMoney(playerid);
                    CEFC_Notify(playerid, "Снятие выполнено.", "success");
                }
            }
            case BANK_ACT_TRANSFER:
            {

                if(target <= 0) target = gCefBankTransferTarget[playerid];
                if(target <= 0) CEFC_Notify(playerid, "Сначала укажите получателя: /transfer <ID счёта>", "error");
                else CEF_OpsBankTransfer(playerid, target, amount);
                gCefBankTransferTarget[playerid] = 0;
            }
            default: CEFC_Notify(playerid, "Это действие банка недоступно.", "hint");
        }
        CEFC_AccountStats(playerid);
        CEFC_HudUpdate(playerid);
        format(dest, size, "{\"balance\":%d,\"cash\":%d}", PI[playerid][pBank], PI[playerid][pCash]);
        return 1;
    }

    format(dest, size, "null");
    return 1;
}




stock CEF_OpsServiceJson(playerid, dest[], size)
{
    new vid = GetPlayerVehicleID(playerid), Float:hp = 1000.0;
    if(vid) GetVehicleHealth(vid, hp);
    return format(dest, size,
        "{\"vehicleName\":\"%d\",\"type\":0,\"health\":%d,\"money\":%d,\"bank\":%d,\"repairPrice\":%d,\"washPrice\":%d,\"disabledSections\":[]}",
        vid ? GetVehicleModel(vid) : 0, floatround(hp), PI[playerid][pCash], PI[playerid][pBank],
        CEF_SERVICE_REPAIR_PRICE, CEF_SERVICE_WASH_PRICE);
}

stock CEF_OpsServiceOpen(playerid)
{
    static json[400];
    CEF_OpsServiceJson(playerid, json, sizeof json);
    CEF_MarkPlayerReady(playerid);
    CEF_OpenScreen(playerid, "cef_car_service_open", json);
    CEF_Focus(playerid, true);
    return 1;
}

stock CEF_OpsServiceResponse(playerid, const arguments[])
{




    new id = CEF_EcoFindInt(arguments, "id");
    new data = CEF_EcoFindInt(arguments, "data");
    new vid = GetPlayerVehicleID(playerid), price;
    static json[128];

    if(id == 1)
    {
        CEF_SendEmpty(playerid, "cef_car_service_close");
        CEF_Hide(playerid);
        return 1;
    }

    if(id == 3)
    {
        price = (data == 1) ? CEF_SERVICE_REPAIR_PRICE : CEF_SERVICE_WASH_PRICE;
        format(json, sizeof json, "{\"sum\":%d,\"text\":\"Оплатить\"}", price);
        CEF_Send(playerid, "cef_car_service_pay_button_set", json);
        return 1;
    }
    if(id == 4) return 1;

    if(!vid) return CEFC_Notify(playerid, "Нужно находиться в транспорте.", "error");

    switch(id)
    {
        case 2, 5, 6:
        {
            price = (id == 6) ? CEF_SERVICE_REPAIR_PRICE : (CEF_SERVICE_REPAIR_PRICE / 2);
            if(!CEF_EcoPay(playerid, price)) return CEFC_Notify(playerid, "Недостаточно средств.", "error");
            RepairVehicle(vid);
            SetVehicleHealth(vid, 1000.0);
            CEFC_SpeedometerRefresh(playerid);
            CEFC_Notify(playerid, "Транспорт отремонтирован.", "success");
            CEFC_HudUpdate(playerid);
            return CEF_OpsServiceOpen(playerid);
        }
        case 36:
        {
            CEFC_Notify(playerid, "Свет в салоне переключен.", "info");
            return 1;
        }
        case 37: return ShowPlayerInventory(playerid);
        case 9:
        {
            new color = data % 256;
            ChangeVehicleColor(vid, color, color);
            CEFC_Notify(playerid, "Цвет изменён.", "success");
            return 1;
        }
    }
    return CEFC_Notify(playerid, "Этот раздел автосервиса пока недоступен.", "hint");
}






new gNeedEat[MAX_PLAYERS];
new gNeedWater[MAX_PLAYERS];
new gNeedWC[MAX_PLAYERS];
new gNeedHygiene[MAX_PLAYERS];
new gNeedPsycho[MAX_PLAYERS];

stock CEF_OpsInventoryIndicators(playerid)
{
    static json[280];
    format(json, sizeof json,
        "[{\"type\":0,\"value\":%d},{\"type\":1,\"value\":%d},{\"type\":2,\"value\":%d},{\"type\":3,\"value\":%d},{\"type\":4,\"value\":%d}]",
        gNeedHygiene[playerid], gNeedWC[playerid], gNeedEat[playerid],
        gNeedWater[playerid], gNeedPsycho[playerid]);
    return CEF_Send(playerid, "cef_inv_update_indcators", json);
}







#define INV_ACT_INFO        0
#define INV_ACT_USE         1
#define INV_ACT_THROW_AWAY  6

forward CEF_InventoryAfterAction(playerid);

new gCefInvType[MAX_PLAYERS][64];
new gCefInvHover[MAX_PLAYERS];
new gCefInvIdx[MAX_PLAYERS][64];

forward CEF_InvRememberIdx(playerid, slot, idx);
public CEF_InvRememberIdx(playerid, slot, idx)
{
    if(slot >= 0 && slot < 64) gCefInvIdx[playerid][slot] = idx;
    return 1;
}

stock CEF_InvRemember(playerid, slot, type)
{
    if(slot >= 0 && slot < 64) gCefInvType[playerid][slot] = type;
    return 1;
}

stock CEF_InvRememberClear(playerid)
{
    for(new s = 0; s < 64; s++) { gCefInvType[playerid][s] = 0; gCefInvIdx[playerid][s] = -1; }
    return 1;
}

stock CEF_OpsInvFindSlotByType(playerid, itemType)
{
    for(new i = 0; i < MAX_ITEMS; i++)
    {
        if(IT[playerid][i][iType] == itemType && IT[playerid][i][iAmount] > 0) return i;
    }
    return -1;
}

stock CEF_OpsInvConsume(playerid, itemType, slot = -1)
{
    if(slot < 0) return RemoveItem(playerid, itemType, 1);
    if(slot >= MAX_ITEMS || IT[playerid][slot][iType] != itemType || IT[playerid][slot][iAmount] <= 0) return 0;
    IT[playerid][slot][iAmount]--;
    if(IT[playerid][slot][iAmount] <= 0)
    {
        IT[playerid][slot][iID] = 0;
        IT[playerid][slot][iType] = 0;
        IT[playerid][slot][iAmount] = 0;
    }
    CEF_InventoryCountSlots(playerid);
    return 1;
}

stock CEF_OpsInvUse(playerid, itemType, slot = -1)
{
    if(slot >= 0 && (slot >= MAX_ITEMS || IT[playerid][slot][iType] != itemType || IT[playerid][slot][iAmount] <= 0))
        return CEFC_Notify(playerid, "Предмет уже недоступен.", "error");
    new Float:hp, vid = GetPlayerVehicleID(playerid), msg[128];
    switch(itemType)
    {
        case CEF_ITEM_MEDKIT:
        {
            GetPlayerHealth(playerid, hp);
            if(hp >= 99.0) return CEFC_Notify(playerid, "Здоровье и так полное.", "hint");
            SetPlayerHealth(playerid, 100.0);
            if(!CEF_OpsInvConsume(playerid, itemType, slot)) return CEFC_Notify(playerid, "Предмет уже недоступен.", "error");
            CEFC_Notify(playerid, "Аптечка использована.", "success");
        }
        case CEF_ITEM_CANISTER, CEF_ITEM_GAS:
        {
            if(!vid) return CEFC_Notify(playerid, "Нужно находиться в транспорте.", "error");
            if(CI[vid][Fuel] >= CEF_GAS_MAX) return CEFC_Notify(playerid, "Бак уже полон.", "hint");
            CI[vid][Fuel] += 20;
            if(CI[vid][Fuel] > CEF_GAS_MAX) CI[vid][Fuel] = CEF_GAS_MAX;
            if(!CEF_OpsInvConsume(playerid, itemType, slot)) return CEFC_Notify(playerid, "Предмет уже недоступен.", "error");
            CEFC_SpeedometerRefresh(playerid);
            format(msg, sizeof msg, "Канистра вылита в бак: топливо %d.", CI[vid][Fuel]);
            CEFC_Notify(playerid, msg, "success");
        }
        case CEF_ITEM_REPAIR:
        {
            if(!vid) return CEFC_Notify(playerid, "Нужно находиться в транспорте.", "error");
            RepairVehicle(vid);
            SetVehicleHealth(vid, 1000.0);
            if(!CEF_OpsInvConsume(playerid, itemType, slot)) return CEFC_Notify(playerid, "Предмет уже недоступен.", "error");
            CEFC_SpeedometerRefresh(playerid);
            CEFC_Notify(playerid, "Ремкомплект использован.", "success");
        }
        case CEF_ITEM_FOOD:
        {
            CEF_NeedsFeed(playerid, 40, 0);
            if(!CEF_OpsInvConsume(playerid, itemType, slot)) return CEFC_Notify(playerid, "Предмет уже недоступен.", "error");
            CEF_OpsInventoryIndicators(playerid);
            CEFC_Notify(playerid, "Еда съедена.", "success");
        }
        case CEF_ITEM_DRINK:
        {
            CEF_NeedsFeed(playerid, 0, 40);
            if(!CEF_OpsInvConsume(playerid, itemType, slot)) return CEFC_Notify(playerid, "Предмет уже недоступен.", "error");
            CEF_OpsInventoryIndicators(playerid);
            CEFC_Notify(playerid, "Вода выпита.", "success");
        }
        case 12:
        {
            SetPlayerArmour(playerid, 100.0);
            if(!CEF_OpsInvConsume(playerid, itemType, slot)) return CEFC_Notify(playerid, "Предмет уже недоступен.", "error");
            CEFC_Notify(playerid, "Броня надета.", "success");
        }
        case 13:
        {
            if(slot < 0 && CEF_OpsInvFindSlotByType(playerid, itemType) < 0)
                return CEFC_Notify(playerid, "You do not own a mask item.", "error");
            if(PI[playerid][pHasMask])
                return CEFC_Notify(playerid, "A mask is already equipped.", "hint");
            PI[playerid][pHasMask] = 1;
            if(!CEF_OpsInvConsume(playerid, itemType, slot)) return CEFC_Notify(playerid, "Предмет уже недоступен.", "error");
            SaveAccount(playerid);
            CEFC_Notify(playerid, "Mask equipped.", "success");
        }
        default:
        {
            if(CEF_CaseIndex(itemType) >= 0)
                return CEF_CaseOpenWindow(playerid, itemType);
            if(itemType == 533)
            {
                CEF_ShopGiveWeapon(playerid, 533);
                CEFC_Notify(playerid, "АС Вал в руках.", "success");
                return 1;
            }
            if(CEF_SkinWear(playerid, itemType))
                return 1;
            return CEFC_Notify(playerid, "Этот предмет нельзя использовать.", "hint");
        }
    }
    SavePlayerInventory(playerid);
    if(!CEF_InventoryAfterAction(playerid)) ShowPlayerInventory(playerid);
    CEF_OpsQuickSlots(playerid);
    CEFC_HudUpdate(playerid);
    return 1;
}

stock CEF_OpsInvResponse(playerid, const arguments[])
{
    printf("[CEF-INV] raw %d %s", playerid, arguments);
    new action = CEF_EcoFindInt(arguments, "action");
    new itemType = CEF_EcoFindInt(arguments, "type");
    new slotId = CEF_EcoFindInt(arguments, "slotId");
    new caseType = CEF_EcoFindInt(arguments, "caseType");
    new itemId = CEF_EcoFindInt(arguments, "itemId");
    new act[32], msg[128];
    if(!itemType) itemType = CEF_EcoFindInt(arguments, "itemType");
    if(!itemType) itemType = CEF_EcoFindInt(arguments, "id");
    if(!slotId) slotId = CEF_EcoFindInt(arguments, "slot");
    if(!caseType) caseType = CEF_EcoFindInt(arguments, "case");

    CEF_Arg(arguments, 0, act);
    if(act[0] && !strcmp(act, "close", true))
    {
        CEF_StorageClose(playerid);
        gCefMenuOpen[playerid] = false;
        CEFC_ChatSetVisible(playerid, true);
        CEF_SendEmpty(playerid, "menu_close");
        CEF_Hide(playerid);
        CEFC_OnMenuClosed(playerid);
        return 1;
    }

    if(!itemType) itemType = itemId;
    if(!itemType) itemType = caseType;
    if(!itemType && slotId >= 0 && slotId < 64) itemType = gCefInvType[playerid][slotId];
    if(!itemType)
    {
        new dataInt = CEF_EcoFindInt(arguments, "data");
        if(dataInt >= 6 && dataInt < 64) { slotId = dataInt; itemType = gCefInvType[playerid][slotId]; }
        else if(dataInt > 0) itemType = dataInt;
    }
    if(!itemType && slotId >= 0 && slotId < 64) itemType = gCefInvType[playerid][slotId];
    if(itemType > 0 && CEF_CaseIndex(itemType) < 0 && CEF_ItemFromSpa(itemType) > 0)
        itemType = CEF_ItemFromSpa(itemType);
    if(itemType > 0) gCefInvHover[playerid] = itemType;
    printf("[CEF-INV] %d act=%d type=%d slot=%d args=%s", playerid, action, itemType, slotId, arguments);
    if(itemType <= 0) return 1;

    if(action == INV_ACT_THROW_AWAY)
    {
        if(CEF_CaseIndex(itemType) >= 0)
        {
            CEF_CaseTake(playerid, itemType, 1);
            CEF_InvSync(playerid);
            return CEFC_Notify(playerid, "Кейс выброшен.", "info");
        }
        if(CEF_OpsInvFindSlotByType(playerid, itemType) < 0)
            return CEFC_Notify(playerid, "Предмета нет в инвентаре.", "error");
        RemoveItem(playerid, itemType, 1);
        SavePlayerInventory(playerid);
        CEF_InvSync(playerid);
        return CEFC_Notify(playerid, "Предмет выброшен.", "info");
    }



    if(action == INV_ACT_INFO || action == 5 || action == 8 || action == 10)
        return 1;

    if(CEF_CaseIndex(itemType) >= 0)
        return CEF_CaseOpenWindow(playerid, itemType);

    if(action == INV_ACT_USE || action == 2 || action == 3 || action == 4)
    {
        new inventoryIdx = (slotId >= 0 && slotId < 64) ? gCefInvIdx[playerid][slotId] : -1;
        switch(itemType)
        {
            case CEF_ITEM_MEDKIT, CEF_ITEM_CANISTER, CEF_ITEM_GAS, CEF_ITEM_REPAIR, CEF_ITEM_FOOD, CEF_ITEM_DRINK:
                return CEF_OpsInvUse(playerid, itemType, inventoryIdx);
        }
        if(itemType >= 1 && itemType <= 311 && itemType != CEF_ITEM_GAS && CEF_SkinHas(playerid, itemType))
            return CEF_SkinWear(playerid, itemType);
        return CEFC_Notify(playerid, "Этот предмет нельзя открыть.", "hint");
    }
    return 1;
}








forward CEF_ForceCamBehind(playerid);
public CEF_ForceCamBehind(playerid)
{
    new Float:x, Float:y, Float:z, Float:a;
    if(!IsPlayerConnected(playerid) || !PT[playerid][pLogged]) return 0;
    if(gCefMenuOpen[playerid] || gCefCamOn[playerid]) return 1;
    TogglePlayerSpectating(playerid, 0);
    TogglePlayerControllable(playerid, 1);
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);
    if((x*x + y*y) < 1.0)
    {
        x = 1933.0570;
        y = 2140.2629;
        z = 16.0413;
        a = 90.0;
        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, 0);
        SetPlayerPos(playerid, x, y, z);
        SetPlayerFacingAngle(playerid, a);
    }
    SetPlayerCameraPos(playerid, x - 3.0 * floatsin(-a, degrees), y - 3.0 * floatcos(-a, degrees), z + 1.2);
    SetPlayerCameraLookAt(playerid, x, y, z + 0.6, CAMERA_CUT);
    SetCameraBehindPlayer(playerid);
    if(!gCefAuthActive[playerid] && !gCefMenuOpen[playerid]) CEF_Focus(playerid, false);
    OFFHud_Int(playerid);
    return 1;
}

forward CEF_SpawnEnsure(playerid);
public CEF_SpawnEnsure(playerid)
{
    if(!IsPlayerConnected(playerid) || !PT[playerid][pLogged]) return 0;
    if(gCefMenuOpen[playerid]) return 1;
    printf("[CEF-SPAWN] %d: ensure state=%d", playerid, GetPlayerState(playerid));
    if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING || GetPlayerState(playerid) == PLAYER_STATE_NONE || GetPlayerState(playerid) == PLAYER_STATE_WASTED)
        SpawnPlayerEx(playerid);
    CEF_ForceCamBehind(playerid);
    CEFC_HideSampHud(playerid);
    if(!gCefAuthActive[playerid] && !gCefMenuOpen[playerid])
        TogglePlayerControllable(playerid, 1);
    return 1;
}

stock CEF_AfterLogin(playerid)
{
    gCefAuthActive[playerid] = false;
    TogglePlayerSpectating(playerid, 0);
    TogglePlayerControllable(playerid, 1);
    SetPlayerHUDActive(playerid, true);
    cef_always_listen_keys(playerid, MAIN_BROWSER, true);
    SpawnPlayerEx(playerid);
    SetTimerEx("CEF_ForceCamBehind", 80, false, "i", playerid);
    SetTimerEx("CEF_ForceCamBehind", 400, false, "i", playerid);
    SetTimerEx("CEF_ForceCamBehind", 1000, false, "i", playerid);
    return CEF_OpsSpawnSelect(playerid);
}

CMD:spawnme(playerid, params[])
{
    #pragma unused params
    CEF_AuthClose(playerid);
    SpawnPlayerEx(playerid);
    CEF_ForceCamBehind(playerid);
    SendClientMessage(playerid, 0x54B367FF, "Принудительный спавн выполнен.");
    return 1;
}


forward CEF_SpawnFallback(playerid);
public CEF_SpawnFallback(playerid)
{
    if(!IsPlayerConnected(playerid) || !PT[playerid][pLogged]) return 0;
    if(!gCefAuthActive[playerid]) return 1;
    gCefAuthActive[playerid] = false;
    CEF_AuthClose(playerid);
    TogglePlayerControllable(playerid, 1);
    CEF_ForceCamBehind(playerid);
    return 1;
}

stock CEF_OpsSpawnSelect(playerid)
{
    static list[256], title[64], b1[32], b2[32];
    new opts = 1;
    gCefSpawnOpt[playerid][0] = 0;
    list = "Город (вокзал)";
    if(GetPlayerHouseID(playerid) > 0)
    {
        strcat(list, "\nДом");
        gCefSpawnOpt[playerid][opts++] = 1;
    }
    if(PI[playerid][pFraction] > 0)
    {
        strcat(list, "\nОрганизация");
        gCefSpawnOpt[playerid][opts++] = 2;
    }
    gCefSpawnCount[playerid] = opts;
    if(CEFC_Ready(playerid))
    {
        SetTimerEx("CEF_SpawnFallback", 20000, false, "i", playerid);
        return CEF_AuthOpenSpawnPlaces(playerid);
    }
    if(opts == 1) return 1;
    title = "Выбор места появления";
    b1 = "Выбрать";
    b2 = "Город";
    ShowPlayerDialogEx(playerid, DIALOG_CEF_SPAWN, DIALOG_STYLE_LIST, title, list, b1, b2);
    return 1;
}

stock CEF_OpsSpawnResponse(playerid, response, listitem)
{
    new place = 0;
    if(response && listitem >= 0 && listitem < gCefSpawnCount[playerid])
        place = gCefSpawnOpt[playerid][listitem];
    PI[playerid][pSpawn] = place;
    new q[128];
    mysql_format(dbHandle, q, sizeof q, "UPDATE `accounts` SET `spawn`=%d WHERE `id`=%d", place, PI[playerid][pID]);
    mysql_tquery(dbHandle, q);
    SpawnPlayerEx(playerid);
    return 1;
}

CMD:spawnplace(playerid, params[])
{
    #pragma unused params
    return CEF_OpsSpawnSelect(playerid);
}






stock CEF_OpsEscOpen(playerid)
{
    static json[256];
    format(json, sizeof json,
        "{\"adminLevel\":%d,\"server\":0,\"nickname\":\"%s\",\"playerId\":%d}",
        PI[playerid][pAdmin], PI[playerid][pName], PI[playerid][pID]);
    CEF_MarkPlayerReady(playerid);
    CEF_Send(playerid, "cef_esc_show", json);
    CEF_Focus(playerid, true);
    return 1;
}

stock CEF_OpsEscResponse(playerid, const arguments[])
{
    new action = CEF_EcoFindInt(arguments, "action");
    switch(action)
    {
        case 0:
        {
            CEF_SendEmpty(playerid, "cef_esc_hide");
            CEF_Focus(playerid, false);
        }
        case 1:
        {
            CEF_SendEmpty(playerid, "cef_esc_hide");
            CEFC_Notify(playerid, "Переподключение: выйдите и зайдите заново.", "hint");
        }
        case 2:
        {
            CEF_SendEmpty(playerid, "cef_esc_hide");
            Kick(playerid);
        }
        case 5:
            CEFC_Notify(playerid, "Смена сервера недоступна: сервер один.", "hint");
        case 6:
            CEFC_Notify(playerid, "Перезапуск клиента выполняется вручную.", "hint");
        default:
            return 1;
    }
    return 1;
}





new PlayerText:gCefBagTD[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...};

stock CEF_OpsBagShow(playerid, bool:on)
{
    if(on)
    {
        if(gCefBagTD[playerid] != PlayerText:INVALID_TEXT_DRAW) return 1;
        new tdText[] = "_";
        gCefBagTD[playerid] = CreatePlayerTextDraw(playerid, -10.0, -5.0, tdText);
        PlayerTextDrawUseBox(playerid, gCefBagTD[playerid], 1);
        PlayerTextDrawBoxColor(playerid, gCefBagTD[playerid], 0x000000FF);
        PlayerTextDrawTextSize(playerid, gCefBagTD[playerid], 700.0, 0.0);
        PlayerTextDrawLetterSize(playerid, gCefBagTD[playerid], 1.0, 50.0);
        PlayerTextDrawShow(playerid, gCefBagTD[playerid]);
        CEFC_Notify(playerid, "На вашу голову надели мешок.", "error");
    }
    else
    {
        if(gCefBagTD[playerid] == PlayerText:INVALID_TEXT_DRAW) return 1;
        PlayerTextDrawDestroy(playerid, gCefBagTD[playerid]);
        gCefBagTD[playerid] = PlayerText:INVALID_TEXT_DRAW;
        CEFC_Notify(playerid, "Мешок сняли.", "success");
    }
    return 1;
}

CMD:esc(playerid, params[])
{
    #pragma unused params
    return CEF_OpsEscOpen(playerid);
}










#define CEF_SERVER_ID         0
#define AUTH_FORM_SIGN_IN     1
#define AUTH_FORM_SIGN_UP     4
#define AUTH_FORM_TERMS       6
#define AUTH_FORM_CHAR        7
#define AUTH_FORM_SPAWN       8

forward CEF_AuthWaitReady(playerid, auth_session);
forward CEF_AuthOpenSignIn(playerid);
forward CEF_AuthOpenSignUp(playerid);
forward RegisterPlayer(playerid);

public CEF_AuthWaitReady(playerid, auth_session)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid)) return 0;
    if(PT[playerid][pAuthSession] != auth_session || PT[playerid][pLogged] || !gCefAuthActive[playerid]) return 0;
    if(PT[playerid][pCefAuthForm] != AUTH_FORM_SIGN_IN && PT[playerid][pCefAuthForm] != AUTH_FORM_SIGN_UP) return 0;
    if(CEFC_Ready(playerid))
    {
        if(PT[playerid][pCefAuthForm] == AUTH_FORM_SIGN_UP) return CEF_AuthOpenSignUp(playerid);
        return CEF_AuthOpenSignIn(playerid);
    }
    PT[playerid][pCefAuthRetries]++;
    if(PT[playerid][pCefAuthRetries] >= 40)
    {
        SendClientMessage(playerid, COLOR_RED, "Не удалось загрузить CEF для входа. Подключитесь ещё раз.");
        Kick(playerid);
        return 1;
    }
    SetTimerEx("CEF_AuthWaitReady", 1000, false, "ii", playerid, auth_session);
    return 1;
}

stock CEF_AuthOpenSignUp(playerid)
{
    static json[256];
    printf("[CEF-AUTH] %d open sign-up CEF", playerid);
    gCefAuthActive[playerid] = true;
    PT[playerid][pCefAuthForm] = AUTH_FORM_SIGN_UP;
    PT[playerid][pCefAuthRetries] = 0;
    PT[playerid][pAuthLoginPending] = false;
    format(json, sizeof json, "{\"form\":%d,\"data\":{\"displayNameField\":false}}", AUTH_FORM_SIGN_UP);
    CEF_MarkPlayerReady(playerid);
    CEF_Show(playerid, false);
    CEF_Send(playerid, "cef_auth_open_form", json);
    CEF_Focus(playerid, true);
    return 1;
}

stock CEF_AuthOpenTerms(playerid)
{
    static json[96];
    gCefAuthActive[playerid] = true;
    PT[playerid][pCefAuthForm] = AUTH_FORM_TERMS;
    format(json, sizeof json, "{\"form\":%d,\"data\":{}}", AUTH_FORM_TERMS);
    CEF_Send(playerid, "cef_auth_open_form", json);
    CEF_Focus(playerid, true);
    return 1;
}

stock CEF_AuthOpenCharacter(playerid)
{
    static json[256], nick[48];
    new gender = (PI[playerid][pSex] == 1) ? 0 : 1;
    PI[playerid][pSkin] = (gender == 0) ? 14 : 12;
    PT[playerid][pIsPlayerChoosingRegisterSkin] = true;
    SetPlayerSkin(playerid, PI[playerid][pSkin]);
    CEF_JsonEscape(PI[playerid][pName], nick, sizeof nick);
    format(json, sizeof json, "{\"form\":%d,\"data\":{\"nickname\":\"%s\"}}", AUTH_FORM_CHAR, nick);
    gCefAuthActive[playerid] = true;
    PT[playerid][pCefAuthForm] = AUTH_FORM_CHAR;
    CEF_Show(playerid, false);
    CEF_Send(playerid, "cef_auth_open_form", json);
    CEF_Focus(playerid, true);
    return 1;
}

stock CEF_RegisterStartCharacterCEF(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) || PT[playerid][pLogged]) return 0;
    TogglePlayerSpectating(playerid, false);
    SetPlayerPos(playerid, -890.1702, -382.2885, 1103.6927);
    SetPlayerFacingAngle(playerid, 272.4342);
    SetPlayerVirtualWorld(playerid, playerid + 1000);
    SetPlayerCameraPos(playerid, -887.808959, -382.165618, 1104.483276);
    SetPlayerCameraLookAt(playerid, -892.762634, -382.178314, 1103.804443);
    TogglePlayerControllable(playerid, 0);
    return CEF_AuthOpenCharacter(playerid);
}

stock CEF_AuthOpenSignIn(playerid)
{
    static json[256], nick[48];
    gCefAuthActive[playerid] = true;
    PT[playerid][pCefAuthForm] = AUTH_FORM_SIGN_IN;
    PT[playerid][pCefAuthRetries] = 0;
    PT[playerid][pAuthLoginPending] = false;
    CEF_JsonEscape(PI[playerid][pName], nick, sizeof nick);
    format(json, sizeof json, "{\"form\":%d,\"data\":{\"nickname\":\"%s\",\"serverId\":%d,\"attempts\":%d}}",
        AUTH_FORM_SIGN_IN, nick, CEF_SERVER_ID, PT[playerid][pLoginAttempts]);
    CEF_MarkPlayerReady(playerid);
    CEF_Show(playerid, false);
    CEF_Send(playerid, "cef_auth_open_form", json);
    CEF_Focus(playerid, true);
    return 1;
}

stock CEF_AuthOpenSpawnPlaces(playerid)
{
    static json[512], part[160];
    new first = 1;
    gCefSpawnCount[playerid] = 0;
    json = "{\"form\":8,\"data\":{\"places\":[";
    format(part, sizeof part, "{\"id\":0,\"title\":\"Город (вокзал)\",\"icon\":\"map_marker_fill\"}");
    strcat(json, part);
    gCefSpawnOpt[playerid][gCefSpawnCount[playerid]++] = 0;
    first = 0;
    if(GetPlayerHouseID(playerid) > 0)
    {
        format(part, sizeof part, "%s{\"id\":1,\"title\":\"Дом\",\"icon\":\"house_fill\"}", first ? ("") : (","));
        strcat(json, part);
        gCefSpawnOpt[playerid][gCefSpawnCount[playerid]++] = 1;
    }
    if(PI[playerid][pFraction] > 0)
    {
        format(part, sizeof part, ",{\"id\":2,\"title\":\"Организация\",\"icon\":\"fraction\"}");
        strcat(json, part);
        gCefSpawnOpt[playerid][gCefSpawnCount[playerid]++] = 2;
    }
    strcat(json, "]}}");
    gCefAuthActive[playerid] = true;
    PT[playerid][pCefAuthForm] = AUTH_FORM_SPAWN;
    printf("[CEF-SPAWN] %d: показано окно выбора места (вариантов %d)", playerid, gCefSpawnCount[playerid]);
    CEF_Show(playerid, false);
    CEF_Send(playerid, "cef_auth_open_form", json);
    CEF_Focus(playerid, true);
    return 1;
}

stock CEF_AuthClose(playerid)
{
    gCefAuthActive[playerid] = false;
    PT[playerid][pCefAuthForm] = 0;
    PT[playerid][pCefAuthRetries] = 0;
    PT[playerid][pAuthLoginPending] = false;
    CEF_SendEmpty(playerid, "cef_auth_close");
    CEF_Focus(playerid, false);
    CEF_Hide(playerid);
    return 1;
}

stock CEF_AuthRpc(playerid, const arguments[], dest[], size)
{
    new key = CEF_EcoFindInt(arguments, "key");
    static pass[64], q[256], regPass[64], promo[64], nickname[64];
    format(dest, size, "null");
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) || !gCefAuthActive[playerid]) return 0;

    switch(key)
    {
        case 1:
        {
            if(!PT[playerid][pLogged]) Kick(playerid);
            return 1;
        }
        case 2:
        {
            if(PT[playerid][pLogged] || PT[playerid][pCefAuthForm] != AUTH_FORM_SIGN_IN || PT[playerid][pAuthLoginPending]) return 1;
            CEF_JsonStr(arguments, "data", pass, sizeof pass);
            if(strlen(pass) < 1 || strlen(pass) >= sizeof pass)
            {
                format(dest, size, "{\"error\":{\"title\":\"Error\",\"message\":\"Invalid password.\"}}");
                return 1;
            }
            PT[playerid][pAuthLoginPending] = true;
            mysql_format(dbHandle, q, sizeof q, "SELECT * FROM `accounts` WHERE `name` = '%e' AND `password` = md5('%e') LIMIT 1", PI[playerid][pName], pass);
            mysql_tquery(dbHandle, q, "CheckAccountLogin", "ii", playerid, PT[playerid][pAuthSession]);
            pass[0] = EOS;
            return 1;
        }
        case 4:
        {
            if(PT[playerid][pCefAuthForm] != AUTH_FORM_SIGN_UP || PT[playerid][pRegistrationPending]) return 1;
            CEF_JsonStr(arguments, "password", regPass, sizeof regPass);
            CEF_JsonStr(arguments, "nickname", nickname, sizeof nickname);
            if(strlen(regPass) < 5 || strlen(regPass) > 16)
            {
                format(dest, size, "{\"error\":{\"title\":\"Error\",\"message\":\"Password must contain 5-16 characters.\"}}");
                return 1;
            }
            if(strlen(nickname) > 0 && strcmp(nickname, PI[playerid][pName], false) != 0)
            {
                format(dest, size, "{\"error\":{\"title\":\"Error\",\"message\":\"Use your game nickname.\"}}");
                return 1;
            }
            format(PI[playerid][pPassword], 64, "%s", regPass);
            regPass[0] = EOS;
            return CEF_AuthOpenTerms(playerid);
        }
        case 5:
        {
            if(PT[playerid][pCefAuthForm] != 5) return 1;
            CEF_JsonStr(arguments, "data", promo, sizeof promo);
            format(PI[playerid][pPromocode], 32, "%s", promo);
            PI[playerid][pPromocodeId] = 0;
            return CEF_AuthOpenTerms(playerid);
        }
        case 6:
        {
            if(PT[playerid][pCefAuthForm] != AUTH_FORM_TERMS) return 1;
            return CEF_RegisterStartCharacterCEF(playerid);
        }
        case 7:
        {
            if(PT[playerid][pCefAuthForm] != AUTH_FORM_CHAR || !PT[playerid][pIsPlayerChoosingRegisterSkin]) return 1;
            new skinId = CEF_EcoFindInt(arguments, "skinId");
            new gender = CEF_EcoFindInt(arguments, "gender");
            if((gender == 0 && skinId != 14 && skinId != 20 && skinId != 21 && skinId != 22 && skinId != 24 && skinId != 25) || (gender == 1 && skinId != 12 && skinId != 13 && skinId != 226 && skinId != 56)) return 1;
            PI[playerid][pSex] = (gender == 0) ? 1 : 0;
            PI[playerid][pSkin] = skinId;
            SetPlayerSkin(playerid, skinId);
            return 1;
        }
        case 8:
        {
            if(PT[playerid][pCefAuthForm] != AUTH_FORM_CHAR || !PT[playerid][pIsPlayerChoosingRegisterSkin]) return 1;
            new skinId = CEF_EcoFindInt(arguments, "skinId");
            new gender = CEF_EcoFindInt(arguments, "gender");
            if((gender == 0 && skinId != 14 && skinId != 20 && skinId != 21 && skinId != 22 && skinId != 24 && skinId != 25) || (gender == 1 && skinId != 12 && skinId != 13 && skinId != 226 && skinId != 56))
            {
                format(dest, size, "{\"error\":{\"title\":\"Error\",\"message\":\"Invalid character.\"}}");
                return 1;
            }
            PI[playerid][pSex] = (gender == 0) ? 1 : 0;
            PI[playerid][pSkin] = skinId;
            return RegisterPlayer(playerid);
        }
        case 9:
        {
            if(!PT[playerid][pLogged] || PT[playerid][pCefAuthForm] != AUTH_FORM_SPAWN) return 1;
            new place = CEF_EcoFindInt(arguments, "data"), allowed = 0;
            for(new i = 0; i < gCefSpawnCount[playerid]; i++)
                if(gCefSpawnOpt[playerid][i] == place) { allowed = 1; break; }
            if(!allowed) return CEFC_Notify(playerid, "Invalid spawn.", "error");
            PI[playerid][pSpawn] = place;
            mysql_format(dbHandle, q, sizeof q, "UPDATE `accounts` SET `spawn`=%d WHERE `id`=%d", place, PI[playerid][pID]);
            mysql_tquery(dbHandle, q);
            CEF_AuthClose(playerid);
            TogglePlayerSpectating(playerid, false);
            SpawnPlayerEx(playerid);
            SetTimerEx("CEF_SpawnEnsure", 3000, false, "i", playerid);
            return 1;
        }
        case 10:
        {
            new nick[48], escNick[96];
            CEF_JsonEscape(PI[playerid][pName], escNick, sizeof escNick);
            format(nick, sizeof nick, "{\"nickname\":\"%s\"}", escNick);
            format(dest, size, "%s", nick);
            return 1;
        }
        case 11:
        {
            if(PT[playerid][pLogged] || PT[playerid][pCefAuthForm] != AUTH_FORM_SIGN_IN) return 1;
            printf("[CEF-AUTH] %d registration requested from sign-in", playerid);
            return CEF_AuthOpenSignUp(playerid);
        }
    }
    return 1;
}

stock CEF_AuthSignIn(playerid, style, const title[], const text[], const b1[], const b2[])
{
    #pragma unused style
    #pragma unused title
    #pragma unused text
    #pragma unused b1
    #pragma unused b2
    if(!CEFC_Ready(playerid))
    {
        gCefAuthActive[playerid] = true;
        PT[playerid][pCefAuthForm] = AUTH_FORM_SIGN_IN;
        PT[playerid][pCefAuthRetries] = 0;
        SetTimerEx("CEF_AuthWaitReady", 1000, false, "ii", playerid, PT[playerid][pAuthSession]);
        return 1;
    }
    return CEF_AuthOpenSignIn(playerid);
}

stock CEF_AuthSignUp(playerid, style, title[], text[], b1[], b2[])
{
    #pragma unused style
    #pragma unused title
    #pragma unused text
    #pragma unused b1
    #pragma unused b2
    gCefAuthActive[playerid] = true;
    PT[playerid][pCefAuthForm] = AUTH_FORM_SIGN_UP;
    if(!CEFC_Ready(playerid))
    {
        SetTimerEx("CEF_AuthWaitReady", 300, false, "ii", playerid, PT[playerid][pAuthSession]);
        return 1;
    }
    return CEF_AuthOpenSignUp(playerid);
}


stock CEF_OpsStorageCategory(playerid)
{
    new frac = PI[playerid][pFraction];
    if(frac <= 0) return 0;
    switch(frac)
    {
        case 1: return 1;
        case 2: return 2;
        case 3: return 3;
        case 4: return 4;
        case 5: return 5;
        case 6: return 5;
        case 13: return 13;
    }
    return frac;
}

stock CEF_OpsStorageOpen(playerid)
{
    new cat = CEF_OpsStorageCategory(playerid);
    static json[64];
    if(!cat) return CEFC_Notify(playerid, "У вашей организации нет склада.", "hint");
    CEF_MarkPlayerReady(playerid);
    format(json, sizeof json, "%d", cat);
    CEF_Send(playerid, "cef_weapon_storage_show", json);
    CEF_Focus(playerid, true);
    return 1;
}

stock CEF_OpsStorageResponse(playerid, const arguments[])
{

    if(strfind(arguments, "-1", true) != -1 && strfind(arguments, "category", true) != -1)
    {
        CEF_SendEmpty(playerid, "cef_weapon_storage_hide");
        CEF_Hide(playerid);
        return 1;
    }
    new item = CEF_EcoFindInt(arguments, "item");
    if(!item) item = CEF_EcoFindInt(arguments, "id");
    if(!item) item = CEF_ArgInt(arguments, 0);
    if(!CEF_OpsStorageCategory(playerid)) return CEFC_Notify(playerid, "Нет доступа к складу.", "error");
    if(!PT[playerid][pDuty]) return CEFC_Notify(playerid, "Сначала начните рабочий день.", "error");

    switch(item)
    {
        case 1:  GivePlayerWeapon(playerid, 22, 100);
        case 2:  GivePlayerWeapon(playerid, 22, 100);
        case 3:  GivePlayerWeapon(playerid, 23, 100);
        case 4:  GivePlayerWeapon(playerid, 30, 200);
        case 5:  GivePlayerWeapon(playerid, 31, 200);
        case 6:  GivePlayerWeapon(playerid, 34, 50);
        case 7:  GivePlayerWeapon(playerid, 25, 60);
        case 8:  GivePlayerWeapon(playerid, 29, 150);
        case 9:  GivePlayerWeapon(playerid, 34, 40);
        case 10: GivePlayerWeapon(playerid, 28, 150);
        case 11: GivePlayerWeapon(playerid, 32, 150);
        case 12: GivePlayerWeapon(playerid, 3, 1);
        case 13: GivePlayerWeapon(playerid, 3, 1);
        case 14: SetPlayerArmour(playerid, 100.0);
        case 15: PI[playerid][pHasMask] = 1;
        case 16: GivePlayerWeapon(playerid, 17, 3);
        default: return CEFC_Notify(playerid, "Этого предмета на складе нет.", "hint");
    }
    CEFC_Notify(playerid, "Предмет получен со склада.", "success");
    CEFC_HudUpdate(playerid);
    return 1;
}

CMD:spasclad(playerid, params[])
{
    #pragma unused params
    return CEF_OpsStorageOpen(playerid);
}









stock CEF_OpsMembersOpen(playerid)
{
    static json[CEF_JSON_SIZE], part[220];
    new frac = PI[playerid][pFraction], first = 1, cnt = 0;
    if(frac <= 0) return CEFC_Notify(playerid, "Вы не состоите в организации.", "hint");

    CEF_MarkPlayerReady(playerid);

    format(json, sizeof json,
        "{\"fractionId\":%d,\"fractionName\":\"%s\",\"canManage\":%s,\"departmentsList\":[]}",
        CEF_OpsStorageCategory(playerid) ? CEF_OpsStorageCategory(playerid) : frac,
        Fraction[frac][fName], (PI[playerid][pLeader] > 0) ? ("true") : ("false"));
    CEF_Send(playerid, "cef_frc_players_list_open", json);
    CEF_SendEmpty(playerid, "cef_frc_players_list_clear");

    json = "[";
    foreach(new i : Player)
    {
        if(PI[i][pFraction] != frac || !PT[i][pLogged]) continue;


        format(part, sizeof part,
            "%s{\"playerId\":%d,\"nickname\":\"%s\",\"rankId\":%d,\"status\":%d,\"departmentId\":0,\"phone\":0,\"afk\":%d}",
            first ? ("") : (","), i, PI[i][pName], PI[i][pFractionRank],
            PI[i][pSuspended] ? 2 : (PT[i][pDuty] ? 1 : 0), PI[i][pAFK] ? 1 : 0);
        strcat(json, part);
        first = 0;
        cnt++;
    }
    strcat(json, "]");
    CEF_Send(playerid, "cef_frc_players_list_update", json);
    CEF_Focus(playerid, true);
    if(!cnt) CEFC_Notify(playerid, "Сейчас никого из организации нет в сети.", "hint");
    return 1;
}

stock CEF_OpsMembersResponse(playerid, const arguments[])
{
    new key = CEF_EcoFindInt(arguments, "key");
    new target = CEF_EcoFindInt(arguments, "playerId");
    new action = CEF_EcoFindInt(arguments, "action");
    static msg[144], q[196];

    if(key == 1)
    {
        CEF_SendEmpty(playerid, "cef_frc_players_list_close");
        CEF_Hide(playerid);
        return 1;
    }
    if(key != 2) return 1;

    if(!IsPlayerConnected(target) || PI[target][pFraction] != PI[playerid][pFraction])
        return CEFC_Notify(playerid, "Игрок недоступен.", "error");
    if(PI[playerid][pLeader] <= 0 && action != 1)
        return CEFC_Notify(playerid, "Только лидер может управлять составом.", "error");

    switch(action)
    {
        case 1:
        {
            format(msg, sizeof msg, "%s вызывает вас на связь.", PI[playerid][pName]);
            CEFC_Notify(target, msg, "info");
            CEFC_Notify(playerid, "Вызов отправлен.", "success");
        }
        case 2:
        {
            PI[target][pFraction] = 0;
            PI[target][pFractionRank] = 0;
            PI[target][pFractionSkin] = 0;
            mysql_format(dbHandle, q, sizeof q,
                "UPDATE `accounts` SET `fraction`=0,`fraction_rank`=0,`fraction_skin`=0 WHERE `id`=%d", PI[target][pID]);
            mysql_tquery(dbHandle, q);
            CEFC_Notify(target, "Вас уволили из организации.", "error");
            CEFC_Notify(playerid, "Сотрудник уволен.", "success");
            CEF_Send(playerid, "cef_frc_players_list_remove", "[0]");
        }
        case 3:
        {
            g_WarnCount[target]++;
            mysql_format(dbHandle, q, sizeof q,
                "UPDATE `accounts` SET `warn_count`=%d WHERE `id`=%d", g_WarnCount[target], PI[target][pID]);
            mysql_tquery(dbHandle, q);
            format(msg, sizeof msg, "Вам вынесен выговор (%d).", g_WarnCount[target]);
            CEFC_Notify(target, msg, "error");
            CEFC_Notify(playerid, "Выговор вынесен.", "success");
        }
        case 4:
        {
            new frac = PI[target][pFraction];
            if(PI[target][pFractionRank] >= Fraction[frac][fMax_ranks])
                return CEFC_Notify(playerid, "Это максимальный ранг.", "hint");
            PI[target][pFractionRank]++;
            mysql_format(dbHandle, q, sizeof q,
                "UPDATE `accounts` SET `fraction_rank`=%d WHERE `id`=%d", PI[target][pFractionRank], PI[target][pID]);
            mysql_tquery(dbHandle, q);
            CEFC_Notify(target, "Вас повысили в должности.", "success");
            CEFC_Notify(playerid, "Сотрудник повышен.", "success");
        }
        case 5:
        {
            if(PI[target][pFractionRank] <= 1)
                return CEFC_Notify(playerid, "Ниже первого ранга понизить нельзя.", "hint");
            PI[target][pFractionRank]--;
            mysql_format(dbHandle, q, sizeof q,
                "UPDATE `accounts` SET `fraction_rank`=%d WHERE `id`=%d", PI[target][pFractionRank], PI[target][pID]);
            mysql_tquery(dbHandle, q);
            CEFC_Notify(target, "Вас понизили в должности.", "error");
            CEFC_Notify(playerid, "Сотрудник понижен.", "success");
        }
        default: return CEFC_Notify(playerid, "Это действие недоступно.", "hint");
    }
    return CEF_OpsMembersOpen(playerid);
}

CMD:sostav(playerid, params[])
{
    #pragma unused params
    return CEF_OpsMembersOpen(playerid);
}





stock CEF_OpsPlayersList(playerid)
{
    static json[CEF_JSON_SIZE], part[280], nick[MAX_PLAYER_NAME + 8], raw[MAX_PLAYER_NAME];
    new first = 1, ping, lvl, fam, frac, aid;
    json = "[";
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i)) continue;
        nick[0] = EOS;
        if(strlen(PI[i][pName])) CEF_JsonEscape(PI[i][pName], nick);
        else
        {
            GetPlayerName(i, raw, sizeof raw);
            CEF_JsonEscape(raw, nick);
        }
        ping = GetPlayerPing(i);
        if(ping < 0) ping = 0;
        lvl = PI[i][pLevel];
        if(lvl < 1) lvl = 1;
        fam = PI[i][pFamily];
        frac = PI[i][pFraction];
        aid = PI[i][pID];
        if(aid < 1) aid = i + 1;
        format(part, sizeof part,
            "%s{\"id\":%d,\"idPlayer\":%d,\"staticId\":%d,\"nickname\":\"%s\",\"name\":\"%s\",\"level\":%d,\"ping\":%d,\"fractionId\":%d,\"familyId\":%d,\"companyId\":0,\"isAdmin\":%s,\"isHelper\":false,\"isLeader\":%s,\"media\":0,\"online\":true}",
            first ? ("") : (","), i, i, aid, nick, nick, lvl, ping, frac, fam,
            (PI[i][pAdmin] > 0) ? ("true") : ("false"),
            (frac > 0 && PI[i][pFractionRank] >= 8) ? ("true") : ("false"));
        if(strlen(json) + strlen(part) + 2 >= sizeof json) break;
        strcat(json, part);
        first = 0;
    }
    strcat(json, "]");
    return CEF_Send(playerid, "players_list_update", json);
}

stock CEF_OpsPlayersListAll()
{
    foreach(new i : Player) if(PT[i][pLogged]) CEF_OpsPlayersList(i);
    return 1;
}

stock CEF_OpsPlayerLeft(playerid)
{
    static json[48];
    format(json, sizeof json, "{\"id\":%d}", playerid);
    foreach(new i : Player)
    {
        if(i == playerid || !PT[i][pLogged]) continue;
        CEF_Send(i, "players_list_remove", json);
    }
    return 1;
}







new gCefTopPage[MAX_PLAYERS];

stock CEF_OpsTopOpen(playerid, page = 0)
{
    static q[256];
    gCefTopPage[playerid] = page;
    if(page == 1)
        mysql_format(dbHandle, q, sizeof q,
            "SELECT `name`,(`cash`+`bank`) AS `val` FROM `accounts` ORDER BY `val` DESC LIMIT 10");
    else
        mysql_format(dbHandle, q, sizeof q,
            "SELECT `name`,`level` AS `val` FROM `accounts` ORDER BY `val` DESC LIMIT 10");
    mysql_tquery(dbHandle, q, "OnCefTopLoaded", "d", playerid);
    return 1;
}

forward OnCefTopLoaded(playerid);
public OnCefTopLoaded(playerid)
{
    static json[CEF_JSON_SIZE], part[200], nick[MAX_PLAYER_NAME];
    new rows = cache_num_rows(), val, first = 1;
    if(!IsPlayerConnected(playerid)) return 0;

    json = "{\"pages\":\"Уровень\nДеньги\",\"headers\":\"Место\nИгрок\nЗначение\",";
    format(part, sizeof part, "\"selectedPage\":%d,\"topPlayers\":3,\"color\":\"#54B367\",\"participants\":[",
        gCefTopPage[playerid]);
    strcat(json, part);

    for(new i = 0; i < rows && i < 10; i++)
    {
        cache_get_value_name(i, "name", nick, sizeof nick);
        cache_get_value_name_int(i, "val", val);
        format(part, sizeof part, "%s{\"text\":\"%d\n%s\n%d\"}", first ? ("") : (","), i + 1, nick, val);
        strcat(json, part);
        first = 0;
    }
    strcat(json, "]}");

    CEF_MarkPlayerReady(playerid);
    CEF_Send(playerid, "cef_leaderboard_show", json);
    CEF_Focus(playerid, true);
    return 1;
}

stock CEF_OpsTopResponse(playerid, const arguments[])
{
    new action = CEF_EcoFindInt(arguments, "action");
    if(action == 0)
    {
        CEF_SendEmpty(playerid, "cef_leaderboard_hide");
        CEF_Hide(playerid);
        return 1;
    }
    return CEF_OpsTopOpen(playerid, CEF_EcoFindInt(arguments, "data"));
}




stock CEF_OpsNews(const text[], const color[] = "54B367")
{
    static json[600], esc[400];
    CEF_JsonEscape(text, esc);
    format(json, sizeof json, "{\"text\":\"%s\",\"color\":\"%s\"}", esc, color);
    foreach(new i : Player) if(PT[i][pLogged]) CEF_Send(i, "cef_news_add", json);
    return 1;
}

CMD:top(playerid, params[])
{
    #pragma unused params
    return CEF_OpsTopOpen(playerid, 0);
}





stock CEF_OpsQuickSlotInit()
{
    mysql_tquery(dbHandle,
        "CREATE TABLE IF NOT EXISTS `player_quick_slots` (`owner_id` INT NOT NULL, `slot_id` TINYINT UNSIGNED NOT NULL, `item_type` SMALLINT UNSIGNED NOT NULL DEFAULT 0, PRIMARY KEY (`owner_id`,`slot_id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4",
        "", "");
    return 1;
}

stock CEF_OpsQuickSlotSave(playerid, slotId, itemType)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || PI[playerid][pID] <= 0 || slotId < 0 || slotId >= 6) return 0;
    new query[240];
    if(itemType <= 0)
    {
        mysql_format(dbHandle, query, sizeof query,
            "DELETE FROM `player_quick_slots` WHERE `owner_id`=%d AND `slot_id`=%d",
            PI[playerid][pID], slotId);
    }
    else
    {
        if(itemType >= sizeof(Item)) return 0;
        mysql_format(dbHandle, query, sizeof query,
            "INSERT INTO `player_quick_slots` (`owner_id`,`slot_id`,`item_type`) VALUES (%d,%d,%d) ON DUPLICATE KEY UPDATE `item_type`=VALUES(`item_type`)",
            PI[playerid][pID], slotId, itemType);
    }
    mysql_tquery(dbHandle, query, "", "");
    return 1;
}

stock CEF_OpsQuickSlotsLoad(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) || PI[playerid][pID] <= 0) return 0;
    for(new slot = 0; slot < 6; slot++) gCefQuickSlotType[playerid][slot] = 0;
    gCefQuickSlotLoadSerial[playerid]++;
    if(gCefQuickSlotLoadSerial[playerid] <= 0) gCefQuickSlotLoadSerial[playerid] = 1;
    new query[200];
    mysql_format(dbHandle, query, sizeof query,
        "SELECT `slot_id`,`item_type` FROM `player_quick_slots` WHERE `owner_id`=%d ORDER BY `slot_id` ASC",
        PI[playerid][pID]);
    mysql_tquery(dbHandle, query, "OnCefQuickSlotsLoaded", "iii",
        playerid, PI[playerid][pID], gCefQuickSlotLoadSerial[playerid]);
    return 1;
}

public OnCefQuickSlotsLoaded(playerid, owner_id, load_serial)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid)) return 0;
    if(PI[playerid][pID] != owner_id || gCefQuickSlotLoadSerial[playerid] != load_serial) return 0;
    for(new slot = 0; slot < 6; slot++) gCefQuickSlotType[playerid][slot] = 0;
    new rows = cache_num_rows(), slot, itemType;
    for(new row = 0; row < rows; row++)
    {
        slot = -1;
        itemType = 0;
        cache_get_value_name_int(row, "slot_id", slot);
        cache_get_value_name_int(row, "item_type", itemType);
        if(slot < 0 || slot >= 6 || itemType <= 0 || itemType >= sizeof(Item)) continue;
        gCefQuickSlotType[playerid][slot] = itemType;
    }
    CEF_OpsQuickSlots(playerid, true);
    return 1;
}

stock CEF_OpsQuickSlotAmount(playerid, itemType)
{
    new amount = 0;
    for(new i = 0; i < MAX_ITEMS; i++)
        if(IT[playerid][i][iType] == itemType && IT[playerid][i][iAmount] > 0)
            amount += IT[playerid][i][iAmount];
    return amount;
}

stock CEF_OpsQuickSlots(playerid, bool:show = true)
{
    static json[600], part[88];
    new first = 1, spaType, itemType, amount;
    if(!show)
    {
        CEF_SendEmpty(playerid, "cef_quick_slots_hide");
        return 1;
    }
    json = "{\"items\":[";
    for(new slotId = 0; slotId < 6; slotId++)
    {
        itemType = gCefQuickSlotType[playerid][slotId];
        amount = 0;
        spaType = itemType > 0 ? CEF_ItemToSpa(itemType) : 0;
        if(itemType > 0) amount = CEF_OpsQuickSlotAmount(playerid, itemType);
        if(spaType <= 0 || amount <= 0) { spaType = 0; amount = 0; }
        format(part, sizeof part, "%s{\"slotId\":%d,\"type\":%d,\"value\":%d}",
            first ? "" : ",", slotId, spaType, amount);
        strcat(json, part, sizeof json);
        first = 0;
    }
    strcat(json, "],\"duration\":3600}", sizeof json);
    return CEF_Send(playerid, "cef_quick_slots_show", json);
}

CMD:qs(playerid, params[])
{
    #pragma unused params
    static bool:shown[MAX_PLAYERS];
    shown[playerid] = !shown[playerid];
    return CEF_OpsQuickSlots(playerid, shown[playerid]);
}








stock CEF_ItemToSpa(modType)
{
    switch(modType)
    {
        case CEF_ITEM_CANISTER: return 20;
        case CEF_ITEM_REPAIR:   return 3;
        case CEF_ITEM_MEDKIT:   return 1;
        case CEF_ITEM_GAS:      return 20;
        case CEF_ITEM_FOOD:     return 26;
        case CEF_ITEM_DRINK:    return 15;
        case 12:                return 12;
        case 13:                return 14;
    }
    if(modType > 0) return modType;
    return 0;
}

stock CEF_ItemFromSpa(spaType)
{
    switch(spaType)
    {
        case 20: return CEF_ITEM_CANISTER;
        case 3:  return CEF_ITEM_REPAIR;
        case 1:  return CEF_ITEM_MEDKIT;
        case 26: return CEF_ITEM_FOOD;
        case 15: return CEF_ITEM_DRINK;
    }
    return 0;
}





new bool:gCefMapOpen[MAX_PLAYERS];

stock CEF_OpsMapToggle(playerid)
{
    static json[300];
    if(gCefMapOpen[playerid])
    {
        gCefMapOpen[playerid] = false;
        CEF_SendEmpty(playerid, "cef_quick_map_hide");
        CEF_Focus(playerid, false);
        return 1;
    }
    gCefMapOpen[playerid] = true;
    CEF_MarkPlayerReady(playerid);
    format(json, sizeof json, "{\"icons\":[12,14,15,16,17,22,23,27]}");
    CEF_Send(playerid, "cef_quick_map_show", json);
    CEF_Send(playerid, "cef_quick_map_update", json);
    CEF_Focus(playerid, true);
    return 1;
}

CMD:map(playerid, params[])
{
    #pragma unused params
    return CEF_OpsMapToggle(playerid);
}

CMD:spabank(playerid, params[])
{
    #pragma unused params
    return CEF_OpsBankOpen(playerid, false);
}

CMD:spaservice(playerid, params[])
{
    #pragma unused params
    return CEF_OpsServiceOpen(playerid);
}


CMD:transfer(playerid, params[])
{
    new id, spec[] = "d", msg[64];
    if(sscanf(params, spec, id))
    {
        format(msg, sizeof msg, "Использование: /transfer <ID счёта>");
        return SendErr(playerid, msg);
    }
    if(id <= 0)
    {
        format(msg, sizeof msg, "Неверный номер счёта.");
        return SendErr(playerid, msg);
    }
    gCefBankTransferTarget[playerid] = id;
    CEFC_Notify(playerid, "Получатель выбран. Теперь в банке нажмите «Перевести» и укажите сумму.", "info");
    return 1;
}
