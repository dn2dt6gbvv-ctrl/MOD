

cmd:sellhome(playerid)
{
    if(GetPlayerHouseID(playerid) <= 0) return SendErr(playerid, "У вас нет дома!");
    ShowPlayerDialogEx(playerid, dialog_SELL_HOUSE, DIALOG_STYLE_MSGBOX, "Продажа недвижимости", "Вы действительно хотите продать свой дом государству?\nОтменить это действие будет невозможно", "Да", "Отмена");
    return 1;
}

cmd:sellmyhome(playerid, params[])
{
    if(GetPlayerHouseID(playerid) <= 0) return SendErr(playerid, "У вас нет дома!");
    if(PI[playerid][pCash] >= 1_000_000_000) return SendErr(playerid, "У вас больше 1 млрд. руб. на руках!");

    extract params -> new toplayerid, price; else return SendClientMessage(playerid, COLOR_GRAY, "Используйте:{FFFFFF} /sellmyhome [игрок] [цена]");

    
    if(!PT[toplayerid][pLogged]) return SendErr(playerid, "Такого игрока нет!");
    if(toplayerid == playerid) return SendErr(playerid, "Вы не можете продать дом самому себе!");
    if(g_PlayerOfferTarget[playerid] != INVALID_PLAYER_ID || g_PlayerOfferFrom[playerid] != INVALID_PLAYER_ID) return SendErr(playerid, "У вас уже есть активное предложение!");
    if(g_PlayerOfferTarget[toplayerid] != INVALID_PLAYER_ID || g_PlayerOfferFrom[toplayerid] != INVALID_PLAYER_ID) return SendErr(playerid, "Игрок уже рассматривает другое предложение!");

    new house_id = GetPlayerHouseID(playerid);
    if(GetPlayerHouseID(toplayerid) != 0) return SendErr(playerid, "У игрока уже есть недвижимость!");


    if(price < 1 || price > House[house_id - 1][hPrice] * 100) return SCMF(playerid, -1, "Введите цену от 1 до %s руб!", SplitInt(House[house_id - 1][hPrice] * 100));
    if(GetDistBetweenPlayers(playerid, toplayerid) > 10.0) return SendErr(playerid, "Игрок находится слишком далеко!");
    new description[112];
    format(description, sizeof(description), "КУПИТЬ ДОМ ЗА %s РУБ.", SplitInt(price));
    return PlayerOffer_Create(playerid, toplayerid, PLAYER_OFFER_HOUSE, price, description);
}

cmd:gpshome(playerid, params[])
{
    if(GetPlayerHouseID(playerid) <= 0) return SendErr(playerid, "У вас нет дома!");

    if(GetPlayerVirtualWorld(playerid) || GetPlayerInterior(playerid)) return SendErr(playerid, "Вы находитесь в виртуальном мире или интерьере!");

    new house_id = GetPlayerHouseID(playerid);
    SetPlayerRaceCheckpoint(playerid, 2, House[house_id - 1][hPos_x], House[house_id - 1][hPos_y], House[house_id - 1][hPos_z], 0.0, 0.0, 0.0, 3.0);

    SendClientMessage(playerid, COLOR_LIME, "Ваш дом отмечен на карте.");
    return 1;
}
