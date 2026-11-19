#if defined _cef_world_create_included
    #endinput
#endif
#define _cef_world_create_included

#define DIALOG_WCREATE_MAIN 30600
#define DIALOG_WCREATE_JOB  30601
#define DIALOG_WCREATE_FRAC 30602
#define DIALOG_WCREATE_NAME 30603
#define DIALOG_WCREATE_HOUSE 30604
#define DIALOG_WCREATE_KVART 30605
#define DIALOG_WCREATE_FRACNEW 30606

#define WCREATE_MAX 128

new gWCreateKind[MAX_PLAYERS];
new gWCreateFrac[MAX_PLAYERS];
new gWCreateFid[MAX_PLAYERS];
new gWCreateName[MAX_PLAYERS][40];
new Float:gWCreateX[MAX_PLAYERS];
new Float:gWCreateY[MAX_PLAYERS];
new Float:gWCreateZ[MAX_PLAYERS];
new gWCreateVw[MAX_PLAYERS];
new gWCreateCap[MAX_PLAYERS][40];
new gWCreateType[MAX_PLAYERS];
new gWCreateRanks[MAX_PLAYERS];

stock WCreate_Admin(playerid)
{
    return PI[playerid][pAdmin] >= 6;
}

stock WCreate_Caption(type, dest[], size)
{
    switch(type)
    {
        case CEF_MK_BANK: format(dest, size, "BANK / ALT");
        case CEF_MK_ATM: format(dest, size, "ATM / ALT");
        case CEF_MK_SHOP: format(dest, size, "SHOP / ALT");
        case CEF_MK_GAS: format(dest, size, "GAS / ALT");
        case CEF_MK_SERVICE: format(dest, size, "SERVICE / ALT");
        case CEF_MK_JOB: format(dest, size, "JOB / ALT");
        default: format(dest, size, "POINT / ALT");
    }
    return 1;
}

forward WCreate_OnPlaceInserted(playerid, type);
public WCreate_OnPlaceInserted(playerid, type)
{


    new id = cache_insert_id();
    if(!IsPlayerConnected(playerid)) return 1;
    if(!CEF_LiveAddMarkEx(type, gWCreateX[playerid], gWCreateY[playerid], gWCreateZ[playerid],
        gWCreateVw[playerid], gWCreateCap[playerid], id))
    {
        SendClientMessage(playerid, 0xFF4C58FF, "[CREATE] SQL ok, no pickup (limit metok).");
        return 1;
    }
    gCefMarkAt[playerid] = gCefMarkCount;
    CEF_LiveUseMark(playerid, type);
    SendClientMessage(playerid, 0x54B367FF, "[CREATE] Tochka sozdana. CEF open / ALT.");
    return 1;
}

stock WCreate_InsertPlace(playerid, type, const name[], extra)
{
    new Float:x, Float:y, Float:z, Float:a, query[352];
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);


    gWCreateX[playerid] = x;
    gWCreateY[playerid] = y;
    gWCreateZ[playerid] = z;
    gWCreateVw[playerid] = GetPlayerVirtualWorld(playerid);
    if(strlen(name)) format(gWCreateCap[playerid], 40, "%s / ALT", name);
    else WCreate_Caption(type, gWCreateCap[playerid], 40);
    mysql_format(dbHandle, query, sizeof query,
        "INSERT INTO `world_places` (`type`,`name`,`extra`,`x`,`y`,`z`,`a`,`vw`,`interior`) VALUES (%d,'%e',%d,%.4f,%.4f,%.4f,%.4f,%d,%d)",
        type, name, extra, x, y, z, a, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid));
    mysql_tquery(dbHandle, query, "WCreate_OnPlaceInserted", "ii", playerid, type);
    return 1;
}

