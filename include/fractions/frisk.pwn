
#if defined _FRISK_INCLUDED
    #endinput
#endif
#define _FRISK_INCLUDED

#define FRISK_FRAC_COUNT 5
new g_FriskFracs[FRISK_FRAC_COUNT] = {
    FRACTION_GOVERMENT,
    FRACTION_FSB,
    FRACTION_TRAFFIC_PATROL_POLICE,
    FRACTION_PATROL_POLICE,
    FRACTION_MILITARY
};


stock CanFrisk(playerid)
{
    if(!PT[playerid][pDuty]) return false;
    new frac = PI[playerid][pFraction];
    for(new i = 0; i < FRISK_FRAC_COUNT; i++)
        if(g_FriskFracs[i] == frac) return true;
    return false;
}


stock GetSlotWeapon(playerid, slot, &weaponid, &ammo)
{


    weaponid = 0; ammo = 0;
    GetPlayerWeaponData(playerid, slot, weaponid, ammo);
}

new g_FriskJSON[MAX_PLAYERS][2048];

stock BuildFriskJSON(targetid, officerId)
{
    new json[2048] = "[";
    new bool:categoryAdded = false;
    new bool:hasWeapon = false;

    for(new slot = 1; slot < 13; slot++)
    {
        if(slot == 10 || slot == 11 || slot == 12) continue;
        new wid, ammo;
        GetPlayerWeaponData(targetid, slot, wid, ammo);
        if(wid <= 0) continue;
        new wname[32];
        GetWeaponName(wid, wname, sizeof(wname));
        if(!categoryAdded) {
            strcat(json, "{\"name\":\"Оружие\",\"isCategory\":true,\"canSeize\":false},");
            categoryAdded = true;
        }
        new entry[128];
        format(entry, sizeof(entry),
            "{\"id\":%d,\"name\":\"%s\",\"quantity\":\"%d пт.\",\"isCategory\":false,\"isWeapon\":true,\"canSeize\":true},",
            wid, wname, ammo);
        strcat(json, entry);
        hasWeapon = true;
    }

    if(!hasWeapon)
        strcat(json, "{\"name\":\"Оружие не обнаружено\",\"isCategory\":true,\"canSeize\":false}");
    else {
        new len = strlen(json);
        if(json[len-1] == ',') json[len-1] = '\0';
    }
    strcat(json, "]");
    format(g_FriskJSON[officerId], 2048, "%s", json);
}

stock OpenFrisk(officerId, targetid)
{
    if(!cef_player_has_plugin(officerId)) return;
    if(!PT[officerId][pCefLoaded]) return;

    g_FriskTarget[officerId] = targetid;
    g_FriskOfficer[targetid] = officerId;

    BuildFriskJSON(targetid, officerId);

    cef_create_browser(officerId, FRISK_BROWSER, FRISK_CEF_LINK, false, true);
    cef_always_listen_keys(officerId, FRISK_BROWSER, true);
    cef_focus_browser(officerId, FRISK_BROWSER, true);
}

forward FriskBrowserReady(officerId, targetid, attempt);
public FriskBrowserReady(officerId, targetid, attempt)
{
    if(!IsPlayerConnected(officerId)) return;
    if(!IsPlayerConnected(g_FriskTarget[officerId])) { CloseFrisk(officerId); return; }
    cef_emit_event(officerId, "frisk:init",
        CEFSTR(PI[g_FriskTarget[officerId]][pName]),
        CEFSTR(g_FriskJSON[officerId]));
}

