


































































                                                                                

#if defined _inc_tdw_vutils


	#undef _inc_tdw_vutils
#endif

#if defined _TDW_VH_USEFUL_FUNCTIONS
	#endinput
#endif

#define _TDW_VH_USEFUL_FUNCTIONS

#include "tdw_vehicle"




enum E_TDW_VEHICLE_WHEEL
{
	FRONT_LEFT,  FRONT_RIGHT,
	MIDDLE_LEFT, MIDDLE_RIGHT,
	REAR_LEFT,   REAR_RIGTH
};












                                                                                

stock DestroyVehicles({Float, _}:...)
{
	const BYTES_PER_CELL = cellbits / charbits;

	new
		count,
		bytes_args;


	#emit LOAD.s.pri 8
	#emit STOR.s.pri bytes_args

	if (0 != bytes_args) {
		new
			darg_start,
			darg_end,
			ret;


		#emit LCTRL 5
		#emit ADD.c 12
		#emit STOR.s.pri darg_start


		#emit LOAD.s.alt bytes_args
		#emit ADD
		#emit STOR.s.pri darg_end


		do {

			#emit LOAD.i

			#emit PUSH.pri
			#emit PUSH.c 4
			#emit SYSREQ.c DestroyVehicle

			#emit STOR.s.pri ret

			if (ret)
				count++;

			darg_end -= BYTES_PER_CELL;

			#emit LOAD.s.pri darg_end
		} while (darg_end > darg_start);

		bytes_args += bytes_args + BYTES_PER_CELL;

		#emit LCTRL 4
		#emit LOAD.s.alt bytes_args
		#emit ADD
		#emit SCTRL 4
	} else {
		#if defined _TDW_VH_DETECT_FOREACH
			foreach (new i: Vehicle)
		#else
			for (new i = _TDW_FOREACH_MAX_VEHICLES_; --i != 0;)
		#endif
		{
			if (0 == DestroyVehicle(i))
				++count;
		}
	}
	return count;
}









                                                                                

stock GetNumberOfValidVehicles()
{
	#if defined _TDW_VH_DETECT_FOREACH
		return Iter_Count(Vehicle);
	#else
		new
			count;
		for (new i = _TDW_FOREACH_MAX_VEHICLES_; --i != 0;)
			if (IsValidVehicle(i))
				++count;
		return count;
	#endif
}









                                                                                

stock IsVehicleOccupied(vehicleid)
{
	if (IsValidVehicle(vehicleid)) {
		#if defined foreach
			foreach (new i: Player)
		#else
			for (new i = _TDW_FOREACH_MAX_PLAYERS_; --i != -1;)
		#endif
		{
			if (0 != IsPlayerInVehicle(i, vehicleid))
				return 1;
		}
	}
	return 0;
}









                                                                                

stock IsVehicleSeatOccupied(vehicleid, seatid)
{
	if (IsValidVehicle(vehicleid)) {
		#if defined foreach
			foreach (new i: Player)
		#else
			for (new i = _TDW_FOREACH_MAX_PLAYERS_; --i != -1;)
		#endif
		{
			if (0 == IsPlayerInVehicle(i, vehicleid))
				continue;
			if (GetPlayerVehicleSeat(i) != seatid)
				continue;
			return 1;
		}
	}
	return 0;
}









                                                                                

stock GetVehicleMaxPassengers(modelid)
{
	static const
		vehicle_seat_data[MAX_VEHICLE_MODELS + 1 char] =
	{
		4, 2, 2, 2, 4, 4, 1, 2, 2, 4, 2, 2, 2, 4, 2, 2, 4, 2, 4, 2, 4, 4, 2, 2,
		2, 1, 4, 4, 4, 2, 1, 7, 1, 2, 2, 0, 2, 7, 4, 2, 4, 1, 2, 2, 2, 4, 1, 2,
		1, 0, 0, 2, 1, 1, 1, 2, 2, 2, 4, 4, 2, 2, 2, 2, 1, 1, 4, 4, 2, 2, 4, 2,
		1, 1, 2, 2, 1, 2, 2, 4, 2, 1, 4, 3, 1, 1, 1, 4, 2, 2, 4, 2, 4, 1, 2, 2,
		2, 4, 4, 2, 2, 1, 2, 2, 2, 2, 2, 4, 2, 1, 1, 2, 1, 1, 2, 2, 4, 2, 2, 1,
		1, 2, 2, 2, 2, 2, 2, 2, 2, 4, 1, 1, 1, 2, 2, 2, 2, 7, 7, 1, 4, 2, 2, 2,
		2, 2, 4, 4, 2, 2, 4, 4, 2, 1, 2, 2, 2, 2, 2, 2, 4, 4, 2, 2, 1, 2, 4, 4,
		1, 0, 0, 1, 1, 2, 1, 2, 2, 1, 2, 4, 4, 2, 4, 1, 0, 4, 2, 2, 2, 2, 0, 0,
		7, 2, 2, 1, 4, 4, 4, 2, 2, 2, 2, 2, 4, 2, 0, 0, 0, 4, 0, 0
	};
	return (
		IS_VALID_MODEL(modelid)
		? (vehicle_seat_data{modelid - MIN_VEHICLE_MODEL})
		: 0
	);
}









                                                                                

