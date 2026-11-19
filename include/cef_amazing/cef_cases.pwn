#if defined _cef_cases_included
    #endinput
#endif
#define _cef_cases_included



















#define CEF_CASES_MAX 20

enum E_CEF_CASE
{
    ccType,
    ccPrizes,
    ccPrice,
    ccName[40]
};

static const gCefCases[CEF_CASES_MAX][E_CEF_CASE] = {
    {126, 14, 250000, "Кладоискатель"},
    {128, 17, 400000, "Гонщик"},
    {155, 15, 300000, "Новогодний"},
    {160, 12, 200000, "Боевой"},
    {162, 15, 300000, "Майский"},
    {163, 13, 350000, "Amazing I"},
    {206, 18, 450000, "Сталкер"},
    {210, 13, 350000, "Amazing II"},
    {230, 15, 300000, "Хэллоуин"},
    {231, 14, 300000, "Новогодний 2024"},
    {232, 10, 150000, "Анимации I"},
    {238, 17, 450000, "Сталкер II"},
    {240, 10, 150000, "Анимации II"},
    {241, 15, 350000, "Кошмар"},
    {243, 11, 900000, "Porsche 911"},
    {244, 15, 300000, "Новогодний 2025"},
    {248, 12, 500000, "Desert Eagle"},
    {249, 11, 900000, "190E Evo II"},
    {251, 10, 999000, "Staff"},
    {253, 10, 150000, "Анимации III"}
};

new gCefCaseCount[MAX_PLAYERS][CEF_CASES_MAX];


stock CEF_CaseTypeByIndex(idx)
{
    if(idx < 0 || idx >= CEF_CASES_MAX) return 0;
    return gCefCases[idx][ccType];
}

stock CEF_CaseNameByIndex(idx, dest[], size)
{
    if(idx < 0 || idx >= CEF_CASES_MAX) { dest[0] = EOS; return 0; }
    format(dest, size, "%s", gCefCases[idx][ccName]);
    return 1;
}

stock CEF_CaseCountOf(playerid, idx)
{
    if(idx < 0 || idx >= CEF_CASES_MAX) return 0;
    return gCefCaseCount[playerid][idx];
}

stock CEF_CaseIndex(caseType)
{
    for(new i = 0; i < CEF_CASES_MAX; i++) if(gCefCases[i][ccType] == caseType) return i;
    return -1;
}

stock CEF_CasePriceByType(caseType)
{
    new idx = CEF_CaseIndex(caseType);
    if(idx < 0) return 0;
    return gCefCases[idx][ccPrice];
}


stock CEF_CaseName(caseType, dest[], size)
{
    new idx = CEF_CaseIndex(caseType);
    if(idx < 0) format(dest, size, "Кейс #%d", caseType);
    else format(dest, size, "%s", gCefCases[idx][ccName]);
    return 1;
}




stock CEF_CasesInit()
{
    new q[400];
    format(q, sizeof q, "CREATE TABLE IF NOT EXISTS `player_cases` (`owner_id` INT NOT NULL, `case_type` INT NOT NULL, `amount` INT NOT NULL DEFAULT 0, PRIMARY KEY(`owner_id`,`case_type`)) DEFAULT CHARSET=utf8");
    mysql_tquery(dbHandle, q);
    print("[CEF-CASES] таблица player_cases готова");
    return 1;
}

forward OnCefCasesLoaded(playerid);
public OnCefCasesLoaded(playerid)
{
    new rows = cache_num_rows(), type, amount, idx;
    if(!IsPlayerConnected(playerid)) return 0;
    for(new i = 0; i < CEF_CASES_MAX; i++) gCefCaseCount[playerid][i] = 0;
    for(new i = 0; i < rows; i++)
    {
        cache_get_value_name_int(i, "case_type", type);
        cache_get_value_name_int(i, "amount", amount);
        idx = CEF_CaseIndex(type);
        if(idx >= 0) gCefCaseCount[playerid][idx] = amount;
    }
    return 1;
}

stock CEF_CasesLoad(playerid)
{
    new q[160];
    mysql_format(dbHandle, q, sizeof q, "SELECT * FROM `player_cases` WHERE `owner_id`=%d", PI[playerid][pID]);
    mysql_tquery(dbHandle, q, "OnCefCasesLoaded", "d", playerid);
    return 1;
}

