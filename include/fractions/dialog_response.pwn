case dialog_FRACTION_WAREHOUSE:
{
    if(!response) return 1;
    
    if(PT[playerid][pDuty] == false)
    {
        SetPlayerSkin(playerid, PI[playerid][pFractionSkin]);
        SendClientMessage(playerid, COLOR_BLUE, "Вы начали рабочий день");
        PT[playerid][pDuty] = true;
    }
    else 
    {
        SetPlayerSkin(playerid, PI[playerid][pSkin]); 
        ResetPlayerWeapons(playerid);
        SendClientMessage(playerid, COLOR_BLUE, "Вы завершили рабочий день");
        PT[playerid][pDuty] = false;
    }
    return 1;
}

case dialog_FRACTION_WAREHOUSE + 1:
{
    if(response == 0) return 1;
    
    new index;
    new frac = PI[playerid][pFraction];

    for(new j = 0; j < totalFractionItems[frac]; j++)
    {
        if(Fraction_Items[frac][j][fiCount] <= 0) continue;

        if(Fraction_Items[frac][j][fiRankAccess] < PI[playerid][pFractionRank]) continue;

        if(index == listitem)
        {
            if(Fraction_Items[frac][j][fiType] == FI_TYPE_NONE) return 0;

            if(Fraction_Items[frac][j][fiType] == FI_TYPE_WEAPON)
            {
                GivePlayerWeapon(playerid, Fraction_Items[frac][j][fiServerID], Fraction_Items[frac][j][fiMaxAmount]);
            }

            Fraction_Items[frac][j][fiCount]--;

            SCMF(playerid, COLOR_LIME, "Вы взяли предмет \"%s\" со склада организации в количестве %d.", Fraction_Items[frac][j][fiName], Fraction_Items[frac][j][fiMaxAmount]);
        }
        index++;
    }
    return 1;
}

case dialog_FRACTION_MEMBERS:
{
    if(response == 0) return 0;
    if(PI[playerid][pFraction] == FRACTION_NONE) return SendErr(playerid, "Вы не состоите в организации");

    PT[playerid][pPageDialog]++;
    
    new fractionid = PI[playerid][pFraction];
    new frac_string[144 * 15] = "ID\tРанг\tСтатус\tТелефон\tAFK\n", temp_string[144];
    new index = 0;
    new members_count = GetFractionOnlineMembersCount(fractionid);

    foreach(new i : Player)
    {
        if(PI[i][pFraction] != fractionid) continue;
        if(index > PT[playerid][pPageDialog] * 15) continue;

        format(temp_string, sizeof temp_string, "{e69348}%d.{FFFFFF}\t%s\t%s{FFFFFF}\t%s\t%s\n", i, GetName(i), PI[i][pFractionSkin] > 0 ? "{99cc00}На работе" : "{ff6347}Отстранён", "Нет", GetVarAsString(PI[i][pAFK]));
        strcat(frac_string, temp_string);

        index++;
    }

    if(members_count < 15) strcat(frac_string, "{FFFFFF} Следующая страница");
    if(index == 0) return SendErr(playerid, "В вашей организации нет членов.");

    ShowPlayerDialogEx(playerid, dialog_FRACTION_MEMBERS, DIALOG_STYLE_TABLIST_HEADERS, GetFractionName(fractionid), frac_string, "Далее", "Выход");
    return 1;
}


