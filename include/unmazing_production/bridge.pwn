

#define NAMAZING_SYNC_COLOR (0x01010100)
#define NAMAZING_PERM_PUBLIC (100478)
#define NAMAZING_PERM_ALL (131071)
#define NAMAZING_PAUSE_BROWSER_ID (1505)
#define NAMAZING_PAUSE_BROWSER_URL "file:///cef/namazing/pause/index.html"

stock NamazingProd_SendHidden(playerid, const text[])
{
    if(!IsPlayerConnected(playerid)) return 0;
    return SendClientMessage(playerid, NAMAZING_SYNC_COLOR, text);
}

stock bool:NamazingProd_IsAdmin(playerid)
{
    return PT[playerid][pLogged] && PT[playerid][pAlogged] && PI[playerid][pAdmin] > 0;
}

stock NamazingProd_SendPermissions(playerid)
{
    new packet[48];
    format(packet, sizeof(packet), "@@AMZPERM:%d", NamazingProd_IsAdmin(playerid) ? NAMAZING_PERM_ALL : NAMAZING_PERM_PUBLIC);
    return NamazingProd_SendHidden(playerid, packet);
}

stock NamazingProd_SendTagsToViewer(viewerid, playerid)
{
    if(!IsPlayerConnected(viewerid) || !IsPlayerConnected(playerid)) return 0;

    new packet[64], textureid;

    if(PI[playerid][pAdmin] > 0)
    {
        textureid = PI[playerid][pAdmin] >= 10 ? 12 : PI[playerid][pAdmin];
        if(textureid < 0) textureid = 0;
        if(textureid > 12) textureid = 12;
        format(packet, sizeof(packet), "@@AMZADMINTAG:S:%d:%d", playerid, textureid);
    }
    else format(packet, sizeof(packet), "@@AMZADMINTAG:H:%d", playerid);
    NamazingProd_SendHidden(viewerid, packet);

    format(packet, sizeof(packet), PI[playerid][pVip] > 0 ? ("@@AMZBLACK:S:%d") : ("@@AMZBLACK:H:%d"), playerid);
    NamazingProd_SendHidden(viewerid, packet);
    return 1;
}

stock NamazingProd_SyncTags(playerid)
{
    foreach(new viewerid : Player) NamazingProd_SendTagsToViewer(viewerid, playerid);
    return 1;
}

CMD:namazingready(playerid)
{
    NamazingProd_SendPermissions(playerid);
    SyncMasksForPlayer(playerid);
    SyncAllTagsForPlayer(playerid);
    return 1;
}

forward OnNamazingPauseReady(playerid, const arguments[]);
public OnNamazingPauseReady(playerid, const arguments[])
{
    cef_focus_browser(playerid, NAMAZING_PAUSE_BROWSER_ID, false);
    return 1;
}

forward OnNamazingPauseOpen(playerid, const arguments[]);
public OnNamazingPauseOpen(playerid, const arguments[])
{
    cef_focus_browser(playerid, CHAT_BROWSER, false);
    cef_focus_browser(playerid, MAIN_BROWSER, false);
    cef_focus_browser(playerid, NAMAZING_PAUSE_BROWSER_ID, true);
    return 1;
}

forward OnNamazingPauseClose(playerid, const arguments[]);
public OnNamazingPauseClose(playerid, const arguments[])
{
    cef_focus_browser(playerid, NAMAZING_PAUSE_BROWSER_ID, false);
    cef_always_listen_keys(playerid, NAMAZING_PAUSE_BROWSER_ID, true);
    cef_focus_browser(playerid, CHAT_BROWSER, false);
    cef_always_listen_keys(playerid, CHAT_BROWSER, true);
    return 1;
}

forward OnNamazingPauseReconnect(playerid, const arguments[]);
public OnNamazingPauseReconnect(playerid, const arguments[])
{
    NamazingProd_SendHidden(playerid, "@@AMZRECONNECT");
    return 1;
}

forward OnNamazingPauseExit(playerid, const arguments[]);
public OnNamazingPauseExit(playerid, const arguments[])
{
    Kick(playerid);
    return 1;
}

forward OnNamazingPauseSetting(playerid, const arguments[]);
public OnNamazingPauseSetting(playerid, const arguments[])
{
    new key[64], value[64], packet[144];
    if(sscanf(arguments, "p<|>s[64]s[64]", key, value)) return 1;
    format(packet, sizeof(packet), "@@AMZSETTING:%s:%s", key, value);
    NamazingProd_SendHidden(playerid, packet);
    return 1;
}

forward OnNamazingPauseSettingsRequest(playerid, const arguments[]);
public OnNamazingPauseSettingsRequest(playerid, const arguments[])
{
    return 1;
}
