#if defined _mechanic_inc
    #endinput
#endif
#define _mechanic_inc

#include "../include/jobs/skills.pwn"

#define MECHANIC_VEHICLE_MODEL      525
#define MECHANIC_RENT_PRICE         5000
#define MECHANIC_AZS_RADIUS         15.0
#define MECHANIC_FIND_RADIUS        10.0
#define MECHANIC_REFUEL_PRICE_PER_L 1650
#define MECHANIC_REPAIR_PRICE       50000
#define MECHANIC_EXIT_TIMEOUT       30000
#define MECHANIC_LABEL_UPDATE_INTERVAL 500

#define MECHANIC_DIALOG_MAIN            30000
#define MECHANIC_DIALOG_MENU            30001
#define MECHANIC_DIALOG_AZS_LIST        30002
#define MECHANIC_DIALOG_REFUEL_LIST     30003
#define MECHANIC_DIALOG_REFUEL_CONFIRM  30004
#define MECHANIC_DIALOG_REPAIR_LIST     30005
#define MECHANIC_DIALOG_REPAIR_CONFIRM  30006
#define MECHANIC_DIALOG_STUB            30007
#define MECHANIC_DIALOG_INFO            30008

#define COLOR_MECH_INFO_STR  "FFA500"
#define COLOR_MECH_ERROR_STR "FF4444"

enum E_MECHANIC_SPAWN {
    mspID,
    Float:mspX,
    Float:mspY,
    Float:mspZ,
    Float:mspAngle,
    mspVehicle,
    bool:mspUsed
}
new g_MechanicSpawns[50][E_MECHANIC_SPAWN];
new g_MechanicSpawnCount = 0;

enum E_MECHANIC_AZS {
    mazID,
    mazName[64],
    Float:mazX,
    Float:mazY,
    Float:mazZ
}
new g_MechanicAZS[50][E_MECHANIC_AZS];
new g_MechanicAZSCount = 0;

new g_MechanicVehicle[MAX_PLAYERS] = {INVALID_VEHICLE_ID, ...};
static bool:g_MechanicWorking[MAX_PLAYERS];
static g_MechanicExitTimer[MAX_PLAYERS] = {-1, ...};
new g_MechanicContract[MAX_PLAYERS] = {-1, ...};

new Text3D:g_MechanicLabel[MAX_PLAYERS] = {Text3D:INVALID_3DTEXT_ID, ...};
static g_MechanicLabelTimer[MAX_PLAYERS] = {-1, ...};

new g_MechanicListTarget[MAX_PLAYERS][MAX_PLAYERS];
new g_MechanicListCount[MAX_PLAYERS];
new g_MechanicSelectedTarget[MAX_PLAYERS] = {INVALID_PLAYER_ID, ...};




stock LoadMechanicSystem() {
    mysql_tquery(dbHandle, "SELECT * FROM `mechanic_spawns`", "OnMechanicSpawnsLoaded", "");
    mysql_tquery(dbHandle, "SELECT * FROM `mechanic_azs`", "OnMechanicAZSLoaded", "");
    printf("[Mechanic] Система загружается...");
    return 1;
}

forward OnMechanicSpawnsLoaded();
public OnMechanicSpawnsLoaded() {
    new rows = cache_num_rows();
    g_MechanicSpawnCount = 0;
    for(new i = 0; i < rows && i < 50; i++) {
        cache_get_value_name_int(i, "id", g_MechanicSpawns[g_MechanicSpawnCount][mspID]);
        cache_get_value_name_float(i, "x", g_MechanicSpawns[g_MechanicSpawnCount][mspX]);
        cache_get_value_name_float(i, "y", g_MechanicSpawns[g_MechanicSpawnCount][mspY]);
        cache_get_value_name_float(i, "z", g_MechanicSpawns[g_MechanicSpawnCount][mspZ]);
        cache_get_value_name_float(i, "angle", g_MechanicSpawns[g_MechanicSpawnCount][mspAngle]);

        new veh = CreateVehicle(MECHANIC_VEHICLE_MODEL,
            g_MechanicSpawns[g_MechanicSpawnCount][mspX],
            g_MechanicSpawns[g_MechanicSpawnCount][mspY],
            g_MechanicSpawns[g_MechanicSpawnCount][mspZ],
            g_MechanicSpawns[g_MechanicSpawnCount][mspAngle],
            -1, -1, -1);
        g_MechanicSpawns[g_MechanicSpawnCount][mspVehicle] = veh;
        g_MechanicSpawns[g_MechanicSpawnCount][mspUsed] = false;
        if(CI[veh][Fuel] != -1) {
            CI[veh][Fuel] = 100;
        }
        g_MechanicSpawnCount++;
    }
    printf("[Mechanic] Загружено %d точек спавна, создано %d машин.", g_MechanicSpawnCount, g_MechanicSpawnCount);
    return 1;
}

