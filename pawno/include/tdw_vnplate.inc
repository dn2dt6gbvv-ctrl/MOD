























































                                                                                

#if defined _inc_tdw_vnplate


	#undef _inc_tdw_vnplate
#endif

#if defined _TDW_VH_NUMBER_PLATE
	#endinput
#endif

#define _TDW_VH_NUMBER_PLATE

#include "tdw_vehicle"




static stock
	TDW_g_sVehicle@NumberPlate[MAX_VEHICLES][MAX_NUMBER_PLATE_SIZE char];





#if !defined BAD_SetVehicleNumberPlate
	native BAD_SetVehicleNumberPlate(vehicleid,
		numberplate[]) = SetVehicleNumberPlate;
#endif

stock TDW_NUMPL@SetVehicleNumberPlate(vehicleid, const number_plate[])
{
	new
		Float:current_x,
		Float:current_y,
		Float:current_z;

	if (0 == GetVehiclePos(vehicleid, current_x, current_y, current_z))
		return 0;

	new
		Float:current_z_angle,
		Float:current_health,
		current_panels,
		current_doors,
		current_lights,
		current_tires,
		passenegers[MAX_VEHICLE_PASSENGERS];

	GetVehicleZAngle(vehicleid, current_z_angle);

	#if !defined TDW_NUMPLATE_NOT_SAFE_DAMAGE
		GetVehicleHealth(vehicleid, current_health);
		GetVehicleDamageStatus(vehicleid, current_panels, current_doors,
			current_lights, current_tires);
	#endif

	GetVehicleOccupantPlayers(vehicleid, passengers);

	const
		PUSH_ARGS_COUNT = 2 * 4,
		PUSHED_ARGS = PUSH_ARGS_COUNT + 4;

	#emit PUSH.s number_plate
	#emit PUSH.s vehicleid
	#emit PUSH.c PUSH_ARGS_COUNT
	#emit SYSREQ.c SetVehicleNumberPlate
	#emit STACK PUSHED_ARGS

	SetVehicleToRespawn(vehicleid);

	#if !defined TDW_NUMPLATE_NOT_SAFE_NUMBER
		strcpy(TDW_g_sVehicle@NumberPlate[vehicleid], number_plate);
	#endif

	SetVehiclePos(vehicleid, current_x, current_y, current_z);

	new i;
	do {
		PutPlayerInVehicle(passengers[i], vehicleid, i);
	} while (++i < sizeof passengers);

	#if !defined TDW_NUMPLATE_NOT_SAFE_DAMAGE
		SetVehicleHealth(vehicleid, current_health);
		UpdateVehicleDamageStatus(vehicleid, current_panels, current_doors,
			current_lights, current_tires);
	#endif

	return 1;
}

#if defined _ALS_SetVehicleNumberPlate
	#undef SetVehicleNumberPlate
#else
	#define _ALS_SetVehicleNumberPlate
#endif

#define SetVehicleNumberPlate TDW_NUMPL@SetVehicleNumberPlate







#if !defined IsPackedString
	#define IsPackedString(%0) ((%0){0} != 0)
#endif

#if !defined strcpy
	static stock strcpy(dest[], const string[], dest_size = sizeof dest)
	{
		return
			(IsPackedString(dest) ? (dest{0} = '\0') : (dest[0] = '\0')),
			strcat(dest, string, dest_size);
	}
#endif












                                                                                

stock GetVehicleNumberPlate(vehicleid, dest[], bool:packed = false,
	dest_size = sizeof dest)
{
	#if !defined TDW_NPLATE_NOT_SAFE_NUMBER
		return packed
			? strcpy(dest, TDW_g_sNumberPlate[vehicleid], dest_size)
			: strunpack(dest, TDW_g_sNumberPlate[vehicleid], dest_size);
	#else
		return 0;
	#endif
}
