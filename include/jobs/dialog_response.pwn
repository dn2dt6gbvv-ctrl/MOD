case RAZVOZ_DIALOG_MAIN:
{
    if(!response) {
        CEFChat_Send(playerid, "AAAAAA", "Вы закрыли диалог.");
        return 1;
    }
    ShowPlayerDialogEx(playerid, RAZVOZ_DIALOG_RESOURCE, DIALOG_STYLE_LIST,
        "Тип работы",
        "Развозка товаров\nРазвозка топлива",
        "Начать", "Закрыть");
    return 1;
}

case RAZVOZ_DIALOG_RESOURCE:
{
    if(!response) {
        CEFChat_Send(playerid, "AAAAAA", "Вы закрыли диалог.");
        return 1;
    }
    new type = listitem + 1;
    GiveRazvozVehicle(playerid, type);
    return 1;
}

case RAZVOZ_DIALOG_MENU:
{
    if(!response) {
        CEFChat_Send(playerid, "AAAAAA", "Вы закрыли меню.");
        return 1;
    }
    new type = Razvoz_GetType(playerid);
    new maxLoad = Razvoz_GetMaxLoad(playerid);
    
    if(type == 1) {
        switch(listitem) {
            case 0: {
                if(!Razvoz_IsAtLoadPointGoods(playerid)) {
                    CEFChat_Send(playerid, "FF4444", "Вы должны находиться на складе товаров.");
                    return 1;
                }
                if(g_RazvozLoaded[playerid] >= maxLoad) {
                    new msg[64];
                    format(msg, sizeof(msg), "Ваш транспорт уже загружен товарами (макс %d ед.).", maxLoad);
                    CEFChat_Send(playerid, "FF4444", msg);
                    return 1;
                }
                new loadAmount = maxLoad - g_RazvozLoaded[playerid];
                new cost = loadAmount * RAZVOZ_BUY_PRICE_GOODS;
                if(PI[playerid][pCash] < cost) {
                    new msg[64];
                    format(msg, sizeof(msg), "У вас недостаточно денег для закупки (нужно %d руб.).", cost);
                    CEFChat_Send(playerid, "FF4444", msg);
                    return 1;
                }
                SetPVarInt(playerid, "RazvozLoadAmount", loadAmount);
                SetPVarInt(playerid, "RazvozLoadCost", cost);
                new confirmMsg[256];
                format(confirmMsg, sizeof(confirmMsg),
                    "Вы хотите закупить {e69348}%d{FFFFFF} единиц товаров\nпо цене {e69348}%d руб./ед.{FFFFFF}\nна сумму {e69348}%d руб.{FFFFFF}?",
                    loadAmount, RAZVOZ_BUY_PRICE_GOODS, cost);
                ShowPlayerDialogEx(playerid, RAZVOZ_DIALOG_CONFIRM_LOAD, DIALOG_STYLE_MSGBOX,
                    "Подтверждение закупки", confirmMsg, "Да, купить", "Нет, отмена");
                return 1;
            }
            case 1: {
                if(g_RazvozLoaded[playerid] <= 0) {
                    CEFChat_Send(playerid, "FF4444", "У вас нет загруженных товаров.");
                    return 1;
                }
                if(g_RazvozLoadedType[playerid] != 0) {
                    CEFChat_Send(playerid, "FF4444", "У вас загружены не товары.");
                    return 1;
                }
                new idx = g_RazvozSelectedOrder[playerid];
                if(idx < 0 || idx >= g_RazvozOrderCount || !g_RazvozOrders[idx][rzActive]) {
                    CEFChat_Send(playerid, "FF4444", "Вы не выбрали активный заказ.");
                    g_RazvozSelectedOrder[playerid] = -1;
                    return 1;
                }
                if(g_RazvozOrders[idx][rzType] != 1) {
                    CEFChat_Send(playerid, "FF4444", "Заказ не для товаров.");
                    return 1;
                }
                if(!Razvoz_IsAtOrderPoint(playerid, idx)) {
                    CEFChat_Send(playerid, "FF4444", "Вы должны находиться около точки заказа.");
                    return 1;
                }
                new maxSell = g_RazvozLoaded[playerid];
                if(maxSell > g_RazvozOrders[idx][rzRequired]) maxSell = g_RazvozOrders[idx][rzRequired];
                if(maxSell <= 0) {
                    CEFChat_Send(playerid, "FF4444", "Заказ уже выполнен.");
                    return 1;
                }
                new reward = maxSell * g_RazvozOrders[idx][rzPrice];
                SetPVarInt(playerid, "RazvozUnloadAmount", maxSell);
                SetPVarInt(playerid, "RazvozUnloadReward", reward);
                SetPVarInt(playerid, "RazvozUnloadOrderIdx", idx);
                new confirmMsg[256];
                format(confirmMsg, sizeof(confirmMsg),
                    "Вы хотите продать {e69348}%d{FFFFFF} единиц товаров\nпо цене {e69348}%d руб./ед.{FFFFFF}\nна сумму {e69348}%d руб.{FFFFFF}?",
                    maxSell, g_RazvozOrders[idx][rzPrice], reward);
                ShowPlayerDialogEx(playerid, RAZVOZ_DIALOG_CONFIRM_UNLOAD, DIALOG_STYLE_MSGBOX,
                    "Подтверждение продажи", confirmMsg, "Да, продать", "Нет, отмена");
                return 1;
            }
            case 2: {
                new count = 0;
                for(new i = 0; i < g_RazvozOrderCount; i++) {
                    if(g_RazvozOrders[i][rzActive] && g_RazvozOrders[i][rzType] == 1 && g_RazvozOrders[i][rzRequired] > 0 && g_RazvozOrders[i][rzPrice] > 0) {
                        count++;
                    }
                }
                if(count == 0) {
                    CEFChat_Send(playerid, "FF4444", "Нет активных заказов для товаров.");
                    return 1;
                }
                g_RazvozOrderListCount[playerid] = 0;
                for(new i = 0; i < g_RazvozOrderCount; i++) {
                    if(g_RazvozOrders[i][rzActive] && g_RazvozOrders[i][rzType] == 1 && g_RazvozOrders[i][rzRequired] > 0 && g_RazvozOrders[i][rzPrice] > 0) {
                        g_RazvozOrderList[playerid][g_RazvozOrderListCount[playerid]++] = i;
                    }
                }
                new idxCount = g_RazvozOrderListCount[playerid];
                for(new i = 0; i < idxCount-1; i++) {
                    for(new j = i+1; j < idxCount; j++) {
                        if(g_RazvozOrders[g_RazvozOrderList[playerid][i]][rzPrice] < g_RazvozOrders[g_RazvozOrderList[playerid][j]][rzPrice]) {
                            new tmp = g_RazvozOrderList[playerid][i];
                            g_RazvozOrderList[playerid][i] = g_RazvozOrderList[playerid][j];
                            g_RazvozOrderList[playerid][j] = tmp;
                        }
                    }
                }
                new dialogStr[2048];
                format(dialogStr, sizeof(dialogStr), "Название\tТребуется\tЦена за ед.\n");
                for(new i = 0; i < idxCount; i++) {
                    new idx = g_RazvozOrderList[playerid][i];
                    new line[128];
                    format(line, sizeof(line), "%s\t%d ед.\t%d руб.\n",
                        g_RazvozOrders[idx][rzName], g_RazvozOrders[idx][rzRequired], g_RazvozOrders[idx][rzPrice]);
                    strcat(dialogStr, line);
                }
                ShowPlayerDialogEx(playerid, RAZVOZ_DIALOG_ORDERS, DIALOG_STYLE_TABLIST_HEADERS,
                    "Доступные заказы (товары)", dialogStr, "Выбрать", "Закрыть");
                return 1;
            }
            case 3: {
                if(!Razvoz_IsAtLoadPointWood(playerid)) {
                    CEFChat_Send(playerid, "FF4444", "Вы должны находиться на складе древесины.");
                    return 1;
                }
                new total = g_RazvozWoodLoaded[playerid] + g_RazvozMetalLoaded[playerid];
                if(total >= RAZVOZ_MAX_WOOD_METAL_LOAD) {
                    CEFChat_Send(playerid, "FF4444", "Ваш транспорт уже полностью загружен сырьём (1000 кг).");
                    return 1;
                }
                new freeSpace = RAZVOZ_MAX_WOOD_METAL_LOAD - total;
                new maxLoadWood = (freeSpace > RAZVOZ_LOAD_PER_TIME) ? RAZVOZ_LOAD_PER_TIME : freeSpace;
                new cost = maxLoadWood * RAZVOZ_PRICE_WOOD_BUY;
                if(PI[playerid][pCash] < cost) {
                    new msg[64];
                    format(msg, sizeof(msg), "У вас недостаточно денег для закупки древесины (нужно %d руб.).", cost);
                    CEFChat_Send(playerid, "FF4444", msg);
                    return 1;
                }
                SetPVarInt(playerid, "RazvozWoodLoadAmount", maxLoadWood);
                SetPVarInt(playerid, "RazvozWoodLoadCost", cost);
                new confirmMsg[256];
                format(confirmMsg, sizeof(confirmMsg),
                    "Вы хотите закупить {e69348}%d{FFFFFF} кг древесины\nпо цене {e69348}%d руб./кг{FFFFFF}\nна сумму {e69348}%d руб.{FFFFFF}?",
                    maxLoadWood, RAZVOZ_PRICE_WOOD_BUY, cost);
                ShowPlayerDialogEx(playerid, RAZVOZ_DIALOG_CONFIRM_LOAD_WOOD, DIALOG_STYLE_MSGBOX,
                    "Подтверждение закупки", confirmMsg, "Да, купить", "Нет, отмена");
                return 1;
            }
            case 4: {
                if(!Razvoz_IsAtLoadPointMetal(playerid)) {
                    CEFChat_Send(playerid, "FF4444", "Вы должны находиться на складе металла.");
                    return 1;
                }
                new total = g_RazvozWoodLoaded[playerid] + g_RazvozMetalLoaded[playerid];
                if(total >= RAZVOZ_MAX_WOOD_METAL_LOAD) {
                    CEFChat_Send(playerid, "FF4444", "Ваш транспорт уже полностью загружен сырьём (1000 кг).");
                    return 1;
                }
                new freeSpace = RAZVOZ_MAX_WOOD_METAL_LOAD - total;
                new maxLoadMetal = (freeSpace > RAZVOZ_LOAD_PER_TIME) ? RAZVOZ_LOAD_PER_TIME : freeSpace;
                new cost = maxLoadMetal * RAZVOZ_PRICE_METAL_BUY;
                if(PI[playerid][pCash] < cost) {
                    new msg[64];
                    format(msg, sizeof(msg), "У вас недостаточно денег для закупки металла (нужно %d руб.).", cost);
                    CEFChat_Send(playerid, "FF4444", msg);
                    return 1;
                }
                SetPVarInt(playerid, "RazvozMetalLoadAmount", maxLoadMetal);
                SetPVarInt(playerid, "RazvozMetalLoadCost", cost);
                new confirmMsg[256];
                format(confirmMsg, sizeof(confirmMsg),
                    "Вы хотите закупить {e69348}%d{FFFFFF} кг металла\nпо цене {e69348}%d руб./кг{FFFFFF}\nна сумму {e69348}%d руб.{FFFFFF}?",
                    maxLoadMetal, RAZVOZ_PRICE_METAL_BUY, cost);
                ShowPlayerDialogEx(playerid, RAZVOZ_DIALOG_CONFIRM_LOAD_METAL, DIALOG_STYLE_MSGBOX,
                    "Подтверждение закупки", confirmMsg, "Да, купить", "Нет, отмена");
                return 1;
            }
            case 5: {
                new total = g_RazvozWoodLoaded[playerid] + g_RazvozMetalLoaded[playerid];
                if(total <= 0) {
                    CEFChat_Send(playerid, "FF4444", "У вас нет загруженного сырья.");
                    return 1;
                }
                if(!Razvoz_IsAtFactoryUnload(playerid)) {
                    CEFChat_Send(playerid, "FF4444", "Вы должны находиться на складе завода.");
                    return 1;
                }
                new woodAmount = g_RazvozWoodLoaded[playerid];
                new metalAmount = g_RazvozMetalLoaded[playerid];
                new reward = woodAmount * RAZVOZ_PRICE_WOOD_SELL + metalAmount * RAZVOZ_PRICE_METAL_SELL;
                SetPVarInt(playerid, "RazvozUnloadWoodAmount", woodAmount);
                SetPVarInt(playerid, "RazvozUnloadMetalAmount", metalAmount);
                SetPVarInt(playerid, "RazvozUnloadReward", reward);
                new confirmMsg[256];
                format(confirmMsg, sizeof(confirmMsg),
                    "Вы хотите продать:\n{e69348}%d{FFFFFF} кг древесины (по %d руб/кг)\n{e69348}%d{FFFFFF} кг металла (по %d руб/кг)\n\nИтого: {e69348}%d руб.{FFFFFF}",
                    woodAmount, RAZVOZ_PRICE_WOOD_SELL,
                    metalAmount, RAZVOZ_PRICE_METAL_SELL,
                    reward);
                ShowPlayerDialogEx(playerid, RAZVOZ_DIALOG_CONFIRM_UNLOAD_WOODMETAL, DIALOG_STYLE_MSGBOX,
                    "Подтверждение продажи", confirmMsg, "Да, продать", "Нет, отмена");
                return 1;
            }
            case 6: {
                Razvoz_ShowInfo(playerid);
                return 1;
            }
        }
    }
    else if(type == 2) {
        switch(listitem) {
            case 0: {
                if(!Razvoz_IsAtLoadPointFuel(playerid)) {
                    CEFChat_Send(playerid, "FF4444", "Вы должны находиться на складе топлива.");
                    return 1;
                }
                if(g_RazvozLoaded[playerid] >= maxLoad) {
                    new msg[64];
                    format(msg, sizeof(msg), "Ваш транспорт уже загружен топливом (макс %d ед.).", maxLoad);
                    CEFChat_Send(playerid, "FF4444", msg);
                    return 1;
                }
                new loadAmount = maxLoad - g_RazvozLoaded[playerid];
                new cost = loadAmount * RAZVOZ_BUY_PRICE_FUEL;
                if(PI[playerid][pCash] < cost) {
                    new msg[64];
                    format(msg, sizeof(msg), "У вас недостаточно денег для закупки топлива (нужно %d руб.).", cost);
                    CEFChat_Send(playerid, "FF4444", msg);
                    return 1;
                }
                SetPVarInt(playerid, "RazvozFuelLoadAmount", loadAmount);
                SetPVarInt(playerid, "RazvozFuelLoadCost", cost);
                new confirmMsg[256];
                format(confirmMsg, sizeof(confirmMsg),
                    "Вы хотите закупить {e69348}%d{FFFFFF} единиц топлива\nпо цене {e69348}%d руб./ед.{FFFFFF}\nна сумму {e69348}%d руб.{FFFFFF}?",
                    loadAmount, RAZVOZ_BUY_PRICE_FUEL, cost);
                ShowPlayerDialogEx(playerid, RAZVOZ_DIALOG_CONFIRM_LOAD_FUEL, DIALOG_STYLE_MSGBOX,
                    "Подтверждение закупки", confirmMsg, "Да, купить", "Нет, отмена");
                return 1;
            }
            case 1: {
                if(g_RazvozLoaded[playerid] <= 0) {
                    CEFChat_Send(playerid, "FF4444", "У вас нет загруженного топлива.");
                    return 1;
                }
                if(g_RazvozLoadedType[playerid] != 3) {
                    CEFChat_Send(playerid, "FF4444", "У вас загружены не топливо.");
                    return 1;
                }
                new idx = g_RazvozSelectedOrder[playerid];
                if(idx < 0 || idx >= g_RazvozOrderCount || !g_RazvozOrders[idx][rzActive]) {
                    CEFChat_Send(playerid, "FF4444", "Вы не выбрали активный заказ.");
                    g_RazvozSelectedOrder[playerid] = -1;
                    return 1;
                }
                if(g_RazvozOrders[idx][rzType] != 2) {
                    CEFChat_Send(playerid, "FF4444", "Заказ не для топлива.");
                    return 1;
                }
                if(!Razvoz_IsAtOrderPoint(playerid, idx)) {
                    CEFChat_Send(playerid, "FF4444", "Вы должны находиться около точки заказа (АЗС).");
                    return 1;
                }
                new maxSell = g_RazvozLoaded[playerid];
                if(maxSell > g_RazvozOrders[idx][rzRequired]) maxSell = g_RazvozOrders[idx][rzRequired];
                if(maxSell <= 0) {
                    CEFChat_Send(playerid, "FF4444", "Заказ уже выполнен.");
                    return 1;
                }
                new reward = maxSell * g_RazvozOrders[idx][rzPrice];
                SetPVarInt(playerid, "RazvozUnloadAmount", maxSell);
                SetPVarInt(playerid, "RazvozUnloadReward", reward);
                SetPVarInt(playerid, "RazvozUnloadOrderIdx", idx);
                new confirmMsg[256];
                format(confirmMsg, sizeof(confirmMsg),
                    "Вы хотите продать {e69348}%d{FFFFFF} единиц топлива\nпо цене {e69348}%d руб./ед.{FFFFFF}\nна сумму {e69348}%d руб.{FFFFFF}?",
                    maxSell, g_RazvozOrders[idx][rzPrice], reward);
                ShowPlayerDialogEx(playerid, RAZVOZ_DIALOG_CONFIRM_UNLOAD, DIALOG_STYLE_MSGBOX,
                    "Подтверждение продажи", confirmMsg, "Да, продать", "Нет, отмена");
                return 1;
            }
            case 2: {
                new count = 0;
                for(new i = 0; i < g_RazvozOrderCount; i++) {
                    if(g_RazvozOrders[i][rzActive] && g_RazvozOrders[i][rzType] == 2 && g_RazvozOrders[i][rzRequired] > 0 && g_RazvozOrders[i][rzPrice] > 0) {
                        count++;
                    }
                }
                if(count == 0) {
                    CEFChat_Send(playerid, "FF4444", "Нет активных заказов для топлива.");
                    return 1;
                }
                g_RazvozOrderListCount[playerid] = 0;
                for(new i = 0; i < g_RazvozOrderCount; i++) {
                    if(g_RazvozOrders[i][rzActive] && g_RazvozOrders[i][rzType] == 2 && g_RazvozOrders[i][rzRequired] > 0 && g_RazvozOrders[i][rzPrice] > 0) {
                        g_RazvozOrderList[playerid][g_RazvozOrderListCount[playerid]++] = i;
                    }
                }
                new idxCount = g_RazvozOrderListCount[playerid];
                for(new i = 0; i < idxCount-1; i++) {
                    for(new j = i+1; j < idxCount; j++) {
                        if(g_RazvozOrders[g_RazvozOrderList[playerid][i]][rzPrice] < g_RazvozOrders[g_RazvozOrderList[playerid][j]][rzPrice]) {
                            new tmp = g_RazvozOrderList[playerid][i];
                            g_RazvozOrderList[playerid][i] = g_RazvozOrderList[playerid][j];
                            g_RazvozOrderList[playerid][j] = tmp;
                        }
                    }
                }
                new dialogStr[2048];
                format(dialogStr, sizeof(dialogStr), "Название\tТребуется\tЦена за ед.\n");
                for(new i = 0; i < idxCount; i++) {
                    new idx = g_RazvozOrderList[playerid][i];
                    new line[128];
                    format(line, sizeof(line), "%s\t%d ед.\t%d руб.\n",
                        g_RazvozOrders[idx][rzName], g_RazvozOrders[idx][rzRequired], g_RazvozOrders[idx][rzPrice]);
                    strcat(dialogStr, line);
                }
                ShowPlayerDialogEx(playerid, RAZVOZ_DIALOG_ORDERS, DIALOG_STYLE_TABLIST_HEADERS,
                    "Доступные заказы (топливо)", dialogStr, "Выбрать", "Закрыть");
                return 1;
            }
            case 3: {
                Razvoz_ShowInfo(playerid);
                return 1;
            }
        }
    }
    return 1;
}

