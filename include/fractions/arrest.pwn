
#if defined _ARREST_INCLUDED
    #endinput
#endif
#define _ARREST_INCLUDED

#define ARREST_REWARD_PER_STAR  50000
#define ARREST_TIME_PER_STAR    180
#define ARREST_RANGE            30.0
#define KPZ_VIRTUAL_WORLD       22

#define ARREST_FRAC_COUNT 3
new g_ArrestFracs[ARREST_FRAC_COUNT] = {
    FRACTION_FSB,
    FRACTION_TRAFFIC_PATROL_POLICE,
    FRACTION_PATROL_POLICE
};

#define ARREST_ZONE_COUNT 3
new Float:g_ArrestZones[ARREST_ZONE_COUNT][3] = {
    {1598.3679, 1201.7579, 1664.0267},
    {1305.4011, 1053.6626, 2161.2371},
    {1550.9154, 803.8300,  1901.2372}
};

new Float:g_KPZPoints[3][4] = {
    {1573.8960, 813.9851, 1901.2372, 270.6129},
    {1577.7050, 814.0264, 1901.2372, 270.6129},
    {1581.2957, 813.6683, 1901.2372, 260.3042}
};

new g_ArrestTime[MAX_PLAYERS]    = {0, ...};
new g_ArrestOfficer[MAX_PLAYERS] = {-1, ...};
new bool:g_IsArrested[MAX_PLAYERS];

stock CanArrest(playerid)
{
    if(!PT[playerid][pDuty]) return false;
    new frac = PI[playerid][pFraction];
    for(new i = 0; i < ARREST_FRAC_COUNT; i++)
        if(g_ArrestFracs[i] == frac) return true;
    return false;
}

stock IsInArrestZone(playerid)
{
    for(new i = 0; i < ARREST_ZONE_COUNT; i++) {
        if(IsPlayerInRangeOfPoint(playerid, ARREST_RANGE,
            g_ArrestZones[i][0], g_ArrestZones[i][1], g_ArrestZones[i][2]))
            return true;
    }
    return false;
}

