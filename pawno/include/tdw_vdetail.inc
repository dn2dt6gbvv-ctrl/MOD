
































































                                                                                

#if defined _inc_tdw_vdetail


	#undef _inc_tdw_vdetail
#endif

#if defined _TDW_VH_VEHICLE_DETAIL
	#endinput
#endif

#define _TDW_VH_VEHICLE_DETAIL

#include "tdw_vehicle"




static stock


	TDW_g_sVehicle@PaintjobId[MAX_VEHICLES char],
	TDW_g_sVehicle@VirtualWorld[MAX_VEHICLES],
	TDW_g_sVehicle@LastDriverId[MAX_VEHICLES] = {INVALID_PLAYER_ID, ...};





#if !defined BAD_SetVehicleVirtualWorld
	native BAD_SetVehicleVirtualWorld(vehicleid,
		worldid) = SetVehicleVirtualWorld;
#endif



stock TDWVH_DETAIL@SetVehicleVW(vehicleid, worldid)
{
	if (0 == IsValidVehicle(vehicleid))
		return 0;

	SetVehicleVirtualWorld(vehicleid,
		(TDW_g_sVehicle@VirtualWorld[vehicleid] = worldid));

	return 1;
}

#if defined _ALS_SetVehicleVirtualWorld
	#undef SetVehicleVirtualWorld
#else
	#define _ALS_SetVehicleVirtualWorld
#endif

#define SetVehicleVirtualWorld TDWVH_DETAIL@SetVehicleVW



#if defined TDW_DETAIL@OnVehiclePaintjob
	forward TDW_DETAIL@OnVehiclePaintjob(playerid, vehicleid, paintjobid);
#endif

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	TDW_g_sVehicle@PaintjobId{vehicleid} = paintjobid;

	#if defined TDW_DETAIL@OnVehiclePaintjob
		TDW_DETAIL@OnVehiclePaintjob(playerid, vehicleid, paintjobid);
	#endif

	return 1;
}

#if defined _ALS_OnVehiclePaintjob
	#undef OnVehiclePaintjob
#else
	#define _ALS_OnVehiclePaintjob
#endif

#define OnVehiclePaintjob TDW_DETAIL@OnVehiclePaintjob



#if defined TDW_DETAIL@OnPlayerStateChange
	forward TDW_DETAIL@OnPlayerStateChange(playerid, newstate, oldstate);
#endif

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if (newstate == PLAYER_STATE_DRIVER) {
		new vehicleid = GetPlayerVehicleID(playerid);

		TDW_g_sVehicle@LastDriverId[vehicleid] = playerid;
	}

	#if defined TDW_DETAIL@OnPlayerStateChange
		TDW_DETAIL@OnPlayerStateChange(playerid, newstate, oldstate);
	#endif

	return 1;
}

#if defined _ALS_OnPlayerStateChange
	#undef OnPlayerStateChange
#else
	#define _ALS_OnPlayerStateChange
#endif

#define OnPlayerStateChange TDW_DETAIL@OnPlayerStateChange














                                                                                

stock SetVehiclePaintjobId(vehicleid, paintjobid)
{
	if (0 == IsValidVehicle(vehicleid))
		return 0;
	if (0 == IS_VALID_PAINTJOB(paintjobid))
		return 0;

	ChangeVehiclePaintjob(vehicleid, paintjobid);
	TDW_g_sVehicle@PaintjobId{vehicleid} = paintjobid;

	return 1;
}










                                                                                

stock GetVehicleLastDriverId(vehicleid)
{
	if (0 == IsValidVehicle(vehicleid))
		return 0;
	return TDW_g_sVehicle@LastDriverId[vehicleid];
}










                                                                                

stock GetVehiclePaintjobId(vehicleid)
{
	if (0 == IsValidVehicle(vehicleid))
		return 0;
	return TDW_g_sVehicle@PaintjobId{vehicleid};
}





#if !defined BAD_ChangeVehiclePaintjob
	native BAD_ChangeVehiclePaintjob(vehicleid,
		paintjobid) = ChangeVehiclePaintjob;
#endif





#if defined _ALS_ChangeVehiclePaintjob
	#undef ChangeVehiclePaintjob
#else
	#define _ALS_ChangeVehiclePaintjob
#endif

#define ChangeVehiclePaintjob SetVehiclePaintjobId