case RAZVOZ_DIALOG_ORDERS:
{
    if(!response) {
        CEFChat_Send(playerid, "AAAAAA", "Вы закрыли список заказов.");
        return 1;
    }
    new idxCount = g_RazvozOrderListCount[playerid];
    if(listitem < 0 || listitem >= idxCount) {
        CEFChat_Send(playerid, "FF4444", "Неверный выбор.");
        return 1;
    }
    new idx = g_RazvozOrderList[playerid][listitem];
    if(idx < 0 || idx >= g_RazvozOrderCount || !g_RazvozOrders[idx][rzActive]) {
        CEFChat_Send(playerid, "FF4444", "Этот заказ уже недоступен.");
        return 1;
    }
    Razvoz_DisableCheckpoint(playerid);
    g_RazvozSelectedOrder[playerid] = idx;
    Razvoz_SetCheckpoint(playerid,
        g_RazvozOrders[idx][rzX], g_RazvozOrders[idx][rzY], g_RazvozOrders[idx][rzZ],
        Float:RAZVOZ_ORDER_RADIUS);
    new msg[128];
    format(msg, sizeof(msg), "Вы выбрали заказ: %s", g_RazvozOrders[idx][rzName]);
    CEFChat_Send(playerid, "54B367", msg);
    CEFChat_Send(playerid, "AAAAAA", "Везите груз к точке заказа (жёлтая метка). Если груза нет – загрузитесь на соответствующем складе.");
    return 1;
}

