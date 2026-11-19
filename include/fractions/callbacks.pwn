

callback::LoadFractions()
{
    cache_get_row_count(totalFractions);
    if(totalFractions <= 0) return print("[LoadFractions] Фракции не были загружены");
    new count = GetTickCount();
    new tmp_str[32];
    
    if(totalFractions > MAX_FRACTIONS)
    {
        printf("[LoadFractions] В БД %d строк, лимит сборки %d. Лишние строки не загружены.", totalFractions, MAX_FRACTIONS);
        totalFractions = MAX_FRACTIONS;
    }

    for(new f = 0; f < totalFractions; f++)
    {
        cache_get_value_name_int(f, "fraction_ranks", Fraction[f][fMax_ranks]);
        cache_get_value_name_int(f, "fraction_type", Fraction[f][fType]);

        if(Fraction[f][fType] == FRACTION_NONE || Fraction[f][fMax_ranks] < 1) continue;

        cache_get_value_name(f, "fraction_name", Fraction[f][fName], 32);

        cache_get_value_name_int(f, "fraction_total_members", Fraction[f][fTotalMembers]);
            
        cache_get_value_name_float(f, "fraction_spawn_X", Fractions_Spawn[f][0]);
        cache_get_value_name_float(f, "fraction_spawn_Y", Fractions_Spawn[f][1]);
        cache_get_value_name_float(f, "fraction_spawn_Z", Fractions_Spawn[f][2]);
        cache_get_value_name_float(f, "fraction_spawn_A", Fractions_Spawn[f][3]);

        cache_get_value_name_float(f, "fraction_dress_X", Fractions_Dress[f][0]);
        cache_get_value_name_float(f, "fraction_dress_Y", Fractions_Dress[f][1]);
        cache_get_value_name_float(f, "fraction_dress_Z", Fractions_Dress[f][2]);
        
        
        if(Fractions_Dress[f][0] == -1 && Fractions_Dress[f][1] == -1 && Fractions_Dress[f][2] == -1) printf("У фракции %s нет координат раздевалки", GetFractionName(f)); 
        else 
        {
            cache_get_value_name_int(f, "fraction_dress_pickup_model", Fraction[f][fDressPickupModel]);
            CreateDynamicPickup(Fraction[f][fDressPickupModel], 23, Fractions_Dress[f][0], Fractions_Dress[f][1], Fractions_Dress[f][2]);
            Fraction[f][fDressPickup] = CreateDynamicSphere(Fractions_Dress[f][0], Fractions_Dress[f][1], Fractions_Dress[f][2], 1.0, -1, -1, -1);
        }

        cache_get_value_name_float(f, "fraction_armoury_X", Fractions_Armoury[f][0]);
        cache_get_value_name_float(f, "fraction_armoury_Y", Fractions_Armoury[f][1]);
        cache_get_value_name_float(f, "fraction_armoury_Z", Fractions_Armoury[f][2]);

        if(Fractions_Armoury[f][0] == -1 && Fractions_Armoury[f][1] == -1 && Fractions_Armoury[f][2] == -1) printf("У фракции %s нет координат склада", GetFractionName(f));
        else
        {
            cache_get_value_name_int(f, "fraction_armoury_pickup_model", Fraction[f][fArmouryPickupModel]);
            CreateDynamicPickup(Fraction[f][fArmouryPickupModel], 23, Fractions_Armoury[f][0], Fractions_Armoury[f][1], Fractions_Armoury[f][2]);
            Fraction[f][fArmouryPickup] = CreateDynamicSphere(Fractions_Armoury[f][0], Fractions_Armoury[f][1], Fractions_Armoury[f][2], 1.0, -1, -1, -1);
        }

        for(new i = 0; i < Fraction[f][fMax_ranks]; i++)
        {
            tmp_str[0] = EOS;
            format(tmp_str, sizeof tmp_str, "rank%d_name",i+1);
            cache_get_value_name(f, tmp_str, Fraction_Rank[f][i], 32);

            tmp_str[0] = EOS;
            format(tmp_str, sizeof tmp_str, "fraction_skin_%d", i+1);
            cache_get_value_name_int(f, tmp_str, Fraction[f][fSkinMale][i]);

            tmp_str[0] = EOS;
            format(tmp_str, sizeof tmp_str, "fraction_skin_female_%d",i+1);
            cache_get_value_name_int(f, tmp_str, Fraction[f][fSkinFemale][i]);

            tmp_str[0] = EOS;
            format(tmp_str, sizeof tmp_str, "salary_rank_%d",i+1);
            cache_get_value_name_int(f, tmp_str, Fraction[f][fSalary][i]);

            printf("rank %d skin %d fem %d salary %d", i + 1, Fraction[f][fSkinMale][i], Fraction[f][fSkinFemale][i], Fraction[f][fSalary][i]);
        }
    }
    printf("[LoadFractions] Было загружено %d фракций(-я/и) за %d мс.", totalFractions, GetTickCount() - count);
    return 1;
}

