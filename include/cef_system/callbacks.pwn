
stock SendClientNotification(playerid, header[], desc[], icon[], timeout, color_1[], color_2[], color_highl[])
    {
    #pragma unused icon
    #pragma unused color_1
    #pragma unused color_2
    #pragma unused color_highl
    return CEFC_NotifyTitled(playerid, header, desc, timeout);
}

stock ShowPlayerDialogEx(playerid, dialogid, style, title[], text[], button1[], button2[], button3[] = "", timerSeconds = 0, picture1Url[] = "", picture2Url[] = "", picture3Url[] = "")
{
    PT[playerid][pDialogID] = dialogid;
    if(dialogid >= dialog_REG && dialogid <= dialog_REG + 2)
        return ShowPlayerDialog(playerid, dialogid, style, title, text, button1, button2);
	if(cef_player_has_plugin(playerid) == 1 && PT[playerid][pCefLoaded])
    {
        CEFC_Dialog(playerid, dialogid, style, title, text, button1, button2);
        #pragma unused button3
        #pragma unused timerSeconds
        #pragma unused picture1Url
        #pragma unused picture2Url
        #pragma unused picture3Url
    }
    else return ShowPlayerDialog(playerid, dialogid, style, title, text, button1, button2);
	return 1;
}

stock PlaySound(playerid, filename[], volume = 100, loop = 0)
{
    cef_emit_event(playerid, "playSound", CEFSTR(filename), CEFINT(volume), CEFINT(loop));
}

stock StopSound(playerid, filename[])
{
    cef_emit_event(playerid, "stopSound", CEFSTR(filename));
}

stock SetVolume(playerid, filename[], volume)
{
    cef_emit_event(playerid, "stopSound", CEFSTR(filename), CEFINT(volume));
}

stock StopAllSounds(playerid) cef_emit_event(playerid, "stopAllSounds");

stock FadeScreen(playerid, fade) cef_emit_event(playerid, "game:fadeScreen", CEFINT(fade));

stock ShowBHint(playerid, const h_title[], const h_description[], const h_timerTitle[], h_timerCurrentTime, h_timerMaxTime, const h_postDescription[], const h_colorLeft[], const h_colorRight[])
{
    CEFC_ProcessInfo(playerid, h_title, h_description, h_timerTitle, h_timerCurrentTime, h_timerMaxTime, h_postDescription, h_colorLeft, h_colorRight);
}

stock HideBHint(playerid) return CEF_SendEmpty(playerid, "cef_process_info_hide");

stock UpdateBHint(playerid, time)
{
    #pragma unused time
    return 1;
}


callback:: CallbackDialogResponse(playerid, const arguments[]) {
	new dId, responsed, list, input[64];
	sscanf(arguments, "P< >ddds[64]", dId, responsed, list, input);
	OnDialogResponse(playerid, dId, responsed, list, input);
	return 1;
}