case RAZVOZ_DIALOG_CONFIRM_LOAD:
{
    if(!response) {
        CEFChat_Send(playerid, "AAAAAA", "Закупка отменена.");
        DeletePVar(playerid, "RazvozLoadAmount");
        DeletePVar(playerid, "RazvozLoadCost");
        return 1;
    }
    new amount = GetPVarInt(playerid, "RazvozLoadAmount");
    new cost = GetPVarInt(playerid, "RazvozLoadCost");
    if(amount <= 0 || cost <= 0) {
        CEFChat_Send(playerid, "FF4444", "Ошибка: данные не найдены.");
        return 1;
    }
    if(!Razvoz_IsAtLoadPointGoods(playerid)) {
        CEFChat_Send(playerid, "FF4444", "Вы отошли от точки загрузки!");
        DeletePVar(playerid, "RazvozLoadAmount");
        DeletePVar(playerid, "RazvozLoadCost");
        return 1;
    }
    if(PI[playerid][pCash] < cost) {
        CEFChat_Send(playerid, "FF4444", "У вас недостаточно денег!");
        DeletePVar(playerid, "RazvozLoadAmount");
        DeletePVar(playerid, "RazvozLoadCost");
        return 1;
    }
    PI[playerid][pCash] -= cost;
    GivePlayerMoney(playerid, -cost);
    UpdatePlayerHUD(playerid);
    new query[128];
    mysql_format(dbHandle, query, sizeof(query), "UPDATE `accounts` SET `cash`=%d WHERE `id`=%d", PI[playerid][pCash], PI[playerid][pID]);
    mysql_tquery(dbHandle, query, "", "");

    g_RazvozLoaded[playerid] += amount;
    g_RazvozLoadedType[playerid] = 0;
    new msg[64];
    format(msg, sizeof(msg), "Вы загрузили %d единиц товаров. Загружено %d/%d.", amount, g_RazvozLoaded[playerid], Razvoz_GetMaxLoad(playerid));
    CEFChat_Send(playerid, "54B367", msg);

    if(g_RazvozSelectedOrder[playerid] != -1) {
        new idx = g_RazvozSelectedOrder[playerid];
        if(idx >= 0 && idx < g_RazvozOrderCount && g_RazvozOrders[idx][rzActive]) {
            Razvoz_DisableCheckpoint(playerid);
            Razvoz_SetCheckpoint(playerid,
                g_RazvozOrders[idx][rzX], g_RazvozOrders[idx][rzY], g_RazvozOrders[idx][rzZ],
                Float:RAZVOZ_ORDER_RADIUS);
            CEFChat_Send(playerid, "AAAAAA", "Теперь везите груз к бизнесу (жёлтая метка).");
        }
    }
    DeletePVar(playerid, "RazvozLoadAmount");
    DeletePVar(playerid, "RazvozLoadCost");
    return 1;
}

