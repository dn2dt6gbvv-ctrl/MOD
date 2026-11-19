#if defined _razvoz_inc
    #endinput
#endif
#define _razvoz_inc

#include "../include/jobs/skills.pwn"

#define RAZVOZ_SKIN         16
#define RAZVOZ_WORLD        0
#define RAZVOZ_INTERIOR     0

static const Float:RAZVOZ_NPC_X = 220.7643;
static const Float:RAZVOZ_NPC_Y = 418.4383;
static const Float:RAZVOZ_NPC_Z = 11.1746;

enum E_RAZVOZ_ORDER {
    rzID,
    rzName[64],
    Float:rzX,
    Float:rzY,
    Float:rzZ,
    rzRequired,
    rzPrice,
    bool:rzActive,
    rzType,
    rzArea,
    rzMapIcon
}

new g_RazvozOrders[50][E_RAZVOZ_ORDER];
new g_RazvozOrderCount = 0;

static g_RazvozNPC  = -1;
static g_RazvozArea = -1;
static g_RazvozLoadAreaGoods = -1;
static g_RazvozLoadAreaFuel  = -1;
static g_RazvozLoadAreaWood  = -1;
static g_RazvozLoadAreaMetal = -1;
static g_RazvozUnloadAreaFactory = -1;

static Text3D:g_RazvozFactoryLabel = Text3D:INVALID_3DTEXT_ID;

new g_RazvozVehicle[MAX_PLAYERS] = {INVALID_VEHICLE_ID, ...};
static g_RazvozExitTimer[MAX_PLAYERS] = {-1, ...};
static bool:g_RazvozWorking[MAX_PLAYERS];
new g_RazvozLoaded[MAX_PLAYERS];
new g_RazvozLoadedType[MAX_PLAYERS];
new g_RazvozWoodLoaded[MAX_PLAYERS];
new g_RazvozMetalLoaded[MAX_PLAYERS];
new g_RazvozSelectedOrder[MAX_PLAYERS] = {-1, ...};
new g_RazvozType[MAX_PLAYERS];

new g_RazvozOrderList[MAX_PLAYERS][50];
new g_RazvozOrderListCount[MAX_PLAYERS];
new g_RazvozOrdersCompleted[MAX_PLAYERS];

new Text3D:g_RazvozPlayerLabels[MAX_PLAYERS][RAZVOZ_LABEL_COUNT];
static g_LastUpdateHour = -1;


stock Razvoz_SetCheckpoint(playerid, Float:x, Float:y, Float:z, Float:radius = 3.0) {
    SetPlayerCheckpoint(playerid, x, y, z, radius);
}
stock Razvoz_DisableCheckpoint(playerid) {
    DisablePlayerCheckpoint(playerid);
}


