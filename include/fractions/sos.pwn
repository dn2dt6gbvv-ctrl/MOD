#if defined _SOS_INCLUDED
    #endinput
#endif
#define _SOS_INCLUDED

#define SOS_MAX         20
#define SOS_EXPIRE      300
#define SOS_COLOR       0x1FA2B1FF
#define SOS_ICON_ID     20
#define SOS_CD          300 

#define SOS_FRAC_COUNT 5
new g_SosFracs[SOS_FRAC_COUNT] = {
    FRACTION_GOVERMENT,
    FRACTION_FSB,
    FRACTION_TRAFFIC_PATROL_POLICE,
    FRACTION_PATROL_POLICE,
    FRACTION_MILITARY
};

enum E_SOS {
    sos_PlayerID,
    sos_Name[MAX_PLAYER_NAME],
    sos_RankName[32],
    sos_FracID,
    Float:sos_X,
    Float:sos_Y,
    Float:sos_Z,
    sos_Time,
    bool:sos_Active
}

new g_SOS[SOS_MAX][E_SOS];
new g_SOSMapIcon[MAX_PLAYERS] = {-1, ...};
new g_SOSViewIdx[MAX_PLAYERS] = {-1, ...};
new g_SOSCooldown[MAX_PLAYERS] = {0, ...};

stock CanUseSOS(playerid)
{
    if(!PT[playerid][pDuty]) return false;
    new frac = PI[playerid][pFraction];
    for(new i = 0; i < SOS_FRAC_COUNT; i++)
        if(g_SosFracs[i] == frac) return true;
    return false;
}

stock CleanExpiredSOS()
{
    new now = gettime();
    for(new i = 0; i < SOS_MAX; i++) {
        if(!g_SOS[i][sos_Active]) continue;
        if(now - g_SOS[i][sos_Time] >= SOS_EXPIRE)
            g_SOS[i][sos_Active] = false;
    }
}

stock AddSOS(playerid)
{

    new now = gettime();
    if(g_SOSCooldown[playerid] > now) {
        new rem = g_SOSCooldown[playerid] - now;
        new msg[64];
        format(msg, sizeof(msg), "[SOS] Повторный вызов доступен через %d сек.", rem);
        SendClientMessage(playerid, SOS_COLOR, msg);
        return 0;
    }

    CleanExpiredSOS();

    new slot = -1;
    for(new i = 0; i < SOS_MAX; i++) {
        if(!g_SOS[i][sos_Active]) { slot = i; break; }
    }
    if(slot == -1) {
        SendClientMessage(playerid, SOS_COLOR, "[SOS] Список вызовов переполнен, попробуйте позже.");
        return 0;
    }

    new frac = PI[playerid][pFraction];
    new rank = PI[playerid][pFractionRank];

    new rankName[32];
    if(rank > 0 && rank <= MAX_FRACTIONS_RANK)
        format(rankName, sizeof(rankName), "%s", Fraction_Rank[frac][rank-1]);
    else rankName = "Сотрудник";

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    g_SOS[slot][sos_PlayerID] = playerid;
    format(g_SOS[slot][sos_Name], MAX_PLAYER_NAME, "%s", PI[playerid][pName]);
    format(g_SOS[slot][sos_RankName], 32, "%s", rankName);
    g_SOS[slot][sos_FracID] = frac;
    g_SOS[slot][sos_X]      = x;
    g_SOS[slot][sos_Y]      = y;
    g_SOS[slot][sos_Z]      = z;
    g_SOS[slot][sos_Time]   = now;
    g_SOS[slot][sos_Active] = true;

    g_SOSCooldown[playerid] = now + SOS_CD;

    new msg[144];
    format(msg, sizeof(msg), "[Внимание] %s %s [%d] вызывает подмогу! (Используйте /sos)",
        rankName, PI[playerid][pName], playerid);

    foreach(new i : Player) {
        if(!PT[i][pLogged] || !PT[i][pDuty]) continue;
        new ifrac = PI[i][pFraction];
        new bool:allowed = false;
        for(new j = 0; j < SOS_FRAC_COUNT; j++)
            if(g_SosFracs[j] == ifrac) { allowed = true; break; }
        if(allowed) CEFChat_Send(i, "1FA2B1", msg);
    }

    SendClientMessage(playerid, SOS_COLOR, "[SOS] Вызов отправлен. Он исчезнет через 5 минут.");
    return 1;
}

stock ShowSOSList(playerid)
{
    CleanExpiredSOS();

    new list[1024], line[128];
    new now = gettime();
    new count = 0;

    for(new i = 0; i < SOS_MAX; i++) {
        if(!g_SOS[i][sos_Active]) continue;
        new remaining = SOS_EXPIRE - (now - g_SOS[i][sos_Time]);
        new mins = remaining / 60;
        new secs = remaining % 60;
        format(line, sizeof(line), "%s %s — %d:%02d\n",
            g_SOS[i][sos_RankName], g_SOS[i][sos_Name], mins, secs);
        strcat(list, line);
        count++;
    }

    if(count == 0) {
        ShowPlayerDialogEx(playerid, DIALOG_SOS_LIST, DIALOG_STYLE_MSGBOX,
            "СПИСОК SOS", "Активных вызовов нет.", "Закрыть", "");
        return;
    }

    ShowPlayerDialogEx(playerid, DIALOG_SOS_LIST, DIALOG_STYLE_LIST,
        "СПИСОК SOS", list, "Метка", "Назад");
}

stock AcceptSOS(playerid, listitem)
{
    CleanExpiredSOS();

    new count = 0;
    for(new i = 0; i < SOS_MAX; i++) {
        if(!g_SOS[i][sos_Active]) continue;
        if(count == listitem) {
            if(g_SOSMapIcon[playerid] != -1)
                RemovePlayerMapIcon(playerid, g_SOSMapIcon[playerid]);

            new iconSlot = 15 + (playerid % 10);
            SetPlayerMapIcon(playerid, iconSlot,
                g_SOS[i][sos_X], g_SOS[i][sos_Y], g_SOS[i][sos_Z],
                SOS_ICON_ID, SOS_COLOR, MAPICON_GLOBAL);
            g_SOSMapIcon[playerid] = iconSlot;
            g_SOSViewIdx[playerid] = i;

            new msg[96];
            format(msg, sizeof(msg), "[SOS] Метка установлена на позицию %s.", g_SOS[i][sos_Name]);
            SendClientMessage(playerid, SOS_COLOR, msg);
            return;
        }
        count++;
    }
}

cmd:sos(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;
    if(!CanUseSOS(playerid)) {
        SendClientMessage(playerid, SOS_COLOR, "[SOS] У вас нет прав для использования этой команды.");
        return 1;
    }

    ShowPlayerDialogEx(playerid, DIALOG_SOS_MAIN, DIALOG_STYLE_LIST,
        "СРОЧНАЯ ПОМОЩЬ",
        "Список SOS-вызовов\nВызов SOS",
        "Выбрать", "Закрыть");
    return 1;
}
