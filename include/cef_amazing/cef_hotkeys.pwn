















#if defined _cef_hotkeys_inc
    #endinput
#endif
#define _cef_hotkeys_inc

#define CEF_INV_RESP_ITEM_ACTION 0
#define CEF_INV_RESP_ITEM_MOVE   1
#define CEF_INV_RESP_SORT        2
#define CEF_INV_RESP_INFO        3
#define CEF_INV_RESP_DEEP        4
#define CEF_INV_RESP_OLD         5

#define CEF_INV_AREA_MAIN        1
#define CEF_INV_AREA_QUICK       6




stock CEF_HotkeyToggleMenu(playerid)
{
    return CEF_InventoryToggle(playerid);
}

stock CEF_HotkeyCloseActive(playerid)
{
    if(gCefAuthActive[playerid]) return 1;
    if(gCefcDialogId[playerid] != -1) return CEFC_DialogClose(playerid);
    if(gCefCaseActive[playerid] || gCefCasePending[playerid]) return CEF_CaseCloseUi(playerid);
    if(gCefChatInput[playerid]) return CEFC_ChatCloseInput(playerid);
    if(gCefInventoryRouteOpen[playerid]) return CEF_InventoryClose(playerid, true);
    if(gCefInventoryPendingOpen[playerid])
    {
        CEF_InventoryClose(playerid, false);
        return 1;
    }
    if(gCefFinesOpen[playerid] || gCefFinesPendingOpen[playerid]) return CEF_FinesClose(playerid);
    if(gCefRadarManageOpen[playerid]) return CEF_RadarManageClose(playerid);
    if(gCefAdminPanelOpen[playerid]) return CEF_AdminPanelClose(playerid);
    if(gCefSupportPanelOpen[playerid]) return CEF_SupportClose(playerid);
    if(gCefMenuOpen[playerid]) return CloseTabCEF(playerid);
    CEF_Focus(playerid, false);
    return 1;
}

stock CEF_HotkeyOpenF3(playerid)
{
    if(gCefAdminPanelOpen[playerid]) return CEF_AdminPanelClose(playerid);
    if(gCefSupportPanelOpen[playerid] && PI[playerid][pAdmin] < 1) return CEF_SupportClose(playerid);
    CEF_HotkeyCloseActive(playerid);
    if(PI[playerid][pAdmin] >= 1) return CEF_AllAdminOpen(playerid);
    return CEF_AllSupportOpen(playerid);
}

public CEF_HotkeyGameKey(playerid, key)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) || !PT[playerid][pLogged]) return 0;
    if(gCefAuthActive[playerid]) return 1;
    switch(key)
    {
        case 9:
        {
            if(gCefCaseActive[playerid] || gCefCasePending[playerid]) return CEF_CaseCloseUi(playerid);
            if(gCefInventoryRouteOpen[playerid] || gCefInventoryPendingOpen[playerid] || gCefFinesOpen[playerid] || gCefFinesPendingOpen[playerid] || gCefRadarManageOpen[playerid] || gCefAdminPanelOpen[playerid] || gCefSupportPanelOpen[playerid] || gCefcDialogId[playerid] != -1 || gCefChatInput[playerid])
                return CEF_HotkeyCloseActive(playerid);
            if(gCefMenuOpen[playerid]) return CloseTabCEF(playerid);
            if(GetTickCount() - gCefTabClosedAt[playerid] < 600) return 1;
            return OpenTabCEF(playerid, 1);
        }
        case 73:
        {
            if(gCefInventoryRouteOpen[playerid]) return CEF_InventoryClose(playerid, true);
            if(gCefInventoryPendingOpen[playerid])
            {
                CEF_InventoryClose(playerid, false);
                return 1;
            }
            return CEF_InventoryToggle(playerid);
        }
        case 27: return CEF_HotkeyCloseActive(playerid);
        case 114: return CEF_HotkeyOpenF3(playerid);
    }
    return 1;
}

stock CEF_HotkeyChat(playerid)
{
    if(gCefMenuOpen[playerid]) return 1;
    if(gCefChatInput[playerid]) return CEFC_ChatCloseInput(playerid);
    return CEFC_ChatOpenInput(playerid);
}

