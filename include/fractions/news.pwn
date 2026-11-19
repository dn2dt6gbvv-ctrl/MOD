#define IsGovFraction(%0) (%0 >= 1 && %0 <= 6)
#define MAX_NEWS_ACTIVE     6
#define NEWS_START_HOUR     9
#define MAX_NEWS_SLOTS      22
#define NEWS_COLOR          "0270AB"

enum E_NEWS {
    news_fractionid, news_leaderid,
    news_start_hour, news_start_min,
    news_end_hour,   news_end_min,
    news_mid_hour,   news_mid_min,
    bool:news_notified_start,
    bool:news_notified_mid,
    bool:news_notified_end,
    bool:news_active
};
new NewsSlots[MAX_NEWS_ACTIVE][E_NEWS];
new bool:NewsSlotTaken[MAX_NEWS_SLOTS];

stock News_SlotIndex(hour, nmin) { return (hour - NEWS_START_HOUR) * 2 + (nmin / 30); }

stock GetFractionShort(fractionid) {
    new s[8];
    switch(fractionid) {
        case 1: s = "Прав";
        case 2: s = "ФСБ";
        case 3: s = "ГАИ";
        case 4: s = "ППС";
        case 5: s = "ЕСС";
        case 6: s = "ВЧ";
        default: s = "???";
    }
    return s;
}

stock GetNewsByFraction(fractionid) {
    for (new i = 0; i < MAX_NEWS_ACTIVE; i++)
        if (NewsSlots[i][news_active] && NewsSlots[i][news_fractionid] == fractionid) return i;
    return -1;
}

stock GetFreeNewsSlot() {
    for (new i = 0; i < MAX_NEWS_ACTIVE; i++)
        if (!NewsSlots[i][news_active]) return i;
    return -1;
}

stock BuildNewsListStr(output[], size) {
    output[0] = EOS;
    new count = 0;
    for (new i = 0; i < MAX_NEWS_ACTIVE; i++) {
        if (!NewsSlots[i][news_active]) continue;
        new line[256];

        if (count > 0) strcat(output, "\n", size);
        format(line, sizeof(line), "%s  |  Начало: %02d:%02d  |  Окончание: %02d:%02d  |  Проводит: %s",
            GetFractionName(NewsSlots[i][news_fractionid]),
            NewsSlots[i][news_start_hour], NewsSlots[i][news_start_min],
            NewsSlots[i][news_end_hour],   NewsSlots[i][news_end_min],
            PI[NewsSlots[i][news_leaderid]][pName]);
        strcat(output, line, size);
        count++;
    }
    return count;
}

stock BuildNewsTimeStr(playerid, output[], size) {
    output[0] = EOS;
    new visible = 0;
    for (new i = 0; i < MAX_NEWS_SLOTS; i++) {
        new nh = NEWS_START_HOUR + i / 2;
        new nm = (i % 2) * 30;
        new eh = nh + (nm + 30) / 60;
        new em = (nm + 30) % 60;
        if (global_hour > eh || (global_hour == eh && global_minute >= em)) continue;
        g_NewsSlotMap[playerid][visible] = i;
        visible++;
        new line[64];
        if (NewsSlotTaken[i])
            format(line, sizeof(line), "%02d:%02d - %02d:%02d  [ЗАНЯТО]\n", nh, nm, eh, em);
        else
            format(line, sizeof(line), "%02d:%02d - %02d:%02d\n", nh, nm, eh, em);
        strcat(output, line, size);
    }
}

stock ProcessNewsCreate(playerid, slotindex) {
    new fractionid = PI[playerid][pFraction];
    if (slotindex < 0 || slotindex >= MAX_NEWS_SLOTS) return SendErr(playerid, "Неверный слот!");
    if (NewsSlotTaken[slotindex]) return SendErr(playerid, "Это время уже занято!");
    new slot = GetFreeNewsSlot();
    if (slot == -1) return SendErr(playerid, "Все слоты заняты!");
    new sh = NEWS_START_HOUR + slotindex / 2;
    new sm = (slotindex % 2) * 30;
    new eh = sh + (sm + 30) / 60;
    new em = (sm + 30) % 60;
    new mh = sh + (sm + 20) / 60;
    new mm = (sm + 20) % 60;
    NewsSlots[slot][news_fractionid]     = fractionid;
    NewsSlots[slot][news_leaderid]       = playerid;
    NewsSlots[slot][news_start_hour]     = sh;
    NewsSlots[slot][news_start_min]      = sm;
    NewsSlots[slot][news_end_hour]       = eh;
    NewsSlots[slot][news_end_min]        = em;
    NewsSlots[slot][news_mid_hour]       = mh;
    NewsSlots[slot][news_mid_min]        = mm;
    NewsSlots[slot][news_active]         = true;
    NewsSlotTaken[slotindex]             = true;
    if (global_hour > sh || (global_hour == sh && global_minute > sm))
        NewsSlots[slot][news_notified_start] = true;
    else
        NewsSlots[slot][news_notified_start] = false;
    if (global_hour > mh || (global_hour == mh && global_minute > mm))
        NewsSlots[slot][news_notified_mid] = true;
    else
        NewsSlots[slot][news_notified_mid] = false;
    NewsSlots[slot][news_notified_end] = false;
    new msg[256];
    format(msg, sizeof(msg), "Собеседование запланировано: %s | %02d:%02d - %02d:%02d",
        GetFractionName(fractionid), sh, sm, eh, em);
    CEFChat_Send(playerid, NEWS_COLOR, msg);
    return 1;
}

