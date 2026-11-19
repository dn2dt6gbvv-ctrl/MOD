



#if defined _avtobus_inc
    #endinput
#endif
#define _avtobus_inc

#include "../include/jobs/skills.pwn"



#define AVTOBUS_TIMER           10
#define AVTOBUS_RENT_PRICE      30000
#define AVTOBUS_EXIT_TIMEOUT    90000
#define AVTOBUS_ZONE_RADIUS     5.0
#define AVTOBUS_DIALOG_START    5000
#define AVTOBUS_MAX_CARS        50
#define AVTOBUS_MAX_ROUTE       200
#define AVTOBUS_MAX_MARSH       20


enum E_AVTOBUS_CAR {
    acID,
    acModel,
    Float:acX,
    Float:acY,
    Float:acZ,
    Float:acAngle,
    acVehicle,
    bool:acUsed,
    Float:acSpawnX,
    Float:acSpawnY,
    Float:acSpawnZ,
    Float:acSpawnAngle,
    acMarshID,
    Text3D:acLabel
}
static g_AvtobusCars[AVTOBUS_MAX_CARS][E_AVTOBUS_CAR];
static g_AvtobusCarCount = 0;

enum E_AVTOBUS_ROUTE_POINT {
    arID,
    arType,
    Float:arX,
    Float:arY,
    Float:arZ,
    arOrder,
    arStopName[64]
}
static g_AvtobusRoutePoints[AVTOBUS_MAX_ROUTE][E_AVTOBUS_ROUTE_POINT];
static g_AvtobusRouteCount = 0;

enum E_AVTOBUS_MARSH {
    amID,
    amName[64],
    amStartIndex,
    amPointCount
}
static g_AvtobusMarsh[AVTOBUS_MAX_MARSH][E_AVTOBUS_MARSH];
static g_AvtobusMarshCount = 0;

static g_AvtobusStopAreas[AVTOBUS_MAX_ROUTE];

enum E_AVTOBUS_PLAYER {
    bool:ap_Working,
    ap_Vehicle,
    ap_MarshID,
    ap_CurrentIndex,
    ap_TimerExit,
    bool:ap_AtStop,
    bool:ap_StopCompleted,
    ap_StopTimer,
    ap_WarningTimer,
    ap_StopArea,
    ap_CarIdx
}
new g_AvtobusPlayer[MAX_PLAYERS][E_AVTOBUS_PLAYER];

static Text3D:g_AvtobusStopLabels[AVTOBUS_MAX_ROUTE];


stock Avtobus_IsWorking(playerid) {
    return g_AvtobusPlayer[playerid][ap_Working];
}


stock Avtobus_DestroyAllStopLabels() {
    for(new i = 0; i < sizeof(g_AvtobusStopLabels); i++) {
        if(g_AvtobusStopLabels[i] != Text3D:INVALID_3DTEXT_ID) {
            DestroyDynamic3DTextLabel(g_AvtobusStopLabels[i]);
            g_AvtobusStopLabels[i] = Text3D:INVALID_3DTEXT_ID;
        }
    }
}

stock Avtobus_RefreshAllStopLabels() {
    Avtobus_DestroyAllStopLabels();
    for(new i = 0; i < g_AvtobusRouteCount; i++) {
        if(g_AvtobusRoutePoints[i][arType] == 2 && strlen(g_AvtobusRoutePoints[i][arStopName]) > 0) {
            new text[256];
            format(text, sizeof(text),
                "{FF8C00}Остановка\n{FFFFFF}%s\n{8DA629}посмотреть маршрут = /route",
                g_AvtobusRoutePoints[i][arStopName]);
            g_AvtobusStopLabels[i] = CreateDynamic3DTextLabel(text, 0xFFFFFFFF,
                g_AvtobusRoutePoints[i][arX],
                g_AvtobusRoutePoints[i][arY],
                g_AvtobusRoutePoints[i][arZ] + 1.0,
                15.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID,
                0, 0, 0, -1, 20.0);
        }
    }
}


stock Avtobus_CreateCarLabel(carIdx) {
    if(carIdx < 0 || carIdx >= g_AvtobusCarCount) return;
    if(!IsValidVehicle(g_AvtobusCars[carIdx][acVehicle])) return;

    if(g_AvtobusCars[carIdx][acLabel] != Text3D:INVALID_3DTEXT_ID) {
        DestroyDynamic3DTextLabel(g_AvtobusCars[carIdx][acLabel]);
        g_AvtobusCars[carIdx][acLabel] = Text3D:INVALID_3DTEXT_ID;
    }
    new marshName[64] = "неизвестный";
    for(new j = 0; j < g_AvtobusMarshCount; j++) {
        if(g_AvtobusMarsh[j][amID] == g_AvtobusCars[carIdx][acMarshID]) {
            format(marshName, sizeof(marshName), "%s", g_AvtobusMarsh[j][amName]);
            break;
        }
    }
    new text[128];
    format(text, sizeof(text),
        "Автобус\nпроезд бесплатный\nМаршрут: %s",
        marshName);
    g_AvtobusCars[carIdx][acLabel] = CreateDynamic3DTextLabel(text, 0xFFFFFFFF,
        0.0, 0.0, 1.2,
        15.0, INVALID_PLAYER_ID, g_AvtobusCars[carIdx][acVehicle],
        0, 0, 0, -1, 20.0);
}

stock Avtobus_DeleteCarLabel(carIdx) {
    if(carIdx < 0 || carIdx >= g_AvtobusCarCount) return;
    if(g_AvtobusCars[carIdx][acLabel] != Text3D:INVALID_3DTEXT_ID) {
        DestroyDynamic3DTextLabel(g_AvtobusCars[carIdx][acLabel]);
        g_AvtobusCars[carIdx][acLabel] = Text3D:INVALID_3DTEXT_ID;
    }
}


stock Avtobus_GetRoutePoints(marshID, &startIdx, &count) {
    for(new i = 0; i < g_AvtobusMarshCount; i++) {
        if(g_AvtobusMarsh[i][amID] == marshID) {
            startIdx = g_AvtobusMarsh[i][amStartIndex];
            count = g_AvtobusMarsh[i][amPointCount];
            return 1;
        }
    }
    return 0;
}