forward CEF_HotkeyHandle(player_id, const arguments[]);
public CEF_HotkeyHandle(player_id, const arguments[])
{
    new playerid = player_id;
    if(!IsPlayerConnected(playerid) || !PT[playerid][pLogged]) return 0;
    if(gCefAuthActive[playerid]) return 1;
    new code[16];
    CEF_JsonTopStr(arguments, "code", code, sizeof code);
    if(!strlen(code)) CEF_Arg(arguments, 0, code);
    printf("[CEF-HOTKEY] %d code=%s args=%s", playerid, code, arguments);
    if(!strcmp(code, "ENTER", true))
    {
        if(!gCefChatInput[playerid]) return 1;
        return CEF_Send(playerid, "cef_chat_action", "{\"action\":1,\"data\":0}");
    }
    if(!strcmp(code, "ESCAPE", true)) return CEF_HotkeyGameKey(playerid, 27);
    if(!strcmp(code, "F1", true)) return CEF_OpsEscOpen(playerid);
    if(!strcmp(code, "F3", true)) return CEF_HotkeyOpenF3(playerid);
    if(!strcmp(code, "F6", true)) return CEF_HotkeyChat(playerid);
    if(!strcmp(code, "TAB", true)) return CEF_HotkeyGameKey(playerid, 9);
    if(!strcmp(code, "I", true)) return CEF_HotkeyGameKey(playerid, 73);
    if(!strcmp(code, "X", true)) return CallLocalFunction("CEF_AllAnimsOpen", "i", playerid);
    if(!strcmp(code, "M", true)) return CallLocalFunction("CEF_AllMapToggle", "i", playerid);
    return 1;
}


stock CEF_InvSortPack(playerid)
{
    return CEF_InventoryCompact(playerid);
}




