#if defined _factory_inc
    #endinput
#endif
#define _factory_inc

#include "../include/jobs/skills.pwn"

#define FACTORY_REWARD      230000
#define FACTORY_SKIN        16
#define DIALOG_FACTORY_START 6000
#define dialog_FACTORY_INFO (DIALOG_FACTORY_START + 1)
#define DIALOG_FACTORY_STOP (DIALOG_FACTORY_START + 2)
#define DIALOG_FACTORY_STORAGE (DIALOG_FACTORY_START + 3)
#define FACTORY_WORLD       1
#define FACTORY_INTERIOR    0

#define FACTORY_STORAGE_X   851.0702
#define FACTORY_STORAGE_Y   2435.1201
#define FACTORY_STORAGE_Z   12.0000
#define FACTORY_COST_WOOD   2
#define FACTORY_COST_METAL  2
#define FACTORY_REWARD_STORAGE  100


#define FACTORY_ENTER_X     812.2437
#define FACTORY_ENTER_Y     2462.8161
#define FACTORY_ENTER_Z     2545.1171

#define FACTORY_EXIT_X      812.0922
#define FACTORY_EXIT_Y      2461.5844
#define FACTORY_EXIT_Z      2545.1171

#define FACTORY_NPC_X       811.2770
#define FACTORY_NPC_Y       2474.6403
#define FACTORY_NPC_Z       2545.1245

#define FACTORY_INFO_POS_X  815.7106
#define FACTORY_INFO_POS_Y  2470.1257
#define FACTORY_INFO_POS_Z  2545.1171

#define FACTORY_METAL_X     850.2045
#define FACTORY_METAL_Y     2470.5664
#define FACTORY_METAL_Z     2545.1093

#define FACTORY_WOOD_X      850.9191
#define FACTORY_WOOD_Y      2482.3349
#define FACTORY_WOOD_Z      2545.1093

#define FACTORY_GEAR_X      828.4168
#define FACTORY_GEAR_Y      2466.0468
#define FACTORY_GEAR_Z      2545.1152

#define FACTORY_PIPE_X      831.3828
#define FACTORY_PIPE_Y      2488.9296
#define FACTORY_PIPE_Z      2545.1152

#define FACTORY_CONVEYOR_X  875.3255
#define FACTORY_CONVEYOR_Y  2485.6386
#define FACTORY_CONVEYOR_Z  2545.1093


#define FACTORY_MACHINE_Z   2545.1093


#define FACTORY_MACHINE_1_X 875.3977
#define FACTORY_MACHINE_1_Y 2479.0310

#define FACTORY_MACHINE_2_X 872.3049
#define FACTORY_MACHINE_2_Y 2478.8300

#define FACTORY_MACHINE_3_X 868.9323
#define FACTORY_MACHINE_3_Y 2478.8322

#define FACTORY_MACHINE_4_X 865.7061
#define FACTORY_MACHINE_4_Y 2478.8325

#define FACTORY_MACHINE_5_X 865.8912
#define FACTORY_MACHINE_5_Y 2474.9414

#define FACTORY_MACHINE_6_X 868.8148
#define FACTORY_MACHINE_6_Y 2474.9433

#define FACTORY_MACHINE_7_X 872.4748
#define FACTORY_MACHINE_7_Y 2474.9433

#define FACTORY_MACHINE_8_X 875.8123
#define FACTORY_MACHINE_8_Y 2474.9455


enum E_FACTORY_PLAYER {
    bool:fp_Working,
    fp_WorkSkin,
    fp_Materials[4],
    fp_Sequence[9],
    fp_Slots[9],
    bool:fp_ItemReady,
    bool:fp_CEFOpen,
    fp_CurrentStep,
    fp_LastPickupTime,
    bool:fp_Animating,
    fp_OldWorld,
    fp_OldInterior
}
new g_FactoryPlayer[MAX_PLAYERS][E_FACTORY_PLAYER];


static const Float:FACTORY_PICKUP_MATERIALS[4][3] = {
    {FACTORY_GEAR_X, FACTORY_GEAR_Y, FACTORY_GEAR_Z},
    {FACTORY_METAL_X, FACTORY_METAL_Y, FACTORY_METAL_Z},
    {FACTORY_PIPE_X, FACTORY_PIPE_Y, FACTORY_PIPE_Z},
    {FACTORY_WOOD_X, FACTORY_WOOD_Y, FACTORY_WOOD_Z}
};

static const Float:FACTORY_INFO_PICKUP_POS[3] = {
    FACTORY_INFO_POS_X,
    FACTORY_INFO_POS_Y,
    FACTORY_INFO_POS_Z
};

