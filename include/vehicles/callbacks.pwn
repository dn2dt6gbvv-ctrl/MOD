

callback::OnPlayerFixCar(playerid)
{
    if (cache_num_rows() == 0)
    {
        return SendErr(playerid, "У вас нет автомобилей.");
    }

    new temp[60], str[1024], model, str_number[20], number[12], region[4], number_type;

    for (new c = 0; c < cache_num_rows(); c++)
    {
        cache_get_value_name_int(c, "model", model);
        cache_get_value_name(c, "number", number, sizeof(number));
        cache_get_value_name(c, "region", region, sizeof(region));
        cache_get_value_name_int(c, "number_type", number_type);

        switch (number_type)
        {
            case 0: format(str_number, sizeof str_number, "Без номеров");
            case 1: format(str_number, sizeof str_number, "%s RU%s", number, region);
            case 2: format(str_number, sizeof str_number, "%s%s", region, number);
        }

        format(temp, sizeof temp, "%s\t%s\n", GetVehicleName(model), str_number);
        strcat(str, temp);
    }

    ShowPlayerDialogEx(playerid, dialog_FIXCAR, DIALOG_STYLE_LIST, "Автомобили", str, "Выбрать", "Отмена");
    return 1;
}

callback::OnPlayerFixCarSelected(playerid, carindex)
{
    new id, model, str_number[20], number[7], region[3], number_type, color_1, color_2, fuel, mileage, audio;

    cache_get_value_name_int(carindex, "id", id);
    cache_get_value_name(carindex, "number", number);
    cache_get_value_name(carindex, "region", region);
    cache_get_value_name_int(carindex, "number_type", number_type);

    cache_get_value_name_int(carindex, "model", model);
    cache_get_value_name_int(carindex, "fuel", fuel);
    cache_get_value_name_int(carindex, "color1", color_1);
    cache_get_value_name_int(carindex, "color2", color_2);

    cache_get_value_name_int(carindex, "audio_system", audio);

    cache_get_value_name_int(carindex, "mileage", mileage);
    
    switch(number_type)
    {
        case 0: str_number = "Без номеров";
        case 1: format(str_number, sizeof str_number, "%s RU%s", number, region);
        case 2: format(str_number, sizeof str_number, "%s%s", region, number);
    }

    if(IsValidVehicle(PI[playerid][pCar])) 
    {
        new query[100];
        mysql_format(dbHandle, query, sizeof(query), 
            "UPDATE cars SET mileage = %d, fuel = %d WHERE id = %d",
            CI[PI[playerid][pCar]][vMileage],
            CI[PI[playerid][pCar]][Fuel],
            id
        );
        mysql_tquery(dbHandle, query, "", "");
        DestroyVehicle(PI[playerid][pCar]);
    }
    new house_id = GetPlayerHouseID(playerid); 
    PI[playerid][pCar] = CreateVehicle(model, House[house_id][hVSPos_x], House[house_id][hVSPos_y], House[house_id][hVSPos_z], House[house_id][hVSPos_a], color_1, color_2, 3600);
    new player_car = PI[playerid][pCar];

    CI[player_car][Fuel] = fuel;
    CI[player_car][Engine] = 0;

    SetVehicleParamsEx(player_car, CI[PI[playerid][pCar]][Engine], CI[PI[playerid][pCar]][Lights], CI[PI[playerid][pCar]][Alarm], CI[PI[playerid][pCar]][Doors], CI[PI[playerid][pCar]][Bonnet], CI[PI[playerid][pCar]][Boot], CI[PI[playerid][pCar]][Engine]);
    SetVehicleNumberPlate(player_car, str_number);

    CI[player_car][vLastPosX] = House[house_id][hVSPos_x];
    CI[player_car][vLastPosY] = House[house_id][hVSPos_y];
    CI[player_car][vLastPosZ] = House[house_id][hVSPos_z];

    CI[player_car][vMileage] = mileage;
    CI[player_car][vAudio] = audio;
    return 1;
}