stock Razvoz_CreateLabelsForPlayer(playerid) {
    new labelText[128];
    format(labelText, sizeof(labelText), "Склад товаров\nЗагрузитесь здесь");
    g_RazvozPlayerLabels[playerid][50] = CreateDynamic3DTextLabel(
        labelText, 0xFFFF00AA,
        Float:RAZVOZ_LOAD_GOODS_X, Float:RAZVOZ_LOAD_GOODS_Y, Float:RAZVOZ_LOAD_GOODS_Z + 1.5,
        10.0, playerid, INVALID_VEHICLE_ID, 0, RAZVOZ_WORLD, RAZVOZ_INTERIOR, -1, 20.0);
    format(labelText, sizeof(labelText), "Склад топлива\nЗагрузитесь здесь");
    g_RazvozPlayerLabels[playerid][51] = CreateDynamic3DTextLabel(
        labelText, 0xFFFF00AA,
        Float:RAZVOZ_LOAD_FUEL_X, Float:RAZVOZ_LOAD_FUEL_Y, Float:RAZVOZ_LOAD_FUEL_Z + 1.5,
        10.0, playerid, INVALID_VEHICLE_ID, 0, RAZVOZ_WORLD, RAZVOZ_INTERIOR, -1, 20.0);
    format(labelText, sizeof(labelText), "Склад древесины\nЗагрузитесь здесь");
    g_RazvozPlayerLabels[playerid][52] = CreateDynamic3DTextLabel(
        labelText, 0xFFFF00AA,
        Float:RAZVOZ_LOAD_WOOD_X, Float:RAZVOZ_LOAD_WOOD_Y, Float:RAZVOZ_LOAD_WOOD_Z + 1.5,
        10.0, playerid, INVALID_VEHICLE_ID, 0, RAZVOZ_WORLD, RAZVOZ_INTERIOR, -1, 20.0);
    format(labelText, sizeof(labelText), "Склад металла\nЗагрузитесь здесь");
    g_RazvozPlayerLabels[playerid][53] = CreateDynamic3DTextLabel(
        labelText, 0xFFFF00AA,
        Float:RAZVOZ_LOAD_METAL_X, Float:RAZVOZ_LOAD_METAL_Y, Float:RAZVOZ_LOAD_METAL_Z + 1.5,
        10.0, playerid, INVALID_VEHICLE_ID, 0, RAZVOZ_WORLD, RAZVOZ_INTERIOR, -1, 20.0);
    for(new i = 0; i < g_RazvozOrderCount; i++) {
        if(g_RazvozOrders[i][rzActive] && (g_RazvozOrders[i][rzType] == 1 || g_RazvozOrders[i][rzType] == 2)) {
            format(labelText, sizeof(labelText), "%s\nТребуется: %d ед., Цена: %d руб./ед.",
                g_RazvozOrders[i][rzName], g_RazvozOrders[i][rzRequired], g_RazvozOrders[i][rzPrice]);
            g_RazvozPlayerLabels[playerid][i] = CreateDynamic3DTextLabel(
                labelText, 0x00FFAAFF,
                g_RazvozOrders[i][rzX], g_RazvozOrders[i][rzY], g_RazvozOrders[i][rzZ] + 1.0,
                10.0, playerid, INVALID_VEHICLE_ID, 0, RAZVOZ_WORLD, RAZVOZ_INTERIOR, -1, 20.0);
        } else {
            g_RazvozPlayerLabels[playerid][i] = Text3D:INVALID_3DTEXT_ID;
        }
    }
}
stock Razvoz_DestroyLabelsForPlayer(playerid) {
    for(new i = 0; i < RAZVOZ_LABEL_COUNT; i++) {
        if(g_RazvozPlayerLabels[playerid][i] != Text3D:INVALID_3DTEXT_ID) {
            DestroyDynamic3DTextLabel(g_RazvozPlayerLabels[playerid][i]);
            g_RazvozPlayerLabels[playerid][i] = Text3D:INVALID_3DTEXT_ID;
        }
    }
}
stock Razvoz_RecreateAllLabels() {
    for(new i = 0; i < MAX_PLAYERS; i++) {
        if(IsPlayerConnected(i) && g_RazvozWorking[i]) {
            Razvoz_DestroyLabelsForPlayer(i);
            Razvoz_CreateLabelsForPlayer(i);
        }
    }
}