callback::LoadFractionsItems()
{
    new count = GetTickCount();
    if(cache_num_rows() <= 0) return print("[LoadFractionsItems] Фракционные предметы отсутствуют в базе данных");

    for(new i = 0; i < cache_num_rows(); i++)
    {
        new fraction_id;
        cache_get_value_name_int(i, "fraction_id", fraction_id);

        cache_get_value_name_int(i, "item_type", Fraction_Items[fraction_id][totalFractionItems[fraction_id]][fiType]);
        cache_get_value_name(i, "item_name", Fraction_Items[fraction_id][totalFractionItems[fraction_id]][fiName], 24);
        cache_get_value_name_int(i, "item_server_id", Fraction_Items[fraction_id][totalFractionItems[fraction_id]][fiServerID]);
        cache_get_value_name_int(i, "item_max_amount", Fraction_Items[fraction_id][totalFractionItems[fraction_id]][fiMaxAmount]);
        cache_get_value_name_int(i, "item_rank_access", Fraction_Items[fraction_id][totalFractionItems[fraction_id]][fiRankAccess]);
        cache_get_value_name_int(i, "item_count", Fraction_Items[fraction_id][totalFractionItems[fraction_id]][fiCount]);
        totalFractionItems[fraction_id]++;

        printf("[LoadFractionsItems] Фракция: %s, Предмет: %s, Тип: %d, Серверный ID: %d, Макс. Кол-во: %d, Доступно для рангов: %d, Кол-во: %d",
            Fraction[fraction_id][fName], Fraction_Items[fraction_id][totalFractionItems[fraction_id]-1][fiName],
            Fraction_Items[fraction_id][totalFractionItems[fraction_id]-1][fiType],
            Fraction_Items[fraction_id][totalFractionItems[fraction_id]-1][fiServerID],
            Fraction_Items[fraction_id][totalFractionItems[fraction_id]-1][fiMaxAmount],
            Fraction_Items[fraction_id][totalFractionItems[fraction_id]-1][fiRankAccess],
            Fraction_Items[fraction_id][totalFractionItems[fraction_id]-1][fiCount]);
    }
    printf("[LoadFractionsItems] Было загружено %d предметов(-а/ов) за %d мс.", cache_num_rows(), GetTickCount() - count);
    return 1;
}