static const Float:FACTORY_MACHINES[8][3] = {
    {FACTORY_MACHINE_1_X, FACTORY_MACHINE_1_Y, FACTORY_MACHINE_Z},
    {FACTORY_MACHINE_2_X, FACTORY_MACHINE_2_Y, FACTORY_MACHINE_Z},
    {FACTORY_MACHINE_3_X, FACTORY_MACHINE_3_Y, FACTORY_MACHINE_Z},
    {FACTORY_MACHINE_4_X, FACTORY_MACHINE_4_Y, FACTORY_MACHINE_Z},
    {FACTORY_MACHINE_5_X, FACTORY_MACHINE_5_Y, FACTORY_MACHINE_Z},
    {FACTORY_MACHINE_6_X, FACTORY_MACHINE_6_Y, FACTORY_MACHINE_Z},
    {FACTORY_MACHINE_7_X, FACTORY_MACHINE_7_Y, FACTORY_MACHINE_Z},
    {FACTORY_MACHINE_8_X, FACTORY_MACHINE_8_Y, FACTORY_MACHINE_Z}
};

static const Float:FACTORY_CONVEYOR[3] = {
    FACTORY_CONVEYOR_X,
    FACTORY_CONVEYOR_Y,
    FACTORY_CONVEYOR_Z
};


static g_FactoryNPC      = -1;
static g_FactoryArea     = -1;
static g_FactoryInfoArea = -1;
static g_FactoryExitArea = -1;
static g_FactoryPickups[4] = {-1, ...};
static g_FactoryInfoPickup = -1;

static g_FactoryMachineAreas[8] = {-1, ...};
static g_FactoryConveyorArea = -1;

new g_FactoryWood      = 0;
new g_FactoryMetal     = 0;
new g_FactoryMaterials = 0;
static Text3D:g_StorageLabel = Text3D:INVALID_3DTEXT_ID;
static g_StorageArea = -1;


forward LoadFactorySystem();
forward OnFactoryStorageLoaded();
forward FactoryFinishAnim(playerid);




public LoadFactorySystem() {
    mysql_tquery(dbHandle, "SELECT * FROM `factory_storage` LIMIT 1", "OnFactoryStorageLoaded", "");
    
    g_FactoryNPC = CreateDynamicActor(16, FACTORY_NPC_X, FACTORY_NPC_Y, FACTORY_NPC_Z, 0.0, 1, FACTORY_WORLD, FACTORY_INTERIOR);
    
    g_FactoryArea = CreateDynamicSphere(FACTORY_NPC_X, FACTORY_NPC_Y, FACTORY_NPC_Z, 1.5, FACTORY_WORLD, FACTORY_INTERIOR, -1);
    g_FactoryInfoArea = CreateDynamicSphere(FACTORY_INFO_POS_X, FACTORY_INFO_POS_Y, FACTORY_INFO_POS_Z, 1.5, FACTORY_WORLD, FACTORY_INTERIOR, -1);
    g_FactoryExitArea = CreateDynamicSphere(FACTORY_EXIT_X, FACTORY_EXIT_Y, FACTORY_EXIT_Z, 1.5, FACTORY_WORLD, FACTORY_INTERIOR, -1);


    for (new i = 0; i < 4; i++) {
        g_FactoryPickups[i] = CreatePickup(11780, 1,
            FACTORY_PICKUP_MATERIALS[i][0],
            FACTORY_PICKUP_MATERIALS[i][1],
            FACTORY_PICKUP_MATERIALS[i][2], FACTORY_WORLD);
    }


    g_FactoryInfoPickup = CreatePickup(1239, 23,
        FACTORY_INFO_POS_X, FACTORY_INFO_POS_Y, FACTORY_INFO_POS_Z, FACTORY_WORLD);
    


    for (new i = 0; i < 8; i++) {
        g_FactoryMachineAreas[i] = CreateDynamicSphere(
            FACTORY_MACHINES[i][0],
            FACTORY_MACHINES[i][1],
            FACTORY_MACHINES[i][2], 1.5, FACTORY_WORLD, FACTORY_INTERIOR, -1);
    }

    g_FactoryConveyorArea = CreateDynamicSphere(
        FACTORY_CONVEYOR_X,
        FACTORY_CONVEYOR_Y,
        FACTORY_CONVEYOR_Z, 1.5, FACTORY_WORLD, FACTORY_INTERIOR, -1);

    new label[64];
    for (new i = 0; i < 4; i++) {
        format(label, sizeof label, "%s", Factory_GetItemName(i));
        CreateDynamic3DTextLabel(label, 0xFFFFFFFF,
            FACTORY_PICKUP_MATERIALS[i][0],
            FACTORY_PICKUP_MATERIALS[i][1],
            FACTORY_PICKUP_MATERIALS[i][2] + 0.5,
            5.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, FACTORY_WORLD, FACTORY_INTERIOR, -1, 8.0);
    }

    CreateDynamic3DTextLabel("Работа фрезеровщиком\nНажмите ALT для информации", 0xFFFFFFFF,
        FACTORY_INFO_POS_X, FACTORY_INFO_POS_Y, FACTORY_INFO_POS_Z + 0.5,
        5.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, FACTORY_WORLD, FACTORY_INTERIOR, -1, 8.0);

    CreateDynamic3DTextLabel("Прораб\nНажмите ALT", 0xFFFFFFFF,
        FACTORY_NPC_X, FACTORY_NPC_Y, FACTORY_NPC_Z + 0.5,
        5.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, FACTORY_WORLD, FACTORY_INTERIOR, -1, 8.0);

    CreateDynamic3DTextLabel("Выход\nНажмите ALT", 0xFFFFFFFF,
        FACTORY_EXIT_X, FACTORY_EXIT_Y, FACTORY_EXIT_Z + 0.5,
        5.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, FACTORY_WORLD, FACTORY_INTERIOR, -1, 8.0);

    for (new i = 0; i < 8; i++) {
        CreateDynamic3DTextLabel("Фрезерный станок", 0xFFFFFFFF,
            FACTORY_MACHINES[i][0],
            FACTORY_MACHINES[i][1],
            FACTORY_MACHINES[i][2] + 0.5,
            5.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, FACTORY_WORLD, FACTORY_INTERIOR, -1, 8.0);
    }

    CreateDynamic3DTextLabel("Конвейер\nALT для сдачи", 0xFFFFFFFF,
        FACTORY_CONVEYOR_X, FACTORY_CONVEYOR_Y, FACTORY_CONVEYOR_Z + 0.5,
        5.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, FACTORY_WORLD, FACTORY_INTERIOR, -1, 8.0);

    g_StorageArea = CreateDynamicSphere(FACTORY_STORAGE_X, FACTORY_STORAGE_Y, FACTORY_STORAGE_Z, 2.0, 0, 0, -1);

    return 1;
}


