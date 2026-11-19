enum SafeZoneStruct
{
    szAreaID,
    Float:szPos_x,
    Float:szPos_y,
    Float:szPos_z,
    Float:szSize,
    szWorld,
}

#define MAX_ZONES 50
new SafeZone[MAX_ZONES][SafeZoneStruct];
