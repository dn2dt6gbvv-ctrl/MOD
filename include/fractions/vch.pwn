#if defined _VCH_INCLUDED
    #endinput
#endif
#define _VCH_INCLUDED






#define MAX_VCH_POSTS       20
#define VCH_POST_REWARD     250000
#define VCH_POST_TIME       900   
#define VCH_BILYET_POSTS    2     
#define VCH_BILYET_DAYS     3    

new gate_vch_main;
new bool:gate_main_open = false;

enum E_VCH_POST {
    vpost_ID,
    vpost_Name[64],
    Float:vpost_X, Float:vpost_Y, Float:vpost_Z,
    vpost_MaxPlayers,
    vpost_Label,
    vpost_Area,
    vpost_Count
}
new g_VchPost[MAX_VCH_POSTS][E_VCH_POST];
new g_VchPostCount = 0;

new g_PostTimer[MAX_PLAYERS]   = {-1, ...};
new g_PostIdx[MAX_PLAYERS]     = {-1, ...};
new g_PostSeconds[MAX_PLAYERS] = {0, ...};

enum E_VCH_BILYET {
    vb_PlayerID,
    vb_Psych,
    vb_Ustav,
    vb_Parachute,
    vb_PostCount,
    vb_DaysInOrg,
    vb_Issued,
    vb_JoinDate[32]
}
new g_VchBilyet[MAX_PLAYERS][E_VCH_BILYET];


new g_PsychQ[MAX_PLAYERS] = {0, ...};
new g_UstavQ[MAX_PLAYERS] = {0, ...};


static const g_PsychQuestions[][128] = {
    "Что такое ДМ (Death Match)?",
    "Что такое МГ (Meta Game)?",
    "Что такое ПГ (Power Game)?",
    "Убьёте ли вы человека без причины?",
    "Вам прикажут прыгнуть с крыши. Вы сделаете это?"
};
static const g_PsychAnswers[][3][96] = {
    {"Убийство игрока без RP причины", "Использование внеигровой информации", "Принуждение другого игрока"},
    {"Убийство игрока без RP причины", "Использование внеигровой информации в игре", "Игнорирование правил сервера"},
    {"Принуждение игрока к действиям без его согласия", "Убийство без причины", "Нарушение правил чата"},
    {"Да", "Нет", "Зависит от ситуации"},
    {"Да", "Нет", "Только если разрешат"}
};
static const g_PsychCorrect[] = {0, 1, 0, 1, 1};


static const g_UstavQuestions[][128] = {
    "Можно ли просить проверить рапорт?",
    "Можно ли разговаривать в строю?",
    "Можно ли встать в строй при опоздании без разрешения?",
    "Можно ли покидать военную часть без разрешения?",
    "Можно ли общаться на 'ты' со старшим по званию?",
    "Можно ли спать на посту?",
    "Можно ли спать вне расположения без разрешения?",
    "Обязан ли военнослужащий докладывать о нарушениях?",
    "Можно ли использовать личное оружие на территории части?",
    "Обязан ли солдат выполнять приказы командира?"
};
static const g_UstavAnswers[][2][32] = {
    {"Да", "Нет"},
    {"Да", "Нет"},
    {"Да", "Нет"},
    {"Да", "Нет"},
    {"Да", "Нет"},
    {"Да", "Нет"},
    {"Да", "Нет"},
    {"Да", "Нет"},
    {"Да", "Нет"},
    {"Да", "Нет"}
};
static const g_UstavCorrect[] = {1, 1, 1, 1, 1, 1, 1, 0, 1, 0};



stock InitVchWarehouse()
{
    CreateDynamicPickup(347, 2, VCH_SCLAD_X, VCH_SCLAD_Y, VCH_SCLAD_Z, -1, -1, -1, 10.0);
    CreateDynamic3DTextLabel("Склад ВЧ", 0xFFFFFFFF, VCH_SCLAD_X, VCH_SCLAD_Y, VCH_SCLAD_Z + 0.5, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, -1, -1, -1, 10.0);
    return 1;
}

cmd:vchs(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;
    if(PI[playerid][pFraction] != 6)
        return SendErr(playerid, "Вы не являетесь сотрудником Воинской части!");
    if(!PT[playerid][pDuty])
        return SendErr(playerid, "Вы должны начать рабочий день, чтобы открыть склад!");
    if(!IsPlayerInRangeOfPoint(playerid, 3.0, VCH_SCLAD_X, VCH_SCLAD_Y, VCH_SCLAD_Z))
        return SendErr(playerid, "Вы должны находиться у оружейного склада ВЧ!");

    cef_create_browser(playerid, VCH_WAREHOUSE_BROWSER, VCH_WAREHOUSE_LINK, false, true);
    cef_focus_browser(playerid, VCH_WAREHOUSE_BROWSER, true);
    TogglePlayerControllable(playerid, 0);
    return 1;
}

