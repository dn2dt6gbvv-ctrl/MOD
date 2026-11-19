
#define CHAT_COLOR_OOC      "AAAAAA"
#define CHAT_COLOR_ME       "C2A2DA"
#define CHAT_COLOR_DO       "C2A2DA"
#define CHAT_COLOR_FRACTION "AADDAA"
#define CHAT_COLOR_FAMILY   "FFCC88"
#define CHAT_COLOR_ADMIN    "FF4444"
#define CHAT_COLOR_SYSTEM   "FFFFFF"
#define CHAT_COLOR_PM_IN    "99CCFF"
#define CHAT_COLOR_PM_OUT   "6699BB"
#define CHAT_COLOR_RADIO    "54B367"
#define CHAT_COLOR_DEPT     "FF8282"

stock CEFChat_HexToInt(const hex[])
{
    new result = 0, len = strlen(hex);
    for (new i = 0; i < len && i < 6; i++) {
        new c = hex[i];
        result <<= 4;
        if (c >= '0' && c <= '9') result |= c - '0';
        else if (c >= 'a' && c <= 'f') result |= c - 'a' + 10;
        else if (c >= 'A' && c <= 'F') result |= c - 'A' + 10;
    }
    return (result << 8) | 0xFF;
}

stock CEFChat_Send(playerid, const color[], const message[], const category[] = "")
{
    if (!cef_player_has_plugin(playerid) || !PT[playerid][pCefLoaded]) {
        return CEFC_ChatBoth(playerid, CEFChat_HexToInt(color), message);
    }
    #pragma unused category
    CEFC_ChatMessage(playerid, message, CEFChat_HexToInt(color) >>> 8);
    return 1;
}

stock CEFChat_SendAll(const color[], const message[], const category[] = "")
{
    foreach (new i : Player)
        CEFChat_Send(i, color, message, category);
    return 1;
}

stock CEFChat_OpenInput(playerid, const prefix[] = "")
{
    if (!cef_player_has_plugin(playerid) || !PT[playerid][pCefLoaded]) return 0;
    #pragma unused prefix
    CEFC_ChatOpenInput(playerid);
    return 1;
}

stock CEFChat_CloseInput(playerid)
{
    if (!cef_player_has_plugin(playerid) || !PT[playerid][pCefLoaded]) return 0;
    CEFC_ChatCloseInput(playerid);
    return 1;
}

stock CEFChat_Clear(playerid)
{
    if (!cef_player_has_plugin(playerid) || !PT[playerid][pCefLoaded]) return 0;
    CEFC_ChatInit(playerid);
    return 1;
}

stock CEFChat_ClearAll()
{
    foreach (new i : Player)
        CEFChat_Clear(i);
    return 1;
}
stock CEFChat_SetVisible(playerid, bool:visible)
{
    if (!cef_player_has_plugin(playerid) || !PT[playerid][pCefLoaded]) return 0;
    CEFC_ChatSetVisible(playerid, visible);
    return 1;
}





cmd:cc(playerid, params[])
{
    if (!PI[playerid][pAdmin]) return 0;
    CEFChat_ClearAll();
    CEFChat_SendAll("AAAAAA", "[A] Чат был очищен администрацией.");
    return 1;
}

cmd:opencefchat(playerid, params[])
{
    if (!cef_player_has_plugin(playerid) || !PT[playerid][pCefLoaded]) return 1;
    new mode = 0;
    sscanf(params, "d", mode);
    if (mode == 1)
        CEFC_ChatOpenInput(playerid);
    else
        CEFC_ChatOpenInput(playerid);
    return 1;
}

cmd:chattest(playerid, params[])
{
    new dbg[256];
    format(dbg, sizeof(dbg), "[CHATDBG] plugin:%d cefLoaded:%d logged:%d",
        cef_player_has_plugin(playerid), PT[playerid][pCefLoaded], PT[playerid][pLogged]);
    SCM_Native(playerid, 0xFFFF00FF, dbg);
    if (!cef_player_has_plugin(playerid)) { SCM_Native(playerid, 0xFF4444FF, "[CHATDBG] no plugin"); return 1; }
    if (!PT[playerid][pCefLoaded])        { SCM_Native(playerid, 0xFF4444FF, "[CHATDBG] not loaded"); return 1; }
    CEFChat_Send(playerid, "FFFFFF", "White SYSTEM");
    CEFChat_Send(playerid, "FF4444", "Red ADMIN", "System");
    CEFChat_Send(playerid, CHAT_COLOR_RADIO, "[R] Рация тест", "Рация");
    CEFChat_Send(playerid, CHAT_COLOR_DEPT, "[D] Департамент тест", "Департамент");
    CEFChat_Send(playerid, "99CCFF", "Blue PM", "PM");
    CEFChat_Send(playerid, "C2A2DA", "Purple /me", "Action");
    CEFChat_Send(playerid, "FFCC88", "Orange /f", "Family");
    CEFChat_Send(playerid, "FFFFFF", "{FF4444}Red {8BC34A}Green {54B367}Radio {FF8282}Dept");
    SCM_Native(playerid, 0x00FF00FF, "[CHATDBG] Done.");
    return 1;
}

callback::OnCefChatSubmit(playerid, const arguments[])
{
    if (!PT[playerid][pLogged]) return 1;
    new msg[145];
    sscanf(arguments, "s[145]", msg);
    if (!strlen(msg)) return 1;
    if (msg[0] == '/') {
        PC_EmulateCommand(playerid, msg);
        return 1;
    }
    new fullMsg[256], Float:px, Float:py, Float:pz;
    GetPlayerPos(playerid, px, py, pz);
    if (strlen(PI[playerid][pRuFirstName]) > 0)
        format(fullMsg, sizeof(fullMsg), "%s %s (%d): %s",
            PI[playerid][pRuFirstName], PI[playerid][pRuLastName], playerid, msg);
    else
        format(fullMsg, sizeof(fullMsg), "%s (%d): %s",
            PI[playerid][pName], playerid, msg);
    foreach (new i : Player) {
        if (IsPlayerInRangeOfPoint(i, 20.0, px, py, pz))
            CEFChat_Send(i, CHAT_COLOR_SYSTEM, fullMsg);
    }
    return 1;
}