case RAZVOZ_DIALOG_CONFIRM_UNLOAD:
{
    if(!response) {
        CEFChat_Send(playerid, "AAAAAA", "Продажа отменена.");
        DeletePVar(playerid, "RazvozUnloadAmount");
        DeletePVar(playerid, "RazvozUnloadReward");
        DeletePVar(playerid, "RazvozUnloadOrderIdx");
        return 1;
    }
    new amount = GetPVarInt(playerid, "RazvozUnloadAmount");
    new reward = GetPVarInt(playerid, "RazvozUnloadReward");
    new idx = GetPVarInt(playerid, "RazvozUnloadOrderIdx");
    if(amount <= 0 || reward <= 0 || idx < 0 || idx >= g_RazvozOrderCount) {
        CEFChat_Send(playerid, "FF4444", "Ошибка: данные не найдены.");
        return 1;
    }
    if(!g_RazvozOrders[idx][rzActive]) {
        CEFChat_Send(playerid, "FF4444", "Заказ неактивен.");
        DeletePVar(playerid, "RazvozUnloadAmount");
        DeletePVar(playerid, "RazvozUnloadReward");
        DeletePVar(playerid, "RazvozUnloadOrderIdx");
        return 1;
    }
    if(!Razvoz_IsAtOrderPoint(playerid, idx)) {
        CEFChat_Send(playerid, "FF4444", "Вы отошли от точки заказа!");
        DeletePVar(playerid, "RazvozUnloadAmount");
        DeletePVar(playerid, "RazvozUnloadReward");
        DeletePVar(playerid, "RazvozUnloadOrderIdx");
        return 1;
    }
    if(amount > g_RazvozOrders[idx][rzRequired]) amount = g_RazvozOrders[idx][rzRequired];
    if(amount > g_RazvozLoaded[playerid]) amount = g_RazvozLoaded[playerid];
    if(amount <= 0) {
        CEFChat_Send(playerid, "FF4444", "Нет груза для продажи или заказ выполнен.");
        DeletePVar(playerid, "RazvozUnloadAmount");
        DeletePVar(playerid, "RazvozUnloadReward");
        DeletePVar(playerid, "RazvozUnloadOrderIdx");
        return 1;
    }
    reward = amount * g_RazvozOrders[idx][rzPrice];

    PI[playerid][pCash] += reward;
    GivePlayerMoney(playerid, reward);
    UpdatePlayerHUD(playerid);
    new query[128];
    mysql_format(dbHandle, query, sizeof(query), "UPDATE `accounts` SET `cash`=%d WHERE `id`=%d", PI[playerid][pCash], PI[playerid][pID]);
    mysql_tquery(dbHandle, query, "", "");

    g_RazvozOrders[idx][rzRequired] -= amount;
    if(g_RazvozOrders[idx][rzRequired] <= 0) {
        g_RazvozOrders[idx][rzActive] = false;
        if(g_RazvozOrders[idx][rzArea] != -1) {
            DestroyDynamicArea(g_RazvozOrders[idx][rzArea]);
            g_RazvozOrders[idx][rzArea] = -1;
        }
        if(g_RazvozOrders[idx][rzMapIcon] != -1) {
            DestroyDynamicMapIcon(g_RazvozOrders[idx][rzMapIcon]);
            g_RazvozOrders[idx][rzMapIcon] = -1;
        }
        new query2[128];
        mysql_format(dbHandle, query2, sizeof(query2), "UPDATE `razvoz_orders` SET `active`=0 WHERE `id`=%d", g_RazvozOrders[idx][rzID]);
        mysql_tquery(dbHandle, query2, "", "");
        CEFChat_Send(playerid, "54B367", "Заказ полностью выполнен! Спасибо.");
        g_RazvozSelectedOrder[playerid] = -1;
        Razvoz_DisableCheckpoint(playerid);

        Skill_AddProgress(playerid, SKILL_RAZVOZ, 1);
        new workType = Razvoz_GetType(playerid);
        if(workType == 1) Razvoz_SetCheckpoint(playerid, Float:RAZVOZ_LOAD_GOODS_X, Float:RAZVOZ_LOAD_GOODS_Y, Float:RAZVOZ_LOAD_GOODS_Z, Float:RAZVOZ_LOAD_RADIUS);
        else if(workType == 2) Razvoz_SetCheckpoint(playerid, Float:RAZVOZ_LOAD_FUEL_X, Float:RAZVOZ_LOAD_FUEL_Y, Float:RAZVOZ_LOAD_FUEL_Z, Float:RAZVOZ_LOAD_RADIUS);
        CEFChat_Send(playerid, "AAAAAA", "Вернитесь на склад для новой загрузки (красная метка).");
    } else {
        new query2[128];
        mysql_format(dbHandle, query2, sizeof(query2), "UPDATE `razvoz_orders` SET `required`=%d WHERE `id`=%d",
            g_RazvozOrders[idx][rzRequired], g_RazvozOrders[idx][rzID]);
        mysql_tquery(dbHandle, query2, "", "");
    }
    g_RazvozLoaded[playerid] -= amount;
    new msg[128];
    format(msg, sizeof(msg), "Вы продали %d ед., получили %d руб. Осталось загружено %d/%d.",
        amount, reward, g_RazvozLoaded[playerid], Razvoz_GetMaxLoad(playerid));
    CEFChat_Send(playerid, "54B367", msg);

    DeletePVar(playerid, "RazvozUnloadAmount");
    DeletePVar(playerid, "RazvozUnloadReward");
    DeletePVar(playerid, "RazvozUnloadOrderIdx");
    return 1;
}

