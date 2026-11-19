cmd:r(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;
    if(PI[playerid][pFraction] <= 0) return SendErr(playerid, "Вы не состоите в организации!");
    if(!PT[playerid][pDuty]) return SendErr(playerid, "Вы должны начать рабочий день!");
    if(isnull(params)) return SendErr(playerid, "Использование: /r [текст]");

    new fractionid = PI[playerid][pFraction];
    new msg[256], otdelName[32], role[32];


    GetOtdelName(fractionid, g_PlayerOtdelID[playerid], otdelName, sizeof(otdelName));


    new idx = GetPlayerOtdelIdx(playerid);
    new dbid = PI[playerid][pID];
    if(idx >= 0) {
        if(g_Otdel[fractionid][idx][otdel_ChiefDBID] == dbid)
            format(role, sizeof(role), "Начальник");
        else if(g_Otdel[fractionid][idx][otdel_Dep1DBID] == dbid ||
                g_Otdel[fractionid][idx][otdel_Dep2DBID] == dbid ||
                g_Otdel[fractionid][idx][otdel_Dep3DBID] == dbid)
            format(role, sizeof(role), "Заместитель");
    }

    new rankName[32];
    format(rankName, sizeof(rankName), "%s", Fraction_Rank[fractionid][PI[playerid][pFractionRank]-1]);

    if(strcmp(otdelName, "Отсутствует", true) != 0) {
        if(strlen(role) > 0)
            format(msg, sizeof(msg), "[R] %s | %s (%s) %s: %s", otdelName, role, rankName, GetName(playerid), params);
        else
            format(msg, sizeof(msg), "[R] %s (%s) %s: %s", otdelName, rankName, GetName(playerid), params);
    } else {
        format(msg, sizeof(msg), "[R] %s %s: %s", rankName, GetName(playerid), params);
    }

    foreach(new i : Player) {
        if(!IsPlayerConnected(i)) continue;
        if(PI[i][pFraction] != fractionid) continue;
        if(!PT[i][pDuty]) continue;
        SendClientMessage(i, COLOR_RADIO, msg);
    }
    if(PI[playerid][pFraction] != FRACTION_FSB)
        FSB_SendListen(PI[playerid][pFraction], GetName(playerid), params);

    return 1;
}

cmd:d(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;
    if(PI[playerid][pFraction] <= 0) return SendErr(playerid, "Вы не состоите в организации!");
    if(!PT[playerid][pDuty]) return SendErr(playerid, "Вы должны начать рабочий день!");
    if(isnull(params)) return SendErr(playerid, "Использование: /d [текст]");

    new msg[144];

    format(msg, sizeof(msg), "[Департамент] %s [%d]: %s", GetName(playerid), playerid, params);

    foreach(new i : Player)
    {
        if(!IsPlayerConnected(i)) continue;
        if(PI[i][pFraction] <= 0) continue;
        if(!PT[i][pDuty]) continue;
        
        SendClientMessage(i, COLOR_DEPT, msg);
    }
    return 1;
}

cmd:showall(playerid)
{
    if(PI[playerid][pFraction] == FRACTION_NONE) return SendErr(playerid, messageUnknownCMD);

    new fractionid = PI[playerid][pFraction];
    new frac_string[144 * 15] = "ID\tРанг\tСтатус\tТелефон\tAFK\n", temp_string[144];
    new index = 0;
    new members_count = GetFractionOnlineMembersCount(fractionid);

    foreach(new i : Player)
    {
        if(PI[i][pFraction] != fractionid) continue;
        format(temp_string, sizeof temp_string, "{e69348}%d.{FFFFFF}\t%s\t%s{FFFFFF}\t%s\t%s\n", i, GetName(i), PI[i][pFractionSkin] > 0 ? "{99cc00}На работе" : "{ff6347}Отстранён", "Нет", GetVarAsString(PI[i][pAFK]));
        strcat(frac_string, temp_string);

        index++;
    }

    if(members_count < 15) strcat(frac_string, "{FFFFFF} Следующая страница");

    PT[playerid][pPageDialog] = 0;

    ShowPlayerDialogEx(playerid, dialog_OK, DIALOG_STYLE_TABLIST_HEADERS, GetFractionName(fractionid), frac_string, "Далее", "Выход");
    SCMF(playerid, COLOR_BLUE, "Было показано %d членов фракции", members_count);
    return 1;
}

