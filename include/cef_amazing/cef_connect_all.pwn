#if defined _cef_connect_all_included
    #endinput
#endif
#define _cef_connect_all_included

forward CEF_AllUiResponse(playerid, const event[], const arguments[]);
forward CEF_AllSysOpen(playerid, const sys[]);







new gCefAllRepTick[MAX_PLAYERS];
new gCefAllAdTick[MAX_PLAYERS];
new gCefAllPin[MAX_PLAYERS];

stock CEF_AllStem(const event[], dest[], size = sizeof dest)
{
    new p = strfind(event, "_response");
    if(p < 0) p = strlen(event);
    dest[0] = EOS;
    if(p >= size) p = size - 1;
    strmid(dest, event, 0, p, size);
    return 1;
}

stock CEF_AllCloseUi(playerid, const event[])
{
    static stem[64], ev[80];
    CEF_AllStem(event, stem);
    if(stem[0])
    {
        format(ev, sizeof ev, "%s_hide", stem);
        CEF_SendEmpty(playerid, ev);
        format(ev, sizeof ev, "%s_close", stem);
        CEF_SendEmpty(playerid, ev);
    }
    if(!strcmp(stem, "cef_admin_panel")) gCefAdminPanelOpen[playerid] = false;
    if(!strcmp(stem, "cef_support")) gCefSupportPanelOpen[playerid] = false;
    CEF_Focus(playerid, false);
    return 1;
}

public CEF_AdminPanelClose(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS) return 0;
    if(!gCefAdminPanelOpen[playerid]) return 0;
    gCefAdminPanelOpen[playerid] = false;
    CEF_SendEmpty(playerid, "cef_admin_panel_hide");
    CEF_Focus(playerid, false);
    CEF_Hide(playerid);
    return 1;
}

public CEF_SupportClose(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS) return 0;
    if(!gCefSupportPanelOpen[playerid]) return 0;
    gCefSupportPanelOpen[playerid] = false;
    CEF_SendEmpty(playerid, "cef_support_hide");
    CEF_Focus(playerid, false);
    CEF_Hide(playerid);
    return 1;
}

stock CEF_AllCloseConflictingUi(playerid)
{
    if(gCefcDialogId[playerid] != -1) CEFC_DialogClose(playerid);
    if(gCefInventoryRouteOpen[playerid] || gCefInventoryPendingOpen[playerid]) CEF_InventoryClose(playerid, true);
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
    if(gCefChatInput[playerid]) CEFC_ChatCloseInput(playerid);
    return 1;
}

stock CEF_AllAnimApply(playerid, idx)
{
    ClearAnimations(playerid);
    switch(idx)
    {
        case 0:  ApplyAnimation(playerid, "PED", "IDLE_CHAT", 4.1, 1, 0, 0, 0, 0, 1);
        case 1:  ApplyAnimation(playerid, "DANCING", "dnce_M_a", 4.1, 1, 0, 0, 0, 0, 1);
        case 2:  ApplyAnimation(playerid, "BEACH", "ParkSit_M_loop", 4.1, 1, 0, 0, 0, 0, 1);
        case 3:  ApplyAnimation(playerid, "GANGS", "leanIDLE", 4.1, 1, 0, 0, 0, 0, 1);
        case 4:  ApplyAnimation(playerid, "SMOKING", "M_smk_in", 4.1, 0, 0, 0, 0, 0, 1);
        case 5:  ApplyAnimation(playerid, "ON_LOOKERS", "wave_loop", 4.1, 1, 0, 0, 0, 0, 1);
        case 6:  ApplyAnimation(playerid, "GHANDS", "gsign1LH", 4.1, 0, 0, 0, 0, 0, 1);
        case 7:  ApplyAnimation(playerid, "PAULNMAC", "Piss_in", 4.1, 0, 0, 0, 0, 0, 1);
        case 8:  ApplyAnimation(playerid, "CRACK", "crckidle2", 4.1, 1, 0, 0, 0, 0, 1);
        case 9:  ApplyAnimation(playerid, "PED", "XPRESSscratch", 4.1, 0, 0, 0, 0, 0, 1);
        case 10: ApplyAnimation(playerid, "FOOD", "EAT_Burger", 4.1, 0, 0, 0, 0, 0, 1);
        case 11: ApplyAnimation(playerid, "COP_AMBIENT", "Coplook_loop", 4.1, 1, 0, 0, 0, 0, 1);
        default: ClearAnimations(playerid);
    }
    return 1;
}

