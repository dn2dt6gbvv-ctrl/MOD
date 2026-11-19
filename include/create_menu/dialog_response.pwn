case dialog_CREATE:
{
    if(response == DIALOG_RESPONSE_CANCEL) return 0;
    new Float:x, Float:y, Float:z; GetPlayerPos(playerid, x, y, z);
    PT[playerid][pSubCreate] = CreateVehicle(466, x, y, z, 0.0, 1, 1, 1000);
    PT[playerid][pCreate] = listitem+1;
    PutPlayerInVehicle(playerid, PT[playerid][pSubCreate], 0);
    CI[PT[playerid][pSubCreate]][Fuel] = 50;

    SetVehicleParamsEx(PT[playerid][pSubCreate], 1, 1, 0, 0, 0, 0, 0);

    SendClientMessage(playerid, COLOR_UNMAZING, "Введите: /addcar для установки позиции автомобиля.");
    SendClientMessage(playerid, COLOR_GRAY, "* Чтобы отменить создание, выйдите из автомобиля.");

}
case dialog_CREATE+8:
{
    if(response == DIALOG_RESPONSE_CANCEL)
    {
        PT[playerid][pCreate] = 0;
        DestroyVehicle(PT[playerid][pSubCreate]);   
        PT[playerid][pSubCreate] = INVALID_VEHICLE_ID;
        return 0;
    }
    PorchInfo[TOTALPORCH][pID] = TOTALPORCH+1;

    new Float: x, Float:y, Float:z;
    new Float: pos_x, Float: pos_y, Float: pos_z, Float: pos_fa;
    new max_porch = 0;

    GetPlayerPos(playerid, x, y, z);

    PorchInfo[TOTALPORCH][pEnterX] = x;
    PorchInfo[TOTALPORCH][pEnterY] = y;
    PorchInfo[TOTALPORCH][pEnterZ] = z;

    switch(listitem)
    {
        case 0: pos_x = 602.2761, pos_y = 554.1732, pos_z = 1501.2372, pos_fa = 360.00, max_porch = 10;
        case 1: pos_x = 199.9387, pos_y = 1107.7383, pos_z = 2502.4341, pos_fa = 357.4695, max_porch = 20;
        default: pos_x = 0.0, pos_y = 0.0, pos_z = 0.0, pos_fa = 0.0;
    }
    PorchInfo[TOTALPORCH][pCarX] = PT[playerid][pCreateVehicleX];
    PorchInfo[TOTALPORCH][pCarY] = PT[playerid][pCreateVehicleY]; 
    PorchInfo[TOTALPORCH][pCarZ] = PT[playerid][pCreateVehicleZ];
    PorchInfo[TOTALPORCH][pCarA] = PT[playerid][pCreateVehicleA];

    PorchInfo[TOTALPORCH][penter_X] = pos_x;
    PorchInfo[TOTALPORCH][penter_Y] = pos_y;
    PorchInfo[TOTALPORCH][penter_Z] = pos_z;
    PorchInfo[TOTALPORCH][penter_Fa] = pos_fa;
    
    PorchInfo[TOTALPORCH][pFirstFlat] = totalPorchHouse+1;
    PorchInfo[TOTALPORCH][pType] = listitem+1;
    PorchInfo[TOTALPORCH][pMaxPorch] = max_porch;

    PorchInfo[TOTALPORCH][enter_pickup] = CreateDynamicSphere(PorchInfo[TOTALPORCH][pEnterX], PorchInfo[TOTALPORCH][pEnterY], PorchInfo[TOTALPORCH][pEnterZ], 1.0, 0);
    CreateDynamicPickup(11779, 23, PorchInfo[TOTALPORCH][pEnterX], PorchInfo[TOTALPORCH][pEnterY], PorchInfo[TOTALPORCH][pEnterZ], -1);
    
    switch(PorchInfo[TOTALPORCH][pType])
    {
        case 1:
        {
            PorchInfo[TOTALPORCH][exit_area] = CreateDynamicSphere(601.9421,551.5764,1501.2372, 1.0, TOTALPORCH, 0);
            PorchInfo[TOTALPORCH][menu_area] = CreateDynamicSphere(599.3630,552.8333,1501.2372, 1.0, TOTALPORCH, 0);
        }
        case 2:
        {
            PorchInfo[TOTALPORCH][exit_area] = CreateDynamicSphere(200.0524,1105.5558,2501.2371, 1.0, TOTALPORCH, 0);
            PorchInfo[TOTALPORCH][menu_area] = CreateDynamicSphere(202.5057,1107.7590,2501.2371, 1.0, TOTALPORCH, 0);
        }
        default: return 1;
    }
    PorchInfo[TOTALPORCH][pMIcon] = CreateDynamicMapIcon(PorchInfo[TOTALPORCH][pEnterX], PorchInfo[TOTALPORCH][pEnterY], PorchInfo[TOTALPORCH][pEnterZ], 40, 0, -1, -1, -1, 100.0);

    TOTALPORCH++;

    new fmt_text[100];
    format(fmt_text, sizeof fmt_text, "Вы успешно создали подъезд №%i, тип %i", TOTALPORCH, listitem+1);
    SendClientMessage(playerid, COLOR_LIME, fmt_text);

    new query[400];
    mysql_format(dbHandle, query, sizeof(query), "INSERT INTO `porch` (`pEnterX`, `pEnterY`, `pEnterZ`, `vxod_x`, `vxod_y`, `vxod_z`, `vxod_fa`, `pCarX`, `pCarY`, `pCarZ`, `pCarA`, `pFirstFlat`, `pType`, `pMaxPorch`) VALUES ('%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%i', '%i', '%i')",
        x, y, z,
        pos_x, pos_y, pos_z, pos_fa,
        PT[playerid][pCreateVehicleX], PT[playerid][pCreateVehicleY], PT[playerid][pCreateVehicleZ], PT[playerid][pCreateVehicleA],
        totalPorchHouse+1,
        listitem+1,
        max_porch);

    mysql_tquery(dbHandle, query, "", "");

    new fmt_query[600];

    for(new i= 0; i < max_porch; i++)
    {
        totalPorchHouse++;

        PorchHouseInfo[totalPorchHouse][hID] = totalPorchHouse;
        
        PorchHouseInfo[totalPorchHouse][hSpawn_X] = -1568.0839;
        PorchHouseInfo[totalPorchHouse][hSpawn_Y] = 1993.3000;
        PorchHouseInfo[totalPorchHouse][hSpawn_Z] = 2204.8342;
        PorchHouseInfo[totalPorchHouse][hSpawn_Fa] = 152.3297;

        PorchHouseInfo[totalPorchHouse][hOwnerID] = 0;
        new r = RandomEX(0, 3);
        switch(r)
        {
            case 0:
            {
                PorchHouseInfo[totalPorchHouse][hPrice] = 500000;
                PorchHouseInfo[totalPorchHouse][hClass] = 1;
                PorchHouseInfo[totalPorchHouse][hPay] = 3000;
            }
            case 1:
            {
                PorchHouseInfo[totalPorchHouse][hPrice] = 800000;
                PorchHouseInfo[totalPorchHouse][hClass] = 1;
                PorchHouseInfo[totalPorchHouse][hPay] = 7000;
            }
            case 2:
            {
                PorchHouseInfo[totalPorchHouse][hPrice] = 1000000;
                PorchHouseInfo[totalPorchHouse][hClass] = 1;
                PorchHouseInfo[totalPorchHouse][hPay] = 10000;
            }
        }
        PorchHouseInfo[totalPorchHouse][hLock] = 1;
        PorchHouseInfo[totalPorchHouse][hBank] = PorchHouseInfo[totalPorchHouse][hPay];
        PorchHouseInfo[totalPorchHouse][hPorch] = TOTALPORCH;

        settext(PorchHouseInfo[totalPorchHouse][hOwner], "None");

        switch(PorchInfo[TOTALPORCH-1][pType])
        {
            case 1:
            {
                PorchHouseInfo[totalPorchHouse][hEntrx] = coord_porch_class[i][0];
                PorchHouseInfo[totalPorchHouse][hEntry] = coord_porch_class[i][1];
                PorchHouseInfo[totalPorchHouse][hEntrz] = coord_porch_class[i][2];
                PorchHouseInfo[totalPorchHouse][hEntrFa] = coord_porch_class[i][3];
            }
            case 2:
            {
                PorchHouseInfo[totalPorchHouse][hEntrx] = coord_porch_class_l[i][0];
                PorchHouseInfo[totalPorchHouse][hEntry] = coord_porch_class_l[i][1];
                PorchHouseInfo[totalPorchHouse][hEntrz] = coord_porch_class_l[i][2];
                PorchHouseInfo[totalPorchHouse][hEntrFa] = coord_porch_class_l[i][3];
            }
        }

        PorchHouseInfo[totalPorchHouse][h_exit_area] = CreateDynamicSphere(-1580.0547,1987.5717,2204.8342, 1.0, totalPorchHouse, 0);
        
        CreateDynamicPickup
        (
            11778, 
            1, 
            -1580.0547,1987.5717,2204.8342, totalPorchHouse, 0
        );
        PorchHouseInfo[totalPorchHouse][h_area] = CreateDynamicSphere(PorchHouseInfo[totalPorchHouse][hEntrx],PorchHouseInfo[totalPorchHouse][hEntry], PorchHouseInfo[totalPorchHouse][hEntrz], 1.0, TOTALPORCH-1, 0);
        mysql_format(dbHandle, fmt_query, sizeof(fmt_query), "INSERT INTO `porch_house` (`hEntrx`, `hEntry`, `hEntrz`, `hEntrFa`, `hSpawn_X`, `hSpawn_Y`, `hSpawn_Z`, `hSpawn_Fa`, `hOwner`, `hOwnerID`, `hPrice`, `hBank`, `hPorch`, `hLock`, `hClass`, `hPay`) \ 
        VALUES ('%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%s', '%i', '%i', '%i', '%i', '%i', '%i', '%i')",
        PorchHouseInfo[totalPorchHouse][hEntrx], PorchHouseInfo[totalPorchHouse][hEntry],PorchHouseInfo[totalPorchHouse][hEntrz],PorchHouseInfo[totalPorchHouse][hEntrFa],
        -1568.0839, 1993.3000,2204.8342, 152.3297,
        0,
        PorchHouseInfo[totalPorchHouse][hOwnerID],
        PorchHouseInfo[totalPorchHouse][hPrice],
        PorchHouseInfo[totalPorchHouse][hBank],
        PorchHouseInfo[totalPorchHouse][hPorch],
        PorchHouseInfo[totalPorchHouse][hLock],
        PorchHouseInfo[totalPorchHouse][hClass],
        PorchHouseInfo[totalPorchHouse][hPay]);
        mysql_tquery(dbHandle, fmt_query, "", "");   
    }
    SendClientMessage(playerid, COLOR_LIME, "Вы успешно создали квартиры");
    PT[playerid][pCreate] = 0;
    PT[playerid][pCreateVehicleX] = 0;
    PT[playerid][pCreateVehicleY] = 0; 
    PT[playerid][pCreateVehicleZ] = 0;
    PT[playerid][pCreateVehicleA] = 0;
    return 1;
}
case dialog_CREATE+1: {}

