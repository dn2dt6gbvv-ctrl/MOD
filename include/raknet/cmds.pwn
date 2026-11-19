CMD:pc(playerid, params[]) callcmd::set_number(playerid, params);
CMD:set_number(playerid, params[])
{
    extract params -> new vehicleId, string:text[50], string:region[50]; else return SendClientMessage(playerid, -1, "/pc <victimid> <text> <region>");

    new BitStream:bs = BS_New();
    BS_WriteUint8(bs, 225);
    BS_WriteUint8(bs, 6);
    BS_WriteUint16(bs, vehicleId);
    BS_WriteString8(bs, text);
    BS_WriteString8(bs, region);
    PR_SendPacket(bs, playerid);
    BS_Delete(bs);

    new string_[256];
    format(string_, sizeof string_, "Plate create: vehicleId - %d", vehicleId);
    SendClientMessage(playerid, -1, string_);
    return 1;
}

CMD:nc(playerid, params[]) callcmd::set_neon(playerid, params);
CMD:set_neon(playerid, params[])
{
    extract params -> new vehicleId, red, green, blue, a; else return SendClientMessage(playerid, COLOR_RED, "Используйте: /set_neon [id машины] [red] [green] [blue] [alpha(0-255)]");

    SetVehicleNeon(playerid, vehicleId, red, green, blue, a);

    SCMF(playerid, -1, "Light neon create: vehicleId - %d | a - %d | red - %d | green - %d | blue - %d", vehicleId, a, red, green, blue);
    return 1;  
}

CMD:tc(playerid, params[]) callcmd::set_tint(playerid, params);
CMD:set_tint(playerid, params[])
{
    extract params -> new vehicleId, red, green, blue, a; else return SendClientMessage(playerid, -1, "/tc <vehID> <R G B A>");

    SetVehicleToning(playerid, vehicleId, red, green, blue, a);

    SCMF(playerid, -1, "Tint create: vehicleId - %d | a - %d | red - %d | green - %d | blue - %d", vehicleId, a, red, green, blue);
    return 1;
}


CMD:ec(playerid, params[]) callcmd::set_prefix(playerid, params);
CMD:set_prefix(playerid, params[])
{
    extract params -> new toplayerid, string:texture[50]; else return SendClientMessage(playerid, -1, "/ec <forplayerid> <texture>");

    SetPlayerPrefix(playerid, toplayerid, texture);
    SCMF(playerid, -1, "Embleme with texture %s was created: forplayerid - %d", texture, toplayerid);

    return 1;
}
CMD:inviz(playerid)
{
    if(!GetAdminLevel(playerid, 1)) return SendErr(playerid, messageUnknownCMD);

    PT[playerid][pInviz] = !PT[playerid][pInviz];
    return 1;
}