callback:: OnCarPrepareToUpdate(playerid)
{
    if (!cache_num_rows()) return;

    new id;
    cache_get_value_name_int(0, "id", id);

    new query[100];
    mysql_format(dbHandle, query, sizeof(query), 
        "UPDATE cars SET mileage = %d, fuel = %d WHERE id = %d",
        CI[PI[playerid][pCar]][vMileage],
        CI[PI[playerid][pCar]][Fuel],
        id
    );
    mysql_tquery(dbHandle, query, "", "");

    DestroyVehicle(PI[playerid][pCar]);
    PI[playerid][pCar] = 0;
}

callback:: OnPlayerCarSave(playerid)
{
    if (!cache_num_rows()) return;

    new id;
    cache_get_value_name_int(0, "id", id);

    new query[100];
    mysql_format(dbHandle, query, sizeof(query),
        "UPDATE cars SET mileage = %d, fuel = %d WHERE id = %d",
        CI[PI[playerid][pCar]][vMileage],
        CI[PI[playerid][pCar]][Fuel],
        id
    );
    mysql_tquery(dbHandle, query, "", "");

    SendErr(playerid, "Ваш транспорт был отправлен на стоянку.");
    DestroyVehicle(PI[playerid][pCar]);
    PI[playerid][pCar] = 0;
}

callback:: OnPlayerCarsReceived(playerid)
{
    if(PI[playerid][pCash] < 10000) return SendErr(playerid, "У Вас недостаточно денег");
    if(cache_num_rows() <= 0) return SendErr(playerid, "У Вас нет транспорта");

    for(new i = 0; i < sizeof parking_places; i++)
    {
        if(IsVehicleAtPoint(parking_places[i][parking_Px], parking_places[i][parking_Py], parking_places[i][parking_Pz], PT[playerid][pParkingID])) continue;
        new parkingid = PT[playerid][pParkingID];

        new id, model, str_number[20], number[7], region[3], number_type, color_1, color_2, fuel, mileage, audio, player_car = PI[playerid][pCar];

        cache_get_value_name_int(0, "id", id);
        
        cache_get_value_name(0, "number", number);
        cache_get_value_name(0, "region", region);
        cache_get_value_name_int(0, "number_type", number_type);

        cache_get_value_name_int(0, "model", model);
        cache_get_value_name_int(0, "fuel", fuel);
        cache_get_value_name_int(0, "color1", color_1);
        cache_get_value_name_int(0, "color2", color_2);

        cache_get_value_name_int(0, "audio_system", audio);

        cache_get_value_name_int(0, "mileage", mileage);
        switch(number_type)
        {
            case 0: str_number = "Без номеров";
            case 1: format(str_number, sizeof str_number, "%s RU%s", number, region);
            case 2: format(str_number, sizeof str_number, "%s%s", region, number);
        }

        if(IsValidVehicle(player_car)) 
        {
            new query[100];
            mysql_format(dbHandle, query, sizeof(query), 
                "UPDATE cars SET mileage = %d, fuel = %d WHERE id = %d",
                CI[PI[playerid][pCar]][vMileage],
                CI[PI[playerid][pCar]][Fuel],
                id
            );
            DestroyVehicle(player_car);
        }

        PI[playerid][pCar] = CreateVehicle(model, parking_places[i][parking_Px], parking_places[i][parking_Py], parking_places[i][parking_Pz], parking_places[i][parking_Pa], color_1, color_2, 3600);
        player_car = PI[playerid][pCar];

        SetVehicleVirtualWorld(player_car, parkingid);
        CI[player_car][Engine] = 0;
        SetVehicleParamsEx(player_car, CI[player_car][Engine], CI[player_car][Lights], CI[player_car][Alarm], CI[player_car][Doors], CI[player_car][Bonnet], CI[player_car][Boot], CI[player_car][Engine]);
        SetVehicleNumberPlate(player_car, str_number);

        CI[player_car][vLastPosX] = parking_places[i][parking_Px];
        CI[player_car][vLastPosY] = parking_places[i][parking_Py];
        CI[player_car][vLastPosZ] = parking_places[i][parking_Pz];

        CI[player_car][vMileage] = mileage;
        CI[player_car][vAudio] = audio;
        CI[player_car][Fuel] = fuel;

        TransferMoney(playerid, -1, 10000, "Получение автомобиля с парковки");
        PT[playerid][pParkingID] = -1;

        return 1;
    }
    return SendErr(playerid, "На паркинге нет свободных мест");
}

