

stock StaffRoles_InitPromoPoint()
{
    g_StaffPromoArea = CreateDynamicSphere(STAFF_PROMO_X, STAFF_PROMO_Y, STAFF_PROMO_Z, 1.35, 0, 0);
    g_StaffPromoExitArea = CreateDynamicSphere(STAFF_PROMO_EXIT_X, STAFF_PROMO_EXIT_Y, STAFF_PROMO_EXIT_Z, 1.35, 0, 1);
    return 1;
}

stock StaffRoles_LeavePromoInterior(playerid)
{
    SetPlayerPos(playerid, STAFF_PROMO_X - 2.5, STAFF_PROMO_Y, STAFF_PROMO_Z);
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    SetCameraBehindPlayer(playerid);
    return 1;
}

stock bool:StaffRoles_OnEnterPromoArea(playerid, areaid)
{
    if(areaid == g_StaffPromoExitArea)
    {
        StaffRoles_LeavePromoInterior(playerid);
        return true;
    }
    if(areaid != g_StaffPromoArea) return false;
    if(!PT[playerid][pLogged]) return true;
    if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER || GetPlayerState(playerid) == PLAYER_STATE_PASSENGER)
        return SendErr(playerid, "Покиньте транспорт, чтобы войти в промоцентр."), true;

    SetPlayerPos(playerid, STAFF_PROMO_INTERIOR_X, STAFF_PROMO_INTERIOR_Y, STAFF_PROMO_INTERIOR_Z);
    SetPlayerFacingAngle(playerid, STAFF_PROMO_INTERIOR_A);
    SetPlayerInterior(playerid, 1);
    SetPlayerVirtualWorld(playerid, 0);
    SetCameraBehindPlayer(playerid);
    StaffRoles_ShowPromoDialog(playerid);
    return true;
}