public CEF_AllAnimsOpen(playerid)
{
    static json[900];
    json = "{\"categories\":[{\"id\":0,\"name\":\"Стойки\"},{\"id\":1,\"name\":\"Жесты\"}],\"items\":[";
    strcat(json, "{\"id\":0,\"name\":\"Разговор\",\"category\":0},");
    strcat(json, "{\"id\":1,\"name\":\"Танец\",\"category\":1},");
    strcat(json, "{\"id\":2,\"name\":\"Сидеть\",\"category\":0},");
    strcat(json, "{\"id\":3,\"name\":\"Опереться\",\"category\":0},");
    strcat(json, "{\"id\":4,\"name\":\"Курить\",\"category\":1},");
    strcat(json, "{\"id\":5,\"name\":\"Привет\",\"category\":1},");
    strcat(json, "{\"id\":6,\"name\":\"Жест\",\"category\":1},");
    strcat(json, "{\"id\":7,\"name\":\"Писс\",\"category\":1},");
    strcat(json, "{\"id\":8,\"name\":\"Лежать\",\"category\":0},");
    strcat(json, "{\"id\":9,\"name\":\"Чесать\",\"category\":1},");
    strcat(json, "{\"id\":10,\"name\":\"Есть\",\"category\":1},");
    strcat(json, "{\"id\":11,\"name\":\"Коп\" ,\"category\":0}]}");
    CEF_MarkPlayerReady(playerid);
    CEF_Send(playerid, "cef_animations_menu_show", json);
    CEF_Send(playerid, "cef_emotes_menu_open", json);
    CEF_Focus(playerid, true);
    return 1;
}

public CEF_AllSupportOpen(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) || !PT[playerid][pLogged]) return 0;
    CEF_AllCloseConflictingUi(playerid);
    static json[192];
    new uid = PI[playerid][pID];
    if(uid < 1) uid = playerid + 1;
    CEF_MarkPlayerReady(playerid);
    CEF_Show(playerid, false);
    format(json, sizeof json, "{\"type\":0}");
    CEF_Send(playerid, "cef_support_show", json);
    format(json, sizeof json, "{\"adminLevel\":%d,\"userId\":%d}", PI[playerid][pAdmin], uid);
    CEF_Send(playerid, "cef_support_send_player_info", json);
    gCefSupportPanelOpen[playerid] = true;
    CEF_Focus(playerid, true);
    return 1;
}

public CEF_AllAdminOpen(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) || !PT[playerid][pLogged]) return 0;
    if(PI[playerid][pAdmin] < 1)
    {
        CEFC_Notify(playerid, "У вас нет доступа.", "error", 4000);
        return 1;
    }
    CEF_AllCloseConflictingUi(playerid);
    static json[8192], part[160], nick[48];
    json = "{\"adminLevel\":";
    format(part, sizeof part, "%d,\"players\":[", PI[playerid][pAdmin]);
    strcat(json, part);
    new first = 1, listed = 0;
    for(new i = 0; i < MAX_PLAYERS && listed < 48; i++)
    {
        if(!IsPlayerConnected(i) || !PT[i][pLogged]) continue;
        CEF_JsonNick(i, nick);
        format(part, sizeof part, "%s{\"id\":%d,\"name\":\"%s\"}", first ? "" : ",", i, nick);
        if(strlen(json) + strlen(part) + 4 >= sizeof json) break;
        strcat(json, part);
        first = 0;
        listed++;
    }
    strcat(json, "]}");
    CEF_MarkPlayerReady(playerid);
    CEF_Show(playerid, false);
    CEF_Send(playerid, "cef_admin_panel_show", json);
    gCefAdminPanelOpen[playerid] = true;
    CEF_Focus(playerid, true);
    return 1;
}

public CEF_AllAdsOpen(playerid)
{
    static json[220];
    format(json, sizeof json, "{\"balance\":%d,\"price\":3000,\"maxLength\":80}", PI[playerid][pCash]);
    CEF_MarkPlayerReady(playerid);
    CEF_Send(playerid, "cef_ads_edit_show", json);
    CEF_Focus(playerid, true);
    return 1;
}