case RAZVOZ_DIALOG_CONFIRM_LOAD_FUEL:
{
    if(!response) {
        CEFChat_Send(playerid, "AAAAAA", "Закупка топлива отменена.");
        DeletePVar(playerid, "RazvozFuelLoadAmount");
        DeletePVar(playerid, "RazvozFuelLoadCost");
        return 1;
    }
    new amount = GetPVarInt(playerid, "RazvozFuelLoadAmount");
    new cost = GetPVarInt(playerid, "RazvozFuelLoadCost");
    if(amount <= 0 || cost <= 0) {
        CEFChat_Send(playerid, "FF4444", "Ошибка: данные не найдены.");
        return 1;
    }
    if(!Razvoz_IsAtLoadPointFuel(playerid)) {
        CEFChat_Send(playerid, "FF4444", "Вы отошли от точки загрузки!");
        DeletePVar(playerid, "RazvozFuelLoadAmount");
        DeletePVar(playerid, "RazvozFuelLoadCost");
        return 1;
    }
    if(PI[playerid][pCash] < cost) {
        CEFChat_Send(playerid, "FF4444", "У вас недостаточно денег!");
        DeletePVar(playerid, "RazvozFuelLoadAmount");
        DeletePVar(playerid, "RazvozFuelLoadCost");
        return 1;
    }
    PI[playerid][pCash] -= cost;
    GivePlayerMoney(playerid, -cost);
    UpdatePlayerHUD(playerid);
    new query[128];
    mysql_format(dbHandle, query, sizeof(query), "UPDATE `accounts` SET `cash`=%d WHERE `id`=%d", PI[playerid][pCash], PI[playerid][pID]);
    mysql_tquery(dbHandle, query, "", "");

    g_RazvozLoaded[playerid] += amount;
    g_RazvozLoadedType[playerid] = 3;
    new msg[64];
    format(msg, sizeof(msg), "Вы загрузили %d единиц топлива. Загружено %d/%d.", amount, g_RazvozLoaded[playerid], Razvoz_GetMaxLoad(playerid));
    CEFChat_Send(playerid, "54B367", msg);

    if(g_RazvozSelectedOrder[playerid] != -1) {
        new idx = g_RazvozSelectedOrder[playerid];
        if(idx >= 0 && idx < g_RazvozOrderCount && g_RazvozOrders[idx][rzActive]) {
            Razvoz_DisableCheckpoint(playerid);
            Razvoz_SetCheckpoint(playerid,
                g_RazvozOrders[idx][rzX], g_RazvozOrders[idx][rzY], g_RazvozOrders[idx][rzZ],
                Float:RAZVOZ_ORDER_RADIUS);
            CEFChat_Send(playerid, "AAAAAA", "Теперь везите топливо к АЗС (жёлтая метка).");
        }
    }
    DeletePVar(playerid, "RazvozFuelLoadAmount");
    DeletePVar(playerid, "RazvozFuelLoadCost");
    return 1;
}