stock IsVehicleAtPoint(Float:x, Float:y, Float:z, vw, Float:range = 3.0)
{
    new Float:vehX, Float:vehY, Float:vehZ;
    for (new v = 1; v < MAX_VEHICLES; v++)
    {
        if (!IsValidVehicle(v)) continue;

        if (GetVehicleVirtualWorld(v) != vw) continue;

        GetVehiclePos(v, vehX, vehY, vehZ);

        if (GetDistanceBetweenCoords(x, y, z, vehX, vehY, vehZ) <= range)
            return 1;
    }
    return 0;
}

stock GetVehicleName(id)
{
    new name[40];
    switch(id)
    {
        case 400: name = "BMW X5 E53";
        case 401: name = "Ford Focus III Hatchback";
        case 402: name = "Mercedes-Benz E63 W212";
        case 403: name = "Тягач Volvo FH16";
        case 404: name = "Renault Logan II";
        case 405: name = "Lamborghini Aventador";
        case 406: name = "Грузовик Tedom Fox";
        case 407: name = "Пожарная Ural Next";
        case 408: name = "Тягач KAMAZ-54901";
        case 409: name = "Rolls-Royce Phantom";
        case 410: name = "Mercedes-Benz AMG GT S 4-Door Coupe";
        case 411: name = "Infiniti Q50";
        case 412: name = "BMW M5 E39";
        case 413: name = "Тягач Renault T";
        case 414: name = "КамАЗ-55111 (Уборщик)";
        case 415: name = "Lamborghini Huracan EVO Spyder";
        case 416: name = "Mercedes-Benz Sprinter 2G (ЕСС)";
        case 417: name = "Грузовой вертолет";
        case 418: name = "Mercedes-Benz Sprinter W907";
        case 419: name = "Nissan Silvia S15";
        case 420: name = "Lexus RX350 F Sport";
        case 421: name = "Mercedes-Benz S600 W140";
        case 422: name = "УАЗ СГР";
        case 423: name = "Wolf Car";
        case 424: name = "Daewoo Matiz M150";
        case 425: name = "Военный вертолет";
        case 426: name = "Mercedes-Maybach S650";
        case 427: name = "ГАЗ-3302 (Полиция)";
        case 428: name = "Volkswagen Transporter T6";
        case 429: name = "Audi RS6 C7";
        case 430: name = "Полицейский катер";
        case 431: name = "МАЗ-203";
        case 432: name = "Танк";
        case 433: name = "Военный Урал-4320 Next";
        case 434: name = "Ford Hot Rod Hotknife 1932";
        case 435: name = "Прицеп";
        case 436: name = "Porsche Taycan";
        case 437: name = "КамАЗ-6282 «Электробус»";
        case 438: name = "Lexus IS300 XE10";
        case 439: name = "ВАЗ-2105";
        case 440: name = "УАЗ-3303";
        case 441: name = "RC Bandit";
        case 442: name = "Holden Sandman HQ Panelvan";
        case 443: name = "Packer";
        case 444: name = "Chevrolet Monster";
        case 445: name = "Renault Megane II";
        case 446: name = "Катер Squalo III";
        case 447: name = "Вертолет";
        case 448: name = "Скутер Pizzaboy";
        case 449: name = "Вагон";
        case 450: name = "Прицеп";
        case 451: name = "Porsche 911 991";
        case 452: name = "Катер";
        case 453: name = "Яхта «Альтаир»";
        case 454: name = "Яхта «Тропик»";
        case 455: name = "Эвакуатор ГАЗель Next";
        case 456: name = "MAN TGL";
        case 457: name = "Гольфкар";
        case 458: name = "ВАЗ-2114";
        case 459: name = "GMC Vandura";
        case 460: name = "Самолет AH 2B";
        case 461: name = "Мотоцикл Ява 350";
        case 462: name = "Скутер";
        case 463: name = "Harley-Davidson FLHRXS";
        case 464: name = "Самолетик RC";
        case 465: name = "Вертолет RC";
        case 466: name = "BMW M5 F90";
        case 467: name = "LR Range Rover Velar L560";
        case 468: name = "Мотоцикл KTM 350 EXC-F";
        case 469: name = "Robinson R-22";
        case 470: name = "УАЗ-3163 «Patriot»";
        case 471: name = "Квадроцикл";
        case 472: name = "Катер";
        case 473: name = "Моторная лодка";
        case 474: name = "Lada Granta";
        case 475: name = "Bentley Continental GT";
        case 476: name = "Самолет";
        case 477: name = "Toyota Sprinter Trueno IV AE86";
        case 478: name = "ГАЗ-3110";
        case 479: name = "ВАЗ-2110";
        case 480: name = "Audi R8 2G";
        case 481: name = "Велосипед Аист";
        case 482: name = "Volkswagen Multivan T6";
        case 483: name = "НефАЗ-5299";
        case 484: name = "Корабль";
        case 485: name = "Baggage";
        case 486: name = "Бульдозер DUDE";
        case 487: name = "Вертолет Robinson R44";
        case 488: name = "Дирижабль";
        case 489: name = "Cadillac Escalade GMT K2XL";
        case 490: name = "LR Range Rover SVAutobiography L405";
        case 491: name = "Mercedes-Benz E55 AMG W210";
        case 492: name = "ВАЗ-2109";
        case 493: name = "Скоростной катер";
        case 494: name = "Ferrari 488 GTB";
        case 495: name = "Ford F-150 Raptor";
        case 496: name = "ВАЗ-2107";
        case 497: name = "Полицейский вертолет";
        case 498: name = "Ford Mustang Hoonicorn";
        case 499: name = "Ford Transit MK6";
        case 500: name = "УАЗ-3163 «Patriot»";
        case 501: name = "Вертолет RC";
        case 502: name = "Nissan GT-R R35";
        case 503: name = "Mitsubishi Lancer Evo IX";
        case 504: name = "Mercedes-Benz VISION AVTR";
        case 505: name = "Mercedes-Benz GLE 63 AMG";
        case 506: name = "BMW M2";
        case 507: name = "Mercedes-Benz E500 W124";
        case 508: name = "LADA Largus";
        case 509: name = "Электросамокат «Xiaomi»";
        case 510: name = "Велосипед";
        case 511: name = "Самолет Авиафлот";
        case 512: name = "Самолет Cropduster";
        case 513: name = "Самолет Stuntplane";
        case 514: name = "Тягач IVECO Stralis";
        case 515: name = "Тягач Renault Magnum";
        case 516: name = "Honda Civic Type-R EK9";
        case 517: name = "Subaru Legacy BC";
        case 518: name = "Mercedes-Benz V-class W447";
        case 519: name = "Самолет Аэрофлот";
        case 520: name = "Истребитель СУ-47 «Беркут»";
        case 521: name = "Ducati XDiavel S";
        case 522: name = "Ducati Desmosedici RR";
        case 523: name = "Мотоцикл BMW R1200RT";
        case 524: name = "Бензовоз ГАЗон NEXT";
        case 525: name = "Эвакуатор ГАЗон NEXT";
        case 526: name = "Audi S5 B9";
        case 527: name = "Lada Vesta SW";
        case 528: name = "Lunar Rover";
        case 529: name = "ВАЗ-2106";
        case 530: name = "Погрузчик";
        case 531: name = "Трактор";
        case 532: name = "Комбайн";
        case 533: name = "BMW M3 E30";
        case 534: name = "Mazda RX-8";
        case 535: name = "BMW M3 E36";
        case 536: name = "Porsche Cayenne Turbo III";
        case 537: name = InvalidVehicleName;
        case 538: name = InvalidVehicleName;
        case 539: name = InvalidVehicleName;
        case 540: name = "Lada Priora";
        case 541: name = "Mercedes-Benz AMG GTR";
        case 542: name = "Lada 4x4";
        case 543: name = "BMW M3 E46";
        case 544: name = "Mercedes-Benz Atego Magirus";
        case 545: name = "ГАЗ-24 Кабриолет";
        case 546: name = "Volkswagen Golf MKI";
        case 547: name = "ВАЗ-2101";
        case 548: name = "Вертолет МИ8";
        case 549: name = "MINI Cooper S JCW";
        case 550: name = "Toyota Camry (XV50)";
        case 551: name = "Kia Rio FB";
        case 552: name = "УАЗ-469";
        case 553: name = "Самолет СССР-46532";
        case 554: name = "Mitsubishi Pajero V80";
        case 555: name = "ЗАЗ-968M";
        case 556: name = "Monster A";
        case 557: name = "Monster B";
        case 558: name = "Toyota GT86";
        case 559: name = "Dodge Charger SRT Hellcat";
        case 560: name = "Mercedes-Benz C63 W205";
        case 561: name = "Toyota Crown Athlete S";
        case 562: name = "Nissan Skyline GT-R R34";
        case 563: name = "Вертолет МЧС";
        case 564: name = "Танк RC";
        case 565: name = "ВАЗ-2108";
        case 566: name = "ВАЗ-2104";
        case 567: name = "BMW 750iL E38";
        case 568: name = "Can-Am Maverick X3";
        case 569: name = InvalidVehicleName;
        case 570: name = InvalidVehicleName;
        case 571: name = "Kart";
        case 572: name = "Mower";
        case 573: name = "Mercedes-Benz Unimog";
        case 574: name = "Sweeper";
        case 575: name = "ГАЗ-М20";
        case 576: name = "Honda Civic Type-R FK8";
        case 577: name = "Большой самолет Авиафлот";
        case 578: name = "Военный КамАЗ-43118";
        case 579: name = "Mercedes-Benz G65 W463";
        case 580: name = "Toyota Mark II X100";
        case 581: name = "Мотоцикл BMW S1000RR";
        case 582: name = "Ford Econoline 150";
        case 583: name = "Tug";
        case 584: name = "Прицеп-цистерна";
        case 585: name = "Subaru Impreza WRX STI GJ";
        case 586: name = "Мотоцикл KTM 1290 Super Duke R";
        case 587: name = "Mercedes-Benz CLS 400 4MATIC";
        case 588: name = "Автобус ЛиАЗ";
        case 589: name = "Audi TT 8S";
        case 590: name = "Вагон";
        case 591: name = "Прицеп";
        case 592: name = "Andromada";
        case 593: name = "Dodo";
        case 594: name = "RC-Cam";
        case 595: name = "Лодка Launch";
        case 596: name = "Chevrolet Corvette C7";
        case 597: name = "Lada Vesta (Полиция)";
        case 598: name = "Skoda Octavia MK3 (Полиция)";
        case 599: name = "УАЗ-3163 «Patriot» (Полиция)";
        case 600: name = "Toyota Supra A80";
        case 601: name = "БТР";
        case 602: name = "Jaguar F-Type";
        case 603: name = "Dodge Challenger R/T";
        case 604: name = "BMW M5 E60";
        case 605: name = "Bugatti Chiron";
        case 606: name = "«ИС-2»";
        case 607: name = "Panzerkampfwagen VI «Tiger II»";
        case 608: name = "Прицеп";
        case 609: name = "ГАЗон NEXT";
        case 610: name = "Прицеп";
        case 611: name = "Прицеп";
        case 612: name = InvalidVehicleName;
        case 613: name = "Audi RS6 C8";
        default: name = InvalidVehicleName;
    }
    return name;
}

