CMD:audio_on(playerid, params[])
{
    if (                                                     GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
        return SendClientMessage(playerid, COLOR_GRAY, "В вашем транспорте не установлена аудиосистема.");

    extract params -> new trackID, string:link[256] = 0; else return SendClientMessage(playerid, COLOR_LIME, "Использование: /audio_on [номер (1-8)] [ссылка (необязательно)]");

    new vehicleid = GetPlayerVehicleID(playerid);
    CI[vehicleid][vAudio] = 1;
    if(!IsValidObject(CI[vehicleid][vAudioObj])) CI[vehicleid][vAudioObj] = CreateObject(1, 0, 0, 0, 0, 0, 0);
    AttachObjectToVehicle(CI[vehicleid][vAudioObj], vehicleid, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0);

    new audioUrl[256];
    switch (trackID)
    {
        case 0:
        {
            if (!strlen(link))
                return SendClientMessage(playerid, COLOR_LIME, "Использование: /audio_on [номер (1-8)] или [ссылка]");
            format(audioUrl, sizeof(audioUrl), "%s", link);
        }
        case 1: audioUrl = "http://unmazing.cretsan-host.ru/music/SoGood.mp3";
        case 2: audioUrl = "http://unmazing.cretsan-host.ru/music/cricket.mp3";
        case 3: audioUrl = "http://unmazing.cretsan-host.ru/music/GORILLA GLUE, LIL NAKUR - Браги два бидона.mp3";
        case 4: audioUrl = "http://unmazing.cretsan-host.ru/music/worldwide_flex.mp3";
        case 5: audioUrl = "http://unmazing.cretsan-host.ru/music/one_thousand_of_eyes.mp3";
        case 6: audioUrl = "http://unmazing.cretsan-host.ru/music/my_fault.mp3";
        case 7: audioUrl = "http://unmazing.cretsan-host.ru/music/wronng.mp3";
        case 8: audioUrl = "http://unmazing.cretsan-host.ru/music/lover2007.mp3";
        default: return 1;
    }

    format(CI[vehicleid][vAudioUrl], 256, "%s", audioUrl);
    CI[vehicleid][vAudioStart] = gettime();

    new Float: x, Float: y, Float: z;
    GetVehiclePos(vehicleid, x, y, z);
    CI[vehicleid][vAudioArea] = CreateDynamicSphere(x, y, z, 30.0);
    AttachDynamicAreaToVehicle(CI[vehicleid][vAudioArea], vehicleid);
    if(IsValidDynamic3DTextLabel(CI[vehicleid][vAudioLabel])) UpdateDynamic3DTextLabelText(CI[vehicleid][vAudioLabel], 0xFFFFFFFF, "Аудиосистема\n{99cc00}Играет");
    else CI[vehicleid][vAudioLabel] = CreateDynamic3DTextLabel("Аудиосистема\n{99cc00}Играет", 0xFFFFFFFF, x, y, z, 20.0, INVALID_PLAYER_ID, vehicleid);
    
    SetVehiclePos(vehicleid, x, y, z+0.01);
    
    new msg[128];
    format(msg, sizeof(msg), "Включено аудио в транспорте: %s", "скрыто", audioUrl);
    SendClientMessage(playerid, COLOR_LIME, msg);
    return 1;
}

cmd:lock(playerid, params[])
{
    extract params -> new type; else return SendClientMessage(playerid, COLOR_LIME, "Используйте:{FFFFFF} /lock [1/2][1 - личный транспорт | 2 -  арендованный / организации]");

    new Float:car_x, Float:car_y, Float:car_z, carid = PI[playerid][pCar];
    if(type == 1)
    {
        GetVehiclePos(carid, car_x, car_y, car_z);
        if(!IsPlayerInRangeOfPoint(playerid, 3.0, car_x, car_y, car_z)) return SendErr(playerid, "Нужно находится рядом с автомобилем.");
        GetVehicleParamsEx(carid, CI[carid][Engine], CI[carid][Lights], CI[carid][Alarm], CI[carid][Doors], CI[carid][Bonnet], CI[carid][Boot], CI[carid][Objective]);
        
        CI[carid][Doors] = !CI[carid][Doors];

        SetVehicleParamsEx(carid, CI[carid][Engine], CI[carid][Lights], CI[carid][Alarm], CI[carid][Doors], CI[carid][Bonnet], CI[carid][Boot], CI[carid][Objective]);

        SCMF(playerid, COLOR_LIME, "Транспорт %s", CI[carid][Doors] ? ("закрыт") : ("открыт"));
    }
    else if(type == 2)
    {
        carid = PI[playerid][pArendID];
        GetVehiclePos(carid, car_x, car_y, car_z);
        if(!IsPlayerInRangeOfPoint(playerid, 3.0, car_x, car_y, car_z)) return SendErr(playerid, "Нужно находится рядом с автомобилем.");
        GetVehicleParamsEx(carid, CI[carid][Engine], CI[carid][Lights], CI[carid][Alarm], CI[carid][Doors], CI[carid][Bonnet], CI[carid][Boot], CI[carid][Objective]);
        
        CI[carid][Doors] = !CI[carid][Doors];

        SetVehicleParamsEx(carid, CI[carid][Engine], CI[carid][Lights], CI[carid][Alarm], CI[carid][Doors], CI[carid][Bonnet], CI[carid][Boot], CI[carid][Objective]);

        SCMF(playerid, COLOR_LIME, "Транспорт %s", CI[carid][Doors] ? ("закрыт") : ("открыт"));
    }
    return 1;
}

cmd:en(playerid)
{
    if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return 1;

    new vehicleid = GetPlayerVehicleID(playerid);
    if(!CI[vehicleid][Fuel]) return SendErr(playerid, "В транспорте закончился бензин");


    GetVehicleParamsEx(vehicleid, CI[vehicleid][Engine], CI[vehicleid][Lights], CI[vehicleid][Alarm], CI[vehicleid][Doors], CI[vehicleid][Bonnet], CI[vehicleid][Boot], CI[vehicleid][Objective]);
    CI[vehicleid][Engine] = !CI[vehicleid][Engine];
    SetVehicleParamsEx(vehicleid, CI[vehicleid][Engine], CI[vehicleid][Lights], CI[vehicleid][Alarm], CI[vehicleid][Doors], CI[vehicleid][Bonnet], CI[vehicleid][Boot], CI[vehicleid][Objective]);
    cef_emit_event(playerid, "game:SetSpeedEngine", CEFINT(CI[vehicleid][Engine]));
    return 1;
}

CMD:fixcar(playerid)
{
    if(GetPlayerHouseID(playerid) == 0)
        return SendErr(playerid, "Игроки без домов могут доставлять транспорт только на паркинге!");

    new query[140];
    mysql_format(dbHandle, query, sizeof(query), "SELECT * FROM `cars` WHERE `owner_id` = %d", PI[playerid][pID]);
    mysql_tquery(dbHandle, query, "OnPlayerFixCar", "i", playerid);
    return 1;
}


cmd:vtoning_apply(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;

    new vehicleid = GetPlayerVehicleID(playerid);
    if(!IsValidVehicle(vehicleid) || GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
        return 1;
    if(PI[playerid][pCar] != vehicleid) return 1;

    new id_str[8], r_str[8], g_str[8], b_str[8], a_str[8];
    if(sscanf(params, "p<,>s[8]s[8]s[8]s[8]s[8]", id_str, r_str, g_str, b_str, a_str))
        return 1;

    new r = strval(r_str);
    new g = strval(g_str);
    new b = strval(b_str);
    new a = strval(a_str);


    if(r < 0) r = 0; if(r > 255) r = 255;
    if(g < 0) g = 0; if(g > 255) g = 255;
    if(b < 0) b = 0; if(b > 255) b = 255;
    if(a < 0) a = 0; if(a > 255) a = 255;

    CI[vehicleid][vToningToggled] = true;
    CI[vehicleid][vToningR] = r;
    CI[vehicleid][vToningG] = g;
    CI[vehicleid][vToningB] = b;
    CI[vehicleid][vToningA] = a;

    ApplyToningToVehicle(vehicleid, r, g, b, a);


    new query[128];
    mysql_format(dbHandle, query, sizeof(query),
        "UPDATE `cars` SET `toning`=1, `toning_r`=%d, `toning_g`=%d, `toning_b`=%d, `toning_a`=%d WHERE `owner_id`=%d LIMIT 1",
        r, g, b, a, PI[playerid][pID]);
    mysql_tquery(dbHandle, query, "", "");

    SendClientMessage(playerid, COLOR_UNMAZING, "Тонировка применена и сохранена!");
    return 1;
}

cmd:vtoning_remove(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;

    new vehicleid = GetPlayerVehicleID(playerid);
    if(!IsValidVehicle(vehicleid) || GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
        return 1;
    if(PI[playerid][pCar] != vehicleid) return 1;

    CI[vehicleid][vToningToggled] = false;
    CI[vehicleid][vToningR] = CI[vehicleid][vToningG] = CI[vehicleid][vToningB] = CI[vehicleid][vToningA] = 0;

    RemoveToningFromVehicle(vehicleid);

    new query[64];
    mysql_format(dbHandle, query, sizeof(query),
        "UPDATE `cars` SET `toning`=0, `toning_r`=0, `toning_g`=0, `toning_b`=0, `toning_a`=0 WHERE `owner_id`=%d LIMIT 1",
        PI[playerid][pID]);
    mysql_tquery(dbHandle, query, "", "");

    SendClientMessage(playerid, COLOR_GRAY, "Тонировка снята.");
    return 1;
}
