
#if defined _cef_chat_included
    #endinput
#endif
#define _cef_chat_included


#define CHAT_CEF_URL "http://176.12.67.1/downloads/amazing/chat/index.html"


static PlayerCEF:g_PlayerChat[MAX_PLAYERS];
static bool:g_ChatOpened[MAX_PLAYERS];
static g_ChatInitTimer[MAX_PLAYERS];


forward InitPlayerChatCEF(playerid);
forward ShowPlayerChatCEF(playerid, bool:show);
forward AddChatMessage(playerid, const text[]);
forward DestroyPlayerChatCEF(playerid);


InitPlayerChatCEF(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;


    if(g_PlayerChat[playerid] != PlayerCEF:0)
    {
        DestroyPlayerCEF(g_PlayerChat[playerid]);
    }


    g_PlayerChat[playerid] = CreatePlayerCEF(playerid, CHAT_CEF_URL, 400, 300);

    if(g_PlayerChat[playerid] != PlayerCEF:0)
    {
        PlayerCEF_SetVisible(g_PlayerChat[playerid], false);
        printf("[CEF] Чат создан для игрока %d", playerid);
        return 1;
    }

    printf("[CEF] Ошибка создания чата для игрока %d", playerid);
    return 0;
}


ShowPlayerChatCEF(playerid, bool:show)
{
    if(!IsPlayerConnected(playerid)) return;
    if(g_PlayerChat[playerid] == PlayerCEF:0) return;

    g_ChatOpened[playerid] = show;
    PlayerCEF_SetVisible(g_PlayerChat[playerid], show);

    if(show)
    {
        SelectTextDraw(playerid, 0xFFFFFFFF);
    }
    else
    {
        CancelSelectTextDraw(playerid);
        PlayerCEF_ExecuteJS(g_PlayerChat[playerid], "resetInput();");
    }
}


AddChatMessage(playerid, const text[])
{
    if(!IsPlayerConnected(playerid)) return;
    if(g_PlayerChat[playerid] == PlayerCEF:0) return;
    if(!g_ChatOpened[playerid]) return;

    new escaped[512];
    strcpy(escaped, text, 512);
    for(new i = 0; i < strlen(escaped); i++)
    {
        if(escaped[i] == '\'') strins(escaped, "\\", i, 512), i++;
        if(escaped[i] == '\"') strins(escaped, "\\", i, 512), i++;
    }

    new js[600];
    format(js, sizeof(js), "addMessage('%s');", escaped);
    PlayerCEF_ExecuteJS(g_PlayerChat[playerid], js);
}


DestroyPlayerChatCEF(playerid)
{
    if(g_PlayerChat[playerid] != PlayerCEF:0)
    {
        DestroyPlayerCEF(g_PlayerChat[playerid]);
        g_PlayerChat[playerid] = PlayerCEF:0;
    }
    g_ChatOpened[playerid] = false;
}


stock SendGlobalCEFMessage(const text[])
{
    new escaped[512];
    strcpy(escaped, text, 512);
    for(new i = 0; i < strlen(escaped); i++)
    {
        if(escaped[i] == '\'') strins(escaped, "\\", i, 512), i++;
        if(escaped[i] == '\"') strins(escaped, "\\", i, 512), i++;
    }

    new js[600];
    format(js, sizeof(js), "addMessage('%s');", escaped);

    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && g_PlayerChat[i] != PlayerCEF:0)
        {
            PlayerCEF_ExecuteJS(g_PlayerChat[i], js);
        }
    }
}
