#if defined _cef_compat_included
    #endinput
#endif
#define _cef_compat_included





#define DIALOG_REGISTER_SKIN_NATIVE 29998
#define CEF_GAS_MAX 100

new bool:gCefcAppReady[MAX_PLAYERS];
new bool:gCefcHudFull[MAX_PLAYERS] = {true, ...};
new gCefcDialogId[MAX_PLAYERS];
new gCefcChatMode[MAX_PLAYERS];
new bool:gCefcConfigSent[MAX_PLAYERS];
new bool:gCefAuthActive[MAX_PLAYERS];
new bool:gCefAdminPanelOpen[MAX_PLAYERS];
new bool:gCefSupportPanelOpen[MAX_PLAYERS];
new bool:gCefMenuOpen[MAX_PLAYERS];
new bool:gCefChatInput[MAX_PLAYERS];
new bool:gCefCamOn[MAX_PLAYERS];
new gCefTabClosedAt[MAX_PLAYERS];
new gCefCaseActive[MAX_PLAYERS];
new gCefCasePending[MAX_PLAYERS];
new bool:gCefSpeedoOn[MAX_PLAYERS];


stock CEF_JsonStr(const src[], const key[], dest[], size = sizeof dest)
{
    new pat[48], p, i = 0;
    dest[0] = EOS;
    format(pat, sizeof pat, "\"%s\":", key);
    p = strfind(src, pat, true);
    if(p < 0) return 0;
    p += strlen(pat);
    while(src[p] == ' ') p++;
    if(src[p] != '"') return 0;
    p++;
    while(src[p] != EOS && src[p] != '"' && i < size - 1)
    {
        if(src[p] == 92)
        {
            p++;
            switch(src[p])
            {
                case 'n': dest[i++] = '\n';
                case 't': dest[i++] = '\t';
                case 'r': {}
                case EOS: { dest[i] = EOS; return 1; }
                default:  dest[i++] = src[p];
            }
            p++;
            continue;
        }
        dest[i++] = src[p++];
    }
    dest[i] = EOS;
    return 1;
}





stock CEF_JsonTopStr(const src[], const key[], dest[], size = sizeof dest)
{
    new pat[48], plen, i = 0, depth = 0, inq = 0, esc = 0, j, n;
    dest[0] = EOS;
    format(pat, sizeof pat, "\"%s\":", key);
    plen = strlen(pat);
    while(src[i] != EOS)
    {
        new c = src[i];
        if(inq)
        {
            if(esc) esc = 0;
            else if(c == 92) esc = 1;
            else if(c == '"') inq = 0;
            i++;
            continue;
        }
        if(c == '"')
        {

            if(depth == 1)
            {
                new hit = 1;
                for(j = 0; j < plen; j++)
                {
                    if(src[i + j] != pat[j]) { hit = 0; break; }
                }
                if(hit)
                {
                    i += plen;
                    while(src[i] == ' ') i++;
                    if(src[i] == '"')
                    {
                        i++;
                        n = 0;
                        while(src[i] != EOS && src[i] != '"' && n < size - 1)
                        {
                            if(src[i] == 92)
                            {
                                i++;
                                switch(src[i])
                                {
                                    case 'n': dest[n++] = '\n';
                                    case 't': dest[n++] = '\t';
                                    case 'r': {}
                                    case EOS: { dest[n] = EOS; return 1; }
                                    default:  dest[n++] = src[i];
                                }
                                i++;
                                continue;
                            }
                            dest[n++] = src[i++];
                        }
                        dest[n] = EOS;
                        return 1;
                    }
                    if(src[i] >= '0' && src[i] <= '9')
                    {
                        n = 0;
                        while(src[i] != EOS && src[i] >= '0' && src[i] <= '9' && n < size - 1)
                            dest[n++] = src[i++];
                        dest[n] = EOS;
                        return 1;
                    }
                    return 0;
                }
            }
            inq = 1;
            i++;
            continue;
        }
        if(c == '{' || c == '[') { depth++; i++; continue; }
        if(c == '}' || c == ']') { depth--; i++; continue; }
        i++;
    }
    return 0;
}

forward CEF_NeedsReset(playerid);
stock CEFC_Reset(playerid)
{
    gCefcAppReady[playerid] = false;
    gCefcHudFull[playerid] = true;
    gCefcChatMode[playerid] = 1;
    gCefcConfigSent[playerid] = false;
    gCefcDialogId[playerid] = -1;
    gCefAuthActive[playerid] = false;
    gCefAdminPanelOpen[playerid] = false;
    gCefSupportPanelOpen[playerid] = false;
    gCefMenuOpen[playerid] = false;
    gCefTabClosedAt[playerid] = 0;
    gCefCaseActive[playerid] = 0;
    gCefCasePending[playerid] = 0;
    gCefChatInput[playerid] = false;
    CEF_NeedsReset(playerid);
    return 1;
}

stock bool:CEFC_Ready(playerid)
{
    return gCefcAppReady[playerid];
}


stock CEFC_OnAppStarted(playerid)
{
    static json[256];
    CEF_MarkPlayerReady(playerid);

    if(gCefcConfigSent[playerid]) return 1;
    gCefcConfigSent[playerid] = true;


    format(json, sizeof json, "{\"serverId\":1,\"time\":\"%s\",\"donateMultiplier\":1}", CEF_NowIso());
    CEF_Send(playerid, "cef_app_state_init", json);
    printf("[CEF-COMPAT] %d: cef_app_started -> set_config + state_init", playerid);
    return 1;
}

