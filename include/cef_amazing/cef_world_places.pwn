forward CEF_FinesCanRegisterVehicle(playerid);

#if defined _cef_world_places_included
    #endinput
#endif
#define _cef_world_places_included












#define MAX_DEALERS          20
#define MAX_DEALER_CARS      12

#define DIALOG_DYN_PARKING    30700
#define DIALOG_DYN_RENT       30701
#define DIALOG_DYN_DEALER     30702
#define DIALOG_DYN_DEALER_CAR 30703
#define DIALOG_DYN_BUY        30704


#define PARK_IX -2066.3630
#define PARK_IY -836.9244
#define PARK_IZ 2004.2372
#define PARK_IA 178.6599
#define PARK_PX -2059.4307
#define PARK_PY -834.3557
#define PARK_PZ 2004.2372
#define PARK_CX -2059.8999
#define PARK_CY -859.7182
#define PARK_CZ 2004.4637

new gDealerCount;
new gDealerDbId[MAX_DEALERS];
new gDealerName[MAX_DEALERS][40];
new Float:gDealerX[MAX_DEALERS];
new Float:gDealerY[MAX_DEALERS];
new Float:gDealerZ[MAX_DEALERS];
new Float:gDealerA[MAX_DEALERS];
new gDealerPickup[MAX_DEALERS];
new gDealerArea[MAX_DEALERS];
new Text3D:gDealerLabel[MAX_DEALERS];

new gDealerCarCount[MAX_DEALERS];
new gDealerCarDbId[MAX_DEALERS][MAX_DEALER_CARS];
new gDealerCarModel[MAX_DEALERS][MAX_DEALER_CARS];
new gDealerCarPrice[MAX_DEALERS][MAX_DEALER_CARS];
new gDealerCarVeh[MAX_DEALERS][MAX_DEALER_CARS];

new gRentIndex[MAX_PLAYERS];
new gBuyDealer[MAX_PLAYERS];
new gBuySlot[MAX_PLAYERS];
new gBuyCarOwner[MAX_PLAYERS];

stock DynWorld_Admin(playerid)
{
    return PI[playerid][pAdmin] >= 6;
}



forward DynWorld_OnParkingLoaded();
public DynWorld_OnParkingLoaded()
{


    for(new i = 0; i < totalParking; i++)
    {
        for(new k = 0; k < 3; k++)
        {
            if(gParkPickup[i][k] != -1 && IsValidDynamicPickup(gParkPickup[i][k])) DestroyDynamicPickup(gParkPickup[i][k]);
            gParkPickup[i][k] = -1;
        }
        if(parking[i][parking_area] != -1 && IsValidDynamicArea(parking[i][parking_area])) DestroyDynamicArea(parking[i][parking_area]);
        if(parking[i][parking_e_area] != -1 && IsValidDynamicArea(parking[i][parking_e_area])) DestroyDynamicArea(parking[i][parking_e_area]);
        if(parking[i][parking_e_area_car] != -1 && IsValidDynamicArea(parking[i][parking_e_area_car])) DestroyDynamicArea(parking[i][parking_e_area_car]);
        parking[i][parking_area] = -1;
        parking[i][parking_e_area] = -1;
        parking[i][parking_e_area_car] = -1;
    }

    new rows = cache_num_rows();
    totalParking = 0;

    for(new i = 0; i < rows && i < MAX_PARKING; i++)
    {
        cache_get_value_name_int(i, "id", parking[i][parking_dbId]);
        cache_get_value_name_int(i, "vw", parking[i][parking_Vw]);
        if(parking[i][parking_Vw] <= 0) parking[i][parking_Vw] = PARKING_VW_BASE + parking[i][parking_dbId];

        cache_get_value_name_float(i, "Vx", parking[i][parking_Vx]);
        cache_get_value_name_float(i, "Vy", parking[i][parking_Vy]);
        cache_get_value_name_float(i, "Vz", parking[i][parking_Vz]);

        cache_get_value_name_float(i, "Ex", parking[i][parking_Ex]);
        cache_get_value_name_float(i, "Ey", parking[i][parking_Ey]);
        cache_get_value_name_float(i, "Ez", parking[i][parking_Ez]);
        cache_get_value_name_float(i, "Ea", parking[i][parking_Ea]);

        cache_get_value_name_float(i, "ix", parking[i][parking_e_ix]);
        cache_get_value_name_float(i, "iy", parking[i][parking_e_iy]);
        cache_get_value_name_float(i, "iz", parking[i][parking_e_iz]);
        cache_get_value_name_float(i, "ia", parking[i][parking_e_ia]);

        cache_get_value_name_float(i, "px", parking[i][parking_e_px]);
        cache_get_value_name_float(i, "py", parking[i][parking_e_py]);
        cache_get_value_name_float(i, "pz", parking[i][parking_e_pz]);

        cache_get_value_name_float(i, "carx", parking[i][parking_e_pick_carX]);
        cache_get_value_name_float(i, "cary", parking[i][parking_e_pick_carY]);
        cache_get_value_name_float(i, "carz", parking[i][parking_e_pick_carZ]);


        gParkPickup[i][0] = CreateDynamicPickup(19134, 23, parking[i][parking_Vx], parking[i][parking_Vy], parking[i][parking_Vz], 0);
        CreateDynamicMapIcon(parking[i][parking_Vx], parking[i][parking_Vy], parking[i][parking_Vz], 36, 0, 0, -1, -1, 250.0);
        parking[i][parking_area] = CreateDynamicSphere(parking[i][parking_Vx], parking[i][parking_Vy], parking[i][parking_Vz], 2.0);


        gParkPickup[i][1] = CreateDynamicPickup(11783, 23, parking[i][parking_e_px], parking[i][parking_e_py], parking[i][parking_e_pz], parking[i][parking_Vw]);
        parking[i][parking_e_area] = CreateDynamicSphere(parking[i][parking_e_px], parking[i][parking_e_py], parking[i][parking_e_pz], 2.0, parking[i][parking_Vw]);

        gParkPickup[i][2] = CreateDynamicPickup(11681, 23, parking[i][parking_e_pick_carX], parking[i][parking_e_pick_carY], parking[i][parking_e_pick_carZ], parking[i][parking_Vw]);
        parking[i][parking_e_area_car] = CreateDynamicSphere(parking[i][parking_e_pick_carX], parking[i][parking_e_pick_carY], parking[i][parking_e_pick_carZ], 1.0, parking[i][parking_Vw]);

        totalParking++;
    }
    printf("[DYN-PARKING] loaded %d", totalParking);
    return 1;
}

