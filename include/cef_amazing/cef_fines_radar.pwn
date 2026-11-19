#if defined _cef_fines_radar_included
    #endinput
#endif
#define _cef_fines_radar_included

#include <zones>

#define CEF_FINE_LIST_MAX          24
#define CEF_FINE_MIN_POLICE_RANK   3
#define CEF_FINE_WANTED_COUNT      3
#define CEF_FINE_WANTED_SUM        50000
#define CEF_FINE_MAX_RADAR_AMOUNT  20000
#define CEF_RADAR_MAX              64
#define CEF_RADAR_MIN_LIMIT        40
#define CEF_RADAR_MAX_LIMIT        160
#define CEF_RADAR_RADIUS           30.0
#define CEF_RADAR_COOLDOWN_SECONDS 60
#define CEF_INV_MAX_WEIGHT         30.0
#define CEF_DROP_MAX               128
#define CEF_DROP_LIFETIME          300
#define CEF_INV_GRID_SLOTS         MAX_ITEMS




enum E_CEF_FINE_ROW
{
    cfrId,
    cfrAmount,
    cfrReason[96],
    cfrOfficer[MAX_PLAYER_NAME],
    cfrDate[24],
    bool:cfrPaid
}
new gCefFineRows[MAX_PLAYERS][CEF_FINE_LIST_MAX][E_CEF_FINE_ROW];
new gCefFineRowsCount[MAX_PLAYERS];
new gCefFinesLoaded[MAX_PLAYERS];
new gCefFineLoadSerial[MAX_PLAYERS];
new gCefFinesOpen[MAX_PLAYERS];
new gCefFinesPendingOpen[MAX_PLAYERS];
new gCefFinePaymentBusy[MAX_PLAYERS];
new gCefFineWantedFlag[MAX_PLAYERS];
new gCefFinesSchemaReady;




enum E_CEF_RADAR
{
    crId,
    Float:crX,
    Float:crY,
    Float:crZ,
    crLimit,
    bool:crActive,
    crOwnerFaction,
    crOwnerSqlId,
    crWorld,
    crInterior,
    STREAMER_TAG_OBJECT:crObject,
    STREAMER_TAG_AREA:crArea,
    crZone[48]
}
new gCefRadar[CEF_RADAR_MAX][E_CEF_RADAR];
new gCefRadarCount;
new bool:gCefRadarInside[MAX_PLAYERS][CEF_RADAR_MAX];
new gCefRadarLastFine[MAX_PLAYERS][CEF_RADAR_MAX];
new gCefRadarHudVisible[MAX_PLAYERS];
new gCefRadarManageOpen[MAX_PLAYERS];




new bool:gCefInventoryRouteOpen[MAX_PLAYERS];
new bool:gCefInventoryPendingOpen[MAX_PLAYERS];
new Float:gCefInventoryFacing[MAX_PLAYERS];

enum E_CEF_DROP
{
    STREAMER_TAG_PICKUP:cdPickup,
    Text3D:cdLabel,
    cdType,
    cdAmount,
    cdExpires,
    cdWorld,
    cdInterior
}
new gCefDrops[CEF_DROP_MAX][E_CEF_DROP];

forward CEF_FinesInit();
forward CEF_FinesHeartbeat(playerid);
forward CEF_FinesLoad(playerid);
forward CEF_FinesOnLoad(playerid, owner_sqlid, load_serial);
forward CEF_FinesOnInsert(playerid, owner_sqlid, amount, radar_id, speed, limit, const reason[], const officer[]);
forward CEF_FinesOnPayDone(playerid, owner_sqlid, amount, mode, fine_id);
forward CEF_FinesOnBalanceLoaded(playerid, owner_sqlid, amount, mode);
forward CEF_RadarSchemaReady();
forward CEF_RadarOnLoad();
forward CEF_RadarOnPlaceDone(playerid, limit, owner_faction, owner_sqlid, world, interior, Float:x, Float:y, Float:z, const zone[]);
forward CEF_RadarOnRemoveDone(playerid, radar_id, owner_faction);
forward CEF_InventoryDropTick();
forward CEF_InventoryOnDataReady(playerid);
forward CEF_InventoryAfterAction(playerid);
forward CEF_InventoryPickup(playerid, STREAMER_TAG_PICKUP:pickupid);
forward CEF_RadarOnAreaEnter(playerid, areaid);
forward CEF_RadarOnAreaLeave(playerid, areaid);
forward CEF_FinesCanRegisterVehicle(playerid);

public CEF_FinesPlayerReset(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS) return 0;
    gCefFineLoadSerial[playerid]++;
    gCefFineRowsCount[playerid] = 0;
    gCefFinesLoaded[playerid] = 0;
    gCefFinesOpen[playerid] = 0;
    gCefFinesPendingOpen[playerid] = 0;
    gCefFinePaymentBusy[playerid] = 0;
    gCefFineWantedFlag[playerid] = 0;
    gCefFineN[playerid] = 0;
    gCefFineSum[playerid] = 0;
    return 1;
}

public CEF_InventoryPlayerReset(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS) return 0;
    gCefInventoryRouteOpen[playerid] = false;
    gCefInventoryPendingOpen[playerid] = false;
    gCefInventoryItemsLoaded[playerid] = false;
    gCefInventoryFacing[playerid] = 0.0;
    return 1;
}