stock CheckNewsTimer() {
    for (new i = 0; i < MAX_NEWS_ACTIVE; i++) {
        if (!NewsSlots[i][news_active]) continue;
        new fracid   = NewsSlots[i][news_fractionid];
        new sh       = NewsSlots[i][news_start_hour];
        new sm       = NewsSlots[i][news_start_min];
        new eh       = NewsSlots[i][news_end_hour];
        new em       = NewsSlots[i][news_end_min];
        new nmh      = NewsSlots[i][news_mid_hour];
        new nmm      = NewsSlots[i][news_mid_min];
        new leaderid = NewsSlots[i][news_leaderid];
        new fracName[32], leaderName[MAX_PLAYER_NAME], sep1[128], sep2[128], msg[256];
        format(fracName,   sizeof(fracName),   "%s", GetFractionName(fracid));
        format(leaderName, sizeof(leaderName), "%s", PI[leaderid][pName]);
        sep1 = "————————————— Государственные новости —————————————";
        format(sep2, sizeof(sep2), "————————————— Вещает %s [%d] —————————————", leaderName, leaderid);
        if (!NewsSlots[i][news_notified_start] && global_hour == sh && global_minute == sm) {
            CEFChat_SendAll(NEWS_COLOR, sep1);
            format(msg, sizeof(msg), "%s | Уважаемые жители области! Сейчас будут объявлены новости о начале собеседования в %s", fracName, fracName);
            CEFChat_SendAll("FFFFFF", msg);
            format(msg, sizeof(msg), "%s | %s объявляет начало собеседования", fracName, fracName);
        CEF_OpsNews(msg, "FFD24A");
            CEFChat_SendAll("FFFFFF", msg);
            format(msg, sizeof(msg), "%s | Время проведения: %02d:%02d - %02d:%02d", GetFractionShort(fracid), sh, sm, eh, em);
            CEFChat_SendAll("FFFFFF", msg);
            if (fracid == 6)
                format(msg, sizeof(msg), "%s | Для вступления на службу приедьте в военкомат", GetFractionShort(fracid));
            else
                format(msg, sizeof(msg), "%s | Для участия приедьте в главное управление организации", GetFractionShort(fracid));
            CEFChat_SendAll("FFFFFF", msg);
            CEFChat_SendAll(NEWS_COLOR, sep2);
            NewsSlots[i][news_notified_start] = true;
        }
        if (!NewsSlots[i][news_notified_mid] && global_hour == nmh && global_minute == nmm) {
            CEFChat_SendAll(NEWS_COLOR, sep1);
            format(msg, sizeof(msg), "%s | Уважаемые жители области! Напоминаем о собеседовании в %s", fracName, fracName);
            CEFChat_SendAll("FFFFFF", msg);
            format(msg, sizeof(msg), "%s | Собеседование продолжается. Окончание в %02d:%02d", GetFractionShort(fracid), eh, em);
            CEFChat_SendAll("FFFFFF", msg);
            if (fracid == 6)
                format(msg, sizeof(msg), "%s | Для вступления на службу приедьте в военкомат", GetFractionShort(fracid));
            else
                format(msg, sizeof(msg), "%s | Для участия приедьте в главное управление организации", GetFractionShort(fracid));
            CEFChat_SendAll("FFFFFF", msg);
            CEFChat_SendAll(NEWS_COLOR, sep2);
            NewsSlots[i][news_notified_mid] = true;
        }
        if (!NewsSlots[i][news_notified_end] && global_hour == eh && global_minute == em) {
            CEFChat_SendAll(NEWS_COLOR, sep1);
            format(msg, sizeof(msg), "%s | Уважаемые жители области! Собеседование в %s завершено", fracName, fracName);
            CEFChat_SendAll("FFFFFF", msg);
            format(msg, sizeof(msg), "%s | Благодарим всех участников", GetFractionShort(fracid));
            CEFChat_SendAll("FFFFFF", msg);
            CEFChat_SendAll(NEWS_COLOR, sep2);
            new nidx = News_SlotIndex(sh, sm);
            if (nidx >= 0 && nidx < MAX_NEWS_SLOTS) NewsSlotTaken[nidx] = false;
            NewsSlots[i][news_active]       = false;
            NewsSlots[i][news_notified_end] = true;
        }
    }
}

cmd:news(playerid, params[]) {
    if (!PT[playerid][pLogged]) return 1;
    new list[1536];
    new count = BuildNewsListStr(list, sizeof(list));
    if (count == 0) {
        CEFChat_Send(playerid, "FF4444", "Сейчас собеседований нет.");
        return 1;
    }
    ShowPlayerDialogEx(playerid, DIALOG_NEWS_LIST, DIALOG_STYLE_LIST,
        "СОБЕСЕДОВАНИЯ", list, "Закрыть", "");
    return 1;
}