stock DynWorld_CreateParking(playerid, const name[])
{
    new Float:x, Float:y, Float:z, Float:a, query[512];
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);
    mysql_format(dbHandle, query, sizeof query,
        "INSERT INTO `parking_spots` (`name`,`Vx`,`Vy`,`Vz`,`Ex`,`Ey`,`Ez`,`Ea`,`ix`,`iy`,`iz`,`ia`,`px`,`py`,`pz`,`carx`,`cary`,`carz`,`vw`) \
         VALUES ('%e', %.4f,%.4f,%.4f, %.4f,%.4f,%.4f,%.4f, %.4f,%.4f,%.4f,%.4f, %.4f,%.4f,%.4f, %.4f,%.4f,%.4f, %d)",
        name,
        x, y, z, x, y, z, a,
        PARK_IX, PARK_IY, PARK_IZ, PARK_IA,
        PARK_PX, PARK_PY, PARK_PZ,
        PARK_CX, PARK_CY, PARK_CZ,
        0);
    mysql_tquery(dbHandle, query, "DynWorld_OnParkingInserted", "i", playerid);
    return 1;
}

forward DynWorld_OnParkingInserted(playerid);
public DynWorld_OnParkingInserted(playerid)
{

    new nid = cache_insert_id();
    new qw[128];
    mysql_format(dbHandle, qw, sizeof qw, "UPDATE `parking_spots` SET `vw` = %d + `id` WHERE `id` = %d", PARKING_VW_BASE, nid);
    mysql_tquery(dbHandle, qw, "", "");
    mysql_tquery(dbHandle,
        "SELECT `id`,`name`,`Vx`,`Vy`,`Vz`,`Ex`,`Ey`,`Ez`,`Ea`,`ix`,`iy`,`iz`,`ia`,`px`,`py`,`pz`,`carx`,`cary`,`carz`,`vw` FROM `parking_spots` ORDER BY `id`",
        "DynWorld_OnParkingLoaded", "");
    if(IsPlayerConnected(playerid))
        SendClientMessage(playerid, 0x54B367FF, "[DYN] Parking sozdana (BD + pikapy).");
    return 1;
}