callback::LoadFractionsVehicles()
{
    new count = GetTickCount();
    if(cache_num_rows() <= 0) return print("[LoadFractionsVehicles] Фракционные транспортные средства отсутствуют в базе данных");

    for(new i = 0; i < cache_num_rows(); i++)
    {
        new fraction_id;
        cache_get_value_name_int(i, "fraction_id", fraction_id);

        new totalVeh = totalFractionVehicles[fraction_id];

        cache_get_value_name_float(i, "fraction_veh_spawn_X", Fraction_Vehicles[fraction_id][totalVeh][fvSpawnX]);
        cache_get_value_name_float(i, "fraction_veh_spawn_Y", Fraction_Vehicles[fraction_id][totalVeh][fvSpawnY]);
        cache_get_value_name_float(i, "fraction_veh_spawn_Z", Fraction_Vehicles[fraction_id][totalVeh][fvSpawnZ]);
        cache_get_value_name_float(i, "fraction_veh_spawn_A", Fraction_Vehicles[fraction_id][totalVeh][fvSpawnA]);

        if(Fraction_Vehicles[fraction_id][totalVeh][fvSpawnX] == -1 || Fraction_Vehicles[fraction_id][totalVeh][fvSpawnY] == -1 || Fraction_Vehicles[fraction_id][totalVeh][fvSpawnZ] == -1)
        {
            printf("У автомобиля bdID: %d фракции %s нет координат спавна транспорта", i, GetFractionName(fraction_id));
            continue;
        }

        cache_get_value_name_int(i, "veh_id", Fraction_Vehicles[fraction_id][totalVeh][fvDBID]);
        cache_get_value_name_int(i, "fraction_veh_color1", Fraction_Vehicles[fraction_id][totalVeh][fvColor1]);
        cache_get_value_name_int(i, "fraction_veh_color2", Fraction_Vehicles[fraction_id][totalVeh][fvColor2]);
        cache_get_value_name_int(i, "fraction_veh_model", Fraction_Vehicles[fraction_id][totalVeh][fvModel]);


        new vehicleid = Fraction_Vehicles[fraction_id][totalVeh][fvServerID] = 
        CreateVehicle(
            Fraction_Vehicles[fraction_id][totalVeh][fvModel], 
            Fraction_Vehicles[fraction_id][totalVeh][fvSpawnX], Fraction_Vehicles[fraction_id][totalVeh][fvSpawnY], Fraction_Vehicles[fraction_id][totalVeh][fvSpawnZ], Fraction_Vehicles[fraction_id][totalVeh][fvSpawnA], 
            Fraction_Vehicles[fraction_id][totalVeh][fvColor1], Fraction_Vehicles[fraction_id][totalVeh][fvColor2], 
        3600);

        CI[Fraction_Vehicles[fraction_id][totalVeh][fvServerID]][vOwnerID] = fraction_id;
        CI[Fraction_Vehicles[fraction_id][totalVeh][fvServerID]][vOwnerType] = VEHICLE_OWNER_FRACTION;

        CI[Fraction_Vehicles[fraction_id][totalVeh][fvServerID]][Fuel] = 50;

        cache_get_value_name_bool(i, "fraction_veh_toning", CI[vehicleid][vToningToggled]);
        cache_get_value_name_int(i, "fraction_veh_rank_avaiable", CI[vehicleid][vRankAvaiable]);

        if(CI[vehicleid][vToningToggled] == true)
        {
            cache_get_value_name_int(i, "fraction_veh_toning_R", CI[vehicleid][vToningR]);
            cache_get_value_name_int(i, "fraction_veh_toning_G", CI[vehicleid][vToningG]);
            cache_get_value_name_int(i, "fraction_veh_toning_B", CI[vehicleid][vToningB]);
            cache_get_value_name_int(i, "fraction_veh_toning_A", CI[vehicleid][vToningA]);
        }

        printf("[LoadFractionsVehicles] Фракция: %s, ID: %d, Модель: %d, Цвет1: %d, Цвет2: %d, Айди в базе данных: %d,Spawn: (%f, %f, %f, %f), Серверный ID: %d, Rank Avaiable: %d, Тонировка: %d, Тонировка RGBA: (%d, %d, %d, %d)",
            GetFractionName(fraction_id),
            fraction_id,
            Fraction_Vehicles[fraction_id][totalVeh][fvModel],
            Fraction_Vehicles[fraction_id][totalVeh][fvColor1],
            Fraction_Vehicles[fraction_id][totalVeh][fvColor2],
            Fraction_Vehicles[fraction_id][totalVeh][fvDBID],
            Fraction_Vehicles[fraction_id][totalVeh][fvSpawnX],
            Fraction_Vehicles[fraction_id][totalVeh][fvSpawnY],
            Fraction_Vehicles[fraction_id][totalVeh][fvSpawnZ],
            Fraction_Vehicles[fraction_id][totalVeh][fvSpawnA],
            vehicleid,
            CI[vehicleid][vRankAvaiable],
            CI[vehicleid][vToningToggled],
            CI[vehicleid][vToningR],
            CI[vehicleid][vToningG],
            CI[vehicleid][vToningB],
            CI[vehicleid][vToningA]
        );
        totalFractionVehicles[fraction_id]++;

    }
    printf("[LoadFractionsVehicles] Было загружено %d транспортных средств за %d мс.", cache_num_rows(), GetTickCount() - count);
    return 1;
}

