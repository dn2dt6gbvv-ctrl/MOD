stock GetPlayerRentID(vehicleid)
{
	foreach(new i: Player) if(vehicleid == PI[i][pArendID]) return i;
	return INVALID_PLAYER_ID;
}
