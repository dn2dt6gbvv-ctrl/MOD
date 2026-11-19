  
                                                     
                                                    
                                                            
   

#if defined _cef_cases_included
	#endinput
#endif
#define _cef_cases_included

#include <a_samp>
#include <cef>
#include <a_mysql>

                                      
#define CEF_INV_BROWSER_ID      9801
#define CEF_CASE_BROWSER_ID     9800
#define MAX_INVENTORY_SLOTS     40
#define MAX_CASE_ITEMS          10
#define MAX_CASES               15

#define ITEM_TYPE_NONE          0
#define ITEM_TYPE_WEAPON        1
#define ITEM_TYPE_DRUGS         2
#define ITEM_TYPE_FOOD          3
#define ITEM_TYPE_PHONE         4
#define ITEM_TYPE_ACCESSORY     5
#define ITEM_TYPE_MONEY         6
#define ITEM_TYPE_VEHICLE       7
#define ITEM_TYPE_SKIN          8
#define ITEM_TYPE_VIP           9
#define ITEM_TYPE_CASE          10

#define RARITY_COMMON           0
#define RARITY_UNCOMMON         1
#define RARITY_RARE             2
#define RARITY_EPIC             3
#define RARITY_LEGENDARY        4
#define RARITY_MYTHIC           5

                                                  
static CefMySQLHandle;
static CefInvReady[MAX_PLAYERS];
static CefCaseReady[MAX_PLAYERS];
static InventoryOpen[MAX_PLAYERS];
static LastCaseID[MAX_PLAYERS];

static InvID[MAX_PLAYERS][MAX_INVENTORY_SLOTS];
static InvItemID[MAX_PLAYERS][MAX_INVENTORY_SLOTS];
static InvName[MAX_PLAYERS][MAX_INVENTORY_SLOTS][64];
static InvType[MAX_PLAYERS][MAX_INVENTORY_SLOTS];
static InvParam[MAX_PLAYERS][MAX_INVENTORY_SLOTS];
static InvAmount[MAX_PLAYERS][MAX_INVENTORY_SLOTS];
static InvRarity[MAX_PLAYERS][MAX_INVENTORY_SLOTS];
static InvCategory[MAX_PLAYERS][MAX_INVENTORY_SLOTS][16];

static TotalCases;

static CaseName[MAX_CASES][64];
static CasePrice[MAX_CASES];
static CaseType[MAX_CASES];
static CaseRarity[MAX_CASES][16];
static CaseRarityKey[MAX_CASES][12];
static CaseImage[MAX_CASES][128];
static CaseDesc[MAX_CASES][128];
static CaseItemCount[MAX_CASES];
static CaseItems[MAX_CASES][MAX_CASE_ITEMS][3];

                                     
forward OnCefInvReady(player_id, success);
forward OnCefCaseReady(player_id, success);
forward OnInventoryLoaded(playerid);
forward OnCasesDataLoaded();
forward OnCefInvAction(player_id, const event[], const data[]);
forward OnCefInvClose(player_id, const event[], const data[]);
forward OnCefCaseOpenReq(player_id, const event[], const data[]);
forward OnCefCaseClaim(player_id, const event[], const data[]);
forward OnCefCaseClose(player_id, const event[], const data[]);

                                          
stock CefCases_Init(mysql_handle)
{
    CefMySQLHandle = mysql_handle;
    TotalCases = 0;
    mysql_tquery(CefMySQLHandle, "SELECT * FROM `cases_data`", "OnCasesDataLoaded");
    printf("[CEF Cases] Init OK, MySQL handle: %d", mysql_handle);
    return 1;
}

