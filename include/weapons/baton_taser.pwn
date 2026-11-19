#if defined _BATON_TASER_INCLUDED
    #endinput
#endif
#define _BATON_TASER_INCLUDED

#define WEAPON_BATON        3
#define WEAPON_TASER        23

#define BATON_DAMAGE        1
#define BATON_COOLDOWN      1500
#define BATON_STUN_TIME     15000
#define TASER_STUN_TIME     15000
#define TASER_COOLDOWN      8000
#define TASER_RANGE         10.0

new g_BatonCooldown[MAX_PLAYERS];
new g_TaserCooldown[MAX_PLAYERS];
new bool:g_PlayerStunned[MAX_PLAYERS];
new g_StunTimer[MAX_PLAYERS] = {-1, ...};

stock InitBatonTaser(playerid)
{
    g_BatonCooldown[playerid] = 0;
    g_TaserCooldown[playerid] = 0;
    g_PlayerStunned[playerid] = false;
    if(g_StunTimer[playerid] != -1) {
        KillTimer(g_StunTimer[playerid]);
        g_StunTimer[playerid] = -1;
    }
}

forward UnStunPlayer(playerid);
public UnStunPlayer(playerid)
{
    if(!IsPlayerConnected(playerid)) return 1;
    g_PlayerStunned[playerid] = false;
    g_StunTimer[playerid] = -1;
    TogglePlayerControllable(playerid, 1);
    ApplyAnimation(playerid, "PED", "getup_front", 4.0, 0, 1, 1, 0, 0);
    return 1;
}

stock StunPlayer(playerid, byid, stun_time)
{
    if(g_PlayerStunned[playerid]) return;

    g_PlayerStunned[playerid] = true;
    TogglePlayerControllable(playerid, 0);
    ApplyAnimation(playerid, "ped", "BIKE_fallR", 4.0, 0, 1, 1, 1, 0);

    if(g_StunTimer[playerid] != -1) KillTimer(g_StunTimer[playerid]);
    g_StunTimer[playerid] = SetTimerEx("UnStunPlayer", stun_time, false, "i", playerid);

    #pragma unused byid
}

stock HandleBatonHit(playerid, targetid)
{
    new tick = GetTickCount();
    if(tick - g_BatonCooldown[playerid] < BATON_COOLDOWN) return;
    g_BatonCooldown[playerid] = tick;

    if(!IsPlayerConnected(targetid)) return;
    if(GetPlayerDistanceFromPoint(playerid,
        PI[targetid][pX], PI[targetid][pY], PI[targetid][pZ]) > 3.0) return;


    new Float:hp;
    GetPlayerHealth(targetid, hp);
    hp -= float(BATON_DAMAGE);
    if(hp <= 0.0) hp = 0.0;
    SetPlayerHealth(targetid, hp);


    StunPlayer(targetid, playerid, BATON_STUN_TIME);

    PlayerPlaySound(playerid, 1130, 0.0, 0.0, 0.0);
}

stock HandleTaserShot(playerid, Float:fX, Float:fY, Float:fZ)
{
    new tick = GetTickCount();
    if(tick - g_TaserCooldown[playerid] < TASER_COOLDOWN) {
        GivePlayerWeapon(playerid, WEAPON_TASER, 1);
        return;
    }

    new targetid = INVALID_PLAYER_ID;
    new Float:minDist = TASER_RANGE;
    foreach(new i : Player) {
        if(i == playerid) continue;
        new Float:dist = GetPlayerDistanceFromPoint(i, fX, fY, fZ);
        if(dist < minDist) {
            minDist = dist;
            targetid = i;
        }
    }

    GivePlayerWeapon(playerid, WEAPON_TASER, 1);

    if(targetid == INVALID_PLAYER_ID) return;


    new Float:hp;
    GetPlayerHealth(targetid, hp);
    hp -= 1.0;
    if(hp <= 0.0) hp = 0.0;
    SetPlayerHealth(targetid, hp);

    g_TaserCooldown[playerid] = tick;

    StunPlayer(targetid, playerid, TASER_STUN_TIME);
}