stock LoadRazvozSystem() {
    g_RazvozNPC = CreateDynamicActor(RAZVOZ_SKIN,
        RAZVOZ_NPC_X, RAZVOZ_NPC_Y, RAZVOZ_NPC_Z,
        0.0, 1, RAZVOZ_WORLD, RAZVOZ_INTERIOR);
    g_RazvozArea = CreateDynamicSphere(
        RAZVOZ_NPC_X, RAZVOZ_NPC_Y, RAZVOZ_NPC_Z,
        2.0, RAZVOZ_WORLD, RAZVOZ_INTERIOR, -1);
    CreateDynamic3DTextLabel("Развозчик\nНажмите ALT для информации",
        0xFFFFFFFF,
        RAZVOZ_NPC_X, RAZVOZ_NPC_Y, RAZVOZ_NPC_Z + 0.5,
        5.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID,
        0, RAZVOZ_WORLD, RAZVOZ_INTERIOR, -1, 8.0);

    g_RazvozLoadAreaGoods = CreateDynamicSphere(
        Float:RAZVOZ_LOAD_GOODS_X, Float:RAZVOZ_LOAD_GOODS_Y, Float:RAZVOZ_LOAD_GOODS_Z,
        Float:RAZVOZ_LOAD_RADIUS, RAZVOZ_WORLD, RAZVOZ_INTERIOR, -1);
    CreateDynamicMapIcon(Float:RAZVOZ_LOAD_GOODS_X, Float:RAZVOZ_LOAD_GOODS_Y, Float:RAZVOZ_LOAD_GOODS_Z,
        56, 0, RAZVOZ_WORLD, RAZVOZ_INTERIOR, -1, 100.0);

    g_RazvozLoadAreaFuel = CreateDynamicSphere(
        Float:RAZVOZ_LOAD_FUEL_X, Float:RAZVOZ_LOAD_FUEL_Y, Float:RAZVOZ_LOAD_FUEL_Z,
        Float:RAZVOZ_LOAD_RADIUS, RAZVOZ_WORLD, RAZVOZ_INTERIOR, -1);
    CreateDynamicMapIcon(Float:RAZVOZ_LOAD_FUEL_X, Float:RAZVOZ_LOAD_FUEL_Y, Float:RAZVOZ_LOAD_FUEL_Z,
        56, 0, RAZVOZ_WORLD, RAZVOZ_INTERIOR, -1, 100.0);

    g_RazvozLoadAreaWood = CreateDynamicSphere(
        Float:RAZVOZ_LOAD_WOOD_X, Float:RAZVOZ_LOAD_WOOD_Y, Float:RAZVOZ_LOAD_WOOD_Z,
        Float:RAZVOZ_LOAD_RADIUS, RAZVOZ_WORLD, RAZVOZ_INTERIOR, -1);
    CreateDynamicMapIcon(Float:RAZVOZ_LOAD_WOOD_X, Float:RAZVOZ_LOAD_WOOD_Y, Float:RAZVOZ_LOAD_WOOD_Z,
        56, 0, RAZVOZ_WORLD, RAZVOZ_INTERIOR, -1, 100.0);

    g_RazvozLoadAreaMetal = CreateDynamicSphere(
        Float:RAZVOZ_LOAD_METAL_X, Float:RAZVOZ_LOAD_METAL_Y, Float:RAZVOZ_LOAD_METAL_Z,
        Float:RAZVOZ_LOAD_RADIUS, RAZVOZ_WORLD, RAZVOZ_INTERIOR, -1);
    CreateDynamicMapIcon(Float:RAZVOZ_LOAD_METAL_X, Float:RAZVOZ_LOAD_METAL_Y, Float:RAZVOZ_LOAD_METAL_Z,
        56, 0, RAZVOZ_WORLD, RAZVOZ_INTERIOR, -1, 100.0);

    g_RazvozUnloadAreaFactory = CreateDynamicSphere(
        Float:RAZVOZ_UNLOAD_FACTORY_X, Float:RAZVOZ_UNLOAD_FACTORY_Y, Float:RAZVOZ_UNLOAD_FACTORY_Z,
        Float:RAZVOZ_LOAD_RADIUS, 0, 0, -1);
    CreateDynamicMapIcon(Float:RAZVOZ_UNLOAD_FACTORY_X, Float:RAZVOZ_UNLOAD_FACTORY_Y, Float:RAZVOZ_UNLOAD_FACTORY_Z,
        56, 0, 0, 0, -1, 100.0);

    new text[256];
    format(text, sizeof(text), "Склад завода\nРазгрузка сырья");
    g_RazvozFactoryLabel = CreateDynamic3DTextLabel(
        text, 0xFFFF00AA,
        Float:RAZVOZ_UNLOAD_FACTORY_X, Float:RAZVOZ_UNLOAD_FACTORY_Y, Float:RAZVOZ_UNLOAD_FACTORY_Z + 1.5,
        15.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0, -1, 20.0
    );

    mysql_tquery(dbHandle, "SELECT * FROM `razvoz_orders` WHERE `active`=1", "OnRazvozOrdersLoaded", "");
    SetTimer("Razvoz_CheckUpdateHour", 60000, true);
    printf("[Razvoz] Система загружена");
    return 1;
}