stock WCreate_MakeHouse(playerid, price, cls, pay)
{
    if(total_houses >= MAX_HOUSES) return SendErr(playerid, "MAX houses");
    if(cls < 1 || cls > 3) cls = 1;
    if(price < 1) price = 5000000;
    if(pay < 1) pay = 5000;
    new h = total_houses;
    new Float:x, Float:y, Float:z, Float:a;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);
    House[h][hID] = h + 1;
    House[h][hPrice] = price;
    House[h][hClass] = cls;
    House[h][hPay] = pay;
    House[h][hHours] = 0;
    House[h][hLock] = 0;
    House[h][hOwnerID] = 0;
    settext(House[h][hOwner], "None");
    House[h][hVSPos_x] = x;
    House[h][hVSPos_y] = y;
    House[h][hVSPos_z] = z;
    House[h][hVSPos_a] = a;
    House[h][hPos_x] = x;
    House[h][hPos_y] = y;
    House[h][hPos_z] = z;
    House[h][hPickup] = CreatePickup(11776, 23, x, y, z);
    House[h][hMapIcon] = CreateDynamicMapIcon(x, y, z, 31, 0, -1, -1, -1, 150.0);
    CreatePickup(11778, 23, House_Interiors[cls][hIPos_X], House_Interiors[cls][hIPos_Y], House_Interiors[cls][hIPos_Z], House[h][hID]);
    CreatePickup(11784, 23, x, y, z + 0.42);
    House[h][hAreaExit] = CreateDynamicSphere(House_Interiors[cls][hIPos_X], House_Interiors[cls][hIPos_Y], House_Interiors[cls][hIPos_Z], 1.0, House[h][hID]);
    House[h][hArea] = CreateDynamicSphere(x, y, z, 1.5);
    House[h][hAreaSpawnVehicle] = CreateDynamicSphere(x, y, z, 5.0);
    total_houses++;
    new query[384];
    mysql_format(dbHandle, query, sizeof query,
        "INSERT INTO `houses` (`price`,`pay`,`class`,`lock`,`hours`,`owner_id`,`pos_x`,`pos_y`,`pos_z`,`vs_posx`,`vs_posy`,`vs_posz`,`vs_posa`) VALUES (%d,%d,%d,0,0,0,'%.4f','%.4f','%.4f','%.4f','%.4f','%.4f','%.4f')",
        price, pay, cls, x, y, z, x, y, z, a);
    mysql_tquery(dbHandle, query, "", "");
    new msg[144];
    format(msg, sizeof msg, "[CREATE] Dom ID %d class %d price %d pay %d", h + 1, cls, price, pay);
    SendClientMessage(playerid, 0x54B367FF, msg);
    return 1;
}

stock WCreate_StartPorch(playerid, cls)
{
    if(cls < 1) cls = 1;
    if(cls > 2) cls = 2;
    new Float:x, Float:y, Float:z, Float:a;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);
    PT[playerid][pCreateVehicleX] = x;
    PT[playerid][pCreateVehicleY] = y;
    PT[playerid][pCreateVehicleZ] = z;
    PT[playerid][pCreateVehicleA] = a;
    PT[playerid][pCreate] = 3;
    PT[playerid][pSubCreate] = 0;
    ShowPlayerDialogEx(playerid, dialog_CREATE+8, DIALOG_STYLE_LIST, "Podezd", "1. Nizkiy klass\n2. Vysokiy klass", "OK", "X");
    SendClientMessage(playerid, 0x54B367FF, "[CREATE] Vyberi klass podezda. Mashina-parkovka = tvoya tochka.");
    return 1;
}

