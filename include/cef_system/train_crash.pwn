
#if defined _TRAIN_CRASH_INCLUDED
    #endinput
#endif
#define _TRAIN_CRASH_INCLUDED

#if !defined INVALID_DYNAMIC_PICKUP_ID
    #define INVALID_DYNAMIC_PICKUP_ID (-1)
#endif
#if !defined INVALID_DYNAMIC_AREA
    #define INVALID_DYNAMIC_AREA (-1)
#endif

#define MAX_TRAIN_BOXES   20
#define MAX_TRAIN_WAGONS  15
#define TRAIN_REWARD      30000000
#define TRAIN_OPEN_DELAY  15
#define TRAIN_BAG_DELAY   20
#define TRAIN_FRAC_VCH    6
#define TRAIN_FRAC_FSB    2
#define TRAIN_TIME_1_H    15
#define TRAIN_TIME_1_M    30
#define TRAIN_TIME_2_H    19
#define TRAIN_TIME_2_M    30
#define TRAIN_TIME_3_H    3
#define TRAIN_TIME_3_M    30
#define TRAIN_LOC_LYT     0
#define TRAIN_LOC_RC      1
#define TRAIN_COLOR_CRASH "1A3A6E"
#define TRAIN_COLOR_INFO  "AAAAAA"

enum { TRAIN_STATE_IDLE, TRAIN_STATE_CRASH, TRAIN_STATE_OPEN, TRAIN_STATE_BAGS }

new g_TrainState  = TRAIN_STATE_IDLE;
new g_TrainLocIdx = -1;
new bool:g_PlayerHasBag[MAX_PLAYERS];

enum E_TBOX {
    tb_ID,
    Float:tb_X, Float:tb_Y, Float:tb_Z,
    tb_Pickup, tb_Area,
    bool:tb_Open,
    tb_Opener
}
new g_TrainBox[MAX_TRAIN_BOXES][E_TBOX];
new g_TrainBoxCount = 0;

enum E_TWAGON {
    tw_ID, tw_Model,
    Float:tw_X, Float:tw_Y, Float:tw_Z,
    Float:tw_RX, Float:tw_RY, Float:tw_RZ,
    tw_Name[32],
    tw_Object
}
new g_TrainWagon[MAX_TRAIN_WAGONS][E_TWAGON];
new g_TrainWagonCount = 0;

new g_PlayerDeliverArea[MAX_PLAYERS];
new g_PlayerDeliverPickup[MAX_PLAYERS];

new g_SpawnObj[MAX_PLAYERS]   = {0, ...};
new g_SpawnModel[MAX_PLAYERS] = {12739, ...};
new g_SpawnLoc[MAX_PLAYERS]   = {0, ...};
new Float:g_SpawnStep[MAX_PLAYERS];

enum E_DELIVER { Float:dv_X, Float:dv_Y, Float:dv_Z, dv_Frac }
new g_DeliverPoints[][E_DELIVER] = {
    {1356.4390,  1734.7126,  3.6245, TRAIN_FRAC_VCH},
    {-278.5954,   557.1439, 12.7347, TRAIN_FRAC_FSB}
};

enum E_SBYT { Float:sb_X, Float:sb_Y, Float:sb_Z }
new g_SbytPoints[][E_SBYT] = {
    {2811.4827, -2547.1321,  1.3579},
    {90.1815,    1681.0039, 11.9800},
    {-2561.2122, 2909.5498, 37.4317}
};
new g_SbytPickup[3];
new g_SbytArea[3];
new Text3D:g_SbytLabel[3];

forward TrainCrashOpenBoxes();
forward TrainCrashEnd();
forward OnTrainBoxesLoaded();
forward OnTrainWagonsLoaded();

stock TrainLog(const msg[])
{
    printf("[TrainCrash] %s", msg);
    foreach(new i : Player) {
        if(!PT[i][pLogged]) continue;
        if(PI[i][pAdmin] < 1) continue;
        CEFChat_Send(i, "AAAAAA", msg);
    }
}

