
























































                                                                                

#if defined _inc_tdw_vxplights


	#undef _inc_tdw_vxplights
#endif

#if defined _TDW_VH_SYS_VEHICLE_PLIGHTS
	#endinput
#endif

#define _TDW_VH_SYS_VEHICLE_PLIGHTS

#include "tdw_vehicle"


#include "tdw_vsa_data"




enum E_TDW_SIREN_TYPE
{
	SIREN_TYPE_POLICE,
	SIREN_TYPE_AMBULANCE
};




static stock
	TDW_g_sPLVehicle[MAX_VEHICLES];




stock UpdatePoliceLights(vehicleid, E_TDW_SIREN_TYPE:type = SIREN_TYPE_POLICE)
{
	new
		modelid;

	if ((modelid = GetVehicleModel(vehicleid)) == 0)
		return 0;
	if (GetModelStaticType(modelid) != CAR)
		return 0;

	new
		siren_state;

	if ((siren_state = GetVehicleParamsSirenState(vehicleid)) == -1)
		return 0;

	new
		objectid,
		Float:size_x,
		Float:size_y,
		Float:size_z,
		object_model;

	if (type == SIREN_TYPE_POLICE) {


		object_model = siren_state ? 19420 : 19419;
	} else {


		object_model = siren_state ? 11702 : 11701;
	}

	GetVehicleModelInfo(modelid, VEHICLE_MODEL_INFO_SIZE, size_x, size_y,
		size_z
	);

	if ((objectid = TDW_g_sPLVehicle[vehicleid]))
		DestroyObject(objectid);

	objectid = TDW_g_sPLVehicle[vehicleid] = CreateObject(object_model,
		0.0, 0.0, 0.0,
		0.0, 0.0, 0.0,
		0.0
	);
	AttachObjectToVehicle(objectid, vehicleid,
		0.0, 0.0, size_z / 2.0,
		0.0, 0.0, 0.0
	);

	return 1;
}


stock RemovePoliceLights(vehicleid)
{
	if (IsValidVehicle(vehicleid))
		return 0;

	new
		objectid;

	if ((objectid = TDW_g_sPLVehicle[vehicleid]))
		DestroyObject(objectid);

	return 1;
}