stock GetFractionOnlineMembersCount(fractionid)
{
    new count = 0; 
    foreach(new i : Player) 
    {
        if(PI[i][pFraction] != fractionid) continue;
        count++;
    }
    return count;
}

stock IsACop(playerid)
{
	switch(PI[playerid][pFraction])
	{
	    case 2..4: return 1;
	    default: return 0;
	}
	return 0;
}
stock IsAGos(playerid)
{
	switch(PI[playerid][pFraction])
	{
	    case 1..6: return 1;
	    default: return 0;
	}
	return 0;
}
callback::cuff_time(playerid)
{
    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CUFFED);
    SetPlayerAttachedObject(playerid, 0, 19418, 6, -0.011000, 0.028000, -0.022000, -15.600012, -33.699977, -81.700035, 0.891999, 1.000000, 1.168000);
    TogglePlayerControllable(playerid, 1);
    SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL, 0);
    DisableRemoteVehicleCollisions(playerid, true);

    SetPlayerArmedWeapon(playerid, 0);
    return true;
}
callback::cuff_player(playerid)
{
	ClearAnimations(playerid);
    return true;
}
callback:: FollowToPlayer(playerid)
{
	static AnimShot[MAX_PLAYERS];
	if(!IsPlayerConnected(FollowBy[playerid]))
	{
		KillTimer(TimerForPlayer[playerid]);
		TimerForPlayer[playerid] = MAX_PLAYERS;
		FollowBy[playerid] = MAX_PLAYERS;
		TogglePlayerControllable(playerid, 1);
		ClearAnimations(playerid);
		AnimShot[playerid] = false;
		SendClientMessage(playerid, 0xFFFF00AA, "Вы свободны, конвой покинул сервер!");
		return 1;
	}
	else if(!IsPlayerConnected(playerid))
	{
		SetPVarInt(FollowBy[playerid], "TempFollowBy", -1);
		KillTimer(TimerForPlayer[playerid]);
		TimerForPlayer[playerid] = MAX_PLAYERS;
		AnimShot[playerid] = false;
		SendClientMessage(FollowBy[playerid], 0xFFFF00AA, "Арестованный покинул сервер!");
		FollowBy[playerid] = MAX_PLAYERS;
		return 1;
	}
	else if(FollowBy[playerid] == MAX_PLAYERS)
	{
		KillTimer(TimerForPlayer[playerid]);
		TimerForPlayer[playerid] = MAX_PLAYERS;
		AnimShot[playerid] = false;
		SendClientMessage(playerid, 0xFFFF00AA, "С вашем конвоем произошла беда, вы свободны !");
		TogglePlayerControllable(playerid, 1);
		ClearAnimations(playerid);
		return 1;
	}
	else if(IsPlayerInAnyVehicle(playerid))
	{
		SetPVarInt(FollowBy[playerid], "TempFollowBy", -1);
		KillTimer(TimerForPlayer[playerid]);
		TimerForPlayer[playerid] = MAX_PLAYERS;
		AnimShot[playerid] = false;
		SendClientMessage(FollowBy[playerid], 0xFFFF00AA, "Ваш заключенный в машине. Конвой остановлен");
		FollowBy[playerid] = MAX_PLAYERS;
		return 1;
	}
	else if(GetPlayerVirtualWorld(FollowBy[playerid]) != GetPlayerVirtualWorld(playerid) || GetPlayerInterior(FollowBy[playerid]) != GetPlayerInterior(playerid))
	{
		new Float: X, Float: Y, Float: Z;
		GetPlayerPos(FollowBy[playerid], X, Y, Z);
		SetPlayerPos(playerid, X, Y, Z);
		SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(FollowBy[playerid]));
		SetPlayerInterior(playerid, GetPlayerInterior(FollowBy[playerid]));
		TogglePlayerControllable(playerid, 0);
		AnimShot[playerid] = false;
		return 1;
	}
	new Float: GotDistance = GetDistanceBetweenPlayers(playerid, FollowBy[playerid]);
	new Float: x_posi;
	new Float: y_posi; 
	new Float: z_posi;
	if (GotDistance < 0.95)
	{
		TogglePlayerControllable(playerid, 0);
		if (pCuff[playerid][pCuffer] != INVALID_PLAYER_ID) SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CUFFED);
		SetPlayerToFacePlayer(playerid, FollowBy[playerid]);
		AnimShot[playerid] = false;
		return 1;
	}
	else if (GotDistance > 6.00)
	{
		GetPlayerPos(FollowBy[playerid], x_posi, y_posi, z_posi);
		SetPlayerPos(playerid, x_posi, y_posi - 1.0, z_posi); 
		TogglePlayerControllable(playerid, 1);
		SetPlayerToFacePlayer(playerid, FollowBy[playerid]);
		
		if (pCuff[playerid][pCuffer] != INVALID_PLAYER_ID) SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CUFFED);
		return 1; 
	}
	else if (GotDistance > 1.0 && GotDistance <= 6.00) 
	{
		TogglePlayerControllable(playerid, 1); 
		SetPlayerToFacePlayer(playerid, FollowBy[playerid]); 
		if (pCuff[playerid][pCuffer] != INVALID_PLAYER_ID) SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CUFFED);
		ApplyAnimation(playerid, "ped", "WALK_civi", 6.0, 1, 1, 1, 1, 0, 1); 
	} 
	else 
	{ 
		new Float: fa_posi;

		GetPlayerPos(FollowBy[playerid], x_posi, y_posi, z_posi);
		GetPlayerFacingAngle(FollowBy[playerid], fa_posi);

		SetPlayerPos(playerid, x_posi, y_posi-1.0, z_posi);
		SetPlayerFacingAngle(playerid, fa_posi);

		TogglePlayerControllable(playerid, 1); 
		if (pCuff[playerid][pCuffer] != INVALID_PLAYER_ID) SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CUFFED);
	}
	return 1;
}

