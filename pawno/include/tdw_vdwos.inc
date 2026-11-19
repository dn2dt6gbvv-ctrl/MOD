

































































                                                                                

#if defined _inc_tdw_vdwos


	#undef _inc_tdw_vdwos
#endif

#if defined _TDW_VH_DWOS_MANAGER
	#endinput
#endif

#define _TDW_VH_DWOS_MANAGER

#include "tdw_vehicle"






#if !defined OpenVehicleDoor



	#define OpenVehicleDoor%0(%1,%2) SetVehicleDoorState(%1,%2,DOOR_OPENED)
#endif

#if !defined CloseVehicleDoor



	#define CloseVehicleDoor%0(%1,%2) SetVehicleDoorState(%1,%2,DOOR_CLOSED)
#endif

#if !defined IsVehicleDoorInState




	#define IsVehicleDoorInState%0(%1,%2,%3) \
		(_:(GetVehicleDoorState(%1,%2)) == _:(E_TDW_VH_DOOR_STATE:(%3)))
#endif



#if !defined OpenVehicleWindow



	#define OpenVehicleWindow%0(%1,%2)\
		SetVehicleWindowState(%1,%2,WINDOW_OPENED)
#endif

#if !defined CloseVehicleWindow



	#define CloseVehicleWindow%0(%1,%2)\
		SetVehicleWindowState(%1,%2,WINDOW_CLOSED)
#endif

#if !defined IsVehicleWindowInState




	#define IsVehicleWindowInState%0(%1,%2,%3)\
		(_:(GetVehicleWindowState(%1,%2) == _:(E_TDW_VH_WINDOW_STATE:(%3))))
#endif






enum E_TDW_VH_DOOR_STATE
{
	DOOR_NOT_SET = -1,
	DOOR_OPENED = 1,
	DOOR_CLOSED = 2
};



enum E_TDW_VH_WINDOW_STATE
{
	WINDOW_NOT_SET = -1,
	WINDOW_OPENED = 0,
	WINDOW_CLOSED
};














                                                                                

stock GetVehicleDoorState(vehicleid, E_TDW_VEHICLE_DOOR:door)
{
	if (0 == IsValidVehicle(vehicleid))
		return 0;
	if (0 == _:(0 <= _:door < MAX_VEHICLE_DOORS))
		return -1;

	new
		driver,
		passenger,
		backleft,
		backright;

	GetVehicleParamsCarDoors(vehicleid, driver, passenger, backleft, backright);


	switch (door) {
		case FRONT_LEFT_DOOR:
			return driver;
		case FRONT_RIGHT_DOOR:
			return passenger;
		case REAR_LEFT_DOOR:
			return backleft;
		case REAR_RIGHT_DOOR:
			return backright;
	}
	return -1;
}









                                                                                

stock SetVehicleDoorState(vehicleid, E_TDW_VEHICLE_DOOR:door,
	E_TDW_VH_DOOR_STATE:newstate)
{
	if (0 == IsValidVehicle(vehicleid))
		return 0;
	if (0 == _:(0 <= _:door < MAX_VEHICLE_DOORS))
		return 0;

	new
		driver,
		passenger,
		backleft,
		backright;

	GetVehicleParamsCarDoors(vehicleid, driver, passenger, backleft, backright);

	switch (door) {
		case FRONT_LEFT_DOOR:
			return SetVehicleParamsCarDoors(vehicleid, _:newstate, passenger,
				backleft, backright);
		case FRONT_RIGHT_DOOR:
			return SetVehicleParamsCarDoors(vehicleid, driver, _:newstate,
				backleft, backright);
		case REAR_LEFT_DOOR:
			return SetVehicleParamsCarDoors(vehicleid, driver, passenger,
				_:newstate, backright);
		case REAR_RIGHT_DOOR:
			return SetVehicleParamsCarDoors(vehicleid, driver, passenger,
				backleft, _:newstate);
	}
	return 0;
}









                                                                                

stock GetVehicleDoorPos(vehicletype, E_TDW_VEHICLE_DOOR:door, &Float:x,
	&Float:y, &Float:z)
{
	if (0 == GetVehiclePos(vehicletype, x, y, z))
		return _:(x = y = z = 0.0);

	new
		Float:z_angle,
		Float:vehicle_x,
		Float:vehicle_y,
		Float:vehicle_z,
		Float:div;

	GetVehicleZAngle(vehicletype, z_angle);
	vehicletype = GetVehicleModel(vehicletype);

	switch (door) {
		case FRONT_LEFT_DOOR, FRONT_RIGHT_DOOR:
			GetVehicleModelInfo(vehicletype,
				VEHICLE_MODEL_INFO_FRONTSEAT,
				vehicle_x, vehicle_y, vehicle_z);
		case REAR_LEFT_DOOR, REAR_RIGHT_DOOR:
			GetVehicleModelInfo(vehicletype,
				VEHICLE_MODEL_INFO_REARSEAT,
				vehicle_x, vehicle_y, vehicle_z);
	}

	div = (_:door % 2) ? (vehicle_x) : (-vehicle_x);

	x = (floatsin((z_angle = 360 - z_angle), degrees) * vehicle_y) +
		(floatcos(z_angle, degrees) * div) + x;
	y = (floatcos(z_angle, degrees) * vehicle_y) -
		(floatsin(z_angle, degrees) * div) + y;
	z += vehicle_z;

	return 1;
}











                                                                                

stock GetVehicleWindowState(vehicleid, E_TDW_VEHICLE_DOOR:door)
{
	if (0 == IsValidVehicle(vehicleid))
		return 0;
	if (0 == _:(0 <= _:door < MAX_VEHICLE_DOORS))
		return -1;

	new
		driver,
		passenger,
		backleft,
		backright;

	GetVehicleParamsCarWindows(vehicleid, driver, passenger, backleft,
		backright);


	switch (door) {
		case FRONT_LEFT_DOOR:
			return driver;
		case FRONT_RIGHT_DOOR:
			return passenger;
		case REAR_LEFT_DOOR:
			return backleft;
		case REAR_RIGHT_DOOR:
			return backright;
	}

	return -1;
}









                                                                                

stock SetVehicleWindowState(vehicleid, E_TDW_VEHICLE_DOOR:door,
	E_TDW_VH_WINDOW_STATE:newstate)
{
	if (0 == IsValidVehicle(vehicleid))
		return 0;
	if (0 == _:(0 <= _:door < MAX_VEHICLE_DOORS))
		return 0;

	new
		driver,
		passenger,
		backleft,
		backright;

	GetVehicleParamsCarWindows(vehicleid, driver, passenger, backleft,
		backright);

	switch (door) {
		case FRONT_LEFT_DOOR:
			return SetVehicleParamsCarWindows(vehicleid, _:newstate, passenger,
				backleft, backright);
		case FRONT_RIGHT_DOOR:
			return SetVehicleParamsCarWindows(vehicleid, driver, _:newstate,
				backleft, backright);
		case REAR_LEFT_DOOR:
			return SetVehicleParamsCarWindows(vehicleid, driver, passenger,
				_:newstate, backright);
		case REAR_RIGHT_DOOR:
			return SetVehicleParamsCarWindows(vehicleid, driver, passenger,
				backleft, _:newstate);
	}
	return 0;
}