stock CEF_CaseSave(playerid, idx)
{
    new q[220];
    if(PI[playerid][pID] <= 0 || idx < 0) return 0;
    mysql_format(dbHandle, q, sizeof q,
        "INSERT INTO `player_cases` (`owner_id`,`case_type`,`amount`) VALUES (%d,%d,%d) ON DUPLICATE KEY UPDATE `amount`=%d",
        PI[playerid][pID], gCefCases[idx][ccType], gCefCaseCount[playerid][idx], gCefCaseCount[playerid][idx]);
    mysql_tquery(dbHandle, q);
    return 1;
}

stock CEF_CaseGive(playerid, caseType, amount = 1)
{
    new idx = CEF_CaseIndex(caseType), msg[128], name[40];
    if(idx < 0) return 0;
    gCefCaseCount[playerid][idx] += amount;
    CEF_CaseSave(playerid, idx);
    CEF_CaseName(caseType, name, sizeof name);
    format(msg, sizeof msg, "Получен кейс «%s» (%d шт.)", name, gCefCaseCount[playerid][idx]);
    CEFC_Notify(playerid, msg, "success");
    return 1;
}

stock CEF_CaseTake(playerid, caseType, amount)
{
    new idx = CEF_CaseIndex(caseType);
    if(idx < 0) return 0;
    if(amount < 1) amount = 1;
    gCefCaseCount[playerid][idx] -= amount;
    if(gCefCaseCount[playerid][idx] < 0) gCefCaseCount[playerid][idx] = 0;
    CEF_CaseSave(playerid, idx);
    return 1;
}




stock CEF_CaseCloseUi(playerid)
{
    CEF_SendEmpty(playerid, "cef_cases_close");
    gCefCaseActive[playerid] = 0;
    gCefCasePending[playerid] = 0;
    CEF_Focus(playerid, true);
    if(!gCefMenuOpen[playerid])
    {
        CEF_Focus(playerid, false);
        TogglePlayerControllable(playerid, 1);
        CEFC_MenuCamera(playerid, false);
    }
    return 1;
}

stock CEF_CaseOpenWindow(playerid, caseType)
{
    new idx = CEF_CaseIndex(caseType);
    if(idx < 0) return CEFC_Notify(playerid, "Такого кейса нет.", "error");
    if(gCefCaseCount[playerid][idx] <= 0)
        return CEFC_Notify(playerid, "У вас нет такого кейса. Купить: /buycase", "error");
    static json[96];
    format(json, sizeof json, "{\"caseType\":%d,\"amount\":%d}", caseType, gCefCaseCount[playerid][idx]);
    gCefCaseActive[playerid] = caseType;
    gCefCasePending[playerid] = 0;
    CEF_MarkPlayerReady(playerid);
    CEF_InvSync(playerid);
    CEF_Send(playerid, "cef_cases_open", json);
    CEF_Focus(playerid, true);
    cef_always_listen_keys(playerid, MAIN_BROWSER, true);
    TogglePlayerControllable(playerid, 0);

    printf("[CEF-CASE] open %d type=%d amount=%d", playerid, caseType, gCefCaseCount[playerid][idx]);
    return 1;
}


stock CEF_InvFirstCase(playerid)
{
    for(new i = 0; i < CEF_CASES_MAX; i++)
        if(gCefCaseCount[playerid][i] > 0) return gCefCases[i][ccType];
    return 0;
}

stock CEF_InvRmb(playerid)
{
    new t;
    if(!IsPlayerConnected(playerid) || !gCefMenuOpen[playerid]) return 0;
    t = gCefInvHover[playerid];
    if(t <= 0 && gCefInvType[playerid][6] > 0) t = gCefInvType[playerid][6];
    if(t <= 0) t = CEF_InvFirstCase(playerid);
    printf("[CEF-INV] rmb-key %d type=%d hover=%d", playerid, t, gCefInvHover[playerid]);
    if(t <= 0) return 0;
    if(CEF_CaseIndex(t) >= 0) return CEF_CaseOpenWindow(playerid, t);
    return CEF_OpsInvUse(playerid, t);
}