CMD:gotome(playerid, params[])
{
	extract params -> new gotplayer; else return SendClientMessage(playerid, COLOR_LIME, "Используйте{FFFFFF} /gotome [id игрока]");

	if(IsACop(playerid))
	{
		if(playerid == gotplayer) return SendClientMessage(playerid, -1, "Вы не можите сопровождать самого себя");
		else if(!IsPlayerConnected(gotplayer)) return SendClientMessage(playerid, -1, "Такого игрока нет на сервере");
		else if(IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, -1, "Вы не можете вести конвой с  машины!");
		else if(FollowBy[playerid] != MAX_PLAYERS) return SendClientMessage(playerid, -1, "Вы не можете взять игрока под конвой, когда сами конвоируетесь!");
		else if(pCuff[gotplayer][pCuffer] == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "Человек должен быть в наручниках или связан!");
		else if(IsPlayerInAnyVehicle(gotplayer)) return SendClientMessage(playerid, -1, "Вы не можете взять под конвой когда игрок в машине!");
		if(!ProxDetectorS(2.0, playerid, gotplayer)) return SendClientMessage(playerid, -1, "Вы далеко друг от друга");
		else if(FollowBy[gotplayer] != MAX_PLAYERS)
		{

			SetPVarInt(playerid, "TempFollowBy", -1);
			FollowBy[gotplayer] = MAX_PLAYERS;
			KillTimer(TimerForPlayer[gotplayer]);
			TimerForPlayer[gotplayer] = MAX_PLAYERS;
			ClearAnimations(gotplayer);
			TogglePlayerControllable(gotplayer, 1);
			SendClientMessage(playerid, -1, "Вы успешно закончили конвой за игроком!");
			return SendClientMessage(gotplayer, -1, "С вас был снят конвой!");
		}
		if(GetPVarInt(playerid, "TempFollowBy") > 0) return SendClientMessage(playerid, -1, "Вы не можете сопровождать больше 2х игроков одновременно!");
		FollowBy[gotplayer] = playerid;
		SetPVarInt(playerid, "TempFollowBy", gotplayer);
		TimerForPlayer[gotplayer] = SetTimerEx("FollowToPlayer", 1000, 1, "i", gotplayer);
		SendClientMessage(playerid, -1, "Вы успешно начали сопровождение этого игрока!");
		return SendClientMessage(gotplayer, -1, "Вас взяли под конвой");
	}
	return 1;
}

CMD:cuff(playerid, params[])
{
	if(!IsACop(playerid)) return SendErr(playerid, messageUnknownCMD);
	extract params -> new to_player; else return CEFChat_Send(playerid, "FF4444", "Используйте{FFFFFF} /cuff [id игрока]");

	if(!IsPlayerConnected(to_player)) return CEFChat_Send(playerid, "FF4444", "Такого игрока нет");
	if(!ProxDetectorS(3.0, playerid, to_player)) return CEFChat_Send(playerid, "FF4444", "Вы далеко друг от друга");
	if(to_player == playerid) return CEFChat_Send(playerid, "FF4444", "Вы не можете надеть наручники на себя!");
	if(pCuff[playerid][pCuffer] != INVALID_PLAYER_ID) return CEFChat_Send(playerid, "FF4444", "Вы сами в наручниках!");
	if(pCuff[to_player][pCuffer] != INVALID_PLAYER_ID) return CEFChat_Send(playerid, "FF4444", "Игрок уже в наручниках!");
	if(GetPlayerState(to_player) == PLAYER_STATE_DRIVER || GetPlayerState(to_player) == PLAYER_STATE_PASSENGER) return CEFChat_Send(playerid, "FF4444", "Игрок находится в транспорте!");

	TogglePlayerControllable(to_player, 0);

	new fmt_text[144];

	format(fmt_text, sizeof fmt_text, "Вы надели наручники на %s", GetName(to_player));
	CEFChat_Send(playerid, "FF69B4", fmt_text);

	if(PI[playerid][pSex] == 1)
	{
		format(fmt_text, sizeof fmt_text, "%s надел на Вас наручники!", GetName(playerid));
		CEFChat_Send(to_player, "FF4444", fmt_text);
	}
	else
	{
		format(fmt_text, sizeof fmt_text, "%s надела на Вас наручники!", GetName(playerid));
		CEFChat_Send(to_player, "FF4444", fmt_text);
	}

	new Float:pos[4];
	GetPlayerPos(to_player, pos[0], pos[1], pos[2]);
	GetPlayerFacingAngle(playerid, pos[3]);

	SetPlayerPos(to_player, pos[0], pos[1], pos[2]);
	SetPlayerFacingAngle(to_player, pos[3]);

	ApplyAnimation(to_player, "ped", "hcuff_criminal", 4.1, 1, 0, 0, 1, 0, 1);
	ApplyAnimation(playerid, "ped", "hcuff_cop", 4.1, 0, 0, 0, 1, 2000, 1);
	SetTimerEx("cuff_time", 2000, false, "d", to_player);
	SetTimerEx("cuff_player", 2000, false, "d", playerid);

	pCuff[playerid][pCuffee] = to_player;
	pCuff[to_player][pCuffer] = playerid;

	if(PI[playerid][pSex] == 1) format(fmt_text, sizeof(fmt_text), "надел наручники на %s", GetName(to_player));
	else format(fmt_text, sizeof(fmt_text), "надела наручники на %s", GetName(to_player));
	MeAction(playerid, fmt_text);
	return 1;
}