stock IsVehicleBMX(vehicleid)
{
    switch(vehicleid)
    {
        case 481: return 1;
        case 509, 510: return 1;
    }
    return 0;
}


public OnVehicleSpawn(vehicleid)
{
    new player_rent = GetPlayerRentID(vehicleid);
    if(player_rent != INVALID_PLAYER_ID)
    {
        SendErr(player_rent, "Ваш арендованный транспорт был отправлен на стоянку.");
        DestroyVehicle(PI[player_rent][pArendID]);
        PI[player_rent][pArendID] = 0;
        PI[player_rent][pArendTime] = 90;
        HideBHint(player_rent);
    }

    foreach (new i : Player)
    {
        if (!PT[i][pLogged]) continue;
        if (PI[i][pCar] != vehicleid) continue;

        new query[128];
        mysql_format(dbHandle, query, sizeof(query),
            "SELECT id FROM cars WHERE owner_id = %d", PI[i][pID]);

        mysql_tquery(dbHandle, query, "OnPlayerCarSave", "i", i);
        break;
    }

    if(Iter_Contains(adminVehicle, vehicleid))
    {
        Iter_Remove(adminVehicle, vehicleid);
        DestroyVehicle(vehicleid);
    }

    if(IsValidObject(CI[vehicleid][vAudioObj])) DestroyObject(CI[vehicleid][vAudioObj]);
    if(IsValidDynamicArea(CI[vehicleid][vAudioArea])) DestroyDynamicArea(CI[vehicleid][vAudioArea]);
    if(IsValidDynamic3DTextLabel(CI[vehicleid][vAudioLabel])) DestroyDynamic3DTextLabel(CI[vehicleid][vAudioLabel]);
    
    if(CI[vehicleid][vStrobsStatus] != 0) KillTimer(CI[vehicleid][vStrobsTimer]), CI[vehicleid][vStrobsStatus] = 0;
    return 1;
}