stock CEF_AllSkinOpen(playerid)
{
    static json[400];
    json = "{\"skins\":[{\"id\":14},{\"id\":20},{\"id\":21},{\"id\":22},{\"id\":24},{\"id\":25},{\"id\":12},{\"id\":13},{\"id\":226},{\"id\":56}]}";
    CEFC_SkinSelector(playerid, "[{\"id\":14},{\"id\":20},{\"id\":21},{\"id\":22},{\"id\":24},{\"id\":25},{\"id\":12},{\"id\":13},{\"id\":226},{\"id\":56}]");
    #pragma unused json
    return 1;
}

forward CEF_AllSkinRegister(playerid);
public CEF_AllSkinRegister(playerid)
{
    if(!IsPlayerConnected(playerid)) return 1;
    if(gCefAuthActive[playerid]) return 1;
    CEF_AllSkinOpen(playerid);
    return 1;
}

stock CEF_AllBooksOpen(playerid)
{
    static json[320];
    json = "{\"books\":[{\"id\":1,\"name\":\"Правила сервера\",\"pages\":4},{\"id\":2,\"name\":\"Работы\",\"pages\":3},{\"id\":3,\"name\":\"Фракции\",\"pages\":3}]}";
    CEF_MarkPlayerReady(playerid);
    CEF_Send(playerid, "cef_books_show", json);
    CEF_Focus(playerid, true);
    return 1;
}

stock CEF_AllToolsOpen(playerid)
{
    static json[200];
    format(json, sizeof json, "{\"level\":%d,\"cash\":%d}", PI[playerid][pLevel], PI[playerid][pCash]);
    CEF_MarkPlayerReady(playerid);
    CEF_Send(playerid, "cef_tools_show", json);
    CEF_Focus(playerid, true);
    return 1;
}

stock CEF_AllTrashOpen(playerid)
{
    static json[160];
    format(json, sizeof json, "{\"rate\":50,\"cash\":%d}", PI[playerid][pCash]);
    CEF_MarkPlayerReady(playerid);
    CEF_Send(playerid, "cef_trash_exchanger_show", json);
    CEF_Focus(playerid, true);
    return 1;
}

stock CEF_AllPinOpen(playerid)
{
    gCefAllPin[playerid] = 1000 + (playerid % 9000);
    static json[96];
    format(json, sizeof json, "{\"length\":4,\"mode\":1}");
    CEF_MarkPlayerReady(playerid);
    CEF_Send(playerid, "cef_pin_code_open", json);
    CEF_Focus(playerid, true);
    return 1;
}

stock CEF_AllPneumoOpen(playerid)
{
    if(!IsPlayerInAnyVehicle(playerid))
    {
        CEFC_Notify(playerid, "Нужен транспорт.", "hint", 3000);
        return 1;
    }
    CEF_MarkPlayerReady(playerid);
    CEF_Send(playerid, "cef_car_pneumo_control_open", "{\"enabled\":1}");
    CEF_Focus(playerid, true);
    return 1;
}

stock CEF_AllTradeOpen(playerid)
{
    new near = -1, i;
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    for(i = 0; i < MAX_PLAYERS; i++)
    {
        if(i == playerid || !IsPlayerConnected(i) || !PT[i][pLogged]) continue;
        if(GetPlayerVirtualWorld(i) != GetPlayerVirtualWorld(playerid)) continue;
        if(GetPlayerInterior(i) != GetPlayerInterior(playerid)) continue;
        if(GetPlayerDistanceFromPoint(i, x, y, z) <= 5.0) { near = i; break; }
    }
    if(near < 0)
    {
        CEFC_Notify(playerid, "No logged-in player is close enough to trade.", "hint", 4000);
        return 1;
    }
    return CEF_TradeOpenPair(playerid, near);
}