public OnFactoryStorageLoaded() {
    if(cache_num_rows() > 0) {
        cache_get_value_name_int(0, "wood", g_FactoryWood);
        cache_get_value_name_int(0, "metal", g_FactoryMetal);
        cache_get_value_name_int(0, "materials", g_FactoryMaterials);
    } else {
        mysql_tquery(dbHandle, "INSERT INTO `factory_storage` (`wood`, `metal`, `materials`) VALUES (0,0,0)", "OnFactoryStorageLoaded", "");
        return;
    }
    UpdateStorageLabel();
    printf("[Factory] Склад загружен: дерево=%d, металл=%d, материалы=%d", g_FactoryWood, g_FactoryMetal, g_FactoryMaterials);
}

stock SaveFactoryStorage() {
    new query[256];
    mysql_format(dbHandle, query, sizeof(query),
        "UPDATE `factory_storage` SET `wood`=%d, `metal`=%d, `materials`=%d WHERE `id`=1",
        g_FactoryWood, g_FactoryMetal, g_FactoryMaterials);
    mysql_tquery(dbHandle, query, "", "");
}

stock UpdateStorageLabel() {
    if(g_StorageLabel != Text3D:INVALID_3DTEXT_ID) {
        DestroyDynamic3DTextLabel(g_StorageLabel);
        g_StorageLabel = Text3D:INVALID_3DTEXT_ID;
    }
    new text[512];
    format(text, sizeof(text),
        "{FF8800}Склад завода\n" \
        "{FFFFFF}Дерева: {FF0000}%d кг\n" \
        "{FFFFFF}Металла: {FF0000}%d кг\n" \
        "{FFFFFF}Материалов: {FF0000}%d ед.\n" \
        "{FFFFFF}Купить материалы – {FF8800}/buy",
        g_FactoryWood, g_FactoryMetal, g_FactoryMaterials);

    g_StorageLabel = CreateDynamic3DTextLabel(text, 0xFFFFFFFF,
        FACTORY_STORAGE_X, FACTORY_STORAGE_Y, FACTORY_STORAGE_Z + 1.0,
        10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0, -1, 20.0);
}


static stock Factory_GetItemName(type) {
    new name[32];
    switch(type) {
        case 0: format(name, sizeof name, "Шестигранник");
        case 1: format(name, sizeof name, "Металл");
        case 2: format(name, sizeof name, "Труба");
        case 3: format(name, sizeof name, "Древесина");
    }
    return name;
}

static stock Factory_GetItemIcon(type) {
    new icon[32];
    switch(type) {
        case 0: format(icon, sizeof icon, "gear.png");
        case 1: format(icon, sizeof icon, "metal.png");
        case 2: format(icon, sizeof icon, "pipe.png");
        case 3: format(icon, sizeof icon, "wood.png");
    }
    return icon;
}