public OnCasesDataLoaded()
{
    new rows = cache_num_rows();
    TotalCases = (rows > MAX_CASES) ? MAX_CASES : rows;

    for(new i = 0; i < TotalCases; i++)
    {
        cache_get_field_content(i, "case_name", CaseName[i], CefMySQLHandle, 64);
        CasePrice[i] = cache_get_field_content_int(i, "case_price", CefMySQLHandle);
        CaseType[i] = cache_get_field_content_int(i, "case_type", CefMySQLHandle);
        cache_get_field_content(i, "case_rarity", CaseRarity[i], CefMySQLHandle, 16);
        cache_get_field_content(i, "case_rarity_key", CaseRarityKey[i], CefMySQLHandle, 12);
        cache_get_field_content(i, "case_image", CaseImage[i], CefMySQLHandle, 128);
        cache_get_field_content(i, "case_desc", CaseDesc[i], CefMySQLHandle, 128);

        new items_str[512];
        cache_get_field_content(i, "items", items_str, CefMySQLHandle, sizeof(items_str));

        new idx = 0, part[32], p1, p2;
        CaseItemCount[i] = 0;
        while(idx < strlen(items_str) && CaseItemCount[i] < MAX_CASE_ITEMS)
        {
            new pi = 0;
            while(items_str[idx] != ',' && items_str[idx] != '\0' && pi < 30)
                part[pi++] = items_str[idx++];
            part[pi] = '\0';
            if(items_str[idx] == ',') idx++;

            p1 = -1;
            for(new j = 0; j < pi; j++) { if(part[j] == ':') { p1 = j; break; } }
            if(p1 == -1) continue;
            part[p1] = '\0';
            p2 = -1;
            for(new j = p1 + 1; j < pi; j++) { if(part[j] == ':') { p2 = j; break; } }

            CaseItems[i][CaseItemCount[i]][0] = strval(part);
            CaseItems[i][CaseItemCount[i]][1] = strval(part[p1 + 1]);
            CaseItems[i][CaseItemCount[i]][2] = (p2 != -1) ? strval(part[p2 + 1]) : 0;
            CaseItemCount[i]++;
        }
    }
    printf("[CEF Cases] Loaded %d cases", TotalCases);
    return 1;
}

                                               
stock CefCases_LoadInventory(playerid, player_mysqli_id)
{
    if(!IsPlayerConnected(playerid)) return 0;
    for(new i = 0; i < MAX_INVENTORY_SLOTS; i++)
    {
        InvID[playerid][i] = 0;
        InvItemID[playerid][i] = 0;
        InvName[playerid][i][0] = '\0';
        InvType[playerid][i] = ITEM_TYPE_NONE;
        InvParam[playerid][i] = 0;
        InvAmount[playerid][i] = 0;
        InvRarity[playerid][i] = RARITY_COMMON;
        format(InvCategory[playerid][i], 16, "other");
    }
    new query[128];
    format(query, sizeof(query), "SELECT * FROM `inventory` WHERE `owner_id` = '%d' ORDER BY `id` ASC LIMIT %d",
        player_mysqli_id, MAX_INVENTORY_SLOTS);
    SetPVarInt(playerid, "CefMySQLID", player_mysqli_id);
    mysql_tquery(CefMySQLHandle, query, "OnInventoryLoaded", "i", playerid);
    return 1;
}

public OnInventoryLoaded(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;
    new rows = cache_num_rows();
    new count = (rows > MAX_INVENTORY_SLOTS) ? MAX_INVENTORY_SLOTS : rows;
    for(new i = 0; i < count; i++)
    {
        InvID[playerid][i] = cache_get_field_content_int(i, "id", CefMySQLHandle);
        InvItemID[playerid][i] = cache_get_field_content_int(i, "item_id", CefMySQLHandle);
        cache_get_field_content(i, "item_name", InvName[playerid][i], CefMySQLHandle, 64);
        InvType[playerid][i] = cache_get_field_content_int(i, "item_type", CefMySQLHandle);
        InvParam[playerid][i] = cache_get_field_content_int(i, "item_param", CefMySQLHandle);
        InvAmount[playerid][i] = cache_get_field_content_int(i, "item_amount", CefMySQLHandle);
        InvRarity[playerid][i] = cache_get_field_content_int(i, "item_rarity", CefMySQLHandle);
        cache_get_field_content(i, "item_category", InvCategory[playerid][i], CefMySQLHandle, 16);
    }
    return 1;
}

                                            
public OnCefInvReady(player_id, success)
{
    CefInvReady[player_id] = success;
    if(success)
    {
        cef_subscribe("page:inventoryAction", "OnCefInvAction");
        cef_subscribe("page:inventoryClose", "OnCefInvClose");
        cef_subscribe("page:caseOpenRequested", "OnCefCaseOpenReq");
        cef_subscribe("page:caseClaim", "OnCefCaseClaim");
        cef_subscribe("page:caseClose", "OnCefCaseClose");
    }
    return 1;
}