forward OnMechanicAZSLoaded();
public OnMechanicAZSLoaded() {
    new rows = cache_num_rows();
    g_MechanicAZSCount = 0;
    for(new i = 0; i < rows && i < 50; i++) {
        cache_get_value_name_int(i, "id", g_MechanicAZS[g_MechanicAZSCount][mazID]);
        cache_get_value_name(i, "name", g_MechanicAZS[g_MechanicAZSCount][mazName], 64);
        cache_get_value_name_float(i, "x", g_MechanicAZS[g_MechanicAZSCount][mazX]);
        cache_get_value_name_float(i, "y", g_MechanicAZS[g_MechanicAZSCount][mazY]);
        cache_get_value_name_float(i, "z", g_MechanicAZS[g_MechanicAZSCount][mazZ]);
        CreateDynamicMapIcon(
            g_MechanicAZS[g_MechanicAZSCount][mazX],
            g_MechanicAZS[g_MechanicAZSCount][mazY],
            g_MechanicAZS[g_MechanicAZSCount][mazZ], 56, 0, 0, -1, -1, 100.0);
        g_MechanicAZSCount++;
    }
    printf("[Mechanic] Загружено %d точек АЗС.", g_MechanicAZSCount);
    return 1;
}

CMD:addmechspawn(playerid, params[]) {
    if(PI[playerid][pAdmin] < 6) return CEFChat_Send(playerid, COLOR_MECH_ERROR_STR, "Нет прав.");
    new Float:x, Float:y, Float:z, Float:angle;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, angle);
    new query[256];
    mysql_format(dbHandle, query, sizeof(query),
        "INSERT INTO `mechanic_spawns` (`x`, `y`, `z`, `angle`) VALUES (%.4f, %.4f, %.4f, %.4f)",
        x, y, z, angle);
    mysql_tquery(dbHandle, query, "OnMechanicSpawnAdded", "i", playerid);
    return 1;
}

forward OnMechanicSpawnAdded(playerid);
public OnMechanicSpawnAdded(playerid) {
    CEFChat_Send(playerid, COLOR_MECH_INFO_STR, "Точка спавна добавлена. Перезапустите сервер для создания машины.");
    mysql_tquery(dbHandle, "SELECT * FROM `mechanic_spawns`", "OnMechanicSpawnsLoaded", "");
    return 1;
}

CMD:addazs(playerid, params[]) {
    if(PI[playerid][pAdmin] < 6) return CEFChat_Send(playerid, COLOR_MECH_ERROR_STR, "Нет прав.");
    new name[64];
    if(sscanf(params, "s[64]", name))
        return CEFChat_Send(playerid, COLOR_MECH_ERROR_STR, "Использование: /addazs [название]");
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    new query[256];
    mysql_format(dbHandle, query, sizeof(query),
        "INSERT INTO `mechanic_azs` (`name`, `x`, `y`, `z`) VALUES ('%e', %.4f, %.4f, %.4f)",
        name, x, y, z);
    mysql_tquery(dbHandle, query, "OnMechanicAZSAdded", "i", playerid);
    return 1;
}

forward OnMechanicAZSAdded(playerid);
public OnMechanicAZSAdded(playerid) {
    CEFChat_Send(playerid, COLOR_MECH_INFO_STR, "АЗС добавлена.");
    mysql_tquery(dbHandle, "SELECT * FROM `mechanic_azs`", "OnMechanicAZSLoaded", "");
    return 1;
}




