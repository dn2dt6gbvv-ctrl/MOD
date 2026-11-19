



#define ZAK_MAX_POINTS  50      
#define ZAK_NPC_SKIN    221
#define ZAK_ANIM_TIME   10    
#define ZAK_CD_5        900 
#define ZAK_CD_10       1500
#define ZAK_CD_20       2400 
#define ZAK_PAY_MIN     25000
#define ZAK_PAY_MAX     35000
#define ZAK_CHANCE_SIG  40 

#define ZAK_FRAC_COUNT  4
static const zak_fracs[ZAK_FRAC_COUNT] = {7, 8, 9, 10};


#define ZAK_ENTER_PICKUP_ID  97
#define ZAK_EXIT_PICKUP_ID   98

#define MAX_POINTS_PER_JOB 20

enum E_ZAK_POINT {
    zp_ID,
    Float:zp_X,
    Float:zp_Y,
    Float:zp_Z
}
static g_ZakPoints[ZAK_MAX_POINTS][E_ZAK_POINT];
static g_ZakPointCount = 0;

new g_ZakAreaNPC        = -1;
new g_ZakNearNPC[MAX_PLAYERS];


static const Float:ZAK_NPC_X    = 1075.7630;
static const Float:ZAK_NPC_Y    = 453.8800;
static const Float:ZAK_NPC_Z    = 1369.6723;


static const Float:ZAK_INSIDE_X = 1066.9157;
static const Float:ZAK_INSIDE_Y = 452.2716;
static const Float:ZAK_INSIDE_Z = 1369.6723;
static const Float:ZAK_EXIT_X   = -2260.0949;
static const Float:ZAK_EXIT_Y   = -196.1218;
static const Float:ZAK_EXIT_Z   = 24.3632;

enum E_ZAK_PLAYER {
    zp_Active,         
    zp_Grams,           
    zp_Done,            
    zp_Total,           
    zp_CurrentPt,       
    zp_AnimTimer,       
    zp_CooldownEnd,
    zp_Points[MAX_POINTS_PER_JOB],
    zp_PointCount
}
new g_ZakPlayer[MAX_PLAYERS][E_ZAK_PLAYER];

forward LoadZakladki();
forward OnZakladkiLoaded();
forward OnZakladkiSelect(playerid, const arguments[]);
forward OnZakladkiClose(playerid, const arguments[]);
forward ZakAnimDone(playerid);
forward ZakAddPointResult(playerid);
forward ZakResetPlayer(playerid);
forward ZakBrowserReady(playerid);
forward ZakInteractWithNPC(playerid);

public LoadZakladki()
{
    mysql_tquery(dbHandle, "SELECT * FROM `zakladki_points`", "OnZakladkiLoaded", "");
    
    CreateActor(ZAK_NPC_SKIN, ZAK_NPC_X, ZAK_NPC_Y, ZAK_NPC_Z, 180.0);
    g_ZakAreaNPC = CreateDynamicSphere(ZAK_NPC_X, ZAK_NPC_Y, ZAK_NPC_Z, 1.5);
    
    printf("[Zakladki] Загрузка завершена. Зона NPC ID: %d", g_ZakAreaNPC);
    return 1;
}

public OnZakladkiLoaded()
{
    g_ZakPointCount = 0;
    new rows = cache_num_rows();
    for(new i = 0; i < rows && i < ZAK_MAX_POINTS; i++) {
        cache_get_value_name_int(i, "id", g_ZakPoints[g_ZakPointCount][zp_ID]);
        cache_get_value_name_float(i, "x", g_ZakPoints[g_ZakPointCount][zp_X]);
        cache_get_value_name_float(i, "y", g_ZakPoints[g_ZakPointCount][zp_Y]);
        cache_get_value_name_float(i, "z", g_ZakPoints[g_ZakPointCount][zp_Z]);
        g_ZakPointCount++;
    }
    printf("[Zakladki] Загружено %d точек.", g_ZakPointCount);
    return 1;
}

