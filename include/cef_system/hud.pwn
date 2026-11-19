
stock UpdatePlayerHUD(playerid) return CEFC_HudUpdate(playerid);

stock SetPlayerHUDActive(playerid, bool:active) return CEFC_HudActive(playerid, active);

stock SetAdminHUDActive(playerid, bool:active) return CEFC_ChatSetAdminLevel(playerid, active ? PI[playerid][pAdmin] : 0);

stock UpdatePlayerWanted(playerid) return CEFC_HudUpdate(playerid);

stock UpdatePlayerCuffed(playerid, bool:cuffed)
{
    #pragma unused cuffed
    return CEFC_HudUpdate(playerid);
}