stock Mechanic_FindNearbyAZS(playerid) {
    for(new i = 0; i < g_MechanicAZSCount; i++) {
        if(GetPlayerDistanceFromPoint(playerid, g_MechanicAZS[i][mazX], g_MechanicAZS[i][mazY], g_MechanicAZS[i][mazZ]) <= MECHANIC_AZS_RADIUS)
            return i;
    }
    return -1;
}

stock Mechanic_FindFreeVehicle() {
    for(new i = 0; i < g_MechanicSpawnCount; i++) {
        if(!g_MechanicSpawns[i][mspUsed] && IsValidVehicle(g_MechanicSpawns[i][mspVehicle])) {
            return i;
        }
    }
    return -1;
}




forward Mechanic_UpdateLabelPosition(playerid);
public Mechanic_UpdateLabelPosition(playerid) {
    if(!IsPlayerConnected(playerid)) {
        Mechanic_DestroyLabel(playerid);
        return 1;
    }
    if(!g_MechanicWorking[playerid]) {
        Mechanic_DestroyLabel(playerid);
        return 1;
    }
    new veh = g_MechanicVehicle[playerid];
    if(!IsValidVehicle(veh)) {
        Mechanic_DestroyLabel(playerid);
        return 1;
    }
    new Float:x, Float:y, Float:z;
    GetVehiclePos(veh, x, y, z);

    if(g_MechanicLabel[playerid] != Text3D:INVALID_3DTEXT_ID) {
        Delete3DTextLabel(g_MechanicLabel[playerid]);
        g_MechanicLabel[playerid] = Text3D:INVALID_3DTEXT_ID;
    }
    
    new text[128];
    if(g_MechanicContract[playerid] != -1) {
        format(text, sizeof(text), "Контракт с %s\nТопливо в наличии", g_MechanicAZS[g_MechanicContract[playerid]][mazName]);
    } else {
        format(text, sizeof(text), "Контракта нет\nБез топлива");
    }
    g_MechanicLabel[playerid] = Create3DTextLabel(text, 0xFFFFFFFF, x, y, z + 1.2, 30.0, 0, 0);
    return 1;
}

stock Mechanic_UpdateLabel(playerid) {
    Mechanic_DestroyLabel(playerid);
    g_MechanicLabelTimer[playerid] = SetTimerEx("Mechanic_UpdateLabelPosition", MECHANIC_LABEL_UPDATE_INTERVAL, true, "i", playerid);
    Mechanic_UpdateLabelPosition(playerid);
    return 1;
}

stock Mechanic_DestroyLabel(playerid) {
    if(g_MechanicLabelTimer[playerid] != -1) {
        KillTimer(g_MechanicLabelTimer[playerid]);
        g_MechanicLabelTimer[playerid] = -1;
    }
    if(g_MechanicLabel[playerid] != Text3D:INVALID_3DTEXT_ID) {
        Delete3DTextLabel(g_MechanicLabel[playerid]);
        g_MechanicLabel[playerid] = Text3D:INVALID_3DTEXT_ID;
    }
    return 1;
}




stock Mechanic_StopWork(playerid) {
    if(g_MechanicExitTimer[playerid] != -1) {
        KillTimer(g_MechanicExitTimer[playerid]);
        g_MechanicExitTimer[playerid] = -1;
    }
    Mechanic_DestroyLabel(playerid);

    new veh = g_MechanicVehicle[playerid];
    for(new i = 0; i < g_MechanicSpawnCount; i++) {
        if(g_MechanicSpawns[i][mspVehicle] == veh) {
            g_MechanicSpawns[i][mspUsed] = false;
            if(CI[veh][Fuel] != -1) {
                CI[veh][Fuel] = 100;
            }
            break;
        }
    }
    g_MechanicVehicle[playerid] = INVALID_VEHICLE_ID;
    g_MechanicWorking[playerid] = false;
    g_MechanicContract[playerid] = -1;
    CEFChat_Send(playerid, "FFFFFF", "Работа механиком завершена.");
    return 1;
}

stock Mechanic_IsWorking(playerid) {
    return g_MechanicWorking[playerid];
}