forward DynWorld_OnRentLoaded();
public DynWorld_OnRentLoaded()
{
    for(new i = 0; i < totalRent; i++)
    {
        if(gRentPickup[i] != -1 && IsValidDynamicPickup(gRentPickup[i])) DestroyDynamicPickup(gRentPickup[i]);
        gRentPickup[i] = -1;
        if(ArendInfo[i][p_area] != -1 && IsValidDynamicArea(ArendInfo[i][p_area])) DestroyDynamicArea(ArendInfo[i][p_area]);
        ArendInfo[i][p_area] = -1;
        if(gRentLabel[i] != Text3D:0) { Delete3DTextLabel(gRentLabel[i]); gRentLabel[i] = Text3D:0; }
    }

    new rows = cache_num_rows();
    totalRent = 0;

    for(new i = 0; i < rows && i < MAX_RENT; i++)
    {
        cache_get_value_name_int(i, "id", ArendInfo[i][p_dbId]);
        cache_get_value_name_int(i, "vw", ArendInfo[i][p_vw]);
        cache_get_value_name_int(i, "model", ArendInfo[i][p_arenda_car]);
        cache_get_value_name_int(i, "price", ArendInfo[i][p_arenda_price]);
        cache_get_value_name_float(i, "x", ArendInfo[i][p_arenda_X]);
        cache_get_value_name_float(i, "y", ArendInfo[i][p_arenda_Y]);
        cache_get_value_name_float(i, "z", ArendInfo[i][p_arenda_Z]);

        gRentPickup[i] = CreateDynamicPickup(12705, 23, ArendInfo[i][p_arenda_X], ArendInfo[i][p_arenda_Y], ArendInfo[i][p_arenda_Z], ArendInfo[i][p_vw]);
        ArendInfo[i][p_area] = CreateDynamicSphere(ArendInfo[i][p_arenda_X], ArendInfo[i][p_arenda_Y], ArendInfo[i][p_arenda_Z], 1.0, ArendInfo[i][p_vw]);
        gRentLabel[i] = Create3DTextLabel("Arenda transporta", -1, ArendInfo[i][p_arenda_X], ArendInfo[i][p_arenda_Y], ArendInfo[i][p_arenda_Z] + 0.5, 15.0, ArendInfo[i][p_vw]);
        totalRent++;
    }
    printf("[DYN-RENT] loaded %d", totalRent);
    return 1;
}

stock DynWorld_CreateRentPoint(playerid, model, price)
{
    if(model < 400 || model > 611) return SendErr(playerid, "model 400..611");
    if(price < 1) price = 250;
    new Float:x, Float:y, Float:z, query[256];
    GetPlayerPos(playerid, x, y, z);
    mysql_format(dbHandle, query, sizeof query,
        "INSERT INTO `rent_points` (`name`,`x`,`y`,`z`,`model`,`price`,`vw`) VALUES ('Rent', %.4f,%.4f,%.4f, %d, %d, %d)",
        x, y, z, model, price, GetPlayerVirtualWorld(playerid));
    mysql_tquery(dbHandle, query, "DynWorld_OnRentInserted", "i", playerid);
    return 1;
}

forward DynWorld_OnRentInserted(playerid);
public DynWorld_OnRentInserted(playerid)
{
    mysql_tquery(dbHandle, "SELECT `id`,`x`,`y`,`z`,`model`,`price`,`vw` FROM `rent_points` ORDER BY `id`", "DynWorld_OnRentLoaded", "");
    if(IsPlayerConnected(playerid))
        SendClientMessage(playerid, 0x54B367FF, "[DYN] Tochka arendy sozdana.");
    return 1;
}



forward DynWorld_OnDealersLoaded();
public DynWorld_OnDealersLoaded()
{
    for(new i = 0; i < gDealerCount; i++)
    {
        for(new s = 0; s < gDealerCarCount[i]; s++)
        {
            if(IsValidVehicle(gDealerCarVeh[i][s])) DestroyVehicle(gDealerCarVeh[i][s]);
            gDealerCarVeh[i][s] = 0;
        }
        if(gDealerPickup[i] != -1 && IsValidDynamicPickup(gDealerPickup[i])) DestroyDynamicPickup(gDealerPickup[i]);
        gDealerPickup[i] = -1;
        if(gDealerArea[i] != -1 && IsValidDynamicArea(gDealerArea[i])) DestroyDynamicArea(gDealerArea[i]);
        gDealerArea[i] = -1;
        if(gDealerLabel[i] != Text3D:0) { Delete3DTextLabel(gDealerLabel[i]); gDealerLabel[i] = Text3D:0; }
        gDealerCarCount[i] = 0;
    }

    new rows = cache_num_rows();
    gDealerCount = 0;

    for(new i = 0; i < rows && i < MAX_DEALERS; i++)
    {
        cache_get_value_name_int(i, "id", gDealerDbId[i]);
        cache_get_value_name(i, "name", gDealerName[i], 40);
        cache_get_value_name_float(i, "x", gDealerX[i]);
        cache_get_value_name_float(i, "y", gDealerY[i]);
        cache_get_value_name_float(i, "z", gDealerZ[i]);
        cache_get_value_name_float(i, "a", gDealerA[i]);

        gDealerPickup[i] = CreateDynamicPickup(19134, 23, gDealerX[i], gDealerY[i], gDealerZ[i], 0);
        CreateDynamicMapIcon(gDealerX[i], gDealerY[i], gDealerZ[i], 55, 0, 0, -1, -1, 250.0);
        gDealerArea[i] = CreateDynamicSphere(gDealerX[i], gDealerY[i], gDealerZ[i], 2.5);
        gDealerLabel[i] = Create3DTextLabel(gDealerName[i], 0x54B367FF, gDealerX[i], gDealerY[i], gDealerZ[i] + 0.8, 20.0, 0);
        gDealerCount++;
    }
    printf("[DYN-DEALER] loaded dealers %d", gDealerCount);
    mysql_tquery(dbHandle, "SELECT `id`,`dealer_id`,`model`,`price`,`x`,`y`,`z`,`a` FROM `car_dealership_cars` ORDER BY `dealer_id`,`id`", "DynWorld_OnDealerCarsLoaded", "");
    return 1;
}