public OnCefCaseReady(player_id, success)
{
    CefCaseReady[player_id] = success;
    return 1;
}

stock CefCases_OnPlayerConnect(playerid)
{
    CefInvReady[playerid] = 0;
    CefCaseReady[playerid] = 0;
    InventoryOpen[playerid] = false;
    LastCaseID[playerid] = -1;
    return 1;
}

                                               
stock CefCases_ShowInventory(playerid, player_name[], player_money)
{
    if(!CefInvReady[playerid]) return SendClientMessage(playerid, 0xFF0000FF, "CEF not loaded.");
    if(InventoryOpen[playerid]) return SendClientMessage(playerid, 0xFF0000FF, "Already open.");
    InventoryOpen[playerid] = true;

    new json[8192], bool:first = true;
    format(json, sizeof(json), "{\"type\":\"PAGE_INVENTORY_SHOW\",\"items\":[");

    for(new i = 0; i < MAX_INVENTORY_SLOTS; i++)
    {
        if(InvItemID[playerid][i] == 0) continue;
        if(!first) strcat(json, ",");
        first = false;

        new rarityKey[12], category[16], rarityLabel[16];
        CefCases_RarityKey(InvRarity[playerid][i], rarityKey);
        CefCases_CategoryName(InvType[playerid][i], category);
        CefCases_RarityLabel(InvRarity[playerid][i], rarityLabel);

        if(InvType[playerid][i] == ITEM_TYPE_CASE)
        {
            new cid = InvParam[playerid][i];
            new img[128] = "assets/cases/01_royal_seal.png";
            if(cid >= 0 && cid < TotalCases && CaseImage[cid][0] != '\0')
                format(img, sizeof(img), "%s", CaseImage[cid]);

            format(json, sizeof(json),
                "%s{\"id\":\"inv-%d\",\"inventoryId\":\"inv-%d\",\"caseId\":\"%d\",\"itemType\":\"case\",\"category\":\"cases\",\"name\":\"%s\",\"rarity\":\"%s\",\"rarityKey\":\"%s\",\"image\":\"%s\",\"count\":%d,\"weight\":0.2,\"detail\":\"Кейс\",\"drops\":[",
                json, InvID[playerid][i], InvID[playerid][i], cid,
                InvName[playerid][i], rarityLabel, rarityKey, img, InvAmount[playerid][i]);

            if(cid >= 0 && cid < TotalCases)
            {
                for(new d = 0; d < CaseItemCount[cid]; d++)
                {
                    if(d > 0) strcat(json, ",");
                    new dropName[64], dropRarityKey[12];
                    CefCases_GetItemName(CaseItems[cid][d][0], dropName);
                    CefCases_RarityKey(CaseItems[cid][d][2], dropRarityKey);
                    format(json, sizeof(json), "%s{\"name\":\"%s\",\"rarityKey\":\"%s\",\"weight\":%d}",
                        json, dropName, dropRarityKey, CaseItems[cid][d][1]);
                }
            }
            strcat(json, "]}");
        }
        else
        {
            new kind[16];
            CefCases_ItemKindStr(InvType[playerid][i], kind);
            format(json, sizeof(json),
                "%s{\"id\":\"inv-%d\",\"inventoryId\":\"inv-%d\",\"itemType\":\"item\",\"category\":\"%s\",\"name\":\"%s\",\"rarity\":\"%s\",\"rarityKey\":\"%s\",\"kind\":\"%s\",\"count\":%d,\"weight\":0.5,\"detail\":\"Предмет\"}",
                json, InvID[playerid][i], InvID[playerid][i],
                category, InvName[playerid][i], rarityLabel, rarityKey, kind, InvAmount[playerid][i]);
        }
    }

    strcat(json, "],\"player\":{\"name\":\"");
    strcat(json, player_name);
    new moneyStr[64];
    format(moneyStr, sizeof(moneyStr), "\",\"money\":%d,\"maxWeight\":50}}", player_money);
    strcat(json, moneyStr);

    cef_emit_event(playerid, "PAGE_INVENTORY_SHOW", CEFSTR(json));
    cef_create_browser(playerid, CEF_INV_BROWSER_ID, "PAGE_ROLE_PLAY_Inventory_CEF/index.html?cef=1", false, true);
    cef_focus_browser(playerid, CEF_INV_BROWSER_ID, true);
    SelectTextDraw(playerid, 0xFFFFFFFF);
    return 1;
}