stock CEF_CasePrizeReward(playerid, idx, prizeId)
{
    new reward = gCefCases[idx][ccPrice], msg[144], name[40];
    if(prizeId <= 1)      reward = gCefCases[idx][ccPrice] * 5;
    else if(prizeId <= 3) reward = gCefCases[idx][ccPrice] * 2;
    else if(prizeId <= 6) reward = gCefCases[idx][ccPrice];
    else                  reward = gCefCases[idx][ccPrice] / 2;

    PI[playerid][pBank] += reward;
    CEF_EcoSaveMoney(playerid);
    CEF_CaseName(gCefCases[idx][ccType], name, sizeof name);
    format(msg, sizeof msg, "Кейс «%s»: приз №%d, начислено %d руб. на счёт.", name, prizeId, reward);
    CEFC_Notify(playerid, msg, "congratulate", 7000);
    CEFC_AccountStats(playerid);
    CEFC_HudUpdate(playerid);
    return reward;
}



stock CEF_CasesRpc(playerid, const arguments[], dest[], size)
{
    new key = CEF_EcoFindInt(arguments, "key");
    new caseType = CEF_EcoFindInt(arguments, "caseType");
    new idx, prizeId;

    format(dest, size, "null");
    if(key == 1)
    {
        CEF_CaseCloseUi(playerid);
        return 1;
    }
    if(key != 2) return 1;

    if(!caseType) caseType = gCefCaseActive[playerid];
    idx = CEF_CaseIndex(caseType);
    if(idx < 0) return CEFC_Notify(playerid, "Неизвестный кейс.", "error");
    if(gCefCaseCount[playerid][idx] <= 0)
        return CEFC_Notify(playerid, "Кейсы этого типа закончились.", "error");

    gCefCaseCount[playerid][idx]--;
    CEF_CaseSave(playerid, idx);

    prizeId = 1 + random(gCefCases[idx][ccPrizes]);
    CEF_CasePrizeReward(playerid, idx, prizeId);

    format(dest, size, "%d", prizeId);
    {
        static upd[96];
        format(upd, sizeof upd, "{\"caseType\":%d,\"amount\":%d}", caseType, gCefCaseCount[playerid][idx]);
        CEF_Send(playerid, "cef_cases_open", upd);
    }
    return 1;
}




stock CEF_CasesInventoryJson(playerid, dest[], size, startSlot, bool:needComma)
{
    static part[180];
    new slot = startSlot, bool:comma = needComma;
    dest[0] = EOS;
    for(new i = 0; i < CEF_CASES_MAX; i++)
    {
        if(gCefCaseCount[playerid][i] <= 0) continue;
        format(part, sizeof part, "%s{\"slotId\":%d,\"type\":%d,\"value\":%d,\"extraValue\":0}",
            comma ? (",") : (""), slot, gCefCases[i][ccType], gCefCaseCount[playerid][i]);
        if(strlen(dest) + strlen(part) >= size - 2) break;
        strcat(dest, part, size);
        CEF_InvRemember(playerid, slot, gCefCases[i][ccType]);
        comma = true;
        slot++;
    }
    return slot;
}




CMD:cases(playerid, params[])
{
    #pragma unused params
    static list[900], part[96], title[32], b1[16], b2[16];
    new have = 0;
    list[0] = EOS;
    for(new i = 0; i < CEF_CASES_MAX; i++)
    {
        if(gCefCaseCount[playerid][i] <= 0) continue;
        format(part, sizeof part, "%s - %d шт.\n", gCefCases[i][ccName], gCefCaseCount[playerid][i]);
        strcat(list, part);
        have++;
    }
    if(!have) return CEFC_Notify(playerid, "У вас нет кейсов. Купить: /buycase", "hint");
    title = "Ваши кейсы";
    b1 = "Открыть";
    b2 = "Отмена";
    ShowPlayerDialogEx(playerid, DIALOG_CEF_CASES, DIALOG_STYLE_LIST, title, list, b1, b2);
    return 1;
}