stock Mechanic_OnPlayerStateChange(playerid, newstate, oldstate) {
    if(newstate == PLAYER_STATE_DRIVER) {
        new veh = GetPlayerVehicleID(playerid);
        if(veh == g_MechanicVehicle[playerid]) {
            if(g_MechanicExitTimer[playerid] != -1) {
                KillTimer(g_MechanicExitTimer[playerid]);
                g_MechanicExitTimer[playerid] = -1;
                CEFChat_Send(playerid, COLOR_MECH_INFO_STR, "Вы вернулись в транспорт. Работа продолжается.");
            }
            return 1;
        }

        if(!g_MechanicWorking[playerid] && GetVehicleModel(veh) == MECHANIC_VEHICLE_MODEL) {
            new spawnIdx = -1;
            for(new i = 0; i < g_MechanicSpawnCount; i++) {
                if(g_MechanicSpawns[i][mspVehicle] == veh) {
                    spawnIdx = i;
                    break;
                }
            }
            if(spawnIdx != -1 && !g_MechanicSpawns[spawnIdx][mspUsed]) {
                SetPVarInt(playerid, "MechSpawnIdx", spawnIdx);
                CEFChat_Send(playerid, COLOR_MECH_INFO_STR, "Вы сели в машину механика. Используйте /jmenu для работы.");
                ShowPlayerDialogEx(playerid, MECHANIC_DIALOG_MAIN, DIALOG_STYLE_MSGBOX,
                    "Механик",
                    "Приветствуем Вас в автопарке «Амазинг»!\n\n\
                    1. Начните работу и арендуйте транспорт\n\
                    2. Заключите контракт с любой АЗС, используя {FFA500}Клавишу J — Заключить контракт с АЗС{FFFFFF}\n\
                    3. Ищите клиентов или ожидайте вызовов\n\
                    4. Оказывайте услуги починки и заправки\n\
                    5. Пополняйте запасы топлива транспортных компаний\n\n\
                    Чем выше Ваш навык работы (/skill), тем больше Вы будете получать за оказанные услуги\n\n\
                    Аренда транспорта обойдётся Вам в {FFA500}5 тыс. руб.{FFFFFF}, Вы хотите начать работу?",
                    "Начать", "Закрыть");
                return 1;
            } else {
                CEFChat_Send(playerid, COLOR_MECH_ERROR_STR, "Эта машина уже занята другим механиком.");
            }
        }
        return 1;
    }
    else if(oldstate == PLAYER_STATE_DRIVER && newstate == PLAYER_STATE_ONFOOT) {
        if(!g_MechanicWorking[playerid]) return 0;
        new veh = GetPlayerVehicleID(playerid);
        if(veh != g_MechanicVehicle[playerid]) return 0;
        if(g_MechanicExitTimer[playerid] == -1) {
            g_MechanicExitTimer[playerid] = SetTimerEx("MechanicExitTimerTick", MECHANIC_EXIT_TIMEOUT, false, "i", playerid);
            CEFChat_Send(playerid, COLOR_MECH_INFO_STR, "Вы вышли из транспорта! У вас есть 30 секунд, чтобы вернуться.");
        }
    }
    return 0;
}

forward MechanicExitTimerTick(playerid);
public MechanicExitTimerTick(playerid) {
    g_MechanicExitTimer[playerid] = -1;
    if(!g_MechanicWorking[playerid]) return 1;
    CEFChat_Send(playerid, COLOR_MECH_ERROR_STR, "Вы не вернулись в транспорт! Работа завершена.");
    Mechanic_StopWork(playerid);
    return 1;
}




stock Mechanic_ShowNearbyList(playerid, dialogid, title[]) {
    new listText[512];
    g_MechanicListCount[playerid] = 0;
    foreach(new i : Player) {
        if(!PT[i][pLogged]) continue;
        if(!IsPlayerInAnyVehicle(i)) continue;
        new Float:x, Float:y, Float:z;
        GetPlayerPos(i, x, y, z);
        if(GetPlayerDistanceFromPoint(playerid, x, y, z) > MECHANIC_FIND_RADIUS) continue;
        new line[80];
        format(line, sizeof(line), "%s [ID: %d]\n", GetName(i), i);
        strcat(listText, line);
        g_MechanicListTarget[playerid][g_MechanicListCount[playerid]] = i;
        g_MechanicListCount[playerid]++;
        if(g_MechanicListCount[playerid] >= MAX_PLAYERS) break;
    }
    if(g_MechanicListCount[playerid] == 0) {
        CEFChat_Send(playerid, COLOR_MECH_ERROR_STR, "Рядом нет игроков в транспорте (радиус 10 метров).");
        return 0;
    }
    ShowPlayerDialogEx(playerid, dialogid, DIALOG_STYLE_LIST, title, listText, "Выбрать", "Закрыть");
    return 1;
}

