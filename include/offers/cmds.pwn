

cmd:pay(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;
    new target, amount;
    if(sscanf(params, "ui", target, amount)) return SendErr(playerid, "Используйте: /pay [id/ник] [сумма]");
    if(!IsPlayerConnected(target) || !PT[target][pLogged] || target == playerid) return SendErr(playerid, "Игрок недоступен.");
    if(amount < 1) return SendErr(playerid, "Сумма должна быть больше нуля.");
    if(PI[playerid][pCash] < amount) return SendErr(playerid, "Недостаточно денег.");
    if(GetDistBetweenPlayers(playerid, target) > 5.0) return SendErr(playerid, "Игрок находится слишком далеко.");
    new description[96];
    format(description, sizeof(description), "ПЕРЕДАТЬ %s РУБ.", SplitInt(amount));
    return PlayerOffer_Create(playerid, target, PLAYER_OFFER_MONEY, amount, description);
}

cmd:givemoneyto(playerid, params[]) return callcmd::pay(playerid, params);
