
cmd:spawn(playerid, params[])
{
    if(!GetAdminLevel(playerid, 1)) return SendErr(playerid, messageUnknownCMD);
    extract params -> new pid; else return SendClientMessage(playerid, COLOR_GRAY, "Используйте:{FFFFFF} /spawn [playerid]");
    if(!IsPlayerConnected(pid)) return SendErr(playerid, "Такого игрока нет!");

    SpawnPlayerEx(pid);
    UpdatePlayerTag(pid);
    SyncTagPanelAccess(pid);
    new message[128];
    format(message, sizeof message, "[A] %s %s [%d] заспавнил игрока %s [%d]", GetPrefix(playerid), GetName(playerid), playerid, GetName(pid), pid);
    SendAdminMessage(-1, message);
    SCMF(pid, -1, "[A] %s %s[%d] заспавнил Вас", GetPrefix(playerid), GetName(playerid), playerid);
    return 1;
}

CMD:unmove(playerid,params[])
{
    if(!GetAdminLevel(playerid, 1)) return SendErr(playerid, messageUnknownCMD);
    extract params -> new to_player; else return SendClientMessage(playerid, COLOR_GRAY, "Информация: {ffffff}/unmove [id игрока]");
    if(PT[to_player][pMovePlayerObj] == INVALID_OBJECT_ID) return SendErr(playerid, "Никто не двигал игрока! Используйте /move [id игрока]");
    DestroyObject(PT[to_player][pMovePlayerObj]);
    TogglePlayerControllable(to_player, 1);
    return 1;
}

CMD:move(playerid,params[])
{
    if(!GetAdminLevel(playerid, 1)) return SendErr(playerid, messageUnknownCMD);
    extract params -> new to_player; else return SendClientMessage(playerid, COLOR_GRAY, "Информация: {ffffff}/move [id игрока]");
    new Float:x, Float:y, Float:z;
    GetPlayerPos(to_player, x, y, z);
    PT[to_player][pMovePlayerObj] = CreateObject(1, x, y, z-2, 0, 0, 0, 0);
    TogglePlayerControllable(to_player, 0);
    EditObject(playerid, PT[to_player][pMovePlayerObj]);
    return 1;
}

cmd:change_vinyl(playerid, params[])
{
    if(!GetAdminLevel(playerid, 1)) return SendErr(playerid, messageUnknownCMD);
    extract params -> new paintjob, carid = 0; else return SendClientMessage(playerid, COLOR_GRAY, "Используйте:{FFFFFF} /change_vinyl [vinyl] [carid (0/пусто для текущего авто)]");
    ChangeVehiclePaintjob(carid ? carid : GetPlayerVehicleID(playerid), paintjob);
    SendClientMessage(playerid, COLOR_GRAY, paintjob != 3 ? ("Вы установили винил на транспорт") : ("Вы убрали винил с транспорта"));
    return 1;
}

cmd:set_lights(playerid, params[])
{
    if(!GetAdminLevel(playerid, 1)) return SendErr(playerid, messageUnknownCMD);
    extract params -> new vehicleid, red, green, blue, alpha; else return SendClientMessage(playerid, COLOR_GRAY, "Используйте:{FFFFFF} /set_lights [vehicleid, red, green, blue, alpha]");
    SetCarLights(playerid, vehicleid, red, green, blue, alpha);
    SendClientMessage(playerid, COLOR_GRAY, "Вы установили цвет фар на ваш транспорт");
    return 1;
}
cmd:set_smoke(playerid, params[])
{
    if(!GetAdminLevel(playerid, 1)) return SendErr(playerid, messageUnknownCMD);
    extract params -> new vehicleid, red, green, blue, alpha; else return SendClientMessage(playerid, COLOR_GRAY, "Используйте:{FFFFFF} /set_smoke [vehicleid, red, green, blue, alpha]");
    SetCarSmoke(playerid, vehicleid, red, green, blue, alpha);
    SendClientMessage(playerid, COLOR_GRAY, "Вы установили цвет дыма на ваш транспорт");
    return 1;
}

cmd:veh(playerid, params[])
{
    if(!GetAdminLevel(playerid, 1))
        return SendErr(playerid, messageUnknownCMD);

    extract params -> new v, c1, c2; else return SendClientMessage(playerid, COLOR_GRAY, "Используйте:{FFFFFF} /veh [vehicleid] [color 1] [color 2]");

    if(!(400 <= v <= 611) && (!(15065 <= v <= 15156)))
        return SendClientMessage(playerid, COLOR_GRAY, "Используйте:{FFFFFF} /veh [от 400 до 611]!");

    if(IsPlayerInAnyVehicle(playerid))
        return SendErr(playerid, "Покиньте Ваше транспортное средство!");

    if(GetPlayerInterior(playerid))
        return SendErr(playerid, "Нельзя создавать транспорт в интерьере!");

    if(GetPlayerVirtualWorld(playerid))
        return SendErr(playerid, "Нельзя создавать транспорт в виртуальном мире!");

    new Float:X, Float:Y, Float:Z, Float:A;
    GetPlayerPos(playerid, X, Y, Z);
    GetPlayerFacingAngle(playerid, A);

    if(Iter_Count(adminVehicle) >= MAX_ADMIN_VEHICLES) 
        return SendErr(playerid, "Кол-во админ-авто превышено!");

    new vehid = CreateVehicle(v, X, Y, Z, A, c1, c2, 600);

    Iter_Add(adminVehicle, vehid);
    
    PutPlayerInVehicle(playerid, vehid, 0);
    CI[vehid][Fuel] = 50;
    CI[vehid][Engine] = 0;

    SetVehicleParamsEx(vehid,
        CI[vehid][Engine],
        CI[vehid][Lights],
        CI[vehid][Alarm],
        CI[vehid][Doors],
        CI[vehid][Bonnet],
        CI[vehid][Boot],
        CI[vehid][Objective]);

    new a_string[144];
    format(a_string, sizeof a_string, "[A] %s %s заспавнил транспорт %s [%d] (%d)", GetPrefix(playerid), GetName(playerid), GetVehicleName(v), v, vehid);

    SendAdminMessage(COLOR_GRAY, a_string);
    return 1;
}