forward Razvoz_CheckUpdateHour();
public Razvoz_CheckUpdateHour() {
    new hour; gettime(hour);
    if((hour % 2 == 0) && g_LastUpdateHour != hour) {
        g_LastUpdateHour = hour;
        Razvoz_UpdateOrders();
        printf("[Razvoz] Заказы обновлены по расписанию (час %d).", hour);
    }
    return 1;
}

forward OnRazvozOrdersLoaded();
public OnRazvozOrdersLoaded() {
    new rows = cache_num_rows();
    g_RazvozOrderCount = 0;
    for(new i = 0; i < rows && i < 50; i++) {
        cache_get_value_name_int(i, "id", g_RazvozOrders[g_RazvozOrderCount][rzID]);
        cache_get_value_name(i, "name", g_RazvozOrders[g_RazvozOrderCount][rzName], 64);
        cache_get_value_name_float(i, "x", g_RazvozOrders[g_RazvozOrderCount][rzX]);
        cache_get_value_name_float(i, "y", g_RazvozOrders[g_RazvozOrderCount][rzY]);
        cache_get_value_name_float(i, "z", g_RazvozOrders[g_RazvozOrderCount][rzZ]);
        cache_get_value_name_int(i, "required", g_RazvozOrders[g_RazvozOrderCount][rzRequired]);
        cache_get_value_name_int(i, "price", g_RazvozOrders[g_RazvozOrderCount][rzPrice]);
        cache_get_value_name_int(i, "type", g_RazvozOrders[g_RazvozOrderCount][rzType]);
        g_RazvozOrders[g_RazvozOrderCount][rzActive] = true;
        g_RazvozOrders[g_RazvozOrderCount][rzArea] = CreateDynamicSphere(
            g_RazvozOrders[g_RazvozOrderCount][rzX],
            g_RazvozOrders[g_RazvozOrderCount][rzY],
            g_RazvozOrders[g_RazvozOrderCount][rzZ],
            Float:RAZVOZ_ORDER_RADIUS, RAZVOZ_WORLD, RAZVOZ_INTERIOR, -1);
        g_RazvozOrders[g_RazvozOrderCount][rzMapIcon] = CreateDynamicMapIcon(
            g_RazvozOrders[g_RazvozOrderCount][rzX],
            g_RazvozOrders[g_RazvozOrderCount][rzY],
            g_RazvozOrders[g_RazvozOrderCount][rzZ],
            55, 0, RAZVOZ_WORLD, RAZVOZ_INTERIOR, -1, 100.0);
        g_RazvozOrderCount++;
    }
    Razvoz_UpdateOrders();
    printf("[Razvoz] Загружено %d заказов.", g_RazvozOrderCount);
    return 1;
}

stock Razvoz_UpdateOrders() {
    new query[256];
    for(new i = 0; i < g_RazvozOrderCount; i++) {
        if(!g_RazvozOrders[i][rzActive]) continue;
        if(g_RazvozOrders[i][rzRequired] <= 0) g_RazvozOrders[i][rzRequired] = 5000 + random(10001);

        if(g_RazvozOrders[i][rzType] == 1) {
            g_RazvozOrders[i][rzPrice] = RAZVOZ_SELL_PRICE_GOODS + random(1000);
        } else {
            g_RazvozOrders[i][rzPrice] = RAZVOZ_SELL_PRICE_FUEL + random(1000);
        }
        mysql_format(dbHandle, query, sizeof(query),
            "UPDATE `razvoz_orders` SET `required`=%d, `price`=%d WHERE `id`=%d",
            g_RazvozOrders[i][rzRequired], g_RazvozOrders[i][rzPrice], g_RazvozOrders[i][rzID]);
        mysql_tquery(dbHandle, query, "", "");
    }
    Razvoz_RecreateAllLabels();
    printf("[Razvoz] Заказы обновлены.");
    return 1;
}

