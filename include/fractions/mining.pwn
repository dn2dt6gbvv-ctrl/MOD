#define MINE_MAX_ORE        60
#define MINE_PARTS_MIN      9
#define MINE_PARTS_MAX      60
#define MINE_PAY_MIN        8232
#define MINE_PAY_MAX        12500
#define MINE_RESPAWN_TIME   900
#define MINE_HIT_CD         1
#define MINE_PICKUP_MODEL   11778
#define MINE_ORE_RADIUS     2.0
#define MINE_IDLE_TIMEOUT   30
#define MINE_NPC_SKIN       16
#define MINE_ACTIVE_ORE     30

static const Float:MINE_NPC_X   = 1199.5651;
static const Float:MINE_NPC_Y   = 1356.3553;
static const Float:MINE_NPC_Z   = 11.1678;
static const Float:MINE_ENTER_X = 1209.5081;
static const Float:MINE_ENTER_Y = 1361.0069;
static const Float:MINE_ENTER_Z = 11.1538;

static const Float:MINE_TP_X    = 1350.9576;
static const Float:MINE_TP_Y    = 1316.1286;
static const Float:MINE_TP_Z    = -8.8564;

static const Float:MINE_PLAYER_SPAWN_X = 1345.9576;
static const Float:MINE_PLAYER_SPAWN_Y = 1316.1286;
static const Float:MINE_PLAYER_SPAWN_Z = -8.8564;

static const Float:MINE_EXIT_X  = 1209.5081;
static const Float:MINE_EXIT_Y  = 1361.0069;
static const Float:MINE_EXIT_Z  = 11.1538;

enum E_ORE {
    ore_ID,
    ore_Active,
    ore_Progress,
    ore_MaxParts,
    ore_Miner,
    ore_Pickup,
    ore_Label,
    ore_Area,
    ore_RespawnTimer,
    Float:ore_X,
    Float:ore_Y,
    Float:ore_Z,
    Float:ore_RZ
}
static g_Ore[MINE_MAX_ORE][E_ORE];
static g_OreCount = 0;

enum E_MINE_PLR {
    mp_OreIdx,
    mp_HitTime,
    mp_IdleTimer,
    mp_InMine,
    mp_WorkSkin
}
static g_MPlr[MAX_PLAYERS][E_MINE_PLR];

static g_AreaNPC      = -1;
static g_AreaEntrance = -1;
static g_AreaExitNPC  = -1;

static stock Float:MineDist(Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2) {
    return floatsqroot((x1-x2)*(x1-x2) + (y1-y2)*(y1-y2) + (z1-z2)*(z1-z2));
}

static stock MineUpdateLabel(idx) {
    if(g_Ore[idx][ore_Label] != -1)
        DestroyDynamic3DTextLabel(Text3D:g_Ore[idx][ore_Label]);
    new lbl[32];
    new remaining = g_Ore[idx][ore_MaxParts] - g_Ore[idx][ore_Progress];
    format(lbl, sizeof lbl, "[%d / %d]", remaining, g_Ore[idx][ore_MaxParts]);
    g_Ore[idx][ore_Label] = _:CreateDynamic3DTextLabel(lbl, 0xFFFFFFFF,
        g_Ore[idx][ore_X], g_Ore[idx][ore_Y], g_Ore[idx][ore_Z] + 0.4,
        8.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0, 0, 8.0);
}

static stock MineSpawnOre(idx) {
    if(g_Ore[idx][ore_Pickup] != -1)
        DestroyPickup(g_Ore[idx][ore_Pickup]);
    g_Ore[idx][ore_Pickup] = CreatePickup(MINE_PICKUP_MODEL, 1,
        g_Ore[idx][ore_X], g_Ore[idx][ore_Y], g_Ore[idx][ore_Z], 0);
    g_Ore[idx][ore_Active]   = 1;
    g_Ore[idx][ore_Progress] = 0;
    g_Ore[idx][ore_MaxParts] = MINE_PARTS_MIN + random(MINE_PARTS_MAX - MINE_PARTS_MIN + 1);
    g_Ore[idx][ore_Miner]    = -1;
    g_Ore[idx][ore_Area] = CreateDynamicSphere(g_Ore[idx][ore_X], g_Ore[idx][ore_Y], g_Ore[idx][ore_Z],
        MINE_ORE_RADIUS + 0.5, 0, 0, -1);
    MineUpdateLabel(idx);
}

