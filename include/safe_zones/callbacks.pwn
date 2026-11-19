callback::LoadSafeZones()
{
    new rows, count = GetTickCount();
    cache_get_row_count(rows);
    if(rows <= 0) return print("[LoadSafeZones] Безопасные зоны не были загружены");

    for(new i = 0; i < rows; i++)
    {
        cache_get_value_name_float(i, "szPos_x", SafeZone[i][szPos_x]);
        cache_get_value_name_float(i, "szPos_y", SafeZone[i][szPos_y]);
        cache_get_value_name_float(i, "szPos_z", SafeZone[i][szPos_z]);
        cache_get_value_name_float(i, "szSize", SafeZone[i][szSize]);

        cache_get_value_name_int(i, "szWorld", SafeZone[i][szWorld]);
        
        SafeZone[i][szAreaID] = CreateDynamicSphere(SafeZone[i][szPos_x], SafeZone[i][szPos_y], SafeZone[i][szPos_z], SafeZone[i][szSize], SafeZone[i][szWorld]);
    }
    printf("[LoadSafeZones] Было загружено %d безопасных зон(ы) за %d мс.", rows, GetTickCount() - count);
    return 1;
}