stock Avtobus_RespawnCar(carIdx) {
    if(carIdx < 0 || carIdx >= g_AvtobusCarCount) return;
    Avtobus_DeleteCarLabel(carIdx);
    new veh = g_AvtobusCars[carIdx][acVehicle];
    if(!IsValidVehicle(veh)) {
        new newveh = CreateVehicle(g_AvtobusCars[carIdx][acModel],
            g_AvtobusCars[carIdx][acSpawnX],
            g_AvtobusCars[carIdx][acSpawnY],
            g_AvtobusCars[carIdx][acSpawnZ],
            g_AvtobusCars[carIdx][acSpawnAngle],
            1, 1, -1);
        g_AvtobusCars[carIdx][acVehicle] = newveh;
        if(CI[newveh][Fuel] != -1) CI[newveh][Fuel] = 100;
        g_AvtobusCars[carIdx][acUsed] = false;
    } else {
        SetVehiclePos(veh,
            g_AvtobusCars[carIdx][acSpawnX],
            g_AvtobusCars[carIdx][acSpawnY],
            g_AvtobusCars[carIdx][acSpawnZ]);
        SetVehicleZAngle(veh, g_AvtobusCars[carIdx][acSpawnAngle]);
        SetVehicleHealth(veh, 1000.0);
        RepairVehicle(veh);
        if(CI[veh][Fuel] != -1) CI[veh][Fuel] = 100;
        g_AvtobusCars[carIdx][acUsed] = false;
    }
}

stock Avtobus_StopAllWorkers(marshID = -1) {
    for(new i = 0; i < MAX_PLAYERS; i++) {
        if(IsPlayerConnected(i) && g_AvtobusPlayer[i][ap_Working]) {
            if(marshID == -1 || g_AvtobusPlayer[i][ap_MarshID] == marshID) {
                Avtobus_StopWork(i);
                CEFChat_Send(i, "FF4444", "Маршрут был изменён. Ваша работа завершена.");
            }
        }
    }
}


forward LoadAvtobusSystem();
public LoadAvtobusSystem() {
    mysql_tquery(dbHandle, "SELECT * FROM `avtobus_marsh`", "OnAvtobusMarshLoaded", "");
    mysql_tquery(dbHandle, "SELECT * FROM `avtobus_cars`", "OnAvtobusCarsLoaded", "");
    mysql_tquery(dbHandle, "SELECT * FROM `avtobus_route` ORDER BY `order` ASC", "OnAvtobusRouteLoaded", "");
    printf("[Avtobus] Система загружается...");
    printf("[Avtobus] Загружено точек маршрута: %d", g_AvtobusRouteCount);
    for(new i = 0; i < g_AvtobusRouteCount; i++) {
    printf("  Точка %d: тип=%d, X=%.2f, Y=%.2f, название=%s",
            i,
            g_AvtobusRoutePoints[i][arType],
            g_AvtobusRoutePoints[i][arX],
            g_AvtobusRoutePoints[i][arY],
            g_AvtobusRoutePoints[i][arStopName]
        );
    }
    return 1;
}

forward OnAvtobusMarshLoaded();
public OnAvtobusMarshLoaded() {
    new rows = cache_num_rows();
    g_AvtobusMarshCount = 0;
    for(new i = 0; i < rows && i < AVTOBUS_MAX_MARSH; i++) {
        new id, startIdx, pointCount;
        new name[64];
        cache_get_value_name_int(i, "id", id);
        cache_get_value_name(i, "name", name, 64);
        cache_get_value_name_int(i, "start_index", startIdx);
        cache_get_value_name_int(i, "point_count", pointCount);

        g_AvtobusMarsh[g_AvtobusMarshCount][amID] = id;
        format(g_AvtobusMarsh[g_AvtobusMarshCount][amName], 64, "%s", name);
        g_AvtobusMarsh[g_AvtobusMarshCount][amStartIndex] = startIdx;
        g_AvtobusMarsh[g_AvtobusMarshCount][amPointCount] = pointCount;
        g_AvtobusMarshCount++;
    }
    printf("[Avtobus] Загружено %d маршрутов.", g_AvtobusMarshCount);
    return 1;
}

forward OnAvtobusCarsLoaded();
public OnAvtobusCarsLoaded() {
    for(new i = 0; i < g_AvtobusCarCount; i++) {
        Avtobus_DeleteCarLabel(i);
        if(IsValidVehicle(g_AvtobusCars[i][acVehicle])) {
            DestroyVehicle(g_AvtobusCars[i][acVehicle]);
        }
    }
    g_AvtobusCarCount = 0;

    new rows = cache_num_rows();
    for(new i = 0; i < rows && i < AVTOBUS_MAX_CARS; i++) {
        new id, model, marshID;
        new Float:x, Float:y, Float:z, Float:angle;
        cache_get_value_name_int(i, "id", id);
        cache_get_value_name_int(i, "model", model);
        cache_get_value_name_float(i, "x", x);
        cache_get_value_name_float(i, "y", y);
        cache_get_value_name_float(i, "z", z);
        cache_get_value_name_float(i, "angle", angle);
        cache_get_value_name_int(i, "marsh_id", marshID);

        g_AvtobusCars[g_AvtobusCarCount][acID] = id;
        g_AvtobusCars[g_AvtobusCarCount][acModel] = model;
        g_AvtobusCars[g_AvtobusCarCount][acX] = x;
        g_AvtobusCars[g_AvtobusCarCount][acY] = y;
        g_AvtobusCars[g_AvtobusCarCount][acZ] = z;
        g_AvtobusCars[g_AvtobusCarCount][acAngle] = angle;
        g_AvtobusCars[g_AvtobusCarCount][acMarshID] = marshID;

        g_AvtobusCars[g_AvtobusCarCount][acSpawnX] = x;
        g_AvtobusCars[g_AvtobusCarCount][acSpawnY] = y;
        g_AvtobusCars[g_AvtobusCarCount][acSpawnZ] = z;
        g_AvtobusCars[g_AvtobusCarCount][acSpawnAngle] = angle;

        new veh = CreateVehicle(model, x, y, z, angle, 1, 1, -1);
        g_AvtobusCars[g_AvtobusCarCount][acVehicle] = veh;
        g_AvtobusCars[g_AvtobusCarCount][acUsed] = false;
        if(CI[veh][Fuel] != -1) CI[veh][Fuel] = 100;
        g_AvtobusCars[g_AvtobusCarCount][acLabel] = Text3D:INVALID_3DTEXT_ID;
        g_AvtobusCarCount++;
    }
    printf("[Avtobus] Загружено %d автобусов.", g_AvtobusCarCount);
    return 1;
}

