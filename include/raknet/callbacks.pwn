stock SetCarLights(playerid, vehicleid, red, green, blue, alpha)
{
    new BitStream:bsn = BS_New();

    BS_WriteUint8(bsn, 225);
    BS_WriteUint8(bsn, 9);
    BS_WriteUint16(bsn, vehicleid);
    BS_WriteUint8(bsn, red);
    BS_WriteUint8(bsn, green);
    BS_WriteUint8(bsn, blue);
    BS_WriteUint8(bsn, alpha);

    PR_SendPacket(bsn, playerid);
    BS_Delete(bsn);

    return 1;
}
stock OpenURL(playerid, const url[])
{
    new BitStream:bs = BS_New();
    new url_length = strlen(url);

    BS_WriteUint8(bs, 225);
    BS_WriteUint8(bs, 13);
    BS_WriteUint16(bs, url_length);
    BS_WriteString(bs, url);

    PR_SendPacket(bs, playerid);
    BS_Delete(bs);
    return 1;
}
stock SetCarSmoke(playerid, vehicleid, red, green, blue, alpha)
{
    new BitStream:bsn = BS_New();

    BS_WriteUint8(bsn, 225);
    BS_WriteUint8(bsn, 10);
    BS_WriteUint16(bsn, vehicleid);
    BS_WriteUint8(bsn, red);
    BS_WriteUint8(bsn, green);
    BS_WriteUint8(bsn, blue);
    BS_WriteUint8(bsn, alpha);

    PR_SendPacket(bsn, playerid);
    BS_Delete(bsn);

    return 1;
}
stock SetPlayerAir(playerid)
{
    new BitStream:bsn = BS_New();

    BS_WriteUint8(bsn, 225);
    BS_WriteUint8(bsn, 11);

    PR_SendPacket(bsn, playerid);
    BS_Delete(bsn);

    return 1;
}
stock OFFHud_Int(playerid)
{
    new BitStream:bsn = BS_New();
    BS_WriteUint8(bsn, 225);
    BS_WriteUint8(bsn, 14);

    PR_SendPacket(bsn, playerid);
    BS_Delete(bsn);
    return 1;
}

stock OnHud_Int(playerid)
{
    new BitStream:bsn = BS_New();
    BS_WriteUint8(bsn, 225);
    BS_WriteUint8(bsn, 15);

    PR_SendPacket(bsn, playerid);
    BS_Delete(bsn);
    return 1;
}
stock SetVehicleNeon(playerid, vehicleid, red, green, blue, a)
{
    new BitStream:bs = BS_New();
    BS_WriteUint8(bs, 225);
    BS_WriteUint8(bs, 0);
    BS_WriteUint16(bs, vehicleid);
    BS_WriteUint8(bs, red);
    BS_WriteUint8(bs, green);
    BS_WriteUint8(bs, blue);
    BS_WriteUint8(bs, a);
    PR_SendPacket(bs, playerid);
    BS_Delete(bs);
    return 1;
}

stock SetVehicleToning(playerid, vehicleid, red, green, blue, a)
{
    new BitStream:bs = BS_New();
    BS_WriteUint8(bs, 225);
    BS_WriteUint8(bs, 2);
    BS_WriteUint16(bs, vehicleid);
    BS_WriteUint8(bs, red);
    BS_WriteUint8(bs, green);
    BS_WriteUint8(bs, blue);
    BS_WriteUint8(bs, a);
    PR_SendPacket(bs, playerid);
    BS_Delete(bs);
    if(vehicleid > 0 && vehicleid < MAX_VEHICLES)
    {
        CI[vehicleid][vToningR] = red;
        CI[vehicleid][vToningG] = green;
        CI[vehicleid][vToningB] = blue;
        CI[vehicleid][vToningA] = a;
        CI[vehicleid][vToningToggled] = (a > 8) ? true : false;
    }
    return 1;
}

stock SetPlayerPrefix(playerid, toplayerid, texture[])
{
    new BitStream:bs = BS_New();
    BS_WriteUint8(bs, 225);
    BS_WriteUint8(bs, 4);
    BS_WriteUint16(bs, toplayerid);
    BS_WriteString8(bs, texture);
    PR_SendPacket(bs, playerid);
    BS_Delete(bs);
}
stock SetAlphaPed(playerid, alpha)
{
    new BitStream:bs = BS_New();
    BS_WriteUint8(bs, 225);
    BS_WriteUint8(bs, 12);
    BS_WriteUint8(bs, alpha);
    PR_SendPacket(bs, playerid);
    BS_Delete(bs);
    return 1;
}
callback::Invisible_HidePlayer(playerid, BitStream: bs)
{
    static Float: X,
        Float: Y,
        Float: Z;

    BS_SetReadOffset(bs, 56);
    BS_ReadFloat(bs, X);
    BS_ReadFloat(bs, Y);
    BS_ReadFloat(bs, Z);


    BS_SetWriteOffset(bs, 0);

    BS_WriteUint8(bs, 212);
    BS_WriteUint16(bs, 0);
    BS_WriteUint16(bs, 0);
    BS_WriteUint16(bs, 0);
    BS_WriteFloat(bs, X);
    BS_WriteFloat(bs, Y);
    BS_WriteFloat(bs, Z);
    return 1;
}
callback::OnPlayerOnfootSync(playerid, BitStream: bs)
{
    if(PT[playerid][pInviz])
    {
        Invisible_HidePlayer(playerid, bs);
        TogglePlayerGhostMode(playerid, true);
        SetAlphaPed(playerid, 89);
    }
    if(!PT[playerid][pInviz])
    {
        TogglePlayerGhostMode(playerid, false);
        SetAlphaPed(playerid, 255);
    }
    return 1;
}