callback:: OnCefBrowserCreated(player_id, browser_id, status_code)
{
    printf("[DEBUGPOS] OnCefBrowserCreated MAIN before-cam tick=%d", GetTickCount());
    if(browser_id == MAIN_BROWSER)
    {
        printf("[CEF] MAIN browser status=%d url=%s", status_code, MAIN_CEF_BROWSER_LINK);
        if(status_code != 200 && status_code != 0)
        {
            new dmsg[160];
            format(dmsg, sizeof dmsg, "CEF:    ( %d).   GTA\\cef\\spa\\index.html", status_code);
            SCM_Native(player_id, 0xFF4444FF, dmsg);
        }
        CEF_OnMainBrowserReady(player_id);
    }
    if(browser_id == MAIN_BROWSER)
    {
        cef_always_listen_keys(player_id, MAIN_BROWSER, true);
    }
    if(browser_id == MAIN_BROWSER && !PT[player_id][pLogged])
    {
        PT[player_id][pAuthTime] = 120;
        PT[player_id][pCefLoaded] = true;
        cef_always_listen_keys(player_id, MAIN_BROWSER, true);
        TogglePlayerSpectating(player_id, true);
        printf("[DEBUGPOS] OnCefBrowserCreated MAIN after-cam tick=%d", GetTickCount());
        cef_emit_event(player_id, "system:show", CEFINT(0), CEFSTR("  "));
        SetTimerEx("ShowAuthDialog", 3000, false, "ii", player_id, PT[player_id][pAuthSession]);

    }
    if(browser_id == CHAT_BROWSER)
    {
        cef_always_listen_keys(player_id, CHAT_BROWSER, true);
        cef_focus_browser(player_id, CHAT_BROWSER, false);
    }
    if(browser_id == LEADERSKIN_BROWSER)
    {
        SetTimerEx("SendLeaderSkinData", 500, false, "i", player_id);
    }
    if(browser_id == TICKET_BROWSER)
    {
        printf("[TICKET] OnCefBrowserCreated browser=%d status=%d", browser_id, status_code);
        SetTimerEx("TicketCEFReady", 800, false, "i", player_id);
    }
    if(browser_id == RADIAL_BROWSER)
    {
        SetTimerEx("RadialMenuReady", 300, false, "i", player_id);
    }
    if(browser_id == FRISK_BROWSER)
    {
        SetTimerEx("FriskBrowserReady", 400, false, "iii", player_id, g_FriskTarget[player_id], 0);
    }
    if(browser_id == HOUSECREATE_BROWSER)
    {
        SetTimerEx("HouseCreateReady", 400, false, "i", player_id);
    }
    if(browser_id == ZAKLADKI_BROWSER) SetTimerEx("ZakBrowserReady", 400, false, "i", player_id);
    if(browser_id == MINING_BROWSER) SetTimerEx("MineOnBrowserReady", 400, false, "i", player_id);
    if(browser_id == SKILL_BROWSER) SetTimerEx("OnSkillBrowserReady", 400, false, "i", player_id);
    if(browser_id == FACTORY_BROWSER) SetTimerEx("FactorySendData", 400, false, "i", player_id);
    if(browser_id == JOB_WIDGET_BROWSER) SetTimerEx("OnJobWidgetReady", 400, false, "i", player_id);
    return 1;
}
forward ShowAuthDialog(playerid, auth_session);
public ShowAuthDialog(playerid, auth_session)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid)) return 0;
    if(PT[playerid][pAuthSession] != auth_session || PT[playerid][pLogged] || PT[playerid][pAuthStarted]) return 0;
    PT[playerid][pAuthStarted] = true;

    printf("[DEBUGPOS] ShowAuthDialog tick=%d", GetTickCount());
    


    PT[playerid][pLoginAttempts] = 3;
    new query[] = "SELECT `password` FROM `accounts` WHERE `name` = '%e' LIMIT 1";
    new fmt_query[sizeof query + MAX_PLAYER_NAME];
    mysql_format(dbHandle, fmt_query, sizeof(fmt_query), query, PI[playerid][pName]);
    mysql_tquery(dbHandle, fmt_query, "CheckAccount", "ii", playerid, PT[playerid][pAuthSession]);
    return 1;
}
callback:: OnPlayerRequestTeleport(playerid, const arguments[])
{
    if(!PT[playerid][pLogged]) return 0;

    TogglePlayerControllable(playerid, 0);

    SendClientMessage(playerid, -1, "OnPlayerRequestTeleport");
    new index = PT[playerid][pTeleport];
    if(index <= -1) return 0;

    switch(PT[playerid][pTeleportType])
    {
        case TELEPORT_TYPE_DEFAULT:
        {
            UseTeleportForPlayer(playerid, index);
        }
        case TELEPORT_TYPE_PARKING_ENTER:
        {
            if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
            {
                new vehicleid = GetPlayerVehicleID(playerid);
                SetVehiclePos(vehicleid, parking[index][parking_e_ix], parking[index][parking_e_iy], parking[index][parking_e_iz]);
                SetVehicleZAngle(vehicleid, parking[index][parking_e_ia]);
                SetVehicleVirtualWorld(vehicleid, parking[index][parking_Vw]);
                SetPlayerVirtualWorld(playerid, parking[index][parking_Vw]);
            }
            else
            {
                if(GetPlayerHouseID(playerid) != 0) SendClientMessage(playerid, COLOR_BLUE, "     ,     ");
                else SendClientMessage(playerid, COLOR_BLUE, "  ,    ");

                SetPlayerFacingAngle(playerid, parking[index][parking_e_ia]);
                SetPlayerPos(playerid, parking[index][parking_e_ix], parking[index][parking_e_iy], parking[index][parking_e_iz]);
                SetPlayerVirtualWorld(playerid, parking[index][parking_Vw]);
            }
        }
        case TELEPORT_TYPE_PARKING_EXIT:
        {
            if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
            {
                new vehicleid = GetPlayerVehicleID(playerid);
                SetVehiclePos(vehicleid, parking[index][parking_Ex], parking[index][parking_Ey], parking[index][parking_Ez]);
                SetVehicleZAngle(vehicleid, parking[index][parking_Ea]);
                SetVehicleVirtualWorld(vehicleid, 0);
                SetPlayerVirtualWorld(playerid, 0);
            }
            else
            {
                SetPlayerPos(playerid, parking[index][parking_Ex], parking[index][parking_Ey], parking[index][parking_Ez]);
                SetPlayerFacingAngle(playerid, parking[index][parking_Ea]);
                SetPlayerVirtualWorld(playerid, 0);
            }
        }
    }

    PT[playerid][pTeleport] = -1;
    PT[playerid][pTeleportType] = TELEPORT_TYPE_NONE;

    TogglePlayerControllable(playerid, true);
    cef_emit_event(playerid, "game:fadeScreen", CEFINT(false));
    return 1;
}
callback:: OnCefInitialize(player_id, success)
{
    SCMF(player_id, -1, "OnCefInitialize(player_id, %s)", success ? ("") : (""));
    CEF_MarkPlayerReset(player_id);
    if(success != 1)
    {
        SendClientMessage(player_id, 0xFFAA00FF, "[CEF] no plugin, use /menu");
        return 1;
    }
    cef_create_browser(player_id, MAIN_BROWSER, MAIN_CEF_BROWSER_LINK, false, false);
    return 1;
}

callback::RequestSelectorClose(playerid, const arguments[])
{
    if(!PT[playerid][pLogged]) return 1;

    cef_emit_event(playerid, "game:openSkinSelector", CEFINT(0));
    PT[playerid][pSelectorOpened] = false;

    return 1;
}

static const Men_Registration_Skins[] = {14, 20, 21, 22, 24, 25};
static const Women_Registration_Skins[] = {12, 13, 226, 56};

stock ChooseRegisterSkin(playerid)
{
    static JSON[512];
    new temp[90];

    if(gCefAuthActive[playerid]) return CEF_AuthOpenCharacter(playerid);
    PT[playerid][pIsPlayerChoosingRegisterSkin] = true;
    if(PI[playerid][pSex] == 1)
    {
        PI[playerid][pSkin] = Men_Registration_Skins[1];
        SetPlayerSkin(playerid, PI[playerid][pSkin]);

        for(new i = 0; i < sizeof(Men_Registration_Skins); i++)
        {
            format(temp, sizeof temp, "{\"name\":\"\",\"price\":\"0 ?\"},");
            strcat(JSON, temp);
        }

        strmid(JSON, JSON, 0, strlen(JSON) - 1);
        format(JSON, sizeof JSON, "[%s]", JSON);
        cef_emit_event(playerid, "game:setCategories", CEFSTR(JSON));
        cef_emit_event(playerid, "game:openSkinSelector", CEFINT(2));
    }
    else if(PI[playerid][pSex] == 0)
    {
        PI[playerid][pSkin] = Women_Registration_Skins[1];
        SetPlayerSkin(playerid, PI[playerid][pSkin]);

        for(new i = 0; i < sizeof(Women_Registration_Skins); i++)
        {
            format(temp, sizeof temp, "{\"name\":\"\",\"price\":\"0 ?\"},");
            strcat(JSON, temp);
        }
        strmid(JSON, JSON, 0, strlen(JSON) - 1);
        format(JSON, sizeof JSON, "[%s]", JSON);
        cef_emit_event(playerid, "game:setCategories", CEFSTR(JSON));
        cef_emit_event(playerid, "game:openSkinSelector", CEFINT(2));
    }
    CallLocalFunction("CEF_AllSkinRegister", "i", playerid);
    return 1;
}