forward OnAvtobusRouteLoaded();
public OnAvtobusRouteLoaded() {
    Avtobus_StopAllWorkers();
    for(new i = 0; i < sizeof(g_AvtobusStopAreas); i++) {
        if(g_AvtobusStopAreas[i] != -1) {
            DestroyDynamicArea(g_AvtobusStopAreas[i]);
            g_AvtobusStopAreas[i] = -1;
        }
    }
    Avtobus_DestroyAllStopLabels();
    new rows = cache_num_rows();
    g_AvtobusRouteCount = 0;
    for(new i = 0; i < rows && i < AVTOBUS_MAX_ROUTE; i++) {
        new id, type, order;
        new Float:x, Float:y, Float:z;
        new stopName[64];
        cache_get_value_name_int(i, "id", id);
        cache_get_value_name_int(i, "type", type);
        cache_get_value_name_float(i, "x", x);
        cache_get_value_name_float(i, "y", y);
        cache_get_value_name_float(i, "z", z);
        cache_get_value_name_int(i, "order", order);
        cache_get_value_name(i, "stop_name", stopName, 64);

        g_AvtobusRoutePoints[g_AvtobusRouteCount][arID] = id;
        g_AvtobusRoutePoints[g_AvtobusRouteCount][arType] = type;
        g_AvtobusRoutePoints[g_AvtobusRouteCount][arX] = x;
        g_AvtobusRoutePoints[g_AvtobusRouteCount][arY] = y;
        g_AvtobusRoutePoints[g_AvtobusRouteCount][arZ] = z;
        g_AvtobusRoutePoints[g_AvtobusRouteCount][arOrder] = order;
        format(g_AvtobusRoutePoints[g_AvtobusRouteCount][arStopName], 64, "%s", stopName);
        g_AvtobusRouteCount++;
    }
    for(new i = 0; i < g_AvtobusRouteCount; i++) {
        if(g_AvtobusRoutePoints[i][arType] == 2) {
            g_AvtobusStopAreas[i] = CreateDynamicSphere(
                g_AvtobusRoutePoints[i][arX],
                g_AvtobusRoutePoints[i][arY],
                g_AvtobusRoutePoints[i][arZ],
                Float:AVTOBUS_ZONE_RADIUS, 0, 0, -1);
        } else {
            g_AvtobusStopAreas[i] = -1;
        }
    }
    Avtobus_RefreshAllStopLabels();
    printf("[Avtobus] Загружено %d точек маршрута.", g_AvtobusRouteCount);
    return 1;
}





CMD:addavtobusmarsh(playerid, params[]) {
    if(PI[playerid][pAdmin] < 6) return CEFChat_Send(playerid, "FF4444", "Нет прав.");
    new name[64];
    if(sscanf(params, "s[64]", name)) {
        CEFChat_Send(playerid, "FF4444", "Использование: /addavtobusmarsh [название маршрута]");
        return 1;
    }
    new query[256];
    mysql_format(dbHandle, query, sizeof(query),
        "INSERT INTO `avtobus_marsh` (`name`, `start_index`, `point_count`) VALUES ('%e', 0, 0)",
        name);
    mysql_tquery(dbHandle, query, "OnAvtobusMarshAdded", "i", playerid);
    return 1;
}

forward OnAvtobusMarshAdded(playerid);
public OnAvtobusMarshAdded(playerid) {
    new id = cache_insert_id();
    new msg[128];
    format(msg, sizeof(msg), "Маршрут создан. ID: %d", id);
    CEFChat_Send(playerid, "54B367", msg);
    mysql_tquery(dbHandle, "SELECT * FROM `avtobus_marsh`", "OnAvtobusMarshLoaded", "");
    return 1;
}

CMD:addcaravtobus(playerid, params[]) {
    if(PI[playerid][pAdmin] < 6) return CEFChat_Send(playerid, "FF4444", "Нет прав.");
    new model, marshID;
    if(sscanf(params, "dd", model, marshID)) {
        CEFChat_Send(playerid, "FF4444", "Использование: /addcaravtobus [model] [id маршрута]");
        return 1;
    }
    new found = 0;
    for(new i = 0; i < g_AvtobusMarshCount; i++) {
        if(g_AvtobusMarsh[i][amID] == marshID) { found = 1; break; }
    }
    if(!found) {
        CEFChat_Send(playerid, "FF4444", "Маршрут с таким ID не найден.");
        return 1;
    }
    new Float:x, Float:y, Float:z, Float:angle;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, angle);
    new query[256];
    mysql_format(dbHandle, query, sizeof(query),
        "INSERT INTO `avtobus_cars` (`model`, `x`, `y`, `z`, `angle`, `marsh_id`) VALUES (%d, %.4f, %.4f, %.4f, %.4f, %d)",
        model, x, y, z, angle, marshID);
    mysql_tquery(dbHandle, query, "OnAvtobusCarAdded", "i", playerid);
    return 1;
}

forward OnAvtobusCarAdded(playerid);
public OnAvtobusCarAdded(playerid) {
    CEFChat_Send(playerid, "54B367", "Автобус добавлен. Используйте /reloadavtobus [id] для применения.");
    mysql_tquery(dbHandle, "SELECT * FROM `avtobus_cars`", "OnAvtobusCarsLoaded", "");
    return 1;
}

CMD:addchipavtobus(playerid, params[]) {
    if(PI[playerid][pAdmin] < 6) return CEFChat_Send(playerid, "FF4444", "Нет прав.");
    new marshID, type;
    if(sscanf(params, "dd", marshID, type) || (type != 1 && type != 2)) {
        CEFChat_Send(playerid, "FF4444", "Использование: /addchipavtobus [id маршрута] [1 - чекпоинт | 2 - остановка]");
        return 1;
    }
    new found = 0, idx = -1;
    for(new i = 0; i < g_AvtobusMarshCount; i++) {
        if(g_AvtobusMarsh[i][amID] == marshID) { found = 1; idx = i; break; }
    }
    if(!found) {
        CEFChat_Send(playerid, "FF4444", "Маршрут с таким ID не найден.");
        return 1;
    }
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    new order = g_AvtobusMarsh[idx][amStartIndex] + g_AvtobusMarsh[idx][amPointCount] + 1;
    new query[256];
    mysql_format(dbHandle, query, sizeof(query),
        "INSERT INTO `avtobus_route` (`type`, `x`, `y`, `z`, `order`, `stop_name`) VALUES (%d, %.4f, %.4f, %.4f, %d, '')",
        type, x, y, z, order);
    mysql_tquery(dbHandle, query, "OnAvtobusChipAdded", "ii", playerid, marshID);
    return 1;
}