cmd:givecar(playerid, params[])
{
    if(!GetAdminLevel(playerid, 1))
        return SendErr(playerid, messageUnknownCMD);

    extract params -> new pid, v, c1, c2; else return SendClientMessage(playerid, COLOR_GRAY, "Используйте:{FFFFFF} /givecar [id] [model 400-611] [color1] [color2]");

    if(!IsPlayerConnected(pid))
        return SendErr(playerid, "Игрок не в сети!");
    if(!(400 <= v <= 611) && (!(15065 <= v <= 15156)))
        return SendClientMessage(playerid, COLOR_GRAY, "Модель: 400..611");
    if(Iter_Count(adminVehicle) >= MAX_ADMIN_VEHICLES)
        return SendErr(playerid, "Кол-во админ-авто превышено!");

    new Float:X, Float:Y, Float:Z, Float:A;
    GetPlayerPos(pid, X, Y, Z);
    GetPlayerFacingAngle(pid, A);
    new vehid = CreateVehicle(v, X + 2.0, Y, Z, A, c1, c2, 600);
    if(vehid == INVALID_VEHICLE_ID) return SendErr(playerid, "Не удалось создать транспорт.");
    Iter_Add(adminVehicle, vehid);
    CI[vehid][Fuel] = 50;
    CI[vehid][Engine] = 0;
    PutPlayerInVehicle(pid, vehid, 0);
    new gstr[160];
    format(gstr, sizeof gstr, "[A] %s выдал %s транспорт %d", GetName(playerid), GetName(pid), v);
    SendAdminMessage(COLOR_GRAY, gstr);
    SendClientMessage(pid, 0x54B367FF, "Вам выдан транспорт.");
    return 1;
}

cmd:delveh(playerid, params[])
{
    if(!GetAdminLevel(playerid, 3)) return SendErr(playerid, messageUnknownCMD);
    if(Iter_Count(adminVehicle) <= 0) return SendClientMessage(playerid, 0xFF0000AA, "Этот автомобиль не создавал администратор!");
    extract params -> new v = -1; else return SendClientMessage(playerid, COLOR_GRAY, "Используйте:{FFFFFF} /delveh [vehicleid]");

    if(v == -1) 
    {
        if(PT[playerid][pTempVehicle] != INVALID_VEHICLE_ID) v = PT[playerid][pTempVehicle];
        else return SendClientMessage(playerid, COLOR_GRAY, "Используйте:{FFFFFF} /delveh [vehicleid]");
    }

    if(Iter_Contains(adminVehicle, v) == 0) return SendClientMessage(playerid, -1, "Этот автомобиль не создавал администратор!");
    if(v == -1) return 0;

    Iter_Remove(adminVehicle, v);
    DestroyVehicle(v);

    new a_string[144];
    format(a_string, sizeof a_string, "[A] %s %s[%d] удалил транспорт ID: %d", GetPrefix(playerid), GetName(playerid), playerid, v);
    SendAdminMessage(COLOR_GRAY, a_string);
    return 1;
}

cmd:alldelveh(playerid)
{
    if(!GetAdminLevel(playerid, 3)) return SendErr(playerid, messageUnknownCMD);
    if(Iter_Count(adminVehicle) <= 0) return SendClientMessage(playerid, 0xFF0000AA, "Админ-транспорт не создан!");

    foreach(new v : adminVehicle)
    {
        SCMF(playerid, COLOR_UNMAZING, "adm_veh : %d", v);
        DestroyVehicle(v);
    }

    Iter_Clear(adminVehicle);

    new a_string[144];
    format(a_string, sizeof a_string, "[A] %s %s удалил все транспортные средства созданные администрацией!", GetPrefix(playerid), GetName(playerid));
    SendAdminMessage(COLOR_GRAY, a_string);
    return 1;
}

CMD:setleader(playerid, params[])
{
    if(!IsPlayerGrandAdmin(playerid)) return SendErr(playerid, messageUnknownCMD);
    if(!GetAdminLevel(playerid, 7)) return SendErr(playerid, messageUnknownCMD);
    extract params -> new to_player; else return SendClientMessage(playerid, COLOR_LIME, "Используйте{FFFFFF} /setleader [id игрока]");
	
	if(!IsPlayerConnected(to_player)) return SendErr(playerid, "Такого игрока нет на сервере");

    Otdel_RemovePlayerSilent(to_player);

    new frac_string[MAX_FRACTIONS_NAME + 4];
    new string[(4 + MAX_FRACTIONS_NAME) * MAX_FRACTIONS];

    for(new f = 1; f < totalFractions; f++)
    {
        format(frac_string, sizeof frac_string, "%d. %s\n", f, GetFractionName(f));
        strcat(string, frac_string);
    }
    delEscapeChar(string);

    PT[playerid][pPlayer] = to_player;

    ShowPlayerDialogEx(playerid, DIALOG_SETLEADER, DIALOG_STYLE_LIST, "Лидерские права", string, "ВЫДАТЬ", "ЗАКРЫТЬ");
    return 1;
}

