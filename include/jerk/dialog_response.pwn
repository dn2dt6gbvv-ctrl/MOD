case dialog_SPERM:
{
    if(!response) return 1;
    if(PI[playerid][pJerkStarted]) return SendClientMessage(playerid, COLOR_BLUE, "Пройдите в любую кабинку, чтобы начать сдачу");

    SendClientMessage(playerid, COLOR_BLUE, "Зайдите в любую комнату, чтобы начать процесс. Когда будете готовы, принесите стакан на ресепшен.");
    PI[playerid][pJerkStarted] = true;
}