callback::SkinSelected(playerid, const arguments[])
{
    if(gCefAuthActive[playerid]) return 1;
    if(PT[playerid][pLogged] == false && PT[playerid][pIsPlayerChoosingRegisterSkin] == false) return 0;

    extract arguments -> new skin_index, IsChoosen; else return 0;
    if(PT[playerid][pIsPlayerChoosingRegisterSkin] == true)
    {
        if(IsChoosen == 0)
        {
            PI[playerid][pSkin] = PI[playerid][pSex] == 1 ? Men_Registration_Skins[skin_index] : Women_Registration_Skins[skin_index];
            SetPlayerSkin(playerid, PI[playerid][pSkin]);
        }
        else if(IsChoosen == 1)
        {
            cef_emit_event(playerid, "game:openSkinSelector", CEFINT(0));
            RegisterPlayer(playerid);
        }
    }
    return 1;
}


callback::KeyReleased(playerid, const arguments[])
{
    if(!PT[playerid][pLogged]) return 1;
    new key = strval(arguments);
    if(!key) key = CEF_EcoFindInt(arguments, "key");
    if(!key) key = CEF_EcoFindInt(arguments, "keyCode");

    switch(key)
    {
        case 9, 73, 27, 114:
            return 1;
        case 84, 117:
        {
            CEFC_ChatOpenInput(playerid);
            return 1;
        }
        case 112:
        {
            CEF_OpsEscOpen(playerid);
            return 1;
        }
        case 77:
        {
            CEF_OpsMapToggle(playerid);
            return 1;
        }
        case 88:
        {
            CEF_AllAnimsOpen(playerid);
            return 1;
        }
        case 18:
        {
            FactoryOnKeyState(playerid, KEY_WALK);
            Razvoz_OnKeyState(playerid, KEY_WALK);
            return 1;
        }
        case 17:
        {
            if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return 1;

            new vehicleid = GetPlayerVehicleID(playerid);
            if(!CI[vehicleid][Fuel]) return SendErr(playerid, "   ");

            GetVehicleParamsEx(vehicleid, CI[vehicleid][Engine], CI[vehicleid][Lights], CI[vehicleid][Alarm], CI[vehicleid][Doors], CI[vehicleid][Bonnet], CI[vehicleid][Boot], CI[vehicleid][Objective]);
            CI[vehicleid][Engine] = !CI[vehicleid][Engine];
            SetVehicleParamsEx(vehicleid, CI[vehicleid][Engine], CI[vehicleid][Lights], CI[vehicleid][Alarm], CI[vehicleid][Doors], CI[vehicleid][Bonnet], CI[vehicleid][Boot], CI[vehicleid][Objective]);
            cef_emit_event(playerid, "game:SetSpeedEngine", CEFINT(CI[vehicleid][Engine]));
            return 1;
        }
        case 66:
        {
            if(PT[playerid][pCreate] != 0) return 1;

            new idx = PT[playerid][pPorchHouse];
            if(IsPlayerInDynamicArea(playerid, PorchHouseInfo[idx][h_area]))
            {
                if(PorchHouseInfo[idx][hOwnerID] != 0) return SendErr(playerid, "  ");
                if(GetPlayerHouseID(playerid)) return SendErr(playerid, "    ");
                if(PI[playerid][pPorchHouse] != 0) return SendErr(playerid, "    ");
                ShowPlayerDialogEx(playerid, DIALOG_BUY_PORCH_HOUSE, DIALOG_STYLE_MSGBOX, " ", "    ?", "", "");
            }
            new h = PT[playerid][pHouseTemp];
            if(IsPlayerInDynamicArea(playerid, House[h][hArea]))
            {
                if(!strcmp(House[h][hOwner], "None", true))
                {
                    if(PI[playerid][pCash] < House[h][hPrice]) return SendErr(playerid, "   !");
                    if(GetPlayerHouseID(playerid)) return SendErr(playerid, "    ");

                    settext(House[h][hOwner], GetName(playerid));
                    House[h][hHours] = 32;
                    House[h][hOwnerID] = PI[playerid][pID];

                    DestroyPickup(House[h][hPickup]); House[h][hPickup] = CreatePickup(11780, 23, House[h][hPos_x], House[h][hPos_y], House[h][hPos_z]);
                    DestroyDynamicMapIcon(House[h][hMapIcon]); House[h][hMapIcon] = CreateDynamicMapIcon(House[h][hPos_x], House[h][hPos_y], House[h][hPos_z], 32, 0,-1,-1,-1,150.0);

                    new house[] =
                    "{FFFFFF}    !\n\
                    \n  :\
                    \n   3-  \
                    \n     ,   , \n\
                    \n ,    .\
                    \n       \
                    \nF6 -> /help,     \n\
                    \n     : {ff9945}/gps\n\
                    \n{FFFFFF}: {ff9945}/home";

                    ShowPlayerDialogEx(playerid, dialog_OK, DIALOG_STYLE_MSGBOX, " ", house, "", "");

                    TransferMoney(playerid, -1, House[h][hPrice], " ");
                    PI[playerid][pSpawn] = 1;

                    SetPlayerPos(playerid, House_Interiors[House[h][hClass]][hIPos_EX], House_Interiors[House[h][hClass]][hIPos_EY], House_Interiors[House[h][hClass]][hIPos_EZ]);
                    SetPlayerVirtualWorld(playerid, House[h][hID]);
                    SetPlayerFacingAngle(playerid, House_Interiors[House[h][hClass]][hIPos_EA]);

                    new query[120];
                    mysql_format(dbHandle,query, sizeof(query), "UPDATE `houses` SET `owner_id` = %d, `hours`= %d WHERE `id` = %d", House[h][hOwnerID], House[h][hHours], House[h][hID]);
                    mysql_tquery(dbHandle, query, "", "");
                    return 1;
                }
            }
        }
        case 69:
        {
            if(DynDoor_TryUse(playerid)) return 1;
            if(PT[playerid][pJerkAreaTemp] != -1)
            {
                new j = PT[playerid][pJerkAreaTemp];
                if(IsPlayerInDynamicArea(playerid, jerkArea[j][jerk_area]))
                {
                    if(!PI[playerid][pJerkStarted]) return SendErr(playerid, "    !    !");
                    if(PI[playerid][pJerkFinished]) return SendClientMessage(playerid, COLOR_BLUE, "   .");
                    if(PI[playerid][pJerkTime]) return 1;
                    SendClientMessage(playerid, COLOR_UNMAZING, "  .    .");

                    TogglePlayerControllable(playerid, 0);
                    ApplyAnimation(playerid, "PAULNMAC", "wank_loop", 1.800001, 1, 0, 0, 1, 600);

                    PI[playerid][pJerkTime] = 120;
                    PI[playerid][pJerkAnim] = 1;
                    return 1;
                }
            }
            if(IsPlayerInDynamicArea(playerid, jerkReception))
            {
                if(PI[playerid][pSex] || PI[playerid][pLevel] < 3) return SendErr(playerid, "       .");
                if(PI[playerid][pJerk]) return SendErr(playerid, "    .");
                if(PI[playerid][pJerkFinished])
                {
                    SCMF(playerid, COLOR_UNMAZING, "       %s .", SplitInt(3000));
                    TransferMoney(-1, playerid, 3000, " ");
                    PI[playerid][pJerk]++;
                    PI[playerid][pJerkStarted] = false;
                    PI[playerid][pJerkFinished] = false;
                }
                else
                {
                    ShowPlayerDialogEx(playerid, dialog_SPERM, DIALOG_STYLE_MSGBOX, " ", "         \
                    \n   ,     (/mm -> )\
                    \n     ,        PayDay\n\
                    \n    {ff9945}3 . .\n\
                    \n{1e90ff}     1   ", "", "");
                }
                return 1;
            }

            if(IsPlayerInDynamicArea(playerid, quest_area[0])) return LoadStartsQuests(playerid);


            if(CheckTrainBoxAreas(playerid)) return 1;
            if(CheckTrainDeliverArea(playerid)) return 1;

            for(new idx; idx <= totalPorchHouse; idx++)
            {
                if(IsPlayerInDynamicArea(playerid, PorchHouseInfo[idx][h_exit_area]))
                {
                    static fmt_lock[500];
                    switch(PorchHouseInfo[idx][hLock])
                    {
                        case 0: format(fmt_lock, sizeof fmt_lock, "\t\t\t\n{e69348}1. {ffffff}  \t\t\n{e69348}2. {ffffff} \t\t{00FF00}  ");
                        case 1: format(fmt_lock, sizeof fmt_lock, "\t\t\t\n{e69348}1. {ffffff}  \t\t\n{e69348}2. {ffffff} \t\t{632122}  ");
                    }

                    if(PI[playerid][pID] == PorchHouseInfo[idx][hOwnerID])
                    {
                        PT[playerid][pPorchHouse] = idx;
                        PT[playerid][pPorch] = PorchHouseInfo[idx][hPorch]-1;
                        ShowPlayerDialogEx(playerid, DIALOG_PORCH_HOUSE_MENU, DIALOG_STYLE_TABLIST_HEADERS, " ",fmt_lock, "", "");
                    }
                    else
                    {
                        SetPlayerPos(playerid, PorchHouseInfo[idx][hEntrx], PorchHouseInfo[idx][hEntry], PorchHouseInfo[idx][hEntrz]);
                        SetPlayerFacingAngle(playerid,PorchHouseInfo[idx][hEntrFa]);
                        SetPlayerVirtualWorld(playerid, PorchHouseInfo[idx][hPorch]-1);
                        SetCameraBehindPlayer(playerid);
                    }
                }
                if(IsPlayerInDynamicArea(playerid, PorchHouseInfo[idx][h_area]))
                {
                    if(PorchHouseInfo[idx][hOwnerID] == 0) return 1;

                    if(PorchHouseInfo[idx][hOwnerID] == PI[playerid][pID])
                    {
                        PT[playerid][pPorchHouse] = idx;
                        SetPlayerPos(playerid, -1578.6465,1987.4329,2204.8342);
                        SetPlayerFacingAngle(playerid,276.7006);
                        SetPlayerVirtualWorld(playerid, idx);
                        SetCameraBehindPlayer(playerid);
                    }
                    else
                    {
                        if(PorchHouseInfo[idx][hLock] == 1) return SendErr(playerid, "  ");
                        PT[playerid][pPorchHouse] = idx;
                        SetPlayerPos(playerid, -1578.6465,1987.4329,2204.8342);
                        SetPlayerFacingAngle(playerid,276.7006);
                        SetPlayerVirtualWorld(playerid, idx);
                        SetCameraBehindPlayer(playerid);
                    }
                }
            }
            if(IsValidHouse(PT[playerid][pHouseTemp]))
            {
                new h = PT[playerid][pHouseTemp];
                if(IsValidHouse(h) == true)
                {
                    if(IsPlayerInDynamicArea(playerid, House[h][hArea]) && House[h][hOwnerID] <= 0)
                    {
                        ShowPlayerDialogEx(playerid, dialog_HOUSE, DIALOG_STYLE_MSGBOX, "", "    ?", "", "");
                        return 1;
                    }

                    if(IsPlayerInDynamicArea(playerid, House[h][hAreaExit]))
                    {
                        ShowPlayerDialogEx(playerid, dialog_HOUSE + 1, DIALOG_STYLE_MSGBOX, "", "    ?", "", "");
                        return 1;
                    }
                }
            }
        }

        case 76:
        {
            if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return 1;

            new vehicleid = GetPlayerVehicleID(playerid);
            GetVehicleParamsEx(vehicleid, CI[vehicleid][Engine], CI[vehicleid][Lights], CI[vehicleid][Alarm], CI[vehicleid][Doors], CI[vehicleid][Bonnet], CI[vehicleid][Boot], CI[vehicleid][Objective]);
            CI[vehicleid][Lights] = !CI[vehicleid][Lights];
            SetVehicleParamsEx(vehicleid, CI[vehicleid][Engine], CI[vehicleid][Lights], CI[vehicleid][Alarm], CI[vehicleid][Doors], CI[vehicleid][Bonnet], CI[vehicleid][Boot], CI[vehicleid][Objective]);
            cef_emit_event(playerid, "game:SetSpeedLights", CEFINT(CI[vehicleid][Lights]));
            return 1;
        }

        case 78:
        {
            if(!PI[playerid][pOffer]) return SendErr(playerid, "  .");
            switch (PI[playerid][pOffer])
            {
                case OFFER_HOUSE:
                {
                    new homeid = GetPlayerHouseID(playerid);

                    SCMF(playerid, COLOR_RED, "      (%d)   %s  %s .", homeid, GetName(PI[playerid][pOfferPlayer]), SplitInt(PI[playerid][pOfferParam]));
                    SCMF(PI[playerid][pOfferPlayer], COLOR_RED, "%s      (%d)  %s .", GetName(playerid), homeid, SplitInt(PI[playerid][pOfferParam]));

                    ClearOffer(playerid);
                    ClearOffer(PI[playerid][pOfferPlayer]);
                }
            }
            return 1;
        }
        case 80:
        {
            ShowPlayerDialogEx(playerid, dialog_MENU_QUEST, DIALOG_STYLE_LIST, "", "{ff9945}1. {FFFFFF}  \n2{ff9945}. {FFFFFF} ", "", "");
            return 1;
        }
        case 89:
        {
            if(!PI[playerid][pOffer]) return 1;
            switch (PI[playerid][pOffer])
            {
                case OFFER_HOUSE:
                {
                    new house_id = GetPlayerHouseID(playerid);
                    new offer_house_id = GetPlayerHouseID(PI[playerid][pOfferPlayer]);
                    if(house_id != 0)
                    {
                        ClearOffer(PI[playerid][pOfferPlayer]);
                        SCMF(PI[playerid][pOfferPlayer], COLOR_RED, "%s      (%d)  %s .", GetName(playerid), offer_house_id, SplitInt(PI[playerid][pOfferParam]));
                        ClearOffer(playerid);
                        SendErr(playerid, "   !");
                        return 1;
                    }
                    if(offer_house_id == 0)
                    {
                        ClearOffer(PI[playerid][pOfferPlayer]);
                        SendErr(playerid, "    ,     .");
                        ClearOffer(playerid);
                        SendErr(playerid, "   !");
                        return 1;
                    }
                    if(PI[playerid][pCash] < PI[playerid][pOfferParam])
                    {
                        ClearOffer(PI[playerid][pOfferPlayer]);
                        SCMF(PI[playerid][pOfferPlayer], COLOR_RED, "%s      (%d)  %s .", GetName(playerid), offer_house_id, SplitInt(PI[playerid][pOfferParam]));
                        ClearOffer(playerid);
                        SendErr(playerid, "   !");
                        return 1;
                    }

                    new h = offer_house_id - 1;
                    SCMF(playerid, COLOR_UNMAZING, "%s     %d.   %s .", GetName(PI[playerid][pOfferPlayer]), offer_house_id, SplitInt(PI[playerid][pOfferParam]));
                    SCMF(PI[playerid][pOfferPlayer], COLOR_UNMAZING, "%s     %d.   %s .", GetName(playerid), offer_house_id, SplitInt(PI[playerid][pOfferParam]));

                    settext(House[h][hOwner], GetName(playerid));
                    House[h][hOwnerID] = PI[playerid][pID];

                    PI[playerid][pSpawn] = 1;
                    PI[PI[playerid][pOfferPlayer]][pSpawn] = 0;

                    TransferMoney(playerid, PI[playerid][pOfferPlayer], PI[playerid][pOfferParam], " ");

                    new query[120];
                    mysql_format(dbHandle,query, sizeof(query), "UPDATE `houses` SET `owner_id` = %d WHERE `id` = %d", House[h][hOwnerID], House[h][hID]);
                    mysql_tquery(dbHandle, query, "", "");

                    ClearOffer(PI[playerid][pOfferPlayer]);
                    ClearOffer(playerid);
                }
                default: SendErr(playerid, "  .");
            }
            return 1;
        }
    }
    return 1;
}