stock CEFC_OnAppReady(playerid)
{
    static bool:hudTimerStarted = false;
    gCefcAppReady[playerid] = true;
    cef_always_listen_keys(playerid, MAIN_BROWSER, true);
    if(!hudTimerStarted)
    {
        new fn[] = "CEFC_HudTick";
        SetTimer(fn, 1000, true);
        hudTimerStarted = true;
    }
    printf("[CEF-COMPAT] %d: cef_app_ready (SPA готов)", playerid);

    if(!PT[playerid][pLogged])
    {
        new fn[] = "ShowAuthDialog", fmt[] = "ii";
        SetTimerEx(fn, 600, false, fmt, playerid, PT[playerid][pAuthSession]);
    }
    return 1;
}


stock CEFC_Notify(playerid, const text[], const type[] = "info", time = 5000)
{
    static json[512], esc[256];
    CEF_JsonEscape(text, esc);
    format(json, sizeof json,
        "{\"viewType\":\"push\",\"messageType\":\"%s\",\"text\":\"%s\",\"title\":\"\",\"time\":%d,\"label\":\"\"}",
        type, esc, time);
    return CEF_Send(playerid, "cef_notifications_show", json);
}

stock CEFC_NotifyFull(playerid, const title[], const text[], time = 6000)
{
    static json[700], e1[128], e2[256];
    CEF_JsonEscape(title, e1);
    CEF_JsonEscape(text, e2);
    format(json, sizeof json,
        "{\"viewType\":\"fullscreen\",\"messageType\":\"info\",\"title\":\"%s\",\"text\":\"%s\",\"time\":%d,\"label\":\"\"}",
        e1, e2, time);
    return CEF_Send(playerid, "cef_notifications_show", json);
}

stock CEFC_ActionHint(playerid, const text[], const leading[] = "E")
{
    static json[320], esc[256];
    CEF_JsonEscape(text, esc);
    format(json, sizeof json, "{\"text\":\"%s\",\"leading\":\"%s\"}", esc, leading);
    return CEF_Send(playerid, "cef_action_hint_show", json);
}

stock CEFC_ActionHintHide(playerid)
{
    return CEF_SendEmpty(playerid, "cef_action_hint_hide");
}


stock CEFC_Dialog(playerid, dialogid, style, const title[], const content[], const b1[], const b2[])
{
    static json[2200], t[128], c[1600], x1[64], x2[64];
    CEF_JsonEscape(title, t);
    CEF_JsonEscape(content, c);
    CEF_JsonEscape(b1, x1);
    CEF_JsonEscape(b2, x2);
    gCefcDialogId[playerid] = dialogid;
    format(json, sizeof json,
        "{\"id\":%d,\"style\":%d,\"title\":\"%s\",\"content\":\"%s\",\"button1\":\"%s\",\"button2\":\"%s\",\"button3\":\"\"}",
        dialogid, style, t, c, x1, x2);
    CEF_Send(playerid, "cef_dialogs_open", json);
    CEF_Focus(playerid, true);
    return 1;
}

stock CEFC_DialogClose(playerid)
{
    gCefcDialogId[playerid] = -1;
    CEF_SendEmpty(playerid, "cef_dialogs_close");
    CEF_Focus(playerid, false);
    return 1;
}



forward CEFC_FocusCheck(playerid);
public CEFC_FocusCheck(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;
    if(gCefcDialogId[playerid] != -1) return 1;
    if(gCefAuthActive[playerid]) return 1;
    if(gCefMenuOpen[playerid]) return 1;
    if(gCefChatInput[playerid]) return 1;
    CEF_Focus(playerid, false);
    return 1;
}

stock CEFC_ReleaseCursor(playerid)
{
    gCefcDialogId[playerid] = -1;
    CEF_SendEmpty(playerid, "cef_dialogs_close");
    CEF_SendEmpty(playerid, "menu_close");
    CEF_Focus(playerid, false);
    CEF_Hide(playerid);
    return 1;
}

stock CEFC_OnDialogResponse(playerid, const arguments[])
{
    new id = CEF_EcoFindInt(arguments, "id");
    new press = CEF_EcoFindInt(arguments, "buttonPress");
    new item = CEF_EcoFindInt(arguments, "listItem");
    static input[256];

    CEF_JsonStr(arguments, "inputText", input, sizeof input);
    if(!strlen(input)) CEF_JsonStr(arguments, "text", input, sizeof input);
    if(id <= 0) id = gCefcDialogId[playerid];
    gCefcDialogId[playerid] = -1;
    CEF_Focus(playerid, false);




    if(id > 0)
    {
        PT[playerid][pDialogID] = id;
        OnDialogResponse(playerid, id, press, item, input);
    }
    {
        new fn[] = "CEFC_FocusCheck";
        SetTimerEx(fn, 250, false, "i", playerid);
    }
    return 1;
}


stock CEFC_ChatInit(playerid)
{
    return CEF_Send(playerid, "cef_chat_init", "{}");
}




stock bool:CEFC_IsServiceText(const text[])
{
    if(text[0] == '{')
    {
        if(strfind(text, "PTAG", true) == 1) return true;
        if(strfind(text, "SMASK", true) == 1) return true;
        if(strfind(text, "PTAGUI", true) == 1) return true;
    }
    if(!strcmp(text, "ACCESS:1", true)) return true;
    if(strfind(text, "ACCESS:", true) == 0) return true;
    if(strfind(text, "SET:", true) == 0) return true;
    if(strfind(text, "CLR:", true) == 0) return true;
    return false;
}