case dialog_CREATE+2:
{
    if(response == DIALOG_RESPONSE_CANCEL)
    {
        PT[playerid][pCreate] = 0;
        DestroyVehicle(PT[playerid][pSubCreate]);   
        PT[playerid][pSubCreate] = INVALID_VEHICLE_ID;
        return 0;
    }
    new color1, color2, rank, fractionid, model;
    if(sscanf(inputtext, "p<,>ddddd", color1, color2, rank, fractionid, model)) return ShowPlayerDialogEx(playerid, dialog_CREATE+2, DIALOG_STYLE_INPUT, "Создание автомобиля", "Введите первый, второй цвет, доступ с ранга и ID фракции через запятую (например: 204, 15, 3, 5, 415):", "Создать", "Отмена");

    if((1 > color1 > 255) || (1 > color2 > 255))  return ShowPlayerDialogEx(playerid, dialog_CREATE+2, DIALOG_STYLE_INPUT, "Создание автомобиля", "Введите первый, второй цвет, доступ с ранга, ID фракции и модель авто через запятую (например: 204, 15, 3, 5, 415)\nПримечание: Цвет автомобиля не может быть меньше нуля и не может превышать 255:", "Создать", "Отмена");
    if(Fraction[fractionid][fMax_ranks] < fractionid) return ShowPlayerDialogEx(playerid, dialog_CREATE+2, DIALOG_STYLE_INPUT, "Создание автомобиля", "Введите первый, второй цвет, доступ с ранга, ID фракции и модель авто через запятую (например: 204, 15, 3, 5, 415)\nПримечание: Ранг не может превышать максимально заданный фракцией ранг:", "Создать", "Отмена");
    if(fractionid >= 0 || fractionid > sizeof Fraction) return ShowPlayerDialogEx(playerid, dialog_CREATE+2, DIALOG_STYLE_INPUT, "Создание автомобиля", "Введите первый, второй цвет, доступ с ранга, ID фракции и модель авто через запятую (например: 204, 15, 3, 5, 415)\nНекорректный ID фракции", "Создать", "Отмена");
    if(!strcmp(GetVehicleName(model), InvalidVehicleName)) return ShowPlayerDialogEx(playerid, dialog_CREATE+2, DIALOG_STYLE_INPUT, "Создание автомобиля", "Введите первый, второй цвет, доступ с ранга, ID фракции и модель авто через запятую (например: 204, 15, 3, 5, 415)\nНекорректный ID автомобиля", "Создать", "Отмена");
    
    DestroyVehicle(PT[playerid][pSubCreate]);
    
    totalFractionVehicles[fractionid]++;
    new totalVehicles = totalFractionVehicles[fractionid];

    Fraction_Vehicles[fractionid][totalVehicles][fvSpawnX] = PT[playerid][pCreateVehicleX];
    Fraction_Vehicles[fractionid][totalVehicles][fvSpawnY] = PT[playerid][pCreateVehicleY]; 
    Fraction_Vehicles[fractionid][totalVehicles][fvSpawnZ] = PT[playerid][pCreateVehicleZ];
    Fraction_Vehicles[fractionid][totalVehicles][fvSpawnA] = PT[playerid][pCreateVehicleA];

    Fraction_Vehicles[fractionid][totalVehicles][fvModel] = model;
    Fraction_Vehicles[fractionid][totalVehicles][fvColor1] = color1; 
    Fraction_Vehicles[fractionid][totalVehicles][fvColor2] = color2;

    new vehicleid = Fraction_Vehicles[fractionid][totalVehicles][fvServerID] = 
    CreateVehicle(
        Fraction_Vehicles[fractionid][totalVehicles][fvModel], 
        Fraction_Vehicles[fractionid][totalVehicles][fvSpawnX], Fraction_Vehicles[fractionid][totalVehicles][fvSpawnY], Fraction_Vehicles[fractionid][totalVehicles][fvSpawnZ], Fraction_Vehicles[fractionid][totalVehicles][fvSpawnA], 
        Fraction_Vehicles[fractionid][totalVehicles][fvColor1], Fraction_Vehicles[fractionid][totalVehicles][fvColor2], 
    3600);

    CI[vehicleid][vOwnerType] = VEHICLE_OWNER_FRACTION;
    CI[vehicleid][vOwnerID] = fractionid;
    
    new query[] = "INSERT INTO `fractions_vehicles` (`fraction_veh_spawn_X`, `fraction_veh_spawn_Y`, `fraction_veh_spawn_Z`, `fraction_veh_spawn_A`, `fraction_veh_color1`, `fraction_veh_color2`, `fraction_veh_model`, `fraction_veh_rank_avaiable`, `fraction_id`) VALUES ('%.2f', '%.2f', '%.2f', '%.2f', %d, %d, %d, %d, %d)";
    new fmt_query[sizeof query + 9 * 8];

    mysql_format(dbHandle, fmt_query, sizeof fmt_query, query,
        Fraction_Vehicles[fractionid][totalVehicles][fvSpawnX], Fraction_Vehicles[fractionid][totalVehicles][fvSpawnY], Fraction_Vehicles[fractionid][totalVehicles][fvSpawnZ], Fraction_Vehicles[fractionid][totalVehicles][fvSpawnA], 
        color1, color2, model, rank, fractionid
    );

    mysql_tquery(dbHandle, fmt_query, "", "");
    SendClientMessage(playerid, -1, "Автомобиль создан.");

    PT[playerid][pSubCreate] = 0;
    PT[playerid][pCreate] = 0;
    PT[playerid][pCreateVehicleX] = 0;
    PT[playerid][pCreateVehicleY] = 0; 
    PT[playerid][pCreateVehicleZ] = 0;
    PT[playerid][pCreateVehicleA] = 0;
}



