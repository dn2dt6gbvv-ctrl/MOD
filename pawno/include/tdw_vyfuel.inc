


































































                                                                                

#if defined _inc_tdw_vyfuel


	#undef _inc_tdw_vyfuel
#endif

#if defined _TDW_VH_SYS_VEHICLE_FUEL
	#endinput
#endif

#define _TDW_VH_SYS_VEHICLE_FUEL

#include "tdw_vehicle"


#include "tdw_vmath"
#include "tdw_vyengine"
#include "tdw_vymileage"









#if !defined TDW_VEHICLE_FUEL_FLOAT
	#define TDW_VEHICLE_FUEL_FLOAT (20000.0)
#endif




static stock
	Float:TDW_g_sVehicleFuel[MAX_VEHICLES],
	TDW_g_sCallbacks,
	TDW_g_sOnVehicleFuelEmpty[] = !"OnVehicleFuelEmpty",
	Float:TDW_g_sModelMaxFuel[MAX_VEHICLE_MODELS + 1] =
{
	 70.0,  45.0, 40.0, 298.0,  40.0,  40.0, 200.0, 80.0, 60.0,  40.0,  40.0,
	 40.0,  40.0, 45.0,  45.0,  40.0,  70.0, 100.0, 45.0, 40.0,  40.0,  40.0,
	 45.0,  45.0, 20.0, 200.0,  40.0,  70.0,  70.0, 40.0, 45.0,  60.0,  90.0,
	100.0,  35.0,  0.0,  40.0,  50.0,  40.0,  40.0, 45.0,  5.0,  40.0,  50.0,
	 65.0,  40.0, 35.0,  90.0,  20.0,  60.0,   0.0, 40.0, 20.0,  20.0,  20.0,
	 60.0,  50.0, 20.0,  40.0,  45.0,  90.0,  30.0, 20.0, 35.0,   5.0,   5.0,
	 40.0,  40.0, 20.0,  90.0,  90.0,  20.0,  20.0, 20.0, 40.0,  40.0,  40.0,
	 40.0,  40.0, 45.0,  40.0,   0.0,  45.0,  45.0, 20.0, 20.0,  30.0,  90.0,
	 90.0,  70.0, 70.0,  40.0,  40.0,  20.0,  40.0, 45.0, 40.0,  90.0,  50.0,
	 50.0,  40.0,  5.0,  40.0,  40.0,  40.0,  50.0, 40.0, 40.0,  50.0,   0.0,
	  0.0,  90.0, 90.0,  90.0, 298.0, 298.0,  40.0, 40.0, 40.0, 400.0, 400.0,
	 30.0,  30.0, 30.0,  50.0,  50.0,  40.0,  40.0, 50.0, 40.0,  20.0,  20.0,
	 60.0,  40.0, 40.0,  40.0,  40.0,  50.0,  50.0, 20.0, 40.0,  40.0,  40.0,
	 50.0,  70.0, 40.0,  40.0,  40.0,  90.0,  40.0, 40.0, 40.0,  40.0, 300.0,
	 50.0,  40.0, 80.0,  80.0,  40.0,  40.0,  40.0, 40.0, 40.0,  90.0,  90.0,
	 40.0,  45.0, 45.0,  20.0,   0.0,  50.0,  10.0, 20.0, 50.0,  20.0,  40.0,
	 40.0, 300.0, 50.0,  50.0,  40.0,  30.0,  50.0, 20.0,  0.0,  40.0,  30.0,
	 40.0,  50.0, 40.0,   0.0,   0.0, 300.0, 200.0,  0.0, 20.0,  40.0,  40.0,
	 40.0,  50.0, 40.0,  60.0,  40.0,  40.0,  40.0, 45.0,  0.0,   0.0,   0.0,
	 50.0,   0.0,  0.0
};





#if defined FILTERSCRIPT
	#if defined TDWVH_FUEL@OnFilterScriptInit
		forward TDWVH_FUEL@OnFilterScriptInit();
	#endif

	public OnFilterScriptInit()
	{
		if (funcidx(TDW_g_sOnVehicleFuelEmpty) != -1)
				TDW_g_sCallbacks |= 1;

		#if defined TDWVH_FUEL@OnFilterScriptInit
			TDWVH_FUEL@OnFilterScriptInit();
		#endif

		return 1;
	}

	#if defined _ALS_OnFilterScriptInit
		#undef OnFilterScriptInit
	#else
		#define _ALS_OnFilterScriptInit
	#endif

	#define OnFilterScriptInit TDWVH_FUEL@OnFilterScriptInit