stock CefCases_CloseInventory(playerid)
{
    InventoryOpen[playerid] = false;
    cef_destroy_browser(playerid, CEF_INV_BROWSER_ID);
    cef_focus_browser(playerid, CEF_INV_BROWSER_ID, false);
    CancelSelectTextDraw(playerid);
    return 1;
}

                                        
public OnCefInvAction(player_id, const event[], const data[])
{
    new action[16] = "", itemIdStr[32] = "";
    new pos = strfind(data, "\"action\"");
    if(pos != -1)
    {
        new sub[64];
        strmid(sub, data, pos, pos+60, sizeof(sub));
        new s = strfind(sub, ":\"");
        if(s != -1)
        {
            new e = strfind(sub[s+2], "\"");
            if(e != -1 && e < 15) strmid(action, sub, s+2, s+2+e, sizeof(action));
        }
    }
    pos = strfind(data, "\"itemId\"");
    if(pos != -1)
    {
        new sub[64];
        strmid(sub, data, pos, pos+60, sizeof(sub));
        new s = strfind(sub, "inv-");
        if(s != -1)
        {
            new e = strfind(sub[s+1], "\"");
            if(e != -1 && e < 30) strmid(itemIdStr, sub, s, s+e, sizeof(itemIdStr));
        }
    }
    new slot = CefCases_FindSlotByID(player_id, itemIdStr);
    if(slot == -1) return 1;
    if(!strcmp(action, "use", true) || !strcmp(action, "equip", true))
        CefCases_UseItem(player_id, slot);
    else if(!strcmp(action, "drop", true))
        CefCases_DropItem(player_id, slot);
    return 1;
}

public OnCefInvClose(player_id, const event[], const data[])
{
    CefCases_CloseInventory(player_id);
    return 1;
}

public OnCefCaseOpenReq(player_id, const event[], const data[])
{
    new caseIdStr[8] = "", invItemId[32] = "";
    new pos = strfind(data, "\"caseId\"");
    if(pos != -1)
    {
        new sub[64];
        strmid(sub, data, pos, pos+60, sizeof(sub));
        new s = strfind(sub, ":\"");
        if(s != -1)
        {
            new e = strfind(sub[s+2], "\"");
            if(e != -1 && e < 7) strmid(caseIdStr, sub, s+2, s+2+e, sizeof(caseIdStr));
        }
    }
    pos = strfind(data, "\"inventoryItemId\"");
    if(pos != -1)
    {
        new sub[64];
        strmid(sub, data, pos, pos+60, sizeof(sub));
        new s = strfind(sub, "inv-");
        if(s != -1)
        {
            new e = strfind(sub[s+1], "\"");
            if(e != -1 && e < 30) strmid(invItemId, sub, s, s+e, sizeof(invItemId));
        }
    }
    new caseid = strval(caseIdStr);
    if(caseid < 0 || caseid >= TotalCases) return 1;
    LastCaseID[player_id] = caseid;

    new total_chance = 0;
    for(new i = 0; i < CaseItemCount[caseid]; i++)
        total_chance += CaseItems[caseid][i][1];
    if(total_chance <= 0) return 1;

    new rand = random(total_chance);
    new cumulative = 0, won_item = 0, won_rarity = RARITY_COMMON;
    for(new i = 0; i < CaseItemCount[caseid]; i++)
    {
        cumulative += CaseItems[caseid][i][1];
        if(rand < cumulative)
        {
            won_item = CaseItems[caseid][i][0];
            won_rarity = CaseItems[caseid][i][2];
            break;
        }
    }
    SetPVarInt(player_id, "CefWonItem", won_item);
    SetPVarInt(player_id, "CefWonRarity", won_rarity);
    SetPVarString(player_id, "CefInvItemId", invItemId);

    new rarityKey[12], itemName[64], itemKind[16], itemVal[32];
    CefCases_RarityKey(won_rarity, rarityKey);
    CefCases_GetItemName(won_item, itemName);
    CefCases_ItemKind(won_item, itemKind);
    CefCases_ItemValue(won_item, itemVal);
    new json[512];
    format(json, sizeof(json),
        "{\"type\":\"PAGE_CASE_RESULT\",\"reward\":{\"name\":\"%s\",\"rarityKey\":\"%s\",\"kind\":\"%s\",\"value\":\"%s\"}}",
        itemName, rarityKey, itemKind, itemVal);
    cef_emit_event(player_id, "PAGE_CASE_RESULT", CEFSTR(json));
    return 1;
}