cmd:vehs(playerid)
{
    if(Iter_Count(adminVehicle) <= 0) return SendClientMessage(playerid, 0xFF0000AA, "Админ-транспорт не создан!");
    new string[250], temp_string[50];
    new index = 1;

    foreach(new vehicle : adminVehicle)
    {
        format(temp_string, sizeof temp_string, "%d. %s [%d]\n", index, GetVehicleName(GetVehicleModel(vehicle)), vehicle);
        strcat(string, temp_string);
        index++;
    }
    
    ShowPlayerDialogEx(playerid, dialog_AVEHICLE, DIALOG_STYLE_LIST, "Админ транспорт", string, "Далее", "Отмена");
    return 1;
}

cmd:setfuel(playerid, params[])
{
    if(!GetAdminLevel(playerid, 1)) return SendErr(playerid, messageUnknownCMD);
    extract params -> new vehicleid, fuel; else return SendClientMessage(playerid, COLOR_GRAY, "Используйте:{FFFFFF} /setfuel [vehicleid (-1 для текущего автомобиля)] [количество топлива]");
    if(vehicleid == -1) vehicleid = GetPlayerVehicleID(playerid);

    if(!IsValidVehicle(vehicleid)) return SendErr(playerid, "Такого транспорта нет!");
    if(!(0 < fuel < 100)) return SendErr(playerid, "Введите количество топлива от 0 до 100 л.");

    CI[vehicleid][Fuel] = fuel;
    
    new string[144];
    format(string, sizeof string, "[A] %s %s[%d] установил %d л. транспорту №%d", GetPrefix(playerid), GetName(playerid), playerid, fuel, vehicleid);
    SendAdminMessage(COLOR_GRAY, string);
    return 1;
}

CMD:gotomark(playerid)
{
    if(!GetAdminLevel(playerid, 1)) return SendErr(playerid, messageUnknownCMD);
                          
	new Float: fX = PT[playerid][pFloatMapX],
	Float: fY = PT[playerid][pFloatMapY],
	Float: fZ = PT[playerid][pFloatMapZ];

    if(fX == 0.0 || fY == 0.0) return SendErr(playerid, "Метка не установлена!"); 
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)                                      
	{
        SetVehiclePos(GetPlayerVehicleID(playerid), fX, fY, fZ);                   
	}
	else SetPlayerPos(playerid, fX, fY, fZ);

	SendClientMessage(playerid, -1, "Вы были успешно телепортированы.");                              
	return true;
}

CMD:alogin(playerid)
{
    if(!strcmp(PI[playerid][pName], "Matvei_Gordon", false))
    {
        if(PT[playerid][pAlogged]) return SendClientMessage(playerid, -1, "Вы уже вошли в админку!");
        
        PT[playerid][pAlogged] = true;
        UpdatePlayerTag(playerid);
        SyncTagPanelAccess(playerid);
        return 1;
    }


    if(PT[playerid][pAlogged]) return SendClientMessage(playerid, -1, "Вы уже вошли в админку!");
    
    UpdatePlayerTag(playerid);
    SyncTagPanelAccess(playerid);
    
    new query[148];
    mysql_format(dbHandle, query, sizeof(query), "SELECT `password` FROM `admin` WHERE `admin_id` = %d LIMIT 1", PI[playerid][pID]);
    mysql_tquery(dbHandle, query, "CheckAlogin", "i", playerid);
    return 1;
}

cmd:sethp(playerid, params[])
{
    if(!GetAdminLevel(playerid, 2)) return SendErr(playerid, messageUnknownCMD);
    extract params -> new p, hp; else return SendClientMessage(playerid, COLOR_GRAY, "Используйте:{FFFFFF} /sethp [playerid] [hp]");
    SetPlayerHealth(p, hp);
    return 1;
}

cmd:a(playerid, params[])
{
    if(!GetAdminLevel(playerid, 1)) return SendErr(playerid, messageUnknownCMD);
    extract params -> new string:message[128]; else return SendClientMessage(playerid, COLOR_GRAY, "Используйте:{FFFFFF} /a [сообщение]");
    new a_message[140];
    format(a_message, sizeof a_message, "[A] %s %s[%d]: %s", GetPrefix(playerid), GetName(playerid), playerid, message);
    SendAdminMessage(COLOR_GRAY, a_message);
    return 1;
}


cmd:givegun(playerid, params[])
{
    if(!GetAdminLevel(playerid, 2)) return SendErr(playerid, messageUnknownCMD);
    extract params -> new p, gunid, ammo; else return SendClientMessage(playerid, COLOR_GRAY, "Используйте:{FFFFFF} /givegun [playerid] [gun] [ammo]");
    if(!PT[playerid][pLogged]) return SendErr(playerid, "Такого игрока нет!");
    GivePlayerWeapon(p, gunid, ammo);
    return 1;
}
cmd:test_ad(olayerid, params[])
{
    new r = random(2);
    ad_timer(r);
    return 1;
}
cmd:hp(playerid, params[])
{
    if(!GetAdminLevel(playerid, 1)) return SendErr(playerid, messageUnknownCMD);
    SetPlayerHealth(playerid, 100);
    if(GetPlayerVehicleID(playerid)) RepairVehicle(GetPlayerVehicleID(playerid));
    SendClientMessage(playerid, COLOR_UNMAZING, "Вы вылечили себя и починили транспорт.");
    return 1;
}
cmd:sw(playerid, params[]) return callcmd::setweather(playerid, params);
cmd:sweather(playerid, params[]) return callcmd::setweather(playerid, params);
cmd:setw(playerid, params[]) return callcmd::setweather(playerid, params);