static stock MineDespawnOre(idx) {
    if(g_Ore[idx][ore_Pickup] != -1) {
        DestroyPickup(g_Ore[idx][ore_Pickup]);
        g_Ore[idx][ore_Pickup] = -1;
    }
    if(g_Ore[idx][ore_Label] != -1) {
        DestroyDynamic3DTextLabel(Text3D:g_Ore[idx][ore_Label]);
        g_Ore[idx][ore_Label] = -1;
    }
    if(g_Ore[idx][ore_Area] != -1) {
        DestroyDynamicArea(g_Ore[idx][ore_Area]);
        g_Ore[idx][ore_Area] = -1;
    }
    g_Ore[idx][ore_Active] = 0;
}

static stock MineOpenCEF(playerid, idx) {

    if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) {
        CEFChat_Send(playerid, "FF4444", "[Шахта] Нельзя добывать руду из транспорта.");
        return;
    }
    cef_create_browser(playerid, MINING_BROWSER, MINING_CEF_LINK, false, true);
    cef_focus_browser(playerid, MINING_BROWSER, true);
    cef_always_listen_keys(playerid, MINING_BROWSER, true);
    TogglePlayerControllable(playerid, 0);
    g_MPlr[playerid][mp_OreIdx] = idx;
    SetTimerEx("MineOnBrowserReady", 400, false, "i", playerid);
}

static stock MineCloseCEF(playerid) {
    cef_emit_event(playerid, "mining:close", CEFINT(1));
    cef_focus_browser(playerid, MINING_BROWSER, false);
    cef_hide_browser(playerid, MINING_BROWSER, true);
    cef_destroy_browser(playerid, MINING_BROWSER);
    cef_always_listen_keys(playerid, MINING_BROWSER, false);

    TogglePlayerControllable(playerid, 1);
    cef_emit_event(playerid, "game:showCursor", CEFINT(0));
}

static stock MineSendOpen(playerid, idx) {
    new json[64];
    format(json, sizeof json, "{\"event\":\"mining:open\",\"progress\":%d,\"total\":%d}",
        g_Ore[idx][ore_Progress], g_Ore[idx][ore_MaxParts]);
    cef_emit_event(playerid, "mining:open", CEFSTR(json));
}

static stock MineSendUpdate(playerid, idx) {
    new json[64];
    format(json, sizeof json, "{\"event\":\"mining:update\",\"progress\":%d,\"total\":%d}",
        g_Ore[idx][ore_Progress], g_Ore[idx][ore_MaxParts]);
    cef_emit_event(playerid, "mining:update", CEFSTR(json));
}

stock MineResetPlayer(playerid) {
    new idx = g_MPlr[playerid][mp_OreIdx];
    if(idx >= 0 && idx < g_OreCount)
        if(g_Ore[idx][ore_Miner] == playerid)
            g_Ore[idx][ore_Miner] = -1;
    g_MPlr[playerid][mp_OreIdx]  = -1;
    g_MPlr[playerid][mp_HitTime] = 0;
    if(g_MPlr[playerid][mp_IdleTimer] != -1) {
        KillTimer(g_MPlr[playerid][mp_IdleTimer]);
        g_MPlr[playerid][mp_IdleTimer] = -1;
    }
    ClearAnimations(playerid, 1);
    TogglePlayerControllable(playerid, 1);
}

