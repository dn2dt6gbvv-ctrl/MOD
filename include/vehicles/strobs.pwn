callback:: function_stroboscop(vehicleid)
{
    new panels, tires;
    GetVehicleDamageStatus(vehicleid, panels, CI[vehicleid][Doors], CI[vehicleid][Lights], tires);
    switch(CI[vehicleid][vStrobsCount])
    {
        case 0: UpdateVehicleDamageStatus(vehicleid, panels, CI[vehicleid][Doors], 1, tires), CI[vehicleid][vStrobsCount] = 1;
        case 1: UpdateVehicleDamageStatus(vehicleid, panels, CI[vehicleid][Doors], 4, tires), CI[vehicleid][vStrobsCount] = 2;
        case 2: UpdateVehicleDamageStatus(vehicleid, panels, CI[vehicleid][Doors], 65,tires), CI[vehicleid][vStrobsCount] = 3;
        case 3: UpdateVehicleDamageStatus(vehicleid, panels, CI[vehicleid][Doors], 68,tires), CI[vehicleid][vStrobsCount] = 0;
    }
    return 1;
}

CMD:strob(playerid)
{
    if(!IsPlayerInAnyVehicle(playerid) || GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return 1;
    new vehicleid = GetPlayerVehicleID(playerid);
    CI[vehicleid][vStrobsCount] = 0;
    if(!CI[vehicleid][vStrobsStatus])
    {
        CI[vehicleid][vStrobsTimer] = SetTimerEx("function_stroboscop", 200, true, "i", vehicleid);
        CI[vehicleid][vStrobsStatus] = true;
        return 1;
    }
    KillTimer(CI[vehicleid][vStrobsTimer]);
    CI[vehicleid][vStrobsStatus] = false;
    new panels, tires;
    GetVehicleDamageStatus(vehicleid, panels, CI[vehicleid][Doors], CI[vehicleid][Lights], tires);
    UpdateVehicleDamageStatus(vehicleid, panels, CI[vehicleid][Doors], 0, tires);
    return 1;
}
