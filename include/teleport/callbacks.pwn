callback::LoadTeleportPickups()
{
	new rows, count = GetTickCount();
	cache_get_row_count(rows);

	if(rows <= 0) return print("[LoadTeleportPickups] Пикапы телепортации не были загружены");

	new bool:IsShown = false;

	for(new i = 0; i < rows; i++)
	{
        cache_get_value_name_int(i, "teleport_is_name_shown", IsShown);
		if(IsShown) cache_get_value_name(i, "teleport_name", teleport[i][T_NAME]);

        cache_get_value_name_int(i, "teleport_pickup_id", teleport[i][T_PICKUP_ID]);

		cache_get_value_name_float(i, "teleport_pickup_pos_x", teleport[i][T_PICKUP_POS_X]);
        cache_get_value_name_float(i, "teleport_pickup_pos_y", teleport[i][T_PICKUP_POS_Y]);
        cache_get_value_name_float(i, "teleport_pickup_pos_z", teleport[i][T_PICKUP_POS_Z]);

        cache_get_value_name_int(i, "teleport_pickup_vw", teleport[i][T_PICKUP_VIRTUAL_WORLD]);

		cache_get_value_name_float(i, "teleport_pos_x", teleport[i][T_POS_X]);
        cache_get_value_name_float(i, "teleport_pos_y", teleport[i][T_POS_Y]);
        cache_get_value_name_float(i, "teleport_pos_z", teleport[i][T_POS_Z]);
        cache_get_value_name_float(i, "teleport_pos_a", teleport[i][T_ANGLE]);

        cache_get_value_name_int(i, "teleport_interior", teleport[i][T_INTERIOR]);
        cache_get_value_name_int(i, "teleport_vw", teleport[i][T_VIRTUAL_WORLD]);
        
        teleport[i][T_SERVER_AREA_ID] = CreatePickup(teleport[i][T_PICKUP_ID], 23, teleport[i][T_PICKUP_POS_X], teleport[i][T_PICKUP_POS_Y] ,teleport[i][T_PICKUP_POS_Z], teleport[i][T_PICKUP_VIRTUAL_WORLD]);
		teleport[i][T_SERVER_AREA_ID] = CreateDynamicSphere(teleport[i][T_PICKUP_POS_X], teleport[i][T_PICKUP_POS_Y] ,teleport[i][T_PICKUP_POS_Z], 1.0, teleport[i][T_PICKUP_VIRTUAL_WORLD]);
		if(strlen(teleport[i][T_NAME]) > 0) Create3DTextLabel(teleport[i][T_NAME], -1, teleport[i][T_PICKUP_POS_X], teleport[i][T_PICKUP_POS_Y] ,teleport[i][T_PICKUP_POS_Z], 5.0, teleport[i][T_PICKUP_VIRTUAL_WORLD]);
	}
	return printf("[LoadTeleportPickups] Было загружено %d пикап (-ов) телепортации за %d мс.", rows, GetTickCount() - count);
}

stock UseTeleportForPlayer(playerid, index)
{
	SetPlayerPos(playerid, teleport[index][T_POS_X], teleport[index][T_POS_Y], teleport[index][T_POS_Z]+0.1);
	SetPlayerFacingAngle(playerid, teleport[index][T_ANGLE]);
	SetPlayerInterior(playerid, teleport[index][T_INTERIOR]);
	SetPlayerVirtualWorld(playerid, teleport[index][T_VIRTUAL_WORLD]);
	SetCameraBehindPlayer(playerid);
}