case dialog_CREATE+3:
{
    if(response == DIALOG_RESPONSE_CANCEL)
    {
        PT[playerid][pCreate] = 0;
        return 0;
    }
    
    PT[playerid][pTempDialogData][0] = listitem + 1;

    new fraction_name[24];

    settext(fraction_name, GetFractionName(PT[playerid][pTempDialogData]));

    new text[200];

    format(text, sizeof text, "Выберите действие которое хотите выполнить с фракцией \t%s.\nУправление автомобилями\nУправление рангами\nУправление зарплатами\nУправление скинами", fraction_name);

    ShowPlayerDialogEx(playerid, dialog_CREATE + 4, DIALOG_STYLE_LIST_TEXT, fraction_name, text, "Изменить", "Отмена");

}

case dialog_CREATE + 4:
{
    if(response == DIALOG_RESPONSE_CANCEL)
    {
        PT[playerid][pCreate] = 0;
        PT[playerid][pTempDialogData] = 0;
        return 0;
    }


    new fraction = PT[playerid][pTempDialogData];
      
    switch(listitem)
    {
        case 0:
        {
            if(totalFractionVehicles[fraction] <= 0) return SendErr(playerid, "Машины для этой фракции не созданы!");
            new string[MAX_FRACTION_VEHICLES * 50] = "Номер\tМодель\tID на сервере\tРанг\n";
            new frac_string[64];

            for(new i = 0; i < totalFractionVehicles[fraction]; i++)
            {
                format(frac_string, sizeof frac_string, "%d.\t%s (%d)\t%d\t%d\n",
                    i + 1,
                    GetVehicleName(Fraction_Vehicles[fraction][i][fvModel]),
                    Fraction_Vehicles[fraction][i][fvModel],
                    Fraction_Vehicles[fraction][i][fvServerID],
                    CI[Fraction_Vehicles[fraction][i][fvServerID]][vRankAvaiable]
                );
                strcat(string, frac_string);
            }
            delEscapeChar(string);
            ShowPlayerDialogEx(playerid, dialog_CREATE + 5, DIALOG_STYLE_TABLIST_HEADERS, "Меню фракционого создания", string, "Далее", "Отмена");
        }
    }
}