stock TrainLogF(const msg[], value)
{
    new out[144];
    format(out, sizeof(out), msg, value);
    TrainLog(out);
}

stock TrainLogS(const msg[], const str[])
{
    new out[144];
    format(out, sizeof(out), msg, str);
    TrainLog(out);
}

stock CreateSbytPoints()
{
    for(new i = 0; i < sizeof(g_SbytPoints); i++) {
        new Float:x = g_SbytPoints[i][sb_X];
        new Float:y = g_SbytPoints[i][sb_Y];
        new Float:z = g_SbytPoints[i][sb_Z];
        g_SbytPickup[i] = CreateDynamicPickup(11094, 1, x, y, z);
        g_SbytLabel[i]  = Create3DTextLabel("{AAAAAA}Точка сбыта", 0xFFFFFFFF, x, y, z + 0.5, 10.0, 0, 1);
        g_SbytArea[i]   = CreateDynamicSphere(x, y, z, 3.0);
    }
}

stock LoadTrainBoxes(locIdx)
{
    new query[64];
    if(locIdx == TRAIN_LOC_LYT) format(query, sizeof(query), "SELECT * FROM `train_boxes_lyt`");
    else format(query, sizeof(query), "SELECT * FROM `train_boxes_rc`");
    mysql_tquery(dbHandle, query, "OnTrainBoxesLoaded", "");
}

public OnTrainBoxesLoaded()
{
    g_TrainBoxCount = 0;
    new rows = cache_num_rows();
    for(new i = 0; i < rows && i < MAX_TRAIN_BOXES; i++) {
        cache_get_value_name_int(i,   "id", g_TrainBox[i][tb_ID]);
        cache_get_value_name_float(i, "x",  g_TrainBox[i][tb_X]);
        cache_get_value_name_float(i, "y",  g_TrainBox[i][tb_Y]);
        cache_get_value_name_float(i, "z",  g_TrainBox[i][tb_Z]);
        g_TrainBox[i][tb_Pickup] = INVALID_DYNAMIC_PICKUP_ID;
        g_TrainBox[i][tb_Area]   = INVALID_DYNAMIC_AREA;
        g_TrainBox[i][tb_Open]   = false;
        g_TrainBox[i][tb_Opener] = INVALID_PLAYER_ID;
        g_TrainBoxCount++;
    }
    printf("[TrainCrash] Загружено ящиков: %d", g_TrainBoxCount);
    SpawnTrainWagons();
    SpawnTrainBoxes();
    g_TrainState = TRAIN_STATE_CRASH;
    CEFChat_SendAll(TRAIN_COLOR_CRASH, "Где-то в Нижегородской области произошло крушение военного поезда...");
    SetTimerEx("TrainCrashOpenBoxes", TRAIN_OPEN_DELAY * 60 * 1000, false, "");
}

stock LoadTrainWagons(locIdx)
{
    new query[64];
    if(locIdx == TRAIN_LOC_LYT) format(query, sizeof(query), "SELECT * FROM `train_wagons_lyt`");
    else format(query, sizeof(query), "SELECT * FROM `train_wagons_rc`");
    mysql_tquery(dbHandle, query, "OnTrainWagonsLoaded", "");
}

public OnTrainWagonsLoaded()
{
    g_TrainWagonCount = 0;
    new rows = cache_num_rows();
    for(new i = 0; i < rows && i < MAX_TRAIN_WAGONS; i++) {
        cache_get_value_name_int(i,   "id",       g_TrainWagon[i][tw_ID]);
        cache_get_value_name_int(i,   "model_id", g_TrainWagon[i][tw_Model]);
        cache_get_value_name_float(i, "x",        g_TrainWagon[i][tw_X]);
        cache_get_value_name_float(i, "y",        g_TrainWagon[i][tw_Y]);
        cache_get_value_name_float(i, "z",        g_TrainWagon[i][tw_Z]);
        cache_get_value_name_float(i, "rx",       g_TrainWagon[i][tw_RX]);
        cache_get_value_name_float(i, "ry",       g_TrainWagon[i][tw_RY]);
        cache_get_value_name_float(i, "rz",       g_TrainWagon[i][tw_RZ]);
        cache_get_value_name(i,       "name",     g_TrainWagon[i][tw_Name], 32);
        g_TrainWagon[i][tw_Object] = 0;
        g_TrainWagonCount++;
    }
    printf("[TrainCrash] Загружено вагонов: %d", g_TrainWagonCount);
    LoadTrainBoxes(g_TrainLocIdx);
}

