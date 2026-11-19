#if defined _DS_SYSTEM_INCLUDED
    #endinput
#endif
#define _DS_SYSTEM_INCLUDED


enum E_DS_SESSION {
    dsStage, dsShop, dsItem, dsColor, dsPreview, dsTestVehicle,
    bool:dsBrowser, bool:dsReady, dsDeadline, dsOpenedAt,
    Float:dsBackX, Float:dsBackY, Float:dsBackZ, Float:dsBackA,
    dsBackWorld, dsBackInterior, dsCooldown, dsModal, dsBuyKind,
    dsLastAction, bool:dsBusy, bool:dsRestoreSpawn
};

new DS[MAX_PLAYERS][E_DS_SESSION];
new DS_Object[sizeof DS_Points], DS_Area[sizeof DS_Points];
new DS_MapIcon[sizeof DS_Points], Text3D:DS_Label[sizeof DS_Points];
new DS_FamilyVehicle[MAX_FAMILY], DS_FamilyDb[MAX_FAMILY];
new DS_Timer;

stock bool:DS_Exec(const query[])
{
    mysql_query(dbHandle, query, false);
    if(mysql_errno(dbHandle)) {
        new error[160]; mysql_error(error, sizeof error, dbHandle);
        printf("[DEALER] SQL failed: %s", error);
        return false;
    }
    return true;
}
stock DS_Msg(playerid, const message[])
{
    SendClientMessage(playerid, 0xE8C17AFF, message);
    if(DS[playerid][dsBrowser] && DS[playerid][dsReady])
        cef_emit_event(playerid, "ds:message", CEFSTR(message));
    return 1;
}
stock DS_CatalogTitle(model)
{
    new title[96];
    for(new i; i < sizeof DS_Catalog; i++) if(DS_Catalog[i][dsModel] == model) { format(title, sizeof title, "%s", DS_Catalog[i][dsTitle]); return title; }
    format(title, sizeof title, "%s", GetVehicleName(model)); return title;
}
stock DS_Init()
{
    DS_Exec("CREATE TABLE IF NOT EXISTS `ds_family_cars` (`id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,`family_id` INT NOT NULL,`buyer_id` INT NOT NULL,`model` INT NOT NULL,`color1` INT NOT NULL,`color2` INT NOT NULL,`fuel` INT NOT NULL DEFAULT 50,`mileage` INT NOT NULL DEFAULT 0,KEY (`family_id`)) ENGINE=InnoDB DEFAULT CHARSET=cp1251");
    for(new d; d < sizeof DS_Points; d++) {
        DS_Object[d] = CreateDynamicObject(11785, DS_Points[d][dsX], DS_Points[d][dsY], DS_Points[d][dsZ] - 0.9, 0.0, 0.0, 0.0, DS_Points[d][dsWorld], DS_Points[d][dsInterior]);
        SetDynamicObjectMaterial(DS_Object[d], 0, 299, "circleP_colours", "circleA_red", 2097220);
        DS_Area[d] = CreateDynamicSphere(DS_Points[d][dsX], DS_Points[d][dsY], DS_Points[d][dsZ], 1.6, DS_Points[d][dsWorld], DS_Points[d][dsInterior]);
        DS_MapIcon[d] = CreateDynamicMapIcon(DS_Points[d][dsX], DS_Points[d][dsY], DS_Points[d][dsZ], 55, 0, DS_Points[d][dsWorld], DS_Points[d][dsInterior]);
        DS_Label[d] = CreateDynamic3DTextLabel(DS_Points[d][dsName], 0xFFFFFFFF, DS_Points[d][dsX], DS_Points[d][dsY], DS_Points[d][dsZ]+0.7, 15.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, DS_Points[d][dsWorld], DS_Points[d][dsInterior]);
    }
    cef_subscribe("ds:ready", "DS_OnReady");
    cef_subscribe("ds:action", "DS_OnAction");
    new timerName[] = "DS_Tick";
    DS_Timer = SetTimer(timerName, 1000, true);
    print("[DEALER] Four dealerships initialized; edit car_dealship/config.pwn.");
    return 1;
}
stock DS_SaveReturn(playerid)
{
    GetPlayerPos(playerid, DS[playerid][dsBackX], DS[playerid][dsBackY], DS[playerid][dsBackZ]);
    GetPlayerFacingAngle(playerid, DS[playerid][dsBackA]);
    DS[playerid][dsBackWorld] = GetPlayerVirtualWorld(playerid);
    DS[playerid][dsBackInterior] = GetPlayerInterior(playerid);
}
stock DS_Return(playerid)
{
    SetPlayerVirtualWorld(playerid, DS[playerid][dsBackWorld]);
    SetPlayerInterior(playerid, DS[playerid][dsBackInterior]);
    SetPlayerPos(playerid, DS[playerid][dsBackX], DS[playerid][dsBackY], DS[playerid][dsBackZ]);
    SetPlayerFacingAngle(playerid, DS[playerid][dsBackA]);
    TogglePlayerControllable(playerid, true);
    SetCameraBehindPlayer(playerid);
    DS[playerid][dsRestoreSpawn] = false;
    return 1;
}
stock bool:DS_ItemValid(playerid)
{
    new i = DS[playerid][dsItem], d = DS[playerid][dsShop];
    return (d >= 0 && d < sizeof DS_Points && i >= 0 && i < sizeof DS_Catalog && DS_Catalog[i][dsDealer] == d);
}
stock bool:DS_AtSession(playerid)
{
    new stage = DS[playerid][dsStage];
    if(stage == 1) {
        new d = DS[playerid][dsShop];
        return GetPlayerVirtualWorld(playerid) == DS_Points[d][dsWorld] && GetPlayerInterior(playerid) == DS_Points[d][dsInterior] && IsPlayerInRangeOfPoint(playerid, 4.0, DS_Points[d][dsX], DS_Points[d][dsY], DS_Points[d][dsZ]);
    }
    if(stage == 2) return GetPlayerVirtualWorld(playerid) == DS_PREVIEW_WORLD+playerid && GetPlayerState(playerid) == PLAYER_STATE_ONFOOT;
    return false;
}
stock bool:DS_FamilyLeader(playerid)
{
    if(PI[playerid][pFamily] <= 0) return false;
    for(new f; f < totalFamily; f++) if(Family[f][famID] == PI[playerid][pFamily])
        return Family[f][famLeader] == PI[playerid][pID];
    return false;
}
stock DS_DialogClear(playerid)
{
    if(PT[playerid][pDialogID] >= DS_DIALOG_INVITE && PT[playerid][pDialogID] <= DS_DIALOG_BUY) {
        CEFC_DialogClose(playerid);
        new empty[1];
        ShowPlayerDialog(playerid, -1, DIALOG_STYLE_MSGBOX, empty, empty, empty, empty);
        PT[playerid][pDialogID] = -1;
    }
    return 1;
}
stock DS_ResumeSelector(playerid)
{
    DS[playerid][dsModal] = 0;
    if(DS[playerid][dsStage] == 2 && DS[playerid][dsBrowser]) {
        cef_hide_browser(playerid, DS_BROWSER, false);
        if(DS[playerid][dsReady]) {
            DS_Send(playerid);
            cef_focus_browser(playerid, DS_BROWSER, true);
        }
    }
    return 1;
}
stock DS_ShowDialog(playerid)
{
    if(!DS_ItemValid(playerid)) return DS_Close(playerid);
    if(DS[playerid][dsBrowser]) {
        cef_focus_browser(playerid, DS_BROWSER, false);
        cef_hide_browser(playerid, DS_BROWSER, true);
    }
    new i = DS[playerid][dsItem], info[850], header[40], yes[16], no[16];
    format(yes, sizeof yes, "Да"); format(no, sizeof no, "Нет");
    if(DS[playerid][dsStage] == 1) {
        format(header, sizeof header, "Автосалон");
        format(info, sizeof info, "Вы хотите взглянуть на имеющиеся модели транспорта?");
        return ShowPlayerDialogEx(playerid, DS_DIALOG_INVITE, DIALOG_STYLE_MSGBOX, header, info, yes, no);
    }
    switch(DS[playerid][dsModal]) {
        case 1: {
            format(info, sizeof info, "Марка и модель: {E8C17A}%s{FFFFFF}\nСтоимость: {E8C17A}%d рублей{FFFFFF}\n\nТест-драйв проходит в отдельном виртуальном мире.\nВремя: 5 минут. По окончании вы вернётесь в автосалон.\nВыход из транспорта, выезд из зоны или /endtest завершают поездку.\n\nНачать тест-драйв?", DS_Catalog[i][dsTitle], DS_Catalog[i][dsTestPrice]);
            format(header, sizeof header, "Тест-драйв");
            return ShowPlayerDialogEx(playerid, DS_DIALOG_TEST, DIALOG_STYLE_MSGBOX, header, info, yes, no);
        }
        case 2: {
            format(header, sizeof header, "Покупка транспорта");
            format(info, sizeof info, "Купить как личный транспорт\nКупить для семьи");
            format(yes, sizeof yes, "Выбрать"); format(no, sizeof no, "Назад");
            return ShowPlayerDialogEx(playerid, DS_DIALOG_OWNER, DIALOG_STYLE_LIST, header, info, yes, no);
        }
        case 3: {
            new owner[36];
            if(DS[playerid][dsBuyKind]) format(owner, sizeof owner, "для семьи");
            else format(owner, sizeof owner, "для личного пользования");
            format(info, sizeof info, "Вы действительно хотите приобрести {E8C17A}%s{FFFFFF} %s?\n\nСтоимость: {E8C17A}%d рублей{FFFFFF}\nОплата наличными покупателя. Выбранный цвет будет сохранён.", DS_Catalog[i][dsTitle], owner, DS_Catalog[i][dsPrice]);
            format(header, sizeof header, "Покупка транспорта"); format(no, sizeof no, "Назад");
            return ShowPlayerDialogEx(playerid, DS_DIALOG_BUY, DIALOG_STYLE_MSGBOX, header, info, yes, no);
        }
    }
    return DS_ResumeSelector(playerid);
}
stock DS_OnDialog(playerid, dialogid, response, listitem)
{
    if(dialogid < DS_DIALOG_INVITE || dialogid > DS_DIALOG_BUY) return 0;
    if(!PT[playerid][pLogged] || DS[playerid][dsBusy] || PT[playerid][pDialogID] != dialogid) return 1;
    if(DS[playerid][dsStage] == 2 && (DS[playerid][dsModal] < 1 || DS[playerid][dsModal] > 3)) return 1;
    new expected = DS[playerid][dsStage] == 1 ? DS_DIALOG_INVITE : DS_DIALOG_INVITE + DS[playerid][dsModal];
    if((DS[playerid][dsStage] != 1 && DS[playerid][dsStage] != 2) || expected != dialogid) return 1;
    if(!DS_ItemValid(playerid) || !DS_AtSession(playerid)) return DS_Close(playerid);
    CEFC_DialogClose(playerid);
    PT[playerid][pDialogID] = -1;
    if(dialogid == DS_DIALOG_INVITE) {
        if(!response) return DS_Close(playerid);
        DS[playerid][dsStage] = 2;
        DS_PreviewShow(playerid);
        if(DS[playerid][dsStage] != 2) return 1;
        DS[playerid][dsOpenedAt] = gettime();
        DS[playerid][dsBrowser] = true;
        cef_create_browser(playerid, DS_BROWSER, DS_URL, false, true);
        return 1;
    }
    if(dialogid == DS_DIALOG_TEST) {
        if(response) DS_StartTest(playerid);
        return DS_ResumeSelector(playerid);
    }
    if(dialogid == DS_DIALOG_OWNER) {
        if(!response) return DS_ResumeSelector(playerid);
        if(listitem < 0 || listitem > 1) return DS_ShowDialog(playerid);
        if(listitem == 1 && !DS_FamilyLeader(playerid)) {
            DS_Msg(playerid, "Покупка для семьи доступна только её лидеру.");
            return DS_ShowDialog(playerid);
        }
        DS[playerid][dsBuyKind] = listitem;
        DS[playerid][dsModal] = 3;
        return DS_ShowDialog(playerid);
    }
    if(dialogid == DS_DIALOG_BUY) {
        if(!response) { DS[playerid][dsModal] = 2; return DS_ShowDialog(playerid); }
        DS_Buy(playerid);
        return DS_ResumeSelector(playerid);
    }
    return 1;
}
stock DS_BrowserClose(playerid)
{
    if(DS[playerid][dsBrowser]) {
        cef_focus_browser(playerid, DS_BROWSER, false);
        cef_destroy_browser(playerid, DS_BROWSER);
    }
    DS[playerid][dsBrowser] = false;
    DS[playerid][dsReady] = false;
}
stock DS_VehiclesClear(playerid)
{
    if(IsValidVehicle(DS[playerid][dsPreview])) DestroyVehicle(DS[playerid][dsPreview]);
    if(IsValidVehicle(DS[playerid][dsTestVehicle])) DestroyVehicle(DS[playerid][dsTestVehicle]);
    DS[playerid][dsPreview] = DS[playerid][dsTestVehicle] = 0;
}
stock DS_Close(playerid, bool:restore = true)
{
    new stage = DS[playerid][dsStage];
    DS_DialogClear(playerid);
    DS[playerid][dsStage] = 0;
    DS_BrowserClose(playerid);
    DS_VehiclesClear(playerid);
    DS[playerid][dsModal] = 0;
    DS[playerid][dsCooldown] = gettime() + 4;
    if(restore && stage) DS_Return(playerid);
    return 1;
}
stock DS_Reset(playerid)
{
    for(new i; i < E_DS_SESSION; i++) DS[playerid][E_DS_SESSION:i] = 0;
    return 1;
}
stock DS_NextItem(dealer, current, step)
{
    new idx = current;
    for(new n; n < sizeof DS_Catalog; n++) {
        idx += step;
        if(idx < 0) idx = sizeof DS_Catalog - 1;
        if(idx >= sizeof DS_Catalog) idx = 0;
        if(DS_Catalog[idx][dsDealer] == dealer) return idx;
    }
    return -1;
}