forward ShowFSBCert(playerid);
public ShowFSBCert(playerid)
{
    new rankName[32] = "-";
    new fullName[64];
    format(fullName, sizeof(fullName), "%s", PI[playerid][pName]);


    cef_emit_event(playerid, "fsb:display", CEFSTR(rankName), CEFSTR(fullName));
}










































#define DOCUMENT_VIEW_RANGE 5.0
#define DOCUMENT_OFFER_TIMEOUT 12000
#define DOC_TYPE_NONE 0
#define DOC_TYPE_PASSPORT 1
#define DOC_TYPE_LICENSE 2

new g_PassportOwner[MAX_PLAYERS] = {INVALID_PLAYER_ID, ...};
new g_LicenseOwner[MAX_PLAYERS] = {INVALID_PLAYER_ID, ...};
new g_DocumentOfferFrom[MAX_PLAYERS] = {INVALID_PLAYER_ID, ...};
new g_DocumentOfferType[MAX_PLAYERS];
new g_DocumentOfferToken[MAX_PLAYERS];

stock Document_GetTitle(type, dest[], size)
{
    if(type == DOC_TYPE_PASSPORT) format(dest, size, "passport");
    else if(type == DOC_TYPE_LICENSE) format(dest, size, "licenses");
    else format(dest, size, "document");
    return 1;
}