forward OnAvtobusChipAdded(playerid, marshID);
public OnAvtobusChipAdded(playerid, marshID) {
    new count = 0;
    for(new i = 0; i < g_AvtobusMarshCount; i++) {
        if(g_AvtobusMarsh[i][amID] == marshID) {
            count = g_AvtobusMarsh[i][amPointCount] + 1;
            new query[128];
            mysql_format(dbHandle, query, sizeof(query),
                "UPDATE `avtobus_marsh` SET `point_count`=%d WHERE `id`=%d",
                count, marshID);
            mysql_tquery(dbHandle, query, "", "");
            break;
        }
    }
    CEFChat_Send(playerid, "54B367", "Точка добавлена. Используйте /reloadavtobus [id] для применения.");
    mysql_tquery(dbHandle, "SELECT * FROM `avtobus_route` ORDER BY `order` ASC", "OnAvtobusRouteLoaded", "");
    mysql_tquery(dbHandle, "SELECT * FROM `avtobus_marsh`", "OnAvtobusMarshLoaded", "");
    return 1;
}

CMD:addastavtobus(playerid, params[]) {
    if(PI[playerid][pAdmin] < 6) return CEFChat_Send(playerid, "FF4444", "Нет прав.");
    new marshID, name[64];
    if(sscanf(params, "ds[64]", marshID, name)) {
        CEFChat_Send(playerid, "FF4444", "Использование: /addastavtobus [id маршрута] [название остановки]");
        return 1;
    }
    new startIdx, count;
    if(!Avtobus_GetRoutePoints(marshID, startIdx, count)) {
        CEFChat_Send(playerid, "FF4444", "Маршрут не найден.");
        return 1;
    }
    new found = 0;
    for(new i = startIdx + count - 1; i >= startIdx; i--) {
        if(g_AvtobusRoutePoints[i][arType] == 2 && strlen(g_AvtobusRoutePoints[i][arStopName]) == 0) {
            new query[256];
            mysql_format(dbHandle, query, sizeof(query),
                "UPDATE `avtobus_route` SET `stop_name`='%e' WHERE `id`=%d",
                name, g_AvtobusRoutePoints[i][arID]);
            mysql_tquery(dbHandle, query, "OnAvtobusStopNameAdded", "i", playerid);
            found = 1;
            break;
        }
    }
    if(!found) {
        CEFChat_Send(playerid, "FF4444", "В этом маршруте нет остановок без названия.");
        return 1;
    }
    return 1;
}

forward OnAvtobusStopNameAdded(playerid);
public OnAvtobusStopNameAdded(playerid) {
    mysql_tquery(dbHandle, "SELECT * FROM `avtobus_route` ORDER BY `order` ASC", "OnAvtobusRouteLoaded", "");
    CEFChat_Send(playerid, "54B367", "Название остановки сохранено и отображается в мире.");
    return 1;
}

CMD:reloadavtobus(playerid, params[]) {
    if(PI[playerid][pAdmin] < 6) return CEFChat_Send(playerid, "FF4444", "Нет прав.");
    new marshID;
    if(sscanf(params, "d", marshID)) {
        CEFChat_Send(playerid, "FF4444", "Использование: /reloadavtobus [id маршрута]");
        return 1;
    }
    Avtobus_StopAllWorkers(marshID);
    mysql_tquery(dbHandle, "SELECT * FROM `avtobus_cars`", "OnAvtobusCarsLoaded", "");
    mysql_tquery(dbHandle, "SELECT * FROM `avtobus_route` ORDER BY `order` ASC", "OnAvtobusRouteLoaded", "");
    mysql_tquery(dbHandle, "SELECT * FROM `avtobus_marsh`", "OnAvtobusMarshLoaded", "");
    new msg[128];
    format(msg, sizeof(msg), "Маршрут %d перезагружен. Все водители остановлены.", marshID);
    CEFChat_Send(playerid, "54B367", msg);
    return 1;
}

CMD:listavtobuscars(playerid, params[]) {
    if(PI[playerid][pAdmin] < 6) return CEFChat_Send(playerid, "FF4444", "Нет прав.");
    if(g_AvtobusCarCount == 0) {
        CEFChat_Send(playerid, "FF4444", "Автобусов нет.");
        return 1;
    }
    new str[1024], line[128];
    format(str, sizeof(str), "Автобусы:\n");
    for(new i = 0; i < g_AvtobusCarCount && strlen(str) < 900; i++) {
        format(line, sizeof(line), "ID:%d | Модель:%d | Маршрут:%d | X:%.2f Y:%.2f | Статус:%s\n",
            g_AvtobusCars[i][acID],
            g_AvtobusCars[i][acModel],
            g_AvtobusCars[i][acMarshID],
            g_AvtobusCars[i][acX],
            g_AvtobusCars[i][acY],
            g_AvtobusCars[i][acUsed] ? "Занят" : "Свободен");
        strcat(str, line);
    }
    ShowPlayerDialogEx(playerid, 0, DIALOG_STYLE_MSGBOX, "Автобусы", str, "Закрыть", "");
    return 1;
}

CMD:delavtobuscar(playerid, params[]) {
    if(PI[playerid][pAdmin] < 6) return CEFChat_Send(playerid, "FF4444", "Нет прав.");
    new id;
    if(sscanf(params, "d", id)) {
        CEFChat_Send(playerid, "FF4444", "Использование: /delavtobuscar [id] (ID из /listavtobuscars)");
        return 1;
    }
    new idx = -1;
    for(new i = 0; i < g_AvtobusCarCount; i++) {
        if(g_AvtobusCars[i][acID] == id) { idx = i; break; }
    }
    if(idx == -1) {
        CEFChat_Send(playerid, "FF4444", "Автобус с таким ID не найден.");
        return 1;
    }
    if(g_AvtobusCars[idx][acUsed]) {
        for(new p = 0; p < MAX_PLAYERS; p++) {
            if(IsPlayerConnected(p) && g_AvtobusPlayer[p][ap_Working] && g_AvtobusPlayer[p][ap_Vehicle] == g_AvtobusCars[idx][acVehicle]) {
                Avtobus_StopWork(p);
                CEFChat_Send(p, "FF4444", "Ваш автобус удалён администратором.");
                break;
            }
        }
    }
    Avtobus_DeleteCarLabel(idx);
    DestroyVehicle(g_AvtobusCars[idx][acVehicle]);
    new query[128];
    mysql_format(dbHandle, query, sizeof(query), "DELETE FROM `avtobus_cars` WHERE `id`=%d", id);
    mysql_tquery(dbHandle, query, "OnAvtobusCarDeleted", "i", playerid);
    return 1;
}