forward CEF_InvItemActionHandle(player_id, const arguments[]);
public CEF_InvItemActionHandle(player_id, const arguments[])
{
    new playerid = player_id;
    if(!IsPlayerConnected(playerid) || !PT[playerid][pLogged]) return 0;
    new response = CEF_EcoFindInt(arguments, "response");
    new slotId   = CEF_EcoFindInt(arguments, "slotId");
    new action   = CEF_EcoFindInt(arguments, "action");
    new area     = CEF_EcoFindInt(arguments, "area");
    new fromSlot = CEF_EcoFindInt(arguments, "fromSlotId");
    new fromArea = CEF_EcoFindInt(arguments, "fromArea");
    new toSlot   = CEF_EcoFindInt(arguments, "toSlotId");
    new toArea   = CEF_EcoFindInt(arguments, "toArea");
    printf("[CEF-INV-ACT] %d resp=%d slot=%d act=%d area=%d from=%d/%d to=%d/%d",
        playerid, response, slotId, action, area, fromSlot, fromArea, toSlot, toArea);

    switch(response)
    {
        case CEF_INV_RESP_ITEM_ACTION:
        {
            new spaType = (slotId >= 0 && slotId < 64) ? gCefInvType[playerid][slotId] : 0;
            new idx     = (slotId >= 0 && slotId < 64) ? gCefInvIdx[playerid][slotId] : -1;
            new itemType = 0;

            if(idx >= 0 && idx < MAX_ITEMS) itemType = IT[playerid][idx][iType];
            if(itemType <= 0 && spaType > 0 && CEF_CaseIndex(spaType) < 0) itemType = CEF_ItemFromSpa(spaType);

            switch(action)
            {
                case 0: return CEF_InvSync(playerid);
                case 1:
                {
                    if(spaType > 0 && CEF_CaseIndex(spaType) >= 0)
                        return CEF_CaseOpenWindow(playerid, spaType);
                    if(itemType <= 0)
                        return CEFC_Notify(playerid, "Пустой слот.", "hint");
                    CEF_OpsInvUse(playerid, itemType, idx);
                    SavePlayerInventory(playerid);
                    return CEF_InvSync(playerid);
                }
                case 2, 3:
                {
                    if(spaType == 9)
                        return CEFC_Notify(playerid, "Скин уже надет.", "hint");
                    if(spaType >= 1 && spaType <= 311 && CEF_SkinHas(playerid, spaType))
                        return CEF_SkinWear(playerid, spaType);
                    return CEFC_Notify(playerid, "Этот предмет нельзя надеть.", "hint");
                }
                case 4:
                {
                    if(itemType == 533 && CEF_ShopGiveWeapon(playerid, 533))
                        return CEFC_Notify(playerid, "Weapon taken in hand.", "info");
                    return CEFC_Notify(playerid, "This item cannot be taken in hand.", "hint");
                }
                case 5:
                {
                    if(idx < 0 || IT[playerid][idx][iAmount] < 2)
                        return CEFC_Notify(playerid, "Этот стек нельзя разделить.", "hint");
                    new half = IT[playerid][idx][iAmount] / 2;
                    new free = -1;
                    for(new i = 0; i < MAX_ITEMS; i++)
                    {
                        if(IT[playerid][i][iType] <= 0) { free = i; break; }
                    }
                    if(free < 0) return CEFC_Notify(playerid, "Нет свободного слота.", "error");
                    IT[playerid][idx][iAmount] -= half;
                    IT[playerid][free][iType]   = IT[playerid][idx][iType];
                    IT[playerid][free][iAmount] = half;
                    SavePlayerInventory(playerid);
                    CEF_InvSync(playerid);
                    return CEFC_Notify(playerid, "Стек разделён.", "success");
                }
                case 6:
                {
                    if(spaType > 0 && CEF_CaseIndex(spaType) >= 0)
                    {
                        CEF_CaseTake(playerid, spaType, 1);
                        CEF_InvSync(playerid);
                        return CEFC_Notify(playerid, "Кейс выброшен.", "info");
                    }
                    if(idx < 0) return CEFC_Notify(playerid, "Этот предмет нельзя выбросить.", "hint");
                    RemoveItem(playerid, IT[playerid][idx][iType], 1);
                    SavePlayerInventory(playerid);
                    CEF_InvSync(playerid);
                    return CEFC_Notify(playerid, "Предмет выброшен.", "info");
                }
                case 7:
                {
                    if(itemType == CEF_ITEM_CANISTER || itemType == CEF_ITEM_GAS)
                        return CEF_OpsInvUse(playerid, itemType, idx);
                    return CEFC_Notify(playerid, "Нечего выливать.", "hint");
                }
                case 8, 10:
                {
                    if(area == CEF_INV_AREA_MAIN || area == CEF_INV_AREA_STORAGE)
                        return CEF_StorageFastMove(playerid, area, slotId);
                    return CEFC_Notify(playerid, "This area cannot be moved to storage.", "hint");
                }
                case 9, 12, 16: return CEFC_Notify(playerid, "Для этого предмета недоступно.", "hint");
                case 11:
                {
                    if(idx < 0) return CEFC_Notify(playerid, "Этот предмет нельзя удалить.", "hint");
                    RemoveItem(playerid, IT[playerid][idx][iType], IT[playerid][idx][iAmount]);
                    SavePlayerInventory(playerid);
                    CEF_InvSync(playerid);
                    return CEFC_Notify(playerid, "Стек удалён.", "info");
                }
                case 13:
                {
                    if(itemType == CEF_ITEM_REPAIR)
                    {
                        CEF_OpsInvUse(playerid, itemType, idx);
                        SavePlayerInventory(playerid);
                        return CEF_InvSync(playerid);
                    }
                    return CEFC_Notify(playerid, "Нет ремкомплекта.", "hint");
                }
                case 14:
                {
                    new actionIndex = CEF_EcoFindInt(arguments, "index");
                    if(actionIndex < 0 || actionIndex >= 6)
                        return CEFC_Notify(playerid, "Select a hotbar slot from 1 to 6.", "hint");
                    if(area != CEF_INV_AREA_MAIN || idx < 0 || idx >= MAX_ITEMS)
                        return CEFC_Notify(playerid, "Select an inventory item first.", "hint");
                    itemType = IT[playerid][idx][iType];
                    if(itemType <= 0 || CEF_OpsInvFindSlotByType(playerid, itemType) < 0)
                        return CEFC_Notify(playerid, "That item is not available.", "hint");
                    gCefQuickSlotType[playerid][actionIndex] = itemType;
                    CEF_OpsQuickSlotSave(playerid, actionIndex, itemType);
                    CEF_OpsQuickSlots(playerid);
                    return CEFC_Notify(playerid, "Quick slot assigned.", "success");
                }
                case 15:
                {
                    if(slotId < 0 || slotId >= 6)
                        return CEFC_Notify(playerid, "Invalid quick slot.", "hint");
                    gCefQuickSlotType[playerid][slotId] = 0;
                    CEF_OpsQuickSlotSave(playerid, slotId, 0);
                    CEF_OpsQuickSlots(playerid);
                    return CEFC_Notify(playerid, "Quick slot cleared.", "info");
                }
                default: return 1;
            }
        }
        case CEF_INV_RESP_ITEM_MOVE:
        {
            if(fromArea == CEF_INV_AREA_STORAGE || toArea == CEF_INV_AREA_STORAGE)
                return CEF_StorageMoveBySlots(playerid, fromArea, fromSlot, toArea, toSlot);
            if(fromArea != CEF_INV_AREA_MAIN || toArea != CEF_INV_AREA_MAIN)
                return CEFC_Notify(playerid, "Перенос между этими областями недоступен.", "hint");
            new fi = (fromSlot >= 0 && fromSlot < 64) ? gCefInvIdx[playerid][fromSlot] : -1;
            new ti = (toSlot >= 0 && toSlot < 64) ? gCefInvIdx[playerid][toSlot] : -1;
            if(fi < 0)
                return CEFC_Notify(playerid, "Этот предмет нельзя перенести.", "hint");
            if(ti < 0)
            {
                CEF_InvSortPack(playerid);
                SavePlayerInventory(playerid);
                return CEF_InvSync(playerid);
            }
            new tmpType   = IT[playerid][fi][iType];
            new tmpAmount = IT[playerid][fi][iAmount];
            IT[playerid][fi][iType]   = IT[playerid][ti][iType];
            IT[playerid][fi][iAmount] = IT[playerid][ti][iAmount];
            IT[playerid][ti][iType]   = tmpType;
            IT[playerid][ti][iAmount] = tmpAmount;
            SavePlayerInventory(playerid);
            return CEF_InvSync(playerid);
        }
        case CEF_INV_RESP_SORT:
        {
            CEF_InvSortPack(playerid);
            SavePlayerInventory(playerid);
            CEF_InvSync(playerid);
            return CEFC_Notify(playerid, "Инвентарь отсортирован.", "success");
        }
        case CEF_INV_RESP_INFO: return CEF_InvSync(playerid);
        case CEF_INV_RESP_DEEP, CEF_INV_RESP_OLD:
            return CEFC_Notify(playerid, "Этот экран в данной сборке не подключён.", "hint");
    }
    return 1;
}




