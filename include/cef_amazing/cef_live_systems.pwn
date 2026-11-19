#if defined _cef_live_included
    #endinput
#endif
#define _cef_live_included

forward CEF_EcoInit();
forward WCreate_Init();
forward CEF_CasesInit();
forward CEF_CurrencyInit();
forward CEF_ProgressInit();
forward CEF_NeedsInit();
forward CEF_DonateShopInit();
forward CEF_CasinoInit();
forward CEF_CasinoOpen(playerid);
forward CEF_StorageInit();
forward CEF_OpsQuickSlotInit();
forward CEF_SpaOwnLoad(playerid);
forward CEF_EcoShopOpen(playerid);
forward CEF_EcoGasOpen(playerid);
forward CEF_EcoJobOpen(playerid);
forward CEF_EcoShopResponse(playerid, const arguments[]);
forward CEF_EcoGasResponse(playerid, const arguments[]);
forward CEF_EcoJobResponse(playerid, const arguments[]);

new gCefFineN[MAX_PLAYERS];
new gCefFineSum[MAX_PLAYERS];
new gCefMilitary[MAX_PLAYERS];

#define CEF_LIVE_MAX 256
#define CEF_MK_BANK     1
#define CEF_MK_ATM      2
#define CEF_MK_SHOP     3
#define CEF_MK_GAS      4
#define CEF_MK_SERVICE  5
#define CEF_MK_JOB      6
#define CEF_MK_CASINO   7

enum E_CEF_MARK {
    mkType,
    Float:mkX,
    Float:mkY,
    Float:mkZ,
    mkVw,
    mkPickup,
    mkArea,
    Text3D:mkLabel,
    mkDbId
}
new gCefMark[CEF_LIVE_MAX][E_CEF_MARK];
new gCefMarkCount;
new gCefMarkAt[MAX_PLAYERS];
new gCefMarkUseTick[MAX_PLAYERS];

stock CEF_LiveReady(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;
    CEF_MarkPlayerReady(playerid);
    return 1;
}

stock CEF_LiveInventory(playerid)
{
    if(!CEF_LiveReady(playerid)) return 0;
    return CallLocalFunction("ShowPlayerInventory", "i", playerid);
}

stock CEF_LiveInvClose(playerid)
{
    CEF_SendEmpty(playerid, "menu_close");
    CEF_Hide(playerid);
    return 1;
}

stock CEF_LiveInvResponse(playerid, const arguments[])
{
    return CEF_OpsInvResponse(playerid, arguments);
}

stock CEF_LiveDocOpen(playerid, const json[])
{
    CEF_LiveReady(playerid);
    cef_emit_event(playerid, "cef_documents_open", CEFSTR(json));
    CEF_Show(playerid, true);
    return 1;
}

stock CEF_LivePassport(viewer, owner)
{
    if(!IsPlayerConnected(viewer) || !IsPlayerConnected(owner)) return 0;
    new nick[MAX_PLAYER_NAME], birth[24], json[CEF_JSON_SIZE], data[1024];
    CEF_JsonEscape(PI[owner][pName], nick);
    if(strlen(PI[owner][pBirthDate])) format(birth, sizeof birth, "%s", PI[owner][pBirthDate]);
    else format(birth, sizeof birth, "2000-01-01");
    format(data, sizeof data,
        "{\"nickname\":\"%s\",\"regDate\":\"2024-01-01 12:00:00\",\"gender\":%d,\"birthDate\":\"%s\",\"birthPlace\":\"-\",\"documentId\":%d,\"skinId\":%d,\"level\":%d,\"militaryId\":1,\"legalityLevel\":%d,\"married\":\"None\",\"residencePlace\":\"-\"}",
        nick, PI[owner][pSex] ? 0 : 1, birth, PI[owner][pID], GetPlayerSkin(owner), PI[owner][pLevel], PI[owner][pLegality]);
    format(json, sizeof json, "{\"type\":1,\"data\":%s}", data);
    return CEF_LiveDocOpen(viewer, json);
}