case dialog_FRACTION_CLOTHES:
{
    if(!response) return SendErr(playerid, "Вы отказались от выбора служебной формы.");
    
    new frac = PI[playerid][pFraction];
    new count = 0;
    new selected_skin = -1;
    

    for(new s = 0; s < MAX_FRACTION_SKINS; s++)
    {
        if(g_FractionSkins[frac][s] == 0) continue;
        
        if(count == listitem)
        {
            selected_skin = g_FractionSkins[frac][s];
            break;
        }
        count++;
    }
    
    if(selected_skin != -1)
    {
        PT[playerid][pDuty] = true;
        PI[playerid][pFractionSkin] = selected_skin;
        SetPlayerSkin(playerid, selected_skin);
        
        SCMF(playerid, COLOR_UNMAZING, "Вы начали рабочий день. Вам выдана форма организации (ID: %d).", selected_skin);
    }
    return 1;
}
case dialog_LEAVE_CONFIRM:
{
    if(!response) return 1;
    

    if(strcmp(inputtext, "Да", true) != 0)
    {
        SendErr(playerid, "Вы ввели неверное слово для подтверждения!");
        return 1;
    }

    new fractionid = PI[playerid][pFraction];
    if(fractionid <= 0) return SendErr(playerid, "Вы не состоите в организации!");

    new msg[140];
    format(msg, sizeof(msg), "[R] %s [%d] покинул организацию по собственному желанию (/leave)", GetName(playerid), playerid);

    foreach(new i : Player)
    {
        if(!IsPlayerConnected(i)) continue;
        if(PI[i][pFraction] == fractionid) SendClientMessage(i, 0x54b367FF, msg); 
    }


    Otdel_RemovePlayerSilent(playerid);
    if(PI[playerid][pFraction] == 6) {
        VchBilyet_Reset(playerid);
        VchPost_Leave(playerid, false);
    }
    PI[playerid][pFraction] = 0;
    PI[playerid][pFractionRank] = 0;
    PT[playerid][pDuty] = false;
    PI[playerid][pPodtdel] = -1;

    SetPlayerSkin(playerid, PI[playerid][pSkin]); 


    new query[128];
    mysql_format(dbHandle, query, sizeof(query), "UPDATE `users` SET `fraction` = 0, `rank` = 0, `otdel` = -1 WHERE `id` = %d", PI[playerid][pID]);
    mysql_tquery(dbHandle, query, "", "");

    SendClientMessage(playerid, COLOR_UNMAZING, "Вы успешно покинули организацию.");
    return 1;
}
case DIALOG_SU_CHAPTERS:
{
    if(!response) return 1;

    new query[128];
    mysql_format(dbHandle, query, sizeof(query),
        "SELECT id FROM `su_chapters` ORDER BY `sort_order` ASC LIMIT 1 OFFSET %d",
        listitem);
    mysql_tquery(dbHandle, query, "GetSuChapterId", "i", playerid);
    return 1;
}

case DIALOG_SU_ARTICLES:
{
    if(!response)
    {
        LoadSuChapters(playerid, g_SuTarget[playerid]);
        return 1;
    }

    new query[192];
    mysql_format(dbHandle, query, sizeof(query),
        "SELECT * FROM `su_articles` WHERE `chapter_id`=%d ORDER BY `sort_order` ASC LIMIT 1 OFFSET %d",
        g_SuChapterId[playerid], listitem);
    mysql_tquery(dbHandle, query, "GetSuArticle", "i", playerid);
    return 1;
}

