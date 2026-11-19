



































































                                                                                

#if defined _inc_tdw_vyengine


	#undef _inc_tdw_vyengine
#endif

#if defined _TDW_VH_SYS_VEHICLE_ENGINE
	#endinput
#endif

#define _TDW_VH_SYS_VEHICLE_ENGINE

#include "tdw_vehicle"


#include "tdw_vsa_data"




#if !defined TDW_ENGINE_TIMER_TICK
	#define TDW_ENGINE_TIMER_TICK				(1000)
#endif




static stock
	bool:TDW_g_sIsVehicleEngineStarted[MAX_VEHICLES char] = {false, ...},
	TDW_g_sCallbacks;

static stock const
	TDW_g_sOnVehEngineStateChange[] = !"OnVehicleEngineStateChange";

#if TDW_ENGINE_TIMER_TICK > 0
	static stock
		TDW_g_sVehicleTimerId[MAX_VEHICLES] = {-1, ...};
#endif





#if defined FILTERSCRIPT
	#if defined TDWVH_ENGIN@OnFilterScriptInit
		forward TDWVH_ENGIN@OnFilterScriptInit();
	#endif

	public OnFilterScriptInit()
	{
		ManualVehicleEngineAndLights();

		if (-1 != funcidx(TDW_g_sOnVehEngineStateChange))
			TDW_g_sCallbacks |= 1;

		#if defined TDWVH_ENGIN@OnFilterScriptInit
			TDWVH_ENGIN@OnFilterScriptInit();
		#endif

		return 1;
	}

	#if defined _ALS_OnFilterScriptInit
		#undef OnFilterScriptInit
	#else
		#define _ALS_OnFilterScriptInit
	#endif

	#define OnFilterScriptInit TDWVH_ENGIN@OnFilterScriptInit
#else
	#if defined TDWVH_ENGIN@OnGameModeInit
		forward TDWVH_ENGIN@OnGameModeInit();
	#endif

	public OnGameModeInit()
	{
		ManualVehicleEngineAndLights();

		if (-1 != funcidx(TDW_g_sOnVehEngineStateChange))
			TDW_g_sCallbacks |= 1;

		#if defined TDWVH_ENGIN@OnGameModeInit
			TDWVH_ENGIN@OnGameModeInit();
		#endif

		return 1;
	}

	#if defined _ALS_OnGameModeInit
		#undef OnGameModeInit
	#else
		#define _ALS_OnGameModeInit
	#endif

	#define OnGameModeInit TDWVH_ENGIN@OnGameModeInit
#endif



#if defined TDWVH_ENGIN@OnPlayerStateChange
	forward TDWVH_ENGIN@OnPlayerStateChange(playerid, newstate, oldstate);
#endif

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if (newstate == PLAYER_STATE_DRIVER) {
		new vehicleid = GetPlayerVehicleID(playerid);

		if (0 == IsVehicleHasEngine(vehicleid))
			ToggleVehicleEngineState(vehicleid, VEHICLE_PARAMS_ON);
	}

	#if defined TDWVH_ENGIN@OnPlayerStateChange
		TDWVH_ENGIN@OnPlayerStateChange(playerid, newstate, oldstate);
	#endif

	return 1;
}

#if defined _ALS_OnPlayerStateChange
	#undef OnPlayerStateChange
#else
	#define _ALS_OnPlayerStateChange
#endif

#define OnPlayerStateChange TDWVH_ENGIN@OnPlayerStateChange












                                                                                

stock StartVehicleEngine(vehicleid)
{
	if (0 == IsVehicleHasEngine(vehicleid))
		return 0;
	if (TDW_g_sIsVehicleEngineStarted{vehicleid})
		return 0;

	#if TDW_ENGINE_TIMER_TICK > 0
		if (TDW_g_sVehicleTimerId[vehicleid] != -1)
			return 0;
		TDW_g_sVehicleTimerId[vehicleid] = SetTimerEx(!"@_TDW_VEHICLE_ENGINE",
			TDW_ENGINE_TIMER_TICK, false, !"i", vehicleid);
	#else
		ToggleVehicleEngineState(vehicleid, VEHICLE_PARAMS_ON);
	#endif

	return 1;
}









                                                                                

stock StopVehicleEngine(vehicleid)
{
	if (0 == IsVehicleHasEngine(vehicleid))
		return 0;
	if (0 == _:TDW_g_sIsVehicleEngineStarted{vehicleid})
		return 0;

	#if TDW_ENGINE_TIMER_TICK > 0
		new timer_id = TDW_g_sVehicleTimerId[vehicleid];

		if (timer_id != -1)
			KillTimer(timer_id);
	#endif

	ToggleVehicleEngineState(vehicleid, VEHICLE_PARAMS_OFF);

	return 1;
}









                                                                                

stock IsVehicleEngineStarted(vehicleid)
{
	return IsValidVehicle(vehicleid) &&
		TDW_g_sIsVehicleEngineStarted{vehicleid};
}




static stock IsVehicleHasEngine(vehicleid)
{
	new model = GetVehicleModel(vehicleid);

	if (0 == model)
		return 0;

	return GetModelStaticType(model) != BIKE;
}

static stock ToggleVehicleEngineState(vehicleid,
	newstate = VEHICLE_PARAMS_UNSET)
{
	new
		engine,
		lights,
		alarm,
		doors,
		bonnet,
		boot,
		objective;

	if (0 == GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet,
		boot, objective))
		return 0;

	if (newstate == engine)
		return 0;

	if (newstate == VEHICLE_PARAMS_UNSET)
		newstate = engine ? VEHICLE_PARAMS_OFF : VEHICLE_PARAMS_ON;

	TDW_g_sIsVehicleEngineStarted{vehicleid} =
		bool:(newstate == VEHICLE_PARAMS_ON);

	SetVehicleParamsEx(vehicleid, newstate, lights, alarm, doors, bonnet, boot,
		objective);

	if (TDW_g_sCallbacks & 1)
		CallLocalFunction(TDW_g_sOnVehEngineStateChange, !"ii", vehicleid,
			newstate);

	return 1;
}

@_TDW_VEHICLE_ENGINE(vehicleid);
@_TDW_VEHICLE_ENGINE(vehicleid)
{
	ToggleVehicleEngineState(vehicleid, VEHICLE_PARAMS_ON);

	#if TDW_ENGINE_TIMER_TICK > 0
		TDW_g_sVehicleTimerId[vehicleid] = -1;
	#endif

	return 1;
}




forward OnVehicleEngineStateChange(vehicleid, engine);