public CEF_FinesInit()
{
    gCefFinesSchemaReady = 0;
    mysql_tquery(dbHandle,
        "CREATE TABLE IF NOT EXISTS `fines` (`id` INT NOT NULL AUTO_INCREMENT, `playerid_sql` INT NOT NULL, `reason` VARCHAR(128) NOT NULL, `amount` INT NOT NULL, `officer_name` VARCHAR(24) NOT NULL, `issued_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, `paid` TINYINT(1) NOT NULL DEFAULT 0, `radar_id` INT NOT NULL DEFAULT 0, PRIMARY KEY (`id`), KEY `idx_fines_owner_paid` (`playerid_sql`,`paid`,`issued_at`), KEY `idx_fines_radar` (`radar_id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
    mysql_tquery(dbHandle,
        "CREATE TABLE IF NOT EXISTS `fines_player_flags` (`owner_id` INT NOT NULL, `added_wanted` TINYINT(1) NOT NULL DEFAULT 0, PRIMARY KEY (`owner_id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
    mysql_tquery(dbHandle,
        "CREATE TABLE IF NOT EXISTS `radars` (`id` INT NOT NULL AUTO_INCREMENT, `x` FLOAT NOT NULL, `y` FLOAT NOT NULL, `z` FLOAT NOT NULL, `limit_kmh` SMALLINT NOT NULL, `active` TINYINT(1) NOT NULL DEFAULT 1, `owner_faction` INT NOT NULL, `owner_id` INT NOT NULL, `world_id` INT NOT NULL DEFAULT 0, `interior_id` INT NOT NULL DEFAULT 0, `zone` VARCHAR(48) NOT NULL DEFAULT '', `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (`id`), KEY `idx_radars_active` (`active`,`owner_faction`)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4",
        "CEF_RadarSchemaReady", "");
    for(new i = 0; i < CEF_DROP_MAX; i++)
    {
        gCefDrops[i][cdPickup] = STREAMER_TAG_PICKUP:-1;
        gCefDrops[i][cdLabel] = Text3D:INVALID_3DTEXT_ID;
    }
    SetTimer("CEF_InventoryDropTick", 30000, true);
    return 1;
}

public CEF_RadarSchemaReady()
{
    gCefFinesSchemaReady = 1;
    foreach(new playerid : Player)
        if(PT[playerid][pLogged] && PI[playerid][pID] > 0) CEF_FinesLoad(playerid);
    mysql_tquery(dbHandle,
        "SELECT `id`,`x`,`y`,`z`,`limit_kmh`,`active`,`owner_faction`,`owner_id`,`world_id`,`interior_id`,`zone` FROM `radars` WHERE `active`=1 ORDER BY `id` ASC",
        "CEF_RadarOnLoad", "");
    return 1;
}

public CEF_RadarOnLoad()
{
    new rows = cache_num_rows();
    new id, limit, active, faction, owner, world, interior;
    new Float:x, Float:y, Float:z, zone[48];
    gCefRadarCount = 0;
    for(new i = 0; i < rows && gCefRadarCount < CEF_RADAR_MAX; i++)
    {
        cache_get_value_name_int(i, "id", id);
        cache_get_value_name_float(i, "x", x);
        cache_get_value_name_float(i, "y", y);
        cache_get_value_name_float(i, "z", z);
        cache_get_value_name_int(i, "limit_kmh", limit);
        cache_get_value_name_int(i, "active", active);
        cache_get_value_name_int(i, "owner_faction", faction);
        cache_get_value_name_int(i, "owner_id", owner);
        cache_get_value_name_int(i, "world_id", world);
        cache_get_value_name_int(i, "interior_id", interior);
        cache_get_value_name(i, "zone", zone, sizeof zone);
        if(id <= 0 || limit < CEF_RADAR_MIN_LIMIT || limit > CEF_RADAR_MAX_LIMIT || !active) continue;
        CEF_RadarAdd(id, x, y, z, limit, faction, owner, world, interior, zone);
    }
    printf("[CEF-RADAR] loaded %d active radars", gCefRadarCount);
    return 1;
}

stock CEF_RadarAdd(id, Float:x, Float:y, Float:z, limit, faction, owner, world, interior, const zone[])
{
    if(gCefRadarCount >= CEF_RADAR_MAX) return -1;
    new idx = gCefRadarCount++;
    gCefRadar[idx][crId] = id;
    gCefRadar[idx][crX] = x;
    gCefRadar[idx][crY] = y;
    gCefRadar[idx][crZ] = z;
    gCefRadar[idx][crLimit] = limit;
    gCefRadar[idx][crActive] = true;
    gCefRadar[idx][crOwnerFaction] = faction;
    gCefRadar[idx][crOwnerSqlId] = owner;
    gCefRadar[idx][crWorld] = world;
    gCefRadar[idx][crInterior] = interior;
    format(gCefRadar[idx][crZone], 48, "%s", zone);
    gCefRadar[idx][crObject] = CreateDynamicObject(18880, x, y, z - 0.65, 0.0, 0.0, 0.0,
        world, interior, -1, 180.0, 180.0);
    gCefRadar[idx][crArea] = CreateDynamicSphere(x, y, z, CEF_RADAR_RADIUS, world, interior, -1);
    for(new p = 0; p < MAX_PLAYERS; p++)
    {
        gCefRadarInside[p][idx] = false;
        gCefRadarLastFine[p][idx] = 0;
    }
    return idx;
}

stock CEF_RadarDestroyAt(idx)
{
    if(idx < 0 || idx >= gCefRadarCount) return 0;
    if(IsValidDynamicArea(gCefRadar[idx][crArea])) DestroyDynamicArea(gCefRadar[idx][crArea]);
    if(IsValidDynamicObject(gCefRadar[idx][crObject])) DestroyDynamicObject(gCefRadar[idx][crObject]);
    for(new i = idx; i < gCefRadarCount - 1; i++)
    {
        gCefRadar[i] = gCefRadar[i + 1];
        for(new p = 0; p < MAX_PLAYERS; p++)
        {
            gCefRadarInside[p][i] = gCefRadarInside[p][i + 1];
            gCefRadarLastFine[p][i] = gCefRadarLastFine[p][i + 1];
        }
    }
    gCefRadarCount--;
    for(new p = 0; p < MAX_PLAYERS; p++)
    {
        gCefRadarInside[p][gCefRadarCount] = false;
        gCefRadarLastFine[p][gCefRadarCount] = 0;
    }
    return 1;
}

stock CEF_IsPoliceFraction(faction)
{
    return faction == FRACTION_TRAFFIC_PATROL_POLICE || faction == FRACTION_PATROL_POLICE || faction == FRACTION_FSB;
}

stock CEF_PlayerCanIssueFine(playerid)
{
    return IsPlayerConnected(playerid) && PT[playerid][pLogged] &&
        CEF_IsPoliceFraction(PI[playerid][pFraction]) &&
        PI[playerid][pFractionRank] >= CEF_FINE_MIN_POLICE_RANK;
}

stock CEF_FineRankLimit(playerid)
{
    new rank = PI[playerid][pFractionRank];
    if(rank <= 4) return 5000;
    if(rank <= 6) return 15000;
    if(rank <= 8) return 30000;
    return 50000;
}

public CEF_FinesLoad(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) || PI[playerid][pID] <= 0) return 0;
    if(!gCefFinesSchemaReady) return 1;
    gCefFineLoadSerial[playerid]++;
    if(gCefFineLoadSerial[playerid] <= 0) gCefFineLoadSerial[playerid] = 1;
    gCefFinesLoaded[playerid] = 0;
    new query[700];
    mysql_format(dbHandle, query, sizeof query,
        "SELECT f.`id`,f.`reason`,f.`amount`,f.`officer_name`,f.`issued_at`,f.`paid`,COALESCE(s.`unpaid_count`,0) AS `unpaid_count`,COALESCE(s.`unpaid_sum`,0) AS `unpaid_sum`,COALESCE(ff.`added_wanted`,0) AS `added_wanted` FROM (SELECT %d AS `owner_id`) AS o LEFT JOIN `fines` AS f ON f.`playerid_sql`=o.`owner_id` LEFT JOIN (SELECT `playerid_sql`,COUNT(*) AS `unpaid_count`,COALESCE(SUM(`amount`),0) AS `unpaid_sum` FROM `fines` WHERE `playerid_sql`=%d AND `paid`=0 GROUP BY `playerid_sql`) AS s ON s.`playerid_sql`=o.`owner_id` LEFT JOIN `fines_player_flags` AS ff ON ff.`owner_id`=o.`owner_id` ORDER BY f.`paid` ASC,f.`issued_at` DESC,f.`id` DESC LIMIT %d",
        PI[playerid][pID], PI[playerid][pID], CEF_FINE_LIST_MAX);
    mysql_tquery(dbHandle, query, "CEF_FinesOnLoad", "iii", playerid, PI[playerid][pID], gCefFineLoadSerial[playerid]);
    return 1;
}

public CEF_FinesOnLoad(playerid, owner_sqlid, load_serial)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid)) return 0;
    if(PI[playerid][pID] != owner_sqlid || gCefFineLoadSerial[playerid] != load_serial) return 0;
    new rows = cache_num_rows(), unpaidCount = 0, unpaidSum = 0, addedWanted = 0;
    new id, amount, paid;
    gCefFineRowsCount[playerid] = 0;
    for(new i = 0; i < rows && i < CEF_FINE_LIST_MAX; i++)
    {
        cache_get_value_name_int(i, "id", id);
        cache_get_value_name_int(i, "unpaid_count", unpaidCount);
        cache_get_value_name_int(i, "unpaid_sum", unpaidSum);
        cache_get_value_name_int(i, "added_wanted", addedWanted);
        if(id <= 0) continue;
        cache_get_value_name_int(i, "amount", amount);
        cache_get_value_name_int(i, "paid", paid);
        new at = gCefFineRowsCount[playerid];
        gCefFineRows[playerid][at][cfrId] = id;
        gCefFineRows[playerid][at][cfrAmount] = amount;
        gCefFineRows[playerid][at][cfrPaid] = paid != 0;
        cache_get_value_name(i, "reason", gCefFineRows[playerid][at][cfrReason], 96);
        cache_get_value_name(i, "officer_name", gCefFineRows[playerid][at][cfrOfficer], MAX_PLAYER_NAME);
        cache_get_value_name(i, "issued_at", gCefFineRows[playerid][at][cfrDate], 24);
        gCefFineRowsCount[playerid]++;
    }
    gCefFineN[playerid] = unpaidCount;
    gCefFineSum[playerid] = unpaidSum;
    gCefFineWantedFlag[playerid] = addedWanted;
    gCefFinesLoaded[playerid] = 1;
    CEF_FinesEvaluateWanted(playerid);
    if(gCefFinesPendingOpen[playerid])
    {
        gCefFinesPendingOpen[playerid] = 0;
        CEF_FinesOpen(playerid);
    }
    else if(gCefFinesOpen[playerid]) CEF_FinesSendUpdate(playerid);
    return 1;
}

