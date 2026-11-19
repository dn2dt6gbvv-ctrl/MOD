cmd:test(playerid) return SendClientMessage(playerid, -1, "OK!");

#define MAX_HOUSES 1000

enum HouseStruct {
    hID,
    hOwner[MAX_PLAYER_NAME],
    hOwnerID,

    hPrice,
    hHours,
    hClass,
    hLock,
    hPay,

    hPickup, 
    hMapIcon,

    Float:hPos_x,
    Float:hPos_y,
    Float:hPos_z,
    hArea,
    hAreaExit,

    Float:hVSPos_x,
    Float:hVSPos_y,
    Float:hVSPos_z,
    Float:hVSPos_a,
    hAreaSpawnVehicle
};
new House[MAX_HOUSES][HouseStruct];

enum hInts {
    Float:hIPos_X,
    Float:hIPos_Y,
    Float:hIPos_Z,

    Float:hIPos_EX,
    Float:hIPos_EY,
    Float:hIPos_EZ,
    Float:hIPos_EA,
};
new House_Interiors[4][hInts] = 
{
    {0.0},
    {-1.0348, 0.1149, 1101.0000, -1.0371,1.6324,1101.0000,359.6261},
    {-2137.7717, 1915.1893, 2158.3501, -2137.6343, 1916.4398, 2158.3501, 358.6235},
    {-2076.3223,482.2941,1851.7976, -2076.3171, 483.7620, 1851.7976, 0.2557}
};

new total_houses;
