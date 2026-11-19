case DIALOG_MERIA:
{
    if(!response) return 0;
    
    switch(listitem)
    {
        case 1:
        {
            if(PI[playerid][pFamily] != 0) return SendErr(playerid, "Вы состоите уже в семье!");
            ShowCreateFamilyDialog(playerid);
        }
        default: return 1;
    }
    return 1;
}

