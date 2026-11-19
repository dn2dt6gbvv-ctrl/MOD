cmd:gps(playerid)
{
    if(PT[playerid][pUseGPS] != -1)
    {
        SendClientMessage(playerid, COLOR_UNMAZING, "Метка была удалена.");
        DestroyDynamicRaceCP(PT[playerid][pUseGPS]);
        PT[playerid][pUseGPS] = -1;

        RemovePlayerMapIcon(playerid, GPS_MAPICON_ID);
        return 0;
    }

    new string[512], temp_string[56];
    for(new i; i < sizeof GPS; i++)
    {
        if(GPS[i][GPS_SubObject] == true) continue;
        format(temp_string, sizeof temp_string, "%d. %s\n", i + 1, GPS[i][GPS_Name]);
        strcat(string, temp_string);
    }
    delEscapeChar(string);
    ShowPlayerDialogEx(playerid, dialog_GPS, DIALOG_STYLE_LIST, "Навигация", string, "Далее", "Отмена");
    PT[playerid][pUseTP] = 0;
    return 1;
}

cmd:tp(playerid)
{
    if(!GetAdminLevel(playerid, 1)) return SendErr(playerid, messageUnknownCMD);
    new string[512], temp_string[56];
    for(new i; i < sizeof GPS; i++)
    {
        if(GPS[i][GPS_SubObject] == true) continue;
        format(temp_string, sizeof temp_string, "%d. %s\n", i + 1, GPS[i][GPS_Name]);
        strcat(string, temp_string);
    }
    delEscapeChar(string);
    ShowPlayerDialogEx(playerid, dialog_GPS, DIALOG_STYLE_LIST, "Навигация", string, "Далее", "Отмена");
    PT[playerid][pUseTP] = 1;
    return 1;
}
