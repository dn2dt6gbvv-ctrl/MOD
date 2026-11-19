#if defined _cef_player_trade_included
    #endinput
#endif
#define _cef_player_trade_included

#define CEF_TRADE_MAIN_SLOTS 90
#define CEF_TRADE_MAX_SLOTS 48
#define CEF_TRADE_OFFER_SLOTS 10
#define CEF_TRADE_MAX_BALANCE 2147483647
#define CEF_TRADE_INVALID_PLAYER -1
#define CEF_TRADE_AREA_MAIN 1
#define CEF_TRADE_AREA_OFFER 5

#define CEF_TRADE_ACTION_REFUSE 1
#define CEF_TRADE_ACTION_ACCEPT 2
#define CEF_TRADE_ACTION_ADD_MONEY 3
#define CEF_TRADE_ACTION_MOVE_ITEM 4
#define CEF_TRADE_ACTION_INFO 5

new gCefTradePartner[MAX_PLAYERS] = { CEF_TRADE_INVALID_PLAYER, ... };
new gCefTradeReady[MAX_PLAYERS];
new gCefTradeCashOffer[MAX_PLAYERS];
new gCefTradeItemType[MAX_PLAYERS][CEF_TRADE_OFFER_SLOTS];
new gCefTradeItemAmount[MAX_PLAYERS][CEF_TRADE_OFFER_SLOTS];
new gCefTradeSourceSlot[MAX_PLAYERS][CEF_TRADE_OFFER_SLOTS];
new gCefTradeInventorySourceSlot[MAX_PLAYERS][CEF_TRADE_MAIN_SLOTS];

forward CEF_TradeHandleResponse(playerid, const arguments[]);
forward CEF_TradeOnConnect(playerid);
forward CEF_TradeOnDisconnect(playerid);
forward CEF_TradeMoneyDialog(playerid, dialogid, response, listitem, const inputtext[]);

stock CEF_TradeResetState(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS) return 0;
    gCefTradeReady[playerid] = 0;
    gCefTradeCashOffer[playerid] = 0;
    for(new i = 0; i < CEF_TRADE_OFFER_SLOTS; i++)
    {
        gCefTradeItemType[playerid][i] = 0;
        gCefTradeItemAmount[playerid][i] = 0;
        gCefTradeSourceSlot[playerid][i] = -1;
    }
    for(new slot = 0; slot < CEF_TRADE_MAIN_SLOTS; slot++)
        gCefTradeInventorySourceSlot[playerid][slot] = -1;
    return 1;
}

stock CEF_TradeOnConnect(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS) return 0;
    gCefTradePartner[playerid] = CEF_TRADE_INVALID_PLAYER;
    CEF_TradeResetState(playerid);
    return 1;
}

stock CEF_TradePairAllowed(playerid, partner)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || partner < 0 || partner >= MAX_PLAYERS || playerid == partner) return 0;
    if(!IsPlayerConnected(playerid) || !IsPlayerConnected(partner)) return 0;
    if(!PT[playerid][pLogged] || !PT[partner][pLogged]) return 0;
    if(!PT[partner][pLogged]) return 0;
    if(gCefTradePartner[partner] != playerid && gCefTradePartner[partner] != CEF_TRADE_INVALID_PLAYER) return 0;
    if(GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(partner)) return 0;
    if(GetPlayerInterior(playerid) != GetPlayerInterior(partner)) return 0;
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    if(GetPlayerDistanceFromPoint(partner, x, y, z) <= 5.0) return 1;
    return 0;
}

stock CEF_TradePairValid(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) || !PT[playerid][pLogged]) return 0;
    new partner = gCefTradePartner[playerid];
    if(partner < 0 || partner >= MAX_PLAYERS || !IsPlayerConnected(partner)) return 0;
    if(!PT[partner][pLogged]) return 0;
    if(gCefTradePartner[partner] != playerid) return 0;
    if(GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(partner)) return 0;
    if(GetPlayerInterior(playerid) != GetPlayerInterior(partner)) return 0;
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    if(GetPlayerDistanceFromPoint(partner, x, y, z) <= 5.0) return 1;
    return 0;
}