stock CEFC_ChatMessage(playerid, const text[], color = 0xFFFFFF)
{
    static json[600], esc[400];
    if(gCefMenuOpen[playerid]) return 1;
    if(CEFC_IsServiceText(text)) return 1;
    CEF_JsonEscape(text, esc);
    format(json, sizeof json,
        "{\"text\":\"%s\",\"textColor\":%d,\"textColorString\":\"#%06x\",\"highlighted\":false,\"duplicates\":0}",
        esc, color, color);
    return CEF_Send(playerid, "cef_chat_add_message", json);
}

forward CEFC_ChatKeepOpen(playerid);
public CEFC_ChatKeepOpen(playerid)
{
    if(!IsPlayerConnected(playerid) || !gCefChatInput[playerid] || gCefMenuOpen[playerid]) return 1;
    CEF_Send(playerid, "cef_chat_action", "{\"action\":0,\"data\":1}");
    CEF_Focus(playerid, true);
    return 1;
}

stock CEFC_ChatOpenInput(playerid)
{
    if(gCefMenuOpen[playerid]) return 1;
    CEFC_ChatSetDisabled(playerid, false);
    CEFC_ChatSetVisible(playerid, true);
    gCefChatInput[playerid] = true;
    CEF_Send(playerid, "cef_chat_action", "{\"action\":0,\"data\":1}");
    CEF_Focus(playerid, true);
    return 1;
}

stock CEFC_ChatCloseInput(playerid)
{
    gCefChatInput[playerid] = false;
    CEF_Send(playerid, "cef_chat_action", "{\"action\":0,\"data\":0}");
    if(!gCefMenuOpen[playerid] && !gCefCaseActive[playerid]) CEF_Focus(playerid, false);
    return 1;
}

stock CEFC_ChatSetVisible(playerid, bool:on)
{

    static json[64];
    format(json, sizeof json, "{\"action\":2,\"data\":%d}", on ? 2 : 0);
    return CEF_Send(playerid, "cef_chat_action", json);
}


stock CEFC_ChatSetDisabled(playerid, bool:off)
{
    static json[64];
    format(json, sizeof json, "{\"action\":6,\"data\":%d}", off ? 1 : 0);
    return CEF_Send(playerid, "cef_chat_action", json);
}

stock CEFC_ChatSetAdminLevel(playerid, level)
{
    static json[64];
    format(json, sizeof json, "{\"action\":3,\"data\":%d}", level);
    return CEF_Send(playerid, "cef_chat_action", json);
}


stock CEFC_AccountStats(playerid)
{









    static json[4096], part[320], nick[MAX_PLAYER_NAME + 8];
    new skin = GetPlayerSkin(playerid);
    if(skin <= 0) skin = PI[playerid][pSkin];
    CEF_JsonEscape(PI[playerid][pName], nick);

    format(json, sizeof json,
        "{\"general\":{\"id\":%d,\"nickname\":\"%s\",\"adminLevel\":%d,\"gender\":%d,",
        playerid, nick, PI[playerid][pAdmin], (PI[playerid][pSex] == 1) ? 0 : 1);

    format(part, sizeof part, "\"skinId\":%d,\"currentSkinId\":%d,\"skinCondition\":100,\"skinStyle\":0,\"skinEnchant\":0,",
        skin, skin);
    strcat(json, part);

    new lvl = PI[playerid][pLevel];
    if(lvl < 1) lvl = 1;
    new expNeed = lvl * 4;
    if(expNeed < 4) expNeed = 4;
    format(part, sizeof part, "\"level\":%d,\"experience\":%d,\"experienceMax\":%d,\"nextLevelExperience\":%d,\"maxLevel\":100,\"wantedLevel\":%d,\"unpaidFines\":%d,",
        lvl, PI[playerid][pExp], expNeed, expNeed, PI[playerid][pWanted], gCefFineN[playerid]);
    strcat(json, part);

    format(part, sizeof part, "\"cashMoney\":%d,\"bankMoney\":%d,\"vip\":%d,\"blackVip\":0,",
        PI[playerid][pCash], PI[playerid][pBank], (PI[playerid][pVip] > 0) ? 1 : 0);
    strcat(json, part);

    format(part, sizeof part, "\"militaryId\":%d,\"legalityLevel\":%d,\"convictionsCount\":0,\"drugsAddictLevel\":%d,\"warningsCount\":%d,",
        gCefMilitary[playerid], PI[playerid][pLegality], PI[playerid][pDrugAddiction], PI[playerid][pWarns]);
    strcat(json, part);

    format(part, sizeof part, "\"fractionId\":%d,\"fractionRankId\":%d,\"jobId\":0,\"phoneNumber\":%d,\"phoneBalance\":0,\"residencePlace\":\"\",\"business\":\"\",",
        PI[playerid][pFraction], PI[playerid][pFractionRank], 100000 + PI[playerid][pID]);
    strcat(json, part);


    {
        new famId = PI[playerid][pFamily], famEsc[40];
        famEsc[0] = EOS;
        if(famId > 0 && famId < MAX_FAMILY) CEF_JsonEscape(Family[famId][famName], famEsc);
        format(part, sizeof part, "\"family\":{\"name\":\"%s\",\"uniqueId\":%d},\"company\":{\"name\":\"\",\"companyType\":0,\"uniqueId\":0}},", famEsc, famId);
        strcat(json, part);
    }


    format(part, sizeof part,
        "\"licenses\":{\"1\":%d,\"2\":%d,\"3\":%d,\"4\":0,\"5\":%d,\"6\":%d,\"7\":%d},",
        PI[playerid][pLicenseB] ? 1 : 0, PI[playerid][pLicenseA] ? 1 : 0, PI[playerid][pLicenseC] ? 1 : 0,
        PI[playerid][pLicenseFlight] ? 1 : 0, PI[playerid][pLicenseBusiness] ? 1 : 0,
        PI[playerid][pLicenseWeapon] ? 1 : 0);
    strcat(json, part);






    strcat(json, "\"jobsSkills\":{");
    new first = 1, prog, need, cefId;
    for(new sk = 0; sk < MAX_SKILLS; sk++)
    {
        switch(sk)
        {
            case SKILL_MINER:       cefId = 1;
            case SKILL_LOGGER:      cefId = 2;
            case SKILL_DIVER:       cefId = 3;
            case SKILL_FARMER:      cefId = 4;
            case SKILL_BUS:         cefId = 5;
            case SKILL_RAZVOZ:      cefId = 6;
            case SKILL_TRUCKER:     cefId = 7;
            case SKILL_TAXI:        cefId = 8;
            case SKILL_MECHANIC:    cefId = 9;
            case SKILL_FACTORY:     cefId = 10;
            case SKILL_CLEANER:     cefId = 11;
            case SKILL_CARJACK:     cefId = 31;
            case SKILL_COOK:        cefId = 34;
            case SKILL_FISHER:      cefId = 30;
            case SKILL_DONOR_BLOOD: cefId = 32;
            case SKILL_DONOR_SPERM: cefId = 33;
            default:                cefId = 0;
        }
        if(!cefId) continue;
        lvl = Skill_GetLevel(playerid, sk);
        Skill_GetProgress(playerid, sk, prog, need);
        format(part, sizeof part, "%s\"%d\":[%d,%d,%d]", first ? ("") : (","), cefId, lvl, prog, (need > 0) ? need : 1);
        strcat(json, part);
        first = 0;
    }
    strcat(json, "},");


    strcat(json, "\"characterCharacteristics\":{\"power\":0,\"stamina\":0},\"characterSkills\":{},\"vehicles\":[],\"settings\":[]}");
    return CEF_Send(playerid, "update_account_stats", json);
}