static stock FactoryGenerateSequence(sequence[]) {
    new maxCounts[4] = {4, 4, 3, 3};
    new result[9];
    new count = 0;
    for (new i = 0; i < 4; i++) result[count++] = i;
    while (count < 9) {
        new avail[4], availCount = 0;
        for (new t = 0; t < 4; t++) {
            new c = 0;
            for (new j = 0; j < count; j++) if (result[j] == t) c++;
            if (c < maxCounts[t]) avail[availCount++] = t;
        }
        if (availCount == 0) break;
        result[count++] = avail[random(availCount)];
    }
    for (new i = count - 1; i > 0; i--) {
        new j = random(i + 1);
        new tmp = result[i];
        result[i] = result[j];
        result[j] = tmp;
    }
    for (new i = 0; i < 9; i++) sequence[i] = result[i];
}

static stock Factory_ReturnSkin(playerid) {
    if (g_FactoryPlayer[playerid][fp_WorkSkin] != 0) {
        SetPlayerSkin(playerid, g_FactoryPlayer[playerid][fp_WorkSkin]);
        g_FactoryPlayer[playerid][fp_WorkSkin] = 0;
    }
}

stock FactoryResetPlayer(playerid) {
    Factory_ReturnSkin(playerid);
    g_FactoryPlayer[playerid][fp_Working] = false;
    for (new i = 0; i < 4; i++) g_FactoryPlayer[playerid][fp_Materials][i] = 0;
    for (new i = 0; i < 9; i++) {
        g_FactoryPlayer[playerid][fp_Sequence][i] = -1;
        g_FactoryPlayer[playerid][fp_Slots][i] = -1;
    }
    g_FactoryPlayer[playerid][fp_ItemReady] = false;
    g_FactoryPlayer[playerid][fp_CEFOpen] = false;
    g_FactoryPlayer[playerid][fp_CurrentStep] = 0;
    g_FactoryPlayer[playerid][fp_Animating] = false;
    SetPlayerVirtualWorld(playerid, g_FactoryPlayer[playerid][fp_OldWorld]);
    SetPlayerInterior(playerid, g_FactoryPlayer[playerid][fp_OldInterior]);
    g_FactoryPlayer[playerid][fp_OldWorld] = 0;
    g_FactoryPlayer[playerid][fp_OldInterior] = 0;
}

static stock FactoryFinishOrder(playerid) {
    for (new i = 0; i < 4; i++) g_FactoryPlayer[playerid][fp_Materials][i] = 0;
    for (new i = 0; i < 9; i++) {
        g_FactoryPlayer[playerid][fp_Sequence][i] = -1;
        g_FactoryPlayer[playerid][fp_Slots][i] = -1;
    }
    g_FactoryPlayer[playerid][fp_ItemReady] = false;
    g_FactoryPlayer[playerid][fp_CEFOpen] = false;
    g_FactoryPlayer[playerid][fp_CurrentStep] = 0;
    g_FactoryPlayer[playerid][fp_Animating] = false;
}


static stock FactoryOpenCEF(playerid) {
    if (g_FactoryPlayer[playerid][fp_CEFOpen]) return;
    if (!g_FactoryPlayer[playerid][fp_Working]) {
        CEFChat_Send(playerid, "FF4444", "[Завод] Начните работу через прораба.");
        return;
    }
    if (GetPlayerVirtualWorld(playerid) != FACTORY_WORLD) {
        CEFChat_Send(playerid, "FF4444", "[Завод] Вы должны быть в цехе.");
        return;
    }
    for (new i = 0; i < 4; i++) {
        if (g_FactoryPlayer[playerid][fp_Materials][i] == 0) {
            CEFChat_Send(playerid, "FF4444", "[Завод] Возьмите все 4 типа материалов.");
            return;
        }
    }
    FactoryGenerateSequence(g_FactoryPlayer[playerid][fp_Sequence]);
    for (new i = 0; i < 9; i++) g_FactoryPlayer[playerid][fp_Slots][i] = -1;
    g_FactoryPlayer[playerid][fp_CurrentStep] = 0;
    g_FactoryPlayer[playerid][fp_ItemReady] = false;

    cef_create_browser(playerid, FACTORY_BROWSER, FACTORY_CEF_LINK, false, true);
    cef_focus_browser(playerid, FACTORY_BROWSER, true);
    cef_always_listen_keys(playerid, FACTORY_BROWSER, true);
    TogglePlayerControllable(playerid, 0);
    g_FactoryPlayer[playerid][fp_CEFOpen] = true;
}

static stock FactoryCloseCEF(playerid) {
    if (!g_FactoryPlayer[playerid][fp_CEFOpen]) return;
    cef_focus_browser(playerid, FACTORY_BROWSER, false);
    cef_hide_browser(playerid, FACTORY_BROWSER, true);
    cef_destroy_browser(playerid, FACTORY_BROWSER);
    cef_always_listen_keys(playerid, FACTORY_BROWSER, false);
    TogglePlayerControllable(playerid, 1);
    cef_emit_event(playerid, "game:showCursor", CEFINT(0));
    g_FactoryPlayer[playerid][fp_CEFOpen] = false;
}