CMD:uncuff(playerid, params[])
{
	if(!IsACop(playerid)) return SendErr(playerid, messageUnknownCMD);
	extract params -> new to_player; else return CEFChat_Send(playerid, "FF4444", "Используйте{FFFFFF} /uncuff [id игрока]");

	else if(!IsPlayerConnected(to_player)) return CEFChat_Send(playerid, "FF4444", "Такого игрока нет");
	else if(!ProxDetectorS(3.0, playerid, to_player)) return CEFChat_Send(playerid, "FF4444", "Вы далеко друг от друга");
	else if(to_player == playerid) return CEFChat_Send(playerid, "FF4444", "Вы не можете снять наручники с себя!");
	else if(pCuff[to_player][pCuffer] == INVALID_PLAYER_ID) return CEFChat_Send(playerid, "FF4444", "Игрок не в наручниках!");

	new fmt_text[144];

	format(fmt_text, sizeof fmt_text, "Вы сняли наручники с %s", GetName(to_player));
	CEFChat_Send(playerid, "FF69B4", fmt_text);

	if(PI[playerid][pSex] == 1)
	{
		format(fmt_text, sizeof fmt_text, "%s снял с Вас наручники!", GetName(playerid));
		CEFChat_Send(to_player, "FF69B4", fmt_text);
	}
	else
	{
		format(fmt_text, sizeof fmt_text, "%s сняла с Вас наручники!", GetName(playerid));
		CEFChat_Send(to_player, "FF69B4", fmt_text);
	}

	if(FollowBy[to_player] != MAX_PLAYERS)
	{
		SetPVarInt(playerid, "TempFollowBy", -1);
		FollowBy[to_player] = MAX_PLAYERS;
		KillTimer(TimerForPlayer[to_player]);
		TimerForPlayer[to_player] = MAX_PLAYERS;
		ClearAnimations(to_player);
		TogglePlayerControllable(to_player, 1);
	}
	SetPlayerSpecialAction(to_player, 0);
	ApplyAnimation(to_player,"PED","IDLE_tired",4.1,0,1,1,0,1);
	ClearAnimations(to_player, true);
	RemovePlayerAttachedObject(to_player, 0);

	new cuffer = pCuff[to_player][pCuffer];
	pCuff[cuffer][pCuffee] = INVALID_PLAYER_ID;
	pCuff[to_player][pCuffer] = INVALID_PLAYER_ID;

	TogglePlayerControllable(to_player, 1);

	if(PI[playerid][pSex] == 1) format(fmt_text, sizeof(fmt_text), "снял наручники с %s", GetName(to_player));
	else format(fmt_text, sizeof(fmt_text), "сняла наручники с %s", GetName(to_player));
	MeAction(playerid, fmt_text);
	return 1;
}


