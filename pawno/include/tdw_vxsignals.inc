

























































                                                                                

#if defined _inc_tdw_vxsignals


	#undef _inc_tdw_vxsignals
#endif

#if defined _TDW_VH_SYS_VEHICLE_SIGNALS
	#endinput
#endif

#define _TDW_VH_SYS_VEHICLE_SIGNALS

#include "tdw_vehicle"


#include "tdw_vsa_data"




#if !defined TDW_SIGNAL_OBJECT_ID
	#define TDW_SIGNAL_OBJECT_ID (19294)
#endif




enum E_TDW_TURN_SIGNAL_STATE(<<= 1)
{
	EI_TURN_SIGNAL_LEFT = 1,
	EI_TURN_SIGNAL_RIGHT,
	EI_TURN_SIGNAL_BOTH = EI_TURN_SIGNAL_LEFT | EI_TURN_SIGNAL_RIGHT
};

_TDW_STATIC_ENUM enum E_TDW_TURN_SIGNAL_OBJECT_IDS
{
	EI_TURN_SIGNAL_FRONT_LEFT,
	EI_TURN_SIGNAL_FRONT_RIGHT,
	EI_TURN_SIGNAL_BACK_LEFT,
	EI_TURN_SIGNAL_BACK_RIGHT
};




static stock
	TDW_g_sVehicleObjects[MAX_VEHICLES][E_TDW_TURN_SIGNAL_OBJECT_IDS];





stock AddVehicleTurnSignals(vehicleid, E_TDW_TURN_SIGNAL_STATE:turn_signal)
{
	new
		vehicle_model;

	if ((vehicle_model = GetVehicleModel(vehicleid)) == 0)
		return 0;
	if (GetModelStaticType(vehicle_model) != CAR)
		return 0;

	new
		Float:x,
		Float:y,
		Float:z;

	GetVehicleModelInfo(vehicle_model, VEHICLE_MODEL_INFO_SIZE, x, y, z);

	if (turn_signal & EI_TURN_SIGNAL_LEFT) {
		TDW_g_sVehicleObjects[vehicleid][EI_TURN_SIGNAL_FRONT_LEFT] =
			CreateObject(
			TDW_SIGNAL_OBJECT_ID,
			0.0, 0.0, 0.0,
			0.0, 0.0, 0.0,
			0.0
		);
		TDW_g_sVehicleObjects[vehicleid][EI_TURN_SIGNAL_BACK_LEFT] =
			CreateObject(
			TDW_SIGNAL_OBJECT_ID,
			0.0, 0.0, 0.0,
			0.0, 0.0, 0.0,
			0.0
		);
		AttachObjectToVehicle(
			TDW_g_sVehicleObjects[vehicleid][EI_TURN_SIGNAL_FRONT_LEFT],
			vehicleid,
			-x / 2.23, y / 2.23, 0.1,
			0.0, 0.0, 0.0
		);
		AttachObjectToVehicle(
			TDW_g_sVehicleObjects[vehicleid][EI_TURN_SIGNAL_BACK_LEFT],
			vehicleid,
			-x / 2.23, -y / 2.23, 0.1,
			0.0, 0.0, 0.0
		);
	}
	if (turn_signal & EI_TURN_SIGNAL_RIGHT) {
		TDW_g_sVehicleObjects[vehicleid][EI_TURN_SIGNAL_FRONT_RIGHT] =
			CreateObject(
			TDW_SIGNAL_OBJECT_ID,
			0.0, 0.0, 0.0,
			0.0, 0.0, 0.0,
			0.0
		);
		TDW_g_sVehicleObjects[vehicleid][EI_TURN_SIGNAL_BACK_RIGHT] =
			CreateObject(
			TDW_SIGNAL_OBJECT_ID,
			0.0, 0.0, 0.0,
			0.0, 0.0, 0.0,
			0.0
		);
		AttachObjectToVehicle(
			TDW_g_sVehicleObjects[vehicleid][EI_TURN_SIGNAL_FRONT_RIGHT],
			vehicleid,
			x / 2.23, y / 2.23, 0.1,
			0.0, 0.0, 0.0
		);
		AttachObjectToVehicle(
			TDW_g_sVehicleObjects[vehicleid][EI_TURN_SIGNAL_BACK_RIGHT],
			vehicleid,
			x / 2.23, -y / 2.23, 0.1,
			0.0, 0.0, 0.0
		);
	}
	return 1;
}

stock RemoveVehicleTurnSignals(vehicleid, E_TDW_TURN_SIGNAL_STATE:turn_signal)
{
	new
		vehicle_model;

	if ((vehicle_model = GetVehicleModel(vehicleid)) == 0)
		return 0;
	if (GetModelStaticType(vehicle_model) != CAR)
		return 0;

	if (turn_signal & EI_TURN_SIGNAL_LEFT) {
		DestroyObject(
			TDW_g_sVehicleObjects[vehicleid][EI_TURN_SIGNAL_FRONT_LEFT]);
		DestroyObject(
			TDW_g_sVehicleObjects[vehicleid][EI_TURN_SIGNAL_BACK_LEFT]);
	}
	if (turn_signal & EI_TURN_SIGNAL_RIGHT) {
		DestroyObject(
			TDW_g_sVehicleObjects[vehicleid][EI_TURN_SIGNAL_FRONT_RIGHT]);
		DestroyObject(
			TDW_g_sVehicleObjects[vehicleid][EI_TURN_SIGNAL_BACK_RIGHT]);
	}
	return 1;
}