stock CEF_LiveLicenses(viewer, owner)
{
    if(!IsPlayerConnected(viewer) || !IsPlayerConnected(owner)) return 0;
    new list[512], part[96], first = 1;
    list[0] = '['; list[1] = EOS;
    if(PI[owner][pLicenseA]) { format(part, sizeof part, "%s{\"type\":1,\"validUntil\":\"01.01.2034\"}", first ? ("") : (",")); strcat(list, part); first = 0; }
    if(PI[owner][pLicenseB]) { format(part, sizeof part, "%s{\"type\":2,\"validUntil\":\"01.01.2034\"}", first ? ("") : (",")); strcat(list, part); first = 0; }
    if(PI[owner][pLicenseC]) { format(part, sizeof part, "%s{\"type\":3,\"validUntil\":\"01.01.2034\"}", first ? ("") : (",")); strcat(list, part); first = 0; }
    if(PI[owner][pLicenseWeapon]) { format(part, sizeof part, "%s{\"type\":4,\"validUntil\":\"01.01.2034\"}", first ? ("") : (",")); strcat(list, part); first = 0; }
    if(PI[owner][pLicenseFlight]) { format(part, sizeof part, "%s{\"type\":5,\"validUntil\":\"01.01.2034\"}", first ? ("") : (",")); strcat(list, part); first = 0; }
    if(PI[owner][pLicenseBusiness]) { format(part, sizeof part, "%s{\"type\":6,\"validUntil\":\"01.01.2034\"}", first ? ("") : (",")); strcat(list, part); first = 0; }
    strcat(list, "]");
    new nick[MAX_PLAYER_NAME], data[1024], json[CEF_JSON_SIZE];
    CEF_JsonEscape(PI[owner][pName], nick);
    format(data, sizeof data, "{\"nickname\":\"%s\",\"licenses\":%s}", nick, list);
    format(json, sizeof json, "{\"type\":5,\"data\":%s}", data);
    return CEF_LiveDocOpen(viewer, json);
}

stock CEF_LiveUdo(viewer, owner)
{

    if(!IsPlayerConnected(viewer) || !IsPlayerConnected(owner)) return 0;
    new frac = PI[owner][pFraction];
    new dtype;
    if(frac == FRACTION_FSB) dtype = 6;
    else if(frac == FRACTION_TRAFFIC_PATROL_POLICE || frac == FRACTION_PATROL_POLICE) dtype = 7;
    else if(frac == FRACTION_MILITARY) dtype = 9;
    else return 0;
    new nick[MAX_PLAYER_NAME], json[CEF_JSON_SIZE], data[900], rank[48], dep[64];
    CEF_JsonEscape(PI[owner][pName], nick);
    if(frac > 0 && PI[owner][pFractionRank] > 0)
        format(rank, sizeof rank, "%s", Fraction_Rank[frac][PI[owner][pFractionRank] - 1]);
    else format(rank, sizeof rank, "-");
    format(dep, sizeof dep, "%s", Fraction[frac][fName]);
    format(data, sizeof data,
        "{\"nickname\":\"%s\",\"fractionId\":%d,\"rankId\":%d,\"positionName\":\"%s\",\"departmentName\":\"%s\",\"documentId\":%d,\"personalId\":%d,\"issuedDate\":%d,\"directorSignature\":\"-\",\"skinId\":%d}",
        nick, frac, PI[owner][pFractionRank], rank, dep,
        100000 + PI[owner][pID], PI[owner][pID], gettime(), GetPlayerSkin(owner));
    format(json, sizeof json, "{\"type\":%d,\"data\":%s}", dtype, data);
    return CEF_LiveDocOpen(viewer, json);
}

stock CEF_LiveCarpass(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;
    new vehicleid = PI[playerid][pCar];
    if(!IsValidVehicle(vehicleid)) return 0;
    new plate[32], nick[MAX_PLAYER_NAME], json[CEF_JSON_SIZE], data[1024];
    new Float:hp;
    GetVehicleHealth(vehicleid, hp);
    GetVehicleNumberPlate(vehicleid, plate, sizeof plate);
    CEF_JsonEscape(PI[playerid][pName], nick);
    format(data, sizeof data,
        "{\"documentId\":%d,\"owner\":\"%s\",\"modelName\":\"%d\",\"maxSpeed\":0,\"health\":%d,\"price\":0,\"ownersCount\":1,\"plate\":\"%s\",\"fuelType\":1,\"fuelTank\":50,\"vehicleId\":%d,\"modelId\":%d}",
        PI[playerid][pID], nick, GetVehicleModel(vehicleid), floatround(hp), plate, vehicleid, GetVehicleModel(vehicleid));
    format(json, sizeof json, "{\"type\":2,\"data\":%s}", data);
    return CEF_LiveDocOpen(playerid, json);
}