forward DynWorld_OnDealerCarsLoaded();
public DynWorld_OnDealerCarsLoaded()
{
    new rows = cache_num_rows();
    new did, idx, model, price, dbid, Float:x, Float:y, Float:z, Float:a;

    for(new c = 0; c < rows; c++)
    {
        cache_get_value_name_int(c, "id", dbid);
        cache_get_value_name_int(c, "dealer_id", did);
        cache_get_value_name_int(c, "model", model);
        cache_get_value_name_int(c, "price", price);
        cache_get_value_name_float(c, "x", x);
        cache_get_value_name_float(c, "y", y);
        cache_get_value_name_float(c, "z", z);
        cache_get_value_name_float(c, "a", a);

        idx = -1;
        for(new d = 0; d < gDealerCount; d++) if(gDealerDbId[d] == did) { idx = d; break; }
        if(idx < 0) continue;
        if(gDealerCarCount[idx] >= MAX_DEALER_CARS) continue;

        new s = gDealerCarCount[idx];
        gDealerCarDbId[idx][s] = dbid;
        gDealerCarModel[idx][s] = model;
        gDealerCarPrice[idx][s] = price;
        if(IsValidVehicle(gDealerCarVeh[idx][s])) DestroyVehicle(gDealerCarVeh[idx][s]);
        gDealerCarVeh[idx][s] = CreateVehicle(model, x, y, z, a, 1, 1, 3600);
        SetVehicleParamsCarDoors(gDealerCarVeh[idx][s], 0, 0, 0, 0);
        gDealerCarCount[idx]++;
    }
    printf("[DYN-DEALER] loaded showroom cars %d", rows);
    return 1;
}

stock DynWorld_NearestDealer(playerid, Float:maxdist = 3.5)
{
    new Float:x, Float:y, Float:z, Float:d, Float:bd = maxdist, best = -1;
    GetPlayerPos(playerid, x, y, z);
    for(new i = 0; i < gDealerCount; i++)
    {
        d = floatsqroot((x - gDealerX[i]) * (x - gDealerX[i]) + (y - gDealerY[i]) * (y - gDealerY[i]) + (z - gDealerZ[i]) * (z - gDealerZ[i]));
        if(d < bd) { bd = d; best = i; }
    }
    return best;
}

stock DynWorld_CreateDealer(playerid, const name[])
{
    if(gDealerCount >= MAX_DEALERS) return SendErr(playerid, "limit salonov 20");
    new Float:x, Float:y, Float:z, Float:a, query[256];
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);
    mysql_format(dbHandle, query, sizeof query,
        "INSERT INTO `car_dealerships` (`name`,`x`,`y`,`z`,`a`) VALUES ('%e', %.4f, %.4f, %.4f, %.4f)",
        name, x, y, z, a);
    mysql_tquery(dbHandle, query, "DynWorld_OnDealerInserted", "i", playerid);
    return 1;
}

forward DynWorld_OnDealerInserted(playerid);
public DynWorld_OnDealerInserted(playerid)
{
    mysql_tquery(dbHandle, "SELECT `id`,`name`,`x`,`y`,`z`,`a` FROM `car_dealerships` ORDER BY `id`", "DynWorld_OnDealersLoaded", "");
    if(IsPlayerConnected(playerid))
        SendClientMessage(playerid, 0x54B367FF, "[DYN] Avtosalon sozdan.");
    return 1;
}

stock DynWorld_CreateDealerCar(playerid, dealerid, model, price)
{
    if(model < 400 || model > 611) return SendErr(playerid, "model 400..611");
    if(price < 1) return SendErr(playerid, "ukazhi cenu (price > 0)");
    new di = -1;
    for(new d = 0; d < gDealerCount; d++) if(gDealerDbId[d] == dealerid) { di = d; break; }
    if(di < 0) return SendErr(playerid, "net takogo salona (sm. /listdealers)");
    if(gDealerCarCount[di] >= MAX_DEALER_CARS) return SendErr(playerid, "v salone uzhe 12 mashin");

    new Float:x, Float:y, Float:z, Float:a, query[320];
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);
    mysql_format(dbHandle, query, sizeof query,
        "INSERT INTO `car_dealership_cars` (`dealer_id`,`model`,`price`,`x`,`y`,`z`,`a`,`color1`,`color2`) VALUES (%d, %d, %d, %.4f, %.4f, %.4f, %.4f, 1, 1)",
        dealerid, model, price, x, y, z, a);
    mysql_tquery(dbHandle, query, "DynWorld_OnDealerCarInserted", "i", playerid);
    return 1;
}

