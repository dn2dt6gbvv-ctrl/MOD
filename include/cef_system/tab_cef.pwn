#if defined _TAB_CEF_INCLUDED
    #endinput
#endif
#define _TAB_CEF_INCLUDED

#define TAB_BROWSER      56
#define TAB_CEF_LINK     "file:///cef/amazing/tab/index.html"

stock CEF_TabPushData(playerid)
{
    if(!IsPlayerConnected(playerid) || !PT[playerid][pLogged]) return 0;
    CEFC_AccountStats(playerid);
    CEF_CurrencySend(playerid);
    CEF_InvSync(playerid);
    CEF_OpsPlayersList(playerid);
    CEF_PerksSend(playerid);
    CEF_TasksSend(playerid);
    CEF_PrizesSend(playerid, false);
    return 1;
}

forward CEFC_TabWarm(playerid);
public CEFC_TabWarm(playerid)
{
    if(!IsPlayerConnected(playerid) || !PT[playerid][pLogged]) return 1;
    cef_always_listen_keys(playerid, MAIN_BROWSER, true);
    TogglePlayerSpectating(playerid, 0);
    CEFC_HideSampHud(playerid);
    CEFC_ChatSetDisabled(playerid, false);
    CEFC_ChatSetVisible(playerid, true);
    CEF_TabPushData(playerid);
    return 1;
}

stock OpenTabCEF(playerid, tab = 1)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) || !PT[playerid][pLogged]) return 0;
    if(tab <= 0) tab = 1;
    TogglePlayerSpectating(playerid, 0);
    cef_always_listen_keys(playerid, MAIN_BROWSER, true);
    if(gCefMenuOpen[playerid])
    {
        CEF_TabPushData(playerid);
        CEFC_MenuCamApply(playerid);
        {
            new js[32];
            format(js, sizeof js, "{\"tab\":%d}", tab);
            CEF_Send(playerid, "menu_open", js);
        }
        CEF_Focus(playerid, true);
        return 1;
    }
    CEFC_MenuBegin(playerid);
    CEF_TabPushData(playerid);
    {
        new js[32];
        format(js, sizeof js, "{\"tab\":%d}", tab);
        CEF_Send(playerid, "menu_open", js);
    }
    CEF_Focus(playerid, true);
    SetTimerEx("CEFC_TabFill", 350, false, "i", playerid);
    return 1;
}

forward CEFC_TabFill(playerid);
public CEFC_TabFill(playerid)
{
    if(!IsPlayerConnected(playerid) || !gCefMenuOpen[playerid]) return 1;
    CEF_TabPushData(playerid);
    return 1;
}

forward TabCEFToggle(playerid);
public TabCEFToggle(playerid)
{
    if(!IsPlayerConnected(playerid) || !PT[playerid][pLogged]) return 1;
    if(gCefCaseActive[playerid] || gCefCasePending[playerid])
    {
        CEF_CaseCloseUi(playerid);
        return 1;
    }
    if(gCefMenuOpen[playerid]) CloseTabCEF(playerid);
    else
    {
        if(GetTickCount() - gCefTabClosedAt[playerid] < 600) return 1;
        OpenTabCEF(playerid, 1);
    }
    return 1;
}

forward TabCEFInv(playerid);
public TabCEFInv(playerid)
{
    if(!IsPlayerConnected(playerid) || !PT[playerid][pLogged]) return 1;
    OpenTabCEF(playerid, 2);
    return 1;
}

forward TabCEFClose(playerid);
public TabCEFClose(playerid)
{
    if(!IsPlayerConnected(playerid)) return 1;
    if(gCefCaseActive[playerid] || gCefCasePending[playerid])
    {
        CEF_CaseCloseUi(playerid);
        return 1;
    }
    if(gCefMenuOpen[playerid]) CloseTabCEF(playerid);
    else
    {
        CEF_Focus(playerid, false);
        TogglePlayerControllable(playerid, 1);
    }
    return 1;
}

forward TabCEFReady(playerid);
public TabCEFReady(playerid)
{
    if(!IsPlayerConnected(playerid)) return 1;
    OpenTabCEF(playerid, 1);
    return 1;
}

stock CloseTabCEF(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;
    if(!gCefMenuOpen[playerid] && !gCefCamOn[playerid])
    {
        CEF_Focus(playerid, false);
        return 1;
    }
    CEF_SendEmpty(playerid, "menu_close");
    CEFC_OnMenuClosed(playerid);
    return 1;
}

callback::OnTabReady(playerid, const arguments[])
{
    #pragma unused arguments
    if(!IsPlayerConnected(playerid) || !PT[playerid][pLogged]) return 1;
    if(gCefMenuOpen[playerid]) CEF_TabPushData(playerid);
    return 1;
}

callback::OnTabOpenRequest(playerid, const arguments[])
{
    #pragma unused arguments
    if(!IsPlayerConnected(playerid) || !PT[playerid][pLogged]) return 1;
    OpenTabCEF(playerid, 1);
    return 1;
}

callback::OnTabOpened(playerid, const arguments[])
{
    #pragma unused arguments
    if(!IsPlayerConnected(playerid) || !PT[playerid][pLogged]) return 1;
    if(gCefMenuOpen[playerid]) CEF_TabPushData(playerid);
    return 1;
}

callback::OnTabClosed(playerid, const arguments[])
{
    CloseTabCEF(playerid);
    return 1;
}

callback::OnTabRequestStats(playerid, const arguments[])
{
    #pragma unused arguments
    if(!IsPlayerConnected(playerid) || !PT[playerid][pLogged]) return 1;
    CEFC_AccountStats(playerid);
    return 1;
}

cmd:test_tab(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;
    OpenTabCEF(playerid, 1);
    return 1;
}

cmd:tab(playerid, params[])
{
    #pragma unused params
    if(!PT[playerid][pLogged]) return 1;
    OpenTabCEF(playerid, 1);
    return 1;
}