stock WCreate_FracPoint(playerid, frac, kind)
{
    if(frac < 1 || frac >= MAX_FRACTIONS) return SendErr(playerid, "frac 1..16");
    new Float:x, Float:y, Float:z, Float:a, query[384];
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);
    if(kind == 1)
    {
        Fractions_Spawn[frac][0] = x; Fractions_Spawn[frac][1] = y; Fractions_Spawn[frac][2] = z; Fractions_Spawn[frac][3] = a;
        mysql_format(dbHandle, query, sizeof query,
            "UPDATE `fractions_coords` SET `fraction_spawn_X`=%.4f,`fraction_spawn_Y`=%.4f,`fraction_spawn_Z`=%.4f,`fraction_spawn_A`=%.4f WHERE `fraction_id`=%d",
            x, y, z, a, frac);
        mysql_tquery(dbHandle, query, "", "");
        SendClientMessage(playerid, 0x54B367FF, "[CREATE] Frac spawn saved.");
    }
    else if(kind == 2)
    {
        Fractions_Dress[frac][0] = x; Fractions_Dress[frac][1] = y; Fractions_Dress[frac][2] = z;
        mysql_format(dbHandle, query, sizeof query,
            "UPDATE `fractions_coords` SET `fraction_dress_X`=%.4f,`fraction_dress_Y`=%.4f,`fraction_dress_Z`=%.4f WHERE `fraction_id`=%d",
            x, y, z, frac);
        mysql_tquery(dbHandle, query, "", "");
        CreateDynamicPickup(1275, 23, x, y, z);
        Fraction[frac][fDressPickup] = CreateDynamicSphere(x, y, z, 2.5, -1, -1, -1);
        SendClientMessage(playerid, 0x54B367FF, "[CREATE] Frac dress saved.");
    }
    else
    {
        Fractions_Armoury[frac][0] = x; Fractions_Armoury[frac][1] = y; Fractions_Armoury[frac][2] = z;
        mysql_format(dbHandle, query, sizeof query,
            "UPDATE `fractions_coords` SET `fraction_armoury_X`=%.4f,`fraction_armoury_Y`=%.4f,`fraction_armoury_Z`=%.4f WHERE `fraction_id`=%d",
            x, y, z, frac);
        mysql_tquery(dbHandle, query, "", "");
        CreateDynamicPickup(1275, 23, x, y, z);
        Fraction[frac][fArmouryPickup] = CreateDynamicSphere(x, y, z, 2.5, -1, -1, -1);
        SendClientMessage(playerid, 0x54B367FF, "[CREATE] Frac armoury saved.");
    }
    return 1;
}

stock WCreate_MakeAzs(playerid, const name[])
{
    new Float:x, Float:y, Float:z, query[256];
    GetPlayerPos(playerid, x, y, z);
    mysql_format(dbHandle, query, sizeof query,
        "INSERT INTO `mechanic_azs` (`name`,`x`,`y`,`z`) VALUES ('%e',%.4f,%.4f,%.4f)", name, x, y, z);
    mysql_tquery(dbHandle, query, "OnMechanicAZSAdded", "i", playerid);
    WCreate_InsertPlace(playerid, CEF_MK_GAS, name, 0);
    return 1;
}


stock WCreate_MakeFaction(playerid, type, ranks, const name[])
{
    if(type < 1 || type > 16) return SendErr(playerid, "type 1..16");
    if(ranks < 1) ranks = 10;
    if(ranks > 12) ranks = 12;
    if(!strlen(name)) return SendErr(playerid, "empty name");
    gWCreateType[playerid] = type;
    gWCreateRanks[playerid] = ranks;
    format(gWCreateName[playerid], 40, "%s", name);
    mysql_tquery(dbHandle, "SELECT COALESCE(MAX(`id`),0)+1 AS nid FROM `fractions`", "WCreate_OnFracNext", "i", playerid);
    return 1;
}

forward WCreate_OnFracNext(playerid);
public WCreate_OnFracNext(playerid)
{
    if(!IsPlayerConnected(playerid)) return 1;
    new nid = 0;
    if(cache_num_rows() > 0) cache_get_value_name_int(0, "nid", nid);
    if(nid < 1) return SendErr(playerid, "[CREATE] ne smog poluchit ID frakcii");
    if(nid >= MAX_FRACTIONS) return SendErr(playerid, "[CREATE] limit frakcii ischerpan (MAX 16)");
    gWCreateFid[playerid] = nid;
    new q[384];
    mysql_format(dbHandle, q, sizeof q,
        "INSERT INTO `fractions` (`id`,`fraction_name`,`fraction_type`,`fraction_ranks`) VALUES (%d,'%e',%d,%d)",
        nid, gWCreateName[playerid], gWCreateType[playerid], gWCreateRanks[playerid]);
    mysql_tquery(dbHandle, q, "", "");
    mysql_format(dbHandle, q, sizeof q, "INSERT INTO `fractions_names` (`fraction_id`) VALUES (%d)", nid);
    mysql_tquery(dbHandle, q, "", "");
    mysql_format(dbHandle, q, sizeof q, "INSERT INTO `fractions_skins` (`fraction_id`) VALUES (%d)", nid);
    mysql_tquery(dbHandle, q, "", "");
    mysql_format(dbHandle, q, sizeof q, "INSERT INTO `fractions_salaries` (`fraction_id`) VALUES (%d)", nid);
    mysql_tquery(dbHandle, q, "", "");
    mysql_format(dbHandle, q, sizeof q, "INSERT INTO `fractions_coords` (`fraction_id`) VALUES (%d)", nid);
    mysql_tquery(dbHandle, q, "WCreate_OnFracRows", "ii", playerid, nid);
    return 1;
}