callback:: UpdateVehiclesFuel()
{
    for(new i = 1; i < MAX_VEHICLES; i++)
    {
        if(IsVehicleBMX(i)) continue; 
        if(!CI[i][Engine] || CI[i][Fuel] <= 0) continue;

        CI[i][Fuel]--;
        if(CI[i][Fuel] > 0) continue;
        
        GetVehicleParamsEx(i, CI[i][Engine], CI[i][Lights], CI[i][Alarm], CI[i][Doors], CI[i][Bonnet], CI[i][Boot], CI[i][Objective]);
        SetVehicleParamsEx(i, false, CI[i][Lights], CI[i][Alarm], CI[i][Doors], CI[i][Bonnet], CI[i][Boot], CI[i][Objective]);

        CI[i][Engine] = false;
        CI[i][Fuel] = 0;
    }
}

callback:: UpdateVehiclesAudio()
{
    for(new i = 1; i < MAX_VEHICLES; i++)
    {
        if(!IsValidObject(CI[i][vAudioObj])) continue;
        if(gettime() - CI[i][vAudioStart] > 140 && CI[i][vAudioUrl] != 0)
        {
            DestroyObject(CI[i][vAudioObj]);
            DestroyDynamicArea(CI[i][vAudioArea]);
            UpdateDynamic3DTextLabelText(CI[i][vAudioLabel], 0xFFFFFFFF, "Аудиосистема\n{FF0000}На паузе");
            CI[i][vAudioUrl] = CI[i][vAudioStart] = 0;
        }
    }
}


