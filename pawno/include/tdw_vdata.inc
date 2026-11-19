







































































                                                                                

#if defined _inc_tdw_vdata


	#undef _inc_tdw_vdata
#endif

#if defined _TDW_VH_VEHICLE_DATA
	#endinput
#endif

#define _TDW_VH_VEHICLE_DATA

#include "tdw_vehicle"




_TDW_STATIC_ENUM enum E_TDW_VEHICLE_DATA
{
	Float:EI_VEHICLE_SPAWN_POS_X,
	Float:EI_VEHICLE_SPAWN_POS_Y,
	Float:EI_VEHICLE_SPAWN_POS_Z,
	Float:EI_VEHICLE_SPAWN_ANGLE,
	EI_VEHICLE_RESPAWN_TIME,
	EI_VEHICLE_MODEL_ID
};




static stock
	TDW_g_sVehicle@Data[MAX_VEHICLES][E_TDW_VEHICLE_DATA],


	TDW_g_sVehicle@Color1[MAX_VEHICLES char],
	TDW_g_sVehicle@Color2[MAX_VEHICLES char],
	bool:TDW_g_sVehicle@Siren[MAX_VEHICLES char],
	TDW_g_sVehicle@Interior[MAX_VEHICLES char],

	TDW_g_sVehicleId;





#if !defined BAD_AddStaticVehicle
	native BAD_AddStaticVehicle(modelid, Float:spawn_x, Float:spawn_y,
		Float:spawn_z, Float:z_angle, color1, color2) = AddStaticVehicle;
#endif

stock TDWVH_DATA@AddStaticVehicle(modelid, Float:spawn_x, Float:spawn_y,
	Float:spawn_z, Float:z_angle, color1, color2)
{
	if (INVALID_VEHICLE_ID != (TDW_g_sVehicleId = AddStaticVehicle(modelid,
		spawn_x, spawn_y, spawn_z, z_angle, color1, color2))) {

		TDW_g_sVehicle@Data[TDW_g_sVehicleId][EI_VEHICLE_MODEL_ID] = modelid;
		TDW_g_sVehicle@Data[TDW_g_sVehicleId][EI_VEHICLE_SPAWN_POS_X] = spawn_x;
		TDW_g_sVehicle@Data[TDW_g_sVehicleId][EI_VEHICLE_SPAWN_POS_Y] = spawn_y;
		TDW_g_sVehicle@Data[TDW_g_sVehicleId][EI_VEHICLE_SPAWN_POS_Z] = spawn_z;
		TDW_g_sVehicle@Data[TDW_g_sVehicleId][EI_VEHICLE_SPAWN_ANGLE] = z_angle;
		TDW_g_sVehicle@Data[TDW_g_sVehicleId][EI_VEHICLE_RESPAWN_TIME] = -1;
		TDW_g_sVehicle@Color1{TDW_g_sVehicleId} = color1;
		TDW_g_sVehicle@Color2{TDW_g_sVehicleId} = color2;
		TDW_g_sVehicle@Siren{TDW_g_sVehicleId} = false;
	}
	return TDW_g_sVehicleId;
}

#if defined _ALS_AddStaticVehicle
	#undef AddStaticVehicle
#else
	#define _ALS_AddStaticVehicle
#endif

#define AddStaticVehicle TDWVH_DATA@AddStaticVehicle



#if !defined BAD_AddStaticVehicleEx
	native BAD_AddStaticVehicleEx(modelid, Float:spawn_x, Float:spawn_y,
		Float:spawn_z, Float:z_angle, color1, color2, respawn_delay,
		addsiren = 0) = AddStaticVehicleEx;
#endif

stock TDWVH_DATA@AddStaticVehicleEx(modelid, Float:spawn_x, Float:spawn_y,
	Float:spawn_z, Float:z_angle, color1, color2, respawn_delay, addsiren = 0)
{
	if (INVALID_VEHICLE_ID != (TDW_g_sVehicleId = AddStaticVehicleEx(modelid,
		spawn_x, spawn_y, spawn_z, z_angle, color1, color2, respawn_delay,
		addsiren))) {

		TDW_g_sVehicle@Data[TDW_g_sVehicleId][EI_VEHICLE_MODEL_ID] = modelid;
		TDW_g_sVehicle@Data[TDW_g_sVehicleId][EI_VEHICLE_SPAWN_POS_X] = spawn_x;
		TDW_g_sVehicle@Data[TDW_g_sVehicleId][EI_VEHICLE_SPAWN_POS_Y] = spawn_y;
		TDW_g_sVehicle@Data[TDW_g_sVehicleId][EI_VEHICLE_SPAWN_POS_Z] = spawn_z;
		TDW_g_sVehicle@Data[TDW_g_sVehicleId][EI_VEHICLE_SPAWN_ANGLE] = z_angle;
		TDW_g_sVehicle@Data[TDW_g_sVehicleId][EI_VEHICLE_RESPAWN_TIME] =
			respawn_delay;
		TDW_g_sVehicle@Color1{TDW_g_sVehicleId} = color1;
		TDW_g_sVehicle@Color2{TDW_g_sVehicleId} = color2;
		TDW_g_sVehicle@Siren{TDW_g_sVehicleId} = bool:addsiren;
	}
	return TDW_g_sVehicleId;
}

#if defined _ALS_AddStaticVehicleEx
	#undef AddStaticVehicleEx
#else
	#define _ALS_AddStaticVehicleEx
#endif

#define AddStaticVehicleEx TDWVH_DATA@AddStaticVehicleEx



#if !defined BAD_CreateVehicle
	native BAD_CreateVehicle(vehicletype, Float:x, Float:y, Float:z,
		Float:rotation, color1, color2, respawn_delay,
		addsiren = 0) = CreateVehicle;