stock bool:Document_CanView(viewer, owner)
{
    if(!IsPlayerConnected(viewer) || !IsPlayerConnected(owner)) return false;
    if(!PT[viewer][pLogged] || !PT[owner][pLogged]) return false;
    if(GetPlayerVirtualWorld(viewer) != GetPlayerVirtualWorld(owner)) return false;
    if(GetPlayerInterior(viewer) != GetPlayerInterior(owner)) return false;
    if(GetDistBetweenPlayers(viewer, owner) > DOCUMENT_VIEW_RANGE) return false;
    return true;
}

stock Document_GetPassportOwner(viewer)
{
    new owner = g_PassportOwner[viewer];
    if(!IsPlayerConnected(owner) || !PT[owner][pLogged]) owner = viewer;
    return owner;
}

stock Document_GetLicenseOwner(viewer)
{
    new owner = g_LicenseOwner[viewer];
    if(!IsPlayerConnected(owner) || !PT[owner][pLogged]) owner = viewer;
    return owner;
}

stock OpenPassportCEFForOwner(viewer, owner)
{
    if(!IsPlayerConnected(viewer) || !IsPlayerConnected(owner)) return 0;
    g_PassportOwner[viewer] = owner;
    return CEF_LivePassport(viewer, owner);
}

stock OpenPassportCEF(playerid)
{
    return OpenPassportCEFForOwner(playerid, playerid);
}