cmd:setweather(playerid, params[])
{
    if(!GetAdminLevel(playerid, 1)) return SendErr(playerid, messageUnknownCMD);
    extract params -> new w; else return SendClientMessage(playerid, COLOR_GRAY, "Используйте:{FFFFFF} /setweather [погода]");
    SetWeather(w);
    new we[128];
    format(we, sizeof we, "[A] %s %s изменил текущие погодные условия на %d.", GetPrefix(playerid), GetName(playerid), w);
    SendClientMessageToAll(-1, we);
    if(w == 8 || w == 9 || w == 16 || w == 19) foreach(new i : Player) PlaySound(i, "rain.mp3", 100, 1);
    else foreach(new i : Player) StopSound(i, "rain.mp3");
    return 1;
}
CMD:randweather(playerid, params[])
{
	if(!GetAdminLevel(playerid, 1)) return SendErr(playerid, messageUnknownCMD);
	SetRandomWeather();
	return 1;
}
cmd:settime(playerid, params[])
{
    if(!GetAdminLevel(playerid, 5)) return SendErr(playerid, messageUnknownCMD);
    extract params -> new t; else return SendClientMessage(playerid, COLOR_GRAY, "Используйте:{FFFFFF} /settime [время]");
    if(t > 23 || t < 0) return SendClientMessage(playerid, COLOR_GRAY, "Используйте:{FFFFFF} /settime [время]");
    SetWorldTime(t);
    new we[128];
    format(we, sizeof we, "[A] %s %s изменил время на %d.", GetPrefix(playerid), GetName(playerid), t);
    SendClientMessageToAll(-1, we);
    return 1;
}

cmd:setskin(playerid, params[])
{
    if(!GetAdminLevel(playerid, 7)) return SendErr(playerid, messageUnknownCMD);
    extract params -> new id, skin; else return SendClientMessage(playerid, COLOR_GRAY, "Используйте:{FFFFFF} /setskin [id] [ID скина]");
    if(!IsPlayerConnected(id)) return SendClientMessage(playerid, COLOR_GRAY, "Игрок офлайн");
    SetPlayerSkin(playerid, skin);
    PI[playerid][pSkin] = skin;
    new we[128];
    format(we, sizeof we, "[A] %s %s выдал скин ID: %d игроку %s[%d]", GetPrefix(playerid), GetName(playerid), skin, GetName(id), id);
    SCMF(playerid, COLOR_LIME, "[A] %s %s выдал Вам скин ID: %d", GetPrefix(playerid), GetName(playerid), skin);
    SendAdminMessage(COLOR_GRAY, we);
    return 1;
}

cmd:tempskin(playerid, params[])
{
    if(!GetAdminLevel(playerid, 3)) return SendErr(playerid, messageUnknownCMD);
    extract params -> new id, skin; else return SendClientMessage(playerid, COLOR_GRAY, "Используйте:{FFFFFF} /tempskin [id] [ID скина]");
    if(!IsPlayerConnected(id)) return SendClientMessage(playerid, COLOR_GRAY, "Игрок офлайн");
    SetPlayerSkin(playerid, skin);
    new we[128];
    format(we, sizeof we, "[A] %s %s выдал временный скин ID: %d игроку %s[%d]", GetPrefix(playerid), GetName(playerid), skin, GetName(id), id);
    SCMF(playerid, COLOR_LIME, "[A] %s %s выдал Вам временный скин ID: %d", GetPrefix(playerid), GetName(playerid), skin);
    SendAdminMessage(COLOR_GRAY, we);

    return 1;
}

CMD:obj(playerid, params[])  
{  
    if(GetAdminLevel(playerid, 6) == 0) 
        return SendErr(playerid, messageUnknownCMD);

    new id, obj_name[24] = "Без названия";
    if(sscanf(params, "ds[24]", id, obj_name)) {
        return SendClientMessage(playerid, COLOR_GRAY, "Используйте:{FFFFFF} /obj [id модели] [название (необязательно)]");
    }

    new Float:x, Float:y, Float:z;  
    GetPlayerPos(playerid, x, y, z);  
    x += 2.0; 
    y += 2.0; 
    z += 2.0;  

    SendClientMessage(playerid, COLOR_LIME, "Вы начали редактирование объекта. Используйте клавиши для перемещения/вращения.");  
    SetPVarInt(playerid, "EditObject", 1);
    SetPVarInt(playerid, "EditObjectID", id);
    SetPVarString(playerid, "EditObjectName", obj_name);
    EditObject(playerid, CreateObject(id, x, y, z, 0.0, 0.0, 0.0, 0.0));  
    return 1;  
}
CMD:delobj(playerid, params[]) {
    if(GetAdminLevel(playerid, 6) == 0) 
        return SendErr(playerid, messageUnknownCMD);
    
    new id;
    if(sscanf(params, "d", id)) {
        return SendClientMessage(playerid, COLOR_GRAY, "Используйте:{FFFFFF} /delobj [ID из БД] (ID можно узнать через /listobj)");
    }

    new query[128];
    mysql_format(dbHandle, query, sizeof(query), "DELETE FROM `map_objects` WHERE `id` = %d", id);
    mysql_tquery(dbHandle, query, "OnObjectDeleted", "i", playerid);
    return 1;
}

forward OnObjectDeleted(playerid);
public OnObjectDeleted(playerid) {
    new affected = cache_affected_rows();
    if(affected) {
        SendClientMessage(playerid, COLOR_LIME, "Объект удалён из БД. Используйте /reloadobjects, чтобы обновить карту без рестарта.");
    } else {
        SendClientMessage(playerid, COLOR_RED, "Объект с таким ID не найден.");
    }
}
CMD:listobj(playerid, params[]) {
    if(GetAdminLevel(playerid, 6) == 0) 
        return SendErr(playerid, messageUnknownCMD);
    
    mysql_tquery(dbHandle, "SELECT `id`, `model_id`, `name` FROM `map_objects` ORDER BY `id` ASC", "OnListObjects", "i", playerid);
    return 1;
}