#endif

stock TDWVH_DATA@CreateVehicle(vehicletype, Float:x, Float:y, Float:z,
	Float:rotation, color1, color2, respawn_delay, addsiren = 0)
{
	if (INVALID_VEHICLE_ID != (TDW_g_sVehicleId = CreateVehicle(vehicletype,
		x, y, z, rotation, color1, color2, respawn_delay,
		addsiren))) {

		TDW_g_sVehicle@Data[TDW_g_sVehicleId][EI_VEHICLE_MODEL_ID] =
			vehicletype;
		TDW_g_sVehicle@Data[TDW_g_sVehicleId][EI_VEHICLE_SPAWN_POS_X] = x;
		TDW_g_sVehicle@Data[TDW_g_sVehicleId][EI_VEHICLE_SPAWN_POS_Y] = y;
		TDW_g_sVehicle@Data[TDW_g_sVehicleId][EI_VEHICLE_SPAWN_POS_Z] = z;
		TDW_g_sVehicle@Data[TDW_g_sVehicleId][EI_VEHICLE_SPAWN_ANGLE] =
			rotation;
		TDW_g_sVehicle@Data[TDW_g_sVehicleId][EI_VEHICLE_RESPAWN_TIME] =
			respawn_delay;
		TDW_g_sVehicle@Color1{TDW_g_sVehicleId} = color1;
		TDW_g_sVehicle@Color2{TDW_g_sVehicleId} = color2;
		TDW_g_sVehicle@Siren{TDW_g_sVehicleId} = bool:addsiren;
	}
	return TDW_g_sVehicleId;
}

#if defined _ALS_CreateVehicle
	#undef CreateVehicle
#else
	#define _ALS_CreateVehicle
#endif

#define CreateVehicle TDWVH_DATA@CreateVehicle



#if !defined BAD_DestroyVehicle
	native BAD_DestroyVehicle(vehicleid) = DestroyVehicle;
#endif

stock TDWVH_DATA@DestroyVehicle(vehicleid)
{
	if (0 == DestroyVehicle(vehicleid))
		return 0;


	TDW_g_sVehicle@Data[vehicleid][EI_VEHICLE_MODEL_ID] =
	TDW_g_sVehicle@Data[vehicleid][EI_VEHICLE_RESPAWN_TIME] =
	TDW_g_sVehicle@Color1{vehicleid} =
	TDW_g_sVehicle@Color2{vehicleid} =
	TDW_g_sVehicle@Interior{vehicleid} = 0;
	TDW_g_sVehicle@Siren{vehicleid} = false;
	TDW_g_sVehicle@Data[vehicleid][EI_VEHICLE_SPAWN_POS_X] =
	TDW_g_sVehicle@Data[vehicleid][EI_VEHICLE_SPAWN_POS_Y] =
	TDW_g_sVehicle@Data[vehicleid][EI_VEHICLE_SPAWN_POS_Z] =
	TDW_g_sVehicle@Data[vehicleid][EI_VEHICLE_SPAWN_ANGLE] = 0.0;

	return 1;
}

#if defined _ALS_DestroyVehicle
	#undef DestroyVehicle
#else
	#define _ALS_DestroyVehicle
#endif

#define DestroyVehicle TDWVH_DATA@DestroyVehicle



#if defined TDWVH_DATA@OnVehicleRespray
	forward TDWVH_DATA@OnVehicleRespray(playerid, vehicleid, color1, color2);
#endif

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	TDW_g_sVehicle@Color1{vehicleid} = color1;
	TDW_g_sVehicle@Color2{vehicleid} = color2;

	#if defined TDWVH_DATA@OnVehicleRespray




		return TDWVH_DATA@OnVehicleRespray(playerid, vehicleid, color1, color2);
	#else
		return 1;
	#endif
}

#if defined _ALS_OnVehicleRespray
	#undef OnVehicleRespray
#else
	#define _ALS_OnVehicleRespray
#endif

#define OnVehicleRespray TDWVH_DATA@OnVehicleRespray



#if !defined ChangeVehicleColor
	native BAD_ChangeVehicleColor(vehicleid, color1,
		color2) = ChangeVehicleColor;
#endif





#if defined _ALS_ChangeVehicleColor
	#undef ChangeVehicleColor
#else
	#define _ALS_ChangeVehicleColor
#endif

#define ChangeVehicleColor SetVehicleColor















                                                                                

stock GetVehicleColor(vehicleid, &color1, &color2)
{
	if (0 == IsValidVehicle(vehicleid))
		return _:(color1 = color2 = 0);

	color1 = TDW_g_sVehicle@Color1{vehicleid};
	color2 = TDW_g_sVehicle@Color2{vehicleid};

	return 1;
}












                                                                                

stock SetVehicleColor(vehicleid, color1, color2)
{
	if (0 == IsValidVehicle(vehicleid))
		return 0;

	TDW_g_sVehicle@Color1{vehicleid} = color1;
	TDW_g_sVehicle@Color2{vehicleid} = color2;

	return 1;
}





































                                                                                

stock CreateVehicleEx(vehicletype, Float:x, Float:y, Float:z, Float:rotation,
	color1, color2, respawn_delay, addsiren = 0)
{
	switch (vehicletype) {
		case 449, 537, 538, 570:
			return AddStaticVehicleEx(vehicletype, x, y, z, rotation, color1,
				color2, respawn_delay, addsiren);
		default:
			return CreateVehicle(vehicletype, x, y, z, rotation, color1, color2,
				respawn_delay, addsiren);
	}

	return 0;
}