stock CEF_AllBroadcastAd(playerid, const text[])
{
    static msg[144], nick[24];
    if(GetTickCount() - gCefAllAdTick[playerid] < 15000)
    {
        CEFC_Notify(playerid, "Не так часто.", "hint", 3000);
        return 1;
    }
    if(PI[playerid][pCash] < 3000)
    {
        CEFC_Notify(playerid, "Нужно 3000 руб. на объявление.", "error", 4000);
        return 1;
    }
    PI[playerid][pCash] -= 3000;
    CEF_EcoSaveMoney(playerid);
    gCefAllAdTick[playerid] = GetTickCount();
    CEF_JsonNick(playerid, nick);
    format(msg, sizeof msg, "[ADS] %s: %s", nick, text);
    SendClientMessageToAll(0x54B367FF, msg);
    CEFC_Notify(playerid, "Объявление опубликовано.", "info", 4000);
    return 1;
}

stock CEF_AllSendReport(playerid, const text[])
{
    static msg[144], nick[24];
    if(GetTickCount() - gCefAllRepTick[playerid] < 8000)
    {
        CEFC_Notify(playerid, "Подождите с репортом.", "hint", 3000);
        return 1;
    }
    gCefAllRepTick[playerid] = GetTickCount();
    CEF_JsonNick(playerid, nick);
    format(msg, sizeof msg, "[REPORT] %s [%d]: %s", nick, playerid, text);
    new i;
    for(i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && PT[i][pLogged] && PI[i][pAdmin] >= 1)
            SendClientMessage(i, 0xFFAA00FF, msg);
    }
    CEFC_Notify(playerid, "Репорт отправлен админам.", "info", 4000);
    printf("[CEF-REPORT] %s", msg);
    return 1;
}

stock CEF_AllExtractText(const arguments[], dest[], size = sizeof dest)
{
    dest[0] = EOS;
    if(!CEF_JsonStr(arguments, "text", dest, size))
        if(!CEF_JsonStr(arguments, "message", dest, size))
            if(!CEF_JsonStr(arguments, "value", dest, size))
                if(!CEF_JsonStr(arguments, "input", dest, size))
                    format(dest, size, "%s", arguments);
    return dest[0] != EOS;
}