CMD:leave(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;
    
    new fractionid = PI[playerid][pFraction];
    if(fractionid <= 0) return SendErr(playerid, "Вы не состоите в организации!");
    Otdel_RemovePlayerSilent(playerid);
    if(PI[playerid][pLeader] > 0) return SendErr(playerid, "Лидер не может покинуть организацию самостоятельно!");

    ShowPlayerDialog(playerid, dialog_LEAVE_CONFIRM, DIALOG_STYLE_INPUT, 
        "{FF3333}Подтверждение увольнения", 
        "{FFFFFF}Вы действительно хотите покинуть организацию по собственному желанию?\n\n\
        {FFFFFF}Для подтверждения введите слово {FF3333}Да {FFFFFF}в поле ниже:", 
        "Выйти", "Отмена");
    return 1;
}
stock SendWarehouseRadio(playerid, const weaponName[])
{
    new fractionid = PI[playerid][pFraction];
    new msg[256];
    format(msg, sizeof msg, "[R] %s взял(а) со склада: %s", GetName(playerid), weaponName);

    foreach(new i : Player)
    {
        if(PI[i][pFraction] != fractionid) continue;
        if(!PT[i][pDuty]) continue;
        SendClientMessage(i, COLOR_RADIO, msg);
    }
}
cmd:su(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;


    new frac = PI[playerid][pFraction];
    if(frac != 2 && frac != 3 && frac != 4)
        return SendErr(playerid, "{F8FAFA}Команда не обнаружена! {F8FAFA}Используйте {FF9900}/menu{F8FAFA} для просмотра команд.");
    if(!PT[playerid][pDuty])
        return SendErr(playerid, "Вы должны начать рабочий день!");

    new id_str[8];
    if(sscanf(params, "s[8]", id_str))
        return SendErr(playerid, "Использование: /su [ID]");

    new targetid = strval(id_str);
    if(!IsPlayerConnected(targetid))
        return SendErr(playerid, "Игрок не найден!");

    LoadSuChapters(playerid, targetid);
    return 1;
}
cmd:wanted(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;

    new frac = PI[playerid][pFraction];
    if(frac != 2 && frac != 3 && frac != 4 && frac != 6)
        return SendErr(playerid, "{F8FAFA}Команда не обнаружена! {F8FAFA}Используйте {FF9900}/menu{F8FAFA} для просмотра команд.");
    if(!PT[playerid][pDuty])
        return SendErr(playerid, "Вы должны начать рабочий день!");

    if(g_WantedCooldown[playerid] > gettime())
    {
        new msg[64];
        format(msg, sizeof(msg), "Повторный пробив доступен через %d сек.", g_WantedCooldown[playerid] - gettime());
        return SendErr(playerid, msg);
    }

    new list[2048], temp[128];
    new count = 0;

    foreach(new i : Player)
    {
        if(!PT[i][pLogged]) continue;
        if(PI[i][pWanted] <= 0) continue;
        format(temp, sizeof(temp), "%s [%d] — %d зв.\n", GetName(i), i, PI[i][pWanted]);
        strcat(list, temp);
        count++;
    }

    if(count == 0)
        return SendErr(playerid, "Розыскиваемых игроков нет.");

    ShowPlayerDialogEx(playerid, DIALOG_WANTED_LIST, DIALOG_STYLE_LIST,
        "Список розыскиваемых",
        list,
        "Пробить", "Закрыть");
    return 1;
}