static stock MineGetNearestOrePickup(playerid) {
    new Float:px, Float:py, Float:pz;
    GetPlayerPos(playerid, px, py, pz);
    for(new i = 0; i < g_OreCount; i++) {
        if(!g_Ore[i][ore_Active]) continue;
        if(g_Ore[i][ore_Pickup] == -1) continue;
        if(MineDist(px,py,pz, g_Ore[i][ore_X],g_Ore[i][ore_Y],g_Ore[i][ore_Z]) <= MINE_ORE_RADIUS)
            return i;
    }
    return -1;
}

static stock MineExitMine(playerid) {
    if(!g_MPlr[playerid][mp_InMine]) return;

    if(g_MPlr[playerid][mp_OreIdx] != -1)
        MineCloseCEF(playerid);
    if(g_MPlr[playerid][mp_WorkSkin] != 0)
        SetPlayerSkin(playerid, g_MPlr[playerid][mp_WorkSkin]);
    MineResetPlayer(playerid);
    g_MPlr[playerid][mp_InMine] = 0;
    g_MPlr[playerid][mp_WorkSkin] = 0;
    SetPlayerPos(playerid, MINE_EXIT_X, MINE_EXIT_Y, MINE_EXIT_Z);
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    SetCameraBehindPlayer(playerid);
    CEFChat_Send(playerid, "AAAAAA", "[Шахта] Вы поднялись на поверхность.");
}

forward LoadMineSystem();
public LoadMineSystem() {
    CreateActor(MINE_NPC_SKIN, MINE_NPC_X, MINE_NPC_Y, MINE_NPC_Z, 180.0);
    g_AreaNPC      = CreateDynamicSphere(MINE_NPC_X,   MINE_NPC_Y,   MINE_NPC_Z,   2.0, 0, 0, -1);
    g_AreaEntrance = CreateDynamicSphere(MINE_ENTER_X, MINE_ENTER_Y, MINE_ENTER_Z, 2.0, 0, 0, -1);
    CreateActor(MINE_NPC_SKIN, MINE_TP_X, MINE_TP_Y, MINE_TP_Z, 0.0);
    g_AreaExitNPC = CreateDynamicSphere(MINE_TP_X, MINE_TP_Y, MINE_TP_Z, 2.0, 0, 0, -1);
    mysql_tquery(dbHandle, "SELECT * FROM `mine_ore_points`", "OnMineOreLoaded", "");
    return 1;
}

forward OnMineOreLoaded();
public OnMineOreLoaded() {
    g_OreCount = 0;
    new rows = cache_num_rows();
    for(new i = 0; i < rows && i < MINE_MAX_ORE; i++) {
        cache_get_value_name_int(i,   "id", g_Ore[g_OreCount][ore_ID]);
        cache_get_value_name_float(i, "x",  g_Ore[g_OreCount][ore_X]);
        cache_get_value_name_float(i, "y",  g_Ore[g_OreCount][ore_Y]);
        cache_get_value_name_float(i, "z",  g_Ore[g_OreCount][ore_Z]);
        cache_get_value_name_float(i, "rz", g_Ore[g_OreCount][ore_RZ]);
        g_Ore[g_OreCount][ore_Pickup]       = -1;
        g_Ore[g_OreCount][ore_Label]        = -1;
        g_Ore[g_OreCount][ore_Area]         = -1;
        g_Ore[g_OreCount][ore_RespawnTimer] = -1;
        g_Ore[g_OreCount][ore_Active]       = 0;
        g_OreCount++;
    }
    new activeCount = 0, attempts = 0;
    while(activeCount < MINE_ACTIVE_ORE && attempts < 100) {
        attempts++;
        new idx = random(g_OreCount);
        if(!g_Ore[idx][ore_Active]) {
            MineSpawnOre(idx);
            activeCount++;
        }
    }
    printf("[Mine] Загружено %d точек руды, активировано %d.", g_OreCount, activeCount);
    return 1;
}

stock MineOnEnterArea(playerid, areaid) {
    if(areaid == g_AreaNPC || areaid == g_AreaEntrance) {
        cef_emit_event(playerid, "game:ShowHint", CEFSTR("Y"), CEFINT(2500));

        CEFChat_Send(playerid, "AAAAAA", "[Шахта] Нажмите Y для входа, ALT для добычи руды.");
    }
    if(areaid == g_AreaExitNPC) {
        cef_emit_event(playerid, "game:ShowHint", CEFSTR("Y"), CEFINT(2500));
    }
}