forward CloseVchWarehouse(playerid);
public CloseVchWarehouse(playerid)
{
    cef_focus_browser(playerid, VCH_WAREHOUSE_BROWSER, false);
    cef_hide_browser(playerid, VCH_WAREHOUSE_BROWSER, true);
    cef_destroy_browser(playerid, VCH_WAREHOUSE_BROWSER);
    TogglePlayerControllable(playerid, 1);
    cef_emit_event(playerid, "game:showCursor", CEFINT(0));
    return 1;
}

forward OnVchWarehouseTake(playerid, const item[]);
public OnVchWarehouseTake(playerid, const item[])
{
    if(PI[playerid][pFraction] != 6) return 1;

    if(!strcmp(item, "svd", true))
    {
        GivePlayerWeapon(playerid, 34, 50);
        SendClientMessage(playerid, -1, "{E69348}[Склад ВЧ] {FFFFFF}Вы взяли СВД ПСО.");
        SendWarehouseRadio(playerid, "СВД ПСО");
    }
    else if(!strcmp(item, "aks74u", true))
    {
        GivePlayerWeapon(playerid, 29, 150);
        SendClientMessage(playerid, -1, "{E69348}[Склад ВЧ] {FFFFFF}Вы взяли АКС-74У.");
        SendWarehouseRadio(playerid, "АКС-74У");
    }
    else if(!strcmp(item, "saiga", true))
    {
        GivePlayerWeapon(playerid, 27, 60);
        SendClientMessage(playerid, -1, "{E69348}[Склад ВЧ] {FFFFFF}Вы взяли Сайгу.");
        SendWarehouseRadio(playerid, "Сайга");
    }
    else if(!strcmp(item, "armor", true))
    {
        SetPlayerArmour(playerid, 100.0);
        SendClientMessage(playerid, -1, "{E69348}[Склад ВЧ] {FFFFFF}Вы взяли Бронежилет.");
        SendWarehouseRadio(playerid, "Бронежилет");
    }
    else if(!strcmp(item, "as_val", true))
    {
        GivePlayerWeapon(playerid, 31, 100);
        SendClientMessage(playerid, -1, "{E69348}[Склад ВЧ] {FFFFFF}Вы взяли АС «ВАЛ».");
        SendWarehouseRadio(playerid, "АС ВАЛ");
    }
    else if(!strcmp(item, "tt_pistol", true))
    {
        GivePlayerWeapon(playerid, 24, 35);
        SendClientMessage(playerid, -1, "{E69348}[Склад ВЧ] {FFFFFF}Вы взяли Пистолет ТТ.");
        SendWarehouseRadio(playerid, "Пистолет ТТ");
    }
    else if(!strcmp(item, "bizon", true))
    {
        GivePlayerWeapon(playerid, 29, 64);
        SendClientMessage(playerid, -1, "{E69348}[Склад ВЧ] {FFFFFF}Вы взяли ПП Бизон.");
        SendWarehouseRadio(playerid, "ПП Бизон");
    }
    else if(!strcmp(item, "baton", true))
    {
        GivePlayerWeapon(playerid, 3, 1);
        SendClientMessage(playerid, -1, "{E69348}[Склад ВЧ] {FFFFFF}Вы взяли Дубинку.");
        SendWarehouseRadio(playerid, "Дубинка");
    }
    else if(!strcmp(item, "grenade", true))
    {
        SendErr(playerid, "Данный предмет вам недоступен!");
        return 1;
    }
    else if(!strcmp(item, "parachute", true))
    {
        GivePlayerWeapon(playerid, 46, 1);
        SendClientMessage(playerid, -1, "{E69348}[Склад ВЧ] {FFFFFF}Вы взяли Парашют.");
        SendWarehouseRadio(playerid, "Парашют");
    }
    else if(!strcmp(item, "medkit", true))
    {
        SendClientMessage(playerid, -1, "{E69348}[Склад ВЧ] {FFFFFF}Вы взяли Аптечку.");
        SendWarehouseRadio(playerid, "Аптечка");
    }
    return 1;
}

callback::OnCloseArmyWarehouse(playerid, const arguments[])
{
    CloseVchWarehouse(playerid);
    return 1;
}

callback::OnArmyWarehouseTake(playerid, const arguments[])
{
    OnVchWarehouseTake(playerid, arguments);
    return 1;
}

forward LoadVchPosts();
public LoadVchPosts() {
    gate_vch_main = CreateObject(12549, 1683.75, 1709.09, 16.1716, 0.0, 0.0, 90.0);
    mysql_tquery(dbHandle, "SELECT * FROM `vch_posts`", "OnVchPostsLoaded", "");
    return 1;
}