forward FactorySendData(playerid);
public FactorySendData(playerid) {
    if (!IsPlayerConnected(playerid)) return;
    if (!g_FactoryPlayer[playerid][fp_CEFOpen]) return;

    new itemList[14];
    new idx = 0;
    for (new t = 0; t < 4; t++) {
        new count = (t == 0 || t == 1) ? 4 : 3;
        for (new j = 0; j < count; j++) {
            itemList[idx++] = t;
        }
    }
    for (new i = 13; i > 0; i--) {
        new j = random(i + 1);
        new tmp = itemList[i];
        itemList[i] = itemList[j];
        itemList[j] = tmp;
    }

    new json[1024];
    strcat(json, "{\"items\":[");
    for (new i = 0; i < 14; i++) {
        if (i > 0) strcat(json, ",");
        new tmp[64];
        format(tmp, sizeof tmp, "{\"type\":%d,\"name\":\"%s\",\"icon\":\"%s\"}",
            itemList[i],
            Factory_GetItemName(itemList[i]),
            Factory_GetItemIcon(itemList[i])
        );
        strcat(json, tmp);
    }
    strcat(json, "],\"sequence\":[");
    for (new i = 0; i < 9; i++) {
        if (i > 0) strcat(json, ",");
        new tmp[8];
        format(tmp, sizeof tmp, "%d", g_FactoryPlayer[playerid][fp_Sequence][i]);
        strcat(json, tmp);
    }
    strcat(json, "]}");

    cef_emit_event(playerid, "factory:open", CEFSTR(json));
    printf("[Factory] Данные отправлены в CEF (%d)", playerid);
}


callback::OnFactoryReady(playerid, const arguments[]) {
    #pragma unused arguments
    if (!IsPlayerConnected(playerid)) return 1;
    if (!g_FactoryPlayer[playerid][fp_CEFOpen]) return 1;
    SetTimerEx("FactorySendData", 100, false, "i", playerid);
    return 1;
}

callback::OnFactoryProgressComplete(playerid, const arguments[]) {
    if (!g_FactoryPlayer[playerid][fp_CEFOpen]) return 1;
    g_FactoryPlayer[playerid][fp_ItemReady] = true;
    CEFChat_Send(playerid, "54B367", "[Завод] Деталь готова! Отнесите её на конвейер.");
    printf("[Factory] %s завершил сборку детали.", GetName(playerid));
    FactoryCloseCEF(playerid);
    return 1;
}

callback::OnCloseFactory(playerid, const arguments[]) {
    FactoryCloseCEF(playerid);
    return 1;
}




stock FactoryOnEnterArea(playerid, areaid) {
    if (areaid == g_FactoryArea) {
        cef_emit_event(playerid, "game:ShowHint", CEFSTR("ALT"), CEFINT(2500));
    }
    if (areaid == g_FactoryInfoArea) {
        cef_emit_event(playerid, "game:ShowHint", CEFSTR("ALT"), CEFINT(2500));
    }
    if (areaid == g_FactoryExitArea) {
        cef_emit_event(playerid, "game:ShowHint", CEFSTR("ALT"), CEFINT(2500));
    }
    if (areaid == g_StorageArea) {
        cef_emit_event(playerid, "game:ShowHint", CEFSTR("ALT"), CEFINT(2500));
    }
    return 1;
}