stock ClosePassportCEF(playerid)
{
    cef_focus_browser(playerid, PASSPORT_BROWSER, false);
    cef_hide_browser(playerid, PASSPORT_BROWSER, true);
    cef_always_listen_keys(playerid, PASSPORT_BROWSER, false);
    cef_emit_event(playerid, "game:showCursor", CEFINT(0));
    cef_destroy_browser(playerid, PASSPORT_BROWSER);
    g_PassportOwner[playerid] = INVALID_PLAYER_ID;
    TogglePlayerControllable(playerid, 1);
    return 1;
}

stock OpenLicenseCEFForOwner(viewer, owner)
{
    if(!IsPlayerConnected(viewer) || !IsPlayerConnected(owner)) return 0;
    g_LicenseOwner[viewer] = owner;
    return CEF_LiveLicenses(viewer, owner);
}

stock OpenLicenseCEF(playerid)
{
    return OpenLicenseCEFForOwner(playerid, playerid);
}

stock CloseLicenseCEF(playerid)
{
    cef_focus_browser(playerid, LICENSE_BROWSER, false);
    cef_hide_browser(playerid, LICENSE_BROWSER, true);
    cef_always_listen_keys(playerid, LICENSE_BROWSER, false);
    cef_emit_event(playerid, "game:showCursor", CEFINT(0));
    cef_destroy_browser(playerid, LICENSE_BROWSER);
    g_LicenseOwner[playerid] = INVALID_PLAYER_ID;
    TogglePlayerControllable(playerid, 1);
    return 1;
}

stock CloseDocumentOffer(playerid)
{
    cef_focus_browser(playerid, DOCUMENT_OFFER_BROWSER, false);
    cef_hide_browser(playerid, DOCUMENT_OFFER_BROWSER, true);
    cef_always_listen_keys(playerid, DOCUMENT_OFFER_BROWSER, false);
    cef_emit_event(playerid, "game:showCursor", CEFINT(0));
    cef_destroy_browser(playerid, DOCUMENT_OFFER_BROWSER);
    return 1;
}

stock Document_ClearOffer(playerid)
{
    g_DocumentOfferFrom[playerid] = INVALID_PLAYER_ID;
    g_DocumentOfferType[playerid] = DOC_TYPE_NONE;
    g_DocumentOfferToken[playerid]++;
    return 1;
}

stock Document_SendOffer(playerid)
{
    new sender = g_DocumentOfferFrom[playerid];
    if(!IsPlayerConnected(sender) || !PT[sender][pLogged]) return 0;
    cef_emit_event(playerid, "docoffer:show",
        CEFSTR(PI[sender][pName]),
        CEFINT(sender),
        CEFINT(g_DocumentOfferType[playerid]));
    return 1;
}

stock Document_Offer(sender, target, type)
{
    if(!IsPlayerConnected(sender) || !PT[sender][pLogged]) return 0;
    if(!IsPlayerConnected(target) || !PT[target][pLogged] || target == sender)
        return SendErr(sender, "Player is unavailable.");
    if(!Document_CanView(sender, target))
        return SendErr(sender, "Player is too far away.");
    if(!cef_player_has_plugin(target) || !PT[target][pCefLoaded])
        return SendErr(sender, "The player does not have CEF enabled.");
    if(g_DocumentOfferFrom[target] != INVALID_PLAYER_ID)
        return SendErr(sender, "The player already has a pending offer.");

    g_DocumentOfferFrom[target] = sender;
    g_DocumentOfferType[target] = type;
    g_DocumentOfferToken[target]++;

    new title[16], description[96];
    Document_GetTitle(type, title, sizeof(title));
    if(type == DOC_TYPE_PASSPORT) format(description, sizeof(description), " ");
    else format(description, sizeof(description), " ");

    new result = PlayerOffer_Create(sender, target, PLAYER_OFFER_DOCUMENT, type, description);
    if(!result) Document_ClearOffer(target);
    return result;
}