forward OnVchPostsLoaded();
public OnVchPostsLoaded() {
    g_VchPostCount = 0;
    new rows = cache_num_rows();
    for(new i = 0; i < rows && i < MAX_VCH_POSTS; i++) {
        new id, name[64]; new Float:x, Float:y, Float:z; new maxp;
        cache_get_value_name_int(i, "id", id);
        cache_get_value_name(i, "name", name, sizeof(name));
        cache_get_value_name_float(i, "x", x);
        cache_get_value_name_float(i, "y", y);
        cache_get_value_name_float(i, "z", z);
        cache_get_value_name_int(i, "max_players", maxp);
        new idx = g_VchPostCount;
        g_VchPost[idx][vpost_ID] = id;
        format(g_VchPost[idx][vpost_Name], 64, "%s", name);
        g_VchPost[idx][vpost_X] = x;
        g_VchPost[idx][vpost_Y] = y;
        g_VchPost[idx][vpost_Z] = z;
        g_VchPost[idx][vpost_MaxPlayers] = maxp ? maxp : 4;
        g_VchPost[idx][vpost_Count] = 0;
        VchPost_CreateLabel(idx);
        g_VchPost[idx][vpost_Area] = CreateDynamicSphere(x, y, z, 3.0);
        g_VchPostCount++;
    }
    printf("[VCH] Загружено постов: %d", g_VchPostCount);
    return 1;
}

stock VchPost_UpdateLabel(idx) {
    if(g_VchPost[idx][vpost_Label]) DestroyDynamic3DTextLabel(Text3D:g_VchPost[idx][vpost_Label]);
    new label[128];
    format(label, sizeof(label), "{e69348}Военный пост\n{FFFFFF}%s\n{AAAAAA}%d/%d чел.",
        g_VchPost[idx][vpost_Name], g_VchPost[idx][vpost_Count], g_VchPost[idx][vpost_MaxPlayers]);
    g_VchPost[idx][vpost_Label] = _:CreateDynamic3DTextLabel(label, -1,
        g_VchPost[idx][vpost_X], g_VchPost[idx][vpost_Y], g_VchPost[idx][vpost_Z]+1.0,
        15.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0);
}

stock VchPost_CreateLabel(idx) {
    VchPost_UpdateLabel(idx);
}


stock LoadVchBilyet(playerid) {
    new query[128];
    mysql_format(dbHandle, query, sizeof(query),
        "SELECT * FROM `vch_bilyet` WHERE `player_id`=%d LIMIT 1", PI[playerid][pID]);
    mysql_tquery(dbHandle, query, "OnVchBilyetLoaded", "i", playerid);
}

forward OnVchBilyetLoaded(playerid);
public OnVchBilyetLoaded(playerid) {
    if(!IsPlayerConnected(playerid)) return 1;
    if(!cache_num_rows()) {

        g_VchBilyet[playerid][vb_Psych] = 0;
        g_VchBilyet[playerid][vb_Ustav] = 0;
        g_VchBilyet[playerid][vb_Parachute] = 1;
        g_VchBilyet[playerid][vb_PostCount] = 0;
        g_VchBilyet[playerid][vb_DaysInOrg] = 0;
        g_VchBilyet[playerid][vb_Issued] = 0;
        format(g_VchBilyet[playerid][vb_JoinDate], 32, "");
        new query[256];
        mysql_format(dbHandle, query, sizeof(query),
            "INSERT IGNORE INTO `vch_bilyet` (`player_id`,`join_date`) VALUES (%d, NOW())",
            PI[playerid][pID]);
        mysql_tquery(dbHandle, query, "", "");
        return 1;
    }
    cache_get_value_name_int(0, "psych_test",  g_VchBilyet[playerid][vb_Psych]);
    cache_get_value_name_int(0, "ustav_test",  g_VchBilyet[playerid][vb_Ustav]);
    cache_get_value_name_int(0, "parachute",   g_VchBilyet[playerid][vb_Parachute]);
    cache_get_value_name_int(0, "post_count",  g_VchBilyet[playerid][vb_PostCount]);
    cache_get_value_name_int(0, "days_in_org", g_VchBilyet[playerid][vb_DaysInOrg]);
    cache_get_value_name_int(0, "issued",      g_VchBilyet[playerid][vb_Issued]);
    cache_get_value_name(0, "join_date", g_VchBilyet[playerid][vb_JoinDate], 32);
    return 1;
}

stock SaveVchBilyet(playerid) {
    new query[512];
    mysql_format(dbHandle, query, sizeof(query),
        "INSERT INTO `vch_bilyet` (`player_id`,`psych_test`,`ustav_test`,`parachute`,`post_count`,`days_in_org`,`issued`,`join_date`) \
         VALUES (%d,%d,%d,%d,%d,%d,%d,NOW()) \
         ON DUPLICATE KEY UPDATE `psych_test`=%d,`ustav_test`=%d,`parachute`=%d,`post_count`=%d,`days_in_org`=%d,`issued`=%d",
        PI[playerid][pID],
        g_VchBilyet[playerid][vb_Psych], g_VchBilyet[playerid][vb_Ustav],
        g_VchBilyet[playerid][vb_Parachute], g_VchBilyet[playerid][vb_PostCount],
        g_VchBilyet[playerid][vb_DaysInOrg], g_VchBilyet[playerid][vb_Issued],
        g_VchBilyet[playerid][vb_Psych], g_VchBilyet[playerid][vb_Ustav],
        g_VchBilyet[playerid][vb_Parachute], g_VchBilyet[playerid][vb_PostCount],
        g_VchBilyet[playerid][vb_DaysInOrg], g_VchBilyet[playerid][vb_Issued]);
    mysql_tquery(dbHandle, query, "", "");
}

