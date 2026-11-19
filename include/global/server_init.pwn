gettime(global_hour, global_minute, global_second);
SetWorldTime(global_hour);

ReadDataBaseConfig();

if (mysql_errno(dbHandle) != 0) 
{
    new error[100];
    mysql_error(error, sizeof (error), dbHandle);
    printf("[ERROR] #%d '%s'", mysql_errno(dbHandle), error);
}
else
{
    print("MySQL connection: TRUE\n");
    mysql_set_charset("cp1251");
    mysql_tquery(dbHandle, "SET CHARACTER SET 'cp1251'", "", "");
    mysql_tquery(dbHandle, "SET NAMES 'cp1251'", "", "");
    mysql_tquery(dbHandle, "SET character_set_client = 'cp1251'", "", "");
    mysql_tquery(dbHandle, "SET character_set_connection = 'cp1251'", "", "");
    mysql_tquery(dbHandle, "SET character_set_results = 'cp1251'", "", "");
    mysql_tquery(dbHandle, "SET SESSION collation_connection = 'cp1251_general_ci'", "", "");
    mysql_log(ERROR);
}

StaffRoles_InitSchema();
StaffRoles_InitPromoPoint();

mysql_tquery(dbHandle, "SELECT * FROM `server_config` WHERE 1", "LoadServerConfig");
mysql_tquery(dbHandle, "SELECT * FROM `safe_zones` WHERE 1", "LoadSafeZones");
mysql_tquery(dbHandle, "SELECT * FROM `teleport_pickups` WHERE 1", "LoadTeleportPickups");
mysql_tquery(dbHandle, "SELECT * FROM `family`", "LoadFamily");

mysql_tquery(dbHandle, "SELECT h.*, COALESCE(a.name, 'None') AS owner_name FROM  houses h LEFT JOIN accounts a ON h.owner_id = a.id;", "LoadHouses");





mysql_tquery(dbHandle, "INSERT IGNORE INTO `fractions_coords` (`fraction_id`) SELECT `id` FROM `fractions`", "", "");
mysql_tquery(dbHandle, "INSERT IGNORE INTO `fractions_skins` (`fraction_id`) SELECT `id` FROM `fractions`", "", "");
mysql_tquery(dbHandle, "INSERT IGNORE INTO `fractions_salaries` (`fraction_id`) SELECT `id` FROM `fractions`", "", "");
mysql_tquery(dbHandle, "INSERT IGNORE INTO `fractions_names` (`fraction_id`) SELECT `id` FROM `fractions`", "", "");

mysql_tquery(
    dbHandle,
    "SELECT f.*, fn.*, fs.*, frs.*, \
    COALESCE(fcd.fraction_spawn_X,-1) AS fraction_spawn_X, COALESCE(fcd.fraction_spawn_Y,-1) AS fraction_spawn_Y, \
    COALESCE(fcd.fraction_spawn_Z,-1) AS fraction_spawn_Z, COALESCE(fcd.fraction_spawn_A,-1) AS fraction_spawn_A, \
    COALESCE(fcd.fraction_dress_X,-1) AS fraction_dress_X, COALESCE(fcd.fraction_dress_Y,-1) AS fraction_dress_Y, \
    COALESCE(fcd.fraction_dress_Z,-1) AS fraction_dress_Z, COALESCE(fcd.fraction_dress_pickup_model,1275) AS fraction_dress_pickup_model, \
    COALESCE(fcd.fraction_armoury_X,-1) AS fraction_armoury_X, COALESCE(fcd.fraction_armoury_Y,-1) AS fraction_armoury_Y, \
    COALESCE(fcd.fraction_armoury_Z,-1) AS fraction_armoury_Z, COALESCE(fcd.fraction_armoury_pickup_model,11093) AS fraction_armoury_pickup_model, \
    (SELECT COUNT(*) FROM accounts a WHERE a.fraction = f.id) AS fraction_total_members \
    FROM fractions f \
    LEFT JOIN fractions_names fn ON f.id = fn.fraction_id LEFT JOIN fractions_skins fs ON f.id = fs.fraction_id \
    LEFT JOIN fractions_salaries frs ON f.id = frs.fraction_id LEFT JOIN fractions_coords fcd ON f.id = fcd.fraction_id;",
    "LoadFractions"
);

mysql_tquery(
    dbHandle,
    "SELECT *, (SELECT COUNT(DISTINCT fraction_id) FROM `fractions_warehouse_items`) AS unique_fractions FROM `fractions_warehouse_items`;",
    "LoadFractionsItems"
);

mysql_tquery(dbHandle, "SELECT * FROM `porch`", "LoadPorch");
mysql_tquery(dbHandle, "SELECT * FROM `porch_house`", "LoadPorchHouse");
mysql_tquery(dbHandle, "SELECT * FROM `fractions_vehicles`", "LoadFractionsVehicles");

for(new i = 0; i < MAX_PLAYERS; i++)
{
    g_IsChased[i]     = false;
    g_ChaseTimer[i]   = -1;
    g_ChaseOfficer[i] = INVALID_PLAYER_ID;
    g_ChaseTarget[i]  = INVALID_PLAYER_ID;
}

SetTimer("ServerUpdate", 1000, 1);
SetTimer("SetRandomWeather", 600000, 1);
SetTimer("UpdateVehiclesAudio", 10000, 1);
SetTimer("UpdateVehiclesFuel", 60000, 1);

InitPpsWarehouse();
InitVchWarehouse();

DisableInteriorEnterExits();
ManualVehicleEngineAndLights();
EnableStuntBonusForAll(0);

LoadOther();

IsServerRestarting = false;
CreateSbytPoints();
Surrender_CreatePickup();
LoadOtdelSystem();

LoadVchPosts();

InitWarehouseAreas();
LoadZakladki();

LoadMineSystem();
InitJobsSchema();
LoadFactorySystem();
LoadRazvozSystem();
LoadMechanicSystem();
LoadAvtobusSystem();

InitDynamicDoors();

mysql_tquery(dbHandle, "SELECT * FROM `map_objects`", "LoadMapObjects", "");