static stock IsCrimFrac(playerid) {
    new frac = PI[playerid][pFraction];
    for(new i = 0; i < ZAK_FRAC_COUNT; i++)
        if(zak_fracs[i] == frac) return true;
    return false;
}

static stock ZakGeneratePoints(playerid, count) {
    if(count > g_ZakPointCount) return 0;
    new perm[ZAK_MAX_POINTS];
    for(new i = 0; i < g_ZakPointCount; i++) perm[i] = i;
    for(new i = g_ZakPointCount - 1; i > 0; i--) {
        new j = random(i + 1);
        new tmp = perm[i];
        perm[i] = perm[j];
        perm[j] = tmp;
    }
    for(new i = 0; i < count; i++) {
        g_ZakPlayer[playerid][zp_Points][i] = perm[i];
    }
    g_ZakPlayer[playerid][zp_PointCount] = count;
    return 1;
}

static stock ZakGetNextPoint(playerid) {
    new idx = g_ZakPlayer[playerid][zp_CurrentPt];
    if(idx < 0 || idx >= g_ZakPlayer[playerid][zp_PointCount]) return -1;
    return g_ZakPlayer[playerid][zp_Points][idx];
}

static stock ZakSetNextCheckpoint(playerid) {
    new pointIdx = ZakGetNextPoint(playerid);
    if(pointIdx < 0 || pointIdx >= g_ZakPointCount) return;
    SetPlayerCheckpoint(playerid,
        g_ZakPoints[pointIdx][zp_X],
        g_ZakPoints[pointIdx][zp_Y],
        g_ZakPoints[pointIdx][zp_Z],
        1.5);
}

static stock ZakGetCD(grams) {
    if(grams == 5)  return ZAK_CD_5;
    if(grams == 10) return ZAK_CD_10;
    return ZAK_CD_20;
}

static stock ZakOpenBrowser(playerid) {
    cef_create_browser(playerid, ZAKLADKI_BROWSER, ZAKLADKI_CEF_LINK, false, true);
    cef_focus_browser(playerid, ZAKLADKI_BROWSER, true);
    cef_always_listen_keys(playerid, ZAKLADKI_BROWSER, true);
    TogglePlayerControllable(playerid, 0);
}

static stock ZakCloseBrowser(playerid) {
    cef_focus_browser(playerid, ZAKLADKI_BROWSER, false);
    cef_hide_browser(playerid, ZAKLADKI_BROWSER, true);
    cef_destroy_browser(playerid, ZAKLADKI_BROWSER);
    TogglePlayerControllable(playerid, 1);
    cef_emit_event(playerid, "game:showCursor", CEFINT(0));
}

static stock ZakSendOpen(playerid) {
    new json[128];
    format(json, sizeof(json),
        "{\"name\":\"Незнакомец\",\"role\":\"Закладчик\",\"text\":\"Ч\\u00e9 надо? Говори быстро.\"}");
    cef_emit_event(playerid, "zakladki:open", CEFSTR(json));
}

ZakResetPlayer(playerid) {
    g_ZakPlayer[playerid][zp_Active]     = 0;
    g_ZakPlayer[playerid][zp_Grams]      = 0;
    g_ZakPlayer[playerid][zp_Done]       = 0;
    g_ZakPlayer[playerid][zp_Total]      = 0;
    g_ZakPlayer[playerid][zp_CurrentPt]  = 0;
    g_ZakPlayer[playerid][zp_PointCount] = 0;
    if(g_ZakPlayer[playerid][zp_AnimTimer] != -1) {
        KillTimer(g_ZakPlayer[playerid][zp_AnimTimer]);
        g_ZakPlayer[playerid][zp_AnimTimer] = -1;
    }
    DisablePlayerCheckpoint(playerid);
    ClearAnimations(playerid, 1);
    TogglePlayerControllable(playerid, 1);
}

