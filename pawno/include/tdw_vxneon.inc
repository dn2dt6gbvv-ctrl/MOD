


























































                                                                                

#if defined _inc_tdw_vxneon


	#undef _inc_tdw_vxneon
#endif

#if defined _TDW_VH_SYS_VEHICLE_NEON
	#endinput
#endif

#define _TDW_VH_SYS_VEHICLE_NEON

#include "tdw_vehicle"


#include "tdw_vsa_data"




enum E_TDW_NEON_COLOR
{

	NEON_COLOR_RED = 18647,
	NEON_COLOR_BLUE,
	NEON_COLOR_GREEN,
	NEON_COLOR_YELLOW,
	NEON_COLOR_PINK,
	NEON_COLOR_WHITE
};

_TDW_STATIC_ENUM enum E_TDW_NEON_OBJECTS
{
	EI_NEON_LEFT_ID,
	EI_NEON_RIGHT_ID
};




static stock
	TDW_g_sNeon[MAX_VEHICLES][E_TDW_NEON_OBJECTS],
	bool:TDW_g_sIsNeonAttached[MAX_VEHICLES char];





#if defined TDWHNE@OnVehicleDeath
	forward OnVehicleDeath(vehicleid, killerid);
#endif

public
	OnVehicleDeath(vehicleid, killerid)
{
	RemoveNeonFromVehicle(vehicleid);

	#if defined TDWHNE@OnVehicleDeath
		return TDWHNE@OnVehicleDeath(vehicleid, killerid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnVehicleDeath
	#undef OnVehicleDeath
#else
	#define _ALS_OnVehicleDeath
#endif

#define OnVehicleDeath TDWHNE@OnVehicleDeath




stock AddNeonToVehicle(vehicleid, E_TDW_NEON_COLOR:color)
{
	new
		vehicle_model;

	if ((vehicle_model = GetVehicleModel(vehicleid)) == 0)
		return 0;
	if (GetModelStaticType(vehicle_model) != CAR)
		return 0;

	new
		Float:size_x,
		Float:size_y,
		Float:size_z;

	GetVehicleModelInfo(vehicle_model, VEHICLE_MODEL_INFO_SIZE, size_x, size_y,
		size_z);

	new
		objectid;
	const Float:OFFSET_Z = -0.6;

	objectid = TDW_g_sNeon[vehicleid][EI_NEON_LEFT_ID] = CreateObject(_:color,
		0.0, 0.0, 0.0,
		0.0, 0.0, 0.0,
		0.0
	);
	AttachObjectToVehicle(objectid, vehicleid,
		-size_x / 2.8, 0.0, OFFSET_Z,
		0.0, 0.0, 0.0
	);
	objectid = TDW_g_sNeon[vehicleid][EI_NEON_RIGHT_ID] = CreateObject(_:color,
		0.0, 0.0, 0.0,
		0.0, 0.0, 0.0,
		0.0
	);
	AttachObjectToVehicle(objectid, vehicleid,
		size_x / 2.8, 0.0, OFFSET_Z,
		0.0, 0.0, 0.0
	);

	TDW_g_sIsNeonAttached{vehicleid} = true;

	return 1;
}

stock RemoveNeonFromVehicle(vehicleid)
{
	if (IsValidVehicle(vehicleid) == 0)
		return 0;
	if (_:TDW_g_sIsNeonAttached{vehicleid} == 0) {
		DestroyObject(TDW_g_sNeon[vehicleid][EI_NEON_LEFT_ID]);
		DestroyObject(TDW_g_sNeon[vehicleid][EI_NEON_RIGHT_ID]);
		TDW_g_sIsNeonAttached{vehicleid} = false;
	}
	return 1;
}