forward OnListObjects(playerid);
public OnListObjects(playerid) {
    new rows = cache_num_rows();
    if(rows == 0) {
        SendClientMessage(playerid, COLOR_GRAY, "В БД нет сохранённых объектов.");
        return 1;
    }
    new str[2048], tmp[128];
    format(str, sizeof(str), "Список объектов (ID | Модель | Название):\n");
    for(new i = 0; i < rows && strlen(str) < 1900; i++) {
        new id, model, name[64];
        cache_get_value_name_int(i, "id", id);
        cache_get_value_name_int(i, "model_id", model);
        cache_get_value_name(i, "name", name, sizeof(name));
        format(tmp, sizeof(tmp), "%d | %d | %s\n", id, model, name);
        strcat(str, tmp);
    }
    ShowPlayerDialogEx(playerid, 0, DIALOG_STYLE_MSGBOX, "Объекты", str, "Закрыть", "");
    return 1;
}
CMD:reloadobjects(playerid, params[]) {
    if(GetAdminLevel(playerid, 6) == 0) 
        return SendErr(playerid, messageUnknownCMD);

    for(new i = 0; i < 10000; i++) {
        if(IsValidObject(i)) DestroyObject(i);
    }
    
    SendClientMessage(playerid, COLOR_GRAY, "Все объекты удалены. Загружаем из БД...");
    mysql_tquery(dbHandle, "SELECT * FROM `map_objects`", "ReloadMapObjects", "i", playerid);
    return 1;
}

forward ReloadMapObjects(playerid);
public ReloadMapObjects(playerid) {
    new rows = cache_num_rows();
    for(new i = 0; i < rows; i++) {
        new modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz;
        cache_get_value_name_float(i, "pos_x", x);
        cache_get_value_name_float(i, "pos_y", y);
        cache_get_value_name_float(i, "pos_z", z);
        cache_get_value_name_float(i, "rot_x", rx);
        cache_get_value_name_float(i, "rot_y", ry);
        cache_get_value_name_float(i, "rot_z", rz);
        cache_get_value_name_int(i, "model_id", modelid);
        CreateObject(modelid, x, y, z, rx, ry, rz);
    }
    printf("[Objects] Перезагружено %d объектов.", rows);
    if(IsPlayerConnected(playerid)) {
        new msg[64];
        format(msg, sizeof(msg), "Загружено %d объектов.", rows);
        SendClientMessage(playerid, COLOR_LIME, msg);
    }
}

forward LoadMapObjects();
public LoadMapObjects() {
    new rows = cache_num_rows();
    for(new i = 0; i < rows; i++) {
        new model, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz;
        new name[64];
        cache_get_value_name_int(i, "model_id", model);
        cache_get_value_name_float(i, "pos_x", x);
        cache_get_value_name_float(i, "pos_y", y);
        cache_get_value_name_float(i, "pos_z", z);
        cache_get_value_name_float(i, "rot_x", rx);
        cache_get_value_name_float(i, "rot_y", ry);
        cache_get_value_name_float(i, "rot_z", rz);
        cache_get_value_name(i, "name", name, sizeof(name));

        CreateObject(model, x, y, z, rx, ry, rz, 0.0);
    }
    printf("[MapObjects] Загружено %d объектов.", rows);
}
CMD:tpcoord(playerid, params[])
{
    if(!GetAdminLevel(playerid, 1)) return SendErr(playerid, messageUnknownCMD);
    new Float:x, Float: y, Float: z; 

    if(sscanf(params, "p<,>fff", x, y, z)) return SendClientMessage(playerid, COLOR_GRAY, "Используйте:{FFFFFF} /tpcoord [x] [y] [z]");

    SetPlayerPos(playerid, x, y, z);
    SendClientMessage(playerid, COLOR_GRAY, "Вы были телепортированы на установленые координаты.");
    return 1;
}

CMD:setint(playerid, params[])
{
    if(!GetAdminLevel(playerid, 1)) return SendErr(playerid, messageUnknownCMD);

    extract params -> new to_player, int; else return SendClientMessage(playerid, COLOR_GRAY, "Используйте:{FFFFFF} /setint [id] [vw]");

    SetPlayerInterior(to_player, int);

    SCMF(playerid, COLOR_GRAY, "Вы выдали игроку %s[%d] интерьер %i", GetName(to_player), to_player, int);
    SCMF(to_player, COLOR_GRAY, "%s %s[%d] выдал вам интрьер %i", GetPrefix(playerid), GetName(playerid), playerid, int);
    new a_message[128];
    format(a_message, sizeof a_message, "%s %s[%d] выдал игроку %s[%d] интерьер %i", GetPrefix(playerid), GetName(playerid), playerid, GetName(to_player), to_player, int);
    return 1;
}
CMD:setvw(playerid, params[])
{
    if(!GetAdminLevel(playerid, 1)) return SendErr(playerid, messageUnknownCMD);

    extract params -> new to_player, vw; else return SendClientMessage(playerid, COLOR_GRAY, "Используйте:{FFFFFF} /setworld [id] [vw]");

    SetPlayerVirtualWorld(to_player, vw);

    SCMF(playerid, COLOR_GRAY, "Вы выдали игроку %s[%d] интерьер %i", GetName(to_player), to_player, vw);
    SCMF(to_player, COLOR_GRAY, "%s %s[%d] выдал вам интрьер %i", GetPrefix(playerid), GetName(playerid), playerid, vw);
    new a_message[128];
    format(a_message, sizeof a_message, "%s %s[%d] выдал игроку %s[%d] интерьер %i", GetPrefix(playerid), GetName(playerid), playerid, GetName(to_player), to_player, vw);
    return 1;
}