stock SpawnTrainWagons()
{
    for(new i = 0; i < g_TrainWagonCount; i++) {
        if(g_TrainWagon[i][tw_Object]) { DestroyObject(g_TrainWagon[i][tw_Object]); g_TrainWagon[i][tw_Object] = 0; }
        g_TrainWagon[i][tw_Object] = CreateObject(g_TrainWagon[i][tw_Model],
            g_TrainWagon[i][tw_X], g_TrainWagon[i][tw_Y], g_TrainWagon[i][tw_Z],
            g_TrainWagon[i][tw_RX], g_TrainWagon[i][tw_RY], g_TrainWagon[i][tw_RZ]);
    }
    printf("[TrainCrash] Вагоны заспавнены: %d шт.", g_TrainWagonCount);
}

stock SpawnTrainBoxes()
{
    for(new i = 0; i < g_TrainBoxCount; i++) {
        g_TrainBox[i][tb_Pickup] = CreateDynamicPickup(12730, 23, g_TrainBox[i][tb_X], g_TrainBox[i][tb_Y], g_TrainBox[i][tb_Z]);
        g_TrainBox[i][tb_Area]   = CreateDynamicSphere(g_TrainBox[i][tb_X], g_TrainBox[i][tb_Y], g_TrainBox[i][tb_Z], 3.0);
        g_TrainBox[i][tb_Open]   = false;
        g_TrainBox[i][tb_Opener] = INVALID_PLAYER_ID;
    }
    printf("[TrainCrash] Ящики заспавнены: %d шт.", g_TrainBoxCount);
}

stock StartTrainCrash()
{
    if(g_TrainState != TRAIN_STATE_IDLE) return 0;
    g_TrainState  = TRAIN_STATE_CRASH;
    g_TrainLocIdx = random(2);
    TrainLogS("[Поезд] Старт. Локация: %s", g_TrainLocIdx == TRAIN_LOC_LYT ? "Лыткарино" : "РЦ");
    LoadTrainWagons(g_TrainLocIdx);
    return 1;
}

public TrainCrashOpenBoxes()
{
    g_TrainState = TRAIN_STATE_OPEN;
    SetTimerEx("TrainCrashEnd", 30 * 60 * 1000, false, "");
}

public TrainCrashEnd()
{
    foreach(new i : Player) {
        if(!g_PlayerHasBag[i]) continue;
        g_PlayerHasBag[i] = false;
        DisablePlayerCheckpoint(i);
        if(g_PlayerDeliverPickup[i] != INVALID_DYNAMIC_PICKUP_ID) { DestroyDynamicPickup(g_PlayerDeliverPickup[i]); g_PlayerDeliverPickup[i] = INVALID_DYNAMIC_PICKUP_ID; }
        if(g_PlayerDeliverArea[i] != INVALID_DYNAMIC_AREA) DestroyDynamicArea(g_PlayerDeliverArea[i]);
        CEFChat_Send(i, TRAIN_COLOR_INFO, "Время вышло. Сумка изъята.");
        TrainLogS("[Поезд] Сумка изъята у %s.", PI[i][pName]);
    }
    CEFChat_SendAll(TRAIN_COLOR_INFO, "Крушение военного поезда завершено.");
    TrainCrashCleanup();
    return 1;
}