CMD:buycase(playerid, params[])
{
    static list[1200], part[96], title[32], b1[16], b2[16];
    new spec[] = "d", type;
    if(sscanf(params, spec, type))
    {
        list[0] = EOS;
        for(new i = 0; i < CEF_CASES_MAX; i++)
        {
            format(part, sizeof part, "%s - %d руб.\n", gCefCases[i][ccName], gCefCases[i][ccPrice]);
            strcat(list, part);
        }
        title = "Покупка кейса";
        b1 = "Купить";
        b2 = "Отмена";
        ShowPlayerDialogEx(playerid, DIALOG_CEF_CASES_BUY, DIALOG_STYLE_LIST, title, list, b1, b2);
        return 1;
    }
    new idx = CEF_CaseIndex(type);
    if(idx < 0) return CEFC_Notify(playerid, "Такого кейса нет.", "error");
    if(!CEF_EcoPay(playerid, gCefCases[idx][ccPrice])) return CEFC_Notify(playerid, "Недостаточно средств.", "error");
    CEF_CaseGive(playerid, type, 1);
    CEFC_HudUpdate(playerid);
    return 1;
}

CMD:givecase(playerid, params[])
{
    new target, num, amount, idx, i, msg[144], err[80];
    amount = 1;
    if(PI[playerid][pAdmin] < 3)
    {
        err = "Нужен админ 3+";
        return SendErr(playerid, err);
    }
    if(params[0] == EOS || sscanf(params, "udD(1)", target, num, amount))
    {
        SendClientMessage(playerid, 0x54B367FF, "/givecase [игрок] [номер] [кол-во]  — список кейсов:");
        for(i = 0; i < CEF_CASES_MAX; i++)
        {
            format(msg, sizeof msg, "  %d. %s", i + 1, gCefCases[i][ccName]);
            SendClientMessage(playerid, 0xCCCCCCFF, msg);
        }
        return 1;
    }
    if(!IsPlayerConnected(target) || !PT[target][pLogged])
    {
        err = "Игрок не найден.";
        return SendErr(playerid, err);
    }
    if(amount < 1) amount = 1;
    idx = -1;
    if(num >= 1 && num <= CEF_CASES_MAX) idx = num - 1;
    else idx = CEF_CaseIndex(num);
    if(idx < 0)
    {
        err = "Нет такого кейса. Напиши /givecase — там список.";
        return SendErr(playerid, err);
    }
    CEF_CaseGive(target, gCefCases[idx][ccType], amount);
    CEF_InvSync(target);
    format(msg, sizeof msg, "Выдал кейс «%s» x%d игроку %d", gCefCases[idx][ccName], amount, target);
    SendClientMessage(playerid, 0x54B367FF, msg);
    return 1;
}

CMD:giveitem(playerid, params[])
{
    new target, num, amount, itype, msg[144], err[80];
    amount = 1;
    if(PI[playerid][pAdmin] < 3)
    {
        err = "Нужен админ 3+";
        return SendErr(playerid, err);
    }
    if(params[0] == EOS || sscanf(params, "udD(1)", target, num, amount))
    {
        SendClientMessage(playerid, 0x54B367FF, "/giveitem [игрок] [номер] [кол-во]  — предметы:");
        SendClientMessage(playerid, 0xCCCCCCFF, "  1. Аптечка");
        SendClientMessage(playerid, 0xCCCCCCFF, "  2. Канистра");
        SendClientMessage(playerid, 0xCCCCCCFF, "  3. Ремкомплект");
        SendClientMessage(playerid, 0xCCCCCCFF, "  4. Еда");
        SendClientMessage(playerid, 0xCCCCCCFF, "  5. Вода");
        SendClientMessage(playerid, 0xCCCCCCFF, "  6. Бензин");
        SendClientMessage(playerid, 0xCCCCCCFF, "  7. Броня");
        SendClientMessage(playerid, 0xCCCCCCFF, "  8. Маска");
        SendClientMessage(playerid, 0xCCCCCCFF, "  9. АС Вал");
        return 1;
    }
    if(!IsPlayerConnected(target) || !PT[target][pLogged])
    {
        err = "Игрок не найден.";
        return SendErr(playerid, err);
    }
    if(amount < 1) amount = 1;
    switch(num)
    {
        case 1: itype = 8;
        case 2: itype = 6;
        case 3: itype = 7;
        case 4: itype = 10;
        case 5: itype = 11;
        case 6: itype = 9;
        case 7: itype = 12;
        case 8: itype = 13;
        case 9: itype = 533;
        default: itype = num;
    }
    if(itype == 533)
    {
        CEF_SpaOwnGive(target, 533, amount);
        CEF_ShopGiveWeapon(target, 533);
        format(msg, sizeof msg, "Выдал АС Вал x%d игроку %d", amount, target);
    }
    else if(CEF_CaseIndex(itype) >= 0)
    {
        CEF_CaseGive(target, itype, amount);
        format(msg, sizeof msg, "Выдал кейс type %d x%d игроку %d", itype, amount, target);
    }
    else
    {
        if(!GiveItem(target, itype, amount))
        {
            err = "Инвентарь полный или нет такого предмета.";
            return SendErr(playerid, err);
        }
        SavePlayerInventory(target);
        format(msg, sizeof msg, "Выдал «%s» x%d игроку %d", GetItemName(itype), amount, target);
    }
    CEF_InvSync(target);
    SendClientMessage(playerid, 0x54B367FF, msg);
    return 1;
}

