
stock OpenHouseCreate(playerid)
{
    cef_create_browser(playerid, HOUSECREATE_BROWSER, HOUSECREATE_CEF_LINK, false, true);
}

stock CloseHouseCreate(playerid)
{
    cef_emit_event(playerid, "housecreate:close");
    cef_focus_browser(playerid, HOUSECREATE_BROWSER, false);
}

forward HouseCreateReady(playerid);
public  HouseCreateReady(playerid)
{
    if (!IsPlayerConnected(playerid)) return 1;
    cef_emit_event(playerid, "housecreate:open");
    return 1;
}
callback::HouseCreatePrice(playerid, const arguments[])
{
    if (!IsPlayerConnected(playerid)) return 1;
    if (PT[playerid][pCreate] != 1) return 1;
    new price = strval(arguments);
    printf("[HouseCreate] price received: %d (raw: %s)", price, arguments);
    if (price < 1 || price > 1000000000) return 1;
    PT[playerid][pTempDialogData][0] = price;
    return 1;
}

callback::HouseCreatePay(playerid, const arguments[])
{
    if (!IsPlayerConnected(playerid)) return 1;
    if (PT[playerid][pCreate] != 1) return 1;
    new pay = strval(arguments);
    printf("[HouseCreate] pay received: %d (raw: %s)", pay, arguments);
    if (pay < 1 || pay > 100000000) return 1;
    PT[playerid][pTempDialogData][1] = pay;
    return 1;
}

callback::HouseCreateClass(playerid, const arguments[])
{
    if (!IsPlayerConnected(playerid)) return 1;
    if (PT[playerid][pCreate] != 1) return 1;

    new cls = strval(arguments);
    if (cls < 1 || cls > 3) return 1;

    new price = PT[playerid][pTempDialogData][0];
    new pay   = PT[playerid][pTempDialogData][1];

    printf("[HouseCreate] cls=%d price=%d pay=%d", cls, price, pay);

    if (price < 1 || pay < 1)
    {
        SendErr(playerid, "Ошибка: цена или оплата не установлены.");
        CloseHouseCreate(playerid);
        PT[playerid][pCreate] = 0;
        return 1;
    }

    new h = total_houses;
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    House[h][hID]      = h + 1;
    House[h][hPrice]   = price;
    House[h][hClass]   = cls;
    House[h][hPay]     = pay;
    House[h][hHours]   = 0;
    House[h][hLock]    = 0;
    House[h][hOwnerID] = 0;
    settext(House[h][hOwner], "None");

    House[h][hVSPos_x] = PT[playerid][pCreateVehicleX];
    House[h][hVSPos_y] = PT[playerid][pCreateVehicleY];
    House[h][hVSPos_z] = PT[playerid][pCreateVehicleZ];
    House[h][hVSPos_a] = PT[playerid][pCreateVehicleA];

    House[h][hPos_x] = x;
    House[h][hPos_y] = y;
    House[h][hPos_z] = z;

    House[h][hPickup]  = CreatePickup(11776, 23, x, y, z);
    House[h][hMapIcon] = CreateDynamicMapIcon(x, y, z, 31, 0, -1, -1, -1, 150.0);

    CreatePickup(11778, 23,
        House_Interiors[cls][hIPos_X],
        House_Interiors[cls][hIPos_Y],
        House_Interiors[cls][hIPos_Z],
        House[h][hID]);
    CreatePickup(11784, 23,
        House[h][hVSPos_x], House[h][hVSPos_y], House[h][hVSPos_z] + 0.42);

    House[h][hAreaExit] = CreateDynamicSphere(
        House_Interiors[cls][hIPos_X],
        House_Interiors[cls][hIPos_Y],
        House_Interiors[cls][hIPos_Z],
        1.0, House[h][hID]);
    House[h][hArea]             = CreateDynamicSphere(x, y, z, 1.5);
    House[h][hAreaSpawnVehicle] = CreateDynamicSphere(x, y, z, 5.0);

    ++total_houses;

    new query[256];
    mysql_format(dbHandle, query, sizeof query,
        "INSERT INTO `houses` (`price`, `pay`, `class`, `lock`, `hours`, `owner_id`, `pos_x`, `pos_y`, `pos_z`, `vs_posx`, `vs_posy`, `vs_posz`, `vs_posa`) \
         VALUES (%d, %d, %d, 0, 0, 0, '%.4f', '%.4f', '%.4f', '%.4f', '%.4f', '%.4f', '%.4f')",
        price, pay, cls, x, y, z,
        House[h][hVSPos_x], House[h][hVSPos_y], House[h][hVSPos_z], House[h][hVSPos_a]);
    mysql_tquery(dbHandle, query, "", "");

    CloseHouseCreate(playerid);

    new msg[128];
    format(msg, sizeof msg, "Дом создан. ID: %d, класс: %d, цена: %d руб., оплата: %d руб/ч.", h+1, cls, price, pay);
    SendClientMessage(playerid, COLOR_LIME, msg);

    PT[playerid][pCreate]            = 0;
    PT[playerid][pTempDialogData][0] = 0;
    PT[playerid][pTempDialogData][1] = 0;
    PT[playerid][pCreateVehicleX]    = 0;
    PT[playerid][pCreateVehicleY]    = 0;
    PT[playerid][pCreateVehicleZ]    = 0;
    PT[playerid][pCreateVehicleA]    = 0;
    return 1;
}

callback::HouseCreateCancel(playerid, const arguments[])
{
    if (!IsPlayerConnected(playerid)) return 1;
    PT[playerid][pCreate]            = 0;
    PT[playerid][pTempDialogData][0] = 0;
    PT[playerid][pTempDialogData][1] = 0;
    return 1;
}