stock MineOnLeaveArea(playerid, areaid) {

    new idx = g_MPlr[playerid][mp_OreIdx];
    if(idx >= 0 && idx < g_OreCount) {
        if(g_Ore[idx][ore_Area] == areaid) {

            MineCloseCEF(playerid);
            MineResetPlayer(playerid);
            CEFChat_Send(playerid, "FF4444", "[Шахта] Вы вышли из зоны добычи руды.");
        }
    }
}

stock MineOnKeyState(playerid, newkeys) {
    if(newkeys & KEY_YES) {
        if(IsPlayerInDynamicArea(playerid, g_AreaNPC) ||
           IsPlayerInDynamicArea(playerid, g_AreaEntrance)) {
            if(g_MPlr[playerid][mp_InMine]) {
                CEFChat_Send(playerid, "FF4444", "[Шахта] Вы уже в шахте.");
                return;
            }
            ShowPlayerDialogEx(playerid, DIALOG_MINE_START, DIALOG_STYLE_MSGBOX,
                "Прораб",
                "Здравствуй, работяга! Готов спуститься в шахту?\n\nЖелезная руда ждёт тебя.\nНаграда: {E69348}8 232 - 12 500 руб.{FFFFFF} за каждую добытую частицу.\nКаждая руда содержит от 9 до 60 частиц.",
                "Спуститься", "Отказаться");
            return;
        }
        if(IsPlayerInDynamicArea(playerid, g_AreaExitNPC)) {
            if(g_MPlr[playerid][mp_InMine]) {
                MineExitMine(playerid);
            }
            return;
        }
    }
    if(newkeys & KEY_WALK) {
        if(!g_MPlr[playerid][mp_InMine]) return;
        if(g_MPlr[playerid][mp_OreIdx] != -1) {
            CEFChat_Send(playerid, "FF4444", "[Шахта] Вы уже добываете руду.");
            return;
        }

        if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) {
            CEFChat_Send(playerid, "FF4444", "[Шахта] Нельзя добывать руду из транспорта.");
            return;
        }
        new idx = MineGetNearestOrePickup(playerid);
        if(idx == -1) {
            CEFChat_Send(playerid, "AAAAAA", "[Шахта] Рядом нет руды.");
            return;
        }
        if(!g_Ore[idx][ore_Active]) {
            CEFChat_Send(playerid, "FF4444", "[Шахта] Руда уже добыта.");
            return;
        }
        if(g_Ore[idx][ore_Miner] != -1) {
            CEFChat_Send(playerid, "FF4444", "[Шахта] Руду уже добывают.");
            return;
        }
        g_Ore[idx][ore_Miner] = playerid;
        MineOpenCEF(playerid, idx);
    }
}

stock MineOnPickup(playerid, pickupid) {
    new idx = -1;
    for(new i = 0; i < g_OreCount; i++) {
        if(g_Ore[i][ore_Pickup] == pickupid) {
            idx = i;
            break;
        }
    }
    if(idx == -1) return;
    if(!g_MPlr[playerid][mp_InMine]) return;
    if(g_MPlr[playerid][mp_OreIdx] != -1) {
        CEFChat_Send(playerid, "FF4444", "[Шахта] Вы уже добываете руду.");
        return;
    }
    if(!g_Ore[idx][ore_Active]) {
        CEFChat_Send(playerid, "FF4444", "[Шахта] Руда уже добыта.");
        return;
    }
    if(g_Ore[idx][ore_Miner] != -1) {
        CEFChat_Send(playerid, "FF4444", "[Шахта] Руду уже добывают.");
        return;
    }
    g_Ore[idx][ore_Miner] = playerid;
    MineOpenCEF(playerid, idx);
}