CMD:addpicrazvoz(playerid, params[]) {
    if(PI[playerid][pAdmin] < 6) return CEFChat_Send(playerid, "FF4444", "Нет прав.");
    new type, name[64];
    if(sscanf(params, "d s[64]", type, name)) {
        CEFChat_Send(playerid, "FF4444", "Использование: /addpicrazvoz [1 - товары | 2 - бензин] [название]");
        return 1;
    }
    if(type != 1 && type != 2) {
        CEFChat_Send(playerid, "FF4444", "Тип должен быть 1 (товары) или 2 (бензин).");
        return 1;
    }
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    new query[512];
    mysql_format(dbHandle, query, sizeof(query),
        "INSERT INTO `razvoz_orders` (`name`, `x`, `y`, `z`, `required`, `price`, `active`, `type`) VALUES ('%e', %.4f, %.4f, %.4f, %d, %d, 1, %d)",
        name, x, y, z, 0, 0, type);
    mysql_tquery(dbHandle, query, "OnRazvozOrderAdded", "i", playerid);
    CEFChat_Send(playerid, "54B367", "Точка добавлена. Заказы обновятся.");
    return 1;
}
forward OnRazvozOrderAdded(playerid);
public OnRazvozOrderAdded(playerid) {
    #pragma unused playerid
    mysql_tquery(dbHandle, "SELECT * FROM `razvoz_orders` WHERE `active`=1", "OnRazvozOrdersLoaded", "");
    CEFChat_Send(playerid, "54B367", "Заказы обновлены.");
    return 1;
}

stock Razvoz_IsWorking(playerid) return g_RazvozWorking[playerid];
stock Razvoz_GetVehicle(playerid) return g_RazvozVehicle[playerid];
stock Razvoz_GetType(playerid) return g_RazvozType[playerid];

stock Razvoz_OnEnterArea(playerid, areaid) {
    if(areaid == g_RazvozArea) {
        cef_emit_event(playerid, "game:ShowHint", CEFSTR("ALT"), CEFINT(2500));
        return 1;
    }
    return 0;
}

stock Razvoz_OnKeyState(playerid, newkeys) {
    if(!(newkeys & KEY_WALK)) return 0;
    if(!IsPlayerInDynamicArea(playerid, g_RazvozArea)) return 0;
    if(g_RazvozWorking[playerid]) {
        CEFChat_Send(playerid, "FF4444", "Вы уже работаете развозчиком!");
        return 1;
    }
    ShowPlayerDialogEx(playerid, RAZVOZ_DIALOG_MAIN, DIALOG_STYLE_MSGBOX,
        "Работа развозчиком",
        "Приветствуем Вас на базе развозчиков!\n\nЗдесь Вы сможете устроиться на работу развозчиком и заработать себе денег.\n\nВыберите тип работы:\n- Развозка товаров (также доступны дерево и металл)\n- Развозка топлива (только топливо)\n\nАренда транспорта — 80.000 рублей\n\nИспользуйте клавишу J для меню.",
        "Начать", "Закрыть");
    return 1;
}