stock CEF_LiveBank(playerid)
{
    CEF_LiveReady(playerid);
    return CEF_OpsBankOpen(playerid, false);
}

stock CEF_LiveAtm(playerid)
{
    CEF_LiveReady(playerid);
    return CEF_OpsAtmOpen(playerid);
}

stock CEF_LiveShop(playerid)
{
    CEF_LiveReady(playerid);
    return CEF_EcoShopOpen(playerid);
}

stock CEF_LiveGas(playerid)
{
    CEF_LiveReady(playerid);
    return CEF_EcoGasOpen(playerid);
}

stock CEF_LiveService(playerid)
{
    CEF_LiveReady(playerid);
    return CEF_OpsServiceOpen(playerid);
}

stock CEF_LiveJobCraft(playerid)
{
    CEF_LiveReady(playerid);
    return CEF_EcoJobOpen(playerid);
}

stock CEF_LiveRadialClick(playerid, const arguments[])
{
    new key[48];
    CEF_Arg(arguments, 0, key);
    if(!strlen(key)) CEF_JsonStr(arguments, "key", key, sizeof key);
    if(!strlen(key)) CEF_JsonStr(arguments, "selectedIndex", key, sizeof key);
    if(strfind(key, "inv", true) != -1) return CEF_LiveInventory(playerid);
    if(strfind(key, "doc", true) != -1 || strfind(key, "pass", true) != -1) return CEF_LivePassport(playerid, playerid);
    if(strfind(key, "lic", true) != -1) return CEF_LiveLicenses(playerid, playerid);
    if(strfind(key, "udo", true) != -1)
    {
        if(!CEF_LiveUdo(playerid, playerid)) SendErr(playerid, "N/A");
        return 1;
    }
    if(strfind(key, "anim", true) != -1 || strfind(key, "emote", true) != -1)
        return CallLocalFunction("CEF_AllAnimsOpen", "i", playerid);
    if(strfind(key, "ads", true) != -1)
        return CallLocalFunction("CEF_AllAdsOpen", "i", playerid);
    if(strfind(key, "sup", true) != -1 || strfind(key, "rep", true) != -1)
        return CallLocalFunction("CEF_AllSupportOpen", "i", playerid);
    if(strfind(key, "map", true) != -1)
        return CallLocalFunction("CEF_AllMapToggle", "i", playerid);
    if(strfind(key, "job", true) != -1)
        return CallLocalFunction("CEF_EcoJobOpen", "i", playerid);
    if(strfind(key, "bank", true) != -1) return CEF_LiveBank(playerid);
    if(strfind(key, "chat", true) != -1)
    {
        CallLocalFunction("CEF_AllChatInput", "i", playerid);
        return 1;
    }
    return 1;
}

stock CEF_LiveUseMark(playerid, type)
{
    CEF_LiveHintHide(playerid);
    switch(type)
    {
        case CEF_MK_BANK: return CEF_LiveBank(playerid);
        case CEF_MK_ATM: return CEF_LiveAtm(playerid);
        case CEF_MK_SHOP: return CEF_LiveShop(playerid);
        case CEF_MK_GAS: return CEF_LiveGas(playerid);
        case CEF_MK_SERVICE: return CEF_LiveService(playerid);
        case CEF_MK_JOB: return CEF_LiveJobCraft(playerid);
        case CEF_MK_CASINO: return CEF_CasinoOpen(playerid);
    }
    return 0;
}

stock CEF_LiveAddMark(type, Float:x, Float:y, Float:z, vw, const caption[])
{
    if(gCefMarkCount >= CEF_LIVE_MAX) return 0;
    new i = gCefMarkCount++;
    gCefMark[i][mkType] = type;
    gCefMark[i][mkX] = x;
    gCefMark[i][mkY] = y;
    gCefMark[i][mkZ] = z;
    gCefMark[i][mkVw] = vw;
    gCefMark[i][mkPickup] = CreateDynamicPickup(19134, 1, x, y, z, vw, -1, -1, 80.0);
    gCefMark[i][mkArea] = CreateDynamicSphere(x, y, z, 3.5, vw, -1, -1);
    gCefMark[i][mkLabel] = CreateDynamic3DTextLabel(caption, 0x54B367FF, x, y, z + 0.6, 20.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, vw);
    gCefMark[i][mkDbId] = 0;
    return 1;
}

