#if defined _chatclear_included
    #endinput
#endif
#define _chatclear_included

#define CHAT_CLEAR_LINES   100
#define CHAT_CLEAR_STEP    10
#define CHAT_CLEAR_DELAY   100 

new clearChatIndex[MAX_PLAYERS];

forward ClearPlayerChatStep(playerid);
public ClearPlayerChatStep(playerid)
{
    if (!IsPlayerConnected(playerid)) return 0;

    new current = clearChatIndex[playerid];
    if (current >= CHAT_CLEAR_LINES) return 0;

    for (new i = 0; i < CHAT_CLEAR_STEP; i++)
    {
        if (current + i >= CHAT_CLEAR_LINES) break;
        SendClientMessage(playerid, -1, "");
    }

    clearChatIndex[playerid] += CHAT_CLEAR_STEP;

    SetTimerEx("ClearPlayerChatStep", CHAT_CLEAR_DELAY, false, "i", playerid);
    return 1;
}

stock ClearPlayerChat(playerid)
{
    if (!IsPlayerConnected(playerid)) return;
    clearChatIndex[playerid] = 0;
    SetTimerEx("ClearPlayerChatStep", CHAT_CLEAR_DELAY, false, "i", playerid);
}

stock ClearChatForAll()
{
    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        if (IsPlayerConnected(i))
        {
            ClearPlayerChat(i);
        }
    }
}
