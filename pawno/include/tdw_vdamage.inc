































































                                                                                

#if defined _inc_tdw_vdamage


	#undef _inc_tdw_vdamage
#endif

#if defined _TDW_VH_DAMAGE_STATUS
	#endinput
#endif

#define _TDW_VH_DAMAGE_STATUS

#include "tdw_vehicle"




static stock
	TDW_g_sNullStorage = 0;















                                                                                

stock GetVehicleLightsStatus(vehicleid, &front_left_light, &front_right_light,
	&back_lights)
{
	new
		lights;



	if (0 == GetVehicleDamageStatus(vehicleid, TDW_g_sNullStorage,
		TDW_g_sNullStorage, lights, TDW_g_sNullStorage))
		return 0;

	front_left_light = lights & 1;
	front_right_light = (lights >>> 2) & 1;
	back_lights = (lights >>> 6) & 1;

	return 1;
}












                                                                                

stock SetVehicleLightsStatus(vehicleid, front_left_light, front_right_light,
	back_lights)
{
	new
		panels,
		doors,
		tires;



	if (0 == GetVehicleDamageStatus(vehicleid, panels, doors,
		TDW_g_sNullStorage, tires))
		return 0;

	UpdateVehicleDamageStatus(vehicleid, panels, doors,
		((back_lights & 1) << 6) | ((front_right_light & 1) << 2) |
		(front_left_light & 1), tires);

	return 1;
}













                                                                                

stock GetVehicleTiresStatus(vehicleid, &rear_right_tire, &front_right_tire,
		&rear_left_tire, &front_left_tire)
{
	new
		tires;

	if (0 == GetVehicleDamageStatus(vehicleid, TDW_g_sNullStorage,
		TDW_g_sNullStorage, TDW_g_sNullStorage, tires))
		return 0;

	rear_right_tire = tires & 1;
	front_right_tire = (tires >>> 1) & 1;
	rear_left_tire = (tires >>> 2) & 1;
	front_left_tire = (tires >>> 3) & 1;

	return 1;
}













                                                                                

stock SetVehicleTiresStatus(vehicleid, rear_right_tire, front_right_tire,
		rear_left_tire, front_left_tire)
{
	new
		panels,
		doors,
		lights;

	if (0 == GetVehicleDamageStatus(vehicleid, panels, doors, lights,
		TDW_g_sNullStorage))
		return 0;

	UpdateVehicleDamageStatus(vehicleid, panels, doors, lights,
		rear_right_tire | (front_right_tire << 1) | (rear_left_tire << 2) |
		(front_left_tire << 3)
	);

	return 1;
}
















                                                                                

stock GetVehiclePanelsStatus(vehicleid, &front_left_panel, &front_right_panel,
	&rear_left_panel, &rear_right_panel, &windshield, &front_bumper,
	&rear_bumper)
{
	new
		panels;

	if (0 == GetVehicleDamageStatus(vehicleid, panels, TDW_g_sNullStorage,
		TDW_g_sNullStorage, TDW_g_sNullStorage))
		return 0;

	front_left_panel = panels & 0xF;
	front_right_panel = (panels >> 4) & 0xF;
	rear_left_panel = (panels >> 8) & 0xF;
	rear_right_panel = (panels >> 12) & 0xF;
	windshield = (panels >> 16) & 0xF;
	front_bumper = (panels >> 20) & 0xF;
	rear_bumper = (panels >> 24) & 0xF;

	return 1;
}
















                                                                                

stock SetVehiclePanelsStatus(vehicleid, front_left_panel, front_right_panel,
	rear_left_panel, rear_right_panel, windshield, front_bumper,
	rear_bumper)
{
	new
		doors,
		lights,
		tires;

	if (0 == GetVehicleDamageStatus(vehicleid, TDW_g_sNullStorage, doors,
		lights, tires))
		return 0;

	UpdateVehicleDamageStatus(vehicleid, (front_left_panel |
		(front_right_panel << 4) | (rear_left_panel << 8) |
		(rear_right_panel << 12) | (windshield << 16) | (front_bumper << 20) |
		(rear_bumper << 24)), doors, lights, tires
	);

	return 1;
}













                                                                                

stock GetVehicleDoorsStatus(vehicleid, &bonnet, &boot, &driver_door,
	&passenger_door)
{
	new
		doors;

	if (0 == GetVehicleDamageStatus(vehicleid, TDW_g_sNullStorage, doors,
		TDW_g_sNullStorage, TDW_g_sNullStorage))
		return 0;

	bonnet = doors & 7;
	boot = (doors >>> 8) & 7;
	driver_door = (doors >>> 16) & 7;
	passenger_door = (doors >>> 24) & 7;

	return 1;
}












                                                                                

stock SetVehicleDoorsStatus(vehicleid, bonnet, boot, driver_door,
	passenger_door)
{
	new
		panels,
		lights,
		tires;

	if (0 == GetVehicleDamageStatus(vehicleid, panels, TDW_g_sNullStorage,
		lights, tires))
		return 0;

	UpdateVehicleDamageStatus(vehicleid, panels, bonnet | (boot << 8) |
		(driver_door << 16) | (passenger_door << 24), lights, tires
	);

	return 1;
}