case RAZVOZ_DIALOG_CONFIRM_LOAD_WOOD:
{
    if(!response) {
        CEFChat_Send(playerid, "AAAAAA", "Закупка древесины отменена.");
        DeletePVar(playerid, "RazvozWoodLoadAmount");
        DeletePVar(playerid, "RazvozWoodLoadCost");
        return 1;
    }
    new amount = GetPVarInt(playerid, "RazvozWoodLoadAmount");
    new cost = GetPVarInt(playerid, "RazvozWoodLoadCost");
    if(amount <= 0 || cost <= 0) {
        CEFChat_Send(playerid, "FF4444", "Ошибка: данные не найдены.");
        return 1;
    }
    if(!Razvoz_IsAtLoadPointWood(playerid)) {
        CEFChat_Send(playerid, "FF4444", "Вы отошли от точки загрузки!");
        DeletePVar(playerid, "RazvozWoodLoadAmount");
        DeletePVar(playerid, "RazvozWoodLoadCost");
        return 1;
    }
    if(PI[playerid][pCash] < cost) {
        CEFChat_Send(playerid, "FF4444", "У вас недостаточно денег!");
        DeletePVar(playerid, "RazvozWoodLoadAmount");
        DeletePVar(playerid, "RazvozWoodLoadCost");
        return 1;
    }
    PI[playerid][pCash] -= cost;
    GivePlayerMoney(playerid, -cost);
    UpdatePlayerHUD(playerid);
    new query[128];
    mysql_format(dbHandle, query, sizeof(query), "UPDATE `accounts` SET `cash`=%d WHERE `id`=%d", PI[playerid][pCash], PI[playerid][pID]);
    mysql_tquery(dbHandle, query, "", "");

    g_RazvozWoodLoaded[playerid] += amount;
    g_RazvozLoadedType[playerid] = 1;
    new total = g_RazvozWoodLoaded[playerid] + g_RazvozMetalLoaded[playerid];
    new msg[64];
    format(msg, sizeof(msg), "Вы загрузили %d кг древесины. Всего сырья: %d/%d.", amount, total, RAZVOZ_MAX_WOOD_METAL_LOAD);
    CEFChat_Send(playerid, "54B367", msg);
    Razvoz_DisableCheckpoint(playerid);
    Razvoz_SetCheckpoint(playerid, Float:RAZVOZ_UNLOAD_FACTORY_X, Float:RAZVOZ_UNLOAD_FACTORY_Y, Float:RAZVOZ_UNLOAD_FACTORY_Z, Float:RAZVOZ_LOAD_RADIUS);
    CEFChat_Send(playerid, "AAAAAA", "Везите древесину на завод (красная метка).");

    DeletePVar(playerid, "RazvozWoodLoadAmount");
    DeletePVar(playerid, "RazvozWoodLoadCost");
    return 1;
}