forward WCreate_OnFracRows(playerid, fid);
public WCreate_OnFracRows(playerid, fid)
{
    if(!IsPlayerConnected(playerid)) return 1;
    new q[640];
    mysql_format(dbHandle, q, sizeof q,
        "SELECT f.*, fn.*, fs.*, frs.*, fcd.*, (SELECT COUNT(*) FROM accounts a WHERE a.fraction = f.id) AS fraction_total_members FROM fractions f LEFT JOIN fractions_names fn ON f.id = fn.fraction_id LEFT JOIN fractions_skins fs ON f.id = fs.fraction_id LEFT JOIN fractions_salaries frs ON f.id = frs.fraction_id LEFT JOIN fractions_coords fcd ON f.id = fcd.fraction_id WHERE f.id = %d",
        fid);
    mysql_tquery(dbHandle, q, "WCreate_OnFracLoaded", "ii", playerid, fid);
    return 1;
}

forward WCreate_OnFracLoaded(playerid, fid);
public WCreate_OnFracLoaded(playerid, fid)
{
    if(!IsPlayerConnected(playerid)) return 1;
    if(cache_num_rows() < 1) return SendErr(playerid, "[CREATE] frakciya ne zagruzilas");
    new f = fid;
    if(f < 0 || f >= MAX_FRACTIONS) return SendErr(playerid, "[CREATE] index vne limita");
    new tmp[32];
    cache_get_value_name_int(0, "fraction_type", Fraction[f][fType]);
    cache_get_value_name_int(0, "fraction_ranks", Fraction[f][fMax_ranks]);
    cache_get_value_name(0, "fraction_name", Fraction[f][fName], 32);
    cache_get_value_name_int(0, "fraction_total_members", Fraction[f][fTotalMembers]);
    cache_get_value_name_float(0, "fraction_spawn_X", Fractions_Spawn[f][0]);
    cache_get_value_name_float(0, "fraction_spawn_Y", Fractions_Spawn[f][1]);
    cache_get_value_name_float(0, "fraction_spawn_Z", Fractions_Spawn[f][2]);
    cache_get_value_name_float(0, "fraction_spawn_A", Fractions_Spawn[f][3]);
    cache_get_value_name_float(0, "fraction_dress_X", Fractions_Dress[f][0]);
    cache_get_value_name_float(0, "fraction_dress_Y", Fractions_Dress[f][1]);
    cache_get_value_name_float(0, "fraction_dress_Z", Fractions_Dress[f][2]);
    cache_get_value_name_float(0, "fraction_armoury_X", Fractions_Armoury[f][0]);
    cache_get_value_name_float(0, "fraction_armoury_Y", Fractions_Armoury[f][1]);
    cache_get_value_name_float(0, "fraction_armoury_Z", Fractions_Armoury[f][2]);
    for(new i = 0; i < Fraction[f][fMax_ranks]; i++)
    {
        tmp[0] = EOS;
        format(tmp, sizeof tmp, "rank%d_name", i + 1);
        cache_get_value_name(0, tmp, Fraction_Rank[f][i], 32);
        tmp[0] = EOS;
        format(tmp, sizeof tmp, "fraction_skin_%d", i + 1);
        cache_get_value_name_int(0, tmp, Fraction[f][fSkinMale][i]);
        tmp[0] = EOS;
        format(tmp, sizeof tmp, "fraction_skin_female_%d", i + 1);
        cache_get_value_name_int(0, tmp, Fraction[f][fSkinFemale][i]);
        tmp[0] = EOS;
        format(tmp, sizeof tmp, "salary_rank_%d", i + 1);
        cache_get_value_name_int(0, tmp, Fraction[f][fSalary][i]);
    }
    if(totalFractions <= f) totalFractions = f + 1;
    new msg[160];
    format(msg, sizeof msg, "[CREATE] Frakciya #%d '%s' tip %d rangov %d. ID dlya /createfrac: %d", f, Fraction[f][fName], Fraction[f][fType], Fraction[f][fMax_ranks], f);
    SendClientMessage(playerid, 0x54B367FF, msg);
    SendClientMessage(playerid, 0x54B367FF, "[CREATE] Teper staw tochki: /createfrac [id] spawn | skin | sklad");
    return 1;
}