CMD:giveprize(playerid, params[])
{
    new target, num, cat, msg[144], err[80], title[40];
    if(PI[playerid][pAdmin] < 3)
    {
        err = "Нужен админ 3+";
        return SendErr(playerid, err);
    }
    if(params[0] == EOS || sscanf(params, "ud", target, num))
    {
        SendClientMessage(playerid, 0x54B367FF, "/giveprize [игрок] [номер]  — в TAB -> Призы:");
        SendClientMessage(playerid, 0xCCCCCCFF, "  1. Транспорт (Infernus)");
        SendClientMessage(playerid, 0xCCCCCCFF, "  2. Аксессуары (маска)");
        SendClientMessage(playerid, 0xCCCCCCFF, "  3. Наличность 100000");
        SendClientMessage(playerid, 0xCCCCCCFF, "  4. Тюнинг транспорта");
        SendClientMessage(playerid, 0xCCCCCCFF, "  5. Статистика (+1 уровень)");
        SendClientMessage(playerid, 0xCCCCCCFF, "  6. Подписка PLUS");
        SendClientMessage(playerid, 0xCCCCCCFF, "  7. Одежда (скин)");
        SendClientMessage(playerid, 0xCCCCCCFF, "  8. Лицензии");
        SendClientMessage(playerid, 0xCCCCCCFF, "  9. Спец. очки");
        SendClientMessage(playerid, 0xCCCCCCFF, "  10. Кредиты (50 амазингов)");
        return 1;
    }
    if(!IsPlayerConnected(target) || !PT[target][pLogged])
    {
        err = "Игрок не найден.";
        return SendErr(playerid, err);
    }
    if(num < 1 || num > 10)
    {
        err = "Нет такого приза. Напиши /giveprize — там список.";
        return SendErr(playerid, err);
    }
    cat = num - 1;
    CEF_PrizeGive(target, cat, 1);
    CEF_PrizeTitle(cat, title, sizeof title);
    format(msg, sizeof msg, "Выдал приз «%s» в TAB-Призы игроку %d", title, target);
    SendClientMessage(playerid, 0x54B367FF, msg);
    format(msg, sizeof msg, "Вам выдан приз «%s». Забери: TAB -> Призы.", title);
    SendClientMessage(target, 0x54B367FF, msg);
    return 1;
}


stock CEF_CasesDialog(playerid, dialogid, response, listitem)
{
    new shown = 0;
    if(dialogid == DIALOG_CEF_CASES)
    {
        if(!response) return 1;
        for(new i = 0; i < CEF_CASES_MAX; i++)
        {
            if(gCefCaseCount[playerid][i] <= 0) continue;
            if(shown == listitem) return CEF_CaseOpenWindow(playerid, gCefCases[i][ccType]);
            shown++;
        }
        return 1;
    }
    if(dialogid == DIALOG_CEF_CASES_BUY)
    {
        if(!response) return 1;
        if(listitem < 0 || listitem >= CEF_CASES_MAX) return 1;
        if(!CEF_EcoPay(playerid, gCefCases[listitem][ccPrice]))
            return CEFC_Notify(playerid, "Недостаточно средств.", "error");
        CEF_CaseGive(playerid, gCefCases[listitem][ccType], 1);
        CEFC_HudUpdate(playerid);
        return 1;
    }
    return 0;
}