CMD:f3(playerid, params[])
{
    #pragma unused params
    return CEF_HotkeyOpenF3(playerid);
}

CMD:help(playerid, params[])
{
    #pragma unused params
    CallLocalFunction("CEF_AllSupportOpen", "i", playerid);
    return 1;
}

CMD:support(playerid, params[])
{
    #pragma unused params
    return CallLocalFunction("CEF_AllSupportOpen", "i", playerid);
}

CMD:pomosh(playerid, params[])
{
    #pragma unused params
    return CallLocalFunction("CEF_AllSupportOpen", "i", playerid);
}

CMD:chat(playerid, params[])
{
    #pragma unused params
    return CEF_HotkeyChat(playerid);
}

CMD:inventory(playerid, params[])
{
    #pragma unused params
    return CEF_InventoryToggle(playerid);
}

CMD:i(playerid, params[])
{
    #pragma unused params
    return CEF_InventoryToggle(playerid);
}

CMD:hotkeys(playerid, params[])
{
    #pragma unused params
    CEFC_Notify(playerid, "F1 пауза · F3 помощь/админ-панель · F6 чат · TAB меню · I инвентарь · X анимации · M карта", "info", 6000);
    SendClientMessage(playerid, 0x54B367FF, "Хоткеи: F1 пауза, F3 помощь/админ-панель, F6 чат, TAB меню, I инвентарь, X анимации, M карта");
    SendClientMessage(playerid, 0xCCCCCCFF, "Если клавиши не работают: /hotkeyson (включить) или /hotkeysoff (выключить)");
    return 1;
}

CMD:hotkeyson(playerid, params[])
{
    #pragma unused params
    cef_always_listen_keys(playerid, MAIN_BROWSER, true);
    SendClientMessage(playerid, 0x54B367FF, "Хоткеи страницы включены (F1/F3/F6/TAB/I/X/M).");
    return 1;
}

CMD:hotkeysoff(playerid, params[])
{
    #pragma unused params
    cef_always_listen_keys(playerid, MAIN_BROWSER, false);
    SendClientMessage(playerid, 0xCCCCCCFF, "Хоткеи страницы выключены. Команды чата продолжают работать.");
    return 1;
}