stock CEF_TradeOfferHasSource(playerid, sourceSlot)
{
    for(new i = 0; i < CEF_TRADE_OFFER_SLOTS; i++)
        if(gCefTradeItemType[playerid][i] > 0 && gCefTradeSourceSlot[playerid][i] == sourceSlot)
            return 1;
    return 0;
}

stock CEF_TradeBuildOfferJson(owner, dest[], size)
{
    static part[120];
    new first = 1, spaType, itemType, amount;
    dest[0] = EOS;
    strcat(dest, "[", size);
    for(new slotId = 0; slotId < CEF_TRADE_OFFER_SLOTS; slotId++)
    {
        itemType = gCefTradeItemType[owner][slotId];
        amount = gCefTradeItemAmount[owner][slotId];
        spaType = itemType > 0 ? CEF_ItemToSpa(itemType) : 0;
        if(spaType <= 0 || amount <= 0) { spaType = 0; amount = 0; }
        format(part, sizeof part,
            "%s{\"slotId\":%d,\"type\":%d,\"value\":%d,\"string\":\"\",\"extraValue\":0,\"enchant\":0}",
            first ? "" : ",", slotId, spaType, amount);
        if(strlen(dest) + strlen(part) + 2 >= size) break;
        strcat(dest, part, size);
        first = 0;
    }
    strcat(dest, "]", size);
    return 1;
}

stock CEF_TradeSendOffer(receiver, owner, const event[])
{
    static json[1800];
    CEF_TradeBuildOfferJson(owner, json, sizeof json);
    return CEF_Send(receiver, event, json);
}

stock CEF_TradeSendInventory(playerid)
{
    static blankJson[11000], visibleJson[7000], part[120];
    new first = 1, itemType, spaType, amount, sourceSlot, sourceIndex;

    CEF_InvSync(playerid);
    for(new tradeSlot = 0; tradeSlot < CEF_TRADE_MAIN_SLOTS; tradeSlot++)
        gCefTradeInventorySourceSlot[playerid][tradeSlot] = -1;

    blankJson[0] = EOS;
    strcat(blankJson, "[", sizeof blankJson);
    for(new tradeSlot = 0; tradeSlot < CEF_TRADE_MAIN_SLOTS; tradeSlot++)
    {
        format(part, sizeof part,
            "%s{\"slotId\":%d,\"type\":0,\"value\":0,\"string\":\"\",\"extraValue\":0,\"enchant\":0}",
            first ? "" : ",", tradeSlot);
        if(strlen(blankJson) + strlen(part) + 2 >= sizeof blankJson) break;
        strcat(blankJson, part, sizeof blankJson);
        first = 0;
    }
    strcat(blankJson, "]", sizeof blankJson);
    CEF_Send(playerid, "cef_trade_update_my_inventory", blankJson);

    visibleJson[0] = EOS;
    strcat(visibleJson, "[", sizeof visibleJson);
    first = 1;
    for(new tradeSlot = 6; tradeSlot < CEF_TRADE_MAX_SLOTS && tradeSlot < 64; tradeSlot++)
    {
        sourceSlot = tradeSlot;
        sourceIndex = gCefInvIdx[playerid][sourceSlot];
        gCefTradeInventorySourceSlot[playerid][tradeSlot] = sourceIndex;
        if(sourceIndex < 0 || sourceIndex >= MAX_ITEMS) continue;
        if(CEF_TradeOfferHasSource(playerid, sourceSlot)) continue;
        itemType = IT[playerid][gCefInvIdx[playerid][sourceSlot]][iType];
        amount = IT[playerid][gCefInvIdx[playerid][sourceSlot]][iAmount];
        spaType = CEF_ItemToSpa(itemType);
        if(spaType <= 0 || amount <= 0) continue;
        format(part, sizeof part,
            "%s{\"slotId\":%d,\"type\":%d,\"value\":%d,\"string\":\"\",\"extraValue\":0,\"enchant\":0}",
            first ? "" : ",", tradeSlot, spaType, amount);
        if(strlen(visibleJson) + strlen(part) + 2 >= sizeof visibleJson) break;
        strcat(visibleJson, part, sizeof visibleJson);
        first = 0;
    }
    strcat(visibleJson, "]", sizeof visibleJson);
    return CEF_Send(playerid, "cef_trade_update_my_inventory", visibleJson);
}