stock GiveRazvozVehicle(playerid, type) {
    if(g_RazvozWorking[playerid]) {
        CEFChat_Send(playerid, "FF4444", "Вы уже работаете!");
        return 0;
    }
    if(PI[playerid][pCash] < 80000) {
        CEFChat_Send(playerid, "FF4444", "У вас недостаточно денег! Нужно 80.000 руб.");
        return 0;
    }
    if(g_RazvozVehicle[playerid] != INVALID_VEHICLE_ID) return 0;

    new model = (type == 2) ? 525 : 499;
    new Float:loadX, Float:loadY, Float:loadZ;
    if(type == 1) {
        loadX = Float:RAZVOZ_LOAD_GOODS_X; loadY = Float:RAZVOZ_LOAD_GOODS_Y; loadZ = Float:RAZVOZ_LOAD_GOODS_Z;
    } else if(type == 2) {
        loadX = Float:RAZVOZ_LOAD_FUEL_X; loadY = Float:RAZVOZ_LOAD_FUEL_Y; loadZ = Float:RAZVOZ_LOAD_FUEL_Z;
    } else {
        return 0;
    }

    new vehicleid = CreateVehicle(model,
        RAZVOZ_NPC_X + 3.0, RAZVOZ_NPC_Y + 3.0, RAZVOZ_NPC_Z,
        0.0, -1, -1, -1);
    if(vehicleid == INVALID_VEHICLE_ID) {
        CEFChat_Send(playerid, "FF4444", "Ошибка создания транспорта.");
        return 0;
    }
    PI[playerid][pCash] -= 80000;
    GivePlayerMoney(playerid, -80000);
    UpdatePlayerHUD(playerid);
    SetVehicleParamsForPlayer(vehicleid, playerid, 0, 0);
    SetVehicleParamsForPlayer(vehicleid, playerid, 1, 1);
    if(CI[vehicleid][Fuel] != -1) CI[vehicleid][Fuel] = 100;

    g_RazvozVehicle[playerid] = vehicleid;
    g_RazvozWorking[playerid] = true;
    g_RazvozType[playerid] = type;
    g_RazvozExitTimer[playerid] = -1;
    g_RazvozLoaded[playerid] = 0;
    g_RazvozLoadedType[playerid] = 0;
    g_RazvozWoodLoaded[playerid] = 0;
    g_RazvozMetalLoaded[playerid] = 0;
    g_RazvozSelectedOrder[playerid] = -1;
    g_RazvozOrdersCompleted[playerid] = 0;
    Razvoz_CreateLabelsForPlayer(playerid);
    PutPlayerInVehicle(playerid, vehicleid, 0);
    Razvoz_SetCheckpoint(playerid, loadX, loadY, loadZ, Float:RAZVOZ_LOAD_RADIUS);

    new typeName[32];
    if(type == 1) format(typeName, sizeof(typeName), "товаров");
    else format(typeName, sizeof(typeName), "топлива");
    CEFChat_Send(playerid, "54B367", "Вы начали работу развозчиком %s! Следуйте к красной метке.", typeName);
    CEFChat_Send(playerid, "AAAAAA", "Для завершения используйте /unrent (только у развозчика).");
    SendSuccess(playerid, "Работа начата", "Вы приступили к работе развозчиком.");
    return 1;
}

stock Razvoz_StopWork(playerid, bool:force = false) {
    if(!force && !IsPlayerInDynamicArea(playerid, g_RazvozArea)) {
        CEFChat_Send(playerid, "FF4444", "Вы должны подойти к развозчику, чтобы завершить работу.");
        return 0;
    }
    if(g_RazvozExitTimer[playerid] != -1) {
        KillTimer(g_RazvozExitTimer[playerid]);
        g_RazvozExitTimer[playerid] = -1;
    }
    Razvoz_DestroyLabelsForPlayer(playerid);
    g_RazvozWorking[playerid] = false;
    g_RazvozType[playerid] = 0;
    g_RazvozLoaded[playerid] = 0;
    g_RazvozLoadedType[playerid] = 0;
    g_RazvozWoodLoaded[playerid] = 0;
    g_RazvozMetalLoaded[playerid] = 0;
    g_RazvozSelectedOrder[playerid] = -1;
    g_RazvozOrdersCompleted[playerid] = 0;

    Razvoz_DisableCheckpoint(playerid);

    new vehicleid = g_RazvozVehicle[playerid];
    if(IsValidVehicle(vehicleid)) {
        DestroyVehicle(vehicleid);
        g_RazvozVehicle[playerid] = INVALID_VEHICLE_ID;
    }

    CEFChat_Send(playerid, "AAAAAA", "Работа развозчиком завершена.");
    return 1;
}

