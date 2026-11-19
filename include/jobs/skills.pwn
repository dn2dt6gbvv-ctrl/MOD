#if defined _skills_inc
    #endinput
#endif
#define _skills_inc

#define SKILL_MINER             0
#define SKILL_LOGGER            1
#define SKILL_DIVER             2
#define SKILL_FARMER            3
#define SKILL_BUS               4
#define SKILL_RAZVOZ            5
#define SKILL_TRUCKER           6
#define SKILL_TAXI              7
#define SKILL_MECHANIC          8
#define SKILL_FACTORY           9
#define SKILL_CLEANER           10
#define SKILL_CARJACK           11
#define SKILL_COOK              12
#define SKILL_FISHER            13
#define SKILL_DONOR_SPERM       14
#define SKILL_DONOR_BLOOD       15
#define SKILL_DRUG              16
#define MAX_SKILLS              17

#define DIALOG_SKILL_MAIN       7500
#define DIALOG_SKILL_WORKS      7501
#define DIALOG_SKILL_SHOOTING   7502
#define DIALOG_SKILL_SPORT      7503

static const g_SkillNames[MAX_SKILLS][] = {
    "Рудокоп","Лесоруб","Дайвер","Фермер","Водитель автобуса",
    "Развозчик товаров","Дальнобойщик","Таксист","Механик","Фрезеровщик",
    "Уборщик улиц","Угонщик","Повар","Рыбак","Донор спермы","Донор крови","Закладчик"
};

static const g_SkillStartReq[MAX_SKILLS] = {
    100,20,20,20,30,30,20,20,30,30,20,20,20,20,20,20,30
};

static const g_SkillMaxLevel[MAX_SKILLS] = {
    30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30
};

enum E_SKILL_DATA { skill_Level, skill_Progress }
static g_SkillData[MAX_PLAYERS][MAX_SKILLS][E_SKILL_DATA];
static bool:g_SkillLoaded[MAX_PLAYERS];

forward OnSkillDataLoaded(playerid);
forward OnSkillBrowserReady(playerid);
forward OnSkillDialogResponse(playerid, dialogid, response, listitem, const inputtext[]);

static stock Skill_GetStartReq(skillId) {
    if(skillId < 0 || skillId >= MAX_SKILLS) return 20;
    return g_SkillStartReq[skillId];
}

static stock Skill_GetMaxLevel(skillId) {
    if(skillId < 0 || skillId >= MAX_SKILLS) return 30;
    return g_SkillMaxLevel[skillId];
}

stock Skill_GetName(skillId, dest[], size = sizeof(dest)) {
    if(skillId < 0 || skillId >= MAX_SKILLS) format(dest, size, "Неизвестно");
    else format(dest, size, "%s", g_SkillNames[skillId]);
}

static stock Skill_GetRequiredProgress(skillId, level) {
    if(level < 1) level = 1;
    return Skill_GetStartReq(skillId) + (level - 1) * 10;
}

stock Skill_LoadPlayer(playerid) {
    if(!IsPlayerConnected(playerid)) return 1;
    new query[128];
    mysql_format(dbHandle, query, sizeof(query),
        "SELECT `skill_id`,`level`,`progress` FROM `player_skills` WHERE `player_id`=%d",
        PI[playerid][pID]);
    mysql_tquery(dbHandle, query, "OnSkillDataLoaded", "i", playerid);
    return 1;
}

public OnSkillDataLoaded(playerid) {
    if(!IsPlayerConnected(playerid)) return 1;
    for(new i = 0; i < MAX_SKILLS; i++) {
        g_SkillData[playerid][i][skill_Level] = 1;
        g_SkillData[playerid][i][skill_Progress] = 0;
    }
    new rows = cache_num_rows();
    for(new i = 0; i < rows; i++) {
        new skillId, level, progress;
        cache_get_value_name_int(i, "skill_id", skillId);
        cache_get_value_name_int(i, "level", level);
        cache_get_value_name_int(i, "progress", progress);
        if(skillId >= 0 && skillId < MAX_SKILLS) {
            g_SkillData[playerid][skillId][skill_Level] = level;
            g_SkillData[playerid][skillId][skill_Progress] = progress;
        }
    }
    g_SkillLoaded[playerid] = true;
    return 1;
}

stock Skill_SavePlayer(playerid) {
    if(!g_SkillLoaded[playerid]) return 0;
    for(new i = 0; i < MAX_SKILLS; i++) Skill_SaveSingle(playerid, i);
    return 1;
}