stock CEFC_HudStatus(playerid)
{
    static json[512], nick[MAX_PLAYER_NAME + 8], d[16], t[16];
    new y, m, dd, h, mi, s;
    getdate(y, m, dd); gettime(h, mi, s);
    format(d, sizeof d, "%02d.%02d.%04d", dd, m, y);
    format(t, sizeof t, "%02d:%02d", h, mi);
    CEF_JsonEscape(PI[playerid][pName], nick);
    format(json, sizeof json,
        "{\"date\":\"%s\",\"time\":\"%s\",\"nickname\":\"%s\",\"playerId\":%d,\"adminLevel\":%d,\"server\":0,\"fps\":0,\"isDamaged\":false}",
        d, t, nick, playerid, PI[playerid][pAdmin]);
    return CEF_Send(playerid, "cef_player_info_status_show", json);
}

stock CEFC_HudInfoSend(playerid)
{
    static json[400];
    new Float:hp, Float:arm;
    GetPlayerHealth(playerid, hp);
    GetPlayerArmour(playerid, arm);
    format(json, sizeof json,
        "{\"weaponId\":%d,\"ammoClip\":%d,\"ammoTotal\":%d,\"fireType\":0,\"health\":%d,\"armour\":%d,\"money\":%d,\"casinoChips\":%d,\"godmode\":false}",
        GetPlayerWeapon(playerid), GetPlayerAmmo(playerid), GetPlayerAmmo(playerid),
        floatround(hp), floatround(arm), PI[playerid][pCash], gCefCasinoChips[playerid]);
    return CEF_Send(playerid, "cef_player_info_show", json);
}


forward CEFC_HideSampHud(playerid);
public CEFC_HideSampHud(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;
    OFFHud_Int(playerid);
    return 1;
}

stock CEFC_KeybindsShow(playerid)
{
    static json[900];
    format(json, sizeof json, "{\"tips\":[{\"key\":\"TAB\",\"action\":\"\\u0418\\u043d\\u0432\\u0435\\u043d\\u0442\\u0430\\u0440\\u044c\"},{\"key\":\"I\",\"action\":\"\\u0418\\u043d\\u0432\\u0435\\u043d\\u0442\\u0430\\u0440\\u044c\"},{\"key\":\"F1\",\"action\":\"\\u041f\\u0430\\u0443\\u0437\\u0430\"},{\"key\":\"F3\",\"action\":\"\\u041f\\u043e\\u043c\\u043e\\u0449\\u044c\"},{\"key\":\"F6\",\"action\":\"\\u0427\\u0430\\u0442\"},{\"key\":\"X\",\"action\":\"\\u0410\\u043d\\u0438\\u043c\\u0430\\u0446\\u0438\\u0438\"},{\"key\":\"M\",\"action\":\"\\u041a\\u0430\\u0440\\u0442\\u0430\"},{\"key\":\"F\",\"action\":\"\\u0414\\u0435\\u0439\\u0441\\u0442\\u0432\\u0438\\u0435\"}],\"left\":0.15,\"bottom\":0.048}");
    return CEF_Send(playerid, "cef_keybinds_hint_show", json);
}

stock CEFC_KeybindsHide(playerid)
{
    return CEF_SendEmpty(playerid, "cef_keybinds_hint_hide");
}