forward DocumentOfferSendDelayed(playerid);
public DocumentOfferSendDelayed(playerid)
{
    if(IsPlayerConnected(playerid) && g_DocumentOfferFrom[playerid] != INVALID_PLAYER_ID)
        Document_SendOffer(playerid);
    return 1;
}

forward DocumentOfferTimeout(playerid, token);
public DocumentOfferTimeout(playerid, token)
{
    if(token != g_DocumentOfferToken[playerid]) return 1;

    new sender = g_DocumentOfferFrom[playerid];
    new type = g_DocumentOfferType[playerid];
    if(sender == INVALID_PLAYER_ID) return 1;

    CloseDocumentOffer(playerid);
    Document_ClearOffer(playerid);

    new title[16];
    Document_GetTitle(type, title, sizeof(title));
    if(IsPlayerConnected(playerid))
        SCMF(playerid, COLOR_GRAY, "The offer to view %s has expired.", title);
    if(IsPlayerConnected(sender))
        SCMF(sender, COLOR_GRAY, "%s[%d] did not respond to your %s offer.", PI[playerid][pName], playerid, title);
    return 1;
}

forward SendPassportCEFData(playerid);
public SendPassportCEFData(playerid)
{
    if(!IsPlayerConnected(playerid) || !PT[playerid][pLogged]) return 1;

    new owner = Document_GetPassportOwner(playerid);
    new birthDate[12];
    if(strlen(PI[owner][pBirthDate])) format(birthDate, sizeof(birthDate), "%s", PI[owner][pBirthDate]);
    else format(birthDate, sizeof(birthDate), "01.01.2000");

    new skinId = GetPlayerSkin(owner);
    if(skinId <= 0) skinId = PI[owner][pSkin];

    static json[512];
    format(json, sizeof(json),
        "{\"nickname\":\"%s\",\"gender\":\"%s\",\"birthDate\":\"%s\",\"birthPlace\":\"Russia\",\"residencePlace\":\"Not specified\",\"documentId\":%d,\"legalityLevel\":%d,\"militaryId\":\"Not specified\",\"married\":\"Not specified\",\"regionResidence\":\"Not specified\",\"skinId\":%d}",
        PI[owner][pName],
        PI[owner][pSex] ? "MALE" : "FEMALE",
        birthDate,
        PI[owner][pID],
        PI[owner][pLegality],
        skinId);
    cef_emit_event(playerid, "passport:show", CEFSTR(json));
    printf("[DOCUMENT] passport viewer=%d owner=%d skin=%d", playerid, owner, skinId);
    return 1;
}

forward SendLicenseCEFData(playerid);
public SendLicenseCEFData(playerid)
{
    if(!IsPlayerConnected(playerid) || !PT[playerid][pLogged]) return 1;

    new owner = Document_GetLicenseOwner(playerid);
    new birthDate[12];
    if(strlen(PI[owner][pBirthDate])) format(birthDate, sizeof(birthDate), "%s", PI[owner][pBirthDate]);
    else format(birthDate, sizeof(birthDate), "01.01.2000");

    new skinId = GetPlayerSkin(owner);
    if(skinId <= 0) skinId = PI[owner][pSkin];

    static json[512];
    format(json, sizeof(json),
        "{\"nickname\":\"%s\",\"gender\":\"%s\",\"birthDate\":\"%s\",\"birthPlace\":\"Russia\",\"documentId\":%d,\"skinId\":%d,\"licenseA\":%d,\"licenseB\":%d,\"licenseC\":%d,\"weapon\":%d,\"flight\":%d,\"business\":%d}",
        PI[owner][pName],
        PI[owner][pSex] ? "MALE" : "FEMALE",
        birthDate,
        PI[owner][pID],
        skinId,
        PI[owner][pLicenseA], PI[owner][pLicenseB], PI[owner][pLicenseC],
        PI[owner][pLicenseWeapon], PI[owner][pLicenseFlight], PI[owner][pLicenseBusiness]);
    cef_emit_event(playerid, "license:show", CEFSTR(json));
    printf("[DOCUMENT] license viewer=%d owner=%d skin=%d", playerid, owner, skinId);
    return 1;
}

stock OpenCarpassCEF(playerid)
{
    return CEF_LiveCarpass(playerid);
}

stock CloseCarpassCEF(playerid)
{
    cef_focus_browser(playerid, CARPASS_BROWSER, false);
    cef_hide_browser(playerid, CARPASS_BROWSER, true);
    cef_destroy_browser(playerid, CARPASS_BROWSER);
    TogglePlayerControllable(playerid, 1);
    return 1;
}

forward SendCarpassCEFData(playerid);
public SendCarpassCEFData(playerid)
{
    if(!IsPlayerConnected(playerid)) return 1;

    new vehicleid = PI[playerid][pCar];
    if(!IsValidVehicle(vehicleid)) return 1;

    new model = GetVehicleModel(vehicleid);
    new plate[32];
    GetVehicleNumberPlate(vehicleid, plate, sizeof(plate));
    if(!strlen(plate)) format(plate, sizeof(plate), "NONE");

    new Float:health;
    GetVehicleHealth(vehicleid, health);
    if(health < 0.0) health = 0.0;
    if(health > 1000.0) health = 1000.0;
    health = floatdiv(health, 10.0);

    new Float:price = 0.0;
    new maxSpeed = 0;
    new owner[64];
    format(owner, sizeof(owner), "%s", PI[playerid][pName]);

    static json[1800];
    format(json, sizeof(json),
        "{\"wanted\":false,\"leasing\":false,\"documentId\":%d,\"owner\":\"%s\",\"modelName\":\"%s\",\"maxSpeed\":%d,\"health\":%.0f,\"price\":%.0f,\"ownersCount\":1,\"plate\":\"none,none,%s,none\",\"fuelType\":\"PETROL\",\"fuelTank\":%d,\"primaryColor\":\"#111111\",\"secondaryColor\":\"#333333\",\"tertiaryColor\":\"#777777\",\"modelId\":%d,\"vehicleId\":%d,\"tuning\":{\"vinyl\":0,\"maxEngine\":5,\"engine\":0,\"negativeCamber\":-1,\"signaling\":0,\"radarDetector\":0,\"audioSystem\":%d,\"strobeLights\":%d,\"nitro\":0,\"hydraulics\":0,\"suspensionLevel\":0,\"airSuspension\":0,\"neon\":%d,\"driftSmoke\":{\"type\":%d,\"name\":\"\",\"wear\":0},\"gradientSupportType\":0,\"gradient\":false,\"extraFuelTank\":0,\"extraInventorySlots\":0},\"mileage\":%d,\"fuel\":%d}",
        PI[playerid][pID], owner, GetVehicleName(model), maxSpeed, health, price, 80,
        model, vehicleid, CI[vehicleid][vAudio], CI[vehicleid][vStrobsStatus],
        CI[vehicleid][vNeonToggled] ? 1 : 0, CI[vehicleid][vSmokeToggled] ? 1 : 0,
        CI[vehicleid][vMileage], CI[vehicleid][Fuel]);
    cef_emit_event(playerid, "carpass:show", CEFSTR(json));
    return 1;
}

