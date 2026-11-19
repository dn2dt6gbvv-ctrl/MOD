


#define PLAYER_OFFER_TIMEOUT 15000

enum E_PLAYER_OFFER_TYPE
{
    PLAYER_OFFER_NONE = 0,
    PLAYER_OFFER_MONEY,
    PLAYER_OFFER_DOCUMENT,
    PLAYER_OFFER_HOUSE
}

new g_PlayerOfferFrom[MAX_PLAYERS] = {INVALID_PLAYER_ID, ...};
new g_PlayerOfferTarget[MAX_PLAYERS] = {INVALID_PLAYER_ID, ...};
new E_PLAYER_OFFER_TYPE:g_PlayerOfferType[MAX_PLAYERS];
new g_PlayerOfferValue[MAX_PLAYERS];
new g_PlayerOfferToken[MAX_PLAYERS];

forward PlayerOffer_OnConnect(playerid);
forward PlayerOffer_OnDisconnect(playerid);
forward bool:PlayerOffer_OnKey(playerid, newkeys);
forward PlayerOffer_Create(sender, target, E_PLAYER_OFFER_TYPE:type, value, const description[]);
forward Document_HandleOfferResponse(playerid, accepted);