public OnZakladkiSelect(playerid, const arguments[]) {
    new grams = strval(arguments);
    if(grams != 5 && grams != 10 && grams != 20) return 1;
    ZakCloseBrowser(playerid);
    new now = gettime();
    if(g_ZakPlayer[playerid][zp_CooldownEnd] > now) {
        new rem = g_ZakPlayer[playerid][zp_CooldownEnd] - now;
        new msg[64];
        format(msg, sizeof(msg), "[Закладки] Подождите ещё %d:%02d.", rem / 60, rem % 60);
        CEFChat_Send(playerid, "FF4444", msg);
        return 1;
    }
    if(g_ZakPointCount < grams) {
        CEFChat_Send(playerid, "FF4444", "[Закладки] Недостаточно точек на карте. Свяжитесь с администрацией.");
        return 1;
    }
    if(!ZakGeneratePoints(playerid, grams)) {
        CEFChat_Send(playerid, "FF4444", "[Закладки] Ошибка генерации точек.");
        return 1;
    }
    g_ZakPlayer[playerid][zp_Active]    = 1;
    g_ZakPlayer[playerid][zp_Grams]     = grams;
    g_ZakPlayer[playerid][zp_Done]      = 0;
    g_ZakPlayer[playerid][zp_Total]     = grams;
    g_ZakPlayer[playerid][zp_AnimTimer] = -1;
    g_ZakPlayer[playerid][zp_CurrentPt] = 0;
    ZakSetNextCheckpoint(playerid);
    new msg[96];
    format(msg, sizeof(msg), "[Закладки] Задание принято. Разложи %d закладок. Следуй к метке.", grams);
    CEFChat_Send(playerid, "54B367", msg);
    printf("[Zakladki] %s взял задание на %d грамм.", ZakGetPlayerName(playerid), grams);
    return 1;
}

public OnZakladkiClose(playerid, const arguments[]) {
    ZakCloseBrowser(playerid);
    return 1;
}

ZakInteractWithNPC(playerid) {
    if(!g_ZakNearNPC[playerid]) return 0;
    if(!IsCrimFrac(playerid)) {
        CEFChat_Send(playerid, "FF4444", "[Закладки] Это не для вас.");
        return 0;
    }

    if(g_ZakPlayer[playerid][zp_Active]) {
        if(g_ZakPlayer[playerid][zp_Done] >= g_ZakPlayer[playerid][zp_Total]) {
            new pay = ZAK_PAY_MIN + random(ZAK_PAY_MAX - ZAK_PAY_MIN + 1);
            GivePlayerMoney(playerid, pay);
            new msg[96];
            format(msg, sizeof(msg), "[Закладки] Отличная работа! Вы получили %d руб.", pay);
            SendClientMessage(playerid, -1, msg);
            printf("[Zakladki] %s выполнил задание на %d грамм, получил %d руб.", ZakGetPlayerName(playerid), g_ZakPlayer[playerid][zp_Grams], pay);
            g_ZakPlayer[playerid][zp_CooldownEnd] = gettime() + ZakGetCD(g_ZakPlayer[playerid][zp_Grams]);
            ZakResetPlayer(playerid);
            return 1;
        } else {
            new msg[96];
            format(msg, sizeof(msg), "[Закладки] Вы ещё не разложили все закладки. Осталось: %d/%d.", 
                g_ZakPlayer[playerid][zp_Total] - g_ZakPlayer[playerid][zp_Done], 
                g_ZakPlayer[playerid][zp_Total]);
            CEFChat_Send(playerid, "FF4444", msg);
            return 0;
        }
    }

    ZakOpenBrowser(playerid);
    return 1;
}

stock ZakHandleEnterArea(playerid, areaid) {
    if(areaid == g_ZakAreaNPC) {
        g_ZakNearNPC[playerid] = 1;
        SendClientMessage(playerid, -1, "[Закладки] Нажмите {00FF00}Y{FFFFFF} для разговора с закладчиком.");
        return 1;
    }
    return 0;
}