stock VchBilyet_Check(playerid) {
    if(g_VchBilyet[playerid][vb_Issued]) return;
    if(g_VchBilyet[playerid][vb_Psych] &&
       g_VchBilyet[playerid][vb_Ustav] &&
       g_VchBilyet[playerid][vb_Parachute] &&
       g_VchBilyet[playerid][vb_PostCount] >= VCH_BILYET_POSTS &&
       g_VchBilyet[playerid][vb_DaysInOrg] >= VCH_BILYET_DAYS) {
        g_VchBilyet[playerid][vb_Issued] = 1;
        PT[playerid][pVchBilyet] = 1;
        SaveVchBilyet(playerid);
        new query[96];
        mysql_format(dbHandle, query, sizeof(query),
            "UPDATE `accounts` SET `vch_bilyet`=1 WHERE `id`=%d", PI[playerid][pID]);
        mysql_tquery(dbHandle, query, "", "");
        CEFChat_Send(playerid, "54B367", "Поздравляем! Вам выдан {e69348}Военный билет{54B367}.");
    }
}


forward VchPostTick(playerid);
public VchPostTick(playerid) {
    if(!IsPlayerConnected(playerid)) return 1;
    new idx = g_PostIdx[playerid];
    if(idx < 0 || idx >= g_VchPostCount) return 1;

    if(!IsPlayerInRangeOfPoint(playerid, 4.0,
        g_VchPost[idx][vpost_X], g_VchPost[idx][vpost_Y], g_VchPost[idx][vpost_Z])) {
        VchPost_Leave(playerid, false);
        CEFChat_Send(playerid, "FF4444", "Вы покинули пост. Прогресс сброшен.");
        return 1;
    }
    g_PostSeconds[playerid]++;
    new remaining = VCH_POST_TIME - g_PostSeconds[playerid];

    if(g_PostSeconds[playerid] % 60 == 0) {
        new msg[96];
        format(msg, sizeof(msg), "[Пост] Вы несёте службу. Осталось: %d мин.", remaining / 60);
        CEFChat_Send(playerid, "AAAAAA", msg);
    }
    if(g_PostSeconds[playerid] >= VCH_POST_TIME) {

        VchPost_Leave(playerid, true);
        GivePlayerMoney(playerid, VCH_POST_REWARD);
        CEFChat_Send(playerid, "54B367", "Вы успешно несли службу! Получено 250 000 руб.");

        if(g_VchBilyet[playerid][vb_PostCount] < VCH_BILYET_POSTS) {
            g_VchBilyet[playerid][vb_PostCount]++;
            new msg2[96];
            format(msg2, sizeof(msg2), "[ВБ] Отстояли пост: %d/%d", g_VchBilyet[playerid][vb_PostCount], VCH_BILYET_POSTS);
            CEFChat_Send(playerid, "e69348", msg2);
            SaveVchBilyet(playerid);
            VchBilyet_Check(playerid);
        }
    }
    g_PostTimer[playerid] = SetTimerEx("VchPostTick", 1000, false, "i", playerid);
    return 1;
}

stock VchPost_Join(playerid, idx) {
    if(g_PostIdx[playerid] != -1) {
        CEFChat_Send(playerid, "FF4444", "Вы уже несёте службу на посту.");
        return;
    }
    if(g_VchPost[idx][vpost_Count] >= g_VchPost[idx][vpost_MaxPlayers]) {
        CEFChat_Send(playerid, "FF4444", "Пост заполнен.");
        return;
    }
    g_PostIdx[playerid] = idx;
    g_PostSeconds[playerid] = 0;
    g_VchPost[idx][vpost_Count]++;
    VchPost_UpdateLabel(idx);
    g_PostTimer[playerid] = SetTimerEx("VchPostTick", 1000, false, "i", playerid);
    new msg[96];
    format(msg, sizeof(msg), "Вы заступили на пост {e69348}%s{FFFFFF}. Стойте 15 минут.", g_VchPost[idx][vpost_Name]);
    CEFChat_Send(playerid, "AAAAAA", msg);
}

stock VchPost_Leave(playerid, bool:success) {
    new idx = g_PostIdx[playerid];
    if(idx < 0) return;
    if(g_PostTimer[playerid] != -1) { KillTimer(g_PostTimer[playerid]); g_PostTimer[playerid] = -1; }
    g_VchPost[idx][vpost_Count]--;
    if(g_VchPost[idx][vpost_Count] < 0) g_VchPost[idx][vpost_Count] = 0;
    VchPost_UpdateLabel(idx);
    g_PostIdx[playerid] = -1;
    g_PostSeconds[playerid] = 0;
    #pragma unused success
}


forward CloseVchGate(playerid);
public CloseVchGate(playerid) {
    MoveObject(gate_vch_main, 1683.75, 1709.09, 16.1716, 2.0);
    gate_main_open = false;
    return 1;
}

