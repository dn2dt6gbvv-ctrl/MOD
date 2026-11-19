























































                                                                                

#if defined _inc_tdw_viterator


	#undef _inc_tdw_viterator
#endif

#if defined _TDW_VH_ITERATOR_ARRAY
	#endinput
#endif

#define _TDW_VH_ITERATOR_ARRAY




#if !defined foreach || !defined Iter_Add
	#endinput
#endif

#if !defined _TDW_VH_DETECT_FOREACH
	#define _TDW_VH_DETECT_FOREACH
#endif

#if !defined Vehicle@YSII_Ag

	new Iterator:Vehicle<MAX_VEHICLES>;



	#pragma unused Vehicle@YSII_Ag, Vehicle@YSII_Cg
#endif




static stock
	TDW_g_sVehicleId;





#if !defined BAD_AddStaticVehicle
	native BAD_AddStaticVehicle(modelid, Float:spawn_x, Float:spawn_y,
		Float:spawn_z, Float:z_angle, color1, color2) = AddStaticVehicle;
#endif

stock TDWVH_ITER@AddStaticVehicle(modelid, Float:spawn_x, Float:spawn_y,
	Float:spawn_z, Float:z_angle, color1, color2)
{
	if (INVALID_VEHICLE_ID != (TDW_g_sVehicleId = AddStaticVehicle(modelid,
		spawn_x, spawn_y, spawn_z, z_angle, color1, color2))) {
		Iter_Add(Vehicle, TDW_g_sVehicleId);
	}
	return TDW_g_sVehicleId;
}

#if defined _ALS_AddStaticVehicle
	#undef AddStaticVehicle
#else
	#define _ALS_AddStaticVehicle
#endif

#define AddStaticVehicle TDWVH_ITER@AddStaticVehicle



#if !defined BAD_AddStaticVehicleEx
	native BAD_AddStaticVehicleEx(modelid, Float:spawn_x, Float:spawn_y,
		Float:spawn_z, Float:z_angle, color1, color2, respawn_delay,
		addsiren = 0) = AddStaticVehicleEx;
#endif

stock TDWVH_ITER@AddStaticVehicleEx(modelid, Float:spawn_x, Float:spawn_y,
	Float:spawn_z, Float:z_angle, color1, color2, respawn_delay, addsiren = 0)
{
	if (INVALID_VEHICLE_ID != (TDW_g_sVehicleId = AddStaticVehicleEx(modelid,
		spawn_x, spawn_y, spawn_z, z_angle, color1, color2, respawn_delay,
		addsiren))) {
		Iter_Add(Vehicle, TDW_g_sVehicleId);
	}
	return TDW_g_sVehicleId;
}

#if defined _ALS_AddStaticVehicleEx
	#undef AddStaticVehicleEx
#else
	#define _ALS_AddStaticVehicleEx
#endif

#define AddStaticVehicleEx TDWVH_ITER@AddStaticVehicleEx



#if !defined BAD_CreateVehicle
	native BAD_CreateVehicle(vehicletype, Float:x, Float:y, Float:z,
		Float:rotation, color1, color2, respawn_delay,
		addsiren = 0) = CreateVehicle;
#endif

stock TDWVH_ITER@CreateVehicle(vehicletype, Float:x, Float:y, Float:z,
	Float:rotation, color1, color2, respawn_delay, addsiren = 0)
{
	if (INVALID_VEHICLE_ID != (TDW_g_sVehicleId = CreateVehicle(vehicletype,
		x, y, z, rotation, color1, color2, respawn_delay,
		addsiren))) {
		Iter_Add(Vehicle, TDW_g_sVehicleId);
	}
	return TDW_g_sVehicleId;
}

#if defined _ALS_CreateVehicle
	#undef CreateVehicle
#else
	#define _ALS_CreateVehicle
#endif

#define CreateVehicle TDWVH_ITER@CreateVehicle














                                                                                

stock DestroyVehicleSafe(&vehicleid)
{
	Iter_SafeRemove(Vehicle, vehicleid, vehicleid);
	return DestroyVehicle(vehicleid);
}






#if !defined BAD_DestroyVehicle
	native BAD_DestroyVehicle(vehicleid) = DestroyVehicle;
#endif

stock TDWVH_ITER@DestroyVehicle(vehicleid)
{
	return DestroyVehicleSafe(vehicleid);
}

#if defined _ALS_DestroyVehicle
	#undef DestroyVehicle
#else
	#define _ALS_DestroyVehicle
#endif

#define DestroyVehicle TDWVH_ITER@DestroyVehicle
