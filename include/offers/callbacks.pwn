

stock PlayerOffer_OnConnect(playerid)
{
    g_PlayerOfferFrom[playerid] = INVALID_PLAYER_ID;
    g_PlayerOfferTarget[playerid] = INVALID_PLAYER_ID;
    g_PlayerOfferType[playerid] = PLAYER_OFFER_NONE;
    g_PlayerOfferValue[playerid] = 0;
    g_PlayerOfferToken[playerid]++;
    return 1;
}

stock PlayerOffer_Clear(target)
{
    new sender = g_PlayerOfferFrom[target];
    if(sender != INVALID_PLAYER_ID && sender >= 0 && sender < MAX_PLAYERS && g_PlayerOfferTarget[sender] == target)
        g_PlayerOfferTarget[sender] = INVALID_PLAYER_ID;

    g_PlayerOfferFrom[target] = INVALID_PLAYER_ID;
    g_PlayerOfferType[target] = PLAYER_OFFER_NONE;
    g_PlayerOfferValue[target] = 0;
    g_PlayerOfferToken[target]++;
    if(IsPlayerConnected(target)) CEFC_OfferHide(target);
    if(sender != INVALID_PLAYER_ID && sender >= 0 && sender < MAX_PLAYERS && IsPlayerConnected(sender)) CEFC_OfferHide(sender);
    return 1;
}

stock PlayerOffer_OnDisconnect(playerid)
{
    new sender = g_PlayerOfferFrom[playerid];
    if(sender != INVALID_PLAYER_ID && IsPlayerConnected(sender))
        SendClientMessage(sender, COLOR_GRAY, "Предложение отменено: игрок вышел с сервера.");
    if(sender != INVALID_PLAYER_ID) PlayerOffer_Clear(playerid);

    new target = g_PlayerOfferTarget[playerid];
    if(target != INVALID_PLAYER_ID && target >= 0 && target < MAX_PLAYERS && g_PlayerOfferFrom[target] == playerid)
    {
        if(IsPlayerConnected(target)) SendClientMessage(target, COLOR_GRAY, "Предложение отменено: игрок вышел с сервера.");
        PlayerOffer_Clear(target);
    }
    g_PlayerOfferTarget[playerid] = INVALID_PLAYER_ID;
    return 1;
}

stock PlayerOffer_Create(sender, target, E_PLAYER_OFFER_TYPE:type, value, const description[])
{
    if(!IsPlayerConnected(sender) || !IsPlayerConnected(target) || !PT[sender][pLogged] || !PT[target][pLogged] || sender == target)
        return SendErr(sender, "Игрок недоступен.");
    if(g_PlayerOfferFrom[target] != INVALID_PLAYER_ID || g_PlayerOfferTarget[target] != INVALID_PLAYER_ID || g_PlayerOfferTarget[sender] != INVALID_PLAYER_ID)
        return SendErr(sender, "У одного из игроков уже есть активное предложение.");

    g_PlayerOfferFrom[target] = sender;
    g_PlayerOfferTarget[sender] = target;
    g_PlayerOfferType[target] = type;
    g_PlayerOfferValue[target] = value;
    g_PlayerOfferToken[target]++;

    new text[144], message[196];
    format(text, sizeof(text), "~w~%s~n~~g~Y~w~ - ПРИНЯТЬ  ~r~N~w~ - ОТКЛОНИТЬ", description);
    GameTextForPlayer(target, text, PLAYER_OFFER_TIMEOUT, 3);
    format(message, sizeof(message), "%s предлагает: %s. Нажмите Y — принять, N — отклонить.", GetName(sender), description);
    SendClientMessage(target, COLOR_UNMAZING, message);
    {
        new nickBuf[64];
        format(nickBuf, sizeof(nickBuf), "%s[%d]", GetName(sender), sender);
        CEFC_OfferShow(target, nickBuf, description, false, PLAYER_OFFER_TIMEOUT / 1000);
        format(nickBuf, sizeof(nickBuf), "%s[%d]", GetName(target), target);
        CEFC_OfferShow(sender, nickBuf, description, true, PLAYER_OFFER_TIMEOUT / 1000);
    }
    format(message, sizeof(message), "Вы отправили предложение игроку %s. Ожидайте Y/N.", GetName(target));
    SendClientMessage(sender, COLOR_GRAY, message);
    SetTimerEx("PlayerOffer_Timeout", PLAYER_OFFER_TIMEOUT, false, "ii", target, g_PlayerOfferToken[target]);
    return 1;
}