stock LoadSuChapters(playerid, targetid)
{
    g_SuTarget[playerid] = targetid;
    new query[64];
    mysql_format(dbHandle, query, sizeof(query),
        "SELECT * FROM `su_chapters` ORDER BY `sort_order` ASC");
    mysql_tquery(dbHandle, query, "ShowSuChapters", "i", playerid);
}

callback::ShowSuChapters(playerid)
{
    if(!cache_num_rows())
        return SendErr(playerid, "Главы не найдены в БД!");

    new list[1024], temp[128], chapterName[64];
    new rows = cache_num_rows();

    for(new i = 0; i < rows; i++)
    {
        cache_get_value_name(i, "name", chapterName, 64);
        format(temp, sizeof(temp), "%s\n", chapterName);
        strcat(list, temp);
    }

    new title[64];
    format(title, sizeof(title), "Розыск — %s [%d]", GetName(g_SuTarget[playerid]), g_SuTarget[playerid]);
    ShowPlayerDialogEx(playerid, DIALOG_SU_CHAPTERS, DIALOG_STYLE_LIST, title, list, "Выбрать", "Отмена");
    return 1;
}


callback::ShowSuArticles(playerid, chapterid)
{
    g_SuChapterId[playerid] = chapterid;

    if(!cache_num_rows())
        return SendErr(playerid, "Статьи не найдены!");

    new list[2048], temp[128], articleName[64];
    new rows = cache_num_rows();

    for(new i = 0; i < rows; i++)
    {
        new wanted;
        cache_get_value_name(i, "name", articleName, 64);
        cache_get_value_name_int(i, "wanted_level", wanted);
        format(temp, sizeof(temp), "%s\t[%d зв.]\n", articleName, wanted);
        strcat(list, temp);
    }

    new title[64];
    format(title, sizeof(title), "Розыск — выберите статью");
    ShowPlayerDialogEx(playerid, DIALOG_SU_ARTICLES, DIALOG_STYLE_TABLIST, title, list, "Выбрать", "Назад");
    return 1;
}
callback::GetSuChapterId(playerid)
{
    if(!cache_num_rows()) return SendErr(playerid, "Глава не найдена!");

    new chapterid;
    cache_get_value_name_int(0, "id", chapterid);
    g_SuChapterId[playerid] = chapterid;

    new query[128];
    mysql_format(dbHandle, query, sizeof(query),
        "SELECT * FROM `su_articles` WHERE `chapter_id`=%d ORDER BY `sort_order` ASC",
        chapterid);
    mysql_tquery(dbHandle, query, "ShowSuArticles", "ii", playerid, chapterid);
    return 1;
}