stock CreateVehicle_hooked(modelid, Float:x, Float:y, Float:z, Float:angle, color1, color2, respawn_delay = 60, addsiren = 0)
{
    new vehicleid = CreateVehicle(modelid, x, y, z, angle, color1, color2, respawn_delay, addsiren);
    if(vehicleid <= 0 || vehicleid >= MAX_VEHICLES) return INVALID_VEHICLE_ID;

    CI[vehicleid][vRankAvaiable] = CI[vehicleid][Engine] = CI[vehicleid][Lights] = CI[vehicleid][Doors] = CI[vehicleid][Bonnet] = CI[vehicleid][Boot] = CI[vehicleid][Fuel] = CI[vehicleid][Alarm] = CI[vehicleid][Objective] = CI[vehicleid][vMileage] = 0;
    CI[vehicleid][vLastPosX] = CI[vehicleid][vLastPosY] = CI[vehicleid][vLastPosZ] = 0;

    CI[vehicleid][vOwnerType] = VEHICLE_OWNER_NONE; CI[vehicleid][vOwnerID] = -1;

    if(IsValidObject(CI[vehicleid][vAudioObj])) DestroyObject(CI[vehicleid][vAudioObj]);
    if(IsValidDynamicArea(CI[vehicleid][vAudioArea])) DestroyDynamicArea(CI[vehicleid][vAudioArea]);
    if(IsValidDynamic3DTextLabel(CI[vehicleid][vAudioLabel])) DestroyDynamic3DTextLabel(CI[vehicleid][vAudioLabel]);

    SetVehicleParamsEx(vehicleid, CI[vehicleid][Engine], CI[vehicleid][Lights], CI[vehicleid][Alarm], CI[vehicleid][Doors], CI[vehicleid][Bonnet], CI[vehicleid][Boot], CI[vehicleid][Objective]);
    
    CI[vehicleid][vAudio] = false; CI[vehicleid][vAudioObj] = CI[vehicleid][vAudioUrl] = CI[vehicleid][vAudioStart] = 0;
    
    if(CI[vehicleid][vStrobsStatus] != 0) KillTimer(CI[vehicleid][vStrobsTimer]), CI[vehicleid][vStrobsStatus] = 0;

    if(CI[vehicleid][vNeonToggled] == true) CI[vehicleid][vNeonR] = CI[vehicleid][vNeonG] = CI[vehicleid][vNeonB] = CI[vehicleid][vNeonA] = 0, CI[vehicleid][vNeonToggled] = false;
    if(CI[vehicleid][vToningToggled] == true) CI[vehicleid][vToningR] = CI[vehicleid][vToningG] = CI[vehicleid][vToningB] = CI[vehicleid][vToningA] = 0, CI[vehicleid][vToningToggled] = false;
    if(CI[vehicleid][vSmokeToggled] == true) CI[vehicleid][vSmokeR] = CI[vehicleid][vSmokeG] = CI[vehicleid][vSmokeB] = CI[vehicleid][vSmokeA] = 0, CI[vehicleid][vSmokeToggled] = false;
    if(CI[vehicleid][vCustomLightsToggled] == true) CI[vehicleid][vCustomLightsR] = CI[vehicleid][vCustomLightsG] = CI[vehicleid][vCustomLightsB] = CI[vehicleid][vCustomLightsA] = 0, CI[vehicleid][vCustomLightsToggled] = false;
    
    return vehicleid;
}