cmd:chase(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;
    new frac = PI[playerid][pFraction];
    if(frac != 2 && frac != 3 && frac != 4 && frac != 6)
        return SendErr(playerid, "{F8FAFA}Команда не обнаружена! {F8FAFA}Используйте {FF9900}/menu{F8FAFA} для просмотра команд.");
    if(!PT[playerid][pDuty])
        return SendErr(playerid, "Вы должны начать рабочий день!");

    new activeTarget = g_ChaseTarget[playerid];
    new bool:hasActive = (IsPlayerConnected(activeTarget)
        && g_IsChased[activeTarget]
        && g_ChaseOfficer[activeTarget] == playerid);

    if(isnull(params))
    {
        if(hasActive)
        {
            new msg[128];
            format(msg, sizeof(msg), "Завершить преследование игрока %s [%d]?", GetName(activeTarget), activeTarget);
            ShowPlayerDialogEx(playerid, DIALOG_CHASE_STOP, DIALOG_STYLE_MSGBOX, "Преследование", msg, "Завершить", "Отмена");
            return 1;
        }


        new Float:px, Float:py, Float:pz;
        GetPlayerPos(playerid, px, py, pz);

        new list[1024], line[48];
        g_ChaseListCount[playerid] = 0;

        foreach(new i : Player)
        {
            if(i == playerid) continue;
            if(!PT[i][pLogged]) continue;
            if(g_IsChased[i]) continue;
            if(!IsPlayerInRangeOfPoint(i, CHASE_RADIUS, px, py, pz)) continue;
            if(g_ChaseListCount[playerid] >= CHASE_LIST_MAX) break;

            g_ChaseListTargets[playerid][g_ChaseListCount[playerid]] = i;
            format(line, sizeof(line), "%s [%d]\n", GetName(i), i);
            strcat(list, line);
            g_ChaseListCount[playerid]++;
        }

        if(g_ChaseListCount[playerid] == 0)
            return SendErr(playerid, "Рядом нет игроков для преследования (радиус 50м).");

        ShowPlayerDialogEx(playerid, DIALOG_CHASE_LIST, DIALOG_STYLE_LIST,
            "Преследование", list, "Выбрать", "Отмена");
        return 1;
    }

    if(hasActive)
        return SendErr(playerid, "У вас уже есть активное преследование. Введите /chase, чтобы завершить его.");

    new id_str[8];
    if(sscanf(params, "s[8]", id_str))
        return SendErr(playerid, "Использование: /chase [ID]");

    new targetid = strval(id_str);
    if(!IsPlayerConnected(targetid) || !PT[targetid][pLogged])
        return SendErr(playerid, "Игрок не найден!");
    if(targetid == playerid)
        return SendErr(playerid, "Нельзя начать преследование самого себя.");
    if(g_IsChased[targetid])
        return SendErr(playerid, "Этот игрок уже в преследовании!");

    new Float:px, Float:py, Float:pz, Float:tx, Float:ty, Float:tz;
    GetPlayerPos(playerid, px, py, pz);
    GetPlayerPos(targetid, tx, ty, tz);
    if(!IsPlayerInRangeOfPoint(playerid, CHASE_RADIUS, tx, ty, tz))
        return SendErr(playerid, "Игрок должен быть в радиусе 50 метров.");

    StartChase(playerid, targetid);
    return 1;
}
cmd:testchase(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;
    StartChase(playerid, playerid);
    return 1;
}
CMD:pogoni(playerid, params[])
{
    new modelid;
    if(sscanf(params, "d", modelid)) return SendClientMessage(playerid, -1, "Используйте: /pogoni [ID модели объекта]");

    if(modelid <= 0)
    {

        if(IsPlayerAttachedObjectSlotUsed(playerid, 1)) RemovePlayerAttachedObject(playerid, 1);
        if(IsPlayerAttachedObjectSlotUsed(playerid, 2)) RemovePlayerAttachedObject(playerid, 2);
        SendClientMessage(playerid, 0xFF0000FF, "Вы сняли погоны.");
        return 1;
    }

    SetPlayerAttachedObject(playerid, 1, modelid, 12, 
        pogonLeft_Pos[0], pogonLeft_Pos[1], pogonLeft_Pos[2], 
        pogonLeft_Pos[3], pogonLeft_Pos[4], pogonLeft_Pos[5], 
        1.0, 1.0, 1.0
    );

    SetPlayerAttachedObject(playerid, 2, modelid, 11, 
        pogonRight_Pos[0], pogonRight_Pos[1], pogonRight_Pos[2], 
        pogonRight_Pos[3], pogonRight_Pos[4], pogonRight_Pos[5], 
        1.0, 1.0, 1.0
    );

    SendClientMessage(playerid, 0x00FF00FF, "Погоны успешно надеты! Используйте /pedit для настройки положения.");
    return 1;
}