public OnCefCaseClaim(player_id, const event[], const data[])
{
    new won_item = GetPVarInt(player_id, "CefWonItem");
    if(won_item <= 0) return 1;

    CefCases_GiveItem(player_id, won_item, 1, GetPVarInt(player_id, "CefWonRarity"));

    new invItemId[32];
    GetPVarString(player_id, "CefInvItemId", invItemId, sizeof(invItemId));
    new slot = CefCases_FindSlotByID(player_id, invItemId);
    if(slot != -1 && InvType[player_id][slot] == ITEM_TYPE_CASE)
    {
        InvAmount[player_id][slot]--;
        if(InvAmount[player_id][slot] <= 0)
        {
            new query[128];
            format(query, sizeof(query), "DELETE FROM `inventory` WHERE `id` = '%d'", InvID[player_id][slot]);
            mysql_tquery(CefMySQLHandle, query);
            InvID[player_id][slot] = 0;
            InvItemID[player_id][slot] = 0;
        }
        else
        {
            new query[128];
            format(query, sizeof(query), "UPDATE `inventory` SET `item_amount` = '%d' WHERE `id` = '%d'",
                InvAmount[player_id][slot], InvID[player_id][slot]);
            mysql_tquery(CefMySQLHandle, query);
        }
    }
    new itemName[64];
    CefCases_GetItemName(won_item, itemName);
    new msg[128];
    format(msg, sizeof(msg), "Вы получили: %s", itemName);
    SendClientMessage(player_id, 0x33AA33FF, msg);
    SetPVarInt(player_id, "CefWonItem", 0);
    return 1;
}

public OnCefCaseClose(player_id, const event[], const data[]) { return 1; }

                                     
stock CefCases_GiveItem(playerid, itemid, amount, rarity)
{
    new slot = -1;
    for(new i = 0; i < MAX_INVENTORY_SLOTS; i++)
    {
        if(InvItemID[playerid][i] == itemid && InvAmount[playerid][i] > 0
           && InvType[playerid][i] != ITEM_TYPE_CASE)
        { slot = i; break; }
        if(InvItemID[playerid][i] == 0 && slot == -1) slot = i;
    }
    if(slot == -1)
    {
        SendClientMessage(playerid, 0xFF0000FF, "Инвентарь полон!");
        return 0;
    }
    new query[512];
    if(InvItemID[playerid][slot] == itemid)
    {
        InvAmount[playerid][slot] += amount;
        format(query, sizeof(query), "UPDATE `inventory` SET `item_amount` = '%d' WHERE `id` = '%d'",
            InvAmount[playerid][slot], InvID[playerid][slot]);
    }
    else
    {
        new itemName[64], category[16];
        CefCases_GetItemName(itemid, itemName);
        CefCases_CategoryName(CefCases_GetItemType(itemid), category);
        InvItemID[playerid][slot] = itemid;
        format(InvName[playerid][slot], 64, "%s", itemName);
        InvType[playerid][slot] = CefCases_GetItemType(itemid);
        InvParam[playerid][slot] = CefCases_GetItemParam(itemid);
        InvAmount[playerid][slot] = amount;
        InvRarity[playerid][slot] = rarity;
        format(InvCategory[playerid][slot], 16, "%s", category);
        format(query, sizeof(query),
            "INSERT INTO `inventory` (`owner_id`,`item_id`,`item_name`,`item_type`,`item_param`,`item_amount`,`item_rarity`,`item_category`,`item_weight`) VALUES ('%d','%d','%s','%d','%d','%d','%d','%s','0.5')",
            GetPVarInt(playerid, "CefMySQLID"), itemid, itemName,
            InvType[playerid][slot], InvParam[playerid][slot], amount, rarity, category);
    }
    mysql_tquery(CefMySQLHandle, query);
    return 1;
}

