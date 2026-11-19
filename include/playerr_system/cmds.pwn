cmd:setspawn(playerid)
{
    ShowPlayerDialogEx(playerid, dialog_SETSPAWN, DIALOG_STYLE_LIST, "Выбор спавна", "Автовокзал\nДома\nНа базе организации", "Выбрать", "Отмена");
}

CMD:piss(playerid)
{
	if(IsPlayerInAnyVehicle(playerid)) return 1;
    if(!PT[playerid][pAnimUsed] && GetPlayerSpecialAction(playerid) != SPECIAL_ACTION_PISSING)
	{
	    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_PISSING);
	    PT[playerid][pAnimUsed] = true;
	}
	else
	{
	    SetPlayerSpecialAction(playerid, 0);
	    PT[playerid][pAnimUsed] = false;
	}
	return 1;
}
cmd:mm(playerid) return callcmd::menu(playerid);
cmd:mn(playerid) return callcmd::menu(playerid);
cmd:menu(playerid) return ShowPlayerMenuDialog(playerid);

cmd:id(playerid, params[])
{
    extract params -> new string: name_part[24]; else return SendClientMessage(playerid, COLOR_LIME, "Используйте{FFFFFF} /id [Ник игрока или ID]");

    extract name_part -> new targetid = -1; else targetid = GetPlayerID(name_part);

	if(strlen(name_part) <= 2 && targetid == INVALID_PLAYER_ID) return SendClientMessage(playerid, COLOR_RED, "Длина ника должна быть не менее 2 символов");

	SendClientMessage(playerid, COLOR_BLUE, "Игроки онлайн:");

    if(targetid != INVALID_PLAYER_ID)
    {
		if(PT[targetid][pLogged] == false) return SendClientMessage(playerid, COLOR_RED, "Совпадений не найдено");

		return SCMF(playerid, -1, "%s {e69348}[%d] %s", GetName(targetid), targetid, PI[targetid][pAFK] >= 3 ? "— {ff6347}AFK" : "");
    }
    else
    {
		new pos, formated_string[64], result;
		foreach(new i : Player)
		{
			pos = strfind(GetName(i), name_part, true, 0);
			if(pos == -1) continue;

			formated_string[0] = EOS;

			format(formated_string, sizeof formated_string, "%s {e69348}[%d] %s", GetName(i), i, PI[i][pAFK] >= 3 ? "— {ff6347}AFK" : ""); 

			strins(formated_string, "{e69348}", pos);
			strins(formated_string, "{ffffff}", pos + strlen(name_part) + 8);

			SendClientMessage(playerid, -1, formated_string);
			result++;
		}
		if(result <= 0) return SendClientMessage(playerid, COLOR_RED, "Совпадений не найдено");
		return SCMF(playerid, COLOR_BLUE, "%s %d %s", result != 1 ? "Показано" : "Показан", result, result != 1 ? "найденных" : "найденный");
    }
}

cmd:s(playerid, params[])
{
	extract params -> new string: message[128]; else return SendClientMessage(playerid, COLOR_LIME, "Используйте{FFFFFF} /s [Сообщение]");

	foreach(new i : Player)
	{
		if(GetDistBetweenPlayers(playerid, i) > 30.0) continue;
		SCMF(i, -1, "%s крикнул: %s", GetName(playerid), message);
	}

	ApplyAnimation(playerid,"ON_LOOKERS","shout_01",4.1,0,0,0,0,0);
	SetPlayerChatBubble(playerid, message, 0xFFF6A0FF, 40.0, 10000);
	return 1;
}

cmd:w(playerid, params[])
{
	extract params -> new string: message[128]; else return SendClientMessage(playerid, COLOR_LIME, "Используйте{FFFFFF} /w [Сообщение]");

	foreach(new i : Player)
	{
		if(GetDistBetweenPlayers(playerid, i) > 5.0) continue;
		SCMF(i, 0xFFF6A0FF, "%s прошептал: %s", GetName(playerid), message);
	}

	SetPlayerChatBubble(playerid, message, 0xFFF6A0FF, 5.0, 5000);
	return 1;
}

CMD:create_pass(playerid)
{
    SendClientMessage(playerid, COLOR_GRAY, "Passport is created automatically. Use /pass.");
    return 1;
}