stock ZakHandleLeaveArea(playerid, areaid) {
    if(areaid == g_ZakAreaNPC) {
        g_ZakNearNPC[playerid] = 0;
        return 1;
    }
    return 0;
}

stock ZakOnEnterLab(playerid) {
    SetPlayerPos(playerid, ZAK_INSIDE_X, ZAK_INSIDE_Y, ZAK_INSIDE_Z);
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    SetCameraBehindPlayer(playerid);
    CEFChat_Send(playerid, "AAAAAA", "[Закладки] Вы вошли в лабораторию.");
}

stock ZakOnExitLab(playerid) {
    SetPlayerPos(playerid, ZAK_EXIT_X, ZAK_EXIT_Y, ZAK_EXIT_Z);
    CEFChat_Send(playerid, "AAAAAA", "[Закладки] Вы вышли из лаборатории.");
}

stock ZakOnCheckpoint(playerid) {
    if(!g_ZakPlayer[playerid][zp_Active]) return;
    if(g_ZakPlayer[playerid][zp_Done] >= g_ZakPlayer[playerid][zp_Total]) return;
    if(g_ZakPlayer[playerid][zp_AnimTimer] != -1) return;

    if(GetPlayerVehicleSeat(playerid) != -1) {
        RemovePlayerFromVehicle(playerid);
        SetTimerEx("ZakOnCheckpoint", 100, false, "i", playerid);
        return;
    }

    DisablePlayerCheckpoint(playerid);
    TogglePlayerControllable(playerid, 0);
    ApplyAnimation(playerid, "BOMBER", "BOM_PLANT", 4.1, 1, 0, 0, 0, 0, 1);
    g_ZakPlayer[playerid][zp_AnimTimer] = SetTimerEx("ZakAnimDone", ZAK_ANIM_TIME * 1000, false, "i", playerid);
    CEFChat_Send(playerid, "AAAAAA", "[Закладки] Кладёте закладку... Не двигайтесь!");
}

public ZakAnimDone(playerid) {
    if(!IsPlayerConnected(playerid)) return 1;
    g_ZakPlayer[playerid][zp_AnimTimer] = -1;
    ClearAnimations(playerid, 1);
    TogglePlayerControllable(playerid, 1);

    new idx = ZakGetNextPoint(playerid);
    if(idx != -1 && idx < g_ZakPointCount) {
        if(GetPlayerDistanceFromPoint(playerid,
            g_ZakPoints[idx][zp_X],
            g_ZakPoints[idx][zp_Y],
            g_ZakPoints[idx][zp_Z]) > 2.5) {
            CEFChat_Send(playerid, "FF4444", "[Закладки] Вы отошли от места закладки! Попробуйте снова.");
            ZakSetNextCheckpoint(playerid);
            return 1;
        }
    }

    g_ZakPlayer[playerid][zp_Done]++;
    new done  = g_ZakPlayer[playerid][zp_Done];
    new total = g_ZakPlayer[playerid][zp_Total];

    if(done >= total) {
        SetPlayerCheckpoint(playerid, ZAK_NPC_X, ZAK_NPC_Y, ZAK_NPC_Z, 1.5);
        CEFChat_Send(playerid, "54B367", "[Закладки] Все закладки разложены! Вернитесь к закладчику и нажмите Y.");
        printf("[Zakladki] %s разложил все %d закладок.", ZakGetPlayerName(playerid), total);
    } else {
        g_ZakPlayer[playerid][zp_CurrentPt]++;
        ZakSetNextCheckpoint(playerid);
        new msg[64];
        format(msg, sizeof(msg), "[Закладки] Закладка %d/%d. Следуй к следующей метке.", done, total);
        CEFChat_Send(playerid, "AAAAAA", msg);
    }
    return 1;
}