#else
	#if defined TDWVH_FUEL@OnGameModeInit
		forward TDWVH_FUEL@OnGameModeInit();
	#endif

	public OnGameModeInit()
	{
		if (funcidx(TDW_g_sOnVehicleFuelEmpty) != -1)
				TDW_g_sCallbacks |= 1;

		#if defined TDWVH_FUEL@OnGameModeInit
			TDWVH_FUEL@OnGameModeInit();
		#endif

		return 1;
	}

	#if defined _ALS_OnGameModeInit
		#undef OnGameModeInit
	#else
		#define _ALS_OnGameModeInit
	#endif

	#define OnGameModeInit TDWVH_FUEL@OnGameModeInit
#endif



#if defined TDWVH_FUEL@OnVehicleMileageUpd
	forward TDWVH_FUEL@OnVehicleMileageUpd(vehicleid);
#endif

public OnVehicleMileageUpdate(vehicleid)
{
	if (IsVehicleEngineStarted(vehicleid)) {
		if (TDW_g_sVehicleFuel[vehicleid] <= 0.1) {
			StopVehicleEngine(vehicleid);
			TDW_g_sVehicleFuel[vehicleid] = 0.0;

			if (TDW_g_sCallbacks & 1) {
				CallLocalFunction(TDW_g_sOnVehicleFuelEmpty, !"i", vehicleid);
			}
		} else {
			TDW_g_sVehicleFuel[vehicleid] -= (GetVehicleSpeed(vehicleid) + 0.1)/
				TDW_VEHICLE_FUEL_FLOAT;
		}
	}

	#if defined TDWVH_FUEL@OnVehicleMileageUpd
		TDWVH_FUEL@OnVehicleMileageUpd(vehicleid);
	#endif

	return 1;
}

#if defined _ALS_OnVehicleMileageUpdate
	#undef OnVehicleMileageUpdate
#else
	#define _ALS_OnVehicleMileageUpdate
#endif

#define OnVehicleMileageUpdate TDWVH_FUEL@OnVehicleMileageUpd



#if defined StartVehicleEngine
	stock TDWVH_FUEL@StartVehicleEngine(vehicleid)
	{
		if (0 == IsValidVehicle(vehicleid))
			return 0;
		if (TDW_g_sVehicleFuel[vehicleid] == 0.0)
			return 0;
		return StartVehicleEngine(vehicleid);
	}

	#if defined _ALS_StartVehicleEngine
		#undef StartVehicleEngine
	#else
		#define _ALS_StartVehicleEngine
	#endif

	#define StartVehicleEngine TDWVH_FUEL@StartVehicleEngine
#endif












                                                                                

stock Float:GetModelMaxFuel(modelid)
{
	if (0 == IS_VALID_MODEL(modelid))
		return 0.0;

	return TDW_g_sModelMaxFuel[modelid - MIN_VEHICLE_MODEL];
}









                                                                                

stock SetModelMaxFuel(modelid, Float:amount)
{
	if (0 == IS_VALID_MODEL(modelid))
		return 0;

	TDW_g_sModelMaxFuel[modelid - MIN_VEHICLE_MODEL] = amount;

	return 1;
}









                                                                                

stock Float:GetVehicleFuel(vehicleid)
{
	if (0 == IsValidVehicle(vehicleid))
		return 0.0;

	return TDW_g_sVehicleFuel[vehicleid];
}









                                                                                

stock SetVehicleFuel(vehicleid, Float:amount)
{
	new modelid = GetVehicleModel(vehicleid);
	if (0 == modelid)
		return 0;

	new Float:max_fuel = GetModelMaxFuel(modelid);

	if (amount > max_fuel)
		amount = max_fuel;
	else if (amount < 0.0)
		amount = 0.0;

	TDW_g_sVehicleFuel[vehicleid] = amount;

	return 1;
}




forward OnVehicleFuelEmpty(vehicleid);