case RAZVOZ_DIALOG_CONFIRM_LOAD_METAL:
{
    if(!response) {
        CEFChat_Send(playerid, "AAAAAA", "Закупка металла отменена.");
        DeletePVar(playerid, "RazvozMetalLoadAmount");
        DeletePVar(playerid, "RazvozMetalLoadCost");
        return 1;
    }
    new amount = GetPVarInt(playerid, "RazvozMetalLoadAmount");
    new cost = GetPVarInt(playerid, "RazvozMetalLoadCost");
    if(amount <= 0 || cost <= 0) {
        CEFChat_Send(playerid, "FF4444", "Ошибка: данные не найдены.");
        return 1;
    }
    if(!Razvoz_IsAtLoadPointMetal(playerid)) {
        CEFChat_Send(playerid, "FF4444", "Вы отошли от точки загрузки!");
        DeletePVar(playerid, "RazvozMetalLoadAmount");
        DeletePVar(playerid, "RazvozMetalLoadCost");
        return 1;
    }
    if(PI[playerid][pCash] < cost) {
        CEFChat_Send(playerid, "FF4444", "У вас недостаточно денег!");
        DeletePVar(playerid, "RazvozMetalLoadAmount");
        DeletePVar(playerid, "RazvozMetalLoadCost");
        return 1;
    }
    PI[playerid][pCash] -= cost;
    GivePlayerMoney(playerid, -cost);
    UpdatePlayerHUD(playerid);
    new query[128];
    mysql_format(dbHandle, query, sizeof(query), "UPDATE `accounts` SET `cash`=%d WHERE `id`=%d", PI[playerid][pCash], PI[playerid][pID]);
    mysql_tquery(dbHandle, query, "", "");

    g_RazvozMetalLoaded[playerid] += amount;
    g_RazvozLoadedType[playerid] = 2;
    new total = g_RazvozWoodLoaded[playerid] + g_RazvozMetalLoaded[playerid];
    new msg[64];
    format(msg, sizeof(msg), "Вы загрузили %d кг металла. Всего сырья: %d/%d.", amount, total, RAZVOZ_MAX_WOOD_METAL_LOAD);
    CEFChat_Send(playerid, "54B367", msg);
    Razvoz_DisableCheckpoint(playerid);
    Razvoz_SetCheckpoint(playerid, Float:RAZVOZ_UNLOAD_FACTORY_X, Float:RAZVOZ_UNLOAD_FACTORY_Y, Float:RAZVOZ_UNLOAD_FACTORY_Z, Float:RAZVOZ_LOAD_RADIUS);
    CEFChat_Send(playerid, "AAAAAA", "Везите металл на завод (красная метка).");

    DeletePVar(playerid, "RazvozMetalLoadAmount");
    DeletePVar(playerid, "RazvozMetalLoadCost");
    return 1;
}

