case dialog_SELL_HOUSE:
{
    if(!response) return 1;
    new h = GetPlayerHouseID(playerid);
    if(h <= 0) return SendErr(playerid, "У вас нет недвижимости!");

    PI[playerid][pSpawn] = 0;
    TransferMoney(-1, playerid, House[h][hPrice]/2, "Продажа недвижимости");

    DestroyPickup(House[h][hPickup]); House[h][hPickup] = CreatePickup(11776, 23, House[h][hPos_x], House[h][hPos_y], House[h][hPos_z]);
    DestroyDynamicMapIcon(House[h][hMapIcon]); House[h][hMapIcon] = CreateDynamicMapIcon(House[h][hPos_x], House[h][hPos_y], House[h][hPos_z], 31, 0,-1,-1,-1,150.0);

    House[h][hOwnerID] = 0;
    settext(House[h][hOwner], "none");
    SendClientMessage(playerid, COLOR_UNMAZING, "Вы продали свою недвижимость. Деньги были зачислены на ваш баланс");

    if(IsPlayerInRangeOfPoint(playerid, 30.0, House_Interiors[House[h][hClass]][hIPos_EX], House_Interiors[House[h][hClass]][hIPos_EY], House_Interiors[House[h][hClass]][hIPos_EZ]))
    {
        SetPlayerPos(playerid, House[h][hPos_x], House[h][hPos_y], House[h][hPos_z]);
        SetPlayerVirtualWorld(playerid, 0);
        SetPlayerInterior(playerid, 0);
    }
    
    new query[] = "UPDATE `houses` SET `owner_id` = %d WHERE `id` = %d";
    new fmt_query[sizeof(query) + 10 + 10];

    mysql_format(dbHandle, fmt_query, sizeof(fmt_query), query, House[h][hOwnerID], House[h][hID]);
    mysql_tquery(dbHandle, fmt_query, "", "");
}

case dialog_HOUSE:
{
    if(!response) return 0;
    new h = PT[playerid][pHouseTemp];
    if(IsValidHouse(h) == false) return SendErr(playerid, "Вы далеко отошли.");
    if(House[h][hLock] && House[h][hOwnerID] != GetPlayerHouseID(playerid)) SendErr(playerid, "У Вас нет ключей от этого дома");

    SetPlayerPos(playerid, House_Interiors[House[h][hClass]][hIPos_EX], House_Interiors[House[h][hClass]][hIPos_EY], House_Interiors[House[h][hClass]][hIPos_EZ]);
    SetPlayerVirtualWorld(playerid, House[h][hID]);
    SetPlayerFacingAngle(playerid, House_Interiors[House[h][hClass]][hIPos_EA]);

    PT[playerid][pHouseTemp] = -1;
}

case dialog_HOUSE+1:
{
    if(!response) return 1;
    new h = PT[playerid][pHouseTemp];
    if(IsValidHouse(h) == false) return SendErr(playerid, "Вы далеко отошли.");

    SetPlayerPos(playerid, House[h][hPos_x], House[h][hPos_y], House[h][hPos_z]);
    SetPlayerVirtualWorld(playerid, 0);
}