forward PlayerOffer_Timeout(target, token);
public PlayerOffer_Timeout(target, token)
{
    if(!IsPlayerConnected(target) || token != g_PlayerOfferToken[target] || g_PlayerOfferFrom[target] == INVALID_PLAYER_ID) return 1;
    new E_PLAYER_OFFER_TYPE:type = g_PlayerOfferType[target];
    new sender = g_PlayerOfferFrom[target];
    if(type == PLAYER_OFFER_DOCUMENT) Document_HandleOfferResponse(target, 0);
    else
    {
        if(IsPlayerConnected(target)) SendClientMessage(target, COLOR_RED, "Время на ответ истекло.");
        if(IsPlayerConnected(sender)) SendClientMessage(sender, COLOR_RED, "Игрок не ответил на предложение.");
    }
    PlayerOffer_Clear(target);
    return 1;
}

stock OfferCompleteHouse(buyer, seller, price)
{
    if(!IsPlayerConnected(buyer) || !IsPlayerConnected(seller) || !PT[buyer][pLogged] || !PT[seller][pLogged]) return 0;
    if(GetDistBetweenPlayers(buyer, seller) > 10.0) return SendErr(buyer, "Продавец находится слишком далеко.");
    if(PI[buyer][pCash] < price) return SendErr(buyer, "Недостаточно денег.");
    if(GetPlayerHouseID(buyer) != 0) return SendErr(buyer, "У вас уже есть недвижимость.");

    new houseId = GetPlayerHouseID(seller);
    if(houseId <= 0) return SendErr(buyer, "У продавца больше нет дома.");
    new h = houseId - 1;
    settext(House[h][hOwner], GetName(buyer));
    House[h][hOwnerID] = PI[buyer][pID];
    PI[buyer][pSpawn] = 1;
    PI[seller][pSpawn] = 0;
    TransferMoney(buyer, seller, price, "Продажа дома игроку");

    new query[160], msg[160];
    mysql_format(dbHandle, query, sizeof(query), "UPDATE `houses` SET `owner_id` = %d WHERE `id` = %d", House[h][hOwnerID], House[h][hID]);
    mysql_tquery(dbHandle, query, "", "");
    format(msg, sizeof(msg), "Вы купили дом у %s за %s руб.", GetName(seller), SplitInt(price));
    SendClientMessage(buyer, COLOR_LIME, msg);
    format(msg, sizeof(msg), "%s купил Ваш дом за %s руб.", GetName(buyer), SplitInt(price));
    SendClientMessage(seller, COLOR_LIME, msg);
    return 1;
}

stock PlayerOffer_Respond(target, accepted)
{
    if(g_PlayerOfferFrom[target] == INVALID_PLAYER_ID) return 0;

    new sender = g_PlayerOfferFrom[target];
    new E_PLAYER_OFFER_TYPE:type = g_PlayerOfferType[target];
    new value = g_PlayerOfferValue[target];

    if(!IsPlayerConnected(sender) || !PT[sender][pLogged])
    {
        PlayerOffer_Clear(target);
        return SendErr(target, "Игрок, отправивший предложение, недоступен.");
    }

    if(type == PLAYER_OFFER_DOCUMENT)
    {
        Document_HandleOfferResponse(target, accepted);
        PlayerOffer_Clear(target);
        return 1;
    }

    PlayerOffer_Clear(target);
    if(!accepted)
    {
        SendClientMessage(target, COLOR_GRAY, "Вы отклонили предложение.");
        SendClientMessage(sender, COLOR_GRAY, "Игрок отклонил Ваше предложение.");
        return 1;
    }

    switch(type)
    {
        case PLAYER_OFFER_MONEY:
        {
            if(GetDistBetweenPlayers(sender, target) > 5.0)
            {
                SendErr(target, "Игрок находится слишком далеко.");
                SendErr(sender, "Игрок находится слишком далеко.");
                return 1;
            }
            if(value < 1 || PI[sender][pCash] < value)
            {
                SendErr(target, "У отправителя недостаточно денег.");
                SendErr(sender, "Недостаточно денег для передачи.");
                return 1;
            }
            TransferMoney(sender, target, value, "Передача денег игроку");
            new msg[144];
            format(msg, sizeof(msg), "Вы передали %s руб. игроку %s.", SplitInt(value), GetName(target));
            SendClientMessage(sender, COLOR_LIME, msg);
            format(msg, sizeof(msg), "%s передал Вам %s руб.", GetName(sender), SplitInt(value));
            SendClientMessage(target, COLOR_LIME, msg);
        }
        case PLAYER_OFFER_HOUSE:
            OfferCompleteHouse(target, sender, value);
    }
    return 1;
}

stock bool:PlayerOffer_OnKey(playerid, newkeys)
{
    if(g_PlayerOfferFrom[playerid] == INVALID_PLAYER_ID) return false;
    if(newkeys & KEY_YES) return PlayerOffer_Respond(playerid, 1), true;
    if(newkeys & KEY_NO) return PlayerOffer_Respond(playerid, 0), true;
    return false;
}