stock DS_PreviewShow(playerid)
{
    if(!DS_ItemValid(playerid)) return DS_Close(playerid);
    if(IsValidVehicle(DS[playerid][dsPreview])) DestroyVehicle(DS[playerid][dsPreview]);
    new d = DS[playerid][dsShop], i = DS[playerid][dsItem], color = DS_Colors[DS[playerid][dsColor]];
    new Float:px = DS_Points[d][dsX]+5.0, Float:py = DS_Points[d][dsY], Float:pz = DS_Points[d][dsZ]+0.5;
    new Float:cx = DS_Points[d][dsX]+10.0, Float:cy = DS_Points[d][dsY]-7.0, Float:cz = DS_Points[d][dsZ]+3.0;
    new vid = CreateVehicle(DS_Catalog[i][dsModel], px, py, pz, DS_Points[d][dsA], color, color, -1);
    if(vid == INVALID_VEHICLE_ID || vid == 0) { DS_Msg(playerid, "Не удалось создать машину для просмотра."); return DS_Close(playerid); }
    DS[playerid][dsPreview] = vid;
    SetVehicleVirtualWorld(vid, DS_PREVIEW_WORLD + playerid);
    LinkVehicleToInterior(vid, DS_Points[d][dsInterior]);
    SetVehicleParamsEx(vid, 0, 0, 0, 1, 0, 0, 0);
    SetPlayerVirtualWorld(playerid, DS_PREVIEW_WORLD + playerid);
    SetPlayerInterior(playerid, DS_Points[d][dsInterior]);
    SetPlayerPos(playerid, DS_Points[d][dsX]-5.0, DS_Points[d][dsY]-8.0, DS_Points[d][dsZ]);
    TogglePlayerControllable(playerid, false);
    SetPlayerCameraPos(playerid, cx, cy, cz);
    SetPlayerCameraLookAt(playerid, px, py, pz+0.1);
    return 1;
}
stock DS_Send(playerid)
{
    if(!DS[playerid][dsBrowser] || !DS[playerid][dsReady] || DS[playerid][dsModal] || DS[playerid][dsStage] != 2) return 0;
    if(!DS_ItemValid(playerid)) return 0;
    new i = DS[playerid][dsItem], d = DS[playerid][dsShop], name[100], shop[80], json[700];
    CEF_JsonEscape(DS_Catalog[i][dsTitle], name, sizeof name);
    CEF_JsonEscape(DS_Points[d][dsName], shop, sizeof shop);
    format(json, sizeof json, "{\"stage\":%d,\"modal\":%d,\"name\":\"%s\",\"shop\":\"%s\",\"price\":%d,\"color\":%d,\"speed\":%d,\"tank\":%d,\"cargo\":%d,\"drive\":%d,\"clearance\":%d,\"trackReady\":%d,\"testPrice\":%d,\"testSeconds\":%d,\"family\":%d,\"buyKind\":%d}", DS[playerid][dsStage], DS[playerid][dsModal], name, shop, DS_Catalog[i][dsPrice], DS[playerid][dsColor], DS_Catalog[i][dsSpeed], DS_Catalog[i][dsTank], DS_Catalog[i][dsCargo], DS_Catalog[i][dsDrive], DS_Catalog[i][dsClearance], DS_TRACK_READY, DS_Catalog[i][dsTestPrice], DS_TEST_SECONDS, PI[playerid][pFamily], DS[playerid][dsBuyKind]);
    cef_emit_event(playerid, "ds:state", CEFSTR(json));
    return 1;
}
stock DS_Open(playerid, d)
{
    if(!PT[playerid][pLogged] || DS[playerid][dsStage] || DS[playerid][dsRestoreSpawn]) return 0;
    if(d < 0 || d >= sizeof DS_Points || gettime() < DS[playerid][dsCooldown]) return 0;
    if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return 0;
    if(gCef[playerid][cef_visible]) return DS_Msg(playerid, "Сначала закройте другое меню.");
    if(!cef_player_has_plugin(playerid)) return DS_Msg(playerid, "Для автосалона необходим CEF-плагин клиента.");
    DS_SaveReturn(playerid);
    DS[playerid][dsShop] = d;
    DS[playerid][dsItem] = DS_NextItem(d, -1, 1);
    DS[playerid][dsColor] = 0;
    DS[playerid][dsStage] = 1;
    DS[playerid][dsModal] = 0;
    DS[playerid][dsOpenedAt] = gettime();
    TogglePlayerControllable(playerid, false);
    return DS_ShowDialog(playerid);
}
stock DS_OnArea(playerid, areaid)
{
    for(new d; d < sizeof DS_Points; d++) if(DS_Area[d] == areaid) {
        if(GetPlayerVirtualWorld(playerid) != DS_Points[d][dsWorld] || GetPlayerInterior(playerid) != DS_Points[d][dsInterior]) return 0;
        DS_Open(playerid, d); return 1;
    }
    return 0;
}
forward DS_OnReady(playerid, const arguments[]);
public DS_OnReady(playerid, const arguments[])
{
    #pragma unused arguments
    if(!DS[playerid][dsBrowser] || !DS[playerid][dsStage]) return 1;
    DS[playerid][dsReady] = true;
    if(DS[playerid][dsModal]) return DS_ShowDialog(playerid);
    cef_focus_browser(playerid, DS_BROWSER, true);
    DS_Send(playerid);
    return 1;
}



