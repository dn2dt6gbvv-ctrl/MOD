#if defined _logs_definitions_inc
    #endinput
#endif
#define _logs_definitions_inc





enum LOG_TYPES
{
    LOG_TYPE_NONE = 0,
    LOG_TYPE_MONEY = 1,
    LOG_TYPE_ITEM = 2,
    LOG_TYPE_ADMIN = 3,
    LOG_TYPE_LOGIN = 4,
    LOG_TYPE_OTHER = 5
}

stock LOG_TypeName(LOG_TYPES:type)
{
    static const names[6][8] = { "none", "money", "item", "admin", "login", "other" };
    new i = _:type;
    if(i < 0 || i > 5) i = 5;
    return names[i];
}

stock LOG_Write(LOG_TYPES:type, const line[])
{
    new fname[64], y, m, d, h, mi, s;
    new File:fh;
    getdate(y, m, d);
    gettime(h, mi, s);
    format(fname, sizeof fname, "logs/%s-%04d-%02d-%02d.txt", LOG_TypeName(type), y, m, d);
    fh = fopen(fname, io_append);
    if(!fh) return 0;
    new out[512];
    format(out, sizeof out, "[%02d:%02d:%02d] %s\r\n", h, mi, s, line);
    fwrite(fh, out);
    fclose(fh);
    return 1;
}



stock Log(fromid, toid, LOG_TYPES:type, extra, amount, const reason[])
{
    new line[384], nn1[MAX_PLAYER_NAME], nn2[MAX_PLAYER_NAME];
    if(fromid >= 0 && fromid < MAX_PLAYERS && IsPlayerConnected(fromid)) GetPlayerName(fromid, nn1, sizeof nn1);
    else format(nn1, sizeof nn1, "%d", fromid);
    if(toid >= 0 && toid < MAX_PLAYERS && IsPlayerConnected(toid)) GetPlayerName(toid, nn2, sizeof nn2);
    else format(nn2, sizeof nn2, "%d", toid);
    format(line, sizeof line, "%s -> %s | type=%d extra=%d amount=%d reason=%s",
        nn1, nn2, _:type, extra, amount, reason);
    return LOG_Write(type, line);
}