stock TrainCrashCleanup()
{
    g_TrainState = TRAIN_STATE_IDLE;
    for(new i = 0; i < g_TrainWagonCount; i++) {
        if(g_TrainWagon[i][tw_Object]) { DestroyObject(g_TrainWagon[i][tw_Object]); g_TrainWagon[i][tw_Object] = 0; }
    }
    g_TrainWagonCount = 0;
    for(new i = 0; i < g_TrainBoxCount; i++) {
        if(g_TrainBox[i][tb_Pickup] != INVALID_DYNAMIC_PICKUP_ID) { DestroyDynamicPickup(g_TrainBox[i][tb_Pickup]); g_TrainBox[i][tb_Pickup] = INVALID_DYNAMIC_PICKUP_ID; }
        if(g_TrainBox[i][tb_Area] != INVALID_DYNAMIC_AREA) DestroyDynamicArea(g_TrainBox[i][tb_Area]);
        g_TrainBox[i][tb_Open] = false; g_TrainBox[i][tb_Opener] = INVALID_PLAYER_ID;
    }
    g_TrainBoxCount = 0;
    TrainLog("[Поезд] Очищено.");
}

stock CheckTrainBoxAreas(playerid)
{
    if(g_TrainState != TRAIN_STATE_OPEN) return 0;
    new frac = PI[playerid][pFraction];
    if(frac != TRAIN_FRAC_VCH && frac != TRAIN_FRAC_FSB) return 0;
    for(new i = 0; i < g_TrainBoxCount; i++) {
        if(g_TrainBox[i][tb_Area] == INVALID_DYNAMIC_AREA) continue;
        if(!IsPlayerInDynamicArea(playerid, g_TrainBox[i][tb_Area])) continue;
        if(g_TrainBox[i][tb_Open]) continue;
        g_TrainBox[i][tb_Open]   = true;
        g_TrainBox[i][tb_Opener] = playerid;
        if(g_TrainBox[i][tb_Pickup] != INVALID_DYNAMIC_PICKUP_ID) DestroyDynamicPickup(g_TrainBox[i][tb_Pickup]);
        g_TrainBox[i][tb_Pickup] = CreateDynamicPickup(12735, 23, g_TrainBox[i][tb_X], g_TrainBox[i][tb_Y], g_TrainBox[i][tb_Z]);

        if(!g_PlayerHasBag[playerid]) {
            g_PlayerHasBag[playerid] = true;
            new dIdx = (frac == TRAIN_FRAC_VCH) ? 0 : 1;
            new Float:dx = g_DeliverPoints[dIdx][dv_X];
            new Float:dy = g_DeliverPoints[dIdx][dv_Y];
            new Float:dz = g_DeliverPoints[dIdx][dv_Z];
            g_PlayerDeliverPickup[playerid] = CreateDynamicPickup(11094, 1, dx, dy, dz);
            g_PlayerDeliverArea[playerid]   = CreateDynamicSphere(dx, dy, dz, 3.0);
            SetPlayerCheckpoint(playerid, dx, dy, dz, 3.0);
            CEFChat_Send(playerid, TRAIN_COLOR_INFO, "Вы получили сумку. Доставьте груз на склад.");
            TrainLogS("[Поезд] %s получил сумку.", PI[playerid][pName]);
        }

        new msg[96];
        format(msg, sizeof(msg), "[Поезд] %s вскрыл ящик.", GetName(playerid));
        CEFChat_SendAll(TRAIN_COLOR_INFO, msg);
        return 1;
    }
    return 0;
}


