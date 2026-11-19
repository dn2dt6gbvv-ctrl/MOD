
stock ShowSpeedometer(playerid)
{
    CEFC_SpeedometerShow(playerid);
    CEFC_SpeedometerRefresh(playerid);
    return 1;
}

stock HideSpeedometer(playerid) return CEFC_SpeedometerHide(playerid);

stock SetSpeedometerIndicatorValue(playerid, param, value)
{
    #pragma unused param
    #pragma unused value
    return CEFC_SpeedometerRefresh(playerid);
}