CMD:test_pass(playerid)
{
    if(!PI[playerid][pHasPassport]) 
        return SendErr(playerid, "У Вас нет паспорта! Получите его: /create_pass");

    new string[320];
    format(string, sizeof string, 
        "{FFFFFF}Фамилия:\t\t{e69348}%s\n\
        {FFFFFF}Имя:\t\t{e69348}%s\n\
        {FFFFFF}Пол:\t\t{e69348}%s\n\
        {FFFFFF}Дата рождения:\t{e69348}%s\n\
        {FFFFFF}Серия паспорта:\t{e69348}%06d", 
        PI[playerid][pRuLastName],
        PI[playerid][pRuFirstName],
        PI[playerid][pSex] ? "Мужской" : "Женский",
        PI[playerid][pBirthDate],
        PI[playerid][pID]
    );

    ShowPlayerDialogEx(playerid, dialog_PASS_TEST, DIALOG_STYLE_MSGBOX, 
        "{e69348}Паспорт гражданина", string, "Закрыть", "");
    return 1;
}
CMD:tpcoords(playerid, params[])
{
    new Float:x, Float:y, Float:z;


    if(sscanf(params, "fff", x, y, z)) 
    {
        return SendClientMessage(playerid, -1, "{FF0000}[Подсказка] {FFFFFF}Используйте: /tpcoords [X] [Y] [Z]");
    }


    if(x > 20000.0 || x < -20000.0 || y > 20000.0 || y < -20000.0 || z > 20000.0 || z < -20000.0)
    {
        return SendClientMessage(playerid, -1, "{FF0000}[Ошибка] {FFFFFF}Введены слишком большие или некорректные координаты!");
    }


    if(IsPlayerInAnyVehicle(playerid))
    {
        new vehicleid = GetPlayerVehicleID(playerid);
        SetVehiclePos(vehicleid, x, y, z);
        

        LinkVehicleToInterior(vehicleid, GetPlayerInterior(playerid)); 
    }
    else
    {
        SetPlayerPos(playerid, x, y, z);
    }


    SetCameraBehindPlayer(playerid);

    new msg_str[128];
    format(msg_str, sizeof(msg_str), "{00FF00}[Телепорт] {FFFFFF}Вы успешно телепортировались на координаты: X: %.2f, Y: %.2f, Z: %.2f", x, y, z);
    SendClientMessage(playerid, -1, msg_str);

    return 1;
}
CMD:spawnnpc(playerid, params[])
{
    if(TestFriskActorID != -1)
    {
        DestroyActor(TestFriskActorID);
        TestFriskActorID = -1;
    }

    new Float:pX, Float:pY, Float:pZ, Float:pA;
    GetPlayerPos(playerid, pX, pY, pZ);
    GetPlayerFacingAngle(playerid, pA);


    TestFriskActorID = CreateActor(211, pX + (1.5 * floatsin(-pA, degrees)), pY + (1.5 * floatcos(-pA, degrees)), pZ, pA);
    
    if(TestFriskActorID != -1)
    {
        SendClientMessage(playerid, 0x33AA33FF, "[Тест] NPC успешно создан! Теперь проверьте его: /frisk 999");
    }
    else
    {
        SendClientMessage(playerid, 0xFF3333FF, "[Ошибка] Не удалось создать актера.");
    }
    return 1;
}
cmd:save(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;
    new Float:x, Float:y, Float:z, Float:a;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);
    new interior = GetPlayerInterior(playerid);
    new vw = GetPlayerVirtualWorld(playerid);
    new File:f = fopen("saved_positions.txt", io_append);
    if(f) {
        new line[256];
        format(line, sizeof(line), "[%s] %.4f, %.4f, %.4f, %.4f | int:%d vw:%d\r\n",
            PI[playerid][pName], x, y, z, a, interior, vw);
        fwrite(f, line);
        fclose(f);
        new msg[128];
        format(msg, sizeof(msg), "Координаты сохранены: %.4f, %.4f, %.4f", x, y, z);
        CEFChat_Send(playerid, "54B367", msg);
    } else {
        CEFChat_Send(playerid, "FF4444", "Ошибка записи файла.");
    }
    return 1;
}
cmd:salto(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;
    ApplyAnimation(playerid, "ped", "dnce_salto", 4.1, 0, 0, 0, 0, 0, 1);
    return 1;
}