stock CheckTrainDeliverArea(playerid)
{
    if(!g_PlayerHasBag[playerid]) return 0;
    new frac = PI[playerid][pFraction];
    if(frac == TRAIN_FRAC_VCH || frac == TRAIN_FRAC_FSB) {
        if(g_PlayerDeliverArea[playerid] == INVALID_DYNAMIC_AREA) return 0;
        if(!IsPlayerInDynamicArea(playerid, g_PlayerDeliverArea[playerid])) return 0;
    } else {
        new found = 0;
        for(new i = 0; i < sizeof(g_SbytPoints); i++)
            if(IsPlayerInDynamicArea(playerid, g_SbytArea[i])) { found = 1; break; }
        if(!found) return 0;
    }
    PI[playerid][pCash] += TRAIN_REWARD;
    GivePlayerMoney(playerid, TRAIN_REWARD);
    new query[128];
    mysql_format(dbHandle, query, sizeof(query), "UPDATE `accounts` SET `cash`=%d WHERE `id`=%d", PI[playerid][pCash], PI[playerid][pID]);
    mysql_tquery(dbHandle, query, "", "");
    g_PlayerHasBag[playerid] = false;
    DisablePlayerCheckpoint(playerid);
    if(g_PlayerDeliverPickup[playerid] != INVALID_DYNAMIC_PICKUP_ID) { DestroyDynamicPickup(g_PlayerDeliverPickup[playerid]); g_PlayerDeliverPickup[playerid] = INVALID_DYNAMIC_PICKUP_ID; }
    if(g_PlayerDeliverArea[playerid] != INVALID_DYNAMIC_AREA) DestroyDynamicArea(g_PlayerDeliverArea[playerid]);
    UpdatePlayerHUD(playerid);
    new msg[128];
    format(msg, sizeof(msg), "Груз доставлен. Получено %s руб.", SplitInt(TRAIN_REWARD));
    CEFChat_Send(playerid, TRAIN_COLOR_INFO, msg);
    TrainLogS("[Поезд] %s доставил груз.", PI[playerid][pName]);
    return 1;
}

stock CheckTrainCrashTime()
{
    if(g_TrainState != TRAIN_STATE_IDLE) return;
    if((global_hour == TRAIN_TIME_1_H && global_minute == TRAIN_TIME_1_M) ||
       (global_hour == TRAIN_TIME_2_H && global_minute == TRAIN_TIME_2_M) ||
       (global_hour == TRAIN_TIME_3_H && global_minute == TRAIN_TIME_3_M))
        StartTrainCrash();
}

stock InitTrainPlayer(playerid)
{
    g_PlayerHasBag[playerid]        = false;
    g_PlayerDeliverArea[playerid]   = INVALID_DYNAMIC_AREA;
    g_PlayerDeliverPickup[playerid] = INVALID_DYNAMIC_PICKUP_ID;
}


cmd:settbox(playerid, params[])
{
    if(PI[playerid][pAdmin] < 3) return SendErr(playerid, "Нет прав!");
    new locName[4];
    if(sscanf(params, "s[4]", locName)) return SendErr(playerid, "/settbox [lyt/rc]");
    new Float:x, Float:y, Float:z; GetPlayerPos(playerid, x, y, z);
    new query[128], table[24];
    if(strcmp(locName, "lyt", true) == 0) table = "train_boxes_lyt"; else table = "train_boxes_rc";
    mysql_format(dbHandle, query, sizeof(query), "INSERT INTO `%s` (`x`,`y`,`z`) VALUES (%.4f,%.4f,%.4f)", table, x, y, z);
    mysql_tquery(dbHandle, query, "", "");
    CEFChat_Send(playerid, "e69348", "[Admin] Ящик добавлен."); return 1;
}

cmd:deltbox(playerid, params[])
{
    if(PI[playerid][pAdmin] < 3) return SendErr(playerid, "Нет прав!");
    new locName[4], id;
    if(sscanf(params, "s[4]d", locName, id)) return SendErr(playerid, "/deltbox [lyt/rc] [id]");
    new query[96], table[24];
    if(strcmp(locName, "lyt", true) == 0) table = "train_boxes_lyt"; else table = "train_boxes_rc";
    mysql_format(dbHandle, query, sizeof(query), "DELETE FROM `%s` WHERE `id`=%d", table, id);
    mysql_tquery(dbHandle, query, "", "");
    CEFChat_Send(playerid, "e69348", "[Admin] Ящик удалён."); return 1;
}