forward DynWorld_OnDealerCarInserted(playerid);
public DynWorld_OnDealerCarInserted(playerid)
{
    mysql_tquery(dbHandle, "SELECT `id`,`name`,`x`,`y`,`z`,`a` FROM `car_dealerships` ORDER BY `id`", "DynWorld_OnDealersLoaded", "");
    if(IsPlayerConnected(playerid))
        SendClientMessage(playerid, 0x54B367FF, "[DYN] Mashina vystavlena v salon.");
    return 1;
}

stock DynWorld_DeleteDealer(playerid, dealerid)
{
    new di = -1;
    for(new d = 0; d < gDealerCount; d++) if(gDealerDbId[d] == dealerid) { di = d; break; }
    if(di < 0) return SendErr(playerid, "net takogo salona");
    for(new s = 0; s < gDealerCarCount[di]; s++)
        if(IsValidVehicle(gDealerCarVeh[di][s])) DestroyVehicle(gDealerCarVeh[di][s]);
    new q[160];
    mysql_format(dbHandle, q, sizeof q, "DELETE FROM `car_dealership_cars` WHERE `dealer_id` = %d", dealerid);
    mysql_tquery(dbHandle, q, "", "");
    mysql_format(dbHandle, q, sizeof q, "DELETE FROM `car_dealerships` WHERE `id` = %d", dealerid);
    mysql_tquery(dbHandle, q, "DynWorld_OnDealerInserted", "i", playerid);
    return 1;
}

stock DynWorld_ListDealers(playerid)
{
    new msg[160];
    for(new d = 0; d < gDealerCount; d++)
    {
        format(msg, sizeof msg, "[SALON] id %d | %s | mashin %d | %.1f %.1f %.1f", gDealerDbId[d], gDealerName[d], gDealerCarCount[d], gDealerX[d], gDealerY[d], gDealerZ[d]);
        SendClientMessage(playerid, 0x54B367FF, msg);
    }
    if(!gDealerCount) SendErr(playerid, "salonov net");
    return 1;
}


stock DynWorld_OpenDealer(playerid, di)
{
    if(di < 0 || di >= gDealerCount) return 0;
    gBuyDealer[playerid] = di;
    new list[1600], temp[96];
    list[0] = EOS;
    for(new s = 0; s < gDealerCarCount[di]; s++)
    {
        if(gDealerCarPrice[di][s] <= 0) continue;
        format(temp, sizeof temp, "%s\t%d rub.\n", GetVehicleName(gDealerCarModel[di][s]), gDealerCarPrice[di][s]);
        strcat(list, temp);
    }
    if(!strlen(list)) return SendErr(playerid, "V salone net mashin s cenoy");
    ShowPlayerDialogEx(playerid, DIALOG_DYN_BUY, DIALOG_STYLE_TABLIST, gDealerName[di], list, "Kupit", "Otkaz");
    return 1;
}

stock DynWorld_BuyCar(playerid, di, slot)
{
    if(!CEF_FinesCanRegisterVehicle(playerid)) return 1;
    if(di < 0 || di >= gDealerCount) return SendErr(playerid, "net salona");
    if(slot < 0 || slot >= gDealerCarCount[di]) return SendErr(playerid, "net mashiny");
    if(gDealerCarPrice[di][slot] <= 0) return SendErr(playerid, "cena ne ustanovlena");

    new price = gDealerCarPrice[di][slot];
    if(!CEF_EcoPay(playerid, price))
        return SendErr(playerid, "Nedostatochno deneg (nalichnye + bank)");

    gBuyDealer[playerid] = di;
    gBuySlot[playerid] = slot;

    new model = gDealerCarModel[di][slot];
    gBuyCarOwner[playerid] = PI[playerid][pID];




    new q[512];
    mysql_format(dbHandle, q, sizeof q,
        "INSERT INTO `cars` (`owner_id`,`model`,`color1`,`color2`,`fuel`,`strobs`,`number`,`region`,`number_type`,`neon`,`neon_color1`,`neon_color2`,`neon_color3`,`neon_alpha`,`mileage`,`audio_system`) \
         VALUES (%d, %d, 1, 1, 50, 0, 'Tranzit', '52', 0, 0, 0, 0, 0, 0, 0, 0)",
        gBuyCarOwner[playerid], model);
    mysql_tquery(dbHandle, q, "DynWorld_OnCarBought", "i", playerid);


    if(IsValidVehicle(PI[playerid][pCar])) DestroyVehicle(PI[playerid][pCar]);
    new vid = CreateVehicle(model, gDealerX[di] + 3.0, gDealerY[di], gDealerZ[di], gDealerA[di], 1, 1, 3600);
    PI[playerid][pCar] = vid;
    CI[vid][Fuel] = 50;
    CI[vid][Engine] = 0;
    CI[vid][Lights] = 0;
    SetVehicleNumberPlate(vid, "Bez nomerov");
    SetVehicleParamsEx(vid, 0, 0, 0, 0, 0, 0, 0);
    PutPlayerInVehicle(playerid, vid, 0);

    new msg[144];
    format(msg, sizeof msg, "[SALON] %s kupil %s. Mashina v garazhe (TAB).", GetName(playerid), GetVehicleName(model));
    SendClientMessage(playerid, 0x54B367FF, msg);
    SendClientMessage(playerid, 0x54B367FF, "[SALON] Tablichki/nomera i tyuning - cherez shtatnye sistemy (TAB).");
    return 1;
}