case dialog_CREATE + 5:
{
    if(response == DIALOG_RESPONSE_CANCEL)
    {
        PT[playerid][pCreate] = 0;
        PT[playerid][pTempDialogData] = 0;
        return 0;
    }

    new fraction = PT[playerid][pTempDialogData][0];
    PT[playerid][pTempDialogData][1] = listitem;
    SCMF(playerid, -1, "PT[playerid][pTempDialogData][1]: %d", PT[playerid][pTempDialogData][1]);

    ShowPlayerDialogEx(playerid, dialog_CREATE + 6, DIALOG_STYLE_LIST_TEXT, GetVehicleName(Fraction_Vehicles[fraction][listitem][fvModel]), "Выберите действие которое хотите сделать с автомобилем:\nСменить цвета\nСменить позицию\nСменить ранг доступа\nСменить организацию", "Далее", "Отмена");
}

case dialog_CREATE + 6:
{
    new fraction = PT[playerid][pTempDialogData][0];

    if(response == DIALOG_RESPONSE_CANCEL)
    {
        if(totalFractionVehicles[fraction] <= 0) return SendErr(playerid, "Машины для этой фракции не созданы!");
        new string[MAX_FRACTION_VEHICLES * 50] = "Номер\tМодель\tID на сервере\tРанг\n";
        new frac_string[64];

        for(new i = 0; i < totalFractionVehicles[fraction]; i++)
        {
            format(frac_string, sizeof frac_string, "%d.\t%s (%d)\t%d\t%d\n",
                i + 1,
                GetVehicleName(Fraction_Vehicles[fraction][i][fvModel]),
                Fraction_Vehicles[fraction][i][fvModel],
                Fraction_Vehicles[fraction][i][fvServerID],
                CI[Fraction_Vehicles[fraction][i][fvServerID]][vRankAvaiable]
            );
            strcat(string, frac_string);
        }
        delEscapeChar(string);
        ShowPlayerDialogEx(playerid, dialog_CREATE + 5, DIALOG_STYLE_TABLIST_HEADERS, "Меню фракционого создания", string, "Далее", "Отмена");
        return 0;
    }


    switch(listitem)
    {
        case 0:
        {
            ShowPlayerDialogEx(playerid, dialog_CREATE + 7, DIALOG_STYLE_INPUT, "Изменения цвета", "Введите первый и второй цвет автомобиля через запятую (например: 201, 4):", "Ввести", "Отмена", "Назад");
        }
        case 1:
        {
            PutPlayerInVehicle(playerid, Fraction_Vehicles[fraction][PT[playerid][pTempDialogData][1]][fvServerID], 0);
            SendClientMessage(playerid, COLOR_LIME, "Используйте:{FFFFFF} /addcar для установки позиции автомобиля");

            PT[playerid][pCreate] = 2;
            PT[playerid][pSubCreate] = Fraction_Vehicles[fraction][PT[playerid][pTempDialogData][1]][fvServerID];
        }
    }
}