public CEF_AllUiResponse(playerid, const event[], const arguments[])
{
    if(!IsPlayerConnected(playerid)) return 1;
    printf("[CEF-ALL] %d %s %s", playerid, event, arguments);

    if(!strcmp(event, "cef_prize_menu_response", true))
        return CEF_PrizesResponse(playerid, arguments);

    if(!strcmp(event, "cef_skin_selector_response", true))
    {
        new skin = CEF_EcoFindInt(arguments, "skinId");
        if(!skin) skin = CEF_EcoFindInt(arguments, "id");
        if(!skin) skin = CEF_EcoFindInt(arguments, "selected");
        new action = CEF_EcoFindInt(arguments, "action");
        if(skin > 0)
        {
            SetPlayerSkin(playerid, skin);
            PI[playerid][pSkin] = skin;
            PT[playerid][pIsPlayerChoosingRegisterSkin] = false;
        }
        CEF_SendEmpty(playerid, "cef_skin_selector_hide");
        CEF_Focus(playerid, false);
        #pragma unused action
        return 1;
    }

    if(!strcmp(event, "cef_animations_menu_response", true) || !strcmp(event, "cef_emotes_menu_response", true))
    {
        new idx = CEF_EcoFindInt(arguments, "id");
        if(!idx) idx = CEF_EcoFindInt(arguments, "animId");
        if(!idx) idx = CEF_EcoFindInt(arguments, "selected");
        new key = CEF_EcoFindInt(arguments, "key");
        if(key == 0) ClearAnimations(playerid);
        else CEF_AllAnimApply(playerid, idx);
        CEF_AllCloseUi(playerid, event);
        return 1;
    }

    if(!strcmp(event, "cef_support_response", true))
    {
        new key = CEF_EcoFindInt(arguments, "key");
        if(key == 0)
        {
            CEF_SupportClose(playerid);
            return 1;
        }
        if(key == 1)
        {
            if(PI[playerid][pAdmin] >= 1)
            {
                static js[48];
                format(js, sizeof js, "{\"type\":1}");
                CEF_Send(playerid, "cef_support_show", js);
            }
            return 1;
        }
        if(key == 3)
        {
            static txt[144];
            CEF_JsonStr(arguments, "text", txt, sizeof txt);
            if(strlen(txt) > 0) CEF_AllSendReport(playerid, txt);
            return 1;
        }
        return 1;
    }

    if(!strcmp(event, "cef_ads_edit_response", true))
    {
        static txt[80];
        CEF_AllExtractText(arguments, txt);
        if(strlen(txt) > 1) CEF_AllBroadcastAd(playerid, txt);
        CEF_AllCloseUi(playerid, event);
        return 1;
    }

    if(!strcmp(event, "cef_admin_panel_response", true))
    {
        new action = CEF_EcoFindInt(arguments, "action");
        new value = CEF_EcoFindInt(arguments, "data");
        new key = CEF_EcoFindInt(arguments, "key");
        new tid = CEF_EcoFindInt(arguments, "id");
        if(!tid) tid = CEF_EcoFindInt(arguments, "playerId");
        if(key == 0 && action == 2) key = 2;
        if(tid == 0 && key == 2 && value >= 0) tid = value;
        if(PI[playerid][pAdmin] >= 2 && key == 2 && tid >= 0 && tid < MAX_PLAYERS && IsPlayerConnected(tid) && PT[tid][pLogged])
        {
            new Float:x, Float:y, Float:z;
            GetPlayerPos(tid, x, y, z);
            SetPlayerPos(playerid, x + 1.0, y, z);
        }
        if(action == 0 || (action == 4 && value == 27)) CEF_AdminPanelClose(playerid);
        return 1;
    }

    if(!strcmp(event, "cef_ratings_response", true) || !strcmp(event, "cef_leaderboard_response", true))
    {
        CEF_OpsTopResponse(playerid, arguments);
        CEF_AllCloseUi(playerid, event);
        return 1;
    }

    if(!strcmp(event, "cef_quick_map_response", true))
    {
        CEF_OpsMapToggle(playerid);
        CEF_AllCloseUi(playerid, event);
        return 1;
    }

    if(!strcmp(event, "cef_shop_selector_response", true))
    {
        CEF_EcoShopResponse(playerid, arguments);
        return 1;
    }

    if(!strcmp(event, "cef_sawmill_response", true) || !strcmp(event, "cef_mining_farm_response", true) || !strcmp(event, "cef_cargo_aggregator_response", true) || !strcmp(event, "cef_tools_response", true))
    {
        CEF_EcoJobResponse(playerid, arguments);
        CEF_AllCloseUi(playerid, event);
        return 1;
    }

    if(!strcmp(event, "cef_pin_code_response", true))
    {
        new pin = CEF_EcoFindInt(arguments, "pin");
        if(!pin) pin = CEF_EcoFindInt(arguments, "code");
        if(!pin) pin = CEF_EcoFindInt(arguments, "value");
        if(pin == gCefAllPin[playerid] || pin > 0)
            CEFC_Notify(playerid, "Код принят.", "info", 3000);
        CEF_AllCloseUi(playerid, event);
        return 1;
    }

    if(!strcmp(event, "cef_books_response", true))
    {
        PI[playerid][pExp] += 1;
        CEFC_Notify(playerid, "Вы прочитали главу (+1 эксп).", "info", 3000);
        CEF_AllCloseUi(playerid, event);
        return 1;
    }

    if(!strcmp(event, "cef_trash_exchanger_response", true))
    {
        PI[playerid][pCash] += 50;
        CEF_EcoSaveMoney(playerid);
        CEFC_Notify(playerid, "+50 руб. за утиль.", "info", 3000);
        CEF_AllCloseUi(playerid, event);
        return 1;
    }

    if(!strcmp(event, "cef_car_pneumo_control_response", true))
    {
        new vid = GetPlayerVehicleID(playerid);
        if(vid) AddVehicleComponent(vid, 1087);
        CEF_AllCloseUi(playerid, event);
        return 1;
    }

    if(!strcmp(event, "cef_trade_response", true))
    {
        return CEF_TradeHandleResponse(playerid, arguments);
    }

    if(!strcmp(event, "cef_device_settings_response", true) || !strcmp(event, "cef_voice_chat_settings_response", true) || !strcmp(event, "cef_first_cam_settings_response", true) || !strcmp(event, "cef_weapons_sound_response", true))
    {
        CEF_AllCloseUi(playerid, event);
        return 1;
    }

    if(!strcmp(event, "cef_tutorial_response", true) || !strcmp(event, "cef_fullscreen_text_response", true) || !strcmp(event, "cef_quest_dialogs_response", true) || !strcmp(event, "cef_notary_response", true))
    {
        CEF_AllCloseUi(playerid, event);
        return 1;
    }

    if(!strcmp(event, "cef_skin_viewer_response", true) || !strcmp(event, "cef_screenshot_viewer_response", true) || !strcmp(event, "cef_object_inspection_response", true) || !strcmp(event, "cef_video_player_response", true) || !strcmp(event, "cef_music_player_response", true))
    {
        CEF_AllCloseUi(playerid, event);
        return 1;
    }

    if(!strcmp(event, "cef_tablet_note_response", true) || !strcmp(event, "cef_event_market_response", true) || !strcmp(event, "cef_sys_notification_response", true) || !strcmp(event, "cef_fractions_contest_response", true) || !strcmp(event, "cef_shoulder_straps_response", true))
    {
        CEF_AllCloseUi(playerid, event);
        return 1;
    }

    if(!strcmp(event, "cef_lock_turning_response", true) || !strcmp(event, "cef_quick_time_events_response", true) || !strcmp(event, "cef_press_on_time_game_response", true) || !strcmp(event, "cef_reaction_game_response", true))
    {
        CEFC_Notify(playerid, "Мини-игра завершена.", "info", 3000);
        CEF_AllCloseUi(playerid, event);
        return 1;
    }


    CEF_AllCloseUi(playerid, event);
    return 1;
}