stock MineOnDialog(playerid, dialogid, response, listitem, inputtext[]) {
    #pragma unused listitem, inputtext
    if(dialogid != DIALOG_MINE_START) return;
    if(!response) {
        CEFChat_Send(playerid, "AAAAAA", "[Шахта] Вы отказались от спуска.");
        return;
    }
    g_MPlr[playerid][mp_WorkSkin] = GetPlayerSkin(playerid);
    SetPlayerPos(playerid, MINE_PLAYER_SPAWN_X, MINE_PLAYER_SPAWN_Y, MINE_PLAYER_SPAWN_Z);
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    SetCameraBehindPlayer(playerid);
    SetPlayerSkin(playerid, 16);
    g_MPlr[playerid][mp_InMine]  = 1;
    g_MPlr[playerid][mp_OreIdx]  = -1;
    g_MPlr[playerid][mp_HitTime] = 0;
    CEFChat_Send(playerid, "54B367", "[Шахта] Вы в шахте! Подходите к руде и нажимайте ALT.");
}

forward MineOnBrowserReady(playerid);
public MineOnBrowserReady(playerid) {
    if(!IsPlayerConnected(playerid)) return 1;
    new idx = g_MPlr[playerid][mp_OreIdx];
    if(idx < 0 || idx >= g_OreCount) return 1;
    MineSendOpen(playerid, idx);
    return 1;
}

callback::OnMiningHit(playerid, const arguments[]) {
    new idx = g_MPlr[playerid][mp_OreIdx];
    if(idx < 0 || idx >= g_OreCount) return 1;
    if(!g_Ore[idx][ore_Active]) return 1;
    if(g_Ore[idx][ore_Miner] != playerid) return 1;
    

    if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) {
        MineCloseCEF(playerid);
        MineResetPlayer(playerid);
        CEFChat_Send(playerid, "FF4444", "[Шахта] Нельзя добывать руду из транспорта.");
        return 1;
    }
    
    new Float:px, Float:py, Float:pz;
    GetPlayerPos(playerid, px, py, pz);
    if(MineDist(px,py,pz,g_Ore[idx][ore_X],g_Ore[idx][ore_Y],g_Ore[idx][ore_Z]) > MINE_ORE_RADIUS + 1.0) {
        MineResetPlayer(playerid);
        MineCloseCEF(playerid);
        CEFChat_Send(playerid, "FF4444", "[Шахта] Вы отошли слишком далеко.");
        return 1;
    }
    
    new now = gettime();
    if(now - g_MPlr[playerid][mp_HitTime] < MINE_HIT_CD) return 1;
    g_MPlr[playerid][mp_HitTime] = now;
    
    ApplyAnimation(playerid, "BASEBALL", "Bat_1", 4.1, 0, 1, 1, 0, 0, 1);
    PlayerPlaySound(playerid, 1131, 0.0, 0.0, 0.0);
    
    g_Ore[idx][ore_Progress]++;
    MineUpdateLabel(idx);
    
    new pay = MINE_PAY_MIN + random(MINE_PAY_MAX - MINE_PAY_MIN + 1);
    PI[playerid][pCash] += pay;
    GivePlayerMoney(playerid, pay);
    UpdatePlayerHUD(playerid);
    
    new msg[80];
    format(msg, sizeof msg, "[Шахта] +%d руб. [%d/%d]", pay, g_Ore[idx][ore_Progress], g_Ore[idx][ore_MaxParts]);
    CEFChat_Send(playerid, "E69348", msg);
    
    MineSendUpdate(playerid, idx);
    
    if(g_MPlr[playerid][mp_IdleTimer] != -1)
        KillTimer(g_MPlr[playerid][mp_IdleTimer]);
    g_MPlr[playerid][mp_IdleTimer] = SetTimerEx("MineIdleExpire", MINE_IDLE_TIMEOUT * 1000, false, "i", playerid);
    
    if(g_Ore[idx][ore_Progress] >= g_Ore[idx][ore_MaxParts]) {
        new kg = 4 + random(6);
        PI[playerid][pOreKg] += kg;
        
        new completeMsg[128];
        format(completeMsg, sizeof completeMsg, "[Шахта] Руда добыта! Вы получили %d кг руды.", kg);
        CEFChat_Send(playerid, "3498DB", completeMsg);
        
        MineCloseCEF(playerid);
        MineResetPlayer(playerid);
        MineDespawnOre(idx);
        g_Ore[idx][ore_RespawnTimer] = SetTimerEx("MineOreRespawn", MINE_RESPAWN_TIME * 1000, false, "i", idx);
    }
    return 1;
}