stock CEF_TradeSendState(playerid)
{
    new partner = gCefTradePartner[playerid];
    if(partner < 0 || partner >= MAX_PLAYERS) return 0;
    static json[320], nick[MAX_PLAYER_NAME + 8];
    CEF_JsonNick(partner, nick);
    format(json, sizeof json,
        "{\"maxSlots\":%d,\"playerName\":\"%s\",\"myMoney\":%d,\"playerMoney\":%d,\"imReady\":%s,\"playerReady\":%s}",
        CEF_TRADE_MAX_SLOTS, nick, gCefTradeCashOffer[playerid], gCefTradeCashOffer[partner],
        gCefTradeReady[playerid] ? "true" : "false",
        gCefTradeReady[partner] ? "true" : "false");
    CEF_MarkPlayerReady(playerid);
    CEF_Send(playerid, "cef_trade_show", json);
    CEF_Focus(playerid, true);
    return 1;
}

stock CEF_TradeSyncOne(playerid)
{
    new partner = gCefTradePartner[playerid];
    if(partner < 0 || partner >= MAX_PLAYERS) return 0;
    CEF_TradeSendState(playerid);
    CEF_TradeSendInventory(playerid);
    CEF_TradeSendOffer(playerid, playerid, "cef_trade_update_my_offer");
    CEF_TradeSendOffer(playerid, partner, "cef_trade_update_player_offer");
    return 1;
}

stock CEF_TradeRefreshPair(playerid)
{
    if(!CEF_TradePairValid(playerid)) return 0;
    new partner = gCefTradePartner[playerid];
    CEF_TradeSyncOne(playerid);
    CEF_TradeSyncOne(partner);
    return 1;
}

stock CEF_TradeInvalidateReady(playerid)
{
    new partner = gCefTradePartner[playerid];
    if(gCefTradeReady[playerid])
        CEFC_Notify(playerid, "Your confirmation was withdrawn because the offer changed.", "hint");
    if(partner >= 0 && partner < MAX_PLAYERS && gCefTradeReady[partner])
        CEFC_Notify(partner, "The offer changed; please confirm again.", "hint");
    gCefTradeReady[playerid] = 0;
    if(partner >= 0 && partner < MAX_PLAYERS)
        gCefTradeReady[partner] = 0;
    return 1;
}

stock CEF_TradeRequireReview(playerid, partner, const reason[])
{
    gCefTradeReady[playerid] = 0;
    if(partner >= 0 && partner < MAX_PLAYERS) gCefTradeReady[partner] = 0;
    CEFC_Notify(playerid, reason, "error");
    if(partner >= 0 && partner < MAX_PLAYERS)
        CEFC_Notify(partner, "Trade offer changed; review it and confirm again.", "hint");
    CEF_TradeRefreshPair(playerid);
    return 0;
}

stock CEF_TradeClosePair(playerid, bool:notify = true)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS) return 0;
    new partner = gCefTradePartner[playerid];
    gCefTradePartner[playerid] = CEF_TRADE_INVALID_PLAYER;
    CEF_TradeResetState(playerid);
    if(IsPlayerConnected(playerid))
    {
        CEF_SendEmpty(playerid, "cef_trade_hide");
        CEF_Focus(playerid, false);
    }
    if(partner >= 0 && partner < MAX_PLAYERS && gCefTradePartner[partner] == playerid)
    {
        gCefTradePartner[partner] = CEF_TRADE_INVALID_PLAYER;
        CEF_TradeResetState(partner);
        if(IsPlayerConnected(partner))
        {
            CEF_SendEmpty(partner, "cef_trade_hide");
            CEF_Focus(partner, false);
            if(notify) CEFC_Notify(partner, "The player trade was closed.", "hint");
        }
    }
    if(notify && IsPlayerConnected(playerid))
        CEFC_Notify(playerid, "The player trade was closed.", "hint");
    return 1;
}

