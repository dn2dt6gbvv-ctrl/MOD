case dialog_AREND:
{
    if(!response) return 1;

    new i = GetPVarInt(playerid, "ArendID");

    if(PI[playerid][pArendID] != 0) return SendErr(playerid, "Вы уже арендуете транспорт!");
    if(PI[playerid][pCash] < ArendInfo[i][p_arenda_price]) return SendErr(playerid, "У вас недостаточно денег для аренды транспорта!");

    SendClientMessage(playerid, COLOR_LIME, "Вы арендовали транспорт.");
    SendClientMessage(playerid, -1, "Используйте /unrent, чтобы прекратить аренду самоката");

    PI[playerid][pArendID] = CreateVehicle(ArendInfo[i][p_arenda_car], ArendInfo[i][p_arenda_X], ArendInfo[i][p_arenda_Y], ArendInfo[i][p_arenda_Z], 0.0, 1, 1, -1);

    CI[PI[playerid][pArendID]][Fuel] = 50;
    CI[PI[playerid][pArendID]][Engine] = 0;
    CI[PI[playerid][pArendID]][Lights] = 0;

    SetVehicleParamsEx(PI[playerid][pArendID], CI[PI[playerid][pArendID]][Engine], CI[PI[playerid][pArendID]][Lights], CI[PI[playerid][pArendID]][Alarm], CI[PI[playerid][pArendID]][Doors], CI[PI[playerid][pArendID]][Bonnet], CI[PI[playerid][pArendID]][Boot], CI[PI[playerid][pArendID]][Objective]);
    
    TransferMoney(playerid, -1, ArendInfo[i][p_arenda_price], "Аренда транспорта");
    PutPlayerInVehicle(playerid, PI[playerid][pArendID], 0);

    DeletePVar(playerid, "ArendID");
}
case dialog_AREND+1:
{
    if(!response) return 1;

    SendErr(playerid, "Вы отменили аренду своего транспорта.");
    DestroyVehicle(PI[playerid][pArendID]);
    HideBHint(playerid);

    PI[playerid][pArendID] = 0;
    PI[playerid][pArendTime] = 0;
}
