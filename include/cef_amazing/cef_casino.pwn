#if defined _cef_casino_included
    #endinput
#endif
#define _cef_casino_included

#define CEF_CASINO_MAX_CHIPS 2000000000
#define CEF_CASINO_MAX_CASH  2147483647

new gCefCasinoMigrationStarted;

forward OnCefCasinoColumnCheck();

stock CEF_CasinoInit()
{
    mysql_tquery(dbHandle,
        "SHOW COLUMNS FROM `accounts` LIKE 'casino_chips'",
        "OnCefCasinoColumnCheck", "");
    return 1;
}

public OnCefCasinoColumnCheck()
{
    if(cache_num_rows() > 0) return 1;
    mysql_tquery(dbHandle,
        "ALTER TABLE `accounts` ADD COLUMN `casino_chips` INT UNSIGNED NOT NULL DEFAULT 0",
        "", "");
    return 1;
}

stock bool:CEF_CasinoIsAtVenue(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid)) return false;
    if(GetPlayerVirtualWorld(playerid) != 0) return false;

    if(GetPlayerInterior(playerid) == 0)
        return (GetPlayerDistanceFromPoint(playerid, 2195.8401, 1677.1505, 12.3672) <= 7.0);

    if(GetPlayerInterior(playerid) == 1)
    {
        new Float:x, Float:y, Float:z;
        GetPlayerPos(playerid, x, y, z);

        return (x >= 2180.0 && x <= 2290.0 && y >= 1540.0 && y <= 1800.0 && z >= 950.0 && z <= 1100.0);
    }
    return false;
}

stock CEF_CasinoSave(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || PI[playerid][pID] <= 0) return 0;
    new query[240];
    mysql_format(dbHandle, query, sizeof query,
        "UPDATE `accounts` SET `cash`=%d, `bank`=%d, `casino_chips`=%d WHERE `id`=%d",
        PI[playerid][pCash], PI[playerid][pBank], gCefCasinoChips[playerid], PI[playerid][pID]);
    mysql_tquery(dbHandle, query, "", "");
    return 1;
}

stock CEF_CasinoUpdateState(playerid)
{
    new json[128];
    format(json, sizeof json,
        "{\"chipsBalance\":%d,\"winningAmount\":0}", gCefCasinoChips[playerid]);
    return CEF_Send(playerid, "cef_casino_update_state", json);
}

stock CEF_CasinoFormData(playerid, dest[], size)
{
    return format(dest, size,
        "{\"balance\":%d,\"chips\":%d,\"rateBuy\":%d,\"rateSell\":%d}",
        PI[playerid][pCash], gCefCasinoChips[playerid], CEF_CASINO_RATE_BUY, CEF_CASINO_RATE_SELL);
}

stock CEF_CasinoOpen(playerid)
{
    if(!IsPlayerConnected(playerid) || !PT[playerid][pLogged]) return 0;
    if(!gCefCasinoLoaded[playerid])
        return CEFC_Notify(playerid, "Casino account data is still loading.", "hint");
    if(!CEF_CasinoIsAtVenue(playerid))
        return CEFC_Notify(playerid, "Go to Caligula's casino to exchange chips.", "error");

    new json[192];
    gCefCasinoFormOpen[playerid] = true;
    CEF_CasinoFormData(playerid, json, sizeof json);
    CEF_MarkPlayerReady(playerid);
    CEF_Send(playerid, "cef_casino_open_form", json);
    CEF_CasinoUpdateState(playerid);
    CEF_Focus(playerid, true);
    return 1;
}

stock CEF_CasinoClose(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS) return 0;
    gCefCasinoFormOpen[playerid] = false;
    CEF_SendEmpty(playerid, "cef_casino_close_form");
    CEF_Focus(playerid, false);
    return 1;
}

stock CEF_CasinoExchange(playerid, key, amount)
{
    if(!gCefCasinoLoaded[playerid] || !gCefCasinoFormOpen[playerid] || !CEF_CasinoIsAtVenue(playerid))
        return CEFC_Notify(playerid, "Casino session is no longer valid.", "error");
    if(amount < 1 || amount > CEF_CASINO_MAX_TRADE)
        return CEFC_Notify(playerid, "Choose an amount from 1 to 50000 chips.", "error");

    new buyCost = amount * CEF_CASINO_RATE_BUY;
    new sellRevenue = amount * CEF_CASINO_RATE_SELL;
    if(key == 40)
    {
        if(PI[playerid][pCash] < buyCost)
            return CEFC_Notify(playerid, "Not enough cash to buy these chips.", "error");
        if(gCefCasinoChips[playerid] < 0 || gCefCasinoChips[playerid] > CEF_CASINO_MAX_CHIPS - amount)
            return CEFC_Notify(playerid, "The chip balance limit would be exceeded.", "error");
        PI[playerid][pCash] -= buyCost;
        gCefCasinoChips[playerid] += amount;
    }
    else if(key == 41)
    {
        if(gCefCasinoChips[playerid] < amount)
            return CEFC_Notify(playerid, "Not enough casino chips to sell.", "error");
        if(PI[playerid][pCash] < 0 || PI[playerid][pCash] > CEF_CASINO_MAX_CASH - sellRevenue)
            return CEFC_Notify(playerid, "The cash balance limit would be exceeded.", "error");
        gCefCasinoChips[playerid] -= amount;
        PI[playerid][pCash] += sellRevenue;
    }
    else return 0;

    ResetPlayerMoney(playerid);
    if(PI[playerid][pCash] > 0) GivePlayerMoney(playerid, PI[playerid][pCash]);
    CEF_CasinoSave(playerid);
    CEF_EcoSaveMoney(playerid);
    CEF_CasinoUpdateState(playerid);
    new json[192];
    CEF_CasinoFormData(playerid, json, sizeof json);
    CEF_Send(playerid, "cef_casino_open_form", json);
    CEFC_HudUpdate(playerid);
    return 1;
}

stock CEF_CasinoRpc(playerid, const arguments[], dest[], size)
{
    new key = CEF_EcoFindInt(arguments, "key");
    new amount = CEF_EcoFindInt(arguments, "amount");

    if(key == 30)
    {
        CEF_CasinoClose(playerid);
        format(dest, size, "{\"result\":true}");
        return 1;
    }

    if(!gCefCasinoLoaded[playerid] || !gCefCasinoFormOpen[playerid] || !CEF_CasinoIsAtVenue(playerid))
    {
        format(dest, size, "{\"result\":false,\"error\":\"casino session unavailable\"}");
        return 0;
    }

    if(key == 40 || key == 41)
    {
        if(!CEF_CasinoExchange(playerid, key, amount))
        {
            format(dest, size, "{\"result\":false,\"balance\":%d,\"chips\":%d}",
                PI[playerid][pCash], gCefCasinoChips[playerid]);
            return 0;
        }
        format(dest, size, "{\"result\":true,\"balance\":%d,\"chips\":%d}",
            PI[playerid][pCash], gCefCasinoChips[playerid]);
        return 1;
    }

    format(dest, size, "{\"result\":false}");
    return 1;
}

CMD:casino(playerid, params[])
{
    #pragma unused params
    return CEF_CasinoOpen(playerid);
}
