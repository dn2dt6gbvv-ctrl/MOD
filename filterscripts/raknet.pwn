#define FILTERSCRIPT

#include <a_samp.inc>
#include <Pawn.CMD>
#include <Pawn.RakNet>
#include <sscanf2>



public OnFilterScriptInit()
{
   return 1;
}

public OnFilterScriptExit()
{
   return 1;
}

public OnPlayerConnect(playerid)
{
   return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
   return 1;
}

forward SendRaknetDataToGameMode(playerid);
public SendRaknetDataToGameMode(playerid)
{
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	SetPlayerPos(playerid, x+10.0, y+10.0, z);
	SendClientMessage(playerid, -1, "Rak.Net.Data from filterscript was delivered successfully!");
}

forward SetVehicleNeon(callerid, vehicleid, red, green, blue, alpha);
public SetVehicleNeon(callerid, vehicleid, red, green, blue, alpha)
{
	new text[56];
	format(text, sizeof text, "SetVehicleNeon(%d, %d, %d, %d) was called from raknet.pwn!", vehicleid, red, green, blue, alpha);
	SendClientMessage(callerid, -1, text);
	
    new BitStream:bs = BS_New();
    BS_WriteUint8(bs, 225);
    BS_WriteUint8(bs, 0);
    BS_WriteUint16(bs, vehicleid);
    BS_WriteUint8(bs, red);
    BS_WriteUint8(bs, green);
    BS_WriteUint8(bs, blue);
    BS_WriteUint8(bs, alpha);

    PR_SendPacketToVehicleStream(bs, vehicleid);
    BS_Delete(bs);
    return 1;
}