stock CEFC_HudActive(playerid, bool:on)
{
    static json[64];
    format(json, sizeof json, "{\"all\":%d}", on ? 1 : 0);
    CEF_Send(playerid, "cef_player_info_status_set_visibility", json);
    if(on)
    {
        CEFC_HideSampHud(playerid);
        SetTimerEx("CEFC_HideSampHud", 300, false, "i", playerid);
        SetTimerEx("CEFC_HideSampHud", 1200, false, "i", playerid);
        SetTimerEx("CEFC_HideSampHud", 2500, false, "i", playerid);
        CEFC_HudStatus(playerid);
        CEFC_AccountStats(playerid);
        CEFC_ChatInit(playerid);
        CEFC_ChatSetDisabled(playerid, false);
        CEFC_ChatSetVisible(playerid, true);
        CEFC_ChatSetAdminLevel(playerid, PI[playerid][pAdmin]);
        CEFC_OfferHide(playerid);
        CEFC_KeybindsShow(playerid);
    }
    else CEFC_KeybindsHide(playerid);
    return 1;
}

stock CEFC_HudUpdate(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;
    CEFC_AccountStats(playerid);
    CEF_CurrencySend(playerid);
    CEFC_HudStatus(playerid);
    if(gCefcHudFull[playerid]) CEFC_HudInfoSend(playerid);
    return 1;
}


stock CEFC_OfferShow(playerid, const nickname[], const text[], bool:fromMe, timeMs = 15000)
{
    static json[520], n[64], t[256];
    CEF_JsonEscape(nickname, n);
    CEF_JsonEscape(text, t);
    format(json, sizeof json, "{\"nickname\":\"%s\",\"text\":\"%s\",\"fromMe\":%s,\"time\":%d}",
        n, t, fromMe ? ("true") : ("false"), (timeMs < 1000) ? (timeMs * 1000) : timeMs);
    return CEF_Send(playerid, "cef_offer_notification_show", json);
}

stock CEFC_OfferHide(playerid)
{
    return CEF_SendEmpty(playerid, "cef_offer_notification_hide");
}


stock CEFC_PropertyInfo(playerid, icon, const title[], const name[], bool:locked, const actionText[])
{
    static json[700], t[96], n[96], a[96];
    CEF_JsonEscape(title, t);
    CEF_JsonEscape(name, n);
    CEF_JsonEscape(actionText, a);
    format(json, sizeof json,
        "{\"icon\":%d,\"title\":\"%s\",\"name\":\"%s\",\"isLocked\":%s,\"actionKey\":\"E\",\"actionText\":\"%s\",\"prohibited\":false,\"items\":[]}",
        icon, t, n, locked ? ("true") : ("false"), a);
    return CEF_Send(playerid, "cef_property_info_show", json);
}

stock CEFC_PropertyHide(playerid)
{
    return CEF_SendEmpty(playerid, "cef_property_info_hide");
}

stock CEFC_HouseInfo(playerid, houseId, lock, const owner[], price, pay, class, bool:free, bool:flat = false)
{
    static title[64], name[128], action[32];
    format(title, sizeof title, "%s #%d", flat ? ("Квартира") : ("Дом"), houseId);
    if(free) format(name, sizeof name, "Свободно - %d руб., класс %d", price, class);
    else format(name, sizeof name, "Владелец: %s, налог %d", owner, pay);
    if(free) action = "Купить";
    else action = "Войти";
    return CEFC_PropertyInfo(playerid, flat ? 5 : 3, title, name, lock != 0, action);
}


stock CEFC_SkinSelector(playerid, const skinsJson[])
{
    static json[1400];
    format(json, sizeof json, "{\"skins\":%s}", skinsJson);
    CEF_Send(playerid, "cef_skin_selector_show", json);
    CEF_Focus(playerid, true);
    return 1;
}


stock CEFC_SpeedometerShow(playerid)
{
    return CEFC_SpeedometerRefresh(playerid);
}

stock CEFC_SpeedometerHide(playerid)
{
    gCefSpeedoOn[playerid] = false;
    CEF_Send(playerid, "cef_speedometer_set_visible", "{\"visible\":false,\"value\":0}");
    return CEF_SendEmpty(playerid, "cef_speedometer_hide");
}

stock CEFC_SpeedometerRefresh(playerid)
{
    new vid = GetPlayerVehicleID(playerid);
    if(!vid || gCefMenuOpen[playerid]) return CEFC_SpeedometerHide(playerid);
    new Float:vx, Float:vy, Float:vz, Float:hp;
    static json[640];
    GetVehicleVelocity(vid, vx, vy, vz);
    GetVehicleHealth(vid, hp);
    new speed = floatround(floatsqroot(vx * vx + vy * vy + vz * vz) * 180.0);
    if(speed < 0) speed = 0;
    new strength = floatround((hp - 250.0) / 750.0 * 1000.0);
    if(strength < 0) strength = 0;
    if(strength > 1000) strength = 1000;
    format(json, sizeof json,
        "{\"speed\":%d,\"maxSpeed\":220,\"fuelType\":1,\"fuelCapacity\":%d,\"fuelValue\":%d,\"strength\":%d,\"mileage\":%d,\"turnsMode\":0,\"staging\":0,\"doorsLocked\":%s,\"engineEnabled\":%s,\"headlightsMode\":%d,\"nitro\":0,\"visible\":true}",
        speed, CEF_GAS_MAX, CI[vid][Fuel], strength, CI[vid][vMileage],
        CI[vid][Doors] ? ("true") : ("false"),
        CI[vid][Engine] ? ("true") : ("false"),
        CI[vid][Lights] ? 1 : 0);
    gCefSpeedoOn[playerid] = true;
    CEF_Send(playerid, "cef_speedometer_show", json);
    return CEF_Send(playerid, "cef_speedometer_update", json);
}