#if defined _ALS_CreateVehicle
	#undef CreateVehicle
#else
	#define _ALS_CreateVehicle
#endif
#define	CreateVehicle CreateVehicle_hooked


stock DestroyVehicle_hooked(vehicleid)
{
    if(vehicleid <= 0 || vehicleid >= MAX_VEHICLES || !IsValidVehicle(vehicleid)) return 0;
    DS_OnVehicleDestroyed(vehicleid);
    CI[vehicleid][vRankAvaiable] = CI[vehicleid][Engine] = CI[vehicleid][Lights] = CI[vehicleid][Doors] = CI[vehicleid][Bonnet] = CI[vehicleid][Boot] = CI[vehicleid][Fuel] = CI[vehicleid][Alarm] = CI[vehicleid][Objective] = CI[vehicleid][vMileage] = 0;
    CI[vehicleid][vLastPosX] = CI[vehicleid][vLastPosY] = CI[vehicleid][vLastPosZ] = 0;

    CI[vehicleid][vOwnerType] = VEHICLE_OWNER_NONE; CI[vehicleid][vOwnerID] = -1;

    if(IsValidObject(CI[vehicleid][vAudioObj]))
    {
        DestroyObject(CI[vehicleid][vAudioObj]);
        DestroyDynamicArea(CI[vehicleid][vAudioArea]);
        DestroyDynamic3DTextLabel(CI[vehicleid][vAudioLabel]);
        CI[vehicleid][vAudio] = CI[vehicleid][vAudioObj] = CI[vehicleid][vAudioUrl] = CI[vehicleid][vAudioStart] = 0;
    }
    if(CI[vehicleid][vStrobsStatus] != 0) KillTimer(CI[vehicleid][vStrobsTimer]), CI[vehicleid][vStrobsStatus] = 0;

    if(CI[vehicleid][vToningToggled] == true) CI[vehicleid][vToningR] = CI[vehicleid][vToningG] = CI[vehicleid][vToningB] = CI[vehicleid][vToningA] = 0, CI[vehicleid][vToningToggled] = false;
    if(CI[vehicleid][vNeonToggled] == true) CI[vehicleid][vNeonR] = CI[vehicleid][vNeonG] = CI[vehicleid][vNeonB] = CI[vehicleid][vNeonA] = 0, CI[vehicleid][vNeonToggled] = false;
    if(CI[vehicleid][vSmokeToggled] == true) CI[vehicleid][vSmokeR] = CI[vehicleid][vSmokeG] = CI[vehicleid][vSmokeB] = CI[vehicleid][vSmokeA] = 0, CI[vehicleid][vSmokeToggled] = false;
    if(CI[vehicleid][vCustomLightsToggled] == true) CI[vehicleid][vCustomLightsR] = CI[vehicleid][vCustomLightsG] = CI[vehicleid][vCustomLightsB] = CI[vehicleid][vCustomLightsA] = 0, CI[vehicleid][vCustomLightsToggled] = false;

    return DestroyVehicle(vehicleid);
}
stock ApplyToningToVehicle(vehicleid, r, g, b, a)
{
    new str[64];
    format(str, sizeof str, "{VTONING}SET:%d:%d:%d:%d:%d", vehicleid, r, g, b, a);
    SendClientMessageToAll(-1, str);
}

