


CMD:set_neon(playerid, params[])
{
    if(GetAdminLevel(playerid, 1) == 0)
        return SendClientMessage(playerid, 0xFF0000FF, "You do not have permission to use this command.");
    
    extract params -> new vehicleid, red, green, blue, alpha; else return SendClientMessage(playerid, 0xFF0000FF, "use: /set_neon vehicleid red green blue alpha");
    CallFunctionInScript("raknet", "SetVehicleNeon", "iiiiii", playerid, vehicleid, red, green, blue, alpha);
    return 1;
}