callback::OnMiningCancel(playerid, const arguments[]) {
    #pragma unused arguments
    MineResetPlayer(playerid);
    MineCloseCEF(playerid);
    return 1;
}

forward MineOreRespawn(idx);
public MineOreRespawn(idx) {
    g_Ore[idx][ore_RespawnTimer] = -1;
    MineSpawnOre(idx);
    return 1;
}

forward MineIdleExpire(playerid);
public MineIdleExpire(playerid) {
    g_MPlr[playerid][mp_IdleTimer] = -1;
    if(!IsPlayerConnected(playerid)) return 1;
    MineResetPlayer(playerid);
    MineCloseCEF(playerid);
    CEFChat_Send(playerid, "FF4444", "[Шахта] Вы перестали добывать руду.");
    return 1;
}


CMD:cancelmine(playerid, params[]) {
    if(!g_MPlr[playerid][mp_InMine]) return SendClientMessage(playerid, -1, "[Шахта] Вы не в шахте.");
    if(g_MPlr[playerid][mp_OreIdx] == -1) return SendClientMessage(playerid, -1, "[Шахта] У вас нет активной добычи.");
    MineResetPlayer(playerid);
    MineCloseCEF(playerid);
    CEFChat_Send(playerid, "FF4444", "[Шахта] Вы отменили добычу руды.");
    return 1;
}

CMD:resetmine(playerid, params[]) {
    #pragma unused params
    if(PI[playerid][pAdmin] < 2) return SendClientMessage(playerid, -1, "Нет прав.");
    for(new i = 0; i < g_OreCount; i++) {
        if(g_Ore[i][ore_RespawnTimer] != -1) {
            KillTimer(g_Ore[i][ore_RespawnTimer]);
            g_Ore[i][ore_RespawnTimer] = -1;
        }
        new miner = g_Ore[i][ore_Miner];
        if(miner != -1 && IsPlayerConnected(miner)) {
            MineCloseCEF(miner);
            MineResetPlayer(miner);
        }
        MineDespawnOre(i);
    }
    new activeCount = 0, attempts = 0;
    while(activeCount < MINE_ACTIVE_ORE && attempts < 100) {
        attempts++;
        new idx = random(g_OreCount);
        if(!g_Ore[idx][ore_Active]) {
            MineSpawnOre(idx);
            activeCount++;
        }
    }
    SendClientMessage(playerid, -1, "[Шахта] Шахта сброшена.");
    return 1;
}

CMD:addorepoint(playerid, params[]) {
    #pragma unused params
    if(PI[playerid][pAdmin] < 2) return SendClientMessage(playerid, -1, "Нет прав.");
    if(g_OreCount >= MINE_MAX_ORE) return SendClientMessage(playerid, -1, "[Шахта] Лимит точек.");
    if(GetPlayerVirtualWorld(playerid) != 0)
        return SendClientMessage(playerid, -1, "[Шахта] Вы должны быть в шахте (мир 0).");
    new Float:x, Float:y, Float:z, Float:a;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);
    new query[192];
    mysql_format(dbHandle, query, sizeof query,
        "INSERT INTO `mine_ore_points` (`x`,`y`,`z`,`rz`) VALUES ('%.4f','%.4f','%.4f','%.4f')",
        x, y, z, a);
    mysql_tquery(dbHandle, query, "OnOrePointAdded", "i", playerid);
    return 1;
}

