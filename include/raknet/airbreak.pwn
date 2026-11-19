stock EnablePlayerAirBreak(playerid)
{
    new BitStream:bitstream = BS_New();

    BS_WriteValue(bitstream, PR_UINT8, 225);
    BS_WriteValue(bitstream, PR_UINT8, 6);
    BS_WriteValue(bitstream, PR_UINT16, playerid);
    BS_WriteValue(bitstream, PR_FLOAT, 3);
    BS_WriteValue(bitstream, PR_BOOL, true);
    PR_SendPacket(bitstream, playerid, PR_MEDIUM_PRIORITY, PR_RELIABLE);

    BS_Delete(bitstream);
    PT[playerid][pAirBreakUsed] = true;
    return 1;
}