stock CefCases_UseItem(playerid, slot)
{
    if(slot < 0 || slot >= MAX_INVENTORY_SLOTS) return 0;
    if(InvItemID[playerid][slot] == 0)
    {
        SendClientMessage(playerid, 0xFF0000FF, "Пустой слот.");
        return 0;
    }
    switch(InvType[playerid][slot])
    {
        case ITEM_TYPE_WEAPON:
        {
            GivePlayerWeapon(playerid, InvParam[playerid][slot], 100);
            SendClientMessage(playerid, 0x33AA33FF, "Вы экипировали оружие.");
        }
        case ITEM_TYPE_FOOD:
        {
            new Float:hp; GetPlayerHealth(playerid, hp);
            SetPlayerHealth(playerid, hp + float(InvParam[playerid][slot]));
            SendClientMessage(playerid, 0x33AA33FF, "Вы поели.");
        }
        case ITEM_TYPE_MONEY:
        {
            GivePlayerMoney(playerid, InvParam[playerid][slot]);
            SendClientMessage(playerid, 0x33AA33FF, "Вы получили деньги.");
        }
        default:
        {
            SendClientMessage(playerid, 0xFFA500FF, "Этот предмет нельзя использовать.");
            return 0;
        }
    }
    CefCases_RemoveSlot(playerid, slot);
    return 1;
}

stock CefCases_DropItem(playerid, slot)
{
    if(slot < 0 || slot >= MAX_INVENTORY_SLOTS) return 0;
    if(InvItemID[playerid][slot] == 0)
    {
        SendClientMessage(playerid, 0xFF0000FF, "Пустой слот.");
        return 0;
    }
    CefCases_RemoveSlot(playerid, slot);
    SendClientMessage(playerid, 0x33AA33FF, "Вы выбросили предмет.");
    return 1;
}

stock CefCases_RemoveSlot(playerid, slot)
{
    new query[128];
    format(query, sizeof(query), "DELETE FROM `inventory` WHERE `id` = '%d'", InvID[playerid][slot]);
    mysql_tquery(CefMySQLHandle, query);
    InvID[playerid][slot] = 0;
    InvItemID[playerid][slot] = 0;
    InvName[playerid][slot][0] = '\0';
    InvType[playerid][slot] = ITEM_TYPE_NONE;
    InvParam[playerid][slot] = 0;
    InvAmount[playerid][slot] = 0;
    InvRarity[playerid][slot] = RARITY_COMMON;
    format(InvCategory[playerid][slot], 16, "other");
    return 1;
}

                                            
stock CefCases_FindSlotByID(playerid, const invIdStr[])
{
    new dbid = strval(invIdStr[4]);
    for(new i = 0; i < MAX_INVENTORY_SLOTS; i++)
        if(InvID[playerid][i] == dbid) return i;
    return -1;
}

stock CefCases_GetItemName(itemid, name[], size = sizeof(name))
{
    switch(itemid)
    {
        case 1: format(name, size, "Deagle");
        case 2: format(name, size, "Shotgun");
        case 3: format(name, size, "MP5");
        case 4: format(name, size, "AK-47");
        case 5: format(name, size, "M4");
        case 6: format(name, size, "Rifle");
        case 7: format(name, size, "Наркотики x10");
        case 8: format(name, size, "Наркотики x50");
        case 9: format(name, size, "Аптечка");
        case 10: format(name, size, "Бронежилет");
        case 11: format(name, size, "$10,000");
        case 12: format(name, size, "$50,000");
        case 13: format(name, size, "$100,000");
        case 14: format(name, size, "$500,000");
        case 15: format(name, size, "$1,000,000");
        case 16: format(name, size, "VIP Bronze");
        case 17: format(name, size, "VIP Silver");
        case 18: format(name, size, "VIP Gold");
        case 19: format(name, size, "Скин Premium");
        case 20: format(name, size, "Неон");
        default: format(name, size, "Предмет #%d", itemid);
    }
    return 1;
}