forward RazvozExitTimerTick(playerid);
public RazvozExitTimerTick(playerid) {
    g_RazvozExitTimer[playerid] = -1;
    if(!g_RazvozWorking[playerid]) return 1;
    CEFChat_Send(playerid, "FF4444", "Вы не вернулись в транспорт! Работа завершена.");
    Razvoz_StopWork(playerid, true);
    return 1;
}

stock Razvoz_OnPlayerStateChange(playerid, newstate, oldstate) {
    if(!g_RazvozWorking[playerid]) return 0;
    if(newstate == PLAYER_STATE_DRIVER) {
        new vehicleid = GetPlayerVehicleID(playerid);
        if(vehicleid == g_RazvozVehicle[playerid]) {
            if(g_RazvozExitTimer[playerid] != -1) {
                KillTimer(g_RazvozExitTimer[playerid]);
                g_RazvozExitTimer[playerid] = -1;
                CEFChat_Send(playerid, "54B367", "Вы вернулись в транспорт. Работа продолжается.");
            }
        }
    }
    else if(oldstate == PLAYER_STATE_DRIVER && newstate == PLAYER_STATE_ONFOOT) {
        new vehicleid = GetPlayerVehicleID(playerid);
        if(vehicleid == g_RazvozVehicle[playerid]) {
            if(g_RazvozExitTimer[playerid] == -1) {
                g_RazvozExitTimer[playerid] = SetTimerEx("RazvozExitTimerTick", 30000, false, "i", playerid);
                CEFChat_Send(playerid, "FFAA00", "Вы вышли из транспорта! У вас есть 30 секунд, чтобы вернуться.");
            }
        }
    }
    return 1;
}

stock Razvoz_IsAtLoadPointGoods(playerid) {
    return IsPlayerInDynamicArea(playerid, g_RazvozLoadAreaGoods);
}
stock Razvoz_IsAtLoadPointFuel(playerid) {
    return IsPlayerInDynamicArea(playerid, g_RazvozLoadAreaFuel);
}
stock Razvoz_IsAtLoadPointWood(playerid) {
    return IsPlayerInDynamicArea(playerid, g_RazvozLoadAreaWood);
}
stock Razvoz_IsAtLoadPointMetal(playerid) {
    return IsPlayerInDynamicArea(playerid, g_RazvozLoadAreaMetal);
}
stock Razvoz_IsAtFactoryUnload(playerid) {
    return IsPlayerInDynamicArea(playerid, g_RazvozUnloadAreaFactory);
}
stock Razvoz_IsAtOrderPoint(playerid, orderIdx) {
    if(orderIdx < 0 || orderIdx >= g_RazvozOrderCount) return 0;
    return IsPlayerInDynamicArea(playerid, g_RazvozOrders[orderIdx][rzArea]);
}