forward OnAvtobusCarDeleted(playerid);
public OnAvtobusCarDeleted(playerid) {
    CEFChat_Send(playerid, "54B367", "Автобус удалён из БД. Используйте /reloadavtobus [id] для применения.");
    mysql_tquery(dbHandle, "SELECT * FROM `avtobus_cars`", "OnAvtobusCarsLoaded", "");
    return 1;
}

CMD:listavtobusmarsh(playerid, params[]) {
    if(PI[playerid][pAdmin] < 6) return CEFChat_Send(playerid, "FF4444", "Нет прав.");
    if(g_AvtobusMarshCount == 0) {
        CEFChat_Send(playerid, "FF4444", "Маршрутов нет.");
        return 1;
    }
    new str[1024], line[128];
    format(str, sizeof(str), "Маршруты:\n");
    for(new i = 0; i < g_AvtobusMarshCount && strlen(str) < 900; i++) {
        format(line, sizeof(line), "ID:%d | Название:%s | Точек:%d\n",
            g_AvtobusMarsh[i][amID],
            g_AvtobusMarsh[i][amName],
            g_AvtobusMarsh[i][amPointCount]);
        strcat(str, line);
    }
    ShowPlayerDialogEx(playerid, 0, DIALOG_STYLE_MSGBOX, "Маршруты", str, "Закрыть", "");
    return 1;
}

CMD:delavtobusmarsh(playerid, params[]) {
    if(PI[playerid][pAdmin] < 6) return CEFChat_Send(playerid, "FF4444", "Нет прав.");
    new marshID;
    if(sscanf(params, "d", marshID)) {
        CEFChat_Send(playerid, "FF4444", "Использование: /delavtobusmarsh [id]");
        return 1;
    }
    new hasCars = 0;
    for(new i = 0; i < g_AvtobusCarCount; i++) {
        if(g_AvtobusCars[i][acMarshID] == marshID) { hasCars = 1; break; }
    }
    if(hasCars) {
        CEFChat_Send(playerid, "FF4444", "Сначала удалите все автобусы на этом маршруте (/delavtobuscar).");
        return 1;
    }
    new query[128];
    mysql_format(dbHandle, query, sizeof(query), "DELETE FROM `avtobus_marsh` WHERE `id`=%d", marshID);
    mysql_tquery(dbHandle, query, "OnAvtobusMarshDeleted", "i", playerid);
    return 1;
}

forward OnAvtobusMarshDeleted(playerid);
public OnAvtobusMarshDeleted(playerid) {
    CEFChat_Send(playerid, "54B367", "Маршрут удалён.");
    mysql_tquery(dbHandle, "SELECT * FROM `avtobus_marsh`", "OnAvtobusMarshLoaded", "");
    return 1;
}


stock Avtobus_StartWork(playerid, vehicleid) {
    if(g_AvtobusPlayer[playerid][ap_Working]) return 0;
    new carIdx = -1;
    for(new i = 0; i < g_AvtobusCarCount; i++) {
        if(g_AvtobusCars[i][acVehicle] == vehicleid) { carIdx = i; break; }
    }
    if(carIdx == -1) return 0;
    if(g_AvtobusCars[carIdx][acUsed]) {
        CEFChat_Send(playerid, "FF4444", "Этот автобус уже занят.");
        return 0;
    }
    if(PI[playerid][pCash] < AVTOBUS_RENT_PRICE) {
        new msg[128];
        format(msg, sizeof(msg), "У вас недостаточно денег для аренды автобуса (нужно %d руб.)", AVTOBUS_RENT_PRICE);
        CEFChat_Send(playerid, "FF4444", msg);
        return 0;
    }
    new marshID = g_AvtobusCars[carIdx][acMarshID];
    new startIdx, count;
    if(!Avtobus_GetRoutePoints(marshID, startIdx, count) || count == 0) {
        CEFChat_Send(playerid, "FF4444", "Маршрут для этого автобуса ещё не добавлен.");
        return 0;
    }

    PI[playerid][pCash] -= AVTOBUS_RENT_PRICE;
    GivePlayerMoney(playerid, -AVTOBUS_RENT_PRICE);
    UpdatePlayerHUD(playerid);
    new query[128];
    mysql_format(dbHandle, query, sizeof(query), "UPDATE `accounts` SET `cash`=%d WHERE `id`=%d", PI[playerid][pCash], PI[playerid][pID]);
    mysql_tquery(dbHandle, query, "", "");

    g_AvtobusCars[carIdx][acUsed] = true;
    g_AvtobusPlayer[playerid][ap_Working] = true;
    g_AvtobusPlayer[playerid][ap_Vehicle] = vehicleid;
    g_AvtobusPlayer[playerid][ap_MarshID] = marshID;
    g_AvtobusPlayer[playerid][ap_CurrentIndex] = 0;
    g_AvtobusPlayer[playerid][ap_TimerExit] = -1;
    g_AvtobusPlayer[playerid][ap_AtStop] = false;
    g_AvtobusPlayer[playerid][ap_StopCompleted] = false;
    g_AvtobusPlayer[playerid][ap_StopTimer] = -1;
    g_AvtobusPlayer[playerid][ap_WarningTimer] = -1;
    g_AvtobusPlayer[playerid][ap_StopArea] = -1;
    g_AvtobusPlayer[playerid][ap_CarIdx] = carIdx;

    Avtobus_CreateCarLabel(carIdx);

    Avtobus_SetCheckpoint(playerid, startIdx + 0);
    CEFChat_Send(playerid, "54B367", "Вы начали работу водителем автобуса. Следуйте к синей метке.");
    CEFChat_Send(playerid, "AAAAAA", "За чекпоинт +40000 руб., за остановку +40000 руб.");
    SendSuccess(playerid, "Работа начата", "Вы приступили к работе водителем автобуса.");
    return 1;
}