cmd:startrain(playerid, params[])
{
    if(PI[playerid][pAdmin] < 3) return SendErr(playerid, "Нет прав!");
    if(g_TrainState != TRAIN_STATE_IDLE) return SendErr(playerid, "Событие уже идёт!");
    StartTrainCrash(); return 1;
}

cmd:stoprain(playerid, params[])
{
    if(PI[playerid][pAdmin] < 3) return SendErr(playerid, "Нет прав!");
    TrainCrashCleanup(); return 1;
}

cmd:trainopen(playerid, params[])
{
    if(PI[playerid][pAdmin] < 3) return SendErr(playerid, "Нет прав!");
    if(g_TrainState != TRAIN_STATE_CRASH) return SendErr(playerid, "Не в стадии CRASH!");
    TrainCrashOpenBoxes(); return 1;
}


cmd:trainstate(playerid, params[])
{
    if(PI[playerid][pAdmin] < 1) return SendErr(playerid, "Нет прав!");
    new states[][] = {"IDLE","CRASH","OPEN","BAGS"};
    new msg[80];
    format(msg, sizeof(msg), "State:%s Loc:%d Wagons:%d Boxes:%d", states[g_TrainState], g_TrainLocIdx, g_TrainWagonCount, g_TrainBoxCount);
    CEFChat_Send(playerid, "AAAAAA", msg); return 1;
}

cmd:traintp(playerid, params[])
{
    if(PI[playerid][pAdmin] < 1) return SendErr(playerid, "Нет прав!");
    if(g_TrainLocIdx < 0) return SendErr(playerid, "Событие не активно!");
    if(g_TrainWagonCount > 0) { SetPlayerPos(playerid, g_TrainWagon[0][tw_X], g_TrainWagon[0][tw_Y], g_TrainWagon[0][tw_Z] + 2.0); SetCameraBehindPlayer(playerid); }
    return 1;
}

cmd:traingivebag(playerid, params[])
{
    if(PI[playerid][pAdmin] < 3) return SendErr(playerid, "Нет прав!");
    if(g_PlayerHasBag[playerid]) return SendErr(playerid, "Сумка уже есть!");
    g_PlayerHasBag[playerid] = true;
    g_PlayerDeliverArea[playerid]   = INVALID_DYNAMIC_AREA;
    g_PlayerDeliverPickup[playerid] = INVALID_DYNAMIC_PICKUP_ID;
    CEFChat_Send(playerid, "AAAAAA", "Тестовая сумка выдана."); return 1;
}


cmd:spawnwagon(playerid, params[])
{
    if(PI[playerid][pAdmin] < 4) return SendErr(playerid, "Нет прав!");
    new locName[4], model;
    if(sscanf(params, "s[4]d", locName, model)) model = 12739;
    if(model == 0) model = 12739;
    g_SpawnLoc[playerid]   = strcmp(locName, "rc", true) == 0 ? 1 : 0;
    g_SpawnModel[playerid] = model;
    g_SpawnStep[playerid]  = 0.25;
    if(g_SpawnObj[playerid]) { DestroyObject(g_SpawnObj[playerid]); g_SpawnObj[playerid] = 0; }
    new Float:x, Float:y, Float:z, Float:a;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);
    new Float:rad = a * 0.017453;
    new Float:ox = x + floatsin(rad) * 4.0;
    new Float:oy = y + floatcos(rad) * 4.0;
    g_SpawnObj[playerid] = CreateObject(model, ox, oy, z, 0.0, 0.0, a);
    new msg[96];
    format(msg, sizeof(msg), "[Editor] Вагон %d (%s). /swrot /swp /swm /swstep /swpos /swsave /swrm", model, g_SpawnLoc[playerid] == 0 ? "lyt" : "rc");
    CEFChat_Send(playerid, "e69348", msg);
    return 1;
}