callback::OnPassportReady(playerid, const arguments[])
{
    #pragma unused arguments
    SetTimerEx("SendPassportCEFData", 150, false, "i", playerid);
    return 1;
}

callback::OnPassportClose(playerid, const arguments[])
{
    #pragma unused arguments
    ClosePassportCEF(playerid);
    return 1;
}

callback::OnLicenseReady(playerid, const arguments[])
{
    #pragma unused arguments
    SetTimerEx("SendLicenseCEFData", 150, false, "i", playerid);
    return 1;
}

callback::OnLicenseClose(playerid, const arguments[])
{
    #pragma unused arguments
    CloseLicenseCEF(playerid);
    return 1;
}

callback::OnDocumentOfferReady(playerid, const arguments[])
{
    #pragma unused arguments
    Document_SendOffer(playerid);
    return 1;
}

stock Document_HandleOfferResponse(playerid, accepted)
{
    new sender = g_DocumentOfferFrom[playerid];
    new type = g_DocumentOfferType[playerid];
    if(sender == INVALID_PLAYER_ID) return 1;

    CloseDocumentOffer(playerid);
    Document_ClearOffer(playerid);

    new title[16];
    Document_GetTitle(type, title, sizeof(title));

    if(!accepted)
    {
        if(IsPlayerConnected(playerid))
            SCMF(playerid, COLOR_GRAY, "You declined the offer to view %s from %s[%d].", title, PI[sender][pName], sender);
        if(IsPlayerConnected(sender))
            SCMF(sender, COLOR_GRAY, "%s[%d] declined the offer to view your %s.", PI[playerid][pName], playerid, title);
        return 1;
    }

    if(!Document_CanView(playerid, sender))
    {
        if(IsPlayerConnected(playerid)) SendErr(playerid, "The player is too far away.");
        if(IsPlayerConnected(sender)) SendErr(sender, "The player is too far away.");
        return 1;
    }

    if(type == DOC_TYPE_PASSPORT)
        OpenPassportCEFForOwner(playerid, sender);
    else if(type == DOC_TYPE_LICENSE)
        OpenLicenseCEFForOwner(playerid, sender);

    if(IsPlayerConnected(playerid))
        SCMF(playerid, COLOR_GRAY, "You accepted the offer to view %s from %s[%d].", title, PI[sender][pName], sender);
    if(IsPlayerConnected(sender))
        SCMF(sender, COLOR_GRAY, "%s[%d] accepted the offer to view your %s.", PI[playerid][pName], playerid, title);
    return 1;
}

callback::OnDocumentOfferResponse(playerid, const arguments[])
{
    new accepted;
    if(sscanf(arguments, "P< >d", accepted)) return 1;
    return Document_HandleOfferResponse(playerid, accepted);
}

callback::OnCarpassReady(playerid, const arguments[])
{
    #pragma unused arguments
    SetTimerEx("SendCarpassCEFData", 150, false, "i", playerid);
    return 1;
}

callback::OnCarpassClose(playerid, const arguments[])
{
    #pragma unused arguments
    CloseCarpassCEF(playerid);
    return 1;
}

stock Document_OnPlayerConnect(playerid)
{
    g_PassportOwner[playerid] = INVALID_PLAYER_ID;
    g_LicenseOwner[playerid] = INVALID_PLAYER_ID;
    Document_ClearOffer(playerid);
    return 1;
}

stock Document_OnPlayerDisconnect(playerid)
{
    new i;
    new title[16];

    if(g_DocumentOfferFrom[playerid] != INVALID_PLAYER_ID)
    {
        new sender = g_DocumentOfferFrom[playerid];
        Document_GetTitle(g_DocumentOfferType[playerid], title, sizeof(title));
        if(IsPlayerConnected(sender))
            SCMF(sender, COLOR_GRAY, "Your %s offer was cancelled: player disconnected.", title);
        Document_ClearOffer(playerid);
    }

    for(i = 0; i < MAX_PLAYERS; i++)
    {
        if(g_DocumentOfferFrom[i] == playerid)
        {
            Document_GetTitle(g_DocumentOfferType[i], title, sizeof(title));
            if(IsPlayerConnected(i))
            {
                CloseDocumentOffer(i);
                SCMF(i, COLOR_GRAY, "The %s offer was cancelled: player disconnected.", title);
            }
            Document_ClearOffer(i);
        }
        if(g_PassportOwner[i] == playerid && IsPlayerConnected(i)) ClosePassportCEF(i);
        if(g_LicenseOwner[i] == playerid && IsPlayerConnected(i)) CloseLicenseCEF(i);
    }
    g_PassportOwner[playerid] = INVALID_PLAYER_ID;
    g_LicenseOwner[playerid] = INVALID_PLAYER_ID;
    return 1;
}