CMD:createfracnew(playerid, params[])
{
    if(!WCreate_Admin(playerid)) return SendErr(playerid, "Nuzhen admin 6+");
    new type, ranks, name[40];
    if(sscanf(params, "dds[40]", type, ranks, name))
        return SendErr(playerid, "/createfracnew [type 1-16] [ranks 1-12] [nazvanie]");
    return WCreate_MakeFaction(playerid, type, ranks, name);
}

stock WCreate_FracTypes(dest[], size)
{
    format(dest, size, "1. Pravitelstvo\n2. FSB\n3. DPS\n4. PPS\n5. Bolnica/ESS\n6. Voinskaya chast\n7. Baykery\n8. Skinhheady\n9. Russkaya mafiya\n10. Kavkazskaya mafiya\n11. OPG Yuzhnaya\n12. OPG Orekhovskaya\n13. OPG Solncevskaya\n14. Chechenskaya mafiya\n15. TRK Unmazing\n16. SK");
    return 1;
}

stock WCreate_Menu(playerid)
{
    ShowPlayerDialogEx(playerid, DIALOG_WCREATE_MAIN, DIALOG_STYLE_LIST, "CREATE",
        "1. Zapravka (AZS+CEF)\n2. Magazin 24/7\n3. Bank\n4. Bankomat\n5. Avtoservis\n6. Dom\n7. Podezd / kvartiry\n8. Rabota\n9. Frakciya: spawn\n10. Frakciya: razdevalka\n11. Frakciya: sklad\n12. Sozdat frakciyu (tip+rangy)\n13. Udalit blizhnuyu tochku\n14. Parkovka\n15. Arenda transporta\n16. Avtosalon\n17. Mashina v avtosalon",
        "OK", "X");
    return 1;
}

CMD:create(playerid, params[])
{
    #pragma unused params
    if(!WCreate_Admin(playerid)) return SendErr(playerid, "Nuzhen admin 6+");
    return WCreate_Menu(playerid);
}

CMD:createazs(playerid, params[])
{
    if(!WCreate_Admin(playerid)) return SendErr(playerid, "Nuzhen admin 6+");
    new name[64];
    if(sscanf(params, "s[64]", name)) return SendErr(playerid, "/createazs [name]");
    return WCreate_MakeAzs(playerid, name);
}

CMD:createshop(playerid, params[])
{
    if(!WCreate_Admin(playerid)) return SendErr(playerid, "Nuzhen admin 6+");
    new name[64];
    if(params[0] == EOS) format(name, sizeof name, "24/7");
    else format(name, sizeof name, "%s", params);
    return WCreate_InsertPlace(playerid, CEF_MK_SHOP, name, 1);
}

CMD:createbank(playerid, params[])
{
    #pragma unused params
    if(!WCreate_Admin(playerid)) return SendErr(playerid, "Nuzhen admin 6+");
    return WCreate_InsertPlace(playerid, CEF_MK_BANK, "Bank", 0);
}

CMD:createatm(playerid, params[])
{
    #pragma unused params
    if(!WCreate_Admin(playerid)) return SendErr(playerid, "Nuzhen admin 6+");
    return WCreate_InsertPlace(playerid, CEF_MK_ATM, "ATM", 0);
}

CMD:createservice(playerid, params[])
{
    #pragma unused params
    if(!WCreate_Admin(playerid)) return SendErr(playerid, "Nuzhen admin 6+");
    return WCreate_InsertPlace(playerid, CEF_MK_SERVICE, "Service", 0);
}