stock FactoryOnKeyState(playerid, newkeys) {
    if (!(newkeys & KEY_WALK)) return;
    if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER) return;
    if (GetPlayerState(playerid) == PLAYER_STATE_WASTED) return;
    if (g_FactoryPlayer[playerid][fp_Animating]) return;



    if (GetPlayerVirtualWorld(playerid) != FACTORY_WORLD || GetPlayerInterior(playerid) != FACTORY_INTERIOR) return;


    if (IsPlayerInDynamicArea(playerid, g_FactoryExitArea)) {
        if (g_FactoryPlayer[playerid][fp_Working]) {
            CEFChat_Send(playerid, "FF4444", "[Завод] Сначала завершите работу через прораба.");
            return;
        }
        SetPlayerVirtualWorld(playerid, 0);
        SetPlayerInterior(playerid, 0);
        SetPlayerPos(playerid, FACTORY_STORAGE_X, FACTORY_STORAGE_Y, FACTORY_STORAGE_Z);
        SetCameraBehindPlayer(playerid);
        CEFChat_Send(playerid, "AAAAAA", "[Завод] Вы вышли из цеха.");
        return;
    }


    if (IsPlayerInDynamicArea(playerid, g_FactoryInfoArea)) {
        ShowPlayerDialogEx(playerid, dialog_FACTORY_INFO, DIALOG_STYLE_MSGBOX,
            "Работа фрезеровщиком",
            "Возьмите по одному каждого материала: Шестигранник, Металл, Труба, Древесина.\nПодойдите к любому станку и соберите деталь по образцу.\nГотовую деталь отнесите на конвейер.\nЗа каждую деталь вы получаете 30 000 руб.",
            "Понятно", "");
        return;
    }


    if (IsPlayerInDynamicArea(playerid, g_FactoryArea)) {
        if (g_FactoryPlayer[playerid][fp_Working]) {
            ShowPlayerDialogEx(playerid, DIALOG_FACTORY_STOP, DIALOG_STYLE_MSGBOX,
                "Завершение работы",
                "Вы действительно хотите закончить работу?\nВаш скин будет возвращён, а все материалы сброшены.",
                "Да, завершить", "Остаться");
        } else {
            ShowPlayerDialogEx(playerid, DIALOG_FACTORY_START, DIALOG_STYLE_MSGBOX,
                "Завод",
                "Вы хотите начать работу?\nПереодеться",
                "Переодеться", "Отказаться");
        }
        return;
    }


    if (IsPlayerInDynamicArea(playerid, g_StorageArea)) {
        new msg[256];
        format(msg, sizeof(msg),
            "Склад завода:\nДерева: %d кг\nМеталла: %d кг\nМатериалов: %d ед.",
            g_FactoryWood, g_FactoryMetal, g_FactoryMaterials);
        ShowPlayerDialogEx(playerid, DIALOG_FACTORY_STORAGE, DIALOG_STYLE_MSGBOX,
            "Склад завода", msg, "Закрыть", "");
        return;
    }


    if (!g_FactoryPlayer[playerid][fp_Working]) {
        CEFChat_Send(playerid, "FF4444", "[Завод] Начните работу через прораба.");
        return;
    }


    for (new i = 0; i < 4; i++) {
        if (GetPlayerDistanceFromPoint(playerid,
            FACTORY_PICKUP_MATERIALS[i][0],
            FACTORY_PICKUP_MATERIALS[i][1],
            FACTORY_PICKUP_MATERIALS[i][2]) <= 1.5) {

            if (g_FactoryPlayer[playerid][fp_Materials][i] >= 1) {
                CEFChat_Send(playerid, "FF4444", "[Завод] У вас уже есть этот материал.");
                return;
            }

            new bool:canTake = false;
            switch(i) {
                case 0, 1, 2: {
                    if (g_FactoryMetal >= FACTORY_COST_METAL) {
                        g_FactoryMetal -= FACTORY_COST_METAL;
                        canTake = true;
                    } else {
                        CEFChat_Send(playerid, "FF4444", "[Завод] На складе недостаточно металла.");
                        return;
                    }
                }
                case 3: {
                    if (g_FactoryWood >= FACTORY_COST_WOOD) {
                        g_FactoryWood -= FACTORY_COST_WOOD;
                        canTake = true;
                    } else {
                        CEFChat_Send(playerid, "FF4444", "[Завод] На складе недостаточно древесины.");
                        return;
                    }
                }
            }
            if (!canTake) return;

            SaveFactoryStorage();
            UpdateStorageLabel();

            g_FactoryPlayer[playerid][fp_Materials][i] = 1;
            g_FactoryPlayer[playerid][fp_Animating] = true;
            ApplyAnimation(playerid, "CARRY", "liftup", 4.0, 0, 0, 0, 0, 0);
            SetTimerEx("FactoryFinishAnim", 1500, false, "i", playerid);
            new msg[64];
            format(msg, sizeof msg, "[Завод] Вы взяли %s", Factory_GetItemName(i));
            CEFChat_Send(playerid, "54B367", msg);
            printf("[Factory] %s взял материал %s (списано со склада)", GetName(playerid), Factory_GetItemName(i));
            return;
        }
    }


    for (new i = 0; i < 8; i++) {
        if (IsPlayerInDynamicArea(playerid, g_FactoryMachineAreas[i])) {
            if (g_FactoryPlayer[playerid][fp_ItemReady]) {
                CEFChat_Send(playerid, "FF4444", "[Завод] Деталь уже готова! Отнесите на конвейер.");
                return;
            }
            for (new j = 0; j < 4; j++) {
                if (g_FactoryPlayer[playerid][fp_Materials][j] == 0) {
                    CEFChat_Send(playerid, "FF4444", "[Завод] Возьмите все 4 типа материалов.");
                    return;
                }
            }
            FactoryOpenCEF(playerid);
            return;
        }
    }


    if (IsPlayerInDynamicArea(playerid, g_FactoryConveyorArea)) {
        if (!g_FactoryPlayer[playerid][fp_ItemReady]) {
            CEFChat_Send(playerid, "FF4444", "[Завод] Нет готовой детали.");
            return;
        }
        g_FactoryPlayer[playerid][fp_Animating] = true;
        ApplyAnimation(playerid, "CARRY", "putdown", 4.0, 0, 0, 0, 0, 0);
        SetTimerEx("FactoryFinishAnim", 1500, false, "i", playerid);

        new baseReward = FACTORY_REWARD;
        new bonusPerLevel = 20000;
        new reward = Skill_GetRewardBonus(playerid, SKILL_FACTORY, baseReward, bonusPerLevel);

        PI[playerid][pCash] += reward;
        GivePlayerMoney(playerid, reward);
        UpdatePlayerHUD(playerid);
        new query[128];
        mysql_format(dbHandle, query, sizeof(query), "UPDATE `accounts` SET `cash`=%d WHERE `id`=%d", PI[playerid][pCash], PI[playerid][pID]);
        mysql_tquery(dbHandle, query, "", "");

        g_FactoryMaterials += FACTORY_REWARD_STORAGE;
        SaveFactoryStorage();
        UpdateStorageLabel();

        Skill_AddProgress(playerid, SKILL_FACTORY, 1);

        new msg[64];
        format(msg, sizeof msg, "[Завод] Вы сдали деталь и получили %d руб. Склад пополнен на %d материалов.", reward, FACTORY_REWARD_STORAGE);
        CEFChat_Send(playerid, "54B367", msg);
        printf("[Factory] %s сдал деталь (скилл %d), склад +%d материалов", GetName(playerid), Skill_GetLevel(playerid, SKILL_FACTORY), FACTORY_REWARD_STORAGE);

        FactoryFinishOrder(playerid);
        CEFChat_Send(playerid, "AAAAAA", "[Завод] Можете собирать следующую деталь.");
        return;
    }
}

