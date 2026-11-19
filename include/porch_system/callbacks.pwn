callback::LoadPorchHouse()
{
    cache_get_row_count(totalPorchHouse);
    if(!totalPorchHouse) return print("[LoadPorchHouse] Дома не созданы!");
    new count = GetTickCount();
    for(new idx = 0; idx < totalPorchHouse; ++idx)
    {
        cache_get_value_name_int(idx, "id", PorchHouseInfo[idx][hID]);
        cache_get_value_name_float(idx, "hEntrx", PorchHouseInfo[idx][hEntrx]);
        cache_get_value_name_float(idx, "hEntry", PorchHouseInfo[idx][hEntry]);
        cache_get_value_name_float(idx, "hEntrz", PorchHouseInfo[idx][hEntrz]);
        cache_get_value_name_float(idx, "hEntrFa", PorchHouseInfo[idx][hEntrFa]);
        cache_get_value_name_float(idx, "hSpawn_X", PorchHouseInfo[idx][hSpawn_X]);
        cache_get_value_name_float(idx, "hSpawn_Y", PorchHouseInfo[idx][hSpawn_Y]);
        cache_get_value_name_float(idx, "hSpawn_Z", PorchHouseInfo[idx][hSpawn_Z]);
        cache_get_value_name_float(idx, "hSpawn_Fa", PorchHouseInfo[idx][hSpawn_Fa]);
        cache_get_value_name(idx, "hOwner", PorchHouseInfo[idx][hOwner], MAX_PLAYER_NAME);
        cache_get_value_name_int(idx, "hOwnerID", PorchHouseInfo[idx][hOwnerID]);
        cache_get_value_name_int(idx, "hPrice", PorchHouseInfo[idx][hPrice]);
        cache_get_value_name_int(idx, "hPorch", PorchHouseInfo[idx][hPorch]);
        cache_get_value_name_int(idx, "hLock", PorchHouseInfo[idx][hLock]);
        cache_get_value_name_int(idx, "hClass", PorchHouseInfo[idx][hClass]);
        cache_get_value_name_int(idx, "hPay", PorchHouseInfo[idx][hPay]);
        cache_get_value_name_int(idx, "hBank", PorchHouseInfo[idx][hBank]);
        
        PorchHouseInfo[idx][h_area] = CreateDynamicSphere(
        PorchHouseInfo[idx][hEntrx], 
        PorchHouseInfo[idx][hEntry], 
        PorchHouseInfo[idx][hEntrz], 
        1.0, 
        PorchHouseInfo[idx][hPorch]-1, 0);

        PorchHouseInfo[idx][h_exit_area] = CreateDynamicSphere(-1580.0547,1987.5717,2204.8342, 1.0, idx, 0);
        
        CreateDynamicPickup
        (
            11778, 
            1, 
            -1580.0547,1987.5717,2204.8342, idx, 0
        );
    }
    printf("[LoadPorchHouse] Было загружено %d квартир за %d мс.", totalPorchHouse, GetTickCount() - count);
    return 1;
}