stock CEF_TradeOpenPair(playerid, partner)
{
    if(!CEF_TradePairAllowed(playerid, partner))
        return CEFC_Notify(playerid, "A logged-in player must be nearby in the same world and interior.", "hint");
    if(gCefTradePartner[playerid] >= 0 && gCefTradePartner[playerid] != partner)
        return CEFC_Notify(playerid, "You are already trading with someone.", "hint");
    if(gCefTradePartner[partner] >= 0 && gCefTradePartner[partner] != playerid)
        return CEFC_Notify(playerid, "That player is already trading with someone.", "hint");

    CEF_TradeResetState(playerid);
    CEF_TradeResetState(partner);
    gCefTradePartner[playerid] = partner;
    gCefTradePartner[partner] = playerid;
    CEF_TradeRefreshPair(playerid);
    return 1;
}

stock CEF_TradeOpenNearest(playerid)
{
    if(!IsPlayerConnected(playerid) || !PT[playerid][pLogged]) return 0;
    new Float:x, Float:y, Float:z, Float:distance, closest = -1;
    GetPlayerPos(playerid, x, y, z);
    for(new target = 0; target < MAX_PLAYERS; target++)
    {
        if(target == playerid || !IsPlayerConnected(target) || !PT[target][pLogged]) continue;
        if(GetPlayerVirtualWorld(target) != GetPlayerVirtualWorld(playerid)) continue;
        if(GetPlayerInterior(target) != GetPlayerInterior(playerid)) continue;
        distance = GetPlayerDistanceFromPoint(target, x, y, z);
        if(distance <= 5.0 && (closest < 0 || distance < GetPlayerDistanceFromPoint(closest, x, y, z)))
            closest = target;
    }
    if(closest < 0) return CEFC_Notify(playerid, "No logged-in player is close enough to trade.", "hint");
    return CEF_TradeOpenPair(playerid, closest);
}

stock CEF_TradeSetItem(playerid, fromSlot, offerSlot)
{
    if(offerSlot < 0 || offerSlot >= CEF_TRADE_OFFER_SLOTS || fromSlot < 0 || fromSlot >= 64)
        return CEFC_Notify(playerid, "That trade slot is invalid.", "hint");
    new sourceIndex = gCefTradeInventorySourceSlot[playerid][fromSlot];
    if(sourceIndex < 0 || sourceIndex >= MAX_ITEMS || sourceIndex != gCefInvIdx[playerid][fromSlot])
        return CEFC_Notify(playerid, "That inventory item is no longer available.", "hint");
    if(CEF_TradeOfferHasSource(playerid, fromSlot))
        return CEFC_Notify(playerid, "That item is already in your offer.", "hint");

    new itemType = IT[playerid][gCefInvIdx[playerid][fromSlot]][iType];
    new amount = IT[playerid][gCefInvIdx[playerid][fromSlot]][iAmount];
    if(itemType <= 0 || amount <= 0 || CEF_ItemToSpa(itemType) <= 0)
        return CEFC_Notify(playerid, "This item cannot be traded.", "hint");

    gCefTradeItemType[playerid][offerSlot] = itemType;
    gCefTradeItemAmount[playerid][offerSlot] = amount;
    gCefTradeSourceSlot[playerid][offerSlot] = fromSlot;
    CEF_TradeInvalidateReady(playerid);
    return 1;
}