stock CefCases_GetItemType(itemid)
{
    switch(itemid)
    {
        case 1..6: return ITEM_TYPE_WEAPON;
        case 7..8: return ITEM_TYPE_DRUGS;
        case 9: return ITEM_TYPE_FOOD;
        case 10: return ITEM_TYPE_ACCESSORY;
        case 11..15: return ITEM_TYPE_MONEY;
        case 16..18: return ITEM_TYPE_VIP;
        case 19: return ITEM_TYPE_SKIN;
        case 20: return ITEM_TYPE_ACCESSORY;
    }
    return ITEM_TYPE_NONE;
}

stock CefCases_GetItemParam(itemid)
{
    switch(itemid)
    {
        case 1: return 24;
        case 2: return 25;
        case 3: return 29;
        case 4: return 30;
        case 5: return 31;
        case 6: return 33;
        case 7: return 10;
        case 8: return 50;
        case 9: return 50;
        case 10: return 100;
        case 11: return 10000;
        case 12: return 50000;
        case 13: return 100000;
        case 14: return 500000;
        case 15: return 1000000;
        case 16: return 1;
        case 17: return 2;
        case 18: return 3;
    }
    return 0;
}

stock CefCases_RarityKey(rarity, key[], size = sizeof(key))
{
    switch(rarity)
    {
        case RARITY_COMMON:    format(key, size, "common");
        case RARITY_UNCOMMON:  format(key, size, "uncommon");
        case RARITY_RARE:      format(key, size, "rare");
        case RARITY_EPIC:      format(key, size, "epic");
        case RARITY_LEGENDARY: format(key, size, "legendary");
        case RARITY_MYTHIC:    format(key, size, "mythic");
        default:               format(key, size, "common");
    }
    return 1;
}

stock CefCases_RarityLabel(rarity, label[], size = sizeof(label))
{
    switch(rarity)
    {
        case RARITY_COMMON:    format(label, size, "Обычный");
        case RARITY_UNCOMMON:  format(label, size, "Необычный");
        case RARITY_RARE:      format(label, size, "Редкий");
        case RARITY_EPIC:      format(label, size, "Эпический");
        case RARITY_LEGENDARY: format(label, size, "Легендарный");
        case RARITY_MYTHIC:    format(label, size, "Мифический");
        default:               format(label, size, "Обычный");
    }
    return 1;
}

stock CefCases_CategoryName(type, cat[], size = sizeof(cat))
{
    switch(type)
    {
        case ITEM_TYPE_WEAPON:    format(cat, size, "weapon");
        case ITEM_TYPE_ACCESSORY: format(cat, size, "accessory");
        case ITEM_TYPE_FOOD:      format(cat, size, "consumable");
        case ITEM_TYPE_DRUGS:     format(cat, size, "consumable");
        case ITEM_TYPE_CASE:      format(cat, size, "cases");
        default:                  format(cat, size, "other");
    }
    return 1;
}

stock CefCases_ItemKind(itemid, kind[], size = sizeof(kind))
{
    switch(itemid)
    {
        case 1..6: format(kind, size, "weapon");
        case 7..9: format(kind, size, "medkit");
        case 10: format(kind, size, "shield");
        case 11..15: format(kind, size, "cash");
        case 16..18: format(kind, size, "crown");
        case 19: format(kind, size, "clothes");
        case 20: format(kind, size, "gem");
        default: format(kind, size, "token");
    }
    return 1;
}

