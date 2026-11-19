new g_TimeInGame[MAX_PLAYERS]   = {0, ...};
new g_TimeAFK[MAX_PLAYERS]      = {0, ...};
new bool:g_TimeOpen[MAX_PLAYERS];

forward TimeWidgetReady(playerid);
public TimeWidgetReady(playerid)
{
    if(!IsPlayerConnected(playerid)) return;
    if(!g_TimeOpen[playerid]) return;

    _SendTimeData(playerid);
}

stock _SendTimeData(playerid)
{
    new gameStr[16];
    new gSec = g_TimeInGame[playerid];
    if(gSec < 60)        format(gameStr, sizeof(gameStr), "%d с.", gSec);
    else if(gSec < 3600) format(gameStr, sizeof(gameStr), "%d м. %d с.", gSec/60, gSec%60);
    else                 format(gameStr, sizeof(gameStr), "%d ч. %d м.", gSec/3600, (gSec%3600)/60);

    new afkStr[16];
    new aSec = g_TimeAFK[playerid];
    if(aSec < 60)        format(afkStr, sizeof(afkStr), "%d с.", aSec);
    else if(aSec < 3600) format(afkStr, sizeof(afkStr), "%d м. %d с.", aSec/60, aSec%60);
    else                 format(afkStr, sizeof(afkStr), "%d ч. %d м.", aSec/3600, (aSec%3600)/60);

    new kpzStr[24];
    if(g_IsArrested[playerid] && g_ArrestTime[playerid] > 0) {
        new rem = g_ArrestTime[playerid];
        if(rem < 60) format(kpzStr, sizeof(kpzStr), "%d с.", rem);
        else         format(kpzStr, sizeof(kpzStr), "%d м. %d с.", rem/60, rem%60);
    } else {
        kpzStr = "Нет";
    }

    new timeStr[12], dateStr[12];
    format(timeStr, sizeof(timeStr), "%02d:%02d:%02d", global_hour, global_minute, global_second);
    new y, mo, d;
    getdate(y, mo, d);
    format(dateStr, sizeof(dateStr), "%02d.%02d.%02d", d, mo, y % 100);

    cef_emit_event(playerid, "time:update",
        CEFSTR(timeStr), CEFSTR(dateStr),
        CEFSTR(gameStr), CEFSTR(afkStr), CEFSTR(kpzStr));
}

stock UpdateTimeWidget(playerid)
{
    if(!PT[playerid][pLogged]) return;


    g_TimeInGame[playerid]++;
    if(PI[playerid][pAFK]) g_TimeAFK[playerid]++;


    if(!g_TimeOpen[playerid]) return;
    if(!PT[playerid][pCefLoaded]) return;
    _SendTimeData(playerid);
}

stock ResetTimeWidget(playerid)
{
    g_TimeInGame[playerid] = 0;
    g_TimeAFK[playerid]    = 0;
    g_TimeOpen[playerid]   = false;
}

cmd:time(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;
    if(!cef_player_has_plugin(playerid)) return SendErr(playerid, "CEF не подключён.");
    if(!PT[playerid][pCefLoaded]) return SendErr(playerid, "CEF не загружен.");

    if(g_TimeOpen[playerid]) {
        g_TimeOpen[playerid] = false;
        cef_destroy_browser(playerid, TIME_BROWSER);
    } else {
        g_TimeOpen[playerid] = true;
        cef_create_browser(playerid, TIME_BROWSER, TIME_CEF_LINK, false, false);
        SetTimerEx("TimeWidgetReady", 600, false, "i", playerid);
    }
    return 1;
}
callback::OnTimeClose(playerid, const arguments[])
{
    g_TimeOpen[playerid] = false;
    cef_destroy_browser(playerid, TIME_BROWSER);
    return 1;
}