stock VchOpenGate(playerid) {
    if(!IsPlayerInRangeOfPoint(playerid, 15.0, 1680.0100, 1709.0767, 15.6679))
        return SendErr(playerid, "Вы далеко от главных ворот.");
    if(!gate_main_open) {
        MoveObject(gate_vch_main, 1683.75, 1717.09, 16.1716, 2.0);
        gate_main_open = true;
        PlayerPlaySound(playerid, 1035, 0.0, 0.0, 0.0);
        CEFChat_Send(playerid, "54B367", "Ворота ВЧ открываются...");
        SetTimerEx("CloseVchGate", 15000, false, "i", playerid);
    } else {
        MoveObject(gate_vch_main, 1683.75, 1709.09, 16.1716, 2.0);
        gate_main_open = false;
        CEFChat_Send(playerid, "FF4444", "Ворота ВЧ закрываются...");
    }
    return 1;
}


cmd:gatevch(playerid, params[]) {
    if(!PT[playerid][pLogged]) return 1;
    new frac = PI[playerid][pFraction];
    if(frac != 2 && frac != 6) return SendErr(playerid, "Нет прав.");
    VchOpenGate(playerid);
    return 1;
}

cmd:post(playerid, params[]) {
    if(!PT[playerid][pLogged]) return 1;
    if(PI[playerid][pFraction] != 6) return SendErr(playerid, "Только для сотрудников ВЧ.");
    if(!PT[playerid][pDuty]) return SendErr(playerid, "Вы должны быть на дежурстве.");

    new nearest = -1; new Float:minDist = 5.0;
    for(new i = 0; i < g_VchPostCount; i++) {
        new Float:dist = GetPlayerDistanceFromPoint(playerid,
            g_VchPost[i][vpost_X], g_VchPost[i][vpost_Y], g_VchPost[i][vpost_Z]);
        if(dist < minDist) { minDist = dist; nearest = i; }
    }
    if(nearest == -1) return SendErr(playerid, "Вы не находитесь у поста.");
    if(g_PostIdx[playerid] == nearest) {

        VchPost_Leave(playerid, false);
        CEFChat_Send(playerid, "FF4444", "Вы покинули пост.");
    } else {
        VchPost_Join(playerid, nearest);
    }
    return 1;
}

cmd:createpost(playerid, params[]) {
    if(!PT[playerid][pLogged]) return 1;
    if(PI[playerid][pAdmin] < 6) return SendErr(playerid, "Нет прав (нужен уровень 6).");
    if(isnull(params)) return SendErr(playerid, "Использование: /createpost [название]");
    if(g_VchPostCount >= MAX_VCH_POSTS) return SendErr(playerid, "Достигнут лимит постов.");
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    new query[256];
    mysql_format(dbHandle, query, sizeof(query),
        "INSERT INTO `vch_posts` (`name`,`x`,`y`,`z`,`max_players`) VALUES ('%e',%.4f,%.4f,%.4f,4)",
        params, x, y, z);
    mysql_tquery(dbHandle, query, "OnVchPostCreated", "is", playerid, params);
    return 1;
}

forward OnVchPostCreated(playerid, const name[]);
public OnVchPostCreated(playerid, const name[]) {
    if(!IsPlayerConnected(playerid)) return 1;
    new insertId = cache_insert_id();
    new idx = g_VchPostCount;
    g_VchPost[idx][vpost_ID] = insertId;
    format(g_VchPost[idx][vpost_Name], 64, "%s", name);
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    g_VchPost[idx][vpost_X] = x;
    g_VchPost[idx][vpost_Y] = y;
    g_VchPost[idx][vpost_Z] = z;
    g_VchPost[idx][vpost_MaxPlayers] = 4;
    g_VchPost[idx][vpost_Count] = 0;
    VchPost_CreateLabel(idx);
    g_VchPost[idx][vpost_Area] = CreateDynamicSphere(x, y, z, 3.0);
    g_VchPostCount++;
    new msg[128];
    format(msg, sizeof(msg), "Пост \"%s\" создан (ID: %d).", name, insertId);
    CEFChat_Send(playerid, "54B367", msg);
    return 1;
}

cmd:deletepost(playerid, params[]) {
    if(!PT[playerid][pLogged]) return 1;
    if(PI[playerid][pAdmin] < 6) return SendErr(playerid, "Нет прав.");
    new postid;
    if(sscanf(params, "d", postid)) return SendErr(playerid, "Использование: /deletepost [id]");
    new found = -1;
    for(new i = 0; i < g_VchPostCount; i++)
        if(g_VchPost[i][vpost_ID] == postid) { found = i; break; }
    if(found == -1) return SendErr(playerid, "Пост не найден.");
    DestroyDynamic3DTextLabel(Text3D:g_VchPost[found][vpost_Label]);
    DestroyDynamicArea(g_VchPost[found][vpost_Area]);
    foreach(new i : Player) {
        if(g_PostIdx[i] == found) VchPost_Leave(i, false);
    }
    new query[64];
    mysql_format(dbHandle, query, sizeof(query), "DELETE FROM `vch_posts` WHERE `id`=%d", postid);
    mysql_tquery(dbHandle, query, "", "");
    for(new i = found; i < g_VchPostCount - 1; i++) g_VchPost[i] = g_VchPost[i+1];
    g_VchPostCount--;
    CEFChat_Send(playerid, "54B367", "Пост удалён.");
    return 1;
}

