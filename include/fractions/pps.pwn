

stock InitPpsWarehouse()
{
    CreateDynamicPickup(347, 2, PPS_SCLAD_X, PPS_SCLAD_Y, PPS_SCLAD_Z, -1, -1, -1, 10.0);
    CreateDynamic3DTextLabel("Склад ППС", 0xFFFFFFFF, PPS_SCLAD_X, PPS_SCLAD_Y, PPS_SCLAD_Z + 0.5, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, -1, -1, -1, 10.0);

    CreateDynamicPickup(347, 2, GAI_SCLAD_X, GAI_SCLAD_Y, GAI_SCLAD_Z, -1, -1, -1, 10.0);
    CreateDynamic3DTextLabel("Склад ГАИ", 0xFFFFFFFF, GAI_SCLAD_X, GAI_SCLAD_Y, GAI_SCLAD_Z + 0.5, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, -1, -1, -1, 10.0);
    return 1;
}

cmd:ppss(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;
    if(PI[playerid][pFraction] != 3 && PI[playerid][pFraction] != 4)
        return SendErr(playerid, "Вы не являетесь сотрудником ППС/ГАИ!");
    if(!PT[playerid][pDuty])
        return SendErr(playerid, "Вы должны начать рабочий день, чтобы открыть склад!");
    if(!IsPlayerInRangeOfPoint(playerid, 3.0, PPS_SCLAD_X, PPS_SCLAD_Y, PPS_SCLAD_Z) &&
       !IsPlayerInRangeOfPoint(playerid, 3.0, GAI_SCLAD_X, GAI_SCLAD_Y, GAI_SCLAD_Z))
        return SendErr(playerid, "Вы должны находиться у оружейного склада!");

    cef_create_browser(playerid, PPS_WAREHOUSE_BROWSER, PPS_WAREHOUSE_LINK, false, true);
    cef_focus_browser(playerid, PPS_WAREHOUSE_BROWSER, true);
    TogglePlayerControllable(playerid, 0);
    return 1;
}

forward ClosePpsWarehouse(playerid);
public ClosePpsWarehouse(playerid)
{
    cef_focus_browser(playerid, PPS_WAREHOUSE_BROWSER, false);
    cef_hide_browser(playerid, PPS_WAREHOUSE_BROWSER, true);
    cef_destroy_browser(playerid, PPS_WAREHOUSE_BROWSER);
    TogglePlayerControllable(playerid, 1);
    cef_emit_event(playerid, "game:showCursor", CEFINT(0));
    return 1;
}

forward OnPpsWarehouseTake(playerid, const item[]);
public OnPpsWarehouseTake(playerid, const item[])
{
    if(PI[playerid][pFraction] != 3 && PI[playerid][pFraction] != 4) return 1;

    if(!strcmp(item, "svd", true))
    {
        GivePlayerWeapon(playerid, 34, 50);
        SendClientMessage(playerid, -1, "{E69348}[Склад ППС/ГАИ] {FFFFFF}Вы взяли СВД ПСО.");
        SendWarehouseRadio(playerid, "СВД ПСО");
    }
    else if(!strcmp(item, "aks74u", true))
    {
        GivePlayerWeapon(playerid, 29, 150);
        SendClientMessage(playerid, -1, "{E69348}[Склад ППС/ГАИ] {FFFFFF}Вы взяли АКС-74У.");
        SendWarehouseRadio(playerid, "АКС-74У");
    }
    else if(!strcmp(item, "saiga", true))
    {
        GivePlayerWeapon(playerid, 27, 60);
        SendClientMessage(playerid, -1, "{E69348}[Склад ППС/ГАИ] {FFFFFF}Вы взяли Сайгу.");
        SendWarehouseRadio(playerid, "Сайга");
    }
    else if(!strcmp(item, "armor", true))
    {
        SetPlayerArmour(playerid, 100.0);
        SendClientMessage(playerid, -1, "{E69348}[Склад ППС/ГАИ] {FFFFFF}Вы взяли Бронежилет.");
        SendWarehouseRadio(playerid, "Бронежилет");
    }
    else if(!strcmp(item, "as_val", true))
    {
        GivePlayerWeapon(playerid, 31, 100);
        SendClientMessage(playerid, -1, "{E69348}[Склад ППС/ГАИ] {FFFFFF}Вы взяли АС «ВАЛ».");
        SendWarehouseRadio(playerid, "АС ВАЛ");
    }
    else if(!strcmp(item, "tt_pistol", true))
    {
        GivePlayerWeapon(playerid, 24, 35);
        SendClientMessage(playerid, -1, "{E69348}[Склад ППС/ГАИ] {FFFFFF}Вы взяли Пистолет ТТ.");
        SendWarehouseRadio(playerid, "Пистолет ТТ");
    }
    else if(!strcmp(item, "baton", true))
    {
        GivePlayerWeapon(playerid, 3, 1);
        SendClientMessage(playerid, -1, "{E69348}[Склад ППС/ГАИ] {FFFFFF}Вы взяли Резиновую дубинку.");
        SendWarehouseRadio(playerid, "Резиновая дубинка");
    }
    else if(!strcmp(item, "baton_police", true))
    {
        GivePlayerWeapon(playerid, 3, 1);
        SendClientMessage(playerid, -1, "{E69348}[Склад ППС/ГАИ] {FFFFFF}Вы взяли Жезл.");
        SendWarehouseRadio(playerid, "Жезл");
    }
    else if(!strcmp(item, "taser", true))
    {
        GivePlayerWeapon(playerid, 23, 10);
        SendClientMessage(playerid, -1, "{E69348}[Склад ППС/ГАИ] {FFFFFF}Вы взяли Тайзер.");
        SendWarehouseRadio(playerid, "Тайзер");
    }
    else if(!strcmp(item, "medkit", true))
    {
        SendClientMessage(playerid, -1, "{E69348}[Склад ППС/ГАИ] {FFFFFF}Вы взяли Аптечку.");
        SendWarehouseRadio(playerid, "Аптечка");
    }
    return 1;
}

callback::OnClosePoliceWarehouse(playerid, const arguments[])
{
    ClosePpsWarehouse(playerid);
    return 1;
}

callback::OnPoliceWarehouseTake(playerid, const arguments[])
{
    OnPpsWarehouseTake(playerid, arguments);
    return 1;
}