callback::LoadPorch()
{

    CreateDynamicPickup(11778, 23, 601.7584,552.0068,1501.2372, -1, -1);
    CreateDynamicPickup(11776, 23, 599.3630,552.8333,1501.2372, -1, -1);

    CreateDynamicPickup(11778, 23, 200.0524,1105.5558,2501.2371, -1, -1);
    CreateDynamicPickup(11776, 23, 202.5057,1107.7590,2501.2371, -1, -1);
    for(new i = 0; i < sizeof coord_porch_class; i++)
    {
        CreateDynamicPickup(11681, 23, coord_porch_class[i][0], coord_porch_class[i][1], coord_porch_class[i][2], -1, -1);
    }
    for(new i = 0; i < sizeof coord_porch_class_l; i++)
    {
        CreateDynamicPickup(11681, 23, coord_porch_class_l[i][0], coord_porch_class_l[i][1], coord_porch_class_l[i][2], -1, -1);
    }
    
    cache_get_row_count(TOTALPORCH);
    if(!TOTALPORCH) return print("[LoadPorchHouse] Дома не созданы!");
    new count = GetTickCount();
    for(new idx = 0; idx < TOTALPORCH; ++idx)
    {
        cache_get_value_name_int(idx, "id", PorchInfo[idx][pID]);
        cache_get_value_name_float(idx, "pEnterX", PorchInfo[idx][pEnterX]);
        cache_get_value_name_float(idx, "pEnterY", PorchInfo[idx][pEnterY]);
        cache_get_value_name_float(idx, "pEnterZ", PorchInfo[idx][pEnterZ]);
        cache_get_value_name_float(idx, "vxod_x", PorchInfo[idx][penter_X]);
        cache_get_value_name_float(idx, "vxod_y", PorchInfo[idx][penter_Y]);
        cache_get_value_name_float(idx, "vxod_z", PorchInfo[idx][penter_Z]);
        cache_get_value_name_float(idx, "vxod_fa", PorchInfo[idx][penter_Fa]);
        cache_get_value_name_float(idx, "pCarX", PorchInfo[idx][pCarX]);
        cache_get_value_name_float(idx, "pCarY", PorchInfo[idx][pCarY]);
        cache_get_value_name_float(idx, "pCarZ", PorchInfo[idx][pCarZ]);
        cache_get_value_name_float(idx, "pCarA", PorchInfo[idx][pCarA]);
        cache_get_value_name_int(idx, "pFirstFlat", PorchInfo[idx][pFirstFlat]);
        cache_get_value_name_int(idx, "pType", PorchInfo[idx][pType]);
        cache_get_value_name_int(idx, "pMaxPorch", PorchInfo[idx][pMaxPorch]);

        PorchInfo[idx][enter_pickup] = CreateDynamicSphere(PorchInfo[idx][pEnterX], PorchInfo[idx][pEnterY], PorchInfo[idx][pEnterZ], 1.0);
        CreateDynamicPickup(11779, 23, PorchInfo[idx][pEnterX], PorchInfo[idx][pEnterY], PorchInfo[idx][pEnterZ], -1);
        
        switch(PorchInfo[idx][pType])
        {
            case 1:
            {
                PorchInfo[idx][exit_area] = CreateDynamicSphere(601.9421,551.5764,1501.2372, 1.0, idx, 0);
                PorchInfo[idx][menu_area] = CreateDynamicSphere(599.3630,552.8333,1501.2372, 1.0, idx, 0);
            }
            case 2:
            {
                PorchInfo[idx][exit_area] = CreateDynamicSphere(200.0524,1105.5558,2501.2371, 1.0, idx, 0);
                PorchInfo[idx][menu_area] = CreateDynamicSphere(202.5057,1107.7590,2501.2371, 1.0, idx, 0);
            }
            default: return 1;
        }
        PorchInfo[idx][pMIcon] = CreateDynamicMapIcon(PorchInfo[idx][pEnterX], PorchInfo[idx][pEnterY], PorchInfo[idx][pEnterZ], 40, 0, -1, -1, -1, 100.0);
    }
    printf("[LoadPorch] Было загружено %d подъезд(-a/ов) за %d мс.", TOTALPORCH, GetTickCount() - count);
    return 1;
}
stock ShowPHouseInfo(playerid, idx) 
{
    new owner[24];
    if(PorchHouseInfo[idx][hOwnerID] == 0) settext(owner, "Государство");
    else settext(owner, PorchHouseInfo[idx][hOwner]);
    cef_emit_event(playerid, "game:ShowHouseInfo", CEFINT(PorchHouseInfo[idx][hID]), CEFINT(PorchHouseInfo[idx][hLock]), CEFSTR(owner), CEFINT(PorchHouseInfo[idx][hPrice]), CEFINT(PorchHouseInfo[idx][hPay]), CEFINT(PorchHouseInfo[idx][hClass]));
    return 1;
}