callback::GetSuArticle(playerid)
{
    if(!cache_num_rows()) return SendErr(playerid, "Статья не найдена!");

    new articleName[64], wanted;
    cache_get_value_name(0, "name", articleName, 64);
    cache_get_value_name_int(0, "wanted_level", wanted);

    new targetid = g_SuTarget[playerid];
    if(!IsPlayerConnected(targetid))
        return SendErr(playerid, "Игрок вышел с сервера!");

    new newWanted = PI[targetid][pWanted] + wanted;
    if(newWanted > 15) newWanted = 15;

    PI[targetid][pWanted] = newWanted;
    SetPlayerWantedLevel(targetid, newWanted);

    new query[128];
    mysql_format(dbHandle, query, sizeof(query),
        "UPDATE `accounts` SET `wanted`=%d WHERE `id`=%d",
        newWanted, PI[targetid][pID]);
    mysql_tquery(dbHandle, query, "", "");

    new msg[192];
    format(msg, sizeof(msg), "Вам выдан розыск %d зв. Статья: %s. Сотрудник: %s.",
        wanted, articleName, GetName(playerid));
    SendClientMessage(targetid, COLOR_RED, msg);

    format(msg, sizeof(msg), "Розыск выдан %s [%d]. Статья: %s.",
        GetName(targetid), targetid, articleName, newWanted);
    SendClientMessage(playerid, COLOR_UNMAZING, msg);

    new radio[192];
    new fractionid = PI[playerid][pFraction];
    new rankName[32], otdelName[32];
    format(rankName, sizeof(rankName), "%s", Fraction_Rank[fractionid][PI[playerid][pFractionRank]-1]);
    GetOtdelName(fractionid, PI[playerid][pPodtdel], otdelName, sizeof(otdelName));

    if(strcmp(otdelName, "Отсутствует", true) != 0)
        format(radio, sizeof(radio), "[R] %s (%s) %s выдал(а) розыск %s [%d]. %s. Итого: %d зв.",
            otdelName, rankName, GetName(playerid), GetName(targetid), targetid, articleName, newWanted);
    else
        format(radio, sizeof(radio), "[R] %s %s выдал(а) розыск %s [%d]. %s. Итого: %d зв.",
            rankName, GetName(playerid), GetName(targetid), targetid, articleName, newWanted);

    foreach(new i : Player)
    {
        if(!IsPlayerConnected(i)) continue;
        if(PI[i][pFraction] != fractionid) continue;
        if(!PT[i][pDuty]) continue;
        SendClientMessage(i, COLOR_RADIO, radio);
    }

    SendAdminMessage(COLOR_GRAY, radio);
    return 1;
}
forward RemoveWantedMapIcon(targetid);
public RemoveWantedMapIcon(targetid)
{
    if(g_WantedMapIcon[targetid] == -1) return;
    foreach(new i : Player)
    {
        if(!IsPlayerConnected(i)) continue;
        new frac = PI[i][pFraction];
        if(frac != 2 && frac != 3 && frac != 4 && frac != 6) continue;
        RemovePlayerMapIcon(i, 10);
    }
    g_WantedMapIcon[targetid] = -1;
}

stock StartChase(officerID, targetid)
{
    g_IsChased[targetid]     = true;
    g_ChaseOfficer[targetid] = officerID;
    g_ChaseTarget[officerID] = targetid;

    cef_create_browser(targetid, CHASE_BROWSER, CHASE_CEF_LINK, false, false);

    SetTimerEx("SendChaseNotify", 1500, false, "i", targetid);

    new msg[128];
    format(msg, sizeof(msg), "За вами начато преследование сотрудником %s. Не покидайте сервер!", GetName(officerID));
    SendClientMessage(targetid, COLOR_RED, msg);

    format(msg, sizeof(msg), "Вы начали преследование игрока %s [%d].", GetName(targetid), targetid);
    SendClientMessage(officerID, COLOR_UNMAZING, msg);

    new radio[192];
    new fractionid = PI[officerID][pFraction];
    format(radio, sizeof(radio), "[R] %s начал(а) преследование %s [%d].",
        GetName(officerID), GetName(targetid), targetid);
    foreach(new i : Player)
    {
        if(!IsPlayerConnected(i)) continue;
        if(PI[i][pFraction] != fractionid) continue;
        if(!PT[i][pDuty]) continue;
        SendClientMessage(i, COLOR_RADIO, radio);
    }

    g_ChaseTimer[targetid] = SetTimerEx("ChaseExpired", CHASE_DURATION * 1000, false, "i", targetid);
    g_ChaseDistanceTimer[targetid] = SetTimerEx("CheckChaseDistance", CHASE_DIST_CHECK, true, "i", targetid);
}