cmd:listposts(playerid, params[]) {
    if(!PT[playerid][pLogged]) return 1;
    if(PI[playerid][pAdmin] < 6 && PI[playerid][pFraction] != 6)
        return SendErr(playerid, "Нет прав.");
    if(g_VchPostCount == 0) return SendErr(playerid, "Постов нет.");
    new str[512];
    for(new i = 0; i < g_VchPostCount; i++) {
        new tmp[80];
        format(tmp, sizeof(tmp), "[%d] %s | %d/%d чел.\n",
            g_VchPost[i][vpost_ID], g_VchPost[i][vpost_Name],
            g_VchPost[i][vpost_Count], g_VchPost[i][vpost_MaxPlayers]);
        strcat(str, tmp);
    }
    CEFChat_Send(playerid, "AAAAAA", str);
    return 1;
}




cmd:vb(playerid, params[]) {
    if(!PT[playerid][pLogged]) return 1;
    if(PI[playerid][pFraction] != 6) return SendErr(playerid, "Только для сотрудников ВЧ.");
    cef_create_browser(playerid, VB_BROWSER, VB_CEF_LINK, false, false);
    TogglePlayerControllable(playerid, 0);
    return 1;
}

stock VchBilyet_ShowStatus(playerid) {
    new b[E_VCH_BILYET];
    b = g_VchBilyet[playerid];


    new days = VchBilyet_GetDays(playerid);
    g_VchBilyet[playerid][vb_DaysInOrg] = days;

    new str[512];
    format(str, sizeof(str),
        "Военный билет\n\n\
        1. Псих. тест: %s\n\
        2. Тест устава: %s\n\
        3. Прыжки с парашютом: %s\n\
        4. Посты (%d/%d): %s\n\
        5. Дней в орге (%d/%d): %s\n\n\
        %s",
        b[vb_Psych]      ? "{54B367}Выполнено" : "{FF4444}Не выполнено",
        b[vb_Ustav]      ? "{54B367}Выполнено" : "{FF4444}Не выполнено",
        b[vb_Parachute]  ? "{54B367}Выполнено" : "{FF4444}Не выполнено",
        b[vb_PostCount], VCH_BILYET_POSTS,
        b[vb_PostCount] >= VCH_BILYET_POSTS ? "{54B367}Выполнено" : "{FF4444}Не выполнено",
        days, VCH_BILYET_DAYS,
        days >= VCH_BILYET_DAYS ? "{54B367}Выполнено" : "{FF4444}Не выполнено",
        b[vb_Issued] ? "{54B367}Билет выдан!" : "{e69348}Выполните все пункты для получения билета."
    );
    new title[64];
    format(title, sizeof(title), "%s", b[vb_Issued] ? "Военный билет — ВЫДАН" : "Военный билет");
    ShowPlayerDialogEx(playerid, DIALOG_VCH_BILYET, DIALOG_STYLE_MSGBOX, title, str,
        b[vb_Psych] ? "Закрыть" : "Пройти псих. тест", "Закрыть");
}

stock VchBilyet_GetDays(playerid) {
    if(!strlen(g_VchBilyet[playerid][vb_JoinDate])) return 0;


    return g_VchBilyet[playerid][vb_DaysInOrg];
}


stock VchPsych_Start(playerid) {
    if(g_VchBilyet[playerid][vb_Psych]) {
        CEFChat_Send(playerid, "AAAAAA", "Вы уже прошли психологический тест.");
        return;
    }
    g_PsychQ[playerid] = 0;
    VchPsych_ShowQ(playerid);
}

stock VchPsych_ShowQ(playerid) {
    new q = g_PsychQ[playerid];
    if(q >= sizeof(g_PsychQuestions)) {

        g_VchBilyet[playerid][vb_Psych] = 1;
        SaveVchBilyet(playerid);
        VchBilyet_Check(playerid);
        CEFChat_Send(playerid, "54B367", "Психологический тест пройден!");
        VchBilyet_ShowStatus(playerid);
        return;
    }
    new title[64];
    format(title, sizeof(title), "Псих. тест (%d/%d)", q+1, sizeof(g_PsychQuestions));
    new list[256];
    for(new i = 0; i < 3; i++) {
        new tmp[100];
        format(tmp, sizeof(tmp), "%s\n", g_PsychAnswers[q][i]);
        strcat(list, tmp);
    }
    ShowPlayerDialogEx(playerid, DIALOG_VCH_PSYCH, DIALOG_STYLE_LIST,
        title, g_PsychQuestions[q], list, "Выбрать", "Отмена");
}


