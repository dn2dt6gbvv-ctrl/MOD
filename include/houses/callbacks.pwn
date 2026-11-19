
callback:: LoadHouses()
{
    cache_get_row_count(total_houses);
    if(!total_houses) return print("[LoadHouses] Дома не созданы!");
    new count = GetTickCount();
    for(new h = 0; h < total_houses; ++h)
    {
        cache_get_value_name_int(h, "id", House[h][hID]);
        cache_get_value_name_int(h, "price", House[h][hPrice]);
        cache_get_value_name_int(h, "class", House[h][hClass]);
        cache_get_value_name_int(h, "lock", House[h][hLock]);
        cache_get_value_name_int(h, "pay", House[h][hPay]);
        cache_get_value_name_int(h, "hours", House[h][hHours]);
        cache_get_value_name_int(h, "owner_id", House[h][hOwnerID]);

        cache_get_value_name(h, "owner_name", House[h][hOwner], MAX_PLAYER_NAME);

        cache_get_value_name_float(h, "pos_x", House[h][hPos_x]);
        cache_get_value_name_float(h, "pos_y", House[h][hPos_y]);
        cache_get_value_name_float(h, "pos_z", House[h][hPos_z]);

        cache_get_value_name_float(h, "vs_posx", House[h][hVSPos_x]);
        cache_get_value_name_float(h, "vs_posy", House[h][hVSPos_y]);
        cache_get_value_name_float(h, "vs_posz", House[h][hVSPos_z]);
        cache_get_value_name_float(h, "vs_posa", House[h][hVSPos_a]);

        if(!strcmp(House[h][hOwner], "None", true)) 
        {
            House[h][hPickup] = CreatePickup(11776, 23, House[h][hPos_x], House[h][hPos_y], House[h][hPos_z]);
            House[h][hMapIcon] = CreateDynamicMapIcon(House[h][hPos_x], House[h][hPos_y], House[h][hPos_z], 31, 0,-1,-1,-1,150.0);
        }
        else { 
            House[h][hPickup] = CreatePickup(11780, 23, House[h][hPos_x], House[h][hPos_y], House[h][hPos_z]);
            House[h][hMapIcon] = CreateDynamicMapIcon(House[h][hPos_x], House[h][hPos_y], House[h][hPos_z], 32, 0,-1,-1,-1,150.0);
        }

        CreatePickup(11778, 23, House_Interiors[House[h][hClass]][hIPos_X], House_Interiors[House[h][hClass]][hIPos_Y], House_Interiors[House[h][hClass]][hIPos_Z], House[h][hID]);
        CreatePickup(11784, 23, House[h][hVSPos_x], House[h][hVSPos_y], House[h][hVSPos_z]+0.42);

        House[h][hAreaExit] = CreateDynamicSphere(House_Interiors[House[h][hClass]][hIPos_X], House_Interiors[House[h][hClass]][hIPos_Y], House_Interiors[House[h][hClass]][hIPos_Z], 1, House[h][hID]);
        House[h][hArea] = CreateDynamicSphere(House[h][hPos_x], House[h][hPos_y], House[h][hPos_z], 1.5);
        House[h][hAreaSpawnVehicle] = CreateDynamicSphere(House[h][hPos_x], House[h][hPos_y], House[h][hPos_z], 5.0);
    }
    printf("[LoadHouses] Было загружено %d дом(-a/ов) за %d мс.", total_houses, GetTickCount() - count);
    return 1;
}

stock ShowHouseInfo(playerid, _h) 
{
    new owner[24];
    if(!strcmp(House[_h][hOwner], "none", true)) settext(owner, "Государство");
    else settext(owner, House[_h][hOwner]);
    cef_emit_event(playerid, "game:ShowHouseInfo", CEFINT(House[_h][hID]), CEFINT(House[_h][hLock]), CEFSTR(owner), CEFINT(House[_h][hPrice]), CEFINT(House[_h][hPay]), CEFINT(House[_h][hClass]));
    return 1;
}

stock bool: IsValidHouse(_h)
{
    if(_h < 0 || _h >= total_houses || House[_h][hID] <= 0) return false; 
    return true;
}