cmd:swrot(playerid, params[])
{
    if(!g_SpawnObj[playerid]) return SendErr(playerid, "Сначала /spawnwagon");
    new Float:rx, Float:ry, Float:rz;
    GetObjectRot(g_SpawnObj[playerid], rx, ry, rz);
    new Float:newRz = rz + 90.0;
    if(newRz >= 360.0) newRz -= 360.0;
    SetObjectRot(g_SpawnObj[playerid], rx, ry, newRz);
    new msg[32]; format(msg, sizeof(msg), "Угол: %.1f", newRz);
    CEFChat_Send(playerid, "AAAAAA", msg); return 1;
}

cmd:swp(playerid, params[])
{
    if(!g_SpawnObj[playerid]) return SendErr(playerid, "Сначала /spawnwagon");
    new Float:x, Float:y, Float:z;
    GetObjectPos(g_SpawnObj[playerid], x, y, z);
    SetObjectPos(g_SpawnObj[playerid], x, y, z + g_SpawnStep[playerid]);
    new msg[32]; format(msg, sizeof(msg), "Z: %.4f", z + g_SpawnStep[playerid]);
    CEFChat_Send(playerid, "AAAAAA", msg); return 1;
}

cmd:swm(playerid, params[])
{
    if(!g_SpawnObj[playerid]) return SendErr(playerid, "Сначала /spawnwagon");
    new Float:x, Float:y, Float:z;
    GetObjectPos(g_SpawnObj[playerid], x, y, z);
    SetObjectPos(g_SpawnObj[playerid], x, y, z - g_SpawnStep[playerid]);
    new msg[32]; format(msg, sizeof(msg), "Z: %.4f", z - g_SpawnStep[playerid]);
    CEFChat_Send(playerid, "AAAAAA", msg); return 1;
}

cmd:swstep(playerid, params[])
{
    new Float:s;
    if(sscanf(params, "f", s) || s <= 0.0) return SendErr(playerid, "/swstep [шаг]");
    g_SpawnStep[playerid] = s;
    new msg[32]; format(msg, sizeof(msg), "Шаг: %.2f", s);
    CEFChat_Send(playerid, "e69348", msg); return 1;
}

cmd:swpos(playerid, params[])
{
    if(!g_SpawnObj[playerid]) return SendErr(playerid, "Нет объекта.");
    new Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz;
    GetObjectPos(g_SpawnObj[playerid], x, y, z);
    GetObjectRot(g_SpawnObj[playerid], rx, ry, rz);
    new msg[128]; format(msg, sizeof(msg), "Pos: %.4f %.4f %.4f | Rot: %.1f", x, y, z, rz);
    CEFChat_Send(playerid, "AAAAAA", msg); return 1;
}

cmd:swsave(playerid, params[])
{
    if(!g_SpawnObj[playerid]) return SendErr(playerid, "Нет объекта.");
    new Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz;
    GetObjectPos(g_SpawnObj[playerid], x, y, z);
    GetObjectRot(g_SpawnObj[playerid], rx, ry, rz);
    new table[24];
    if(g_SpawnLoc[playerid] == 0) table = "train_wagons_lyt"; else table = "train_wagons_rc";
    new query[200];
    mysql_format(dbHandle, query, sizeof(query),
        "INSERT INTO `%s` (`model_id`,`x`,`y`,`z`,`rx`,`ry`,`rz`,`name`) VALUES (%d,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,'vagon')",
        table, g_SpawnModel[playerid], x, y, z, rx, ry, rz);
    mysql_tquery(dbHandle, query, "", "");
    new msg[128]; format(msg, sizeof(msg), "[Admin] Вагон %d сохранён (%s). %.2f %.2f %.2f", g_SpawnModel[playerid], table, x, y, z);
    CEFChat_Send(playerid, "e69348", msg);
    DestroyObject(g_SpawnObj[playerid]); g_SpawnObj[playerid] = 0;
    return 1;
}

cmd:swrm(playerid, params[])
{
    if(g_SpawnObj[playerid]) { DestroyObject(g_SpawnObj[playerid]); g_SpawnObj[playerid] = 0; }
    CEFChat_Send(playerid, "AAAAAA", "[Editor] Вагон удалён."); return 1;
}