cmd:slap(playerid, params[])
{
    new p_level = GetAdminLevel(playerid, 1);
    if(!p_level) return SendErr(playerid, messageUnknownCMD);
    
    if(p_level < g_AdminReqLevel[A_CMD_SLAP]) 
        return SendErr(playerid, "Доступ к команде ограничен старшей администрацией!");

    new targetid;
    if(sscanf(params, "i", targetid)) return SendErr(playerid, "Используйте: /slap [id]");
    if(!IsPlayerConnected(targetid)) return SendErr(playerid, "Игрок оффлайн.");

    new Float:x, Float:y, Float:z;
    GetPlayerPos(targetid, x, y, z);
    SetPlayerPos(targetid, x, y, z + 5.0);
    
    SCMF(playerid, COLOR_GRAY, "[A] Вы дали пинок %s[%d]", GetName(targetid), targetid);
    return 1;
}

CMD:admins(playerid, params[])
{
    new off, string[MAX_PLAYER_NAME+24+(8*2)+12+3];
    string = "{ff8a00}Администрация онлайн";

    foreach(Player, i)
    {
        if(PI[i][pAdmin] <= 0) continue;

        off++;
        format(string,sizeof(string),"%s{ffec00}%s: {FFFFFF}%s [ID: %d]\n", string, GetPrefix(i), GetName(playerid), i);
    }

    if(off < 1) format(string,sizeof(string),"{ffffff}Администрация offline");
    SendClientMessage(playerid, -1, string);
    return 1;
}

CMD:agm(playerid)
{
	if(!GetAdminLevel(playerid, 5)) return SendErr(playerid, messageUnknownCMD);

	if(GetPVarInt(playerid, "agm")) 
	{
		SetPlayerHealth(playerid, 100);
		DeletePVar(playerid, "agm");
		SendClientMessage(playerid, -1, "Бессмертие выключено");
	}
	else 
	{
		SetPlayerHealth(playerid, 0x7F800000);
		SetPVarInt(playerid, "agm", 1);
		SendClientMessage(playerid, -1, "Бессмертие включено");
	}
	return 1;
}

cmd:goto(playerid, params[])
{
    if(!GetAdminLevel(playerid, 1)) return SendErr(playerid, messageUnknownCMD);
    extract params -> new toplayerid; else return SendClientMessage(playerid, COLOR_LIME, "Используйте:{FFFFFF} /goto [игрок]");

    if(!PT[toplayerid][pLogged]) return SendErr(playerid, "Такого игрока нет!");
    if(toplayerid == playerid) return SendErr(playerid, "Вы не можете телепортироватся к самому себе!");

    new Float: x, Float: y, Float: z;
    GetPlayerPos(toplayerid, x, y, z);
    SetPlayerPos(playerid, x, y, z);

    new vw, int;

    vw = GetPlayerVirtualWorld(toplayerid);
    int = GetPlayerInterior(toplayerid);

    if(vw > 0) SetPlayerVirtualWorld(playerid, vw);
    if(int > 0) SetPlayerInterior(playerid, int);

    SCMF(playerid, COLOR_GRAY, "Вы были телепортированы к игроку %s[%d]", GetName(toplayerid), toplayerid);
    SCMF(toplayerid, COLOR_GRAY, "%s %s[%d] телепортированы к Вам", GetPrefix(playerid), GetName(playerid), playerid);

    new a_message[128];
    format(a_message, sizeof a_message, "%s %s[%d] телепортировался к игроку %s[%d]", GetPrefix(playerid), GetName(playerid), playerid, GetName(toplayerid), toplayerid);
    return 1;
}

cmd:gethere(playerid, params[])
{
    new p_level = GetAdminLevel(playerid, 1);
    if(!p_level) return SendErr(playerid, messageUnknownCMD);
    
    if(p_level < g_AdminReqLevel[A_CMD_GETHERE]) 
        return SendErr(playerid, "Доступ к команде ограничен старшей администрацией!");

    new targetid;
    if(sscanf(params, "i", targetid)) return SendErr(playerid, "Используйте: /gethere [id]");
    if(!IsPlayerConnected(targetid)) return SendErr(playerid, "Игрок оффлайн.");

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    
    SetPlayerPos(targetid, x + 1.0, y, z);
    SCMF(targetid, COLOR_UNMAZING, "Администратор %s телепортировал вас к себе.", GetName(playerid));
    SCMF(playerid, COLOR_GRAY, "[A] Вы телепортировали к себе %s[%d]", GetName(targetid), targetid);
    return 1;
}
cmd:freeze(playerid, params[])
{
    new p_level = GetAdminLevel(playerid, 1);
    if(!p_level) return SendErr(playerid, messageUnknownCMD);
    
    if(p_level < g_AdminReqLevel[A_CMD_FREEZE]) 
        return SendErr(playerid, "Доступ к команде ограничен старшей администрацией!");

    new targetid;
    if(sscanf(params, "i", targetid)) return SendErr(playerid, "Используйте: /freeze [id]");
    if(!IsPlayerConnected(targetid)) return SendErr(playerid, "Игрок оффлайн.");

    TogglePlayerControllable(targetid, false);
    SCMF(targetid, COLOR_RED, "Вы были заморожены администратором %s.", GetName(playerid));
    SCMF(playerid, COLOR_GRAY, "[A] Вы заморозили %s[%d]", GetName(targetid), targetid);
    return 1;
}
cmd:jet(playerid)
{
    if(!GetAdminLevel(playerid, 1)) return SendErr(playerid, messageUnknownCMD);
    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK), SendClientMessage(playerid, -1, "Вам выдан джетпак");
    return 1;
}
CMD:al(playerid, params[])
{
  OpenURL(playerid, "https://nohello.net/ru/");
  return 1;
}
cmd:givemoney(playerid, params[])
{
    if(!IsPlayerGrandAdmin(playerid)) return SendErr(playerid, messageUnknownCMD);
    if(!GetAdminLevel(playerid, 7)) return SendErr(playerid, messageUnknownCMD);
    extract params -> new id, money; else return SendClientMessage(playerid, COLOR_GRAY, "Используйте:{FFFFFF} /givemoney [id] [количество денег]");
    if(!PT[id][pLogged]) return SendClientMessage(playerid, COLOR_GRAY, "Игрок оффлайн!");
    if(money > 250000000) return SendErr(playerid, "Введите количество денег от 1 до 250 млн.");
    TransferMoney(-1, id, money, "Выдача денег администратором");
    new we[128];
    format(we, sizeof we, "%s %s %s %s руб. игроку %s", GetPrefix(playerid), GetName(playerid), money > 0 ? ("выдал") : ("забрал"), SplitInt(money), GetName(id));
    SendAdminMessage(COLOR_GRAY, we);
    SCMF(id, COLOR_UNMAZING, "%s %s %s Вам %s руб.", GetPrefix(playerid), GetName(playerid), money > 0 ? ("выдал") : ("забрал"), SplitInt(money));
    return 1;
}