stock CEFC_RadialOpen(playerid, const itemsJson[])
{
    static json[1600];
    format(json, sizeof json, "{\"isFirstStep\":true,\"interaction\":0,\"items\":%s}", itemsJson);
    CEF_Send(playerid, "cef_radial_menu_open", json);
    CEF_Focus(playerid, true);
    return 1;
}



forward CEFC_MenuCamAnim(playerid);
public CEFC_MenuCamAnim(playerid)
{
    if(!IsPlayerConnected(playerid) || !gCefCamOn[playerid]) return 1;
    CEFC_MenuCamApply(playerid);
    CEFC_MenuStand(playerid);
    return 1;
}

stock CEFC_MenuStand(playerid)
{

    ApplyAnimation(playerid, "PED", "IDLE_STANCE", 4.1, 1, 0, 0, 1, 0, 1);
    return 1;
}

stock CEFC_MenuCamApply(playerid)
{
    new Float:x, Float:y, Float:z, Float:a, Float:cx, Float:cy, Float:cz;
    new Float:fx, Float:fy, Float:rx, Float:ry, Float:lx, Float:ly;
    if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING)
        TogglePlayerSpectating(playerid, 0);
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);
    fx = floatsin(-a, degrees);
    fy = floatcos(-a, degrees);
    rx = fy;
    ry = -fx;

    lx = x + rx * 1.70;
    ly = y + ry * 1.70;
    cx = lx + fx * 2.55;
    cy = ly + fy * 2.55;
    cz = z + 0.62;
    SetPlayerCameraPos(playerid, cx, cy, cz);
    SetPlayerCameraLookAt(playerid, lx, ly, z + 0.48, CAMERA_CUT);
    return 1;
}

stock CEFC_MenuCamera(playerid, bool:on)
{
    if(on)
    {
        if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER || GetPlayerState(playerid) == PLAYER_STATE_PASSENGER)
            RemovePlayerFromVehicle(playerid);
        SetPlayerArmedWeapon(playerid, 0);
        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
        TogglePlayerSpectating(playerid, 0);
        TogglePlayerControllable(playerid, 0);
        gCefCamOn[playerid] = true;
        CEFC_MenuCamApply(playerid);
        CEFC_MenuStand(playerid);
        SetTimerEx("CEFC_MenuCamAnim", 50, false, "i", playerid);
        SetTimerEx("CEFC_MenuCamAnim", 150, false, "i", playerid);
        SetTimerEx("CEFC_MenuCamAnim", 350, false, "i", playerid);
        SetTimerEx("CEFC_MenuCamAnim", 700, false, "i", playerid);
        SetTimerEx("CEFC_MenuCamAnim", 1200, false, "i", playerid);
        SetTimerEx("CEFC_MenuCamAnim", 2000, false, "i", playerid);
        return 1;
    }
    if(!gCefCamOn[playerid]) return 1;
    gCefCamOn[playerid] = false;
    ClearAnimations(playerid);
    SetCameraBehindPlayer(playerid);
    TogglePlayerControllable(playerid, 1);
    return 1;
}

stock CEFC_MenuBegin(playerid)
{
    gCefMenuOpen[playerid] = true;
    gCefChatInput[playerid] = false;
    CEFC_ChatSetVisible(playerid, false);
    CEFC_ChatSetDisabled(playerid, true);
    CEF_Send(playerid, "cef_chat_action", "{\"action\":0,\"data\":0}");
    CEFC_SpeedometerHide(playerid);
    CEF_OpsQuickSlots(playerid, false);
    CEFC_MenuCamera(playerid, true);
    CEFC_KeybindsHide(playerid);
    return 1;
}

stock CEFC_OnMenuClosed(playerid)
{
    gCefChatInput[playerid] = false;
    CEFC_HideSampHud(playerid);
    CEFC_ChatSetDisabled(playerid, false);
    CEFC_ChatSetVisible(playerid, true);
    if(gCefCaseActive[playerid] || gCefCasePending[playerid])
    {
        gCefMenuOpen[playerid] = false;
        gCefTabClosedAt[playerid] = GetTickCount();
        CEF_Focus(playerid, true);
        TogglePlayerControllable(playerid, 0);
        CEFC_KeybindsHide(playerid);
        return 1;
    }
    gCefMenuOpen[playerid] = false;
    gCefTabClosedAt[playerid] = GetTickCount();
    CEFC_MenuCamera(playerid, false);
    CEF_Focus(playerid, false);
    CEF_Hide(playerid);
    CEFC_KeybindsShow(playerid);
    return 1;
}

stock CEFC_DocumentsClosed(playerid)
{
    CEF_SendEmpty(playerid, "cef_documents_close");
    CEF_Focus(playerid, false);
    return 1;
}


stock CEFC_RpcReply(playerid, const id[], const dataJson[])
{
    static json[1200];
    format(json, sizeof json, "{\"id\":\"%s\",\"data\":%s}", id, dataJson);
    return CEF_Send(playerid, "cef_rpc", json);
}