stock GetVehicleDoorsCount(modelid)
{
	static const
		vehicle_door_data[MAX_VEHICLE_MODELS + 1 char] =
	{
		4, 2, 2, 2, 4, 4, 2, 2, 2, 4, 2, 2, 2, 2, 2, 2, 2, 2, 4, 2, 4, 4, 2, 2,
		0, 1, 4, 2, 2, 0, 0, 0, 0, 2, 2, 0, 2, 0, 4, 0, 2, 0, 2, 2, 2, 4, 0, 2,
		0, 0, 0, 2, 0, 0, 0, 2, 2, 0, 4, 2, 0, 0, 0, 0, 0, 0, 4, 4, 0, 2, 4, 0,
		0, 0, 2, 2, 1, 2, 2, 4, 0, 0, 2, 2, 0, 0, 0, 4, 4, 2, 4, 2, 4, 0, 0, 2,
		2, 4, 2, 2, 2, 0, 0, 0, 0, 2, 2, 4, 2, 0, 0, 2, 0, 0, 2, 2, 4, 2, 2, 0,
		1, 0, 0, 0, 2, 2, 2, 2, 2, 4, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 4, 2, 2, 2,
		2, 2, 4, 4, 0, 2, 4, 4, 2, 0, 2, 0, 2, 2, 2, 2, 4, 4, 2, 2, 0, 2, 4, 0,
		0, 0, 0, 0, 0, 2, 2, 0, 2, 0, 2, 4, 4, 0, 2, 2, 0, 4, 0, 2, 2, 2, 0, 0,
		0, 2, 0, 0, 4, 4, 4, 2, 2, 0, 2, 2, 4, 2, 0, 0, 0, 2, 0, 0
	};
	return (
		IS_VALID_MODEL(modelid)
		? (vehicle_door_data{modelid - MIN_VEHICLE_MODEL})
		: 0
	);
}









                                                                                

stock IsValidModelForPaintjob(modelid)
{
	switch (modelid) {
		case 483:
			return 1;
		case 575:
			return 2;
		case 534, 535, 536, 558, 559, 560, 561, 562, 567, 576:
			return 3;
	}
	return 0;
}









                                                                                

stock GetVehicleWheelPos(vehicletype, E_TDW_VEHICLE_WHEEL:wheel, &Float:x,
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

	switch (wheel)
	{
		case FRONT_LEFT, FRONT_RIGHT:
			GetVehicleModelInfo(vehicletype,
				VEHICLE_MODEL_INFO_WHEELSFRONT,
				vehicle_x, vehicle_y, vehicle_z
			);
		case MIDDLE_LEFT, MIDDLE_RIGHT:
			GetVehicleModelInfo(vehicletype,
				VEHICLE_MODEL_INFO_WHEELSMID,
				vehicle_x, vehicle_y, vehicle_z
			);
		case REAR_LEFT, REAR_RIGTH:
			GetVehicleModelInfo(vehicletype,
				VEHICLE_MODEL_INFO_WHEELSREAR,
				vehicle_x, vehicle_y, vehicle_z
			);
	}

	div = (_:wheel % 2) ? (vehicle_x) : (-vehicle_x);

	x = (floatsin((z_angle = 360 - z_angle), degrees) * vehicle_y) +
		(floatcos(z_angle, degrees) * div) + x;
	y = (floatcos(z_angle, degrees) * vehicle_y) -
		(floatsin(z_angle, degrees) * div) + y;
	z = z + vehicle_z;

	return 1;
}









                                                                                

stock GetVehicleOccupant(vehicleid, seatid = 0)
{
	if (IsValidVehicle(vehicleid)) {
		#if defined foreach
			foreach (new i: Player)
		#else
			for (new i = _TDW_FOREACH_MAX_PLAYERS_; --i != -1;)
		#endif
		{
			if (GetPlayerVehicleID(i) != vehicleid)
				continue;
			if (GetPlayerVehicleSeat(i) != seatid)
				continue;

			return i;
		}
	}
	return INVALID_PLAYER_ID;
}









                                                                                

stock GetVehicleOccupantPlayers(vehicleid, playerlist[],
	size = sizeof playerlist)
{
	if (IsValidVehicle(vehicleid))
	{
		new
			array_index,
			i;

		#if defined foreach
			foreach (new i: Player)
		#else
			for (new i = _TDW_FOREACH_MAX_PLAYERS_; --i != -1;)
		#endif
		{
			if (GetPlayerVehicleID(i) != vehicleid)
				continue;
			if (array_index >= size)
				break;
			else playerlist[array_index++] = i;
		}
		if (0 != array_index) {
			playerlist[array_index] = INVALID_VEHICLE_ID;
			return 1;
		}
	}
	return 0;
}









                                                                                

stock IsVehicleMoving(vehicleid)
{
	new
		Float:x,
		Float:y,
		Float:z;

	if (0 != GetVehicleVelocity(vehicleid, x, y, z)) {
		if (0 == _:floatcmp(x, 0.0) && 0 == _:floatcmp(y, 0.0) &&
			0 == _:floatcmp(z, 0.0))
			return 1;
	}
	return 0;
}









                                                                                

stock IsVehicleBackwordsDirection(vehicleid)
{
	new
		Float:x,
		Float:y,
		Float:z;

	if (GetVehicleVelocity(vehicleid, x, y, z))
	{
		new
			Float:z_angle;

		GetVehicleZAngle(vehicleid, z_angle);

		if (z_angle < 90.0) {
			if (x > 0.0 && y < 0.0)
				return 1;
		} else if (z_angle < 180.0) {
			if (x > 0.0 && y > 0.0)
				return 1;
		} else if (z_angle < 270.0) {
			if (x < 0.0 && y > 0.0)
				return 1;
		} else {
			if (x < 0.0 && y < 0.0)
				return 1;
		}
	}
	return 0;
}