CMD:pedit(playerid, params[])
{
    new slot;
    if(sscanf(params, "d", slot)) return SendClientMessage(playerid, -1, "Используйте: /pedit [1 - Левое плечо | 2 - Правое плечо]");
    
    if(slot != 1 && slot != 2) return SendClientMessage(playerid, -1, "Неверный слот! Доступны только 1 и 2.");
    if(!IsPlayerAttachedObjectSlotUsed(playerid, slot)) return SendClientMessage(playerid, -1, "На вас нет объекта в этом слоте!");


    EditAttachedObject(playerid, slot);
    SendClientMessage(playerid, -1, "Вы вошли в режим редактирования. Нажмите ENTER для сохранения или ESC для отмены.");
    return 1;
}
CMD:deject(playerid, params[])
{
    if(!IsACop(playerid)) return SendErr(playerid, messageUnknownCMD);
    new targetid;
    if(sscanf(params, "u", targetid)) return CEFChat_Send(playerid, "FF4444", "Используйте /deject [id]");
    if(!IsPlayerConnected(targetid)) return CEFChat_Send(playerid, "FF4444", "Игрок не найден.");
    if(!IsPlayerInAnyVehicle(targetid)) return CEFChat_Send(playerid, "FF4444", "Игрок не в машине.");
    if(!ProxDetectorS(5.0, playerid, targetid)) return CEFChat_Send(playerid, "FF4444", "Вы далеко.");

    RemovePlayerFromVehicle(targetid);
    SetTimerEx("DejectAnim", 500, false, "d", targetid);

    new fmt[128];
    format(fmt, sizeof(fmt), "Вы вытащили %s из машины.", GetName(targetid));
    CEFChat_Send(playerid, "FF69B4", fmt);
    format(fmt, sizeof(fmt), "%s вытащил(а) вас из машины.", GetName(playerid));
    CEFChat_Send(targetid, "FF4444", fmt);

    if(PI[playerid][pSex] == 1) format(fmt, sizeof(fmt), "вытащил %s из машины", GetName(targetid));
    else format(fmt, sizeof(fmt), "вытащила %s из машины", GetName(targetid));
    MeAction(playerid, fmt);
    return 1;
}

forward DejectAnim(targetid);
public DejectAnim(targetid) {
    if(!IsPlayerConnected(targetid)) return 1;
    ApplyAnimation(targetid, "CRACK", "crckdeth2", 4.1, 0, 1, 1, 1, 0, 1);
    return 1;
}
stock ResetBagState(playerid)
{
    if(g_HasBag[playerid])
    {
        g_HasBag[playerid] = false;
        CEF_OpsBagShow(playerid, false);
    }
}
cmd:meshok(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;
    new frac = PI[playerid][pFraction];
    if(frac != 2 && frac != 3 && frac != 4 && frac != 6)
        return SendErr(playerid, "{F8FAFA}Команда не обнаружена! {F8FAFA}Используйте {FF9900}/menu{F8FAFA} для просмотра команд.");
    if(!PT[playerid][pDuty])
        return SendErr(playerid, "Вы должны начать рабочий день!");

    new id_str[8];
    if(sscanf(params, "s[8]", id_str))
        return SendErr(playerid, "Использование: /meshok [ID]");

    new targetid = strval(id_str);
    if(!IsPlayerConnected(targetid) || !PT[targetid][pLogged])
        return SendErr(playerid, "Игрок не найден!");
    if(targetid == playerid)
        return SendErr(playerid, "Нельзя надеть мешок на себя.");

    new Float:px, Float:py, Float:pz, Float:tx, Float:ty, Float:tz;
    GetPlayerPos(playerid, px, py, pz);
    GetPlayerPos(targetid, tx, ty, tz);
    if(!IsPlayerInRangeOfPoint(playerid, BAG_RANGE, tx, ty, tz))
        return SendErr(playerid, "Игрок должен быть рядом (3 метра).");

    if(!g_HasBag[targetid])
    {
        g_HasBag[targetid] = true;
        CEF_OpsBagShow(targetid, true);
        CEFChat_Send(playerid, "E69348", "Вы надели мешок на игрока.");
    }
    else
    {
        g_HasBag[targetid] = false;
        CEF_OpsBagShow(targetid, false);
        CEFChat_Send(playerid, "E69348", "Вы сняли мешок с игрока.");
    }
    return 1;
}

