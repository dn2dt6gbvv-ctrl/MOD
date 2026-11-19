






























































                                                                                

#if defined _inc_tdw_vehicle


	#undef _inc_tdw_vehicle
#endif

#if defined _TDW_VH_CORE
	#endinput
#endif

#define _TDW_VH_CORE





#if !defined MIN_VEHICLE_PAINTJOB
	#define MIN_VEHICLE_PAINTJOB		(0)
#endif
#if !defined MAX_VEHICLE_PAINTJOB
	#define MAX_VEHICLE_PAINTJOB		(3)
#endif


#if !defined MIN_VEHICLE_MODEL
	#define MIN_VEHICLE_MODEL			(400)
#endif
#if !defined MAX_VEHICLE_MODEL
	#define MAX_VEHICLE_MODEL			(611)
#endif
#if !defined MAX_VEHICLE_MODELS
	#define MAX_VEHICLE_MODELS			(MAX_VEHICLE_MODEL - MIN_VEHICLE_MODEL)
#endif


#if !defined MIN_VEHICLE_COMPONENT_ID
	#define MIN_VEHICLE_COMPONENT_ID	(1000)
#endif
#if !defined MAX_VEHICLE_COMPONENT_ID
	#define MAX_VEHICLE_COMPONENT_ID	(1193)
#endif
#if !defined MAX_VEHICLE_COMPONENTS
	#define MAX_VEHICLE_COMPONENTS		(MAX_VEHICLE_COMPONENT_ID - \
		MIN_VEHICLE_COMPONENT_ID)
#endif


#if !defined MAX_NUMBER_PLATE_SIZE
	#define MAX_NUMBER_PLATE_SIZE		(32)
#endif
#if !defined MAX_NUMBER_PLATE
	#define MAX_NUMBER_PLATE			(8)
#endif


#if !defined MAX_VEHICLE_PASSENGERS
	#define MAX_VEHICLE_PASSENGERS		(8)
#endif


#if !defined MAX_VEHICLE_DOORS
	#define MAX_VEHICLE_DOORS			(4)
#endif


#if !defined _TDW_FOREACH_MAX_VEHICLES_
	#if defined GetVehiclePoolSize
		#define _TDW_FOREACH_MAX_VEHICLES_	(GetVehiclePoolSize() + 1)
	#else
		#define _TDW_FOREACH_MAX_VEHICLES_	(MAX_VEHICLES)
	#endif
#endif

#if !defined _TDW_FOREACH_MAX_PLAYERS_
	#if defined GetPlayerPoolSize
		#define _TDW_FOREACH_MAX_PLAYERS_	(GetPlayerPoolSize() + 1)
	#else
		#define _TDW_FOREACH_MAX_PLAYERS_	(GetMaxPlayers())
	#endif
#endif





#if !defined IS_VALID_PAINTJOB
	#define IS_VALID_PAINTJOB%0(%1)		_:(MIN_VEHICLE_PAINTJOB <= \
		(%1) <= MAX_VEHICLE_PAINTJOB)
#endif


#if !defined IS_VALID_MODEL
	#define IS_VALID_MODEL%0(%1)		_:(MIN_VEHICLE_MODEL <= \
		(%1) <= MAX_VEHICLE_MODEL)
#endif


#if !defined IS_VALID_COMPONENT_ID
	#define IS_VALID_COMPONENT_ID%0(%1)	_:(MIN_VEHICLE_COMPONENT_ID <= \
		(%1) <= MAX_VEHICLE_COMPONENT_ID)
#endif


#if !defined IS_VALID_VEHICLEID
	#define IS_VALID_VEHICLEID%0(%1) _:(0 < (%1) < MAX_VEHICLES)
#endif




#if !defined IsValidVehicle

	native IsValidVehicle(vehicleid);
#endif




#if !defined _TDW_STATIC_ENUM
	#if defined __PawnBuild
		#define _TDW_STATIC_ENUM static
	#else
		#define _TDW_STATIC_ENUM
	#endif
#endif




forward __TDW_VEHICLE_CALL_EMIT_FIX__@();
public __TDW_VEHICLE_CALL_EMIT_FIX__@()
{
	#emit RETN
	static null_string[] = !" ";


	DestroyVehicle(0);
	SetVehicleNumberPlate(0, null_string);
	Create3DTextLabel(null_string, 0, 0.0, 0.0, 0.0, 0.0, 0, 0);
	Attach3DTextLabelToVehicle(Text3D:0, 0, 0.0, 0.0, 0.0);
	#if defined _TDW_VH_DETECT_STREAMER
		UpdateDynamic3DTextLabelText(Text3D:0, 0, null_string);
	#else
		Update3DTextLabelText(Text3D:0, 0, null_string);
	#endif
}