stock Avtobus_StopWork(playerid) {
    if(!g_AvtobusPlayer[playerid][ap_Working]) return;
    if(g_AvtobusPlayer[playerid][ap_TimerExit] != -1) {
        KillTimer(g_AvtobusPlayer[playerid][ap_TimerExit]);
        g_AvtobusPlayer[playerid][ap_TimerExit] = -1;
    }
    if(g_AvtobusPlayer[playerid][ap_StopTimer] != -1) {
        KillTimer(g_AvtobusPlayer[playerid][ap_StopTimer]);
        g_AvtobusPlayer[playerid][ap_StopTimer] = -1;
    }
    if(g_AvtobusPlayer[playerid][ap_WarningTimer] != -1) {
        KillTimer(g_AvtobusPlayer[playerid][ap_WarningTimer]);
        g_AvtobusPlayer[playerid][ap_WarningTimer] = -1;
    }
    DisablePlayerCheckpoint(playerid);
    Avtobus_HideWidget(playerid);
    DestroyJobWidget(playerid);
    new veh = g_AvtobusPlayer[playerid][ap_Vehicle];
    if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER && GetPlayerVehicleID(playerid) == veh) {
        new Float:x, Float:y, Float:z;
        GetPlayerPos(playerid, x, y, z);
        RemovePlayerFromVehicle(playerid);
        SetPlayerPos(playerid, x, y, z);
        new Float:angle;
        GetPlayerFacingAngle(playerid, angle);
        SetPlayerFacingAngle(playerid, angle);
    }
    new carIdx = g_AvtobusPlayer[playerid][ap_CarIdx];
    if(carIdx != -1 && carIdx < g_AvtobusCarCount) {
        Avtobus_DeleteCarLabel(carIdx);
        Avtobus_RespawnCar(carIdx);
    }
    g_AvtobusPlayer[playerid][ap_Working] = false;
    g_AvtobusPlayer[playerid][ap_Vehicle] = INVALID_VEHICLE_ID;
    g_AvtobusPlayer[playerid][ap_MarshID] = 0;
    g_AvtobusPlayer[playerid][ap_CurrentIndex] = 0;
    g_AvtobusPlayer[playerid][ap_AtStop] = false;
    g_AvtobusPlayer[playerid][ap_StopCompleted] = false;
    g_AvtobusPlayer[playerid][ap_StopArea] = -1;
    g_AvtobusPlayer[playerid][ap_CarIdx] = -1;
    CEFChat_Send(playerid, "AAAAAA", "Работа водителем автобуса завершена.");
}

stock Avtobus_SetCheckpoint(playerid, routeIndex) {
    DisablePlayerCheckpoint(playerid);
    new startIdx, count;
    Avtobus_GetRoutePoints(g_AvtobusPlayer[playerid][ap_MarshID], startIdx, count);
    if(routeIndex >= startIdx + count) {
        CEFChat_Send(playerid, "54B367", "Вы завершили полный маршрут! Начинаем новый круг.");
        g_AvtobusPlayer[playerid][ap_CurrentIndex] = 0;
        routeIndex = startIdx + 0;
    }
    if(routeIndex < startIdx || routeIndex >= startIdx + count) {
        routeIndex = startIdx;
    }
    new Float:x = g_AvtobusRoutePoints[routeIndex][arX];
    new Float:y = g_AvtobusRoutePoints[routeIndex][arY];
    new Float:z = g_AvtobusRoutePoints[routeIndex][arZ];
    SetPlayerCheckpoint(playerid, x, y, z, AVTOBUS_ZONE_RADIUS);
}

stock Avtobus_ShowStopWidget(playerid) {
    if(g_AvtobusPlayer[playerid][ap_StopTimer] != -1) return;
    DestroyJobWidget(playerid);
    g_AvtobusPlayer[playerid][ap_AtStop] = true;
    g_AvtobusPlayer[playerid][ap_StopCompleted] = false;

    cef_create_browser(playerid, AVTOBUS_BROWSER, AVTOBUS_CEF_LINK, true, false);
    cef_always_listen_keys(playerid, AVTOBUS_BROWSER, false);
    cef_focus_browser(playerid, AVTOBUS_BROWSER, false);
    cef_emit_event(playerid, "game:showCursor", CEFINT(0));
    cef_hide_browser(playerid, AVTOBUS_BROWSER, false);

    g_AvtobusPlayer[playerid][ap_StopTimer] = SetTimerEx("Avtobus_StopTimerEnd", AVTOBUS_TIMER * 1000, false, "i", playerid);
}

stock Avtobus_HideWidget(playerid) {
    cef_destroy_browser(playerid, AVTOBUS_BROWSER);
    cef_emit_event(playerid, "game:showCursor", CEFINT(0));
    if(g_AvtobusPlayer[playerid][ap_StopTimer] != -1) {
        KillTimer(g_AvtobusPlayer[playerid][ap_StopTimer]);
        g_AvtobusPlayer[playerid][ap_StopTimer] = -1;
    }
    g_AvtobusPlayer[playerid][ap_AtStop] = false;
}


stock Avtobus_FinishStop(playerid) {
    if(g_AvtobusPlayer[playerid][ap_StopCompleted]) return;
    g_AvtobusPlayer[playerid][ap_StopCompleted] = true;
    g_AvtobusPlayer[playerid][ap_AtStop] = false;

    new basePay = AVTOBUS_PAY_PER_STOP;
    new bonusPerLevel = 7500;
    new pay = Skill_GetRewardBonus(playerid, SKILL_BUS, basePay, bonusPerLevel);

    PI[playerid][pCash] += pay;
    GivePlayerMoney(playerid, pay);
    UpdatePlayerHUD(playerid);
    new query[128];
    mysql_format(dbHandle, query, sizeof(query), "UPDATE `accounts` SET `cash`=%d WHERE `id`=%d", PI[playerid][pCash], PI[playerid][pID]);
    mysql_tquery(dbHandle, query, "", "");


    Skill_AddProgress(playerid, SKILL_BUS, 1);

    new msg[64];
    format(msg, sizeof(msg), "Остановка засчитана! +%d руб.", pay);
    CEFChat_Send(playerid, "54B367", msg);
    Avtobus_HideWidget(playerid);
    new startIdx, count;
    Avtobus_GetRoutePoints(g_AvtobusPlayer[playerid][ap_MarshID], startIdx, count);
    g_AvtobusPlayer[playerid][ap_CurrentIndex]++;
    if(g_AvtobusPlayer[playerid][ap_CurrentIndex] >= count) {
        g_AvtobusPlayer[playerid][ap_CurrentIndex] = 0;
    }
    Avtobus_SetCheckpoint(playerid, startIdx + g_AvtobusPlayer[playerid][ap_CurrentIndex]);
}