public CEF_FinesHeartbeat(playerid)
{
    if(playerid >= 0 && playerid < MAX_PLAYERS && gCefFinesLoaded[playerid])
        CEF_FinesEvaluateWanted(playerid);
    return 1;
}

stock CEF_FinesEvaluateWanted(playerid)
{
    new query[220];
    new bool:overdue = gCefFineN[playerid] > CEF_FINE_WANTED_COUNT || gCefFineSum[playerid] > CEF_FINE_WANTED_SUM;
    if(overdue && !gCefFineWantedFlag[playerid] && PI[playerid][pWanted] <= 0)
    {
        PI[playerid][pWanted] = 1;
        gCefFineWantedFlag[playerid] = 1;
        mysql_format(dbHandle, query, sizeof query,
            "INSERT INTO `fines_player_flags` (`owner_id`,`added_wanted`) VALUES (%d,1) ON DUPLICATE KEY UPDATE `added_wanted`=1",
            PI[playerid][pID]);
        mysql_tquery(dbHandle, query, "", "");
        SaveAccount(playerid);
    }
    else if(overdue && gCefFineWantedFlag[playerid] && PI[playerid][pWanted] <= 0)
    {
        PI[playerid][pWanted] = 1;
        SaveAccount(playerid);
    }
    else if(!overdue && gCefFineWantedFlag[playerid])
    {
        if(PI[playerid][pWanted] > 0) PI[playerid][pWanted]--;
        gCefFineWantedFlag[playerid] = 0;
        mysql_format(dbHandle, query, sizeof query,
            "INSERT INTO `fines_player_flags` (`owner_id`,`added_wanted`) VALUES (%d,0) ON DUPLICATE KEY UPDATE `added_wanted`=0",
            PI[playerid][pID]);
        mysql_tquery(dbHandle, query, "", "");
        SaveAccount(playerid);
    }
    return 1;
}

stock CEF_FinesBuildJson(playerid, dest[], size)
{
    new part[480], reason[192], officer[64], date[48], first = 1;
    format(dest, size, "{\"balance\":%d,\"total\":%d,\"count\":%d,\"fines\":[",
        PI[playerid][pBank], gCefFineSum[playerid], gCefFineN[playerid]);
    for(new i = 0; i < gCefFineRowsCount[playerid]; i++)
    {
        CEF_JsonEscape(gCefFineRows[playerid][i][cfrReason], reason, sizeof reason);
        CEF_JsonEscape(gCefFineRows[playerid][i][cfrOfficer], officer, sizeof officer);
        CEF_JsonEscape(gCefFineRows[playerid][i][cfrDate], date, sizeof date);
        format(part, sizeof part,
            "%s{\"id\":%d,\"reason\":\"%s\",\"amount\":%d,\"officer\":\"%s\",\"date\":\"%s\",\"status\":\"%s\"}",
            first ? "" : ",", gCefFineRows[playerid][i][cfrId], reason,
            gCefFineRows[playerid][i][cfrAmount], officer, date,
            gCefFineRows[playerid][i][cfrPaid] ? "paid" : "unpaid");
        if(strlen(dest) + strlen(part) + 2 >= size) break;
        strcat(dest, part, size);
        first = 0;
    }
    strcat(dest, "]}", size);
    return 1;
}

stock CEF_FinesSendUpdate(playerid)
{
    new json[CEF_JSON_SIZE];
    CEF_FinesBuildJson(playerid, json, sizeof json);
    return CEF_Send(playerid, "cef_fines_update", json);
}

stock CEF_FinesOpen(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) || !PT[playerid][pLogged]) return 0;
    if(gCefInventoryRouteOpen[playerid]) CEF_InventoryClose(playerid, true);
    if(gCefRadarManageOpen[playerid]) CEF_RadarManageClose(playerid);
    if(gCefAdminPanelOpen[playerid]) CEF_AdminPanelClose(playerid);
    if(gCefSupportPanelOpen[playerid]) CEF_SupportClose(playerid);
    if(gCefCaseActive[playerid] || gCefCasePending[playerid]) CEF_CaseCloseUi(playerid);
    if(gCefMenuOpen[playerid])
    {
        CEF_SendEmpty(playerid, "menu_close");
        CEFC_OnMenuClosed(playerid);
    }
    if(gCefcDialogId[playerid] != -1) CEFC_DialogClose(playerid);
    if(gCefChatInput[playerid]) CEFC_ChatCloseInput(playerid);
    if(!gCefFinesLoaded[playerid])
    {
        gCefFinesPendingOpen[playerid] = 1;
        CEF_FinesLoad(playerid);
        return 1;
    }
    gCefFinesOpen[playerid] = 1;
    CEF_MarkPlayerReady(playerid);
    CEF_Show(playerid, false);
    new json[CEF_JSON_SIZE];
    CEF_FinesBuildJson(playerid, json, sizeof json);
    CEF_Send(playerid, "cef_fines_open", json);
    CEF_Focus(playerid, true);
    return 1;
}

stock CEF_FinesClose(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS) return 0;
    new bool:wasOpen = (gCefFinesOpen[playerid] != 0);
    gCefFinesOpen[playerid] = 0;
    gCefFinesPendingOpen[playerid] = 0;
    if(wasOpen) CEF_SendEmpty(playerid, "cef_fines_close");
    CEF_Focus(playerid, false);
    CEF_Hide(playerid);
    return 1;
}

stock CEF_FinesNotify(playerid, id, amount, const reason[], const officer[])
{
    if(!IsPlayerConnected(playerid)) return 0;
    new json[600], escReason[192], escOfficer[64];
    CEF_JsonEscape(reason, escReason, sizeof escReason);
    CEF_JsonEscape(officer, escOfficer, sizeof escOfficer);
    format(json, sizeof json,
        "{\"id\":%d,\"reason\":\"%s\",\"amount\":%d,\"officer\":\"%s\"}",
        id, escReason, amount, escOfficer);
    return CEF_Send(playerid, "cef_fines_notify", json);
}

stock CEF_FineIssue(targetid, amount, const reason[], radar_id = 0, speed = 0, limit = 0, const officer_override[] = "")
{
    if(targetid < 0 || targetid >= MAX_PLAYERS || !IsPlayerConnected(targetid) || !PT[targetid][pLogged]) return 0;
    if(amount <= 0 || PI[targetid][pID] <= 0 || !strlen(reason)) return 0;
    new officer[MAX_PLAYER_NAME], query[700];
    if(officer_override[0]) format(officer, sizeof officer, "%s", officer_override);
    else format(officer, sizeof officer, "%s", "Полиция");
    mysql_format(dbHandle, query, sizeof query,
        "INSERT INTO `fines` (`playerid_sql`,`reason`,`amount`,`officer_name`,`issued_at`,`paid`,`radar_id`) VALUES (%d,'%e',%d,'%e',NOW(),0,%d)",
        PI[targetid][pID], reason, amount, officer, radar_id);
    mysql_tquery(dbHandle, query, "CEF_FinesOnInsert", "ddddddss",
        targetid, PI[targetid][pID], amount, radar_id, speed, limit, reason, officer);
    return 1;
}

stock CEF_FineIssueByOfficer(officerid, targetid, amount, const reason[])
{
    if(!IsPlayerConnected(officerid) || !IsPlayerConnected(targetid) || !PT[targetid][pLogged] || PI[targetid][pID] <= 0) return 0;
    if(amount <= 0 || !strlen(reason)) return 0;
    new officer[MAX_PLAYER_NAME], query[700];
    format(officer, sizeof officer, "%s", PI[officerid][pName]);
    mysql_format(dbHandle, query, sizeof query,
        "INSERT INTO `fines` (`playerid_sql`,`reason`,`amount`,`officer_name`,`issued_at`,`paid`,`radar_id`) VALUES (%d,'%e',%d,'%e',NOW(),0,0)",
        PI[targetid][pID], reason, amount, officer);
    mysql_tquery(dbHandle, query, "CEF_FinesOnInsert", "ddddddss",
        targetid, PI[targetid][pID], amount, 0, 0, 0, reason, officer);
    return 1;
}