stock VchUstav_Start(playerid) {
    if(g_VchBilyet[playerid][vb_Ustav]) {
        CEFChat_Send(playerid, "AAAAAA", "Вы уже прошли тест устава.");
        return;
    }
    if(!g_VchBilyet[playerid][vb_Psych]) {
        CEFChat_Send(playerid, "FF4444", "Сначала пройдите психологический тест.");
        return;
    }
    g_UstavQ[playerid] = 0;
    VchUstav_ShowQ(playerid);
}

stock VchUstav_ShowQ(playerid) {
    new q = g_UstavQ[playerid];
    if(q >= sizeof(g_UstavQuestions)) {
        g_VchBilyet[playerid][vb_Ustav] = 1;
        SaveVchBilyet(playerid);
        VchBilyet_Check(playerid);
        CEFChat_Send(playerid, "54B367", "Тест устава пройден!");
        VchBilyet_ShowStatus(playerid);
        return;
    }
    new title[64];
    format(title, sizeof(title), "Тест устава (%d/%d)", q+1, sizeof(g_UstavQuestions));
    new list[64];
    format(list, sizeof(list), "%s\n%s", g_UstavAnswers[q][0], g_UstavAnswers[q][1]);
    ShowPlayerDialogEx(playerid, DIALOG_VCH_USTAV, DIALOG_STYLE_LIST,
        title, g_UstavQuestions[q], list, "Выбрать", "Отмена");
}







stock VchPsych_Response(playerid, response, listitem) {
    if(!response) return;
    new q = g_PsychQ[playerid];
    if(listitem != g_PsychCorrect[q]) {
        CEFChat_Send(playerid, "FF4444", "Неверный ответ. Тест провален. Попробуйте позже.");
        g_PsychQ[playerid] = 0;
        return;
    }
    g_PsychQ[playerid]++;
    VchPsych_ShowQ(playerid);
}

stock VchUstav_Response(playerid, response, listitem) {
    if(!response) return;
    new q = g_UstavQ[playerid];
    if(listitem != g_UstavCorrect[q]) {
        CEFChat_Send(playerid, "FF4444", "Неверный ответ. Тест провален. Попробуйте позже.");
        g_UstavQ[playerid] = 0;
        return;
    }
    g_UstavQ[playerid]++;
    VchUstav_ShowQ(playerid);
}

stock VchBilyet_Response(playerid, response) {
    if(!response) return;
    if(!g_VchBilyet[playerid][vb_Psych]) VchPsych_Start(playerid);
}


stock VchHornGate(playerid) {
    new frac = PI[playerid][pFraction];
    if(frac != 4 && frac != 6) return;
    if(!IsPlayerInAnyVehicle(playerid)) return;
    if(IsPlayerInRangeOfPoint(playerid, 15.0, 1680.0100, 1709.0767, 15.6679))
        VchOpenGate(playerid);
}


cmd:vbgive(playerid, params[]) {
    if(!PT[playerid][pLogged]) return 1;
    if(PI[playerid][pAdmin] < 4) return SendErr(playerid, "Нет прав.");
    new targetid, pnum;
    if(sscanf(params, "ud", targetid, pnum))
        return SendErr(playerid, "Использование: /vbgive [id] [пункт 1-5]");
    if(!IsPlayerConnected(targetid)) return SendErr(playerid, "Игрок не найден.");
    switch(pnum) {
        case 1: g_VchBilyet[targetid][vb_Psych] = 1;
        case 2: g_VchBilyet[targetid][vb_Ustav] = 1;
        case 3: g_VchBilyet[targetid][vb_Parachute] = 1;
        case 4: {
            if(g_VchBilyet[targetid][vb_PostCount] < VCH_BILYET_POSTS)
                g_VchBilyet[targetid][vb_PostCount]++;
        }
        case 5: g_VchBilyet[targetid][vb_DaysInOrg] = VCH_BILYET_DAYS;
        default: return SendErr(playerid, "Пункт от 1 до 5.");
    }
    SaveVchBilyet(targetid);
    VchBilyet_Check(targetid);
    new msg[96];
    format(msg, sizeof(msg), "Пункт %d военного билета засчитан игроку %s.", pnum, GetName(targetid));
    CEFChat_Send(playerid, "54B367", msg);
    format(msg, sizeof(msg), "Администратор засчитал вам пункт %d военного билета.", pnum);
    CEFChat_Send(targetid, "e69348", msg);
    return 1;
}


