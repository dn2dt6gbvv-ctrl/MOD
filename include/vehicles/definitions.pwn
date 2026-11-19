#if !defined IsValidVehicle
    native IsValidVehicle(vehicleid);
#endif

new Float:PlayerNitro[MAX_PLAYERS] = {100.0, ...};

enum CarInfo
{
    Engine, 
    Lights, 
    Doors, 
    Bonnet, 
    Boot, 
    Fuel, 
    Alarm, 
    Objective,
    vMileage,
    vStrobsTimer,
    vStrobsStatus,
    vStrobsCount,
    vAudio,
    vAudioObj,
    vAudioUrl[256],
    vAudioStart,
    vAudioArea,
    Text3D:vAudioLabel,
    Float:vLastPosX, 
    Float:vLastPosY, 
    Float:vLastPosZ,
    vOwnerID,
    vOwnerType,
    vRankAvaiable,
    bool:vToningToggled,
    vToningR,
    vToningG,
    vToningB,
    vToningA,
    bool:vNeonToggled,
    vNeonR,
    vNeonG,
    vNeonB,
    vNeonA,
    bool:vSmokeToggled,
    vSmokeR,
    vSmokeG,
    vSmokeB,
    vSmokeA,
    bool:vCustomLightsToggled,
    vCustomLightsR,
    vCustomLightsG,
    vCustomLightsB,
    vCustomLightsA
}
new CI[MAX_VEHICLES][CarInfo];

enum
{
    VEHICLE_OWNER_NONE = 0,
    VEHICLE_OWNER_PLAYER = 1,
    VEHICLE_OWNER_FRACTION = 2
}

new const InvalidVehicleName[] = "Неизвестно";