forward DynWorld_OnCarBought(playerid);
public DynWorld_OnCarBought(playerid)
{
    printf("[SALON] avto zapisano v BD: cars.id=%d owner_id=%d", cache_insert_id(), gBuyCarOwner[playerid]);
    return 1;
}


forward DynWorld_EnsureCarIds();
public DynWorld_EnsureCarIds()
{
    mysql_tquery(dbHandle,
        "SELECT (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'cars' AND COLUMN_NAME = 'id' AND EXTRA LIKE '%auto_increment%') AS ai, \
                (SELECT COUNT(*) FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'cars' AND INDEX_NAME = 'PRIMARY') AS pk FROM DUAL",
        "DynWorld_OnCarIdsChecked", "");
    return 1;
}

forward DynWorld_OnCarIdsChecked();
public DynWorld_OnCarIdsChecked()
{
    new ai = 1, pk = 1, q[192];
    if(cache_num_rows() > 0)
    {
        cache_get_value_name_int(0, "ai", ai);
        cache_get_value_name_int(0, "pk", pk);
    }
    if(ai && pk) return 1;

    printf("[DYN] cars: ai=%d pk=%d -> ispravlyayu shemu", ai, pk);
    if(!pk && !ai)
        mysql_tquery(dbHandle, "ALTER TABLE `cars` MODIFY `id` INT NOT NULL AUTO_INCREMENT, ADD PRIMARY KEY (`id`)", "DynWorld_OnCarAlter", "");
    else if(!pk)
        mysql_tquery(dbHandle, "ALTER TABLE `cars` ADD PRIMARY KEY (`id`)", "DynWorld_OnCarAlter", "");
    else
        mysql_tquery(dbHandle, "ALTER TABLE `cars` MODIFY `id` INT NOT NULL AUTO_INCREMENT", "DynWorld_OnCarAlter", "");
    return 1;
}

forward DynWorld_OnCarAlter();
public DynWorld_OnCarAlter()
{


    printf("[DYN] cars schema alter: %s", (cache_num_rows() || 1) ? "OK" : "?");
    return 1;
}

forward DynWorld_OnAreaEnter(playerid, areaid);
public DynWorld_OnAreaEnter(playerid, areaid)
{
    for(new d = 0; d < gDealerCount; d++)
    {
        if(areaid != gDealerArea[d]) continue;
        if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return 1;
        DynWorld_OpenDealer(playerid, d);
        return 1;
    }
    return 0;
}



stock DynWorld_MenuItem(playerid, listitem)
{
    switch(listitem)
    {
        case 13: ShowPlayerDialogEx(playerid, DIALOG_DYN_PARKING, DIALOG_STYLE_INPUT, "Parkovka", "nazvanie parkovki:", "OK", "X");
        case 14: ShowPlayerDialogEx(playerid, DIALOG_DYN_RENT, DIALOG_STYLE_INPUT, "Arenda", "model cena\nprimer: 462 250", "OK", "X");
        case 15: ShowPlayerDialogEx(playerid, DIALOG_DYN_DEALER, DIALOG_STYLE_INPUT, "Avtosalon", "nazvanie salona:", "OK", "X");
        case 16: ShowPlayerDialogEx(playerid, DIALOG_DYN_DEALER_CAR, DIALOG_STYLE_INPUT, "Mashina v salon", "id_salona model cena\nprimer: 1 411 500000", "OK", "X");
    }
    return 1;
}