public CEF_FinesOnInsert(playerid, owner_sqlid, amount, radar_id, speed, limit, const reason[], const officer[])
{
    if(cache_insert_id() <= 0) return 0;
    new fineid = cache_insert_id();
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) || PI[playerid][pID] != owner_sqlid) return 1;
    CEF_FinesNotify(playerid, fineid, amount, reason, officer);
    if(radar_id > 0)
    {
        new json[128];
        format(json, sizeof json, "{\"speed\":%d,\"limit\":%d,\"amount\":%d}", speed, limit, amount);
        CEF_Send(playerid, "cef_radar_fine", json);
    }
    CEF_FinesLoad(playerid);
    return 1;
}

stock CEF_FinesFindIndex(playerid, fineid)
{
    for(new i = 0; i < gCefFineRowsCount[playerid]; i++)
        if(gCefFineRows[playerid][i][cfrId] == fineid) return i;
    return -1;
}

stock CEF_FinesPayOne(playerid, fineid)
{
    if(!IsPlayerConnected(playerid) || !PT[playerid][pLogged] || PI[playerid][pID] <= 0) return 0;
    if(gCefFinePaymentBusy[playerid]) return 1;
    if(fineid <= 0) return CEFC_Notify(playerid, "Штраф не найден.", "error");
    new idx = CEF_FinesFindIndex(playerid, fineid);
    if(idx >= 0 && gCefFineRows[playerid][idx][cfrPaid]) return CEFC_Notify(playerid, "Этот штраф уже оплачен.", "hint");
    if(idx >= 0 && PI[playerid][pBank] < gCefFineRows[playerid][idx][cfrAmount])
        return CEFC_Notify(playerid, "На банковском счёте недостаточно средств.", "error");
    new query[500];
    mysql_format(dbHandle, query, sizeof query,
        "UPDATE `fines` AS f JOIN `accounts` AS a ON a.`id`=f.`playerid_sql` SET f.`paid`=1,a.`bank`=a.`bank`-f.`amount` WHERE f.`id`=%d AND f.`playerid_sql`=%d AND f.`paid`=0 AND a.`bank`>=f.`amount`",
        fineid, PI[playerid][pID]);
    gCefFinePaymentBusy[playerid] = 1;
    mysql_tquery(dbHandle, query, "CEF_FinesOnPayDone", "ddddd", playerid, PI[playerid][pID], idx >= 0 ? gCefFineRows[playerid][idx][cfrAmount] : 0, 1, fineid);
    return 1;
}

stock CEF_FinesPayAll(playerid)
{
    if(!IsPlayerConnected(playerid) || !PT[playerid][pLogged] || PI[playerid][pID] <= 0) return 0;
    if(gCefFinePaymentBusy[playerid]) return 1;
    if(gCefFineN[playerid] <= 0 || gCefFineSum[playerid] <= 0)
        return CEFC_Notify(playerid, "Неоплаченных штрафов нет.", "hint");
    if(PI[playerid][pBank] < gCefFineSum[playerid])
        return CEFC_Notify(playerid, "На банковском счёте недостаточно средств.", "error");
    new query[760];
    mysql_format(dbHandle, query, sizeof query,
        "UPDATE `accounts` AS a JOIN (SELECT `playerid_sql`,SUM(`amount`) AS `due` FROM `fines` WHERE `playerid_sql`=%d AND `paid`=0 GROUP BY `playerid_sql`) AS d ON d.`playerid_sql`=a.`id` JOIN `fines` AS f ON f.`playerid_sql`=a.`id` AND f.`paid`=0 SET a.`bank`=a.`bank`-d.`due`,f.`paid`=1 WHERE a.`id`=%d AND a.`bank`>=d.`due`",
        PI[playerid][pID], PI[playerid][pID]);
    gCefFinePaymentBusy[playerid] = 1;
    mysql_tquery(dbHandle, query, "CEF_FinesOnPayDone", "ddddd", playerid, PI[playerid][pID], gCefFineSum[playerid], 2, 0);
    return 1;
}

public CEF_FinesOnPayDone(playerid, owner_sqlid, amount, mode, fine_id)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) || PI[playerid][pID] != owner_sqlid) return 0;
    if(cache_affected_rows() <= 0)
    {
        gCefFinePaymentBusy[playerid] = 0;
        if(mode == 1) CEFC_Notify(playerid, "Штраф уже оплачен или на счёте недостаточно средств.", "error");
        else CEFC_Notify(playerid, "Не удалось оплатить штрафы: проверьте баланс.", "error");
        CEF_FinesLoad(playerid);
        return 1;
    }
    new query[128];
    mysql_format(dbHandle, query, sizeof query,
        "SELECT `cash`,`bank` FROM `accounts` WHERE `id`=%d LIMIT 1", owner_sqlid);
    mysql_tquery(dbHandle, query, "CEF_FinesOnBalanceLoaded", "dddd", playerid, owner_sqlid, amount, mode);
    #pragma unused fine_id
    return 1;
}

public CEF_FinesOnBalanceLoaded(playerid, owner_sqlid, amount, mode)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) || PI[playerid][pID] != owner_sqlid) return 0;
    if(cache_num_rows() > 0)
    {
        cache_get_value_name_int(0, "cash", PI[playerid][pCash]);
        cache_get_value_name_int(0, "bank", PI[playerid][pBank]);
        UpdatePlayerHUD(playerid);
        CEFC_AccountStats(playerid);
        CEF_CurrencySend(playerid);
        if(mode == 1) CEFC_Notify(playerid, "Штраф оплачен.", "success");
        else CEFC_Notify(playerid, "Все штрафы оплачены.", "success");
    }
    gCefFinePaymentBusy[playerid] = 0;
    CEF_FinesLoad(playerid);
    #pragma unused amount
    return 1;
}

stock CEF_FineShow(playerid)
{
    return CEF_FinesOpen(playerid);
}

stock CEF_FinePay(playerid)
{
    return CEF_FinesPayAll(playerid);
}

CMD:fines(playerid, params[])
{
    #pragma unused params
    return CEF_FinesOpen(playerid);
}

CMD:tickets(playerid, params[])
{
    #pragma unused params
    return CEF_FinesOpen(playerid);
}

CMD:payfines(playerid, params[])
{
    #pragma unused params
    return CEF_FinesPayAll(playerid);
}

CMD:fine(playerid, params[])
{
    new target, amount, reason[96], maxAmount;
    if(!CEF_PlayerCanIssueFine(playerid))
        return SendErr(playerid, "Выписывать штрафы может полиция с 3-го звания.");
    if(sscanf(params, "udS()[96]", target, amount, reason) || !strlen(reason))
        return SendErr(playerid, "/fine [id] [сумма] [причина]");
    if(target == INVALID_PLAYER_ID || !IsPlayerConnected(target) || !PT[target][pLogged])
        return SendErr(playerid, "Игрок не найден или не авторизован.");
    maxAmount = CEF_FineRankLimit(playerid);
    if(amount < 1 || amount > maxAmount)
    {
        new text[96];
        format(text, sizeof text, "Сумма должна быть от 1 до %d руб. для вашего звания.", maxAmount);
        return SendErr(playerid, text);
    }
    CEF_FineIssueByOfficer(playerid, target, amount, reason);
    return 1;
}

stock CEF_PlayerSpeed(playerid)
{
    new Float:vx, Float:vy, Float:vz;
    new vehicleid = GetPlayerVehicleID(playerid);
    if(vehicleid) GetVehicleVelocity(vehicleid, vx, vy, vz);
    else GetPlayerVelocity(playerid, vx, vy, vz);
    return floatround(floatsqroot(vx * vx + vy * vy + vz * vz) * 180.0);
}

stock CEF_RadarSendHud(playerid, speed, limit, bool:visible)
{
    new json[96];
    format(json, sizeof json, "{\"speed\":%d,\"limit\":%d,\"visible\":%s}",
        speed, limit, visible ? "true" : "false");
    return CEF_Send(playerid, "cef_radar_hud", json);
}

public CEF_RadarOnAreaEnter(playerid, areaid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !PT[playerid][pLogged]) return 0;
    for(new i = 0; i < gCefRadarCount; i++)
    {
        if(gCefRadar[i][crArea] == areaid && gCefRadar[i][crActive])
        {
            gCefRadarInside[playerid][i] = true;
            return 1;
        }
    }
    return 0;
}

