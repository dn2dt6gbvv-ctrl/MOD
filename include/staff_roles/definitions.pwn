


#define STAFF_HELPER_MAX_LEVEL   3
#define STAFF_YOUTUBER_MAX_LEVEL 2

#define DIALOG_YT_PROMO 570
#define STAFF_PROMO_X (-315.5539)
#define STAFF_PROMO_Y (705.0232)
#define STAFF_PROMO_Z (12.2150)
#define STAFF_PROMO_INTERIOR_X (1412.6399)
#define STAFF_PROMO_INTERIOR_Y (-1.7875)
#define STAFF_PROMO_INTERIOR_Z (1000.9244)
#define STAFF_PROMO_INTERIOR_A (0.0)
#define STAFF_PROMO_EXIT_X (1409.7000)
#define STAFF_PROMO_EXIT_Y (-1.7875)
#define STAFF_PROMO_EXIT_Z (1000.9244)

new g_StaffPromoArea = -1;
new g_StaffPromoExitArea = -1;

new Iterator:StaffHelpers<MAX_PLAYERS>;
new Iterator:StaffYouTubers<MAX_PLAYERS>;

forward StaffRoles_InitSchema();
forward StaffRoles_OnConnect(playerid);
forward StaffRoles_OnDisconnect(playerid);
forward StaffRoles_LoadPlayer(playerid);
forward StaffRoles_CheckPromoRewards(playerid);
forward bool:StaffRoles_ValidPromoCode(const code[]);
forward StaffRoles_ShowPromoDialog(playerid);
forward StaffRoles_ActivatePromo(playerid, const code[]);
forward StaffRoles_InitPromoPoint();
forward bool:StaffRoles_OnEnterPromoArea(playerid, areaid);
forward StaffRoles_LeavePromoInterior(playerid);

stock bool:StaffRoles_IsHelper(playerid)
{
    return PI[playerid][pHelper] > 0;
}

stock bool:StaffRoles_IsYouTuber(playerid)
{
    return PI[playerid][pYouTuber] > 0;
}

stock bool:StaffRoles_CanManage(playerid)
{

    return GetAdminLevel(playerid, 7);
}