stock Razvoz_ShowInfo(playerid) {
    new info[512];
    new totalWoodMetal = g_RazvozWoodLoaded[playerid] + g_RazvozMetalLoaded[playerid];
    format(info, sizeof(info),
        "Информация по работе:\nЗагружено товаров/топлива: %d/%d\nЗагружено древесины: %d кг\nЗагружено металла: %d кг\nВсего сырья: %d/%d\n",
        g_RazvozLoaded[playerid], RAZVOZ_MAX_LOAD,
        g_RazvozWoodLoaded[playerid],
        g_RazvozMetalLoaded[playerid],
        totalWoodMetal, RAZVOZ_MAX_WOOD_METAL_LOAD);
    new type = g_RazvozLoadedType[playerid];
    if(type == 0) format(info, sizeof(info), "%sТип загруженного груза: товары", info);
    else if(type == 1) format(info, sizeof(info), "%sТип загруженного груза: древесина", info);
    else if(type == 2) format(info, sizeof(info), "%sТип загруженного груза: металл", info);
    else if(type == 3) format(info, sizeof(info), "%sТип загруженного груза: топливо", info);
    new idx = g_RazvozSelectedOrder[playerid];
    if(idx >= 0 && idx < g_RazvozOrderCount && g_RazvozOrders[idx][rzActive]) {
        format(info, sizeof(info), "%s\nВыбранный заказ: %s\nОсталось: %d ед., Цена: %d руб/ед.",
            info, g_RazvozOrders[idx][rzName], g_RazvozOrders[idx][rzRequired], g_RazvozOrders[idx][rzPrice]);
    } else {
        format(info, sizeof(info), "%s\nЗаказ не выбран.", info);
    }
    ShowPlayerDialogEx(playerid, RAZVOZ_DIALOG_INFO, DIALOG_STYLE_MSGBOX, "Информация по работе", info, "Закрыть", "");
}
stock Razvoz_GetMaxLoad(playerid)
{
    new level = Skill_GetLevel(playerid, SKILL_RAZVOZ);
    return 10 + level * 5;
}
#pragma unused g_RazvozFactoryLabel
#pragma unused g_RazvozLoadAreaGoods, g_RazvozLoadAreaFuel, g_RazvozLoadAreaWood, g_RazvozLoadAreaMetal, g_RazvozUnloadAreaFactory, g_RazvozNPC

stock Razvoz_PayCraft(playerid)
{
    if (!IsPlayerConnected(playerid)) return 0;
    if (!Razvoz_IsWorking(playerid)) return 0;
    new query[160], reward, amount, idx;
    idx = g_RazvozSelectedOrder[playerid];
    if (idx >= 0 && idx < g_RazvozOrderCount && g_RazvozOrders[idx][rzActive] && g_RazvozLoaded[playerid] > 0)
    {
        if (!Razvoz_IsAtOrderPoint(playerid, idx)) return -2;
        amount = g_RazvozLoaded[playerid];
        if (amount > g_RazvozOrders[idx][rzRequired]) amount = g_RazvozOrders[idx][rzRequired];
        if (amount <= 0) return -1;
        reward = amount * g_RazvozOrders[idx][rzPrice];
        PI[playerid][pCash] += reward;
        GivePlayerMoney(playerid, reward);
        UpdatePlayerHUD(playerid);
        mysql_format(dbHandle, query, sizeof(query), "UPDATE `accounts` SET `cash`=%d WHERE `id`=%d", PI[playerid][pCash], PI[playerid][pID]);
        mysql_tquery(dbHandle, query, "", "");
        g_RazvozOrders[idx][rzRequired] -= amount;
        g_RazvozLoaded[playerid] -= amount;
        if (g_RazvozOrders[idx][rzRequired] <= 0) g_RazvozOrders[idx][rzActive] = false;
        Skill_AddProgress(playerid, SKILL_RAZVOZ, 1);
        return reward;
    }
    if (Razvoz_IsAtFactoryUnload(playerid) && (g_RazvozWoodLoaded[playerid] + g_RazvozMetalLoaded[playerid]) > 0)
    {
        new woodAmount = g_RazvozWoodLoaded[playerid];
        new metalAmount = g_RazvozMetalLoaded[playerid];
        reward = woodAmount * RAZVOZ_PRICE_WOOD_SELL + metalAmount * RAZVOZ_PRICE_METAL_SELL;
        if (reward <= 0) return -1;
        PI[playerid][pCash] += reward;
        GivePlayerMoney(playerid, reward);
        UpdatePlayerHUD(playerid);
        mysql_format(dbHandle, query, sizeof(query), "UPDATE `accounts` SET `cash`=%d WHERE `id`=%d", PI[playerid][pCash], PI[playerid][pID]);
        mysql_tquery(dbHandle, query, "", "");
        g_RazvozWoodLoaded[playerid] = 0;
        g_RazvozMetalLoaded[playerid] = 0;
        Skill_AddProgress(playerid, SKILL_RAZVOZ, 1);
        return reward;
    }
    return -1;
}