public CEF_RadarOnAreaLeave(playerid, areaid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS) return 0;
    for(new i = 0; i < gCefRadarCount; i++)
    {
        if(gCefRadar[i][crArea] == areaid)
        {
            gCefRadarInside[playerid][i] = false;
            return 1;
        }
    }
    return 0;
}

stock CEF_RadarPulse(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !PT[playerid][pLogged]) return 0;
    new hasRadar = 0, bestLimit = 0, speed = 0, now = gettime(), amount, reason[96];
    new bool:driver = IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER;
    if(driver) speed = CEF_PlayerSpeed(playerid);
    for(new i = 0; i < gCefRadarCount; i++)
    {
        if(!gCefRadar[i][crActive]) continue;
        if(GetPlayerVirtualWorld(playerid) != gCefRadar[i][crWorld] || GetPlayerInterior(playerid) != gCefRadar[i][crInterior])
        {
            gCefRadarInside[playerid][i] = false;
            continue;
        }
        gCefRadarInside[playerid][i] = IsPlayerInRangeOfPoint(playerid, CEF_RADAR_RADIUS,
            gCefRadar[i][crX], gCefRadar[i][crY], gCefRadar[i][crZ]);
        if(!gCefRadarInside[playerid][i]) continue;
        if(!hasRadar || gCefRadar[i][crLimit] < bestLimit) bestLimit = gCefRadar[i][crLimit];
        hasRadar = 1;
        if(!driver || speed <= gCefRadar[i][crLimit]) continue;
        if(gCefRadarLastFine[playerid][i] > 0 && now - gCefRadarLastFine[playerid][i] < CEF_RADAR_COOLDOWN_SECONDS) continue;
        gCefRadarLastFine[playerid][i] = now;
        amount = (speed - gCefRadar[i][crLimit]) * 20;
        if(amount > CEF_FINE_MAX_RADAR_AMOUNT) amount = CEF_FINE_MAX_RADAR_AMOUNT;
        if(amount < 100) amount = 100;
        format(reason, sizeof reason, "Превышение скорости %d/%d км/ч", speed, gCefRadar[i][crLimit]);
        CEF_FineIssue(playerid, amount, reason, gCefRadar[i][crId], speed, gCefRadar[i][crLimit], "Автоматический радар");
    }
    if(hasRadar && driver)
    {
        CEF_RadarSendHud(playerid, speed, bestLimit, true);
        gCefRadarHudVisible[playerid] = 1;
    }
    else if(gCefRadarHudVisible[playerid])
    {
        CEF_RadarSendHud(playerid, speed, bestLimit, false);
        gCefRadarHudVisible[playerid] = 0;
    }
    return hasRadar;
}

stock CEF_RadarSendPoliceList(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) || !PT[playerid][pLogged]) return 0;
    if(gCefInventoryRouteOpen[playerid]) CEF_InventoryClose(playerid, true);
    if(gCefFinesOpen[playerid] || gCefFinesPendingOpen[playerid]) CEF_FinesClose(playerid);
    if(gCefAdminPanelOpen[playerid]) CEF_AdminPanelClose(playerid);
    if(gCefSupportPanelOpen[playerid]) CEF_SupportClose(playerid);
    if(gCefCaseActive[playerid] || gCefCasePending[playerid]) CEF_CaseCloseUi(playerid);
    if(gCefMenuOpen[playerid])
    {
        CEF_SendEmpty(playerid, "menu_close");
        CEFC_OnMenuClosed(playerid);
    }
    if(gCefcDialogId[playerid] != -1) CEFC_DialogClose(playerid);
    if(gCefChatInput[playerid]) CEFC_ChatCloseInput(playerid);
    new json[CEF_JSON_SIZE], part[220], zone[128], first = 1;
    json = "{\"radars\":[";
    for(new i = 0; i < gCefRadarCount; i++)
    {
        if(!gCefRadar[i][crActive]) continue;
        CEF_JsonEscape(gCefRadar[i][crZone], zone, sizeof zone);
        format(part, sizeof part, "%s{\"id\":%d,\"zone\":\"%s\",\"limit\":%d,\"active\":%s}",
            first ? "" : ",", gCefRadar[i][crId], zone, gCefRadar[i][crLimit],
            gCefRadar[i][crActive] ? "true" : "false");
        if(strlen(json) + strlen(part) + 3 >= sizeof json) break;
        strcat(json, part);
        first = 0;
    }
    strcat(json, "]}");
    CEF_MarkPlayerReady(playerid);
    CEF_Show(playerid, false);
    CEF_Send(playerid, "cef_radar_cop_open", json);

    gCefRadarManageOpen[playerid] = 1;
    return 1;
}

stock CEF_RadarIsManager(playerid)
{
    return IsPlayerConnected(playerid) && PT[playerid][pLogged] &&
        (CEF_IsPoliceFraction(PI[playerid][pFraction]) || PI[playerid][pAdmin] > 0);
}

stock CEF_RadarPlace(playerid, limit)
{
    if(!CEF_PlayerCanIssueFine(playerid) && PI[playerid][pAdmin] <= 0)
        return SendErr(playerid, "Устанавливать радары может полиция с 3-го звания.");
    if(limit < CEF_RADAR_MIN_LIMIT || limit > CEF_RADAR_MAX_LIMIT)
    {
        new msg[96];
        format(msg, sizeof msg, "Лимит радара должен быть от %d до %d км/ч.", CEF_RADAR_MIN_LIMIT, CEF_RADAR_MAX_LIMIT);
        return SendErr(playerid, msg);
    }
    if(IsPlayerInAnyVehicle(playerid)) return SendErr(playerid, "Выйдите из транспорта для установки радара.");
    if(gCefRadarCount >= CEF_RADAR_MAX) return SendErr(playerid, "Достигнут лимит установленных радаров.");
    new Float:x, Float:y, Float:z, zone[48], query[640];
    GetPlayerPos(playerid, x, y, z);
    GetPlayer3DZone(playerid, zone, sizeof zone);
    if(!strlen(zone)) format(zone, sizeof zone, "%.1f, %.1f", x, y);
    mysql_format(dbHandle, query, sizeof query,
        "INSERT INTO `radars` (`x`,`y`,`z`,`limit_kmh`,`active`,`owner_faction`,`owner_id`,`world_id`,`interior_id`,`zone`) VALUES (%f,%f,%f,%d,1,%d,%d,%d,%d,'%e')",
        x, y, z, limit, PI[playerid][pFraction], PI[playerid][pID], GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), zone);
    mysql_tquery(dbHandle, query, "CEF_RadarOnPlaceDone", "ddddddfffs", playerid, limit,
        PI[playerid][pFraction], PI[playerid][pID], GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), x, y, z, zone);
    return 1;
}

public CEF_RadarOnPlaceDone(playerid, limit, owner_faction, owner_sqlid, world, interior, Float:x, Float:y, Float:z, const zone[])
{
    new id = cache_insert_id();
    if(id <= 0 || gCefRadarCount >= CEF_RADAR_MAX) return 0;
    if(!IsPlayerConnected(playerid) || PI[playerid][pID] != owner_sqlid) return 0;
    CEF_RadarAdd(id, x, y, z, limit, owner_faction, owner_sqlid, world, interior, zone);
    CEFC_Notify(playerid, "Радар установлен и сохранён.", "success");
    if(gCefRadarManageOpen[playerid]) CEF_RadarSendPoliceList(playerid);
    return 1;
}

stock CEF_RadarFindIndex(radarid)
{
    for(new i = 0; i < gCefRadarCount; i++)
        if(gCefRadar[i][crId] == radarid) return i;
    return -1;
}

stock CEF_RadarManageClose(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS) return 0;
    new bool:wasOpen = (gCefRadarManageOpen[playerid] != 0);
    gCefRadarManageOpen[playerid] = 0;
    if(wasOpen) CEF_SendEmpty(playerid, "cef_radar_close");
    CEF_Focus(playerid, false);
    CEF_Hide(playerid);
    return 1;
}

