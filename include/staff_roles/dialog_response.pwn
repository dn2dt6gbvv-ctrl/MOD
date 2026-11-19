case DIALOG_YT_PROMO:
{
    if(!response) return 1;
    if(!StaffRoles_ValidPromoCode(inputtext))
    {
        SendErr(playerid, "Код: от 3 до 24 символов A-Z, 0-9, _ или -.");
        return StaffRoles_ShowPromoDialog(playerid);
    }
    return StaffRoles_ActivatePromo(playerid, inputtext);
}