stock DynWorld_OnDialog(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == DIALOG_DYN_PARKING)
    {
        if(!response) return 1;
        if(!strlen(inputtext)) return SendErr(playerid, "pustoe nazvanie");
        DynWorld_CreateParking(playerid, inputtext);
        return 1;
    }
    if(dialogid == DIALOG_DYN_RENT)
    {
        if(!response) return 1;
        new model, price;
        if(sscanf(inputtext, "dd", model, price)) return SendErr(playerid, "model cena");
        DynWorld_CreateRentPoint(playerid, model, price);
        return 1;
    }
    if(dialogid == DIALOG_DYN_DEALER)
    {
        if(!response) return 1;
        if(!strlen(inputtext)) return SendErr(playerid, "pustoe nazvanie");
        DynWorld_CreateDealer(playerid, inputtext);
        return 1;
    }
    if(dialogid == DIALOG_DYN_DEALER_CAR)
    {
        if(!response) return 1;
        new did, model, price;
        if(sscanf(inputtext, "ddd", did, model, price)) return SendErr(playerid, "id_salona model cena");
        DynWorld_CreateDealerCar(playerid, did, model, price);
        return 1;
    }
    if(dialogid == DIALOG_DYN_BUY)
    {
        if(!response) return 1;

        new di = gBuyDealer[playerid];
        if(di < 0 || di >= gDealerCount) di = DynWorld_NearestDealer(playerid, 5.0);
        if(di < 0) return SendErr(playerid, "Salon nedostupen");
        new cnt = -1;
        for(new s = 0; s < gDealerCarCount[di]; s++)
        {
            if(gDealerCarPrice[di][s] <= 0) continue;
            cnt++;
            if(cnt == listitem) { DynWorld_BuyCar(playerid, di, s); return 1; }
        }
        return 1;
    }
    return 0;
}


CMD:createparking(playerid, params[])
{
    if(!DynWorld_Admin(playerid)) return SendErr(playerid, "Nuzhen admin 6+");
    new name[40];
    if(sscanf(params, "s[40]", name)) return SendErr(playerid, "/createparking [nazvanie]");
    return DynWorld_CreateParking(playerid, name);
}

CMD:createrent(playerid, params[])
{
    if(!DynWorld_Admin(playerid)) return SendErr(playerid, "Nuzhen admin 6+");
    new model, price;
    if(sscanf(params, "dD(250)", model, price)) return SendErr(playerid, "/createrent [model] [cena]");
    return DynWorld_CreateRentPoint(playerid, model, price);
}

CMD:createdealer(playerid, params[])
{
    if(!DynWorld_Admin(playerid)) return SendErr(playerid, "Nuzhen admin 6+");
    new name[40];
    if(sscanf(params, "s[40]", name)) return SendErr(playerid, "/createdealer [nazvanie]");
    return DynWorld_CreateDealer(playerid, name);
}

CMD:createdealercar(playerid, params[])
{
    if(!DynWorld_Admin(playerid)) return SendErr(playerid, "Nuzhen admin 6+");
    new did, model, price;
    if(sscanf(params, "ddd", did, model, price)) return SendErr(playerid, "/createdealercar [id_salona] [model] [cena]");
    return DynWorld_CreateDealerCar(playerid, did, model, price);
}

CMD:deldealer(playerid, params[])
{
    if(!DynWorld_Admin(playerid)) return SendErr(playerid, "Nuzhen admin 6+");
    new did;
    if(sscanf(params, "d", did)) return SendErr(playerid, "/deldealer [id]");
    return DynWorld_DeleteDealer(playerid, did);
}

CMD:listdealers(playerid, params[])
{
    #pragma unused params
    if(!DynWorld_Admin(playerid)) return SendErr(playerid, "Nuzhen admin 6+");
    return DynWorld_ListDealers(playerid);
}