stock CEF_RadarRemove(playerid, radarid)
{
    if(!CEF_RadarIsManager(playerid)) return 0;
    new idx = CEF_RadarFindIndex(radarid);
    if(idx < 0) return CEFC_Notify(playerid, "Радар не найден.", "error");
    if(PI[playerid][pAdmin] <= 0 && gCefRadar[idx][crOwnerFaction] != PI[playerid][pFraction])
        return CEFC_Notify(playerid, "Можно удалить только радар своей фракции.", "error");
    new query[256];
    mysql_format(dbHandle, query, sizeof query,
        "UPDATE `radars` SET `active`=0 WHERE `id`=%d AND `active`=1 AND `owner_faction`=%d",
        radarid, gCefRadar[idx][crOwnerFaction]);
    mysql_tquery(dbHandle, query, "CEF_RadarOnRemoveDone", "ddd", playerid, radarid, gCefRadar[idx][crOwnerFaction]);
    return 1;
}

public CEF_RadarOnRemoveDone(playerid, radar_id, owner_faction)
{
    if(cache_affected_rows() > 0)
    {
        new idx = CEF_RadarFindIndex(radar_id);
        if(idx >= 0) CEF_RadarDestroyAt(idx);
        if(IsPlayerConnected(playerid)) CEFC_Notify(playerid, "Радар удалён.", "success");
    }
    if(IsPlayerConnected(playerid) && gCefRadarManageOpen[playerid]) CEF_RadarSendPoliceList(playerid);
    #pragma unused owner_faction
    return 1;
}

CMD:radar(playerid, params[])
{
    new limit;
    if(sscanf(params, "d", limit)) return SendErr(playerid, "/radar [лимит 40-160]");
    return CEF_RadarPlace(playerid, limit);
}

CMD:radars(playerid, params[])
{
    #pragma unused params
    if(!CEF_RadarIsManager(playerid)) return SendErr(playerid, "Список радаров доступен полиции.");
    return CEF_RadarSendPoliceList(playerid);
}

public CEF_FinesCanRegisterVehicle(playerid)
{
    if(!gCefFinesLoaded[playerid])
    {
        CEFC_Notify(playerid, "Подождите, данные штрафов ещё загружаются.", "hint");
        return 0;
    }
    if(gCefFineN[playerid] > CEF_FINE_WANTED_COUNT || gCefFineSum[playerid] > CEF_FINE_WANTED_SUM)
    {
        CEFC_Notify(playerid, "Сначала оплатите неоплаченные штрафы.", "error");
        return 0;
    }
    return 1;
}



stock Float:CEF_InventoryItemWeight(itemtype)
{
    switch(itemtype)
    {
        case 6: return 5.0;
        case 7: return 2.0;
        case 8: return 0.5;
        case 9: return 1.0;
        case 10: return 0.3;
        case 11: return 0.5;
        case 12: return 4.0;
        case 13: return 0.2;
    }
    return 0.5;
}

stock Float:CEF_InventoryWeight(playerid)
{
    new Float:total = 0.0;
    for(new i = 0; i < MAX_ITEMS; i++)
        if(IT[playerid][i][iType] > 0 && IT[playerid][i][iAmount] > 0)
            total += CEF_InventoryItemWeight(IT[playerid][i][iType]) * IT[playerid][i][iAmount];
    return total;
}

stock CEF_InventoryItemType(itemtype)
{
    switch(itemtype)
    {
        case 6, 7, 8, 9, 10, 11: return 1;
        case 12, 13: return 2;
    }
    return 0;
}

stock CEF_InventoryItemName(itemtype, dest[], size)
{
    if(itemtype > 0 && itemtype < sizeof(Item)) format(dest, size, "%s", Item[itemtype][itemName]);
    else if(itemtype > 0) format(dest, size, "Одежда %d", itemtype);
    else format(dest, size, "Неизвестный предмет");
    return 1;
}

stock CEF_InventoryItemIcon(itemtype, dest[], size)
{
    switch(itemtype)
    {
        case 6, 9: format(dest, size, "fuel");
        case 7: format(dest, size, "repair");
        case 8: format(dest, size, "medkit");
        case 10: format(dest, size, "food");
        case 11: format(dest, size, "water");
        case 12: format(dest, size, "armor");
        case 13: format(dest, size, "mask");
        default: format(dest, size, "item");
    }
    return 1;
}

stock Float:CEF_InventoryMaxWeight(playerid)
{
    #pragma unused playerid
    return CEF_INV_MAX_WEIGHT;
}

stock CEF_InventoryBuildPayload(playerid, dest[], size)
{
    new Float:weight = CEF_InventoryWeight(playerid);
    new items[6200], part[360], name[64], icon[24], desc[128], first = 1;
    items = "[";
    for(new i = 0; i < MAX_ITEMS; i++)
    {
        new itemtype = IT[playerid][i][iType];
        new count = IT[playerid][i][iAmount];
        if(itemtype <= 0 || count <= 0) continue;
        CEF_InventoryItemName(itemtype, name, sizeof name);
        CEF_InventoryItemIcon(itemtype, icon, sizeof icon);
        format(desc, sizeof desc, "%s", name);
        new escName[128], escIcon[48], escDesc[256];
        CEF_JsonEscape(name, escName, sizeof escName);
        CEF_JsonEscape(icon, escIcon, sizeof escIcon);
        CEF_JsonEscape(desc, escDesc, sizeof escDesc);
        format(part, sizeof part,
            "%s{\"slot\":%d,\"id\":%d,\"name\":\"%s\",\"count\":%d,\"weight\":%.1f,\"icon\":\"%s\",\"type\":\"%s\",\"description\":\"%s\"}",
            first ? "" : ",", i, itemtype, escName, count,
            CEF_InventoryItemWeight(itemtype), escIcon,
            CEF_InventoryItemType(itemtype) == 1 ? "use" : (CEF_InventoryItemType(itemtype) == 2 ? "equip" : "item"), escDesc);
        if(strlen(items) + strlen(part) + 2 >= sizeof items) break;
        strcat(items, part);
        first = 0;
    }
    strcat(items, "]");
    return format(dest, size,
        "{\"slots\":%d,\"weight\":%.1f,\"maxweight\":%.1f,\"money\":%d,\"items\":%s,\"skin\":%d,\"clothes\":{\"skin\":%d,\"accessories\":[]}}",
        MAX_ITEMS, weight, CEF_InventoryMaxWeight(playerid), PI[playerid][pCash], items,
        GetPlayerSkin(playerid), GetPlayerSkin(playerid));
}

stock CEF_InventorySendOpen(playerid)
{
    new json[8192];
    CEF_InventoryBuildPayload(playerid, json, sizeof json);
    CEF_Send(playerid, "cef_inventory_open", json);
    return 1;
}

stock CEF_InventoryUpdate(playerid)
{
    new json[8192];
    if(!gCefInventoryRouteOpen[playerid]) return 0;
    CEF_InventoryBuildPayload(playerid, json, sizeof json);
    CEF_Send(playerid, "cef_inventory_update", json);
    return 1;
}

public CEF_InventoryOpen(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) || !PT[playerid][pLogged]) return 0;
    if(gCefInventoryRouteOpen[playerid])
    {
        CEF_InventoryUpdate(playerid);
        if(!gCefInventoryItemsLoaded[playerid]) CEF_InvSync(playerid);
        return 1;
    }
    if(!gCefInventoryItemsLoaded[playerid]) gCefInventoryPendingOpen[playerid] = true;
    if(gCefFinesOpen[playerid] || gCefFinesPendingOpen[playerid]) CEF_FinesClose(playerid);
    if(gCefRadarManageOpen[playerid]) CEF_RadarManageClose(playerid);
    if(gCefAdminPanelOpen[playerid]) CEF_AdminPanelClose(playerid);
    if(gCefSupportPanelOpen[playerid]) CEF_SupportClose(playerid);
    if(gCefCaseActive[playerid] || gCefCasePending[playerid]) CEF_CaseCloseUi(playerid);
    if(gCefMenuOpen[playerid])
    {
        CEF_SendEmpty(playerid, "menu_close");
        CEFC_OnMenuClosed(playerid);
    }
    if(gCefcDialogId[playerid] != -1) CEFC_DialogClose(playerid);
    if(gCefChatInput[playerid]) CEFC_ChatCloseInput(playerid);
    CEF_MarkPlayerReady(playerid);
    CEF_Show(playerid, false);
    CEFC_MenuBegin(playerid);
    gCefInventoryRouteOpen[playerid] = true;
    GetPlayerFacingAngle(playerid, gCefInventoryFacing[playerid]);
    printf("[CEF-INV] %d open loaded=%d", playerid, gCefInventoryItemsLoaded[playerid]);
    CEF_Send(playerid, "menu_open", "{\"tab\":2}");
    CEF_InventorySendOpen(playerid);
    CEF_InvSync(playerid);
    CEF_Focus(playerid, true);
    return 1;
}