stock RemoveToningFromVehicle(vehicleid)
{
    new str[32];
    format(str, sizeof str, "{VTONING}CLR:%d", vehicleid);
    SendClientMessageToAll(-1, str);
}

stock SyncToningForPlayer(playerid)
{
    new str[64];
    for(new i = 1; i < MAX_VEHICLES; i++)
    {
        if(!IsValidVehicle(i)) continue;
        if(!CI[i][vToningToggled]) continue;
        format(str, sizeof str, "{VTONING}SYNC:%d:%d:%d:%d:%d",
            i, CI[i][vToningR], CI[i][vToningG], CI[i][vToningB], CI[i][vToningA]);
        SendClientMessage(playerid, -1, str);
    }
}
#if defined _ALS_DestroyVehicle
	#undef DestroyVehicle
#else
	#define _ALS_DestroyVehicle
#endif
#define	DestroyVehicle DestroyVehicle_hooked

forward UpdateNitro();
public UpdateNitro()
{
    foreach(new i : Player)
    {
        if(!IsPlayerInAnyVehicle(i) || GetPlayerState(i) != PLAYER_STATE_DRIVER) continue;

        new vehicleid = GetPlayerVehicleID(i);
        new keys, ud, lr;
        GetPlayerKeys(i, keys, ud, lr);

        if(keys & KEY_FIRE && PlayerNitro[i] > 0.0)
        {
            PlayerNitro[i] -= 0.625;
            
            new n_str[32];
            format(n_str, sizeof(n_str), "~b~NITRO: %.0f%%", PlayerNitro[i]);
            GameTextForPlayer(i, n_str, 300, 3);
            
            if(PlayerNitro[i] <= 0.0) 
            {
                PlayerNitro[i] = 0.0;
                RemoveVehicleComponent(vehicleid, 1010);
            }
        }
        else if(PlayerNitro[i] < 100.0)
        {
            PlayerNitro[i] += 0.375;
            if(PlayerNitro[i] > 100.0) PlayerNitro[i] = 100.0;
        }
    }
    return 1;
}