forward Avtobus_StopTimerEnd(playerid);
public Avtobus_StopTimerEnd(playerid) {
    if(!IsPlayerConnected(playerid)) return;
    g_AvtobusPlayer[playerid][ap_StopTimer] = -1;

    new bool:stillInZone = false;
    new area = g_AvtobusPlayer[playerid][ap_StopArea];
    if(area != -1 && IsPlayerInDynamicArea(playerid, area)) {
        stillInZone = true;
    }
    if(g_AvtobusPlayer[playerid][ap_AtStop] && !g_AvtobusPlayer[playerid][ap_StopCompleted] && stillInZone) {
        Avtobus_FinishStop(playerid);
    } else {
        if(g_AvtobusPlayer[playerid][ap_AtStop]) {
            CEFChat_Send(playerid, "FF4444", "Вы покинули остановку раньше времени! Остановка не засчитана.");
        }
        Avtobus_HideWidget(playerid);
        new startIdx, count;
        Avtobus_GetRoutePoints(g_AvtobusPlayer[playerid][ap_MarshID], startIdx, count);
        new current = g_AvtobusPlayer[playerid][ap_CurrentIndex];
        new routeIdx = startIdx + current;
        if(routeIdx < startIdx || routeIdx >= startIdx + count) {
            routeIdx = startIdx;
        }
        SetPlayerCheckpoint(playerid,
            g_AvtobusRoutePoints[routeIdx][arX],
            g_AvtobusRoutePoints[routeIdx][arY],
            g_AvtobusRoutePoints[routeIdx][arZ],
            AVTOBUS_ZONE_RADIUS);
    }
}

callback::OnAvtobusFinished(playerid, const arguments[]) {
    #pragma unused arguments
    if(!IsPlayerConnected(playerid)) return 1;
    if(g_AvtobusPlayer[playerid][ap_AtStop] && !g_AvtobusPlayer[playerid][ap_StopCompleted]) {
        Avtobus_FinishStop(playerid);
    } else {
        Avtobus_HideWidget(playerid);
    }
    return 1;
}

forward Avtobus_ShowWarning(playerid);
public Avtobus_ShowWarning(playerid) {
    if(IsPlayerConnected(playerid) && g_AvtobusPlayer[playerid][ap_Working]) {
        ShowJobWidget(playerid, "Скоро будет остановка", "Снизьте скорость и дождитесь всех пассажиров", "");
        if(g_AvtobusPlayer[playerid][ap_WarningTimer] != -1) {
            KillTimer(g_AvtobusPlayer[playerid][ap_WarningTimer]);
        }
        g_AvtobusPlayer[playerid][ap_WarningTimer] = SetTimerEx("Avtobus_HideWarning", 5000, false, "i", playerid);
    }
}

forward Avtobus_HideWarning(playerid);
public Avtobus_HideWarning(playerid) {
    if(IsPlayerConnected(playerid)) {
        if(g_AvtobusPlayer[playerid][ap_WarningTimer] != -1) {
            KillTimer(g_AvtobusPlayer[playerid][ap_WarningTimer]);
            g_AvtobusPlayer[playerid][ap_WarningTimer] = -1;
        }
        if(!g_AvtobusPlayer[playerid][ap_AtStop]) {
            DestroyJobWidget(playerid);
        }
    }
}

stock Avtobus_OnPlayerEnterCheckpoint(playerid) {
    if(!g_AvtobusPlayer[playerid][ap_Working]) return 0;
    new startIdx, count;
    Avtobus_GetRoutePoints(g_AvtobusPlayer[playerid][ap_MarshID], startIdx, count);
    if(count == 0) return 0;
    new current = g_AvtobusPlayer[playerid][ap_CurrentIndex];
    new routeIdx = startIdx + current;
    if(routeIdx < startIdx || routeIdx >= startIdx + count) return 0;

    if(!IsPlayerInRangeOfPoint(playerid, AVTOBUS_ZONE_RADIUS,
        g_AvtobusRoutePoints[routeIdx][arX],
        g_AvtobusRoutePoints[routeIdx][arY],
        g_AvtobusRoutePoints[routeIdx][arZ])) return 0;

    if(g_AvtobusRoutePoints[routeIdx][arType] == 1) {
        new basePay = AVTOBUS_PAY_PER_CHECKPOINT;
        new bonusPerLevel = 7500;
        new pay = Skill_GetRewardBonus(playerid, SKILL_BUS, basePay, bonusPerLevel);

        PI[playerid][pCash] += pay;
        GivePlayerMoney(playerid, pay);
        UpdatePlayerHUD(playerid);
        new query[128];
        mysql_format(dbHandle, query, sizeof(query), "UPDATE `accounts` SET `cash`=%d WHERE `id`=%d", PI[playerid][pCash], PI[playerid][pID]);
        mysql_tquery(dbHandle, query, "", "");

        Skill_AddProgress(playerid, SKILL_BUS, 1);

        new msg[64];
        format(msg, sizeof(msg), "Чекпоинт пройден! +%d руб.", pay);
        CEFChat_Send(playerid, "54B367", msg);

        g_AvtobusPlayer[playerid][ap_CurrentIndex]++;
        if(g_AvtobusPlayer[playerid][ap_CurrentIndex] >= count) {
            g_AvtobusPlayer[playerid][ap_CurrentIndex] = 0;
        }
        Avtobus_SetCheckpoint(playerid, startIdx + g_AvtobusPlayer[playerid][ap_CurrentIndex]);
        new nextIdx = startIdx + g_AvtobusPlayer[playerid][ap_CurrentIndex];
        if(g_AvtobusRoutePoints[nextIdx][arType] == 2) {
            SetTimerEx("Avtobus_ShowWarning", 500, false, "i", playerid);
        }
        return 1;
    }
    else if(g_AvtobusRoutePoints[routeIdx][arType] == 2) {
        if(g_AvtobusPlayer[playerid][ap_AtStop]) return 0;
        if(g_AvtobusPlayer[playerid][ap_WarningTimer] != -1) {
            KillTimer(g_AvtobusPlayer[playerid][ap_WarningTimer]);
            g_AvtobusPlayer[playerid][ap_WarningTimer] = -1;
        }
        DestroyJobWidget(playerid);
        g_AvtobusPlayer[playerid][ap_StopArea] = g_AvtobusStopAreas[routeIdx];
        Avtobus_ShowStopWidget(playerid);
        return 1;
    }
    return 0;
}