stock VchPlayer_Disconnect(playerid) {
    if(g_PostIdx[playerid] != -1) VchPost_Leave(playerid, false);
}
cmd:takevb(playerid, params[]) {
    if(!PT[playerid][pLogged]) return 1;
    if(PI[playerid][pLeader] != 2 && PI[playerid][pLeader] != 6)
        return SendErr(playerid, "Только для лидера ФСБ или ВЧ.");
    new targetid;
    if(sscanf(params, "u", targetid)) return SendErr(playerid, "Использование: /takevb [id]");
    if(!IsPlayerConnected(targetid)) return SendErr(playerid, "Игрок не найден.");
    if(!PT[targetid][pVchBilyet]) return SendErr(playerid, "У игрока нет военного билета.");
    PT[targetid][pVchBilyet] = 0;
    g_VchBilyet[targetid][vb_Issued] = 0;
    g_VchBilyet[targetid][vb_Psych] = 0;
    g_VchBilyet[targetid][vb_Ustav] = 0;
    g_VchBilyet[targetid][vb_Parachute] = 0;
    g_VchBilyet[targetid][vb_PostCount] = 0;
    g_VchBilyet[targetid][vb_DaysInOrg] = 0;
    SaveVchBilyet(targetid);
    SaveVchBilyet(targetid);
    new query[96];
    mysql_format(dbHandle, query, sizeof(query), "UPDATE `accounts` SET `vch_bilyet`=0 WHERE `id`=%d", PI[targetid][pID]);
    mysql_tquery(dbHandle, query, "", "");
    new msg[96];
    format(msg, sizeof(msg), "Военный билет изъят у %s.", GetName(targetid));
    CEFChat_Send(playerid, "AAAAAA", msg);
    CEFChat_Send(targetid, "FF4444", "У вас изъяли военный билет.");
    return 1;
}

cmd:give_vb(playerid, params[]) {
    if(!PT[playerid][pLogged]) return 1;
    if(PI[playerid][pAdmin] < 4) return SendErr(playerid, "Нет прав.");
    new targetid;
    if(sscanf(params, "u", targetid)) return SendErr(playerid, "Использование: /give_vb [id]");
    if(!IsPlayerConnected(targetid)) return SendErr(playerid, "Игрок не найден.");
    PT[targetid][pVchBilyet] = 1;
    g_VchBilyet[targetid][vb_Issued] = 1;
    SaveVchBilyet(targetid);
    new query[96];
    mysql_format(dbHandle, query, sizeof(query), "UPDATE `accounts` SET `vch_bilyet`=1 WHERE `id`=%d", PI[targetid][pID]);
    mysql_tquery(dbHandle, query, "", "");
    new msg[96];
    format(msg, sizeof(msg), "Вы выдали военный билет игроку %s.", GetName(targetid));
    CEFChat_Send(playerid, "54B367", msg);
    CEFChat_Send(targetid, "54B367", "Вам выдан военный билет администратором.");
    return 1;
}
callback::OnVbReady(playerid, const arguments[]) {
    cef_focus_browser(playerid, VB_BROWSER, true);
    cef_always_listen_keys(playerid, VB_BROWSER, true);
    SetTimerEx("VbSendData", 100, false, "i", playerid);
    return 1;
}
forward VbSendData(playerid);
public VbSendData(playerid) {
    if(!IsPlayerConnected(playerid)) return 1;
    new json[256];
    format(json, sizeof(json),
        "{\"psych\":%d,\"ustav\":%d,\"parachute\":%d,\"postCount\":%d,\"days\":%d,\"issued\":%d}",
        g_VchBilyet[playerid][vb_Psych], g_VchBilyet[playerid][vb_Ustav],
        g_VchBilyet[playerid][vb_Parachute], g_VchBilyet[playerid][vb_PostCount],
        g_VchBilyet[playerid][vb_DaysInOrg], g_VchBilyet[playerid][vb_Issued]);
    cef_emit_event(playerid, "vb:open", CEFSTR(json));
    return 1;
}
callback::OnVbClose(playerid, const arguments[]) {
    cef_focus_browser(playerid, VB_BROWSER, false);
    cef_hide_browser(playerid, VB_BROWSER, true);
    cef_destroy_browser(playerid, VB_BROWSER);
    TogglePlayerControllable(playerid, 1);
    return 1;
}
callback::OnVbTestDone(playerid, const arguments[]) {
    new type = strval(arguments);
    if(type == 1 && !g_VchBilyet[playerid][vb_Psych]) {
        g_VchBilyet[playerid][vb_Psych] = 1;
        SaveVchBilyet(playerid);
        VchBilyet_Check(playerid);
    } else if(type == 2 && !g_VchBilyet[playerid][vb_Ustav]) {
        g_VchBilyet[playerid][vb_Ustav] = 1;
        SaveVchBilyet(playerid);
        VchBilyet_Check(playerid);
    }
    return 1;
}
stock VchBilyet_Reset(playerid) {
    PT[playerid][pVchBilyet] = 0;
    g_VchBilyet[playerid][vb_Issued] = 0;
    g_VchBilyet[playerid][vb_Psych] = 0;
    g_VchBilyet[playerid][vb_Ustav] = 0;
    g_VchBilyet[playerid][vb_Parachute] = 0;
    g_VchBilyet[playerid][vb_PostCount] = 0;
    g_VchBilyet[playerid][vb_DaysInOrg] = 0;
    SaveVchBilyet(playerid);
    new query[96];
    mysql_format(dbHandle, query, sizeof(query),
        "UPDATE `accounts` SET `vch_bilyet`=0 WHERE `id`=%d", PI[playerid][pID]);
    mysql_tquery(dbHandle, query, "", "");
}