stock CEFC_OnRpc(playerid, const channel[], const arguments[])
{
    static id[32];
    new key;


    CEF_JsonTopStr(arguments, "id", id, sizeof id);
    key = CEF_EcoFindInt(arguments, "key");
    if(!strcmp(channel, "documents", true))
    {
        if(key == 1) CEFC_DocumentsClosed(playerid);
        CEFC_RpcReply(playerid, id, "null");
        return 1;
    }
    if(!strcmp(channel, "bank", true))
    {
        static data[512];
        CEF_OpsBankRpc(playerid, arguments, data, sizeof data);
        CEFC_RpcReply(playerid, id, data);
        return 1;
    }
    if(!strcmp(channel, "casino", true))
    {
        static casdata[256];
        CEF_CasinoRpc(playerid, arguments, casdata, sizeof casdata);
        CEFC_RpcReply(playerid, id, casdata);
        return 1;
    }
    if(!strcmp(channel, "cases", true))
    {
        static cdata[64];
        CEF_CasesRpc(playerid, arguments, cdata, sizeof cdata);
        CEFC_RpcReply(playerid, id, cdata);
        return 1;
    }
    if(!strcmp(channel, "shop", true))
    {
        static sdata[1800];
        CEF_DonateShopRpc(playerid, arguments, sdata, sizeof sdata);
        CEFC_RpcReply(playerid, id, sdata);
        return 1;
    }
    if(!strcmp(channel, "car_service", true))
    {

        static sdata[160];
        switch(key)
        {
            case 0: format(sdata, sizeof sdata, "[]");
            case 1: format(sdata, sizeof sdata, "{\"price\":15000}");
            case 2: format(sdata, sizeof sdata, "{\"result\":true}");
            default: format(sdata, sizeof sdata, "null");
        }
        CEFC_RpcReply(playerid, id, sdata);
        return 1;
    }
    if(!strcmp(channel, "auth", true))
    {
        static adata[256];
        CEF_AuthRpc(playerid, arguments, adata, sizeof adata);
        CEFC_RpcReply(playerid, id, adata);
        return 1;
    }
    if(!strcmp(channel, "tau_meter", true))
    {
        static tdata[320];
        CEF_TauMeterRpc(playerid, arguments, tdata, sizeof tdata);
        CEFC_RpcReply(playerid, id, tdata);
        return 1;
    }

    CEFC_RpcReply(playerid, id, "null");
    return 1;
}


stock CEFC_ProcessInfo(playerid, const title[], const description[], const timerTitle[],
                       curTime, maxTime, const postDescription[], const colorLeft[], const colorRight[])
{
    static json[900], t[96], d[192], tt[96], pd[96];
    CEF_JsonEscape(title, t);
    CEF_JsonEscape(description, d);
    CEF_JsonEscape(timerTitle, tt);
    CEF_JsonEscape(postDescription, pd);
    format(json, sizeof json,
        "{\"title\":\"%s\",\"preTitle\":\"\",\"postTitle\":\"\",\"description\":\"%s\",\"postDescription\":\"%s\",\"timerTitle\":\"%s\",\"timerText\":\"\",\"timerCurrentTime\":%d,\"timerMaxTime\":%d,\"colorLeft\":\"%s\",\"colorRight\":\"%s\"}",
        t, d, pd, tt, curTime, maxTime, colorLeft, colorRight);
    return CEF_Send(playerid, "cef_process_info_show", json);
}


stock CEFC_NotifyTitled(playerid, const title[], const text[], time = 5000)
{
    static json[700], e1[128], e2[256];
    CEF_JsonEscape(title, e1);
    CEF_JsonEscape(text, e2);
    if(time < 1000) time *= 1000;
    format(json, sizeof json,
        "{\"viewType\":\"push\",\"messageType\":\"info\",\"title\":\"%s\",\"text\":\"%s\",\"time\":%d,\"label\":\"\"}",
        e1, e2, time);
    return CEF_Send(playerid, "cef_notifications_show", json);
}

stock CEFC_NotifyCentered(playerid, const title[], const text[], const type[] = "error", time = 6000)
{
    static json[700], e1[128], e2[256], tp[24];
    CEF_JsonEscape(title, e1);
    CEF_JsonEscape(text, e2);
    CEF_JsonEscape(type, tp);
    if(!tp[0]) tp = "error";
    if(time < 1000) time *= 1000;
    format(json, sizeof json,
        "{\"viewType\":\"centered\",\"messageType\":\"%s\",\"title\":\"%s\",\"text\":\"%s\",\"time\":%d,\"label\":\"\"}",
        tp, e1, e2, time);
    return CEF_Send(playerid, "cef_notifications_show", json);
}


forward CEFC_HudTick();
forward CEF_NeedsOnSecond();
new gCefTabWarmTick;

forward CEFC_SpeedoTick();
public CEFC_SpeedoTick()
{
    foreach(new i : Player)
    {
        if(!PT[i][pLogged] || !gCefcAppReady[i]) continue;
        if(GetPlayerVehicleID(i)) CEFC_SpeedometerRefresh(i);
        else if(gCefSpeedoOn[i]) CEFC_SpeedometerHide(i);
    }
    return 1;
}

public CEFC_HudTick()
{
    gCefTabWarmTick++;
    foreach(new i : Player)
    {
        if(!PT[i][pLogged]) continue;
        CEFC_HideSampHud(i);
        CallLocalFunction("CEF_FinesHeartbeat", "i", i);
        if(!gCefcAppReady[i]) continue;
        CEFC_HudInfoSend(i);
        CEFC_HudStatus(i);
        if(GetPlayerVehicleID(i)) CEFC_SpeedometerRefresh(i);
        CEF_RadarPulse(i);
        if(gCefMenuOpen[i])
        {
            CEFC_MenuCamApply(i);
            CEFC_MenuStand(i);
            if((gCefTabWarmTick % 2) == 0) CEF_OpsPlayersList(i);
        }
        else if((gCefTabWarmTick % 4) == 0 && !gCefCaseActive[i])
        {
            CEF_TabPushData(i);
        }
    }
    CEF_NeedsOnSecond();
    return 1;
}