stock Mechanic_GetListTarget(playerid, listitem) {
    if(listitem < 0 || listitem >= g_MechanicListCount[playerid]) return INVALID_PLAYER_ID;
    new target = g_MechanicListTarget[playerid][listitem];
    if(!IsPlayerConnected(target)) return INVALID_PLAYER_ID;
    return target;
}
forward OnMechanicDialogResponse(playerid, dialogid, response, listitem, const inputtext[]);
public OnMechanicDialogResponse(playerid, dialogid, response, listitem, const inputtext[]) {
    #pragma unused inputtext
    switch(dialogid) {
        case MECHANIC_DIALOG_MAIN: {
            if(!response) { 
                CEFChat_Send(playerid, "FFFFFF", "Вы закрыли диалог.");
                return 1; 
            }
            if(PI[playerid][pCash] < MECHANIC_RENT_PRICE) {
                CEFChat_Send(playerid, COLOR_MECH_ERROR_STR, "У вас недостаточно денег для аренды транспорта.");
                return 1;
            }
            new veh = GetPlayerVehicleID(playerid);
            if(veh == 0 || GetVehicleModel(veh) != MECHANIC_VEHICLE_MODEL) {
                CEFChat_Send(playerid, COLOR_MECH_ERROR_STR, "Вы должны находиться в машине механика.");
                return 1;
            }
            new spawnIdx = GetPVarInt(playerid, "MechSpawnIdx");
            if(spawnIdx < 0 || spawnIdx >= g_MechanicSpawnCount || g_MechanicSpawns[spawnIdx][mspVehicle] != veh) {
                for(new i = 0; i < g_MechanicSpawnCount; i++) {
                    if(g_MechanicSpawns[i][mspVehicle] == veh) {
                        spawnIdx = i;
                        SetPVarInt(playerid, "MechSpawnIdx", spawnIdx);
                        break;
                    }
                }
            }
            if(spawnIdx < 0 || spawnIdx >= g_MechanicSpawnCount || g_MechanicSpawns[spawnIdx][mspVehicle] != veh || g_MechanicSpawns[spawnIdx][mspUsed]) {
                CEFChat_Send(playerid, COLOR_MECH_ERROR_STR, "Эта машина уже занята или не является точкой спавна.");
                return 1;
            }

            PI[playerid][pCash] -= MECHANIC_RENT_PRICE;
            GivePlayerMoney(playerid, -MECHANIC_RENT_PRICE);
            UpdatePlayerHUD(playerid);
            new query[128];
            mysql_format(dbHandle, query, sizeof(query), "UPDATE `accounts` SET `cash`=%d WHERE `id`=%d", PI[playerid][pCash], PI[playerid][pID]);
            mysql_tquery(dbHandle, query, "", "");

            g_MechanicSpawns[spawnIdx][mspUsed] = true;
            g_MechanicWorking[playerid] = true;
            g_MechanicVehicle[playerid] = veh;
            g_MechanicContract[playerid] = -1;
            g_MechanicExitTimer[playerid] = -1;

            Mechanic_UpdateLabel(playerid);
            CEFChat_Send(playerid, COLOR_MECH_INFO_STR, "Вы арендовали транспорт механика за 5000 рублей");
            CEFChat_Send(playerid, COLOR_MECH_INFO_STR, "Воспользуйтесь меню механика, чтобы получить доступ ко всем функциям работы: Клавиша J");
            CEFChat_Send(playerid, COLOR_MECH_INFO_STR, "Подпишите контракт с любой АЗС, чтобы Вы могли заправлять игроков");
            DeletePVar(playerid, "MechSpawnIdx");
            SendSuccess(playerid, "Работа начата", "Вы приступили к работе механиком.");

            ShowPlayerDialogEx(playerid, MECHANIC_DIALOG_MENU, DIALOG_STYLE_LIST,
                "Меню механика",
                "Заключить контракт с АЗС\nЗаправить транспорт\nПочинить транспорт\n(скоро)\n(скоро)\n(скоро)\n(скоро)",
                "Выбрать", "Закрыть");
            return 1;
        }

        case MECHANIC_DIALOG_MENU: {
            if(!response) { 
                CEFChat_Send(playerid, "FFFFFF", "Вы закрыли меню."); 
                return 1; 
            }
            switch(listitem) {
                case 0: {
                    new azs = Mechanic_FindNearbyAZS(playerid);
                    if(azs == -1) {
                        CEFChat_Send(playerid, COLOR_MECH_ERROR_STR, "Вы должны находиться рядом с АЗС (/gps ? 8. Бизнесы ? 1. АЗС)");
                        return 1;
                    }
                    g_MechanicContract[playerid] = azs;
                    Mechanic_UpdateLabel(playerid);
                    new msg[128];
                    format(msg, sizeof(msg), "Вы подписали контракт с %s", g_MechanicAZS[azs][mazName]);
                    CEFChat_Send(playerid, COLOR_MECH_INFO_STR, msg);
                    CEFChat_Send(playerid, COLOR_MECH_INFO_STR, "С каждой заправки Вам будет приходить процент — зарплата");
                    CEFChat_Send(playerid, COLOR_MECH_INFO_STR, "Теперь Вы можете заправлять транспорт: Клавиша J");
                    return 1;
                }
                case 1: {
                    if(g_MechanicContract[playerid] == -1) {
                        CEFChat_Send(playerid, COLOR_MECH_ERROR_STR, "Сначала заключите контракт с АЗС.");
                        return 1;
                    }
                    Mechanic_ShowNearbyList(playerid, MECHANIC_DIALOG_REFUEL_LIST, "Заправка транспорта");
                    return 1;
                }
                case 2: {
                    Mechanic_ShowNearbyList(playerid, MECHANIC_DIALOG_REPAIR_LIST, "Починка транспорта");
                    return 1;
                }
                case 3, 4, 5, 6: {
                    ShowPlayerDialogEx(playerid, MECHANIC_DIALOG_STUB, DIALOG_STYLE_MSGBOX,
                        "Механик", "Скоро будет выполнено", "Ок", "");
                    return 1;
                }
            }
            return 1;
        }

        case MECHANIC_DIALOG_REFUEL_LIST: {
            if(!response) return 1;
            new target = Mechanic_GetListTarget(playerid, listitem);
            if(target == INVALID_PLAYER_ID) {
                CEFChat_Send(playerid, COLOR_MECH_ERROR_STR, "Игрок больше недоступен.");
                return 1;
            }
            new tveh = GetPlayerVehicleID(target);
            if(!IsValidVehicle(tveh)) {
                CEFChat_Send(playerid, COLOR_MECH_ERROR_STR, "Игрок не в транспорте.");
                return 1;
            }
            new fuel = CI[tveh][Fuel];
            if(fuel == -1) {
                CEFChat_Send(playerid, COLOR_MECH_ERROR_STR, "У этого транспорта нет системы топлива.");
                return 1;
            }
            if(fuel >= 100) {
                CEFChat_Send(playerid, COLOR_MECH_ERROR_STR, "Бак игрока полон, заправка не требуется.");
                return 1;
            }
            new liters = 100 - fuel;
            new price = liters * MECHANIC_REFUEL_PRICE_PER_L;
            g_MechanicSelectedTarget[playerid] = target;
            new msg[256];
            format(msg, sizeof(msg), "Вы хотите залить игроку \"%s\" %d литров топлива на сумму %d руб.?", GetName(target), liters, price);
            ShowPlayerDialogEx(playerid, MECHANIC_DIALOG_REFUEL_CONFIRM, DIALOG_STYLE_MSGBOX,
                "Подтверждение", msg, "Да", "Нет");
            return 1;
        }

        case MECHANIC_DIALOG_REFUEL_CONFIRM: {
            new target = g_MechanicSelectedTarget[playerid];
            g_MechanicSelectedTarget[playerid] = INVALID_PLAYER_ID;
            if(!response || target == INVALID_PLAYER_ID || !IsPlayerConnected(target)) return 1;
            new tveh = GetPlayerVehicleID(target);
            if(!IsValidVehicle(tveh)) {
                CEFChat_Send(playerid, COLOR_MECH_ERROR_STR, "Игрок больше не в транспорте.");
                return 1;
            }
            new fuel = CI[tveh][Fuel];
            if(fuel == -1) {
                CEFChat_Send(playerid, COLOR_MECH_ERROR_STR, "У этого транспорта нет системы топлива.");
                return 1;
            }
            if(fuel >= 100) {
                CEFChat_Send(playerid, COLOR_MECH_ERROR_STR, "Бак уже полон.");
                return 1;
            }
            new liters = 100 - fuel;
            new price = liters * MECHANIC_REFUEL_PRICE_PER_L;
            if(PI[target][pCash] < price) {
                CEFChat_Send(playerid, COLOR_MECH_ERROR_STR, "У игрока недостаточно денег для заправки.");
                return 1;
            }
            PI[target][pCash] -= price;
            GivePlayerMoney(target, -price);
            UpdatePlayerHUD(target);
            new query[128];
            mysql_format(dbHandle, query, sizeof(query), "UPDATE `accounts` SET `cash`=%d WHERE `id`=%d", PI[target][pCash], PI[target][pID]);
            mysql_tquery(dbHandle, query, "", "");

            PI[playerid][pCash] += price;
            GivePlayerMoney(playerid, price);
            UpdatePlayerHUD(playerid);
            mysql_format(dbHandle, query, sizeof(query), "UPDATE `accounts` SET `cash`=%d WHERE `id`=%d", PI[playerid][pCash], PI[playerid][pID]);
            mysql_tquery(dbHandle, query, "", "");

            CI[tveh][Fuel] = 100;
            new msg[128];
            format(msg, sizeof(msg), "Вы заправили транспорт игрока %s на %d литров, получили %d руб.", GetName(target), liters, price);
            CEFChat_Send(playerid, COLOR_MECH_INFO_STR, msg);
            format(msg, sizeof(msg), "Механик %s заправил Ваш транспорт на %d литров за %d руб.", GetName(playerid), liters, price);
            CEFChat_Send(target, COLOR_MECH_INFO_STR, msg);


            Skill_AddProgress(playerid, SKILL_MECHANIC, 1);
            return 1;
        }

        case MECHANIC_DIALOG_REPAIR_LIST: {
            if(!response) return 1;
            new target = Mechanic_GetListTarget(playerid, listitem);
            if(target == INVALID_PLAYER_ID) {
                CEFChat_Send(playerid, COLOR_MECH_ERROR_STR, "Игрок больше недоступен.");
                return 1;
            }
            new tveh = GetPlayerVehicleID(target);
            if(!IsValidVehicle(tveh)) {
                CEFChat_Send(playerid, COLOR_MECH_ERROR_STR, "Игрок не в транспорте.");
                return 1;
            }
            new Float:health;
            GetVehicleHealth(tveh, health);
            if(health >= 900.0) {
                CEFChat_Send(playerid, COLOR_MECH_ERROR_STR, "Транспорт игрока в отличном состоянии, ремонт не требуется.");
                return 1;
            }
            g_MechanicSelectedTarget[playerid] = target;
            new msg[128];
            format(msg, sizeof(msg), "Вы хотите починить машину игрока \"%s\" за %d руб.?", GetName(target), MECHANIC_REPAIR_PRICE);
            ShowPlayerDialogEx(playerid, MECHANIC_DIALOG_REPAIR_CONFIRM, DIALOG_STYLE_MSGBOX,
                "Подтверждение", msg, "Да", "Нет");
            return 1;
        }

        case MECHANIC_DIALOG_REPAIR_CONFIRM: {
            new target = g_MechanicSelectedTarget[playerid];
            g_MechanicSelectedTarget[playerid] = INVALID_PLAYER_ID;
            if(!response || target == INVALID_PLAYER_ID || !IsPlayerConnected(target)) return 1;
            new tveh = GetPlayerVehicleID(target);
            if(!IsValidVehicle(tveh)) {
                CEFChat_Send(playerid, COLOR_MECH_ERROR_STR, "Игрок больше не в транспорте.");
                return 1;
            }
            new Float:health;
            GetVehicleHealth(tveh, health);
            if(health >= 900.0) {
                CEFChat_Send(playerid, COLOR_MECH_ERROR_STR, "Транспорт уже в отличном состоянии.");
                return 1;
            }
            if(PI[target][pCash] < MECHANIC_REPAIR_PRICE) {
                CEFChat_Send(playerid, COLOR_MECH_ERROR_STR, "У игрока недостаточно денег для ремонта.");
                return 1;
            }
            PI[target][pCash] -= MECHANIC_REPAIR_PRICE;
            GivePlayerMoney(target, -MECHANIC_REPAIR_PRICE);
            UpdatePlayerHUD(target);
            new query[128];
            mysql_format(dbHandle, query, sizeof(query), "UPDATE `accounts` SET `cash`=%d WHERE `id`=%d", PI[target][pCash], PI[target][pID]);
            mysql_tquery(dbHandle, query, "", "");


            new bonusPerLevel = 5000;
            new repairPrice = MECHANIC_REPAIR_PRICE + (Skill_GetLevel(playerid, SKILL_MECHANIC) - 1) * bonusPerLevel;
            PI[playerid][pCash] += repairPrice;
            GivePlayerMoney(playerid, repairPrice);
            UpdatePlayerHUD(playerid);
            mysql_format(dbHandle, query, sizeof(query), "UPDATE `accounts` SET `cash`=%d WHERE `id`=%d", PI[playerid][pCash], PI[playerid][pID]);
            mysql_tquery(dbHandle, query, "", "");

            SetVehicleHealth(tveh, 1000.0);
            RepairVehicle(tveh);
            new msg[128];
            format(msg, sizeof(msg), "Вы починили транспорт игрока %s, получили %d руб.", GetName(target), repairPrice);
            CEFChat_Send(playerid, COLOR_MECH_INFO_STR, msg);
            format(msg, sizeof(msg), "Механик %s починил Ваш транспорт за %d руб.", GetName(playerid), MECHANIC_REPAIR_PRICE);
            CEFChat_Send(target, COLOR_MECH_INFO_STR, msg);


            Skill_AddProgress(playerid, SKILL_MECHANIC, 1);
            return 1;
        }

        case MECHANIC_DIALOG_STUB, MECHANIC_DIALOG_INFO: {
            return 1;
        }
    }
    return 1;
}