stock DS_Buy(playerid)
{
    if(DS[playerid][dsBusy] || !DS_ItemValid(playerid) || !DS_AtSession(playerid)) return 0;
    if(!CEF_FinesCanRegisterVehicle(playerid)) return 0;
    new i = DS[playerid][dsItem], price = DS_Catalog[i][dsPrice], kind = DS[playerid][dsBuyKind];
    if(price <= 0) return DS_Msg(playerid, "Покупка недоступна: администратор ещё не настроил цену.");
    if(PI[playerid][pCash] < price) return DS_Msg(playerid, "Недостаточно наличных для покупки.");
    if(kind && !DS_FamilyLeader(playerid)) return DS_Msg(playerid, "Покупка для семьи доступна только её лидеру.");
    DS[playerid][dsBusy] = true;
    if(!DS_Exec("START TRANSACTION")) { DS[playerid][dsBusy] = false; return 0; }
    new q[700], bool:ok = true, owned, color = DS_Colors[DS[playerid][dsColor]];
    mysql_format(dbHandle, q, sizeof q, "SELECT `cash` FROM `accounts` WHERE `id`=%d FOR UPDATE", PI[playerid][pID]);
    new Cache:c = mysql_query(dbHandle, q), dbcash = -1;
    if(mysql_errno(dbHandle) || cache_num_rows() != 1) ok = false;
    else cache_get_value_name_int(0, "cash", dbcash);
    cache_delete(c);
    if(dbcash != PI[playerid][pCash] || dbcash < price) ok = false;
    if(kind) mysql_format(dbHandle, q, sizeof q, "SELECT COUNT(*) AS n FROM `ds_family_cars` WHERE `family_id`=%d", PI[playerid][pFamily]);
    else mysql_format(dbHandle, q, sizeof q, "SELECT COUNT(*) AS n FROM `cars` WHERE `owner_id`=%d", PI[playerid][pID]);
    c = mysql_query(dbHandle, q);
    if(mysql_errno(dbHandle) || cache_num_rows() != 1) ok = false;
    else cache_get_value_name_int(0, "n", owned);
    cache_delete(c);
    if(owned >= (kind ? DS_FAMILY_LIMIT : DS_MAX_OWNED)) ok = false;
    if(ok) {
        mysql_format(dbHandle, q, sizeof q, "UPDATE `accounts` SET `cash`=`cash`-%d WHERE `id`=%d AND `cash`=%d", price, PI[playerid][pID], dbcash);
        ok = DS_Exec(q);
    }
    if(ok) {
        if(kind) mysql_format(dbHandle, q, sizeof q, "INSERT INTO `ds_family_cars` (`family_id`,`buyer_id`,`model`,`color1`,`color2`,`fuel`) VALUES (%d,%d,%d,%d,%d,50)", PI[playerid][pFamily], PI[playerid][pID], DS_Catalog[i][dsModel], color, color);
        else mysql_format(dbHandle, q, sizeof q, "INSERT INTO `cars` (`owner_id`,`model`,`color1`,`color2`,`fuel`,`strobs`,`number`,`region`,`number_type`,`neon`,`neon_color1`,`neon_color2`,`neon_color3`,`neon_alpha`,`mileage`,`audio_system`) VALUES (%d,%d,%d,%d,50,0,'Tranzit','52',0,0,0,0,0,0,0,0)", PI[playerid][pID], DS_Catalog[i][dsModel], color, color);
        ok = DS_Exec(q);
    }
    if(ok) ok = DS_Exec("COMMIT");
    if(!ok) {
        DS_Exec("ROLLBACK");
        DS[playerid][dsBusy] = false;
        DS[playerid][dsModal] = 0; DS_Send(playerid);
        return DS_Msg(playerid, "Покупка не выполнена: проверьте лимит транспорта, синхронизацию баланса и SQL-лог. Деньги не списаны.");
    }
    PI[playerid][pCash] -= price;
    UpdatePlayerHUD(playerid);
    DS[playerid][dsBusy] = false;
    DS_Close(playerid);
    if(kind) DS_Msg(playerid, "Транспорт куплен для семьи. Получение и парковка: /familycars.");
    else DS_Msg(playerid, "Транспорт куплен и сохранён в гараже (TAB). Текущая машина не удалена.");
    return 1;
}
stock DS_StartTest(playerid)
{
    new bool:trackReady = DS_TRACK_READY;
    if(!trackReady) return DS_Msg(playerid, "Администратор ещё не настроил трассу тест-драйва.");
    if(!DS_ItemValid(playerid) || DS[playerid][dsStage] != 2) return 0;
    new i = DS[playerid][dsItem], color = DS_Colors[DS[playerid][dsColor]], testPrice = DS_Catalog[i][dsTestPrice];
    if(testPrice <= 0 || PI[playerid][pCash] < testPrice) return DS_Msg(playerid, "Недостаточно наличных для тест-драйва.");
    new v = CreateVehicle(DS_Catalog[i][dsModel], DS_TRACK_X, DS_TRACK_Y, DS_TRACK_Z, DS_TRACK_A, color, color, -1);
    if(v == INVALID_VEHICLE_ID || !v) return DS_Msg(playerid, "Не удалось создать тестовый транспорт. Деньги не списаны.");
    new q[220]; mysql_format(dbHandle, q, sizeof q, "UPDATE `accounts` SET `cash`=`cash`-%d WHERE `id`=%d AND `cash`=%d AND `cash`>=%d", testPrice, PI[playerid][pID], PI[playerid][pCash], testPrice);
    new Cache:c = mysql_query(dbHandle, q);
    new bool:paid = (!mysql_errno(dbHandle) && cache_affected_rows() == 1); cache_delete(c);
    if(!paid) { DestroyVehicle(v); return DS_Msg(playerid, "Баланс ещё синхронизируется. Попробуйте позже."); }
    PI[playerid][pCash] -= testPrice; UpdatePlayerHUD(playerid);
    DS[playerid][dsStage] = 3;
    DS[playerid][dsModal] = 0;
    DS_BrowserClose(playerid);
    if(IsValidVehicle(DS[playerid][dsPreview])) DestroyVehicle(DS[playerid][dsPreview]);
    DS[playerid][dsPreview] = 0;
    DS[playerid][dsTestVehicle] = v;
    DS[playerid][dsDeadline] = gettime()+DS_TEST_SECONDS;
    SetVehicleVirtualWorld(v, DS_TEST_WORLD+playerid); LinkVehicleToInterior(v, DS_TRACK_INTERIOR);
    CI[v][Fuel] = 100; CI[v][Engine] = 1;
    SetVehicleParamsEx(v, 1, 0, 0, 0, 0, 0, 0);
    SetPlayerVirtualWorld(playerid, DS_TEST_WORLD+playerid); SetPlayerInterior(playerid, DS_TRACK_INTERIOR);
    SetPlayerPos(playerid, DS_TRACK_X, DS_TRACK_Y, DS_TRACK_Z+1.0);
    TogglePlayerControllable(playerid, true); SetCameraBehindPlayer(playerid);
    PutPlayerInVehicle(playerid, v, 0);
    DS_Msg(playerid, "Тест-драйв начался. Время: 5 минут. /endtest — завершить.");
    return 1;
}
forward DS_OnAction(playerid, const arguments[]);
public DS_OnAction(playerid, const arguments[])
{
    if(!PT[playerid][pLogged] || !DS[playerid][dsBrowser] || !DS[playerid][dsReady] || DS[playerid][dsBusy]) return 1;
    if(!DS_ItemValid(playerid) || !DS_AtSession(playerid)) return DS_Close(playerid);
    new op; if(sscanf(arguments, "i", op)) return 1;
    if(op != 0 && GetTickCount()-DS[playerid][dsLastAction] < 150) return 1;
    DS[playerid][dsLastAction] = GetTickCount();
    if(DS[playerid][dsModal] || DS[playerid][dsStage] != 2) return 1;
    if(op == 0) return DS_Close(playerid);
    if(op == 2 || op == 3) {
        DS[playerid][dsItem] = DS_NextItem(DS[playerid][dsShop], DS[playerid][dsItem], op == 2 ? -1 : 1);
        DS_PreviewShow(playerid);
    }
    else if(op >= 20 && op < 20+sizeof DS_Colors) {
        DS[playerid][dsColor] = op-20;
        if(IsValidVehicle(DS[playerid][dsPreview])) ChangeVehicleColor(DS[playerid][dsPreview], DS_Colors[op-20], DS_Colors[op-20]);
    }
    else if(op == 4) { DS[playerid][dsModal] = 1; return DS_ShowDialog(playerid); }
    else if(op == 5) { DS[playerid][dsModal] = 2; return DS_ShowDialog(playerid); }
    DS_Send(playerid);
    return 1;
}
forward DS_Tick();
public DS_Tick()
{
    foreach(new p: Player) {
        if(DS[p][dsStage] && DS[p][dsBrowser] && !DS[p][dsReady] && gettime()-DS[p][dsOpenedAt] > 15) {
            DS_Close(p); DS_Msg(p, "Меню CEF не загрузилось. Проверьте клиентские файлы автосалона."); continue;
        }
        if((DS[p][dsStage] == 1 || DS[p][dsStage] == 2) && gettime()-DS[p][dsOpenedAt] > 900) {
            DS_Close(p); DS_Msg(p, "Просмотр автосалона завершён по тайм-ауту."); continue;
        }
        if(DS[p][dsStage] != 3) continue;
        new v = DS[p][dsTestVehicle], Float:hp;
        if(IsValidVehicle(v)) GetVehicleHealth(v, hp);
        if(!IsValidVehicle(v) || hp < 250.0 || gettime() >= DS[p][dsDeadline] || GetPlayerVirtualWorld(p) != DS_TEST_WORLD+p || GetPlayerInterior(p) != DS_TRACK_INTERIOR || !IsPlayerInRangeOfPoint(p, DS_TRACK_RADIUS, DS_TRACK_X, DS_TRACK_Y, DS_TRACK_Z) || GetPlayerVehicleID(p) != v) {
            DS_Close(p); DS_Msg(p, "Тест-драйв завершён. Вы возвращены в автосалон.");
        }
    }
    return 1;
}
stock DS_OnDeath(playerid)
{
    if(!DS[playerid][dsStage]) return 0;
    DS_Close(playerid, false);
    DS[playerid][dsRestoreSpawn] = true;
    return 1;
}
stock DS_OnSpawn(playerid)
{
    if(DS[playerid][dsRestoreSpawn]) DS_Return(playerid);
    return 1;
}
stock DS_OnDisconnect(playerid)
{
    if(DS[playerid][dsStage] || DS[playerid][dsRestoreSpawn]) {
        DS_Return(playerid); DS_Close(playerid, false);
    }
    DS_Reset(playerid);
    return 1;
}
CMD:exitdealer(playerid, params[])
{
    #pragma unused params
    if(DS[playerid][dsStage]) return DS_Close(playerid);
    return 1;
}
CMD:endtest(playerid, params[])
{
    #pragma unused params
    if(DS[playerid][dsStage] == 3) return DS_Close(playerid);
    return DS_Msg(playerid, "Вы не на тест-драйве.");
}
CMD:autodealer(playerid, params[])
{
    #pragma unused params
    for(new d; d < sizeof DS_Points; d++) if(GetPlayerVirtualWorld(playerid) == DS_Points[d][dsWorld] && GetPlayerInterior(playerid) == DS_Points[d][dsInterior] && IsPlayerInRangeOfPoint(playerid, 3.0, DS_Points[d][dsX], DS_Points[d][dsY], DS_Points[d][dsZ])) return DS_Open(playerid, d);
    return DS_Msg(playerid, "Подойдите к красному маркеру автосалона.");
}
stock DS_FamilyStore(f)
{
    new v = DS_FamilyVehicle[f];
    if(IsValidVehicle(v) && (CI[v][vOwnerType] != DS_OWNER_FAMILY || CI[v][vOwnerID] != f)) { DS_FamilyVehicle[f] = 0; DS_FamilyDb[f] = 0; return 1; }
    if(!IsValidVehicle(v)) { DS_FamilyVehicle[f] = 0; return 1; }
    new q[220]; mysql_format(dbHandle, q, sizeof q, "UPDATE `ds_family_cars` SET `fuel`=%d,`mileage`=%d WHERE `id`=%d", CI[v][Fuel], CI[v][vMileage], DS_FamilyDb[f]);
    if(!DS_Exec(q)) return 0;
    DS_FamilyVehicle[f] = 0; DS_FamilyDb[f] = 0; DestroyVehicle(v);
    return 1;
}
CMD:familycars(playerid, params[])
{
    if(!PT[playerid][pLogged] || DS[playerid][dsStage] || DS[playerid][dsRestoreSpawn]) return 0;
    new fam = PI[playerid][pFamily];
    if(fam <= 0 || fam >= MAX_FAMILY) return DS_Msg(playerid, "Вы не состоите в семье.");
    if(!strlen(params)) {
        new q[180]; mysql_format(dbHandle, q, sizeof q, "SELECT `id`,`model` FROM `ds_family_cars` WHERE `family_id`=%d ORDER BY `id`", fam);
        new Cache:c = mysql_query(dbHandle, q);
        new rows = cache_num_rows(), id, model, text[144];
        for(new r; r < rows; r++) { cache_get_value_name_int(r, "id", id); cache_get_value_name_int(r, "model", model); format(text, sizeof text, "[Семья] ID %d — %s. /familycars ID; /familycars 0 — парковка.", id, DS_CatalogTitle(model)); SendClientMessage(playerid, -1, text); }
        cache_delete(c);
        if(!rows) DS_Msg(playerid, "У семьи ещё нет купленного транспорта.");
        return 1;
    }
    if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT || GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0) return DS_Msg(playerid, "Для получения/парковки выйдите из транспорта и интерьера в основной мир.");
    new id; if(sscanf(params, "i", id) || id < 0) return DS_Msg(playerid, "/familycars [ID], 0 — убрать машину на парковку.");
    if(IsValidVehicle(DS_FamilyVehicle[fam])) {
        new v = DS_FamilyVehicle[fam], Float:x, Float:y, Float:z;
        GetVehiclePos(v, x, y, z);
        if(!IsPlayerInRangeOfPoint(playerid, 10.0, x, y, z)) return DS_Msg(playerid, "Подойдите к активной семейной машине для её парковки.");
        foreach(new p: Player) if(GetPlayerVehicleID(p) == v) return DS_Msg(playerid, "Сначала все должны выйти из семейной машины.");
        if(!DS_FamilyStore(fam)) return DS_Msg(playerid, "Ошибка сохранения семейной машины.");
    }
    if(!id) return DS_Msg(playerid, "Семейная машина убрана на парковку.");
    new q[200]; mysql_format(dbHandle, q, sizeof q, "SELECT * FROM `ds_family_cars` WHERE `id`=%d AND `family_id`=%d LIMIT 1", id, fam);
    new Cache:c = mysql_query(dbHandle, q);
    if(mysql_errno(dbHandle) || !cache_num_rows()) { cache_delete(c); return DS_Msg(playerid, "Такой машины у вашей семьи нет."); }
    new model, color1, color2, fuel, mileage;
    cache_get_value_name_int(0, "model", model); cache_get_value_name_int(0, "color1", color1); cache_get_value_name_int(0, "color2", color2); cache_get_value_name_int(0, "fuel", fuel); cache_get_value_name_int(0, "mileage", mileage); cache_delete(c);
    new Float:x, Float:y, Float:z, Float:a; GetPlayerPos(playerid, x, y, z); GetPlayerFacingAngle(playerid, a);
    new v = CreateVehicle(model, x+3.0, y, z+0.3, a, color1, color2, -1);
    if(v == INVALID_VEHICLE_ID || !v) return DS_Msg(playerid, "Нет свободных слотов транспорта.");
    DS_FamilyVehicle[fam] = v; DS_FamilyDb[fam] = id;
    CI[v][Fuel] = fuel; CI[v][vMileage] = mileage;
    CI[v][vOwnerType] = DS_OWNER_FAMILY; CI[v][vOwnerID] = fam;
    return DS_Msg(playerid, "Семейный транспорт получен. Доступ к управлению — у членов семьи.");
}
stock DS_CanDrive(playerid, vehicleid)
{
    return CI[vehicleid][vOwnerType] != DS_OWNER_FAMILY || (PI[playerid][pFamily] > 0 && PI[playerid][pFamily] == CI[vehicleid][vOwnerID]);
}
stock DS_OnVehicleDestroyed(vehicleid)
{
    if(vehicleid <= 0 || vehicleid >= MAX_VEHICLES) return 1;
    foreach(new p: Player) {
        if(DS[p][dsPreview] == vehicleid) DS[p][dsPreview] = 0;
        if(DS[p][dsTestVehicle] == vehicleid) DS[p][dsTestVehicle] = 0;
    }
    for(new f; f < MAX_FAMILY; f++) if(DS_FamilyVehicle[f] == vehicleid) {
        new q[200]; mysql_format(dbHandle, q, sizeof q, "UPDATE `ds_family_cars` SET `fuel`=%d,`mileage`=%d WHERE `id`=%d", CI[vehicleid][Fuel], CI[vehicleid][vMileage], DS_FamilyDb[f]);
        DS_Exec(q); DS_FamilyVehicle[f] = 0; DS_FamilyDb[f] = 0;
    }
    return 1;
}
stock DS_OnVehicleDeath(vehicleid)
{
    for(new f; f < MAX_FAMILY; f++) if(DS_FamilyVehicle[f] == vehicleid) { DS_FamilyStore(f); return 1; }
    return 1;
}
stock DS_Shutdown()
{
    KillTimer(DS_Timer);
    foreach(new p: Player) if(DS[p][dsStage]) DS_Close(p);
    for(new f; f < MAX_FAMILY; f++) DS_FamilyStore(f);
    for(new d; d < sizeof DS_Points; d++) { DestroyDynamicObject(DS_Object[d]); DestroyDynamicArea(DS_Area[d]); DestroyDynamicMapIcon(DS_MapIcon[d]); DestroyDynamic3DTextLabel(DS_Label[d]); }
    return 1;
}