case dialog_CREATE + 7:
{
    if(response == DIALOG_RESPONSE_CANCEL)
    {
        PT[playerid][pCreate] = 0;
        PT[playerid][pTempDialogData] = 0;
        return 0;
    }

    new fraction = PT[playerid][pTempDialogData][0];

    if(response == DIALOG_RESPONSE_MIDDLE)
    {
        if(totalFractionVehicles[fraction] <= 0) return SendErr(playerid, "Машины для этой фракции не созданы!");
        new string[MAX_FRACTION_VEHICLES * 50] = "Номер\tМодель\tID на сервере\tРанг\n";
        new frac_string[64];

        for(new i = 0; i < totalFractionVehicles[fraction]; i++)
        {
            format(frac_string, sizeof frac_string, "%d.\t%s (%d)\t%d\t%d\n",
                i + 1,
                GetVehicleName(Fraction_Vehicles[fraction][i][fvModel]),
                Fraction_Vehicles[fraction][i][fvModel],
                Fraction_Vehicles[fraction][i][fvServerID],
                CI[Fraction_Vehicles[fraction][i][fvServerID]][vRankAvaiable]
            );
            strcat(string, frac_string);
        }
        delEscapeChar(string);
        ShowPlayerDialogEx(playerid, dialog_CREATE + 5, DIALOG_STYLE_TABLIST_HEADERS, "Меню фракционого создания", string, "Далее", "Отмена");
        return 0;
    }

    SendClientMessage(playerid, -1, inputtext);
    new color1, color2;
    if(sscanf(inputtext, "p<,>dd", color1, color2)) return ShowPlayerDialogEx(playerid, dialog_CREATE + 5, DIALOG_STYLE_INPUT, "Изменения цвета", "Введите первый и второй цвет автомобиля через запятую (например: 201, 4):", "Ввести", "Отмена", "Назад");
    if((1 > color1 > 255) || (1 > color2 > 255)) return ShowPlayerDialogEx(playerid, dialog_CREATE + 5, DIALOG_STYLE_INPUT, "Изменения цвета", "Введите первый и второй цвет автомобиля через запятую (например: 201, 4) \n- Примечание: введите номер цвета от 1 до 255:", "Ввести", "Отмена", "Назад");

    new vehicleid = Fraction_Vehicles[fraction][PT[playerid][pTempDialogData][1]][fvServerID];

    Fraction_Vehicles[fraction][PT[playerid][pTempDialogData][1]][fvColor1] = color1;
    Fraction_Vehicles[fraction][PT[playerid][pTempDialogData][1]][fvColor2] = color2;

    ChangeVehicleColor(vehicleid, color1, color2);

    new query[] = "UPDATE `fractions_vehicles` SET `fraction_veh_color1` = %d, `fraction_veh_color2` = %d WHERE `veh_id` = %d";
    new fmt_query[sizeof query + 4 + 4 + 4];
    
    mysql_format(dbHandle, fmt_query, sizeof fmt_query, query, Fraction_Vehicles[fraction][PT[playerid][pTempDialogData][1]][fvColor1], Fraction_Vehicles[fraction][PT[playerid][pTempDialogData][1]][fvColor2], Fraction_Vehicles[fraction][PT[playerid][pTempDialogData][1]][fvDBID]);
    mysql_tquery(dbHandle, fmt_query, "");

    new a_string[144];
    format(a_string, sizeof a_string, "[A] %s %s сменил цвет транспорту организации %s (%s [%d]) на цвета %d и %d", GetPrefix(playerid), GetName(playerid), GetFractionName(fraction), GetVehicleName(Fraction_Vehicles[fraction][PT[playerid][pTempDialogData][1]][fvModel]), Fraction_Vehicles[fraction][PT[playerid][pTempDialogData][1]][fvModel], color1, color2);
    SendAdminMessage(COLOR_GRAY, a_string);
    SCMF(playerid, -1, "vehicleid: %d", vehicleid);
    SCMF(playerid, -1, "PT[playerid][pTempDialogData][1]: %d", PT[playerid][pTempDialogData][1]);
}
case dialog_FLATS:
{
    if(response == DIALOG_RESPONSE_CANCEL) return 0;
    new porch = PT[playerid][pTempDialogData];
    new h = PorchInfo[porch][pFirstFlat] + listitem;

    new text[200];
    if(PorchHouseInfo[h][hOwnerID] > 0)
        format(text, sizeof text, "Квартира №%d\nВладелец: %s\nЦена: %d руб.\nОплата: %d руб/ч", PorchHouseInfo[h][hID], PorchHouseInfo[h][hOwner], PorchHouseInfo[h][hPrice], PorchHouseInfo[h][hPay]);
    else
        format(text, sizeof text, "Квартира №%d\nСвободна\nЦена: %d руб.\nОплата: %d руб/ч", PorchHouseInfo[h][hID], PorchHouseInfo[h][hPrice], PorchHouseInfo[h][hPay]);

    ShowPlayerDialogEx(playerid, dialog_FLATS+1, DIALOG_STYLE_MSGBOX, "Информация о квартире", text, "Закрыть", "");
    return 1;
}
case dialog_FLATS+1: return 1;