forward CEF_LiveInit();
public CEF_LiveInit()
{
    gCefMarkCount = 0;
    CEF_LiveAddMark(CEF_MK_BANK, 1481.2288, -1771.5322, 18.7958, 0, "BANK / ALT");
    CEF_LiveAddMark(CEF_MK_ATM, 1497.4867, -1749.8743, 15.4453, 0, "ATM / ALT");
    CEF_LiveAddMark(CEF_MK_SHOP, 1315.4520, -898.6210, 39.5781, 0, "SHOP / ALT");
    CEF_LiveAddMark(CEF_MK_SHOP, 1928.6866, -1776.2706, 13.5469, 0, "SHOP / ALT");
    CEF_LiveAddMark(CEF_MK_GAS, 1940.1917, -1772.9000, 13.3906, 0, "GAS / ALT");
    CEF_LiveAddMark(CEF_MK_GAS, 1004.0690, -939.3734, 42.1797, 0, "GAS / ALT");
    CEF_LiveAddMark(CEF_MK_SERVICE, 1041.3420, -1026.1790, 32.1016, 0, "SERVICE / ALT");
    CEF_LiveAddMark(CEF_MK_SERVICE, 2065.2690, -1831.4000, 13.5469, 0, "SERVICE / ALT");
    CEF_LiveAddMark(CEF_MK_JOB, 220.7643, 418.4383, 11.1746, 0, "JOB / ALT");
    CEF_LiveAddMark(CEF_MK_JOB, 851.0702, 2435.1201, 12.0000, 0, "JOB / ALT");
    CEF_LiveAddMark(CEF_MK_CASINO, 2195.8401, 1677.1505, 12.3672, 0, "CALIGULA CASINO");
    printf("[CEF-LIVE] markers %d", gCefMarkCount);
    CEF_EcoInit();
    WCreate_Init();
    DynWorld_Init();
    CEF_CasesInit();
    CEF_CurrencyInit();
    CEF_ProgressInit();
    CEF_NeedsInit();
    CEF_DonateShopInit();
    CEF_CasinoInit();
    CEF_StorageInit();
    CEF_OpsQuickSlotInit();
    return 1;
}


stock CEF_LiveAddMarkEx(type, Float:x, Float:y, Float:z, vw, const caption[], dbid)
{
    if(!CEF_LiveAddMark(type, x, y, z, vw, caption)) return 0;
    gCefMark[gCefMarkCount - 1][mkDbId] = dbid;
    return 1;
}

stock CEF_LiveRemoveAt(idx)
{
    if(idx < 0 || idx >= gCefMarkCount) return 0;
    DestroyDynamicPickup(gCefMark[idx][mkPickup]);
    DestroyDynamicArea(gCefMark[idx][mkArea]);
    DestroyDynamic3DTextLabel(gCefMark[idx][mkLabel]);
    for(new i = idx; i < gCefMarkCount - 1; i++) gCefMark[i] = gCefMark[i + 1];
    gCefMarkCount--;
    return 1;
}

stock CEF_LiveNearest(playerid, Float:maxdist = 4.0)
{
    new Float:x, Float:y, Float:z, Float:d, best = -1;
    new Float:bd = maxdist;
    GetPlayerPos(playerid, x, y, z);
    for(new i = 0; i < gCefMarkCount; i++)
    {
        d = GetPlayerDistanceFromPoint(playerid, gCefMark[i][mkX], gCefMark[i][mkY], gCefMark[i][mkZ]);
        if(d < bd) { bd = d; best = i; }
    }
    return best;
}
stock CEF_LiveHintText(type, dest[], size)
{
    switch(type)
    {
        case CEF_MK_BANK: format(dest, size, " ");
        case CEF_MK_ATM: format(dest, size, "");
        case CEF_MK_SHOP: format(dest, size, " 24/7");
        case CEF_MK_GAS: format(dest, size, "");
        case CEF_MK_SERVICE: format(dest, size, "");
        case CEF_MK_JOB: format(dest, size, "");
        case CEF_MK_CASINO: format(dest, size, "Casino chip exchange");
        default: format(dest, size, "");
    }
    return 1;
}

stock CEF_LiveHintShow(playerid, const text[])
{
    static json[320], esc[256];
    CEF_JsonEscape(text, esc);
    format(json, sizeof json, "{\"text\":\"%s\",\"leading\":\"ALT\"}", esc);
    return CEF_Send(playerid, "cef_action_hint_show", json);
}