stock CEF_TradeMoveItem(playerid, fromSlot, fromArea, toSlot, toArea)
{
    if(!CEF_TradePairValid(playerid)) return CEF_TradeClosePair(playerid, true);
    if(fromArea == CEF_TRADE_AREA_MAIN && toArea == CEF_TRADE_AREA_OFFER)
    {
        if(fromSlot < 0 || fromSlot >= CEF_TRADE_MAIN_SLOTS || toSlot < 0 || toSlot >= CEF_TRADE_OFFER_SLOTS) return 0;
        if(!CEF_TradeSetItem(playerid, fromSlot, toSlot)) return 0;
        return CEF_TradeRefreshPair(playerid);
    }
    if(fromArea == CEF_TRADE_AREA_OFFER && toArea == CEF_TRADE_AREA_MAIN)
    {
        if(fromSlot < 0 || fromSlot >= CEF_TRADE_OFFER_SLOTS) return 0;
        gCefTradeItemType[playerid][fromSlot] = 0;
        gCefTradeItemAmount[playerid][fromSlot] = 0;
        gCefTradeSourceSlot[playerid][fromSlot] = -1;
        CEF_TradeInvalidateReady(playerid);
        return CEF_TradeRefreshPair(playerid);
    }
    if(fromArea == CEF_TRADE_AREA_OFFER && toArea == CEF_TRADE_AREA_OFFER)
    {
        if(fromSlot < 0 || fromSlot >= CEF_TRADE_OFFER_SLOTS || toSlot < 0 || toSlot >= CEF_TRADE_OFFER_SLOTS) return 0;
        new tempType = gCefTradeItemType[playerid][fromSlot];
        new tempAmount = gCefTradeItemAmount[playerid][fromSlot];
        new tempSource = gCefTradeSourceSlot[playerid][fromSlot];
        gCefTradeItemType[playerid][fromSlot] = gCefTradeItemType[playerid][toSlot];
        gCefTradeItemAmount[playerid][fromSlot] = gCefTradeItemAmount[playerid][toSlot];
        gCefTradeSourceSlot[playerid][fromSlot] = gCefTradeSourceSlot[playerid][toSlot];
        gCefTradeItemType[playerid][toSlot] = tempType;
        gCefTradeItemAmount[playerid][toSlot] = tempAmount;
        gCefTradeSourceSlot[playerid][toSlot] = tempSource;
        CEF_TradeInvalidateReady(playerid);
        return CEF_TradeRefreshPair(playerid);
    }
    return CEFC_Notify(playerid, "Only inventory and offer slots can be traded.", "hint");
}

stock CEF_TradeParseMoney(const text[], &amount)
{
    amount = 0;
    if(!strlen(text)) return 0;
    for(new i = 0; text[i] != EOS; i++)
    {
        if(text[i] < '0' || text[i] > '9') return 0;
        new digit = text[i] - '0';
        if(amount > (CEF_TRADE_MAX_BALANCE - digit) / 10) return 0;
        amount = amount * 10 + digit;
    }
    return 1;
}

stock CEF_TradeMoneyDialog(playerid, dialogid, response, listitem, const inputtext[])
{
    #pragma unused listitem
    if(dialogid != DIALOG_CEF_TRADE_MONEY) return 0;
    PT[playerid][pDialogID] = 0;
    if(!CEF_TradePairValid(playerid)) return CEF_TradeClosePair(playerid, true);
    CEF_Focus(playerid, true);
    if(!response) return 1;
    new amount;
    if(!CEF_TradeParseMoney(inputtext, amount))
        return CEFC_Notify(playerid, "Enter digits only; enter 0 to clear your cash offer.", "error");
    if(amount > PI[playerid][pCash])
        return CEFC_Notify(playerid, "You do not have that much cash.", "error");
    gCefTradeCashOffer[playerid] = amount;
    CEF_TradeInvalidateReady(playerid);
    CEF_Focus(playerid, true);
    return CEF_TradeRefreshPair(playerid);
}

stock CEF_TradeSnapshot(playerid, oldType[], oldAmount[], oldId[])
{
    for(new slot = 0; slot < MAX_ITEMS; slot++)
    {
        oldType[slot] = IT[playerid][slot][iType];
        oldAmount[slot] = IT[playerid][slot][iAmount];
        oldId[slot] = IT[playerid][slot][iID];
    }
    return PI[playerid][pInventorySlotsUsed];
}