public CEF_AllSysOpen(playerid, const sys[])
{
    if(!strcmp(sys, "SYS_animations_menu") || !strcmp(sys, "SYS_emotes_menu")) return CEF_AllAnimsOpen(playerid);
    if(!strcmp(sys, "SYS_support")) return CEF_AllSupportOpen(playerid);
    if(!strcmp(sys, "SYS_admin_panel")) return CEF_AllAdminOpen(playerid);
    if(!strcmp(sys, "SYS_ads_edit")) return CEF_AllAdsOpen(playerid);
    if(!strcmp(sys, "SYS_skin_selector") || !strcmp(sys, "SYS_skin_viewer")) return CEF_AllSkinOpen(playerid);
    if(!strcmp(sys, "SYS_books")) return CEF_AllBooksOpen(playerid);
    if(!strcmp(sys, "SYS_tools")) return CEF_AllToolsOpen(playerid);
    if(!strcmp(sys, "SYS_trash_exchanger")) return CEF_AllTrashOpen(playerid);
    if(!strcmp(sys, "SYS_pin_code")) return CEF_AllPinOpen(playerid);
    if(!strcmp(sys, "SYS_car_pneumo_control")) return CEF_AllPneumoOpen(playerid);
    if(!strcmp(sys, "SYS_trade")) return CEF_AllTradeOpen(playerid);
    if(!strcmp(sys, "SYS_ratings") || !strcmp(sys, "SYS_leaderboard")) return CEF_OpsTopOpen(playerid);
    if(!strcmp(sys, "SYS_quick_map")) return CEF_OpsMapToggle(playerid);
    if(!strcmp(sys, "SYS_prize_menu")) return CEF_PrizesSend(playerid, false);
    if(!strcmp(sys, "SYS_sawmill") || !strcmp(sys, "SYS_job_crafting") || !strcmp(sys, "SYS_cargo_aggregator") || !strcmp(sys, "SYS_mining")) return CEF_EcoJobOpen(playerid);
    if(!strcmp(sys, "SYS_shop_selector") || !strcmp(sys, "SYS_shop_menu")) return CEF_EcoShopOpen(playerid);
    if(!strcmp(sys, "SYS_bank")) return CEF_OpsBankOpen(playerid, false);
    if(!strcmp(sys, "SYS_atm")) return CEF_OpsAtmOpen(playerid);
    if(!strcmp(sys, "SYS_car_service")) return CEF_OpsServiceOpen(playerid);
    if(!strcmp(sys, "SYS_gs_fueling_menu")) return CEF_EcoGasOpen(playerid);
    if(!strcmp(sys, "SYS_esc")) return CEF_OpsEscOpen(playerid);
    if(!strcmp(sys, "SYS_radial_menu")) return CEF_OpenRadialCef(playerid);
    if(!strcmp(sys, "SYS_inventory")) return OpenTabCEF(playerid, 2);
    if(!strcmp(sys, "SYS_documents")) return CEF_LivePassport(playerid, playerid);
    if(!strcmp(sys, "SYS_weapon_storage")) return CEF_OpsStorageOpen(playerid);
    if(!strcmp(sys, "SYS_frc_players_list") || !strcmp(sys, "SYS_frc_members_list")) return CEF_OpsMembersOpen(playerid);
    if(!strcmp(sys, "SYS_cases")) return OpenTabCEF(playerid, 2);
    if(!strcmp(sys, "SYS_perks")) return CEF_PerksSend(playerid);
    if(!strcmp(sys, "SYS_mini_battle_pass") || !strcmp(sys, "SYS_mini_battle_pass_upd_tasks"))
    {
        CEF_OpenBattlePassCef(playerid);
        return CEF_TasksSend(playerid);
    }
    if(!strcmp(sys, "SYS_chat")) return CEFC_ChatOpenInput(playerid);
    if(!strcmp(sys, "SYS_license")) return CEF_LiveLicenses(playerid, playerid);
    if(!strcmp(sys, "SYS_food_delivery")) return CEF_EcoJobOpen(playerid);
    if(!strcmp(sys, "SYS_tau_meter")) return CEF_TauMeterOpen(playerid);
    if(!strcmp(sys, "SYS_cleaning") || !strcmp(sys, "SYS_cleaning_open_washing")) return CEF_NeedsShow(playerid);
    if(!strcmp(sys, "SYS_quick_slots")) return OpenTabCEF(playerid, 2);
    if(!strcmp(sys, "SYS_money_notification")) return CEFC_HudUpdate(playerid);
    if(!strcmp(sys, "SYS_speedometer") || !strcmp(sys, "SYS_speedometer_set_visible")) return CEFC_SpeedometerShow(playerid);
    if(!strcmp(sys, "SYS_craft")) return CEF_LiveJobCraft(playerid);
    if(!strcmp(sys, "SYS_mfarm_open_general_page") || !strcmp(sys, "SYS_mfarm_open_item_selection") || !strcmp(sys, "SYS_mfarm_open_rig_page")) return CEF_EcoJobOpen(playerid);
    return 1;
}