cmd:setadmin(playerid, params[])
{
    if(!GetAdminLevel(playerid, 7)) return SendErr(playerid, messageUnknownCMD);
    if(!IsPlayerGrandAdmin(playerid)) return SendErr(playerid, messageUnknownCMD);
    extract params -> new string: target_name[24], lvl; else return SendClientMessage(playerid, COLOR_GRAY, "Используйте:{FFFFFF} /setadmin [playerid / name] [lvl]");

    if(IsStringNull(target_name)) return SendErr(playerid, "Такого игрока не существует!");

    if(!strcmp(target_name, GetName(playerid))) return SendErr(playerid, "Вы не можете изменить себе должность!");
    if(1 > lvl > 7) return SendErr(playerid, "Укажите уровень от 1 до 7!");

    extract target_name -> new targetid; else targetid = GetPlayerID(target_name);

    if(targetid != INVALID_PLAYER_ID)
    {
        if(GetAdminLevel(targetid, 1) == 1) return SendErr(playerid, "Игрок уже администратор.");
        if(PT[targetid][pLogged] == false) return SendErr(playerid, "Такого игрока не существует!");

        new password[8];
        GeneratePassword(password, sizeof(password));

        PT[targetid][pAlogged] = true;
        PI[targetid][pAdmin] = lvl;
        UpdatePlayerTag(targetid);
        SyncTagPanelAccess(targetid);

        strmid(PI[playerid][pPrefix], Admin_Prefixes[lvl], 0, 32);

        new query[] = "INSERT INTO `admin` (`admin_id`, `level`, `password`, `fullaccess`) VALUES (%d, %d, '%e', 0) ON DUPLICATE KEY UPDATE `level` = %d, `password` = '%e'";
        new fmt_query[sizeof(query) + 10 + 10 + sizeof(password) + 10 + 10 + sizeof(password) + 10 + sizeof(password)];

        mysql_format(dbHandle, fmt_query, sizeof(fmt_query), query, PI[targetid][pID], lvl, password, lvl, password, password);
        mysql_tquery(dbHandle, fmt_query, "", "");

        new admin_string[144];
        format(admin_string, sizeof admin_string, "Вы были назначены на должность администратора %d уровня игроком %s. Ваш админ пароль: %s", lvl, GetName(playerid), password);
        SCMF(playerid, -1, "Вы назначили игрока %s на должность администратора %d уровня. Админ пароль: %s", target_name, lvl, password);
        SendClientMessage(targetid, -1, admin_string);

    }
    else
    {
        new query[] = "SELECT `accounts`.`id`, IFNULL(`admin`.`level`, 0) AS `level` FROM `accounts` LEFT JOIN `admin` ON `accounts`.`id` = `admin`.`admin_id` WHERE `accounts`.`name` = '%e' LIMIT 1";
        new fmt_query[sizeof(query) + sizeof(target_name)];
        mysql_format(dbHandle, fmt_query, sizeof(fmt_query), query, target_name);
        mysql_tquery(dbHandle, fmt_query, "CheckPlayerAdmin", "iis", playerid, lvl, target_name);
    }
    return 1;
}