stock CloseFrisk(officerId)
{
    cef_focus_browser(officerId, FRISK_BROWSER, false);
    cef_destroy_browser(officerId, FRISK_BROWSER);
    new targetid = g_FriskTarget[officerId];
    if(targetid != -1) g_FriskOfficer[targetid] = -1;
    g_FriskTarget[officerId] = -1;
    g_FriskJSON[officerId][0] = '\0';

    ClearAnimations(officerId);
    if(targetid != -1 && IsPlayerConnected(targetid)) ClearAnimations(targetid);
}
stock FriskSeizeWeapon(officerId, weaponId)
{
    new targetid = g_FriskTarget[officerId];
    if(targetid == -1 || !IsPlayerConnected(targetid)) return;

    new wname[32];
    GetWeaponName(weaponId, wname, sizeof(wname));


    new saveWep[13], saveAmmo[13];
    new ammo = 0;
    for(new slot = 0; slot < 13; slot++) {
        GetPlayerWeaponData(targetid, slot, saveWep[slot], saveAmmo[slot]);
        if(saveWep[slot] == weaponId) ammo = saveAmmo[slot];
    }


    ResetPlayerWeapons(targetid);


    for(new slot = 0; slot < 13; slot++) {
        if(saveWep[slot] <= 0) continue;
        if(saveWep[slot] == weaponId) continue;
        GivePlayerWeapon(targetid, saveWep[slot], saveAmmo[slot]);
    }

    new msg[128];
    format(msg, sizeof(msg), "[Досмотр] У %s изъято: %s (%d пт.)", GetName(targetid), wname, ammo);
    CEFChat_Send(officerId, "AAAAAA", msg);
    CEFChat_Send(targetid, "FF4444", "У вас изъято оружие в ходе досмотра.");

    BuildFriskJSON(targetid, officerId);
    cef_emit_event(officerId, "frisk:init", CEFSTR(PI[targetid][pName]), CEFSTR(g_FriskJSON[officerId]));
}

stock FriskSeizeAll(officerId)
{
    new targetid = g_FriskTarget[officerId];
    if(targetid == -1 || !IsPlayerConnected(targetid)) return;

    new count = 0;
    for(new slot = 1; slot < 13; slot++) {
        if(slot == 10 || slot == 11 || slot == 12) continue;
        new wid, ammo;
        GetPlayerWeaponData(targetid, slot, wid, ammo);
        if(wid > 0) count++;
    }

    ResetPlayerWeapons(targetid);

    new msg[128];
    format(msg, sizeof(msg), "[Досмотр] У %s изъято всё оружие (%d ед.).", GetName(targetid), count);
    CEFChat_Send(officerId, "AAAAAA", msg);
    CEFChat_Send(targetid, "FF4444", "У вас изъято всё оружие в ходе досмотра.");

    BuildFriskJSON(targetid, officerId);
    cef_emit_event(officerId, "frisk:init", CEFSTR(PI[targetid][pName]), CEFSTR(g_FriskJSON[officerId]));
}

callback::OnFriskClick(playerid, const arguments[])
{
    new action, itemId;
    sscanf(arguments, "dd", action, itemId);
    switch(action) {
        case 0: CloseFrisk(playerid);
        case 1: FriskSeizeWeapon(playerid, itemId);
        case 2: FriskSeizeAll(playerid);
    }
    return 1;
}

cmd:frisk(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;
    if(!CanFrisk(playerid)) return SendErr(playerid, "У вас нет прав для досмотра.");

    new targetid;
    if(sscanf(params, "u", targetid)) return SendErr(playerid, "Использование: /frisk [ID]");
    if(!IsPlayerConnected(targetid)) return SendErr(playerid, "Игрок не в сети.");

    new Float:tx, Float:ty, Float:tz;
    GetPlayerPos(targetid, tx, ty, tz);
    if(!IsPlayerInRangeOfPoint(playerid, 5.0, tx, ty, tz))
        return SendErr(playerid, "Игрок слишком далеко.");

    OpenFrisk(playerid, targetid);

    ApplyAnimation(targetid, "ped", "handsup", 4.1, 0, 1, 1, 1, 0, 1);
    ApplyAnimation(playerid, "ped", "сrusher", 4.1, 1, 1, 1, 1, 0, 1);

    new msg[96];
    format(msg, sizeof(msg), "%s начал ваш досмотр.", GetName(playerid));
    CEFChat_Send(targetid, "AAAAAA", msg);
    return 1;
}
