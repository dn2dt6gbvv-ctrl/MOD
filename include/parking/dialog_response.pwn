case dialog_PARKING:
{
    if(!response) return 0;
    ShowPlayerDialogEx(playerid, dialog_PARKING+1, DIALOG_STYLE_MSGBOX, "Гаражный кооператив", "{FF0000}Внимание! {FFFFFF}Воспользовавшись данной системой Вы сможете забрать свое транспортное средство, \
    которое идет первым по списку в {ff9945}TAB\n\
    {FFFFFF}Остальные транспортные средства доступны {ff9945}только при наличии квартиры или дома\n\
    {FFFFFF}Данная операция стоит{ff9945} 10.000 рублей{FFFFFF}, Вы точно хотите забрать транспорт?", "Забрать", "Закрыть");

    return 1;
}

case dialog_PARKING+1:
{
    if(!response) return 0;
    if(PI[playerid][pCash] < 10000) return SendErr(playerid, "У Вас недостаточно денег");

    new query[90];
    mysql_format(dbHandle, query, sizeof(query), "SELECT * FROM `cars` WHERE `owner_id` = %d", PI[playerid][pID]);
    mysql_tquery(dbHandle, query, "OnPlayerCarsReceived", "i", playerid);

    return 1;
}