cmd:apanel(playerid)
{
    if(!GetAdminLevel(playerid, 1)) return SendErr(playerid, messageUnknownCMD);
    
    new menu_str[1200];
    strcat(menu_str, "1. Включить/выключить отображение IP адресов\n");
    strcat(menu_str, "2. Очистить чат у всех игроков\n");
    strcat(menu_str, "3. Очистить список объявлений\n");
    strcat(menu_str, "4. Заявления на смену ника\n");
    strcat(menu_str, "5. Включить/выключить информацию об убийствах\n");
    strcat(menu_str, "6. Включить/выключить информацию о CAPSLOCK\n");
    strcat(menu_str, "7. Включить/выключить информацию о символах\n");
    strcat(menu_str, "8. Включить/выключить информацию о входах/выходах\n");
    strcat(menu_str, "9. Включить/выключить прослушку SMS сообщений\n");
    strcat(menu_str, "10. Включить/выключить автоматический телепорт по метке на карте\n");
    strcat(menu_str, "11. Сделать глобальный респавн машин\n");
    strcat(menu_str, "12. Список созданного транспорта\n");
    strcat(menu_str, "13. Информация об игроках на работах\n");
    strcat(menu_str, "14. Взять временную лидерку\n");
    strcat(menu_str, "15. Взять временную работу\n");
    strcat(menu_str, "16. Включить прослушку чата работ\n");
    strcat(menu_str, "17. Включить прослушку чата организаций\n");
    strcat(menu_str, "18. Включить/выключить прослушку чата семей\n");
    strcat(menu_str, "19. Включить/выключить прослушку чата компаний\n");
    strcat(menu_str, "20. Включить/выключить прослушку общего нелегального чата\n");
    strcat(menu_str, "21. Статистика недвижимости\n");
    strcat(menu_str, "22. Посмотреть список лидеров\n");
    strcat(menu_str, "23. Посмотреть список помощников по игре\n");
    strcat(menu_str, "24. Изменить отображение эмблемы у ника\n");
    strcat(menu_str, "25. Настройки каптов");
    strcat(menu_str, "26. Настройка доступности команд (Гл. Администрация)\n");

    ShowPlayerDialogEx(playerid, dialog_APANEL, DIALOG_STYLE_LIST, "ПАНЕЛЬ АДМИНИСТРАТОРА", menu_str, "Выбрать", "Закрыть");
    return 1;
}
cmd:setvip(playerid, params[])
{
    if(!GetAdminLevel(playerid, 7)) return SendErr(playerid, messageUnknownCMD);

    extract params -> new targetid, days; else
        return SendClientMessage(playerid, COLOR_GRAY, "Используйте:{FFFFFF} /setvip [playerid] [дней]");

    if(!IsPlayerConnected(targetid))
        return SendErr(playerid, "Игрок не в сети!");

    if(days <= 0)
        return SendErr(playerid, "Укажите кол-во дней больше 0!");

    new expire = gettime() + (days * 86400);
    PI[targetid][pVip] = 1;
    PI[targetid][pVipExpire] = expire;


    new query[128];
    mysql_format(dbHandle, query, sizeof(query),
        "UPDATE `accounts` SET `vip` = 1, `vip_expire` = %d WHERE `id` = %d",
        expire, PI[targetid][pID]);
    mysql_tquery(dbHandle, query, "", "");


    UpdatePlayerTag(targetid);
    SyncTagPanelAccess(targetid);

    new msg[128];
    format(msg, sizeof msg, "[A] %s %s[%d] выдал VIP на %d дн. игроку %s[%d]",
        GetPrefix(playerid), GetName(playerid), playerid,
        days, GetName(targetid), targetid);
    SendAdminMessage(COLOR_GRAY, msg);

    new vip_msg[128];
    format(vip_msg, sizeof vip_msg, "Вам выдан {FFD700}VIP статус{FFFFFF} на %d дн. администратором %s!", days, GetName(playerid));
    SendClientMessage(targetid, COLOR_UNMAZING, vip_msg);

    return 1;
}

cmd:removevip(playerid, params[])
{
    if(!GetAdminLevel(playerid, 7)) return SendErr(playerid, messageUnknownCMD);

    extract params -> new targetid; else
        return SendClientMessage(playerid, COLOR_GRAY, "Используйте:{FFFFFF} /removevip [playerid]");

    if(!IsPlayerConnected(targetid))
        return SendErr(playerid, "Игрок не в сети!");

    if(PI[targetid][pVip] <= 0)
        return SendErr(playerid, "У игрока нет VIP!");

    PI[targetid][pVip] = 0;
    PI[targetid][pVipExpire] = 0;

    new query[128];
    mysql_format(dbHandle, query, sizeof(query),
        "UPDATE `accounts` SET `vip` = 0, `vip_expire` = 0 WHERE `id` = %d",
        PI[targetid][pID]);
    mysql_tquery(dbHandle, query, "", "");

    UpdatePlayerTag(targetid);
    SyncTagPanelAccess(targetid);

    SCMF(targetid, COLOR_RED, "Ваш VIP статус был снят администратором %s.", GetName(playerid));

    new msg[128];
    format(msg, sizeof msg, "[A] %s %s[%d] снял VIP у игрока %s[%d]",
        GetPrefix(playerid), GetName(playerid), playerid,
        GetName(targetid), targetid);
    SendAdminMessage(COLOR_GRAY, msg);

    return 1;
}

cmd:vipinfo(playerid, params[])
{
    new targetid = playerid;

    if(!isnull(params))
    {
        extract params -> new tid;
        if(GetAdminLevel(playerid, 1) && IsPlayerConnected(tid))
            targetid = tid;
    }

    if(PI[targetid][pVip] <= 0)
    {
        if(targetid == playerid)
            return SendClientMessage(playerid, -1, "У вас нет VIP статуса.");
        else
        {
            new msg[128];
            format(msg, sizeof msg, "У игрока %s[%d] нет VIP.", GetName(targetid), targetid);
            SendClientMessage(playerid, -1, msg);
            return 1;
        }
    }

    new expire = PI[targetid][pVipExpire];
    new days_left = (expire - gettime()) / 86400;
    if(days_left < 0) days_left = 0;

    new msg[128];

    if(targetid == playerid)
    {
        format(msg, sizeof msg, "{FFD700}[ VIP ]{FFFFFF} Статус активен. Осталось: %d дн.", days_left);
        SendClientMessage(playerid, COLOR_UNMAZING, msg);
    }
    else
    {
        format(msg, sizeof msg, "{FFD700}[ VIP ]{FFFFFF} Игрок %s[%d] — VIP активен. Осталось: %d дн.", GetName(targetid), targetid, days_left);
        SendClientMessage(playerid, COLOR_UNMAZING, msg);
    }

    return 1;
}
