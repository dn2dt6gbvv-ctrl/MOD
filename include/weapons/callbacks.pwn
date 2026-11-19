

#include "include/weapons/baton_taser.pwn"

public ac_OnPlayerGiveDamage(playerid, damageid, Float:amount, weaponid, bodypart)
{
    if(weaponid == WEAPON_BATON)
    {
        HandleBatonHit(playerid, damageid);
        return 1;
    }
    return 0;
}

public ac_OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
    if(weaponid == WEAPON_TASER)
    {
        HandleTaserShot(playerid, fX, fY, fZ);
        return 1;
    }
    return 1;
}
