#if defined _jobs_compat_inc
    #endinput
#endif
#define _jobs_compat_inc

#pragma warning disable 201
#pragma warning disable 203
#pragma warning disable 204
#pragma warning disable 213
#pragma warning disable 217

#if defined FACTORY_WORLD
    #undef FACTORY_WORLD
#endif
#define FACTORY_WORLD 1

stock SendSuccess(playerid, const title[], const message[])
{
    #pragma unused title
    CEFChat_Send(playerid, "54B367", message);
    return 1;
}

stock SendError(playerid, const title[], const message[])
{
    #pragma unused title
    CEFChat_Send(playerid, "FF4444", message);
    return 1;
}

stock SendInfo(playerid, const title[], const message[])
{
    #pragma unused title
    CEFChat_Send(playerid, "AAAAAA", message);
    return 1;
}