stock StopChase(targetid, bool:expired)
{
    if(!g_IsChased[targetid]) return;
    g_IsChased[targetid] = false;

    new officerID = g_ChaseOfficer[targetid];

    if(!expired && g_ChaseTimer[targetid] != -1)
    {
        KillTimer(g_ChaseTimer[targetid]);
        g_ChaseTimer[targetid] = -1;
    }

    if(g_ChaseDistanceTimer[targetid] != -1)
    {
        KillTimer(g_ChaseDistanceTimer[targetid]);
        g_ChaseDistanceTimer[targetid] = -1;
    }

    if(IsPlayerConnected(targetid))
    {
        cef_destroy_browser(targetid, CHASE_BROWSER);
        if(!expired) SendClientMessage(targetid, COLOR_GRAY, "Преследование снято.");
    }

    g_ChaseOfficer[targetid] = INVALID_PLAYER_ID;
    if(officerID != INVALID_PLAYER_ID)
        g_ChaseTarget[officerID] = INVALID_PLAYER_ID;
}

forward ChaseExpired(targetid);
public ChaseExpired(targetid)
{
    StopChase(targetid, true);
    if(IsPlayerConnected(targetid))
        SendClientMessage(targetid, COLOR_GRAY, "Преследование завершено.");
}
forward CheckChaseDistance(targetid);
public CheckChaseDistance(targetid)
{
    if(!g_IsChased[targetid]) return;
    new officerID = g_ChaseOfficer[targetid];

    if(!IsPlayerConnected(officerID) || !IsPlayerConnected(targetid))
    {
        StopChase(targetid, false);
        return;
    }

    new Float:tx, Float:ty, Float:tz;
    GetPlayerPos(targetid, tx, ty, tz);

    if(GetPlayerDistanceFromPoint(officerID, tx, ty, tz) > CHASE_BREAK_DISTANCE)
    {
        StopChase(targetid, false);
        SendClientMessage(targetid, COLOR_GRAY, "Вы оторвались от преследования.");
        SendClientMessage(officerID, COLOR_GRAY, "Цель оторвалась от преследованиz.");
    }
}
forward SendChaseNotify(targetid);
public SendChaseNotify(targetid)
{
    if(!IsPlayerConnected(targetid)) return 1;
    if(!g_IsChased[targetid]) return 1;

    new officerID = g_ChaseOfficer[targetid];
    new msg[128];
    format(msg, sizeof(msg), "Вас преследуют! Преследование начал: %s [%d]", GetName(officerID), officerID);
    cef_emit_event(targetid, "notify:full", CEFINT(1), CEFSTR("Внимание!"), CEFSTR(msg), CEFINT(7000));
    return 1;
}
forward OnCefEvent(playerid, const event[], const arguments[]);
public OnCefEvent(playerid, const event[], const arguments[])
{
    if(!strcmp(event, "frisk:click"))
    {
        new action, activeId;
        sscanf(arguments, "p<,>ii", action, activeId); 
        

        CallLocalFunction("OnDialogResponse", "iiiis", playerid, dialog_PLAYER_FRISK, action, activeId, "\0");
        return 1;
    }
    return 1;
}
stock InitWarehouseAreas()
{
    g_FsbWarehousePickup = CreateDynamicPickup(1275, 1, 1629.5416, 1185.2831, 1664.0236);
    g_PpsWarehousePickup = CreateDynamicPickup(1275, 1, PPS_SCLAD_X, PPS_SCLAD_Y, PPS_SCLAD_Z);
    g_GaiWarehousePickup = CreateDynamicPickup(1275, 1, GAI_SCLAD_X, GAI_SCLAD_Y, GAI_SCLAD_Z);
    g_VchWarehousePickup = CreateDynamicPickup(1275, 1, VCH_SCLAD_X, VCH_SCLAD_Y, VCH_SCLAD_Z);
    return 1;
}