stock Avtobus_OnLeaveArea(playerid, areaid) {
    if(!g_AvtobusPlayer[playerid][ap_Working]) return 0;
    if(!g_AvtobusPlayer[playerid][ap_AtStop]) return 0;
    if(g_AvtobusPlayer[playerid][ap_StopArea] == areaid) {
        if(g_AvtobusPlayer[playerid][ap_StopTimer] != -1) {
            KillTimer(g_AvtobusPlayer[playerid][ap_StopTimer]);
            g_AvtobusPlayer[playerid][ap_StopTimer] = -1;
        }
        Avtobus_HideWidget(playerid);
        CEFChat_Send(playerid, "FF4444", "Вы покинули остановку! Остановка не засчитана.");
        g_AvtobusPlayer[playerid][ap_AtStop] = false;
        g_AvtobusPlayer[playerid][ap_StopArea] = -1;
        new startIdx, count;
        Avtobus_GetRoutePoints(g_AvtobusPlayer[playerid][ap_MarshID], startIdx, count);
        new routeIdx = startIdx + g_AvtobusPlayer[playerid][ap_CurrentIndex];
        if(routeIdx < startIdx || routeIdx >= startIdx + count) return 0;
        SetPlayerCheckpoint(playerid,
            g_AvtobusRoutePoints[routeIdx][arX],
            g_AvtobusRoutePoints[routeIdx][arY],
            g_AvtobusRoutePoints[routeIdx][arZ],
            AVTOBUS_ZONE_RADIUS);
        return 1;
    }
    return 0;
}

stock Avtobus_OnPlayerStateChange(playerid, newstate, oldstate) {
    if(newstate == PLAYER_STATE_DRIVER) {
        new veh = GetPlayerVehicleID(playerid);
        if(!g_AvtobusPlayer[playerid][ap_Working]) {
            for(new i = 0; i < g_AvtobusCarCount; i++) {
                if(g_AvtobusCars[i][acVehicle] == veh && !g_AvtobusCars[i][acUsed]) {
                    new dialogText[512];
                    format(dialogText, sizeof(dialogText),
                        "{FFFFFF}Приветствуем Вас в автопарке «Немазинг»!\n\n\
                        Здесь Вы сможете устроиться на работу водителем маршрутного средства и заработать себе денег.\n\n\
                        1) Начните работу и арендуйте транспорт\n\
                        2) Двигайтесь по чекпоинтам\n\
                        3) Подбирайте людей и останавливайтесь на остановках\n\
                        4) Во время работы нельзя уходить в АРК, иначе аренда прекратится\n\n\
                        {FFFFFF}Тип маршрутного средства: {e69348}Городской\n\
                        {FFFFFF}Маршрут транспортного средства: {e69348}по пгт. Батырево\n\
                        {FFFFFF}Стоимость аренды транспортного средства: {e69348}%d тыс. руб\n\
                        {FFFFFF}Плата за 1 чекпоинт: {e69348}%d тыс. руб\n\
                        {FFFFFF}Минимальный скилл для работы: {e69348}1",
                        AVTOBUS_RENT_PRICE / 1000,
                        AVTOBUS_PAY_PER_CHECKPOINT / 1000
                    );
                    ShowPlayerDialogEx(playerid, AVTOBUS_DIALOG_START, DIALOG_STYLE_MSGBOX,
                        "Водитель автобуса",
                        dialogText,
                        "Начать", "Закрыть");
                    SetPVarInt(playerid, "AvtobusVehicle", veh);
                    return 1;
                }
            }
        } else {
            if(veh == g_AvtobusPlayer[playerid][ap_Vehicle]) {
                if(g_AvtobusPlayer[playerid][ap_TimerExit] != -1) {
                    KillTimer(g_AvtobusPlayer[playerid][ap_TimerExit]);
                    g_AvtobusPlayer[playerid][ap_TimerExit] = -1;
                    CEFChat_Send(playerid, "54B367", "Вы вернулись в автобус. Работа продолжается.");
                }
            } else {
                CEFChat_Send(playerid, "FF4444", "Вы пересели в другой транспорт. Работа завершена.");
                Avtobus_StopWork(playerid);
            }
        }
    }
    else if(oldstate == PLAYER_STATE_DRIVER && newstate == PLAYER_STATE_ONFOOT) {
        if(g_AvtobusPlayer[playerid][ap_Working]) {
            new veh = GetPlayerVehicleID(playerid);
            if(veh == g_AvtobusPlayer[playerid][ap_Vehicle]) {
                if(g_AvtobusPlayer[playerid][ap_TimerExit] == -1) {
                    g_AvtobusPlayer[playerid][ap_TimerExit] = SetTimerEx("Avtobus_ExitTimerTick", AVTOBUS_EXIT_TIMEOUT, false, "i", playerid);
                    CEFChat_Send(playerid, "FFAA00", "Вы вышли из автобуса! У вас есть 90 секунд, чтобы вернуться.");
                }
            }
        }
    }
    return 1;
}

forward Avtobus_ExitTimerTick(playerid);
public Avtobus_ExitTimerTick(playerid) {
    g_AvtobusPlayer[playerid][ap_TimerExit] = -1;
    if(!g_AvtobusPlayer[playerid][ap_Working]) return;
    CEFChat_Send(playerid, "FF4444", "Вы не вернулись в автобус! Работа завершена.");
    Avtobus_StopWork(playerid);
}

stock Avtobus_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    #pragma unused listitem, inputtext
    if(dialogid == AVTOBUS_DIALOG_START) {
        if(!response) {
            CEFChat_Send(playerid, "AAAAAA", "Вы отказались от работы.");
            return 1;
        }
        new veh = GetPVarInt(playerid, "AvtobusVehicle");
        if(!IsValidVehicle(veh)) {
            CEFChat_Send(playerid, "FF4444", "Автобус больше не доступен.");
            return 1;
        }
        Avtobus_StartWork(playerid, veh);
        DeletePVar(playerid, "AvtobusVehicle");
        return 1;
    }
    return 0;
}

stock Avtobus_OnDisconnect(playerid) {
    if(g_AvtobusPlayer[playerid][ap_Working]) {
        Avtobus_StopWork(playerid);
    }
    if(g_AvtobusPlayer[playerid][ap_StopTimer] != -1) {
        KillTimer(g_AvtobusPlayer[playerid][ap_StopTimer]);
        g_AvtobusPlayer[playerid][ap_StopTimer] = -1;
    }
    if(g_AvtobusPlayer[playerid][ap_WarningTimer] != -1) {
        KillTimer(g_AvtobusPlayer[playerid][ap_WarningTimer]);
        g_AvtobusPlayer[playerid][ap_WarningTimer] = -1;
    }
    Avtobus_HideWidget(playerid);
    DestroyJobWidget(playerid);
}