cmd:create_news(playerid, params[]) {
    if (!PT[playerid][pLogged]) return 1;
    new fractionid = PI[playerid][pFraction];
    if (!IsGovFraction(fractionid)) return SendErr(playerid, "Команда недоступна для вашей организации!");
    if (global_hour >= 20 || global_hour < NEWS_START_HOUR)
    return SendErr(playerid, "Собеседования можно планировать только с 09:00 до 20:00!");
    new maxRank = Fraction[fractionid][fMax_ranks];
    new bool:isLeader = (PI[playerid][pLeader] == fractionid);
    new bool:isDeputy = (PI[playerid][pFractionRank] >= maxRank - 1);
    if (!isLeader && !isDeputy) return SendErr(playerid, "Только лидер или заместитель может создать собеседование!");
    if (GetNewsByFraction(fractionid) != -1) return SendErr(playerid, "Ваша организация уже проводит собеседование!");
    if (GetFreeNewsSlot() == -1) return SendErr(playerid, "Все слоты заняты!");
    new list[1024];
    BuildNewsTimeStr(playerid, list, sizeof(list));
    ShowPlayerDialogEx(playerid, DIALOG_NEWS_CREATE, DIALOG_STYLE_LIST,
        "СОБЕСЕДОВАНИЕ — ВЫБОР ВРЕМЕНИ", list, "Выбрать", "Закрыть");
    return 1;
}

cmd:delete_news(playerid, params[]) {
    if (!PT[playerid][pLogged]) return 1;
    new fractionid = PI[playerid][pFraction];
    new bool:isAdmin  = (PI[playerid][pAdmin] >= 2);
    new bool:isLeader = (PI[playerid][pLeader] == fractionid && fractionid > 0);
    if (!isAdmin && !isLeader) return SendErr(playerid, "Нет прав!");
    new target_frac = -1;
    if (isAdmin && !isnull(params)) target_frac = strval(params);
    else if (isLeader) target_frac = fractionid;
    if (target_frac <= 0) return SendErr(playerid, "Использование: /delete_news [id фракции]");
    new slot = GetNewsByFraction(target_frac);
    if (slot == -1) return SendErr(playerid, "У этой организации нет активного собеседования!");
    new dsh = NewsSlots[slot][news_start_hour];
    new dsm = NewsSlots[slot][news_start_min];
    new didx = News_SlotIndex(dsh, dsm);
    if (didx >= 0 && didx < MAX_NEWS_SLOTS) NewsSlotTaken[didx] = false;
    NewsSlots[slot][news_active] = false;
    new msg[128];
    format(msg, sizeof(msg), "Собеседование %s удалено.", GetFractionName(target_frac));
    CEFChat_Send(playerid, "FF4444", msg);
    return 1;
}

cmd:test_news(playerid, params[]) {
    if (PI[playerid][pAdmin] < 2) return 1;
    new slot = -1;
    for (new i = 0; i < MAX_NEWS_ACTIVE; i++)
        if (NewsSlots[i][news_active]) { slot = i; break; }
    if (slot == -1) return SendErr(playerid, "Нет активных собеседований!");
    new fracid   = NewsSlots[slot][news_fractionid];
    new sh       = NewsSlots[slot][news_start_hour];
    new sm       = NewsSlots[slot][news_start_min];
    new eh       = NewsSlots[slot][news_end_hour];
    new em       = NewsSlots[slot][news_end_min];
    new leaderid = NewsSlots[slot][news_leaderid];
    new fracName[32], leaderName[MAX_PLAYER_NAME], sep1[128], sep2[128], msg[256];
    format(fracName,   sizeof(fracName),   "%s", GetFractionName(fracid));
    format(leaderName, sizeof(leaderName), "%s", PI[leaderid][pName]);
    sep1 = "————————————— Государственные новости —————————————";
    format(sep2, sizeof(sep2), "————————————— Вещает %s [%d] —————————————", leaderName, leaderid);
    CEFChat_Send(playerid, NEWS_COLOR, sep1);
    format(msg, sizeof(msg), "%s | Уважаемые жители области! Сейчас будут объявлены новости о начале собеседования в %s", fracName, fracName);
    CEFChat_Send(playerid, "FFFFFF", msg);
    format(msg, sizeof(msg), "%s | %s объявляет начало собеседования", fracName, fracName);
    CEFChat_Send(playerid, "FFFFFF", msg);
    format(msg, sizeof(msg), "%s | Время проведения: %02d:%02d - %02d:%02d", GetFractionShort(fracid), sh, sm, eh, em);
    CEFChat_Send(playerid, "FFFFFF", msg);
    if (fracid == 6)
        format(msg, sizeof(msg), "%s | Для вступления на службу приедьте в военкомат", GetFractionShort(fracid));
    else
        format(msg, sizeof(msg), "%s | Для участия приедьте в главное управление организации", GetFractionShort(fracid));
    CEFChat_Send(playerid, "FFFFFF", msg);
    CEFChat_Send(playerid, NEWS_COLOR, sep2);
    return 1;
}