public FactoryFinishAnim(playerid) {
    g_FactoryPlayer[playerid][fp_Animating] = false;
    return 1;
}




stock FactoryOnDialog(playerid, dialogid, response, listitem, inputtext[]) {
    #pragma unused listitem, inputtext
    if (dialogid == dialog_FACTORY_INFO || dialogid == DIALOG_FACTORY_STORAGE) {
        return 1;
    }

    if (dialogid == DIALOG_FACTORY_STOP) {
        if (response) {
            if (g_FactoryPlayer[playerid][fp_CEFOpen]) FactoryCloseCEF(playerid);
            Factory_ReturnSkin(playerid);
            FactoryResetPlayer(playerid);
            CEFChat_Send(playerid, "AAAAAA", "[Завод] Вы завершили работу. Приходите ещё!");
            printf("[Factory] %s завершил работу через прораба.", GetName(playerid));
        }
        return 1;
    }

    if (dialogid != DIALOG_FACTORY_START) return 0;
    if (!response) {
        CEFChat_Send(playerid, "AAAAAA", "[Завод] Вы отказались от работы.");
        return 1;
    }
    if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER || GetPlayerState(playerid) == PLAYER_STATE_WASTED) {
        CEFChat_Send(playerid, "FF4444", "[Завод] Вы не можете начать работу сейчас.");
        return 1;
    }
    g_FactoryPlayer[playerid][fp_OldWorld] = GetPlayerVirtualWorld(playerid);
    g_FactoryPlayer[playerid][fp_OldInterior] = GetPlayerInterior(playerid);
    g_FactoryPlayer[playerid][fp_WorkSkin] = GetPlayerSkin(playerid);
    SetPlayerSkin(playerid, FACTORY_SKIN);
    g_FactoryPlayer[playerid][fp_Working] = true;
    SetPlayerVirtualWorld(playerid, FACTORY_WORLD);
    SetPlayerInterior(playerid, FACTORY_INTERIOR);
    SetCameraBehindPlayer(playerid);
    for (new i = 0; i < 4; i++) g_FactoryPlayer[playerid][fp_Materials][i] = 0;
    for (new i = 0; i < 9; i++) {
        g_FactoryPlayer[playerid][fp_Sequence][i] = -1;
        g_FactoryPlayer[playerid][fp_Slots][i] = -1;
    }
    g_FactoryPlayer[playerid][fp_ItemReady] = false;
    g_FactoryPlayer[playerid][fp_CEFOpen] = false;
    g_FactoryPlayer[playerid][fp_CurrentStep] = 0;
    g_FactoryPlayer[playerid][fp_Animating] = false;
    CEFChat_Send(playerid, "54B367", "[Завод] Вы начали работу. Возьмите по одному каждого материала (шестерня, металл, труба, дерево).");
    printf("[Factory] %s начал работу на заводе.", GetName(playerid));
    SendSuccess(playerid, "Работа начата", "Вы приступили к работе на заводе.");
    return 1;
}




stock FactoryOnDisconnect(playerid) {
    if (g_FactoryPlayer[playerid][fp_CEFOpen]) FactoryCloseCEF(playerid);
    if (g_FactoryPlayer[playerid][fp_Working]) Factory_ReturnSkin(playerid);
    FactoryResetPlayer(playerid);
}




CMD:stopfactory(playerid, params[]) {
    if (!g_FactoryPlayer[playerid][fp_Working]) return SendClientMessage(playerid, -1, "[Завод] Вы не работаете.");
    if (g_FactoryPlayer[playerid][fp_CEFOpen]) FactoryCloseCEF(playerid);
    Factory_ReturnSkin(playerid);
    FactoryResetPlayer(playerid);
    CEFChat_Send(playerid, "AAAAAA", "[Завод] Вы завершили работу. Можете начать заново у прораба.");
    printf("[Factory] %s завершил работу по команде.", GetName(playerid));
    return 1;
}