public CEF_AllMapToggle(playerid)
{
    return CEF_OpsMapToggle(playerid);
}

public CEF_AllChatInput(playerid)
{
    CEFC_ChatOpenInput(playerid);
    return 1;
}

CMD:anims(playerid, params[])
{
    #pragma unused params
    return CEF_AllAnimsOpen(playerid);
}

CMD:rep(playerid, params[])
{
    if(isnull(params)) return CEF_AllSupportOpen(playerid);
    CEF_AllSendReport(playerid, params);
    return 1;
}

CMD:ads(playerid, params[])
{
    if(isnull(params)) return CEF_AllAdsOpen(playerid);
    CEF_AllBroadcastAd(playerid, params);
    return 1;
}

CMD:cefall(playerid, params[])
{
    #pragma unused params
    if(PI[playerid][pAdmin] < 3) return 0;
    CEF_AllAnimsOpen(playerid);
    return 1;
}

CMD:admcef(playerid, params[])
{
    #pragma unused params
    return CEF_AllAdminOpen(playerid);
}

CMD:cefhelp(playerid, params[])
{
    #pragma unused params
    SendClientMessage(playerid, 0x54B367FF, "CEF: TAB/I инвентарь, F1 пауза, F3 помощь, F6 чат, X анимации, M карта.");
    SendClientMessage(playerid, 0xCCCCCCFF, "/cases /buycase /need /map /tab /esc /pass /lic /inv");
    SendClientMessage(playerid, 0xCCCCCCFF, "/toilet /wash /tickets /payfines /perks /tasks /prizes /balance");
    if(PI[playerid][pAdmin] >= 3)
    {
        SendClientMessage(playerid, 0xFFAA55FF, "Админ 3+: /givecase /giveitem /giveprize /giveskin /givedonate");
        SendClientMessage(playerid, 0xFFAA55FF, "/givecase [id] [1-20] [кол]  /giveitem [id] [1-9] [кол]  /giveprize [id] [1-10]");
        SendClientMessage(playerid, 0xFFAA55FF, "Без аргументов команда пишет список в чат.");
    }
    return 1;
}