case DIALOG_SU_CONFIRM:
{
    if(!response) return 1;

    new targetid = g_SuTarget[playerid];
    if(!IsPlayerConnected(targetid))
        return SendErr(playerid, "Игрок вышел с сервера!");

    new newWanted = PI[targetid][pWanted] + g_SuWantedLevel[playerid];
    if(newWanted > 6) newWanted = 6;

    PI[targetid][pWanted] = newWanted;
    SetPlayerWantedLevel(targetid, newWanted);

    new query[128];
    mysql_format(dbHandle, query, sizeof(query),
        "UPDATE `accounts` SET `wanted`=%d WHERE `id`=%d",
        newWanted, PI[targetid][pID]);
    mysql_tquery(dbHandle, query, "", "");

    new msg[192];
    format(msg, sizeof(msg), "Вам выдан розыск %d зв. Статья: %s. Сотрудник: %s.",
        g_SuWantedLevel[playerid], g_SuArticleName[playerid], GetName(playerid));
    SendClientMessage(targetid, COLOR_RED, msg);

    format(msg, sizeof(msg), "Розыск выдан %s [%d]. Статья: %s. Розыск: %d зв.",
        GetName(targetid), targetid, g_SuArticleName[playerid], newWanted);
    SendClientMessage(playerid, COLOR_UNMAZING, msg);


    new radio[192];
    format(radio, sizeof(radio), "[R] %s выдал розыск %s. Статья: %s. Звёзд: %d.",
        GetName(playerid), GetName(targetid), g_SuArticleName[playerid], newWanted);
    foreach(new i : Player)
    {
        if(PI[i][pFraction] != PI[playerid][pFraction]) continue;
        if(!PT[i][pDuty]) continue;
        SendClientMessage(i, COLOR_RADIO, radio);
    }

    SendAdminMessage(COLOR_GRAY, radio);
    return 1;
}
case DIALOG_WANTED_LIST:
{
    if(!response) return 1;


    if(g_WantedCooldown[playerid] > gettime())
    {
        new msg[64];
        format(msg, sizeof(msg), "Повторный пробив доступен через %d сек.", g_WantedCooldown[playerid] - gettime());
        return SendErr(playerid, msg);
    }


    new count = 0, targetid = INVALID_PLAYER_ID;
    foreach(new i : Player)
    {
        if(!PT[i][pLogged]) continue;
        if(PI[i][pWanted] <= 0) continue;
        if(count == listitem) { targetid = i; break; }
        count++;
    }

    if(targetid == INVALID_PLAYER_ID || !IsPlayerConnected(targetid))
        return SendErr(playerid, "Игрок вышел с сервера!");

    g_WantedCooldown[playerid] = gettime() + 20;

    new Float:x, Float:y, Float:z;
    GetPlayerPos(targetid, x, y, z);

    new fractionid = PI[playerid][pFraction];

    if(g_WantedMapIcon[targetid] != -1)
    {
        RemovePlayerMapIcon(playerid, g_WantedMapIcon[targetid]);
    }

    SetPlayerMapIcon(playerid, 10, x, y, z, 4, 0xFF0000FF, MAPICON_GLOBAL);
    g_WantedMapIcon[targetid] = 10;


    new msg[192], rankName[32];
    format(rankName, sizeof(rankName), "%s", Fraction_Rank[fractionid][PI[playerid][pFractionRank]-1]);

    new otdelName[32];
    GetOtdelName(fractionid, PI[playerid][pPodtdel], otdelName, sizeof(otdelName));

    if(strcmp(otdelName, "Отсутствует", true) != 0)
        format(msg, sizeof(msg), "[R] %s (%s) %s пробил(а) розыск: %s [%d] — %d зв.",
            otdelName, rankName, GetName(playerid), GetName(targetid), targetid, PI[targetid][pWanted]);
    else
        format(msg, sizeof(msg), "[R] %s %s пробил(а) розыск: %s [%d] — %d зв.",
            rankName, GetName(playerid), GetName(targetid), targetid, PI[targetid][pWanted]);

    foreach(new i : Player)
    {
        if(!IsPlayerConnected(i)) continue;
        if(PI[i][pFraction] != fractionid) continue;
        if(!PT[i][pDuty]) continue;
        SendClientMessage(i, COLOR_RADIO, msg);


        SetPlayerMapIcon(i, 10, x, y, z, 4, 0xFF0000FF, MAPICON_GLOBAL);
    }


    new info[128];
    format(info, sizeof(info), "Пробит розыск: %s [%d]. Розыск: %d зв. Игрок отмечен на карте добавлена на карту.",
        GetName(targetid), targetid, PI[targetid][pWanted]);
    SendClientMessage(playerid, COLOR_UNMAZING, info);


    SetTimerEx("RemoveWantedMapIcon", 30000, false, "i", targetid);

    return 1;
}
case DIALOG_NEWS_LIST: return 1;
case DIALOG_NEWS_CREATE:
{
    if (!response) return 1;
    ProcessNewsCreate(playerid, g_NewsSlotMap[playerid][listitem]);
    return 1;
}

case DIALOG_WB_MAIN:
{
    if(!response) return 1;

    new list[1024], line[64];
    new targetid = g_WBViewTarget[playerid];
    for(new f = 1; f < totalFractions; f++) {
        if(f == FRACTION_FSB && !CanViewWorkbook(playerid, targetid)) continue;
        format(line, sizeof(line), "%s\n", Fraction[f][fName]);
        strcat(list, line);
    }
    new title[64];
    format(title, sizeof(title), "История — %s", GetName(targetid));
    ShowPlayerDialogEx(playerid, DIALOG_WB_ORGS, DIALOG_STYLE_LIST, title, list, "Просмотр", "Назад");
    return 1;
}

case DIALOG_WB_ORGS:
{
    if(!response) {

        CallLocalFunction("OnPlayerCommandText", "is", playerid, "/mytk");
        return 1;
    }

    new targetid = g_WBViewTarget[playerid];
    new fracId = 0, count = 0;
    for(new f = 1; f < totalFractions; f++) {
        if(f == FRACTION_FSB && !CanViewWorkbook(playerid, targetid)) continue;
        if(count == listitem) { fracId = f; break; }
        count++;
    }
    if(!fracId) return 1;

    new query[160];
    mysql_format(dbHandle, query, sizeof(query),
        "SELECT * FROM `work_history` WHERE `player_id`=%d AND `fraction_id`=%d ORDER BY `id` DESC",
        PI[targetid][pID], fracId);
    mysql_tquery(dbHandle, query, "OnWBHistoryLoaded", "i", playerid);
    return 1;
}