CMD:cancelzak(playerid, params[]) {
    if(!g_ZakPlayer[playerid][zp_Active]) return SendClientMessage(playerid, -1, "[Закладки] У вас нет активного задания.");
    CEFChat_Send(playerid, "FF4444", "[Закладки] Вы отменили задание. Кулдаун 5 минут.");
    g_ZakPlayer[playerid][zp_CooldownEnd] = gettime() + 300;
    ZakResetPlayer(playerid);
    return 1;
}

CMD:addzakpoint(playerid, params[]) {
    if(PI[playerid][pAdmin] < 5) return SendClientMessage(playerid, -1, "Нет прав.");
    if(g_ZakPointCount >= ZAK_MAX_POINTS) return SendClientMessage(playerid, -1, "[Закладки] Лимит точек достигнут.");
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    new query[192];
    mysql_format(dbHandle, query, sizeof(query),
        "INSERT INTO `zakladki_points` (`x`,`y`,`z`) VALUES ('%.4f','%.4f','%.4f')", x, y, z);
    mysql_tquery(dbHandle, query, "ZakAddPointResult", "i", playerid);
    return 1;
}

public ZakAddPointResult(playerid) {
    if(!IsPlayerConnected(playerid)) return 1;
    new id = cache_insert_id();
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    new idx = g_ZakPointCount;
    g_ZakPoints[idx][zp_ID] = id;
    g_ZakPoints[idx][zp_X]  = x;
    g_ZakPoints[idx][zp_Y]  = y;
    g_ZakPoints[idx][zp_Z]  = z;
    g_ZakPointCount++;
    new msg[96];
    format(msg, sizeof(msg), "[Закладки] Точка #%d добавлена (%.1f %.1f). Всего: %d.", id, x, y, g_ZakPointCount);
    SendClientMessage(playerid, -1, msg);
    return 1;
}

CMD:delzakpoint(playerid, params[]) {
    if(PI[playerid][pAdmin] < 5) return SendClientMessage(playerid, -1, "Нет прав.");
    new id;
    if(sscanf(params, "d", id)) return SendClientMessage(playerid, -1, "Использование: /delzakpoint [id]");
    new idx = -1;
    for(new i = 0; i < g_ZakPointCount; i++) {
        if(g_ZakPoints[i][zp_ID] == id) { idx = i; break; }
    }
    if(idx == -1) return SendClientMessage(playerid, -1, "[Закладки] Точка не найдена.");
    for(new i = idx; i < g_ZakPointCount - 1; i++)
        g_ZakPoints[i] = g_ZakPoints[i+1];
    g_ZakPointCount--;
    new query[96];
    mysql_format(dbHandle, query, sizeof(query), "DELETE FROM `zakladki_points` WHERE `id`=%d", id);
    mysql_tquery(dbHandle, query, "", "");
    new msg[64];
    format(msg, sizeof(msg), "[Закладки] Точка #%d удалена.", id);
    SendClientMessage(playerid, -1, msg);
    return 1;
}

CMD:listzakpoints(playerid, params[]) {
    if(PI[playerid][pAdmin] < 4) return SendClientMessage(playerid, -1, "Нет прав.");
    if(g_ZakPointCount == 0) return SendClientMessage(playerid, -1, "[Закладки] Точек нет.");
    new str[512];
    for(new i = 0; i < g_ZakPointCount; i++) {
        new tmp[64];
        format(tmp, sizeof(tmp), "#%d: %.1f %.1f %.1f\n", g_ZakPoints[i][zp_ID], g_ZakPoints[i][zp_X], g_ZakPoints[i][zp_Y], g_ZakPoints[i][zp_Z]);
        strcat(str, tmp);
        if(strlen(str) > 400) break;
    }
    SendClientMessage(playerid, -1, str);
    return 1;
}

stock ZakGetPlayerName(playerid) {
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    return name;
}
