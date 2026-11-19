



























































                                                                                

#if defined _inc_tdw_vyboost


	#undef _inc_tdw_vyboost
#endif

#if defined _TDW_VH_SYS_VEHICLE_SPEED_BOOST
	#endinput
#endif

#define _TDW_VH_SYS_VEHICLE_SPEED_BOOST

#include "tdw_vehicle"


#include "tdw_vsa_data"
#include "tdw_vmath"
#include "tdw_vutils"




#if !defined _TDW_BOOSTER_SPEED_UPDATE
	#define _TDW_BOOSTER_SPEED_UPDATE (450)
#else
	#assert (0 <= _TDW_BOOSTER_SPEED_UPDATE)
#endif

#if !defined _TDW_BOOSTER_MIN_SPEED
	#define _TDW_BOOSTER_MIN_SPEED (5.0)
#else
	#assert (0 <= _TDW_BOOSTER_MIN_SPEED)
#endif

#if !defined _TDW_BOOSTER_BOOST_SPEED
	#define _TDW_BOOSTER_BOOST_SPEED (10.0)
#endif

#if !defined _TDW_BOOSTER_INACCURACY
	#define _TDW_BOOSTER_INACCURACY (0.15)
#endif




static stock
	TDW_g_sTimerName[] = !"_TDW_BOOSTER_SPEED_UPDATE_";


enum eBOOST
{
	boost_time,
	min_speed,
	boost_speed,
	inaccuracy
}
new PLAYER_BOOST[MAX_PLAYERS][eBOOST];




#if defined TDWVH_BOOST@OnPlayerStateChange
	forward TDWVH_BOOST@OnPlayerStateChange(playerid, newstate, oldstate);
#endif

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if (newstate == PLAYER_STATE_DRIVER) {
		new vehicleid = GetPlayerVehicleID(playerid);

		if (GetModelStaticType(GetVehicleModel(vehicleid)) == CAR || GetModelStaticType(GetVehicleModel(vehicleid)) == MOTORBIKE)
			_TDW_BOOSTER_SPEED_UPDATE_(playerid, vehicleid);
	}

	#if defined TDWVH_BOOST@OnPlayerStateChange
		TDWVH_BOOST@OnPlayerStateChange(playerid, newstate, oldstate);
	#endif

	return 1;
}

#if defined _ALS_OnPlayerStateChange
	#undef OnPlayerStateChange
#else
	#define _ALS_OnPlayerStateChange
#endif

#define OnPlayerStateChange TDWVH_BOOST@OnPlayerStateChange


#if defined TDWVH_BOOST@OnPlayerConnect
	forward TDWVH_BOOST@OnPlayerConnect(playerid);
#endif

public OnPlayerConnect(playerid)
{
	PLAYER_BOOST[playerid][boost_time] = _TDW_BOOSTER_SPEED_UPDATE;
	PLAYER_BOOST[playerid][min_speed] = floatround(_TDW_BOOSTER_MIN_SPEED);
	PLAYER_BOOST[playerid][boost_speed] = floatround(_TDW_BOOSTER_BOOST_SPEED);
	PLAYER_BOOST[playerid][inaccuracy] = floatround(_TDW_BOOSTER_INACCURACY);

	#if defined TDWVH_BOOST@OnPlayerConnect
		TDWVH_BOOST@OnPlayerConnect(playerid);
	#endif

	return 1;
}

#if defined _ALS_OnPlayerConnect
	#undef OnPlayerConnect
#else
	#define _ALS_OnPlayerConnect
#endif

#define OnPlayerConnect TDWVH_BOOST@OnPlayerConnect




forward _TDW_BOOSTER_SPEED_UPDATE_(playerid, vehicleid);
public _TDW_BOOSTER_SPEED_UPDATE_(playerid, vehicleid)
{
	static
		Float:z_angle,
		keys, __keys,
		Float:z_angle_old[MAX_VEHICLES],
		Float:angle_tmp,
		Float:tmp,
		Float:speed;
	if (0 == GetVehicleZAngle(vehicleid, z_angle)) return 0;
	GetPlayerKeys(playerid, keys, __keys, __keys);
	if (keys & KEY_SPRINT) 
	{
		tmp = z_angle_old[vehicleid] = floatround(floatabs(floatadd(z_angle_old[vehicleid],                             PLAYER_BOOST[playerid][inaccuracy])));
		angle_tmp = floatround(floatabs(z_angle));
		if (_:(tmp > angle_tmp || tmp < angle_tmp) == 0) 
		{
			speed = GetVehicleSpeed(vehicleid);
			if (_:(speed < PLAYER_BOOST[playerid][min_speed]                           || IsVehicleBackwordsDirection(vehicleid)) == 0)
			{
				SetVehicleSpeed(vehicleid, speed + PLAYER_BOOST[playerid][boost_speed]                            );
			}
		}
	}
	z_angle_old[vehicleid] = z_angle;
	return SetTimerEx(TDW_g_sTimerName,                              PLAYER_BOOST[playerid][boost_time], false, !"ii", playerid, vehicleid);
}