stock CEF_InventoryClose(playerid, bool:notifyClient = false)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS) return 0;
    gCefInventoryPendingOpen[playerid] = false;
    if(!gCefInventoryRouteOpen[playerid]) return 0;
    gCefInventoryRouteOpen[playerid] = false;
    printf("[CEF-INV] %d close notify=%d", playerid, notifyClient);
    CEF_SendEmpty(playerid, "menu_close");
    if(notifyClient) CEF_SendEmpty(playerid, "cef_inventory_close");
    CEFC_OnMenuClosed(playerid);
    return 1;
}

stock CEF_InventoryToggle(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) || !PT[playerid][pLogged]) return 0;
    if(gCefInventoryRouteOpen[playerid]) return CEF_InventoryClose(playerid, true);
    return CEF_InventoryOpen(playerid);
}

public CEF_InventoryOnDataReady(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid)) return 0;
    gCefInventoryItemsLoaded[playerid] = true;
    if(gCefInventoryPendingOpen[playerid] && PT[playerid][pLogged])
    {
        gCefInventoryPendingOpen[playerid] = false;
        if(gCefInventoryRouteOpen[playerid]) CEF_InvSync(playerid);
        else CEF_InventoryOpen(playerid);
    }
    else if(gCefInventoryRouteOpen[playerid]) CEF_InvSync(playerid);
    return 1;
}

public CEF_InventoryAfterAction(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !gCefInventoryRouteOpen[playerid]) return 0;
    return CEF_InventoryUpdate(playerid);
}

stock CEF_InventoryRotate(playerid, dir)
{
    if(!CEF_InventoryCanInteract(playerid) || dir == 0) return 0;
    gCefInventoryFacing[playerid] += (dir > 0) ? 15.0 : -15.0;
    if(gCefInventoryFacing[playerid] >= 360.0) gCefInventoryFacing[playerid] -= 360.0;
    if(gCefInventoryFacing[playerid] < 0.0) gCefInventoryFacing[playerid] += 360.0;
    SetPlayerFacingAngle(playerid, gCefInventoryFacing[playerid]);
    CEFC_MenuCamApply(playerid);
    CEFC_MenuStand(playerid);
    return 1;
}

stock CEF_InventoryCanInteract(playerid)
{
    return (playerid >= 0 && playerid < MAX_PLAYERS && IsPlayerConnected(playerid) && PT[playerid][pLogged] && gCefInventoryItemsLoaded[playerid] && gCefInventoryRouteOpen[playerid]);
}

stock CEF_InventoryTakeFromSlot(playerid, slot, count)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || slot < 0 || slot >= MAX_ITEMS || count <= 0) return 0;
    if(IT[playerid][slot][iType] <= 0 || IT[playerid][slot][iType] >= sizeof(Item) || IT[playerid][slot][iAmount] < count) return 0;
    IT[playerid][slot][iAmount] -= count;
    if(IT[playerid][slot][iAmount] <= 0)
    {
        IT[playerid][slot][iID] = 0;
        IT[playerid][slot][iType] = 0;
        IT[playerid][slot][iAmount] = 0;
    }
    CEF_InventoryCountSlots(playerid);
    return 1;
}

stock CEF_InventoryDoUse(playerid, slot)
{
    if(!CEF_InventoryCanInteract(playerid)) return 0;
    if(slot < 0 || slot >= MAX_ITEMS || IT[playerid][slot][iType] <= 0 || IT[playerid][slot][iType] >= sizeof(Item) || IT[playerid][slot][iAmount] <= 0)
        return CEFC_Notify(playerid, "В этом слоте нет предмета.", "hint");
    return CEF_OpsInvUse(playerid, IT[playerid][slot][iType], slot);
}

stock CEF_InventoryDropCreate(playerid, itemtype, count, &drop_slot)
{
    new slot = -1, Float:x, Float:y, Float:z, name[64], label[96];
    drop_slot = -1;
    for(new i = 0; i < CEF_DROP_MAX; i++)
        if(gCefDrops[i][cdPickup] == STREAMER_TAG_PICKUP:-1) { slot = i; break; }
    if(slot < 0 || itemtype <= 0 || itemtype >= sizeof(Item) || count <= 0) return 0;
    GetPlayerPos(playerid, x, y, z);
    new world = GetPlayerVirtualWorld(playerid), interior = GetPlayerInterior(playerid);
    CEF_InventoryItemName(itemtype, name, sizeof name);
    format(label, sizeof label, "%s x%d", name, count);
    gCefDrops[slot][cdPickup] = CreateDynamicPickup(1279, 3, x, y, z - 0.5, world, interior, -1, 80.0);
    if(gCefDrops[slot][cdPickup] == STREAMER_TAG_PICKUP:-1) return 0;
    gCefDrops[slot][cdLabel] = CreateDynamic3DTextLabel(label, 0xD9B96EFF, x, y, z, 5.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, world, interior);
    gCefDrops[slot][cdType] = itemtype;
    gCefDrops[slot][cdAmount] = count;
    gCefDrops[slot][cdExpires] = gettime() + CEF_DROP_LIFETIME;
    gCefDrops[slot][cdWorld] = world;
    gCefDrops[slot][cdInterior] = interior;
    drop_slot = slot;
    return 1;
}

stock CEF_InventoryDropDestroy(slot)
{
    if(slot < 0 || slot >= CEF_DROP_MAX || gCefDrops[slot][cdPickup] == STREAMER_TAG_PICKUP:-1) return 0;
    if(IsValidDynamicPickup(gCefDrops[slot][cdPickup])) DestroyDynamicPickup(gCefDrops[slot][cdPickup]);
    if(IsValidDynamic3DTextLabel(gCefDrops[slot][cdLabel])) DestroyDynamic3DTextLabel(gCefDrops[slot][cdLabel]);
    gCefDrops[slot][cdPickup] = STREAMER_TAG_PICKUP:-1;
    gCefDrops[slot][cdLabel] = Text3D:INVALID_3DTEXT_ID;
    gCefDrops[slot][cdType] = 0;
    gCefDrops[slot][cdAmount] = 0;
    gCefDrops[slot][cdExpires] = 0;
    return 1;
}

public CEF_InventoryDropTick()
{
    new now = gettime();
    for(new i = 0; i < CEF_DROP_MAX; i++)
        if(gCefDrops[i][cdPickup] != STREAMER_TAG_PICKUP:-1 && gCefDrops[i][cdExpires] <= now)
            CEF_InventoryDropDestroy(i);
    return 1;
}

public CEF_InventoryPickup(playerid, STREAMER_TAG_PICKUP:pickupid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) || !PT[playerid][pLogged] || !gCefInventoryItemsLoaded[playerid]) return 0;
    for(new i = 0; i < CEF_DROP_MAX; i++)
    {
        if(gCefDrops[i][cdPickup] != pickupid) continue;
        if(GetPlayerVirtualWorld(playerid) != gCefDrops[i][cdWorld] || GetPlayerInterior(playerid) != gCefDrops[i][cdInterior]) return 1;
        new itemtype = gCefDrops[i][cdType], count = gCefDrops[i][cdAmount];
        if(itemtype <= 0 || itemtype >= sizeof(Item) || count <= 0) return 1;
        if(!CEF_InvCanGive(playerid, itemtype, count))
        {
            CEFC_Notify(playerid, "В инвентаре недостаточно места.", "error");
            return 1;
        }
        if(!GiveItem(playerid, itemtype, count)) return 1;
        SavePlayerInventory(playerid);
        CEF_InventoryDropDestroy(i);
        CEF_InventoryUpdate(playerid);
        CEFC_Notify(playerid, "Предмет поднят.", "success");
        return 1;
    }
    return 0;
}