stock HandleWarehousePickup(playerid, STREAMER_TAG_PICKUP:pickupid)
{
    if(!PT[playerid][pLogged]) return 0;
    if(!PT[playerid][pDuty])   return 0;


    if(pickupid == STREAMER_TAG_PICKUP:g_FsbWarehousePickup)
    {
        if(PI[playerid][pFraction] != FRACTION_FSB) return SendErr(playerid, "Вы не являетесь сотрудником ФСБ!"), 1;
        if(g_FsbWarehouseOpen[playerid]) return 1;
        g_FsbWarehouseOpen[playerid] = true;
        CEF_OpsStorageOpen(playerid);
        cef_focus_browser(playerid, WAREHOUSE_FSB_BROWSER, true);
        TogglePlayerControllable(playerid, 0);
        return 1;
    }


    if(pickupid == STREAMER_TAG_PICKUP:g_PpsWarehousePickup)
    {
        if(PI[playerid][pFraction] != FRACTION_PATROL_POLICE) return SendErr(playerid, "Вы не являетесь сотрудником ППС!"), 1;
        if(g_PpsWarehouseOpen[playerid]) return 1;
        g_PpsWarehouseOpen[playerid] = true;
        cef_create_browser(playerid, PPS_WAREHOUSE_BROWSER, PPS_WAREHOUSE_LINK, false, true);
        cef_focus_browser(playerid, PPS_WAREHOUSE_BROWSER, true);
        TogglePlayerControllable(playerid, 0);
        return 1;
    }


    if(pickupid == STREAMER_TAG_PICKUP:g_GaiWarehousePickup)
    {
        if(PI[playerid][pFraction] != FRACTION_TRAFFIC_PATROL_POLICE) return SendErr(playerid, "Вы не являетесь сотрудником ГАИ!"), 1;
        if(g_PpsWarehouseOpen[playerid]) return 1;
        g_PpsWarehouseOpen[playerid] = true;
        cef_create_browser(playerid, PPS_WAREHOUSE_BROWSER, PPS_WAREHOUSE_LINK, false, true);
        cef_focus_browser(playerid, PPS_WAREHOUSE_BROWSER, true);
        TogglePlayerControllable(playerid, 0);
        return 1;
    }


    if(pickupid == STREAMER_TAG_PICKUP:g_VchWarehousePickup)
    {
        if(PI[playerid][pFraction] != FRACTION_MILITARY) return SendErr(playerid, "Вы не являетесь сотрудником ВЧ!"), 1;
        if(g_VchWarehouseOpen[playerid]) return 1;
        g_VchWarehouseOpen[playerid] = true;
        cef_create_browser(playerid, VCH_WAREHOUSE_BROWSER, VCH_WAREHOUSE_LINK, false, true);
        cef_focus_browser(playerid, VCH_WAREHOUSE_BROWSER, true);
        TogglePlayerControllable(playerid, 0);
        return 1;
    }

    return 0;
}
stock ResetCuffState(playerid)
{
    if(pCuff[playerid][pCuffer] != INVALID_PLAYER_ID)
    {
        new cuffer = pCuff[playerid][pCuffer];
        pCuff[cuffer][pCuffee] = INVALID_PLAYER_ID;
    }
    if(pCuff[playerid][pCuffee] != INVALID_PLAYER_ID)
    {
        new cuffee = pCuff[playerid][pCuffee];
        pCuff[cuffee][pCuffer] = INVALID_PLAYER_ID;
        if(IsPlayerConnected(cuffee))
        {
            TogglePlayerControllable(cuffee, 1);
            ClearAnimations(cuffee);
        }
    }
    pCuff[playerid][pCuffer] = INVALID_PLAYER_ID;
    pCuff[playerid][pCuffee] = INVALID_PLAYER_ID;
}