stock CEF_TradeRestore(playerid, oldType[], oldAmount[], oldId[], oldUsed)
{
    for(new slot = 0; slot < MAX_ITEMS; slot++)
    {
        IT[playerid][slot][iType] = oldType[slot];
        IT[playerid][slot][iAmount] = oldAmount[slot];
        IT[playerid][slot][iID] = oldId[slot];
    }
    PI[playerid][pInventorySlotsUsed] = oldUsed;
    return 1;
}

stock CEF_TradeCommit(playerid, partner)
{
    if(partner < 0 || !gCefTradeReady[playerid] || !gCefTradeReady[partner]) return 0;
    if(!CEF_TradePairValid(playerid)) return CEF_TradeClosePair(playerid, true);

    CEF_TradeSendInventory(playerid);
    CEF_TradeSendInventory(partner);

    for(new i = 0; i < CEF_TRADE_OFFER_SLOTS; i++)
    {
        if(gCefTradeItemType[playerid][i] <= 0) continue;
        new sourceSlot = gCefTradeSourceSlot[playerid][i];
        if(sourceSlot < 0 || sourceSlot >= 64 || gCefInvIdx[playerid][sourceSlot] < 0 ||
            gCefInvIdx[playerid][sourceSlot] >= MAX_ITEMS ||
            gCefTradeInventorySourceSlot[playerid][sourceSlot] != gCefInvIdx[playerid][sourceSlot])
            return CEF_TradeRequireReview(playerid, partner, "An offered item changed; review the offer and confirm again.");
        if(IT[playerid][gCefInvIdx[playerid][sourceSlot]][iType] != gCefTradeItemType[playerid][i] ||
            IT[playerid][gCefInvIdx[playerid][sourceSlot]][iAmount] != gCefTradeItemAmount[playerid][i])
            return CEF_TradeRequireReview(playerid, partner, "An offered item changed; review the offer and confirm again.");
    }
    for(new i = 0; i < CEF_TRADE_OFFER_SLOTS; i++)
    {
        if(gCefTradeItemType[partner][i] <= 0) continue;
        new sourceSlot = gCefTradeSourceSlot[partner][i];
        if(sourceSlot < 0 || sourceSlot >= 64 || gCefInvIdx[partner][sourceSlot] < 0 ||
            gCefInvIdx[partner][sourceSlot] >= MAX_ITEMS ||
            gCefTradeInventorySourceSlot[partner][sourceSlot] != gCefInvIdx[partner][sourceSlot])
            return CEF_TradeRequireReview(playerid, partner, "An offered item changed; review the offer and confirm again.");
        if(IT[partner][gCefInvIdx[partner][sourceSlot]][iType] != gCefTradeItemType[partner][i] ||
            IT[partner][gCefInvIdx[partner][sourceSlot]][iAmount] != gCefTradeItemAmount[partner][i])
            return CEF_TradeRequireReview(playerid, partner, "An offered item changed; review the offer and confirm again.");
    }

    new incomingAType[CEF_TRADE_OFFER_SLOTS], incomingAAmount[CEF_TRADE_OFFER_SLOTS], incomingACount = 0;
    new incomingBType[CEF_TRADE_OFFER_SLOTS], incomingBAmount[CEF_TRADE_OFFER_SLOTS], incomingBCount = 0;
    for(new i = 0; i < CEF_TRADE_OFFER_SLOTS; i++)
    {
        if(gCefTradeItemType[partner][i] > 0)
        {
            incomingAType[incomingACount] = gCefTradeItemType[partner][i];
            incomingAAmount[incomingACount++] = gCefTradeItemAmount[partner][i];
        }
        if(gCefTradeItemType[playerid][i] > 0)
        {
            incomingBType[incomingBCount] = gCefTradeItemType[playerid][i];
            incomingBAmount[incomingBCount++] = gCefTradeItemAmount[playerid][i];
        }
    }

    new giveA = gCefTradeCashOffer[playerid];
    new giveB = gCefTradeCashOffer[partner];
    new cashA = PI[playerid][pCash];
    new cashB = PI[partner][pCash];
    if(giveA < 0 || giveB < 0 || giveA > cashA || giveB > cashB)
        return CEF_TradeRequireReview(playerid, partner, "A cash offer is no longer affordable.");
    new afterA = cashA - giveA;
    new afterB = cashB - giveB;
    if(giveB > CEF_TRADE_MAX_BALANCE - afterA || giveA > CEF_TRADE_MAX_BALANCE - afterB)
        return CEF_TradeRequireReview(playerid, partner, "The resulting cash balance would exceed the limit.");
    afterA += giveB;
    afterB += giveA;

    new oldTypeA[MAX_ITEMS], oldAmountA[MAX_ITEMS], oldIdA[MAX_ITEMS];
    new oldTypeB[MAX_ITEMS], oldAmountB[MAX_ITEMS], oldIdB[MAX_ITEMS];
    new oldUsedA = CEF_TradeSnapshot(playerid, oldTypeA, oldAmountA, oldIdA);
    new oldUsedB = CEF_TradeSnapshot(partner, oldTypeB, oldAmountB, oldIdB);

    for(new i = 0; i < CEF_TRADE_OFFER_SLOTS; i++)
    {
        if(gCefTradeItemType[playerid][i] <= 0) continue;
        if(!RemoveItem(playerid, gCefTradeItemType[playerid][i], gCefTradeItemAmount[playerid][i]))
        {
            CEF_TradeRestore(playerid, oldTypeA, oldAmountA, oldIdA, oldUsedA);
            CEF_TradeRestore(partner, oldTypeB, oldAmountB, oldIdB, oldUsedB);
            return CEF_TradeRequireReview(playerid, partner, "A trade item could not be removed; review the offer.");
        }
    }
    for(new i = 0; i < CEF_TRADE_OFFER_SLOTS; i++)
    {
        if(gCefTradeItemType[partner][i] <= 0) continue;
        if(!RemoveItem(partner, gCefTradeItemType[partner][i], gCefTradeItemAmount[partner][i]))
        {
            CEF_TradeRestore(playerid, oldTypeA, oldAmountA, oldIdA, oldUsedA);
            CEF_TradeRestore(partner, oldTypeB, oldAmountB, oldIdB, oldUsedB);
            return CEF_TradeRequireReview(playerid, partner, "A trade item could not be removed; review the offer.");
        }
    }

    if(incomingACount > 0 && !CEF_InvCanGiveBatch(playerid, incomingAType, incomingAAmount, incomingACount))
    {
        CEF_TradeRestore(playerid, oldTypeA, oldAmountA, oldIdA, oldUsedA);
        CEF_TradeRestore(partner, oldTypeB, oldAmountB, oldIdB, oldUsedB);
        return CEF_TradeRequireReview(playerid, partner, "There is not enough inventory space for the incoming offer.");
    }
    if(incomingBCount > 0 && !CEF_InvCanGiveBatch(partner, incomingBType, incomingBAmount, incomingBCount))
    {
        CEF_TradeRestore(playerid, oldTypeA, oldAmountA, oldIdA, oldUsedA);
        CEF_TradeRestore(partner, oldTypeB, oldAmountB, oldIdB, oldUsedB);
        return CEF_TradeRequireReview(playerid, partner, "There is not enough inventory space for the incoming offer.");
    }

    for(new i = 0; i < incomingACount; i++)
    {
        if(!GiveItem(playerid, incomingAType[i], incomingAAmount[i]))
        {
            CEF_TradeRestore(playerid, oldTypeA, oldAmountA, oldIdA, oldUsedA);
            CEF_TradeRestore(partner, oldTypeB, oldAmountB, oldIdB, oldUsedB);
            return CEF_TradeRequireReview(playerid, partner, "The exchange was rolled back; review the offer.");
        }
    }
    for(new i = 0; i < incomingBCount; i++)
    {
        if(!GiveItem(partner, incomingBType[i], incomingBAmount[i]))
        {
            CEF_TradeRestore(playerid, oldTypeA, oldAmountA, oldIdA, oldUsedA);
            CEF_TradeRestore(partner, oldTypeB, oldAmountB, oldIdB, oldUsedB);
            return CEF_TradeRequireReview(playerid, partner, "The exchange was rolled back; review the offer.");
        }
    }

    PI[playerid][pCash] = afterA;
    PI[partner][pCash] = afterB;
    ResetPlayerMoney(playerid);
    ResetPlayerMoney(partner);
    if(afterA > 0) GivePlayerMoney(playerid, afterA);
    if(afterB > 0) GivePlayerMoney(partner, afterB);
    SavePlayerInventory(playerid);
    SavePlayerInventory(partner);
    CEF_EcoSaveMoney(playerid);
    CEF_EcoSaveMoney(partner);
    CEF_InvSync(playerid);
    CEF_InvSync(partner);
    CEFC_Notify(playerid, "The trade completed successfully.", "success");
    CEFC_Notify(partner, "The trade completed successfully.", "success");
    CEF_TradeClosePair(playerid, false);
    return 1;
}