stock Skill_SaveSingle(playerid, skillId) {
    if(!g_SkillLoaded[playerid] || skillId < 0 || skillId >= MAX_SKILLS) return 0;
    new query[256];
    mysql_format(dbHandle, query, sizeof(query),
        "INSERT INTO `player_skills` (`player_id`,`skill_id`,`level`,`progress`) VALUES (%d,%d,%d,%d) \
        ON DUPLICATE KEY UPDATE `level`=%d,`progress`=%d",
        PI[playerid][pID], skillId,
        g_SkillData[playerid][skillId][skill_Level],
        g_SkillData[playerid][skillId][skill_Progress],
        g_SkillData[playerid][skillId][skill_Level],
        g_SkillData[playerid][skillId][skill_Progress]);
    mysql_tquery(dbHandle, query, "", "");
    return 1;
}

stock Skill_GetLevel(playerid, skillId) {
    if(!g_SkillLoaded[playerid] || skillId < 0 || skillId >= MAX_SKILLS) return 1;
    return g_SkillData[playerid][skillId][skill_Level];
}

stock Skill_GetProgress(playerid, skillId, &progress, &needed) {
    if(!g_SkillLoaded[playerid] || skillId < 0 || skillId >= MAX_SKILLS) {
        progress = 0; needed = 20; return;
    }
    new level = g_SkillData[playerid][skillId][skill_Level];
    progress = g_SkillData[playerid][skillId][skill_Progress];
    needed = Skill_GetRequiredProgress(skillId, level);
}

stock Skill_AddProgress(playerid, skillId, amount = 1) {
    if(!g_SkillLoaded[playerid] || skillId < 0 || skillId >= MAX_SKILLS) return 0;
    new level = g_SkillData[playerid][skillId][skill_Level];
    new maxLevel = Skill_GetMaxLevel(skillId);
    if(level >= maxLevel) return 0;
    g_SkillData[playerid][skillId][skill_Progress] += amount;
    new progress = g_SkillData[playerid][skillId][skill_Progress];
    new needed = Skill_GetRequiredProgress(skillId, level);
    new skillName[32];
    Skill_GetName(skillId, skillName, sizeof(skillName));
    while(progress >= needed && level < maxLevel) {
        level++;
        g_SkillData[playerid][skillId][skill_Level] = level;
        progress -= needed;
        g_SkillData[playerid][skillId][skill_Progress] = progress;
        new msg[128];
        format(msg, sizeof(msg), "{4CAF50}Ваш уровень навыка {FFA500}%s{4CAF50} повышен до {FFA500}%d{4CAF50}! (/skill)", skillName, level);
        SendClientMessage(playerid, -1, msg);
        printf("[Skills] %s повысил %s до %d уровня.", GetName(playerid), skillName, level);
        Skill_SaveSingle(playerid, skillId);
        if(level >= maxLevel) break;
        needed = Skill_GetRequiredProgress(skillId, level);
    }
    Skill_SaveSingle(playerid, skillId);
    return 1;
}

stock Skill_GetRewardBonus(playerid, skillId, baseReward, bonusPerLevel) {
    return baseReward + (Skill_GetLevel(playerid, skillId) - 1) * bonusPerLevel;
}

stock Skill_GetCapacityBonus(playerid, skillId, baseCapacity, bonusPerLevel) {
    return baseCapacity + (Skill_GetLevel(playerid, skillId) - 1) * bonusPerLevel;
}

CMD:skill(playerid, params[]) {
    #pragma unused params
    if(!g_SkillLoaded[playerid]) return SendClientMessage(playerid, -1, "Данные не загружены.");
    cef_create_browser(playerid, SKILL_BROWSER, SKILL_CEF_LINK, false, true);
    cef_focus_browser(playerid, SKILL_BROWSER, true);
    cef_always_listen_keys(playerid, SKILL_BROWSER, true);
    TogglePlayerControllable(playerid, 0);
    return 1;
}

public OnSkillBrowserReady(playerid) {
    if(!IsPlayerConnected(playerid)) return 1;
    new json[2048], tmp[128], skillName[32];
    strcat(json, "[");
    for(new i = 0; i < MAX_SKILLS; i++) {
        new level = Skill_GetLevel(playerid, i);
        new progress, needed;
        Skill_GetProgress(playerid, i, progress, needed);
        Skill_GetName(i, skillName, sizeof(skillName));
        format(tmp, sizeof tmp, "%s{\"name\":\"%s\",\"level\":%d,\"progress\":%d,\"needed\":%d}",
            i > 0 ? "," : "", skillName, level, progress, needed);
        strcat(json, tmp);
    }
    strcat(json, "]");
    cef_emit_event(playerid, "skill:open", CEFSTR(json));
    return 1;
}