CMD:createhouse(playerid, params[])
{
    if(!WCreate_Admin(playerid)) return SendErr(playerid, "Nuzhen admin 6+");
    new price, cls, pay;
    if(sscanf(params, "dD(1)D(5000)", price, cls, pay))
        return SendErr(playerid, "/createhouse [price] [class 1-3] [pay]");
    return WCreate_MakeHouse(playerid, price, cls, pay);
}

CMD:createkvart(playerid, params[])
{
    if(!WCreate_Admin(playerid)) return SendErr(playerid, "Nuzhen admin 6+");
    new cls;
    if(sscanf(params, "D(1)", cls)) cls = 1;
    return WCreate_StartPorch(playerid, cls);
}

CMD:createjob(playerid, params[])
{
    if(!WCreate_Admin(playerid)) return SendErr(playerid, "Nuzhen admin 6+");
    new kind[16];
    if(sscanf(params, "s[16]", kind))
        return SendErr(playerid, "/createjob [factory|razvoz|bus|mech]");
    if(!strcmp(kind, "factory", true) || !strcmp(kind, "zavod", true))
        return WCreate_InsertPlace(playerid, CEF_MK_JOB, "Factory", 1);
    if(!strcmp(kind, "razvoz", true))
        return WCreate_InsertPlace(playerid, CEF_MK_JOB, "Razvoz", 2);
    if(!strcmp(kind, "bus", true) || !strcmp(kind, "avtobus", true))
    {
        SendClientMessage(playerid, 0x54B367FF, "Avtobus: /addcaravtobus  i  /addchipavtobus  (marshrut). Stavlju JOB-metku.");
        return WCreate_InsertPlace(playerid, CEF_MK_JOB, "Bus", 3);
    }
    if(!strcmp(kind, "mech", true) || !strcmp(kind, "mechanic", true))
    {
        new Float:mx, Float:my, Float:mz, Float:ma, q2[192];
        GetPlayerPos(playerid, mx, my, mz);
        GetPlayerFacingAngle(playerid, ma);
        mysql_format(dbHandle, q2, sizeof q2, "INSERT INTO `mechanic_spawns` (`x`,`y`,`z`,`angle`) VALUES (%.4f,%.4f,%.4f,%.4f)", mx, my, mz, ma);
        mysql_tquery(dbHandle, q2, "OnMechanicSpawnAdded", "i", playerid);
        return WCreate_InsertPlace(playerid, CEF_MK_JOB, "Mech", 4);
    }
    return SendErr(playerid, "/createjob [factory|razvoz|bus|mech]");
}

CMD:createfrac(playerid, params[])
{
    if(!WCreate_Admin(playerid)) return SendErr(playerid, "Nuzhen admin 6+");
    new frac, kind[16];
    if(sscanf(params, "ds[16]", frac, kind))
        return SendErr(playerid, "/createfrac [id] [spawn|skin|sklad]");
    if(!strcmp(kind, "spawn", true)) return WCreate_FracPoint(playerid, frac, 1);
    if(!strcmp(kind, "skin", true) || !strcmp(kind, "dress", true) || !strcmp(kind, "razdevalka", true)) return WCreate_FracPoint(playerid, frac, 2);
    if(!strcmp(kind, "sklad", true) || !strcmp(kind, "armoury", true)) return WCreate_FracPoint(playerid, frac, 3);
    return SendErr(playerid, "/createfrac [id] [spawn|skin|sklad]");
}

stock WCreate_Delete(playerid)
{
    new idx = CEF_LiveNearest(playerid, 5.0);
    if(idx < 0) return SendErr(playerid, "Ryadom net tochki");
    new dbid = gCefMark[idx][mkDbId];
    if(dbid > 0)
    {
        new q[96];
        mysql_format(dbHandle, q, sizeof q, "DELETE FROM `world_places` WHERE `id`=%d", dbid);
        mysql_tquery(dbHandle, q, "", "");
    }
    CEF_LiveRemoveAt(idx);
    SendClientMessage(playerid, 0x54B367FF, "[CREATE] Tochka udalena.");
    return 1;
}

CMD:dellplace(playerid, params[])
{
    #pragma unused params
    if(!WCreate_Admin(playerid)) return SendErr(playerid, "Nuzhen admin 6+");
    return WCreate_Delete(playerid);
}