CMD:jmenu(playerid, params[]) {
    if(Razvoz_IsWorking(playerid)) {
        if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) {
            CEFChat_Send(playerid, COLOR_MECH_ERROR_STR, "Вы должны находиться в транспорте.");
            return 1;
        }
        new type = Razvoz_GetType(playerid);
        new menuText[512];
        if(type == 1) {
            format(menuText, sizeof(menuText),
                "Закупка товаров\nПродажа товаров\nСписок заказов\nЗагрузка дерева\nЗагрузка металла\nРазгрузка на заводе\nИнформация");
        } else if(type == 2) {
            format(menuText, sizeof(menuText),
                "Закупка топлива\nПродажа топлива\nСписок заказов\nИнформация");
        } else {
            CEFChat_Send(playerid, "FF4444", "Неизвестный тип работы.");
            return 1;
        }
        ShowPlayerDialogEx(playerid, RAZVOZ_DIALOG_MENU, DIALOG_STYLE_LIST,
            "Меню развозчика", menuText, "Выбрать", "Закрыть");
        return 1;
    }
    if(Mechanic_IsWorking(playerid)) {
        if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) {
            CEFChat_Send(playerid, COLOR_MECH_ERROR_STR, "Вы должны находиться в транспорте.");
            return 1;
        }
        ShowPlayerDialogEx(playerid, MECHANIC_DIALOG_MENU, DIALOG_STYLE_LIST,
            "Меню механика",
            "Заключить контракт с АЗС\nЗаправить транспорт\nПочинить транспорт\n(скоро)\n(скоро)\n(скоро)\n(скоро)",
            "Выбрать", "Закрыть");
        return 1;
    }
    CEFChat_Send(playerid, COLOR_MECH_ERROR_STR, "Вы не работаете ни на одной из работ.");
    return 1;
}

#pragma unused g_MechanicAZSCount
#pragma unused g_MechanicSelectedTarget