callback::OnSkillClose(playerid, const arguments[]) {
    #pragma unused arguments
    cef_focus_browser(playerid, SKILL_BROWSER, false);
    cef_hide_browser(playerid, SKILL_BROWSER, true);
    cef_destroy_browser(playerid, SKILL_BROWSER);
    TogglePlayerControllable(playerid, 1);
    cef_emit_event(playerid, "game:showCursor", CEFINT(0));
    return 1;
}

callback::OnSkillReady(playerid, const arguments[])
{
    #pragma unused arguments
    if(!IsPlayerConnected(playerid)) return 1;
    new json[2048], tmp[128], skillName[32];
    strcat(json, "[");
    for(new i = 0; i < MAX_SKILLS; i++) {
        new level = Skill_GetLevel(playerid, i);
        new progress, needed;
        Skill_GetProgress(playerid, i, progress, needed);
        Skill_GetName(i, skillName, sizeof(skillName));
        format(tmp, sizeof tmp, "%s{\"name\":\"%s\",\"level\":%d,\"progress\":%d,\"needed\":%d}",
            i > 0 ? "," : "", skillName, level, progress, needed);
        strcat(json, tmp);
    }
    strcat(json, "]");
    cef_emit_event(playerid, "skill:open", CEFSTR(json));
    return 1;
}




public OnSkillDialogResponse(playerid, dialogid, response, listitem, const inputtext[]) {
}

stock Skill_OnPlayerDisconnect(playerid) {
    if(g_SkillLoaded[playerid]) {
        Skill_SavePlayer(playerid);
        g_SkillLoaded[playerid] = false;
    }
}

CMD:setskill(playerid, params[]) {
    if(PI[playerid][pAdmin] < 4) return SendClientMessage(playerid, -1, "Нет прав.");
    new target, skillId, level;
    if(sscanf(params, "udd", target, skillId, level)) return SendClientMessage(playerid, -1, "Использование: /setskill [player] [id] [уровень]");
    if(!IsPlayerConnected(target)) return SendClientMessage(playerid, -1, "Игрок не найден.");
    if(skillId < 0 || skillId >= MAX_SKILLS) return SendClientMessage(playerid, -1, "Неверный ID скилла.");
    if(level < 1 || level > Skill_GetMaxLevel(skillId)) return SendClientMessage(playerid, -1, "Неверный уровень.");
    new skillName[32];
    Skill_GetName(skillId, skillName, sizeof(skillName));
    g_SkillData[target][skillId][skill_Level] = level;
    g_SkillData[target][skillId][skill_Progress] = 0;
    Skill_SaveSingle(target, skillId);
    new msg[128];
    format(msg, sizeof(msg), "Вы установили навык %s игроку %s на %d уровень.", skillName, GetName(target), level);
    SendClientMessage(playerid, -1, msg);
    format(msg, sizeof(msg), "Администратор установил ваш навык %s на %d уровень.", skillName, level);
    SendClientMessage(target, -1, msg);
    return 1;
}

CMD:addskillprogress(playerid, params[]) {
    if(PI[playerid][pAdmin] < 4) return SendClientMessage(playerid, -1, "Нет прав.");
    new target, skillId, amount;
    if(sscanf(params, "udd", target, skillId, amount)) return SendClientMessage(playerid, -1, "Использование: /addskillprogress [player] [id] [кол-во]");
    if(!IsPlayerConnected(target)) return SendClientMessage(playerid, -1, "Игрок не найден.");
    if(skillId < 0 || skillId >= MAX_SKILLS) return SendClientMessage(playerid, -1, "Неверный ID.");
    if(amount <= 0) return SendClientMessage(playerid, -1, "Кол-во > 0.");
    Skill_AddProgress(target, skillId, amount);
    new skillName[32];
    Skill_GetName(skillId, skillName, sizeof(skillName));
    new msg[128];
    format(msg, sizeof(msg), "Вы добавили %d прогресса навыку %s игроку %s.", amount, skillName, GetName(target));
    SendClientMessage(playerid, -1, msg);
    return 1;
}
