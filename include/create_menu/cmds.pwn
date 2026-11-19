

CMD:add(playerid)
{
    if(!IsPlayerGrandAdmin(playerid)) return SendErr(playerid, messageUnknownCMD);
    if(!GetAdminLevel(playerid, 7)) return SendErr(playerid, messageUnknownCMD);

    if(PT[playerid][pCreate] && PT[playerid][pSubCreate]) return 1;
    switch(PT[playerid][pCreate])
    {
        case 0: ShowPlayerDialogEx(playerid, dialog_CREATE, DIALOG_STYLE_LIST, "Что вы хотите создать?", "Дом\nАвтомобиль во фракцию\nПодъезд", "Начать", "Отмена");
        case 1: OpenHouseCreate(playerid);
        case 3: ShowPlayerDialogEx(playerid, dialog_CREATE+8, DIALOG_STYLE_LIST, "Создание подъезда", "1.Низкий  класс\n2.Высокий класс", "Создать", "Отмена");
    }
    return 1;
}
CMD:addcar(playerid)
{
    if(!IsPlayerGrandAdmin(playerid)) return SendErr(playerid, messageUnknownCMD);
    if(!GetAdminLevel(playerid, 7)) return SendErr(playerid, messageUnknownCMD);

    if(!PT[playerid][pSubCreate]) return SendErr(playerid, "Вы не начали создание!");

    switch(PT[playerid][pCreate])
    {
        case 1:
        {
            GetVehiclePos(PT[playerid][pSubCreate], PT[playerid][pCreateVehicleX], PT[playerid][pCreateVehicleY], PT[playerid][pCreateVehicleZ]);
            GetVehicleZAngle(PT[playerid][pSubCreate], PT[playerid][pCreateVehicleA]);

            DestroyVehicle(PT[playerid][pSubCreate]);
            PT[playerid][pSubCreate] = 0;
            return SendClientMessage(playerid, COLOR_LIME, "Вы установили позицию автомобиля. Встаньте на пикап дома и напишите /add.");
        }
        case 2:
        {
            GetVehiclePos(PT[playerid][pSubCreate], PT[playerid][pCreateVehicleX], PT[playerid][pCreateVehicleY], PT[playerid][pCreateVehicleZ]);
            GetVehicleZAngle(PT[playerid][pSubCreate], PT[playerid][pCreateVehicleA]);

            return ShowPlayerDialogEx(playerid, dialog_CREATE+2, DIALOG_STYLE_INPUT, "Создание автомобиля", "Введите первый, второй цвет, доступ с ранга и ID фракции через запятую (например: 204, 15, 3, 5, 415):", "Создать", "Отмена");
        }

        case 3:
        {
            if(GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0) SendErr(playerid, "Вы не должны находится в интерьере");

            GetVehiclePos(PT[playerid][pSubCreate], PT[playerid][pCreateVehicleX], PT[playerid][pCreateVehicleY], PT[playerid][pCreateVehicleZ]);
            GetVehicleZAngle(PT[playerid][pSubCreate], PT[playerid][pCreateVehicleA]);

            DestroyVehicle(PT[playerid][pSubCreate]);
            PT[playerid][pSubCreate] = 0;
            return SendClientMessage(playerid, COLOR_LIME, "Вы установили позицию автомобиля. Встаньте на пикап подъезда и напишите /add.");
        }
































           
        default: return 0;
    }

    return 1;
}

cmd:fractions_menu(playerid)
{
    if(!IsPlayerGrandAdmin(playerid)) return SendErr(playerid, messageUnknownCMD);
    if(!GetAdminLevel(playerid, 7)) return SendErr(playerid, messageUnknownCMD);

    new frac_string[MAX_FRACTIONS_NAME + 4];
    new string[(4 + MAX_FRACTIONS_NAME) * MAX_FRACTIONS];

    for(new f = 1; f < totalFractions; f++)
    {
        format(frac_string, sizeof frac_string, "%d. %s\n", f, GetFractionName(f));
        strcat(string, frac_string);
    }
    delEscapeChar(string);

    PT[playerid][pCreate] = 3;

    ShowPlayerDialogEx(playerid, dialog_CREATE + 3, DIALOG_STYLE_LIST, "Меню фракционого создания", string, "Далее", "Отмена");
    return 1;
}

CMD:flats(playerid, params[])
{
    new porch = -1;
    for(new i = 0; i < TOTALPORCH; i++)
    {
        if(IsPlayerInRangeOfPoint(playerid, 5.0, PorchInfo[i][pEnterX], PorchInfo[i][pEnterY], PorchInfo[i][pEnterZ]))
        {
            porch = i;
            break;
        }
    }
    if(porch == -1) return SendErr(playerid, "Вы не находитесь рядом с подъездом.");

    new string[1024], line[96];
    format(string, sizeof string, "№\tСтатус\tЦена\tОплата/ч\n");

    for(new i = 0; i < PorchInfo[porch][pMaxPorch]; i++)
    {
        new h = PorchInfo[porch][pFirstFlat] + i;
        if(PorchHouseInfo[h][hOwnerID] > 0)
            format(line, sizeof line, "%d.\t{FF4444}Занята: %s\t%d\t%d\n", PorchHouseInfo[h][hID], PorchHouseInfo[h][hOwner], PorchHouseInfo[h][hPrice], PorchHouseInfo[h][hPay]);
        else
            format(line, sizeof line, "%d.\t{8BC34A}Свободна\t%d\t%d\n", PorchHouseInfo[h][hID], PorchHouseInfo[h][hPrice], PorchHouseInfo[h][hPay]);
        strcat(string, line);
    }

    PT[playerid][pTempDialogData] = porch;
    ShowPlayerDialogEx(playerid, dialog_FLATS, DIALOG_STYLE_TABLIST_HEADERS, "Квартиры подъезда", string, "Выбрать", "Закрыть");
    return 1;
}