forward DynWorld_Init();
public DynWorld_Init()
{


    for(new i = 0; i < MAX_PARKING; i++)
    {
        for(new k = 0; k < 3; k++) gParkPickup[i][k] = -1;
        parking[i][parking_area] = -1;
        parking[i][parking_e_area] = -1;
        parking[i][parking_e_area_car] = -1;
    }
    for(new i = 0; i < MAX_RENT; i++)
    {
        gRentPickup[i] = -1;
        ArendInfo[i][p_area] = -1;
        gRentLabel[i] = Text3D:0;
    }
    for(new i = 0; i < MAX_DEALERS; i++)
    {
        gDealerPickup[i] = -1;
        gDealerArea[i] = -1;
        gDealerLabel[i] = Text3D:0;
        for(new s = 0; s < MAX_DEALER_CARS; s++) gDealerCarVeh[i][s] = 0;
    }
    totalParking = 0;
    totalRent = 0;
    gDealerCount = 0;

    mysql_tquery(dbHandle,
        "CREATE TABLE IF NOT EXISTS `parking_spots` (`id` INT NOT NULL AUTO_INCREMENT, `name` VARCHAR(40) NOT NULL DEFAULT '', `Vx` FLOAT NOT NULL, `Vy` FLOAT NOT NULL, `Vz` FLOAT NOT NULL, `Ex` FLOAT NOT NULL, `Ey` FLOAT NOT NULL, `Ez` FLOAT NOT NULL, `Ea` FLOAT NOT NULL DEFAULT 0, `ix` FLOAT NOT NULL, `iy` FLOAT NOT NULL, `iz` FLOAT NOT NULL, `ia` FLOAT NOT NULL DEFAULT 0, `px` FLOAT NOT NULL, `py` FLOAT NOT NULL, `pz` FLOAT NOT NULL, `carx` FLOAT NOT NULL, `cary` FLOAT NOT NULL, `carz` FLOAT NOT NULL, `vw` INT NOT NULL DEFAULT 0, PRIMARY KEY (`id`)) ENGINE=InnoDB DEFAULT CHARSET=cp1251",
        "", "");


    mysql_tquery(dbHandle,
        "INSERT IGNORE INTO `parking_spots` (`id`,`name`,`Vx`,`Vy`,`Vz`,`Ex`,`Ey`,`Ez`,`Ea`,`ix`,`iy`,`iz`,`ia`,`px`,`py`,`pz`,`carx`,`cary`,`carz`,`vw`) VALUES \
         (1,'Parkovka LS', 1940.2545,2033.5909,13.2788, 1923.2852,2033.5428,15.8750,359.9608, -2066.3630,-836.9244,2004.2372,178.6599, -2059.4307,-834.3557,2004.2372, -2059.8999,-859.7182,2004.4637, 101), \
         (2,'Parkovka SF', 451.2792,1712.9032,9.4106, 467.6765,1713.1969,12.0078,173.8864, -2066.3630,-836.9244,2004.2372,178.6599, -2059.4307,-834.3557,2004.2372, -2059.8999,-859.7182,2004.4637, 102)",
        "", "");
    mysql_tquery(dbHandle, "SELECT `id`,`name`,`Vx`,`Vy`,`Vz`,`Ex`,`Ey`,`Ez`,`Ea`,`ix`,`iy`,`iz`,`ia`,`px`,`py`,`pz`,`carx`,`cary`,`carz`,`vw` FROM `parking_spots` ORDER BY `id`", "DynWorld_OnParkingLoaded", "");

    mysql_tquery(dbHandle,
        "CREATE TABLE IF NOT EXISTS `rent_points` (`id` INT NOT NULL AUTO_INCREMENT, `name` VARCHAR(40) NOT NULL DEFAULT '', `x` FLOAT NOT NULL, `y` FLOAT NOT NULL, `z` FLOAT NOT NULL, `model` INT NOT NULL DEFAULT 462, `price` INT NOT NULL DEFAULT 250, `vw` INT NOT NULL DEFAULT 0, PRIMARY KEY (`id`)) ENGINE=InnoDB DEFAULT CHARSET=cp1251",
        "", "");

    mysql_tquery(dbHandle,
        "INSERT IGNORE INTO `rent_points` (`id`,`name`,`x`,`y`,`z`,`model`,`price`,`vw`) VALUES \
         (1,'Arenda LS', 1873.7175,2140.2478,15.8713, 462, 250, 0), \
         (2,'Arenda SF', 1194.5521,1352.2885,11.1723, 462, 250, 0)",
        "", "");
    mysql_tquery(dbHandle, "SELECT `id`,`x`,`y`,`z`,`model`,`price`,`vw` FROM `rent_points` ORDER BY `id`", "DynWorld_OnRentLoaded", "");

    mysql_tquery(dbHandle,
        "CREATE TABLE IF NOT EXISTS `car_dealerships` (`id` INT NOT NULL AUTO_INCREMENT, `name` VARCHAR(40) NOT NULL DEFAULT 'Avtosalon', `x` FLOAT NOT NULL, `y` FLOAT NOT NULL, `z` FLOAT NOT NULL, `a` FLOAT NOT NULL DEFAULT 0, PRIMARY KEY (`id`)) ENGINE=InnoDB DEFAULT CHARSET=cp1251",
        "", "");
    mysql_tquery(dbHandle,
        "CREATE TABLE IF NOT EXISTS `car_dealership_cars` (`id` INT NOT NULL AUTO_INCREMENT, `dealer_id` INT NOT NULL, `model` INT NOT NULL, `price` INT NOT NULL DEFAULT 0, `x` FLOAT NOT NULL, `y` FLOAT NOT NULL, `z` FLOAT NOT NULL, `a` FLOAT NOT NULL DEFAULT 0, `color1` INT NOT NULL DEFAULT 1, `color2` INT NOT NULL DEFAULT 1, PRIMARY KEY (`id`)) ENGINE=InnoDB DEFAULT CHARSET=cp1251",
        "", "");

    mysql_tquery(dbHandle,
        "INSERT IGNORE INTO `car_dealerships` (`id`,`name`,`x`,`y`,`z`,`a`) VALUES (1,'Avtosalon LS', 2081.0295,1879.0118,15.9179,64.1639)",
        "", "");
    mysql_tquery(dbHandle, "SELECT `id`,`name`,`x`,`y`,`z`,`a` FROM `car_dealerships` ORDER BY `id`", "DynWorld_OnDealersLoaded", "");


    DynWorld_EnsureCarIds();

    printf("[DYN] parking/rent/dealer schema init");
    return 1;
}
