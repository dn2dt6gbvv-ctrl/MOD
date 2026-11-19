case dialog_GPS:
{
    if (!response) 
    {
        PT[playerid][pUseTP] = 0;
        return 1;
    }

    new string[512], temp_string[56];
    new index = 1;

    for (new i = 0; i < sizeof GPS; i++)
    {
        if (GPS[i][GPS_Category] != listitem + 1 && GPS[i][GPS_SubObject] != true) continue;

        format(temp_string, sizeof temp_string, "%d. %s\n", index, GPS[i][GPS_Name]);
        strcat(string, temp_string);
        index++;
    }

    PT[playerid][pSelectedGPSCategory] = listitem + 1;
    ShowPlayerDialogEx(playerid, dialog_GPS + 1, DIALOG_STYLE_LIST, "Навигация", string, "Установить", "Назад");
    return 1;
}

case dialog_GPS + 1:
{
    if (!response) 
    {
        PT[playerid][pUseTP] = 0;
        return 1;
    }

    new count = -1, selectedIndex = -1;

    new idx = PT[playerid][pUseTP];

    for (new i = 0; i < sizeof GPS; i++)
    {
        if (GPS[i][GPS_Category] != PT[playerid][pSelectedGPSCategory] && GPS[i][GPS_SubObject] != true) continue;
        
        count++;
        if (count == listitem)
        {
            selectedIndex = i;
            break;
        }
    }

    if (selectedIndex == -1) return SendErr(playerid, "Ошибка GPS: не удалось определить точку.");

    
    switch(idx)
    {
        case 0:
        {
            PT[playerid][pUseGPS] = CreateDynamicRaceCP(1, GPS[selectedIndex][GPS_X],
                GPS[selectedIndex][GPS_Y],
                GPS[selectedIndex][GPS_Z], 0.0, 0.0, 0.0, 3.0, -1, -1, playerid);

            SCMF(playerid, COLOR_UNMAZING, "Вы поставили метку на %s", GPS[selectedIndex][GPS_Name]);
            

            PT[playerid][pSelectedGPSCategory] = 0;
            PT[playerid][pUseTP] = 0;

            SetPlayerMapIcon(playerid, GPS_MAPICON_ID, GPS[selectedIndex][GPS_X], GPS[selectedIndex][GPS_Y], GPS[selectedIndex][GPS_Z], GPS_MAPICON_ICON, 0, MAPICON_GLOBAL);
        }
        case 1:
        {
            SetPlayerPos(playerid, GPS[selectedIndex][GPS_X], GPS[selectedIndex][GPS_Y], GPS[selectedIndex][GPS_Z]);
        }
    }
    return 1;
}