stock CEF_TradeHandleResponse(playerid, const arguments[])
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) || !PT[playerid][pLogged]) return 0;
    new actionId = CEF_EcoFindInt(arguments, "actionId");
    new partner = gCefTradePartner[playerid];
    if(actionId == CEF_TRADE_ACTION_REFUSE) return CEF_TradeClosePair(playerid, true);
    if(!CEF_TradePairValid(playerid)) return CEF_TradeClosePair(playerid, true);

    switch(actionId)
    {
        case CEF_TRADE_ACTION_ACCEPT:
        {
            if(gCefTradeReady[playerid])
            {
                gCefTradeReady[playerid] = 0;
                if(partner >= 0 && partner < MAX_PLAYERS) gCefTradeReady[partner] = 0;
                CEFC_Notify(playerid, "Your confirmation was withdrawn.", "hint");
                return CEF_TradeRefreshPair(playerid);
            }
            gCefTradeReady[playerid] = 1;
            CEF_TradeRefreshPair(playerid);
            if(partner < 0 || !gCefTradeReady[playerid] || !gCefTradeReady[partner]) return 1;
            return CEF_TradeCommit(playerid, partner);
        }
        case CEF_TRADE_ACTION_ADD_MONEY:
        {
            CEF_Focus(playerid, false);
            PT[playerid][pDialogID] = DIALOG_CEF_TRADE_MONEY;
            ShowPlayerDialog(playerid, DIALOG_CEF_TRADE_MONEY, DIALOG_STYLE_INPUT,
                "Player trade", "Enter the cash amount to offer (0 clears it):", "Set", "Cancel");
            return 1;
        }
        case CEF_TRADE_ACTION_MOVE_ITEM:
        {
            new fromSlot = CEF_EcoFindInt(arguments, "fromSlotId");
            new fromArea = CEF_EcoFindInt(arguments, "fromArea");
            new toSlot = CEF_EcoFindInt(arguments, "toSlotId");
            new toArea = CEF_EcoFindInt(arguments, "toArea");
            return CEF_TradeMoveItem(playerid, fromSlot, fromArea, toSlot, toArea);
        }
        case CEF_TRADE_ACTION_INFO:
            return CEF_TradeRefreshPair(playerid);
    }
    return 1;
}

stock CEF_TradeOnDisconnect(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS) return 0;
    if(gCefTradePartner[playerid] >= 0) CEF_TradeClosePair(playerid, true);
    CEF_TradeOnConnect(playerid);
    return 1;
}

CMD:trade(playerid, params[])
{
    #pragma unused params
    return CEF_TradeOpenNearest(playerid);
}

CMD:obmen(playerid, params[])
{
    #pragma unused params
    return CEF_TradeOpenNearest(playerid);
}