stock CEF_LiveHintHide(playerid)
{
    return CEF_SendEmpty(playerid, "cef_action_hint_hide");
}

stock CEF_LiveOnArea(playerid, areaid, bool:enter)
{
    new i, hint[48];
    for(i = 0; i < gCefMarkCount; i++)
    {
        if(gCefMark[i][mkArea] == areaid)
        {
            gCefMarkAt[playerid] = enter ? (i + 1) : 0;
            if(enter)
            {
                CEF_LiveHintText(gCefMark[i][mkType], hint, sizeof hint);
                CEF_LiveHintShow(playerid, hint);
            }
            else CEF_LiveHintHide(playerid);
            return 1;
        }
    }
    return 0;
}

stock CEF_LiveKeys(playerid, newkeys, oldkeys)
{
    new walk = (newkeys & KEY_WALK) && !(oldkeys & KEY_WALK);
    new act  = (newkeys & KEY_ACTION) && !(oldkeys & KEY_ACTION);
    if(!walk && !act) return 0;
    if(gCefMarkAt[playerid] > 0)
    {
        CEF_LiveHintHide(playerid);
        CEF_LiveUseMark(playerid, gCefMark[gCefMarkAt[playerid] - 1][mkType]);
        return 1;
    }
    new near = CEF_LiveNearest(playerid, 3.5);
    if(near >= 0)
    {
        CEF_LiveHintHide(playerid);
        CEF_LiveUseMark(playerid, gCefMark[near][mkType]);
        return 1;
    }
    if(CEF_NeedsNearestToilet(playerid) >= 0)
    {
        CEF_NeedsUseToilet(playerid);
        return 1;
    }
    return 0;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    CEF_LiveKeys(playerid, newkeys, oldkeys);
    #if defined CEFLive_OnPlayerKeyStateChange
        return CEFLive_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerKeyStateChange
    #undef OnPlayerKeyStateChange
#else
    #define _ALS_OnPlayerKeyStateChange
#endif
#define OnPlayerKeyStateChange CEFLive_OnPlayerKeyStateChange
#if defined CEFLive_OnPlayerKeyStateChange
    forward CEFLive_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
#endif

public OnPlayerEnterDynamicArea(playerid, areaid)
{
    CEF_LiveOnArea(playerid, areaid, true);
    #if defined CEFLive_OnPEnterDynArea
        return CEFLive_OnPEnterDynArea(playerid, areaid);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerEnterDynamicArea
    #undef OnPlayerEnterDynamicArea
#else
    #define _ALS_OnPlayerEnterDynamicArea
#endif
#define OnPlayerEnterDynamicArea CEFLive_OnPEnterDynArea
#if defined CEFLive_OnPEnterDynArea
    forward CEFLive_OnPEnterDynArea(playerid, areaid);
#endif

public OnPlayerLeaveDynamicArea(playerid, areaid)
{
    CEF_LiveOnArea(playerid, areaid, false);
    #if defined CEFLive_OnPLeaveDynArea
        return CEFLive_OnPLeaveDynArea(playerid, areaid);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerLeaveDynamicArea
    #undef OnPlayerLeaveDynamicArea
#else
    #define _ALS_OnPlayerLeaveDynamicArea
#endif
#define OnPlayerLeaveDynamicArea CEFLive_OnPLeaveDynArea
#if defined CEFLive_OnPLeaveDynArea
    forward CEFLive_OnPLeaveDynArea(playerid, areaid);
#endif

CMD:cefinv(playerid, params[])
{
    #pragma unused params
    CEF_LiveInventory(playerid);
    return 1;
}

CMD:cefbank(playerid, params[])
{
    #pragma unused params
    CEF_LiveBank(playerid);
    return 1;
}

CMD:cefatm(playerid, params[])
{
    #pragma unused params
    CEF_LiveAtm(playerid);
    return 1;
}

CMD:cefshop(playerid, params[])
{
    #pragma unused params
    CEF_LiveShop(playerid);
    return 1;
}

CMD:cefgas(playerid, params[])
{
    #pragma unused params
    CEF_LiveGas(playerid);
    return 1;
}

CMD:cefsrv(playerid, params[])
{
    #pragma unused params
    CEF_LiveService(playerid);
    return 1;
}