stock DoArrest(officerId, targetid)
{
    new stars = PI[targetid][pWanted];
    if(stars <= 0) return SendErr(officerId, "У этого игрока нет розыска.");


    if(FollowBy[targetid] != MAX_PLAYERS)
    {
        KillTimer(TimerForPlayer[targetid]);
        TimerForPlayer[targetid] = MAX_PLAYERS;
        FollowBy[targetid] = MAX_PLAYERS;
    }


    if(pCuff[targetid][pCuffer] != INVALID_PLAYER_ID)
    {
        new cuffer = pCuff[targetid][pCuffer];
        pCuff[cuffer][pCuffee] = INVALID_PLAYER_ID;
        pCuff[targetid][pCuffer] = INVALID_PLAYER_ID;
    }
    TogglePlayerControllable(targetid, 1);
    ClearAnimations(targetid);

    new kpz = random(3);
    SetPlayerPos(targetid, g_KPZPoints[kpz][0], g_KPZPoints[kpz][1], g_KPZPoints[kpz][2]);
    SetPlayerFacingAngle(targetid, g_KPZPoints[kpz][3]);
    SetPlayerVirtualWorld(targetid, KPZ_VIRTUAL_WORLD);
    SetPlayerInterior(targetid, 0);
    SetCameraBehindPlayer(targetid);

    new arrestSeconds = stars * ARREST_TIME_PER_STAR;
    g_ArrestTime[targetid]    = arrestSeconds;
    g_IsArrested[targetid]    = true;
    g_ArrestOfficer[targetid] = officerId;

    new query[128];
    mysql_format(dbHandle, query, sizeof(query),
        "UPDATE `accounts` SET `arrest_time`=%d WHERE `id`=%d",
        arrestSeconds, PI[targetid][pID]);
    mysql_tquery(dbHandle, query, "", "");

    PI[targetid][pWanted] = 0;
    SetPlayerWantedLevel(targetid, 0);
    mysql_format(dbHandle, query, sizeof(query),
        "UPDATE `accounts` SET `wanted`=0 WHERE `id`=%d", PI[targetid][pID]);
    mysql_tquery(dbHandle, query, "", "");

    new reward = stars * ARREST_REWARD_PER_STAR;
    PI[officerId][pCash] += reward;
    GivePlayerMoney(officerId, reward);
    mysql_format(dbHandle, query, sizeof(query),
        "UPDATE `accounts` SET `cash`=%d WHERE `id`=%d",
        PI[officerId][pCash], PI[officerId][pID]);
    mysql_tquery(dbHandle, query, "", "");

    PI[officerId][pExp]++;
    mysql_format(dbHandle, query, sizeof(query),
        "UPDATE `accounts` SET `exp`=%d WHERE `id`=%d",
        PI[officerId][pExp], PI[officerId][pID]);
    mysql_tquery(dbHandle, query, "", "");

    new msgTarget[144];
    new mins = arrestSeconds / 60;
    format(msgTarget, sizeof(msgTarget),
        "Вы арестованы! Срок: %d мин. Причина: %d зв. розыска.", mins, stars);
    CEFChat_Send(targetid, "FF4444", msgTarget);

    new msgOfficer[144];
    format(msgOfficer, sizeof(msgOfficer),
        "Поздравляем! Вы получаете премию в виде %s рублей и +1 EXP (опыт)", SplitInt(reward));
    CEFChat_Send(officerId, "2980B9", msgOfficer);

    new frac = PI[officerId][pFraction];
    new rankName[32], otdelName[32];
    format(rankName, sizeof(rankName), "%s", Fraction_Rank[frac][PI[officerId][pFractionRank]-1]);
    GetOtdelName(frac, PI[officerId][pPodtdel], otdelName, sizeof(otdelName));

    new radio[200];
    if(strcmp(otdelName, "Отсутствует", true) != 0)
        format(radio, sizeof(radio), "[Внимание] %s (%s) %s арестовал преступника %s и получил премию %s руб.",
            otdelName, rankName, GetName(officerId), GetName(targetid), SplitInt(reward));
    else
        format(radio, sizeof(radio), "[Внимание] %s %s арестовал преступника %s и получил премию %s руб.",
            rankName, GetName(officerId), GetName(targetid), SplitInt(reward));

    foreach(new i : Player) {
        if(!PT[i][pLogged] || !PT[i][pDuty]) continue;
        new ifrac = PI[i][pFraction];
        for(new j = 0; j < ARREST_FRAC_COUNT; j++) {
            if(g_ArrestFracs[j] == ifrac) {
                CEFChat_Send(i, "2B78C5", radio);
                break;
            }
        }
    }
    if(pCuff[targetid][pCuffer] != INVALID_PLAYER_ID)
    {
        new cuffer = pCuff[targetid][pCuffer];
        pCuff[cuffer][pCuffee] = INVALID_PLAYER_ID;
        pCuff[targetid][pCuffer] = INVALID_PLAYER_ID;
    }
    SetPlayerSpecialAction(targetid, SPECIAL_ACTION_NONE);
    RemovePlayerAttachedObject(targetid, 0);
    TogglePlayerControllable(targetid, 1);
    ClearAnimations(targetid);
    UpdatePlayerHUD(officerId);
    UpdatePlayerHUD(targetid);
    return 1;
}

stock TickArrestTimer(playerid)
{
    if(!g_IsArrested[playerid]) return;
    if(g_ArrestTime[playerid] <= 0) {
        ReleaseFromArrest(playerid);
        return;
    }
    g_ArrestTime[playerid]--;

    if(g_ArrestTime[playerid] % 30 == 0 && g_ArrestTime[playerid] > 0) {
        new query[96];
        mysql_format(dbHandle, query, sizeof(query),
            "UPDATE `accounts` SET `arrest_time`=%d WHERE `id`=%d",
            g_ArrestTime[playerid], PI[playerid][pID]);
        mysql_tquery(dbHandle, query, "", "");
    }

    if(g_ArrestTime[playerid] > 0 && g_ArrestTime[playerid] % 60 == 0) {
        new msg[64];
        format(msg, sizeof(msg), "[КПЗ] Осталось: %d мин.", g_ArrestTime[playerid] / 60);
        CEFChat_Send(playerid, "AAAAAA", msg);
    }
}

