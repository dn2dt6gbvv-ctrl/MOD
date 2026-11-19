case DIALOG_SETLEADER:
{
    if(!response) 
    {
        PT[playerid][pPlayer] = -1;
        return 1;
    }

    new i = PT[playerid][pPlayer];
    if(!IsPlayerConnected(i)) return SendErr(playerid, "Игрок уже не в сети.");

    new selected_frac = listitem + 1;

    Otdel_RemovePlayerSilent(i);
    PI[i][pFraction]     = selected_frac;
    PI[i][pLeader]       = selected_frac;
    PI[i][pFractionRank] = Fraction[selected_frac][fMax_ranks];

    switch(PI[i][pSex])
    {
        case 1:  PI[i][pFractionSkin] = Fraction[selected_frac][fSkinMale][PI[i][pFractionRank]-1];
        default: PI[i][pFractionSkin] = Fraction[selected_frac][fSkinFemale][PI[i][pFractionRank]-1];
    }

    new query[256];
    mysql_format(dbHandle, query, sizeof(query),
        "UPDATE `accounts` SET `leader` = %d, `fraction` = %d, `fraction_rank` = %d, `fraction_skin` = %d WHERE `id` = %d",
        PI[i][pLeader], PI[i][pFraction], PI[i][pFractionRank], PI[i][pFractionSkin], PI[i][pID]);
    mysql_tquery(dbHandle, query, "", "");

    SetPlayerSkin(i, PI[i][pFractionSkin]);
    UpdatePlayerTag(i);
    SyncTagPanelAccess(i);

    new fracNameWB[64];
    format(fracNameWB, sizeof(fracNameWB), "%s", Fraction[selected_frac][fName]);
    new wbQuery[320];
    mysql_format(dbHandle, wbQuery, sizeof(wbQuery),
        "INSERT INTO `work_history` (`player_id`,`fraction_id`,`fraction_name`,`action`,`rank_from`,`rank_to`,`reason`,`by_name`) VALUES (%d,%d,'%e',1,0,%d,'Назначен лидером','%e')",
        PI[i][pID], selected_frac, fracNameWB, PI[i][pFractionRank], GetName(playerid));
    mysql_tquery(dbHandle, wbQuery, "", "");
    
    new string[144];
    format(string, sizeof string, "[A] %s %s[%d] выдал лидерские права фракции %s игроку %s[%d]",
        GetPrefix(playerid), GetName(playerid), playerid,
        Fraction[selected_frac][fName], GetName(i), i);
    SendAdminMessage(0x54b367FF, string);

    format(string, sizeof string, "%s %s выдал Вам лидерские права фракции %s",
        GetPrefix(playerid), GetName(playerid), Fraction[selected_frac][fName]);
    SendClientMessage(i, 0x54b367FF, string);

    PT[playerid][pPlayer] = -1;
    return 1;
}
case dialog_ADMIN:
{
    if(!response) return 1;
    new query[128]; 
    mysql_format(dbHandle, query, sizeof(query), "SELECT * FROM `admin` WHERE `admin_id` = %d AND `password` = '%s' LIMIT 1", PI[playerid][pID], inputtext);
    mysql_tquery(dbHandle, query, "CheckAloginD", "i", playerid);
}

case dialog_AVEHICLE:
{
    if(!response) return 1;

    PT[playerid][pTempAdminVehicle] = listitem;
    ShowPlayerDialogEx(playerid, dialog_AVEHICLE + 1, DIALOG_STYLE_LIST, "Админ транспорт", "Телепортироваться к транспорту\nТелепортировать транспорт\nУдалить транспорт\nЗаправить транспорт", "Выбрать", "Отмена");
}

case dialog_AVEHICLE + 1:
{
    if(!response) return 1;
    if(PT[playerid][pTempAdminVehicle] <= -1) return SendClientMessage(playerid, COLOR_RED, "Вы не выбрали транспорт!");
    
    new vehicleid = INVALID_VEHICLE_ID;
    new index = 0;
    new targetIndex = PT[playerid][pTempAdminVehicle];
    new string[144];

    foreach (new vid : adminVehicle)
    {
        if (index == targetIndex)
        {
            vehicleid = vid;
            break;
        }
        index++;
    }
    
    if(!IsValidVehicle(vehicleid)) return SendErr(playerid, "Выбранный транспорт не существует!");
    if(Iter_Contains(adminVehicle, vehicleid) == 0 || Iter_Count(adminVehicle) <= 0) return SendClientMessage(playerid, -1, "Этот автомобиль не создавал администратор!");
    if((listitem < 2 && (GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0) || GetPlayerState(playerid) == PLAYER_STATE_DRIVER)) 
        return SendClientMessage(playerid, COLOR_RED, "Действие невозможно в интерьере, виртуальном мире или когда вы находитесь в транспортном средстве!");

    switch(listitem)
    {
        case 0:
        {
            new Float:x, Float:y, Float:z;
            GetVehiclePos(vehicleid, x, y, z);
            SetPlayerPos(playerid, x, y, z + 5.0);

            format(string, sizeof string, "%s %s[%d] телепортировался к транспорту №%d", GetPrefix(playerid), GetName(playerid), playerid, vehicleid);
            SendAdminMessage(COLOR_GRAY, string);
        }
        case 1:
        {
            new Float:x, Float:y, Float:z;
            GetPlayerPos(playerid, x, y, z);
            SetVehiclePos(vehicleid, x, y, z);

            format(string, sizeof string, "%s %s[%d] телепортировал транспорт №%d к себе", GetPrefix(playerid), GetName(playerid), playerid, vehicleid);
            SendAdminMessage(COLOR_GRAY, string);
        }
        case 2:
        {
            Iter_Remove(adminVehicle, vehicleid);
            DestroyVehicle(vehicleid);

            format(string, sizeof string, "%s %s[%d] удалил транспорт ID: %d", GetPrefix(playerid), GetName(playerid), playerid, vehicleid);
            SendAdminMessage(COLOR_GRAY, string);
        }
        case 3:
        {
            if(CI[vehicleid][Fuel] >= 100) return SendClientMessage(playerid, COLOR_RED, "Транспорт уже заправлен!");

            CI[vehicleid][Fuel] = 100;
            format(string, sizeof string, "%s %s[%d] установил 100 л. транспорту №%d", GetPrefix(playerid), GetName(playerid), playerid, vehicleid);
            SendAdminMessage(COLOR_GRAY, string);  
        }
    }
    PT[playerid][pTempAdminVehicle] = -1;
    return 1;
}