forward OnOrePointAdded(playerid);
public OnOrePointAdded(playerid) {
    if(!IsPlayerConnected(playerid)) return 1;
    new id = cache_insert_id();
    new Float:x, Float:y, Float:z, Float:a;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);

    new idx = g_OreCount;
    g_Ore[idx][ore_ID]           = id;
    g_Ore[idx][ore_X]            = x;
    g_Ore[idx][ore_Y]            = y;
    g_Ore[idx][ore_Z]            = z;
    g_Ore[idx][ore_RZ]           = a;
    g_Ore[idx][ore_Pickup]       = -1;
    g_Ore[idx][ore_Label]        = -1;
    g_Ore[idx][ore_Area]         = -1;
    g_Ore[idx][ore_RespawnTimer] = -1;
    g_Ore[idx][ore_Active]       = 0;
    g_OreCount++;

    new activeCount = 0;
    for(new i = 0; i < g_OreCount; i++)
        if(g_Ore[i][ore_Active]) activeCount++;

    if(activeCount >= MINE_ACTIVE_ORE) {
        for(new i = 0; i < g_OreCount - 1; i++) {
            if(g_Ore[i][ore_Active]) {
                new miner = g_Ore[i][ore_Miner];
                if(miner != -1 && IsPlayerConnected(miner)) {
                    MineCloseCEF(miner);
                    MineResetPlayer(miner);
                }
                MineDespawnOre(i);
                break;
            }
        }
    }
    MineSpawnOre(idx);

    new msg[80];
    format(msg, sizeof msg, "[Шахта] Точка #%d добавлена и активирована. Всего: %d.", id, g_OreCount);
    SendClientMessage(playerid, -1, msg);
    return 1;
}

CMD:delorepoint(playerid, params[]) {
    if(PI[playerid][pAdmin] < 2) return SendClientMessage(playerid, -1, "Нет прав.");
    new id;
    if(sscanf(params, "d", id)) return SendClientMessage(playerid, -1, "Использование: /delorepoint [id]");
    new idx = -1;
    for(new i = 0; i < g_OreCount; i++)
        if(g_Ore[i][ore_ID] == id) { idx = i; break; }
    if(idx == -1) return SendClientMessage(playerid, -1, "[Шахта] Точка не найдена.");
    new miner = g_Ore[idx][ore_Miner];
    if(miner != -1 && IsPlayerConnected(miner)) {
        MineCloseCEF(miner);
        MineResetPlayer(miner);
    }
    MineDespawnOre(idx);
    if(g_Ore[idx][ore_RespawnTimer] != -1) {
        KillTimer(g_Ore[idx][ore_RespawnTimer]);
        g_Ore[idx][ore_RespawnTimer] = -1;
    }
    for(new i = idx; i < g_OreCount - 1; i++) g_Ore[i] = g_Ore[i+1];
    g_OreCount--;
    new query[80];
    mysql_format(dbHandle, query, sizeof query, "DELETE FROM `mine_ore_points` WHERE `id`=%d", id);
    mysql_tquery(dbHandle, query, "", "");
    new msg[64];
    format(msg, sizeof msg, "[Шахта] Точка #%d удалена.", id);
    SendClientMessage(playerid, -1, msg);
    return 1;
}

CMD:listorepoints(playerid, params[]) {
    #pragma unused params
    if(PI[playerid][pAdmin] < 2) return SendClientMessage(playerid, -1, "Нет прав.");
    if(g_OreCount == 0) return SendClientMessage(playerid, -1, "[Шахта] Точек нет.");
    new str[512];
    for(new i = 0; i < g_OreCount; i++) {
        new tmp[64];
        format(tmp, sizeof tmp, "#%d: %.1f %.1f %.1f\n",
            g_Ore[i][ore_ID], g_Ore[i][ore_X], g_Ore[i][ore_Y], g_Ore[i][ore_Z]);
        strcat(str, tmp);
        if(strlen(str) > 430) { strcat(str, "..."); break; }
    }
    SendClientMessage(playerid, -1, str);
    return 1;
}