stock ReleaseFromArrest(playerid)
{
    g_IsArrested[playerid]    = false;
    g_ArrestTime[playerid]    = 0;
    g_ArrestOfficer[playerid] = -1;

    new query[96];
    mysql_format(dbHandle, query, sizeof(query),
        "UPDATE `accounts` SET `arrest_time`=0 WHERE `id`=%d", PI[playerid][pID]);
    mysql_tquery(dbHandle, query, "", "");
    PI[playerid][pSpawn] = 0;
    SpawnPlayerEx(playerid);

    CEFChat_Send(playerid, "54B367", "Вы освобождены из-под стражи.");
}
stock LoadArrestTime(playerid, arrestTime)
{
    if(arrestTime <= 0) return;
    g_ArrestTime[playerid] = arrestTime;
    g_IsArrested[playerid] = true;
    SetTimerEx("ApplyArrestSpawn", 500, false, "i", playerid);
    SetTimerEx("ApplyArrestSpawn", 2500, false, "i", playerid);
    new msg[64];
    format(msg, sizeof(msg), "[КПЗ] Вы под стражей. Осталось: %d мин.", arrestTime / 60);
    CEFChat_Send(playerid, "FF4444", msg);
}

forward ApplyArrestSpawn(playerid);
public ApplyArrestSpawn(playerid)
{
    if(!IsPlayerConnected(playerid)) return;
    if(!g_IsArrested[playerid]) return;
    new kpz = random(3);
    SetPlayerPos(playerid, g_KPZPoints[kpz][0], g_KPZPoints[kpz][1], g_KPZPoints[kpz][2]);
    SetPlayerFacingAngle(playerid, g_KPZPoints[kpz][3]);
    SetPlayerVirtualWorld(playerid, KPZ_VIRTUAL_WORLD);
    SetPlayerInterior(playerid, 0);
    SetCameraBehindPlayer(playerid);
}

cmd:arrest(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;
    if(!CanArrest(playerid)) return SendErr(playerid, "У вас нет прав для ареста.");

    new targetid;
    if(sscanf(params, "u", targetid)) return SendErr(playerid, "Использование: /arrest [ID]");
    if(!IsPlayerConnected(targetid)) return SendErr(playerid, "Игрок не в сети.");
    if(targetid == playerid) return SendErr(playerid, "Нельзя арестовать себя.");
    if(g_IsArrested[targetid]) return SendErr(playerid, "Игрок уже под стражей.");
    if(PI[targetid][pWanted] <= 0) return SendErr(playerid, "У этого игрока нет розыска.");

    new Float:tx, Float:ty, Float:tz;
    GetPlayerPos(targetid, tx, ty, tz);
    if(!IsPlayerInRangeOfPoint(playerid, ARREST_RANGE, tx, ty, tz))
        return SendErr(playerid, "Игрок слишком далеко.");

    if(!IsInArrestZone(playerid))
        return SendErr(playerid, "Вы должны находиться в зоне ареста.");

    DoArrest(playerid, targetid);
    return 1;
}

cmd:freekpz(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;
    if(PI[playerid][pAdmin] < 3) return SendErr(playerid, "Нет прав!");

    new targetid;
    if(sscanf(params, "u", targetid)) return SendErr(playerid, "Использование: /freekpz [ID]");
    if(!IsPlayerConnected(targetid)) return SendErr(playerid, "Игрок не в сети.");
    if(!g_IsArrested[targetid]) return SendErr(playerid, "Игрок не находится в КПЗ.");

    ReleaseFromArrest(targetid);

    new msg[144];
    format(msg, sizeof(msg), "[Администрация] %s выпустил из КПЗ игрока %s.", GetName(playerid), GetName(targetid));
    CEFChat_SendAll("E69348", msg);
    return 1;
}