stock WCreate_OnDialog(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == DIALOG_WCREATE_MAIN)
    {
        if(!response) return 1;
        switch(listitem)
        {
            case 0: { gWCreateKind[playerid] = CEF_MK_GAS; ShowPlayerDialogEx(playerid, DIALOG_WCREATE_NAME, DIALOG_STYLE_INPUT, "AZS", "Nazvanie zapravki:", "OK", "X"); }
            case 1: { gWCreateKind[playerid] = CEF_MK_SHOP; ShowPlayerDialogEx(playerid, DIALOG_WCREATE_NAME, DIALOG_STYLE_INPUT, "SHOP", "Nazvanie magazina:", "OK", "X"); }
            case 2: WCreate_InsertPlace(playerid, CEF_MK_BANK, "Bank", 0);
            case 3: WCreate_InsertPlace(playerid, CEF_MK_ATM, "ATM", 0);
            case 4: WCreate_InsertPlace(playerid, CEF_MK_SERVICE, "Service", 0);
            case 5: ShowPlayerDialogEx(playerid, DIALOG_WCREATE_HOUSE, DIALOG_STYLE_INPUT, "DOM", "price class pay\nprimer: 5000000 1 5000", "OK", "X");
            case 6: ShowPlayerDialogEx(playerid, DIALOG_WCREATE_KVART, DIALOG_STYLE_LIST, "Kvartiry", "Nizkiy klass (10 kv)\nVysokiy klass (20 kv)", "OK", "X");
            case 7: ShowPlayerDialogEx(playerid, DIALOG_WCREATE_JOB, DIALOG_STYLE_LIST, "Rabota", "Zavod (craft)\nRazvozchik\nAvtobus\nMehanik spawn", "OK", "X");
            case 8: { gWCreateKind[playerid] = 101; ShowPlayerDialogEx(playerid, DIALOG_WCREATE_FRAC, DIALOG_STYLE_INPUT, "FRAC spawn", "ID frakcii (2 FSB, 3 DPS, 4 PPS, 6 VCH):", "OK", "X"); }
            case 9: { gWCreateKind[playerid] = 102; ShowPlayerDialogEx(playerid, DIALOG_WCREATE_FRAC, DIALOG_STYLE_INPUT, "FRAC dress", "ID frakcii:", "OK", "X"); }
            case 10: { gWCreateKind[playerid] = 103; ShowPlayerDialogEx(playerid, DIALOG_WCREATE_FRAC, DIALOG_STYLE_INPUT, "FRAC sklad", "ID frakcii:", "OK", "X"); }
            case 11:
            {
                new tl[420];
                gWCreateKind[playerid] = 200;
                WCreate_FracTypes(tl, sizeof tl);
                SendClientMessage(playerid, 0x54B367FF, tl);
                ShowPlayerDialogEx(playerid, DIALOG_WCREATE_FRACNEW, DIALOG_STYLE_INPUT, "Novaya frakciya", "type ranks nazvanie\nprimer: 2 10 FSB Samara", "OK", "X");
            }
            case 12: WCreate_Delete(playerid);
            default: DynWorld_MenuItem(playerid, listitem);
        }
        return 1;
    }
    if(dialogid == DIALOG_WCREATE_NAME)
    {
        if(!response) return 1;
        if(!strlen(inputtext)) return WCreate_Menu(playerid);
        if(gWCreateKind[playerid] == CEF_MK_GAS) WCreate_MakeAzs(playerid, inputtext);
        else WCreate_InsertPlace(playerid, gWCreateKind[playerid], inputtext, 1);
        return 1;
    }
    if(dialogid == DIALOG_WCREATE_HOUSE)
    {
        if(!response) return 1;
        new price, cls, pay;
        if(sscanf(inputtext, "dD(1)D(5000)", price, cls, pay)) return SendErr(playerid, "price class pay");
        WCreate_MakeHouse(playerid, price, cls, pay);
        return 1;
    }
    if(dialogid == DIALOG_WCREATE_KVART)
    {
        if(!response) return 1;
        WCreate_StartPorch(playerid, listitem + 1);
        return 1;
    }
    if(dialogid == DIALOG_WCREATE_JOB)
    {
        if(!response) return 1;
        switch(listitem)
        {
            case 0: WCreate_InsertPlace(playerid, CEF_MK_JOB, "Factory", 1);
            case 1: WCreate_InsertPlace(playerid, CEF_MK_JOB, "Razvoz", 2);
            case 2:
            {
                SendClientMessage(playerid, 0x54B367FF, "Dalee: /addcaravtobus  /addchipavtobus");
                WCreate_InsertPlace(playerid, CEF_MK_JOB, "Bus", 3);
            }
            case 3:
            {
                new Float:mx, Float:my, Float:mz, Float:ma, q2[192];
                GetPlayerPos(playerid, mx, my, mz);
                GetPlayerFacingAngle(playerid, ma);
                mysql_format(dbHandle, q2, sizeof q2, "INSERT INTO `mechanic_spawns` (`x`,`y`,`z`,`angle`) VALUES (%.4f,%.4f,%.4f,%.4f)", mx, my, mz, ma);
                mysql_tquery(dbHandle, q2, "OnMechanicSpawnAdded", "i", playerid);
                WCreate_InsertPlace(playerid, CEF_MK_JOB, "Mech", 4);
            }
        }
        return 1;
    }
    if(dialogid == DIALOG_WCREATE_FRACNEW)
    {
        if(!response) return 1;
        new type, ranks, name[40];
        if(sscanf(inputtext, "dds[40]", type, ranks, name)) return SendErr(playerid, "type ranks nazvanie");
        WCreate_MakeFaction(playerid, type, ranks, name);
        return 1;
    }
    if(dialogid == DIALOG_WCREATE_FRAC)
    {
        if(!response) return 1;
        new frac = strval(inputtext);
        if(gWCreateKind[playerid] == 101) WCreate_FracPoint(playerid, frac, 1);
        else if(gWCreateKind[playerid] == 102) WCreate_FracPoint(playerid, frac, 2);
        else WCreate_FracPoint(playerid, frac, 3);
        return 1;
    }
    if(DynWorld_OnDialog(playerid, dialogid, response, listitem, inputtext)) return 1;
    return 0;
}
forward WCreate_Init();
public WCreate_Init()
{
    mysql_tquery(dbHandle,
        "CREATE TABLE IF NOT EXISTS `world_places` (`id` INT NOT NULL AUTO_INCREMENT, `type` INT NOT NULL, `name` VARCHAR(64) NOT NULL DEFAULT '', `extra` INT NOT NULL DEFAULT 0, `x` FLOAT NOT NULL, `y` FLOAT NOT NULL, `z` FLOAT NOT NULL, `a` FLOAT NOT NULL DEFAULT 0, `vw` INT NOT NULL DEFAULT 0, `interior` INT NOT NULL DEFAULT 0, PRIMARY KEY (`id`)) ENGINE=InnoDB DEFAULT CHARSET=cp1251",
        "", "");
    mysql_tquery(dbHandle, "SELECT `id`,`type`,`name`,`extra`,`x`,`y`,`z`,`vw` FROM `world_places`", "WCreate_OnPlacesLoaded", "");
    return 1;
}

forward WCreate_OnPlacesLoaded();
public WCreate_OnPlacesLoaded()
{
    new rows = cache_num_rows();
    new id, type, extra, vw, Float:x, Float:y, Float:z, name[64], cap[32];
    for(new i = 0; i < rows; i++)
    {
        cache_get_value_name_int(i, "id", id);
        cache_get_value_name_int(i, "type", type);
        cache_get_value_name_int(i, "extra", extra);
        cache_get_value_name_int(i, "vw", vw);
        cache_get_value_name_float(i, "x", x);
        cache_get_value_name_float(i, "y", y);
        cache_get_value_name_float(i, "z", z);
        cache_get_value_name(i, "name", name, 64);
        WCreate_Caption(type, cap, sizeof cap);
        if(strlen(name)) format(cap, sizeof cap, "%s / ALT", name);
        CEF_LiveAddMarkEx(type, x, y, z, vw, cap, id);
        #pragma unused extra
    }
    printf("[CREATE] loaded world_places %d", rows);
    return 1;
}
