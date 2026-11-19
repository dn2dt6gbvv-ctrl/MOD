case DIALOG_PORCH_MENU:
{
    if(!response) return 1;
    switch(listitem)
    {
        case 0:
        {
            new idx = PI[playerid][pPorchHouse];
            new total_hours = PorchHouseInfo[idx-1][hBank] / PorchHouseInfo[idx-1][hPay];
            new days = total_hours / 24;
            new hours = total_hours % 24;

            new fmt_text[350];
            format
            (
                fmt_text, sizeof fmt_text, 
                "{ffffff}Квартира оплачена на: {4F84BA}%i дн. и %i часов\n{ffffff}Почасовая плата: {90af3a}%i рублей\n\n{ffffff}На сколько часов Вы хотите оплатить квартиру?",
                days,
                hours,
                PorchHouseInfo[idx-1][hPay]
            );
            ShowPlayerDialogEx(playerid, DIALOG_PORCH_PAY, DIALOG_STYLE_INPUT, "Оплата квартиры", fmt_text, "Оплатить", "Назад"); 
        }
        case 1: ShowPlayerDialogEx(playerid, DIALOG_PORCH_SELL, DIALOG_STYLE_MSGBOX, "Продажа квартиры", "Вы уверены, что хотите продать квартиру государтсву?", "Да", "Нет");
    }
}
case DIALOG_PORCH_PAY:
{
    if(!response) return 1;

    new idx = PI[playerid][pPorchHouse];
    
    new total_hours = PorchHouseInfo[idx-1][hBank] / PorchHouseInfo[idx-1][hPay];
    new days = total_hours / 24;
    new hours = total_hours % 24;

    new fmt_text[350];
    format
    (
        fmt_text, sizeof fmt_text, 
        "{ffffff}Квартира оплачена на: {4F84BA}%i дн. и %i часов\n{ffffff}Почасовая плата: {90af3a}%i рублей\n\n{ffffff}На сколько часов Вы хотите оплатить квартиру?",
        days,
        hours,
        PorchHouseInfo[idx-1][hPay]
    );

    new pay_time;
    if(sscanf(inputtext, "p<,>d", pay_time)) 
    {
        SendErr(playerid, "Введите корректное количество часов");
        return ShowPlayerDialogEx(playerid, DIALOG_PORCH_PAY, DIALOG_STYLE_INPUT, "Оплата квартиры", fmt_text, "Оплатить", "Назад"); 
    }

    if(pay_time <= 0)
    {
        SendErr(playerid, "Введите корректное количество часов (больше 0)");
        return ShowPlayerDialogEx(playerid, DIALOG_PORCH_PAY, DIALOG_STYLE_INPUT, "Оплата квартиры", fmt_text, "Оплатить", "Назад"); 
    }

    new pay_bank = pay_time * PorchHouseInfo[idx-1][hPay];
    
    if(PI[playerid][pCash] < pay_bank)
    {
        SendErr(playerid, "У Вас недостаточно средств для оплаты аренды квартиры");
        return ShowPlayerDialogEx(playerid, DIALOG_PORCH_PAY, DIALOG_STYLE_INPUT, "Оплата квартиры", fmt_text, "Оплатить", "Назад"); 
    }
    
    new p_days = pay_time / 24;
    new p_hours = pay_time % 24;

    PorchHouseInfo[idx-1][hBank] += pay_bank;

    SCMF(playerid, COLOR_BLUE, "Вы заплатили за квартиру %i рублей. Аренда продлена на %i дн. и %i часов", pay_bank, p_days, p_hours);

    new fmt_query[128];
    mysql_format
    (
        dbHandle, fmt_query, sizeof(fmt_query), 
        "UPDATE `porch_house` SET `hBank` = %d WHERE `id` = %d",
        PorchHouseInfo[idx-1][hBank],
        idx 
    );
    mysql_tquery(dbHandle, fmt_query, "", "");  
    TransferMoney(-1, playerid, -pay_bank, "Оплата аренды квартиры"); 
    return 1;
}
case DIALOG_PORCH_SELL:
{
    if(!response) return 1;

    new idx = PI[playerid][pPorchHouse],
        money = PorchHouseInfo[idx-1][hPrice]/2;

    SCMF(playerid, 0x74353680, "Вашу квартиру №%i забрало государство по причине:собественник прекратил аренду", idx);
    SCMF(playerid, 0x74353680, "%i рублей были возвращены на Ваш банковский счет", money);

    PI[playerid][pBank] += money;

    
    PorchHouseInfo[idx-1][hLock] = 1;
    PorchHouseInfo[idx-1][hOwnerID] = 0;
    PorchHouseInfo[idx-1][hBank] = 0;
    strmid(PorchHouseInfo[idx-1][hOwner], "None", 0, strlen("None"), MAX_PLAYER_NAME);

    new fmt_query[600];
    mysql_format
    (
        dbHandle, fmt_query, sizeof(fmt_query), "UPDATE `porch_house` SET `hLock` = %d, `hOwnerID` = %d, `hBank` = %d, `hOwner` = 'None' WHERE `id` = %d",
        PorchHouseInfo[idx-1][hLock],
        PorchHouseInfo[idx-1][hOwnerID],
        PorchHouseInfo[idx-1][hBank],
        PorchHouseInfo[idx-1][hID]
    );
    mysql_tquery(dbHandle, fmt_query, "", "");   

    PI[playerid][pPorchHouse] = 0;
}
case DIALOG_BUY_PORCH_HOUSE:
{
    if(!response) return 1;

    new idx = PT[playerid][pPorchHouse];
    new money = PorchHouseInfo[idx][hPrice];
    new fmt_text[200];

    if(PI[playerid][pCash] < money) return SendErr(playerid, "У вас недодстаточно средств для аренды данной квартиры!");
    if(PorchHouseInfo[idx][hOwnerID] != 0) return SendErr(playerid, "Данная квартира занята");

    SCMF(playerid, -1 ,"check %i", idx);
    format(fmt_text, sizeof fmt_text, "Внимание! Каждый PayDay со счета квартиры будет сниматься сумма в размере: %i рублей", PorchHouseInfo[idx][hPay]);
    SendErr(playerid, fmt_text);
    SendErr(playerid, "Если на счете не будет достаточно денег, то вас выселят из квартиры");
    SendClientMessage(playerid, COLOR_UNMAZING, "Пополнить домашний счет можно в парадной у входа");

    SetPlayerPos(playerid, -1578.6465,1987.4329,2204.8342);
    SetPlayerFacingAngle(playerid,276.7006);
    SetPlayerVirtualWorld(playerid, idx);
    SetCameraBehindPlayer(playerid);

    PorchHouseInfo[idx][hOwnerID] = PI[playerid][pID];
    PI[playerid][pPorchHouse] = PorchHouseInfo[idx][hID];
    PorchHouseInfo[idx][hBank] = PorchHouseInfo[idx][hPay];
    strmid(PorchHouseInfo[idx][hOwner], PI[playerid][pName], 0, strlen(PI[playerid][pName]), MAX_PLAYER_NAME);

    new global_string[500];
    mysql_format(dbHandle, global_string, sizeof global_string, "UPDATE porch_house SET `hOwner` = '%s', `hOwnerID` = '%d', `hBank` = '%d' WHERE `id` = '%d'", GetName(playerid), PI[playerid][pID], PorchHouseInfo[idx][hBank], PorchHouseInfo[idx][hID]);
    mysql_tquery(dbHandle, global_string, "", "");

    new fmt_sql[244];
    mysql_format(dbHandle, fmt_sql, sizeof(fmt_sql), "UPDATE `accounts` SET `porch_house` = '%d' WHERE `name` = %e", PorchHouseInfo[idx][hID], GetName(playerid));
    mysql_tquery(dbHandle, fmt_sql, "", "");

    TransferMoney(-1, playerid, -money, "Аренда квартиры");
}
case DIALOG_PORCH_HOUSE_MENU:
{
    if(!response) return 1;

    new idx = PT[playerid][pPorchHouse];

    switch(listitem)
    {
        case 0:
        {
            SetPlayerPos(playerid, PorchHouseInfo[idx][hEntrx], PorchHouseInfo[idx][hEntry], PorchHouseInfo[idx][hEntrz]);
            SetPlayerFacingAngle(playerid,PorchHouseInfo[idx][hEntrFa]);
            SetPlayerVirtualWorld(playerid, PT[playerid][pPorch]);
            SetCameraBehindPlayer(playerid);
        }
        case 1:
        {
            if(PorchHouseInfo[idx][hLock] != 0) PorchHouseInfo[idx][hLock] = 0, SendClientMessage(playerid, COLOR_UNMAZING, "Вы открыли входную дверь в свою квартиру");
            else if(PorchHouseInfo[idx][hLock] == 0) PorchHouseInfo[idx][hLock] = 1, SendClientMessage(playerid, COLOR_UNMAZING, "Вы закрыли входную дверь в свою квартиру");
            new fmt_sql[100];
            mysql_format(dbHandle, fmt_sql, sizeof fmt_sql, "UPDATE porch_house SET `hLock` = '%i' WHERE `id` = '%d'", PorchHouseInfo[idx][hLock], PorchHouseInfo[idx][hID]);
            mysql_tquery(dbHandle, fmt_sql, "", "");
        }
    }
}