case RAZVOZ_DIALOG_CONFIRM_UNLOAD_WOODMETAL:
{
    if(!response) {
        CEFChat_Send(playerid, "AAAAAA", "Продажа отменена.");
        DeletePVar(playerid, "RazvozUnloadWoodAmount");
        DeletePVar(playerid, "RazvozUnloadMetalAmount");
        DeletePVar(playerid, "RazvozUnloadReward");
        return 1;
    }
    new woodAmount = GetPVarInt(playerid, "RazvozUnloadWoodAmount");
    new metalAmount = GetPVarInt(playerid, "RazvozUnloadMetalAmount");
    new reward = GetPVarInt(playerid, "RazvozUnloadReward");
    if((woodAmount + metalAmount) <= 0 || reward <= 0) {
        CEFChat_Send(playerid, "FF4444", "Ошибка: данные не найдены.");
        return 1;
    }
    if(!Razvoz_IsAtFactoryUnload(playerid)) {
        CEFChat_Send(playerid, "FF4444", "Вы отошли от точки разгрузки!");
        DeletePVar(playerid, "RazvozUnloadWoodAmount");
        DeletePVar(playerid, "RazvozUnloadMetalAmount");
        DeletePVar(playerid, "RazvozUnloadReward");
        return 1;
    }
    if(g_RazvozWoodLoaded[playerid] < woodAmount) woodAmount = g_RazvozWoodLoaded[playerid];
    if(g_RazvozMetalLoaded[playerid] < metalAmount) metalAmount = g_RazvozMetalLoaded[playerid];
    if(woodAmount + metalAmount <= 0) {
        CEFChat_Send(playerid, "FF4444", "Нет сырья для разгрузки.");
        DeletePVar(playerid, "RazvozUnloadWoodAmount");
        DeletePVar(playerid, "RazvozUnloadMetalAmount");
        DeletePVar(playerid, "RazvozUnloadReward");
        return 1;
    }
    reward = woodAmount * RAZVOZ_PRICE_WOOD_SELL + metalAmount * RAZVOZ_PRICE_METAL_SELL;

    #if defined _factory_inc
        if(woodAmount > 0) g_FactoryWood += woodAmount;
        if(metalAmount > 0) g_FactoryMetal += metalAmount;
        SaveFactoryStorage();
        UpdateStorageLabel();
    #endif

    PI[playerid][pCash] += reward;
    GivePlayerMoney(playerid, reward);
    UpdatePlayerHUD(playerid);
    new query[128];
    mysql_format(dbHandle, query, sizeof(query), "UPDATE `accounts` SET `cash`=%d WHERE `id`=%d", PI[playerid][pCash], PI[playerid][pID]);
    mysql_tquery(dbHandle, query, "", "");

    g_RazvozWoodLoaded[playerid] -= woodAmount;
    g_RazvozMetalLoaded[playerid] -= metalAmount;
    if(g_RazvozWoodLoaded[playerid] == 0 && g_RazvozMetalLoaded[playerid] == 0) g_RazvozLoadedType[playerid] = 0;
    new total = g_RazvozWoodLoaded[playerid] + g_RazvozMetalLoaded[playerid];
    new msg[128];
    format(msg, sizeof(msg), "Вы разгрузили %d кг сырья (древесина: %d, металл: %d), получили %d руб. Осталось: %d кг.",
        woodAmount + metalAmount, woodAmount, metalAmount, reward, total);
    CEFChat_Send(playerid, "54B367", msg);
    Razvoz_DisableCheckpoint(playerid);
    Razvoz_SetCheckpoint(playerid, Float:RAZVOZ_LOAD_WOOD_X, Float:RAZVOZ_LOAD_WOOD_Y, Float:RAZVOZ_LOAD_WOOD_Z, Float:RAZVOZ_LOAD_RADIUS);
    CEFChat_Send(playerid, "AAAAAA", "Вернитесь на склад для новой загрузки (красная метка).");

    DeletePVar(playerid, "RazvozUnloadWoodAmount");
    DeletePVar(playerid, "RazvozUnloadMetalAmount");
    DeletePVar(playerid, "RazvozUnloadReward");
    return 1;
}

case RAZVOZ_DIALOG_INFO:
{
    return 1;
}