CMD:chatmode(playerid, params[])
{
    new spec[] = "d", mode = -1;
    if(sscanf(params, spec, mode) || mode < 0 || mode > 2)
    {
        SendClientMessage(playerid, 0x54B367FF, "/chatmode 0 - оба чата, 1 - только CEF (по умолчанию), 2 - только старый");
        return 1;
    }
    gCefcChatMode[playerid] = mode;
    CEFC_Notify(playerid, "Режим чата изменён.", "success");
    return 1;
}


CMD:cefhudfull(playerid, params[])
{
    #pragma unused params
    gCefcHudFull[playerid] = !gCefcHudFull[playerid];
    if(gCefcHudFull[playerid]) CEFC_HudInfoSend(playerid);
    else CEF_Send(playerid, "cef_player_info_set_visibility", "{\"all\":0}");
    SendClientMessage(playerid, 0x54B367FF, gCefcHudFull[playerid] ? ("Полный HUD SPA включен") : ("Полный HUD SPA выключен"));
    return 1;
}

CMD:chatcef(playerid, params[])
{
    #pragma unused params
    CEFC_ChatOpenInput(playerid);
    return 1;
}

CMD:chatcefclose(playerid, params[])
{
    #pragma unused params
    CEFC_ChatCloseInput(playerid);
    return 1;
}

CMD:usecef(playerid, params[])
{
    #pragma unused params
    CEF_LiveKeys(playerid, KEY_WALK, 0);
    return 1;
}

forward CEFC_ChatMarkClosed(playerid);
public CEFC_ChatMarkClosed(playerid)
{
    gCefChatInput[playerid] = false;
    return 1;
}

CMD:cursor(playerid, params[])
{
    #pragma unused params
    CEFC_ReleaseCursor(playerid);
    SendClientMessage(playerid, 0x54B367FF, "Курсор снят.");
    return 1;
}

CMD:cefdump(playerid, params[])
{
    #pragma unused params
    static msg[190];
    new Float:hp, Float:arm;
    GetPlayerHealth(playerid, hp);
    GetPlayerArmour(playerid, arm);
    format(msg, sizeof msg, "HUD: ник %s | ID %d | ур. %d | опыт %d | нал. %d | банк %d",
        PI[playerid][pName], PI[playerid][pID], PI[playerid][pLevel], PI[playerid][pExp],
        PI[playerid][pCash], PI[playerid][pBank]);
    SendClientMessage(playerid, 0x54B367FF, msg);
    format(msg, sizeof msg, "HUD: HP %d | броня %d | скин %d | фракция %d ранг %d | оружие %d патроны %d",
        floatround(hp), floatround(arm), GetPlayerSkin(playerid), PI[playerid][pFraction],
        PI[playerid][pFractionRank], GetPlayerWeapon(playerid), GetPlayerAmmo(playerid));
    SendClientMessage(playerid, 0x54B367FF, msg);
    format(msg, sizeof msg, "CEF: готов %d | полный HUD %d | режим чата %d | деньги в игре %d",
        gCefcAppReady[playerid], gCefcHudFull[playerid], gCefcChatMode[playerid], GetPlayerMoney(playerid));
    SendClientMessage(playerid, 0x54B367FF, msg);
    return 1;
}

CMD:cefstate(playerid, params[])
{
    #pragma unused params
    static msg[144];
    format(msg, sizeof msg, "SPA ready: %d | HUD full: %d | cash %d bank %d",
        gCefcAppReady[playerid], gCefcHudFull[playerid], PI[playerid][pCash], PI[playerid][pBank]);
    SendClientMessage(playerid, 0x54B367FF, msg);
    return 1;
}

CMD:cefreload(playerid, params[])
{
    #pragma unused params
    new url[] = MAIN_CEF_BROWSER_LINK, msg[160];
    cef_destroy_browser(playerid, MAIN_BROWSER);
    cef_create_browser(playerid, MAIN_BROWSER, url, false, false);
    format(msg, sizeof msg, "Перезагружаю CEF: %s", url);
    SendClientMessage(playerid, 0x54B367FF, msg);
    return 1;
}

CMD:cefurl(playerid, params[])
{
    #pragma unused params
    new msg[160];
    format(msg, sizeof msg, "URL главного окна: %s | плагин: %d | загружен: %d",
        MAIN_CEF_BROWSER_LINK, cef_player_has_plugin(playerid), PT[playerid][pCefLoaded]);
    SendClientMessage(playerid, 0x54B367FF, msg);
    return 1;
}

CMD:cefdialogtest(playerid, params[])
{
    #pragma unused params
    CEFC_Dialog(playerid, 29997, 0, "Проверка", "Диалог SPA работает.", "ОК", "Отмена");
    return 1;
}


stock CEFC_ChatBoth(playerid, color, const text[])
{
    if(gCefMenuOpen[playerid]) return 1;
    if(gCefcAppReady[playerid])
    {
        CEFC_ChatMessage(playerid, text, color >>> 8);
        return 1;
    }
    return SCM_Native(playerid, color, text);
}

stock CEFC_ChatBothAll(color, const text[])
{
    foreach(new i : Player) CEFC_ChatBoth(i, color, text);
    return 1;
}