CMD:resetfactory(playerid, params[]) {
    if (PI[playerid][pAdmin] < 2) return SendClientMessage(playerid, -1, "Нет прав.");
    new target = -1;
    if (sscanf(params, "u", target)) {
        for (new i = 0; i < MAX_PLAYERS; i++) {
            if (IsPlayerConnected(i)) {
                if (g_FactoryPlayer[i][fp_CEFOpen]) FactoryCloseCEF(i);
                if (g_FactoryPlayer[i][fp_Working]) {
                    Factory_ReturnSkin(i);
                    FactoryResetPlayer(i);
                }
            }
        }
        SendClientMessage(playerid, -1, "[Завод] Все состояния сброшены.");
        return 1;
    }
    if (!IsPlayerConnected(target)) return SendClientMessage(playerid, -1, "Игрок не найден.");
    if (g_FactoryPlayer[target][fp_CEFOpen]) FactoryCloseCEF(target);
    if (g_FactoryPlayer[target][fp_Working]) {
        Factory_ReturnSkin(target);
        FactoryResetPlayer(target);
    }
    new msg[64];
    format(msg, sizeof msg, "[Завод] Состояние игрока %d сброшено.", target);
    SendClientMessage(playerid, -1, msg);
    return 1;
}

CMD:givezavodmat(playerid, params[]) {
    if (PI[playerid][pAdmin] < 2) return SendClientMessage(playerid, -1, "Нет прав.");
    new type, amount;
    if (sscanf(params, "dd", type, amount) || amount <= 0) {
        SendClientMessage(playerid, -1, "Использование: /givezavodmat [1 - дерево | 2 - металл | 3 - готовые материалы] [кол-во]");
        return 1;
    }
    new msg[128];
    switch(type) {
        case 1: {
            g_FactoryWood += amount;
            SaveFactoryStorage();
            UpdateStorageLabel();
            format(msg, sizeof(msg), "[Завод] Древесина пополнена на %d кг. Теперь: %d кг.", amount, g_FactoryWood);
            SendClientMessage(playerid, -1, msg);
        }
        case 2: {
            g_FactoryMetal += amount;
            SaveFactoryStorage();
            UpdateStorageLabel();
            format(msg, sizeof(msg), "[Завод] Металл пополнен на %d кг. Теперь: %d кг.", amount, g_FactoryMetal);
            SendClientMessage(playerid, -1, msg);
        }
        case 3: {
            g_FactoryMaterials += amount;
            SaveFactoryStorage();
            UpdateStorageLabel();
            format(msg, sizeof(msg), "[Завод] Готовые материалы пополнены на %d ед. Теперь: %d ед.", amount, g_FactoryMaterials);
            SendClientMessage(playerid, -1, msg);
        }
        default: {
            SendClientMessage(playerid, -1, "Неверный тип. 1 - дерево, 2 - металл, 3 - готовые материалы.");
            return 1;
        }
    }
    return 1;
}

#pragma unused g_FactoryNPC, g_FactoryPickups, g_FactoryInfoPickup, g_FactoryMachineAreas, g_FactoryConveyorArea, g_FactoryArea, g_FactoryInfoArea, g_FactoryExitArea, FACTORY_CONVEYOR, FACTORY_INFO_PICKUP_POS
stock Factory_PayCraft(playerid)
{
    if (!IsPlayerConnected(playerid)) return 0;
    if (!g_FactoryPlayer[playerid][fp_Working]) return 0;
    new all = 1, j;
    for (j = 0; j < 4; j++) if (g_FactoryPlayer[playerid][fp_Materials][j] == 0) all = 0;
    if (!g_FactoryPlayer[playerid][fp_ItemReady])
    {
        if (!all) return -1;
        g_FactoryPlayer[playerid][fp_ItemReady] = true;
    }
    new baseReward = FACTORY_REWARD;
    new reward = Skill_GetRewardBonus(playerid, SKILL_FACTORY, baseReward, 20000);
    PI[playerid][pCash] += reward;
    GivePlayerMoney(playerid, reward);
    UpdatePlayerHUD(playerid);
    new query[128];
    mysql_format(dbHandle, query, sizeof(query), "UPDATE `accounts` SET `cash`=%d WHERE `id`=%d", PI[playerid][pCash], PI[playerid][pID]);
    mysql_tquery(dbHandle, query, "", "");
    g_FactoryMaterials += FACTORY_REWARD_STORAGE;
    SaveFactoryStorage();
    UpdateStorageLabel();
    Skill_AddProgress(playerid, SKILL_FACTORY, 1);
    FactoryFinishOrder(playerid);
    return reward;
}