case DIALOG_WB_HISTORY:
{
    if(!response) {

        new list[1024], line[64];
        new targetid = g_WBViewTarget[playerid];
        for(new f = 1; f < totalFractions; f++) {
            if(f == FRACTION_FSB && !CanViewWorkbook(playerid, targetid)) continue;
            format(line, sizeof(line), "%s\n", Fraction[f][fName]);
            strcat(list, line);
        }
        new title[64];
        format(title, sizeof(title), "История — %s", GetName(targetid));
        ShowPlayerDialogEx(playerid, DIALOG_WB_ORGS, DIALOG_STYLE_LIST, title, list, "Просмотр", "Назад");
        return 1;
    }
    return 1;
}

case DIALOG_WB_INVITE:
{
    new inviterid = g_WBTarget[playerid];
    if(!IsPlayerConnected(inviterid)) return 1;
    if(!response) {
        CEFChat_Send(inviterid, "FF4444", "Игрок отказался от приглашения.");
        g_WBTarget[playerid] = -1;
        return 1;
    }
    new frac = PI[inviterid][pFraction];
    PI[playerid][pFraction]     = frac;
    PI[playerid][pFractionRank] = 1;
    WB_AddRecord(playerid, WB_ACTION_INVITE, 0, 1, "", GetName(inviterid));
    new query[96];
    mysql_format(dbHandle, query, sizeof(query),
        "UPDATE `accounts` SET `fraction`=%d,`fraction_rank`=1 WHERE `id`=%d",
        frac, PI[playerid][pID]);
    mysql_tquery(dbHandle, query, "", "");
    new msg[128];
    format(msg, sizeof(msg), "Вы приняты в организацию {e69348}%s{FFFFFF}.", Fraction[frac][fName]);
    CEFChat_Send(playerid, "54B367", msg);
    format(msg, sizeof(msg), "%s принял приглашение.", GetName(playerid));
    CEFChat_Send(inviterid, "54B367", msg);
    new frac_msg[128];
    format(frac_msg, sizeof(frac_msg), "[Орг] %s вступил в организацию.", GetName(playerid));
    foreach(new i : Player) {
        if(PI[i][pFraction] == frac && PT[i][pLogged])
            CEFChat_Send(i, "AAAAAA", frac_msg);
    }
    g_WBTarget[playerid] = -1;
    return 1;
}
case DIALOG_SOS_MAIN:
{
    if(!response) return 1;
    switch(listitem) {
        case 0: ShowSOSList(playerid);
        case 1: AddSOS(playerid);
    }
    return 1;
}
case DIALOG_SOS_LIST:
{
    if(!response) {
        ShowPlayerDialogEx(playerid, DIALOG_SOS_MAIN, DIALOG_STYLE_LIST,
            "СРОЧНАЯ ПОМОЩЬ", "Список SOS-вызовов\nВызов SOS", "Выбрать", "Закрыть");
        return 1;
    }
    AcceptSOS(playerid, listitem);
    return 1;
}
case DIALOG_VCH_PSYCH:  VchPsych_Response(playerid, response, listitem);
case DIALOG_VCH_USTAV:  VchUstav_Response(playerid, response, listitem);
case DIALOG_VCH_BILYET: VchBilyet_Response(playerid, response);
case DIALOG_CHASE_LIST:
{
    if(!response) return 1;
    if(listitem >= g_ChaseListCount[playerid]) return 1;
    new targetid = g_ChaseListTargets[playerid][listitem];
    if(!IsPlayerConnected(targetid) || g_IsChased[targetid]) return SendErr(playerid, "Этот игрок недоступен.");

    new Float:px, Float:py, Float:pz, Float:tx, Float:ty, Float:tz;
    GetPlayerPos(playerid, px, py, pz);
    GetPlayerPos(targetid, tx, ty, tz);
    if(!IsPlayerInRangeOfPoint(playerid, CHASE_RADIUS, tx, ty, tz))
        return SendErr(playerid, "Игрок отошёл слишком далеко.");

    StartChase(playerid, targetid);
    return 1;
}

case DIALOG_CHASE_STOP:
{
    if(!response) return 1;
    new targetid = g_ChaseTarget[playerid];
    if(!IsPlayerConnected(targetid) || !g_IsChased[targetid] || g_ChaseOfficer[targetid] != playerid)
        return SendErr(playerid, "Преследование уже завершено.");

    StopChase(targetid, false);

    new msg[128];
    format(msg, sizeof(msg), "Преследование %s [%d] снято.", GetName(targetid), targetid);
    SendClientMessage(playerid, COLOR_UNMAZING, msg);
    return 1;
}