stock CefCases_ItemKindStr(type, kind[], size = sizeof(kind))
{
    switch(type)
    {
        case ITEM_TYPE_WEAPON:    format(kind, size, "weapon");
        case ITEM_TYPE_FOOD:      format(kind, size, "medkit");
        case ITEM_TYPE_DRUGS:     format(kind, size, "medkit");
        case ITEM_TYPE_ACCESSORY: format(kind, size, "chain");
        case ITEM_TYPE_MONEY:     format(kind, size, "cash");
        default:                  format(kind, size, "token");
    }
    return 1;
}

stock CefCases_ItemValue(itemid, val[], size = sizeof(val))
{
    switch(itemid)
    {
        case 1..6: format(val, size, "Weapon");
        case 7: format(val, size, "x10");
        case 8: format(val, size, "x50");
        case 9: format(val, size, "+50 HP");
        case 10: format(val, size, "+100 Armor");
        case 11: format(val, size, "$ 10,000");
        case 12: format(val, size, "$ 50,000");
        case 13: format(val, size, "$ 100,000");
        case 14: format(val, size, "$ 500,000");
        case 15: format(val, size, "$ 1,000,000");
        case 16: format(val, size, "VIP Bronze");
        case 17: format(val, size, "VIP Silver");
        case 18: format(val, size, "VIP Gold");
        case 19: format(val, size, "Skin");
        case 20: format(val, size, "Accessory");
        default: format(val, size, "Item");
    }
    return 1;
}

                                                       
CMD:cefinv(playerid, params[])
{
    new playerName[32], playerMoney;
    GetPlayerName(playerid, playerName, sizeof(playerName));
    playerMoney = GetPlayerMoney(playerid);
    CefCases_ShowInventory(playerid, playerName, playerMoney);
    return 1;
}
CMD:cefgiveitem(playerid, params[])
{
    new targetid, itemid, amount;
    if(sscanf(params, "iii", targetid, itemid, amount))
        return SendClientMessage(playerid, 0xFFA500FF, "/cefgiveitem [ID] [ItemID] [кол-во]");
    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, 0xFF0000FF, "Игрок не найден.");
    CefCases_GiveItem(targetid, itemid, amount, RARITY_COMMON);
    return 1;
}
CMD:cefgivecase(playerid, params[])
{
    new targetid, caseid;
    if(sscanf(params, "ii", targetid, caseid))
        return SendClientMessage(playerid, 0xFFA500FF, "/cefgivecase [ID] [CaseID 0-%d]", TotalCases-1);
    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, 0xFF0000FF, "Игрок не найден.");
    if(caseid < 0 || caseid >= TotalCases) return SendClientMessage(playerid, 0xFF0000FF, "Неверный ID кейса.");

    new slot = -1;
    for(new i = 0; i < MAX_INVENTORY_SLOTS; i++)
        if(InvItemID[targetid][i] == 0) { slot = i; break; }
    if(slot == -1) return SendClientMessage(playerid, 0xFF0000FF, "Инвентарь полон.");

    new rarity = RARITY_LEGENDARY;
    if(caseid <= 4) rarity = RARITY_COMMON;
    else if(caseid <= 9) rarity = RARITY_RARE;
    else rarity = RARITY_EPIC;

    InvItemID[targetid][slot] = caseid + 1000;
    format(InvName[targetid][slot], 64, "%s", CaseName[caseid]);
    InvType[targetid][slot] = ITEM_TYPE_CASE;
    InvParam[targetid][slot] = caseid;
    InvAmount[targetid][slot] = 1;
    InvRarity[targetid][slot] = rarity;
    format(InvCategory[targetid][slot], 16, "cases");

    new query[512];
    format(query, sizeof(query),
        "INSERT INTO `inventory` (`owner_id`,`item_id`,`item_name`,`item_type`,`item_param`,`item_amount`,`item_rarity`,`item_category`,`item_weight`) VALUES ('%d','%d','%s','%d','%d','%d','%d','%s','0.2')",
        GetPVarInt(targetid, "CefMySQLID"), caseid + 1000, CaseName[caseid], ITEM_TYPE_CASE, caseid, 1, rarity, "cases");
    mysql_tquery(CefMySQLHandle, query);

    new msg[128];
    format(msg, sizeof(msg), "Выдан кейс '%s' игроку", CaseName[caseid]);
    SendClientMessage(playerid, 0x33AA33FF, msg);
    return 1;
}