stock CEF_InventoryDoDrop(playerid, slot, count)
{
    if(!CEF_InventoryCanInteract(playerid)) return 0;
    if(slot < 0 || slot >= MAX_ITEMS || count <= 0 || IT[playerid][slot][iType] <= 0 || IT[playerid][slot][iType] >= sizeof(Item) || count > IT[playerid][slot][iAmount])
        return CEFC_Notify(playerid, "Неверный слот или количество.", "error");
    new itemtype = IT[playerid][slot][iType], drop_slot;
    if(!CEF_InventoryDropCreate(playerid, itemtype, count, drop_slot)) return CEFC_Notify(playerid, "Нет свободного места для выброшенных предметов.", "error");
    if(!CEF_InventoryTakeFromSlot(playerid, slot, count))
    {
        CEF_InventoryDropDestroy(drop_slot);
        return CEFC_Notify(playerid, "Предмет уже недоступен.", "error");
    }
    SavePlayerInventory(playerid);
    CEF_InventoryUpdate(playerid);
    return CEFC_Notify(playerid, "Предмет выброшен.", "info");
}

stock Float:CEF_PlayerDistance(player1, player2)
{
    new Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2;
    GetPlayerPos(player1, x1, y1, z1);
    GetPlayerPos(player2, x2, y2, z2);
    return floatsqroot((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2) + (z1 - z2) * (z1 - z2));
}

stock CEF_InventoryDoGive(playerid, slot, count, targetid)
{
    if(!CEF_InventoryCanInteract(playerid)) return 0;
    if(slot < 0 || slot >= MAX_ITEMS || count <= 0 || IT[playerid][slot][iType] <= 0 || IT[playerid][slot][iType] >= sizeof(Item) || count > IT[playerid][slot][iAmount])
        return CEFC_Notify(playerid, "Неверный слот или количество.", "error");
    if(targetid < 0 || targetid >= MAX_PLAYERS || targetid == playerid || !IsPlayerConnected(targetid) || !PT[targetid][pLogged] || !gCefInventoryItemsLoaded[targetid])
        return CEFC_Notify(playerid, "Игрок не найден или его инвентарь загружается.", "error");
    if(GetPlayerVirtualWorld(targetid) != GetPlayerVirtualWorld(playerid) || GetPlayerInterior(targetid) != GetPlayerInterior(playerid) || CEF_PlayerDistance(playerid, targetid) > 3.0)
        return CEFC_Notify(playerid, "Игрок должен находиться рядом, не дальше 3 метров.", "error");
    new itemtype = IT[playerid][slot][iType];
    if(!CEF_InvCanGive(targetid, itemtype, count))
        return CEFC_Notify(playerid, "У получателя недостаточно места.", "error");
    if(!CEF_InventoryTakeFromSlot(playerid, slot, count))
        return CEFC_Notify(playerid, "Предмет уже недоступен.", "error");
    if(!GiveItem(targetid, itemtype, count))
    {
        GiveItem(playerid, itemtype, count);
        return CEFC_Notify(playerid, "Передать предмет не удалось.", "error");
    }
    SavePlayerInventory(playerid);
    SavePlayerInventory(targetid);
    CEF_InventoryUpdate(playerid);
    CEF_InventoryUpdate(targetid);
    CEFC_Notify(playerid, "Предмет передан.", "success");
    CEFC_Notify(targetid, "Вам передали предмет.", "info");
    return 1;
}

stock CEF_InventoryDoMove(playerid, from, to)
{
    if(!CEF_InventoryCanInteract(playerid)) return 0;
    if(from < 0 || from >= MAX_ITEMS || to < 0 || to >= MAX_ITEMS || from == to)
        return CEFC_Notify(playerid, "Неверный слот.", "error");
    new fromType = IT[playerid][from][iType], fromAmount = IT[playerid][from][iAmount];
    if(fromType <= 0 || fromType >= sizeof(Item) || fromAmount <= 0) return 0;
    new toType = IT[playerid][to][iType], toAmount = IT[playerid][to][iAmount];
    if(toType < 0 || toType >= sizeof(Item)) return 0;
    if(toType == 0)
    {
        IT[playerid][to][iType] = fromType;
        IT[playerid][to][iAmount] = fromAmount;
        IT[playerid][to][iID] = IT[playerid][from][iID];
        IT[playerid][from][iType] = 0;
        IT[playerid][from][iAmount] = 0;
        IT[playerid][from][iID] = 0;
    }
    else if(toType == fromType)
    {
        if(toAmount <= 0 || toAmount + fromAmount > Item[fromType][itemMaxAmount])
            return CEFC_Notify(playerid, "В целевом слоте недостаточно места.", "hint");
        IT[playerid][to][iAmount] += fromAmount;
        IT[playerid][from][iType] = 0;
        IT[playerid][from][iAmount] = 0;
        IT[playerid][from][iID] = 0;
    }
    else
    {
        new oldId = IT[playerid][from][iID];
        IT[playerid][from][iType] = toType;
        IT[playerid][from][iAmount] = toAmount;
        IT[playerid][from][iID] = IT[playerid][to][iID];
        IT[playerid][to][iType] = fromType;
        IT[playerid][to][iAmount] = fromAmount;
        IT[playerid][to][iID] = oldId;
    }
    CEF_InventoryCountSlots(playerid);
    SavePlayerInventory(playerid);
    CEF_InventoryUpdate(playerid);
    return 1;
}

stock CEF_InventoryOpenEvent(playerid, const arguments[])
{
    return CEF_InventoryOpen(playerid);
}

forward CEVC_FinesPay(playerid, const arguments[]);
public CEVC_FinesPay(playerid, const arguments[]) { return CEF_FinesPayOne(playerid, CEF_EcoFindInt(arguments, "id")); }
forward CEVC_FinesPayAll(playerid, const arguments[]);
public CEVC_FinesPayAll(playerid, const arguments[])
{
    #pragma unused arguments
    return CEF_FinesPayAll(playerid);
}
forward CEVC_FinesClose(playerid, const arguments[]);
public CEVC_FinesClose(playerid, const arguments[])
{
    #pragma unused arguments
    return CEF_FinesClose(playerid);
}

forward CEVC_RadarPlace(playerid, const arguments[]);
public CEVC_RadarPlace(playerid, const arguments[]) { return CEF_RadarPlace(playerid, CEF_EcoFindInt(arguments, "limit")); }
forward CEVC_RadarRemove(playerid, const arguments[]);
public CEVC_RadarRemove(playerid, const arguments[]) { return CEF_RadarRemove(playerid, CEF_EcoFindInt(arguments, "id")); }
forward CEVC_RadarClose(playerid, const arguments[]);
public CEVC_RadarClose(playerid, const arguments[])
{
    #pragma unused arguments
    return CEF_RadarManageClose(playerid);
}

forward CEVC_InventoryUse(playerid, const arguments[]);
public CEVC_InventoryUse(playerid, const arguments[]) { return CEF_InventoryDoUse(playerid, CEF_EcoFindInt(arguments, "slot")); }
forward CEVC_InventoryDrop(playerid, const arguments[]);
public CEVC_InventoryDrop(playerid, const arguments[]) { return CEF_InventoryDoDrop(playerid, CEF_EcoFindInt(arguments, "slot"), CEF_EcoFindInt(arguments, "count")); }
forward CEVC_InventoryGive(playerid, const arguments[]);
public CEVC_InventoryGive(playerid, const arguments[]) { return CEF_InventoryDoGive(playerid, CEF_EcoFindInt(arguments, "slot"), CEF_EcoFindInt(arguments, "count"), CEF_EcoFindInt(arguments, "targetid")); }
forward CEVC_InventoryMove(playerid, const arguments[]);
public CEVC_InventoryMove(playerid, const arguments[]) { return CEF_InventoryDoMove(playerid, CEF_EcoFindInt(arguments, "from"), CEF_EcoFindInt(arguments, "to")); }
forward CEVC_InventoryRotate(playerid, const arguments[]);
public CEVC_InventoryRotate(playerid, const arguments[]) { return CEF_InventoryRotate(playerid, CEF_EcoFindInt(arguments, "dir")); }
forward CEVC_InventoryClosed(playerid, const arguments[]);
public CEVC_InventoryClosed(playerid, const arguments[])
{
    #pragma unused arguments
    return CEF_InventoryClose(playerid, false);
}
