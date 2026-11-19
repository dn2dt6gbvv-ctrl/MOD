forward CEF_FinesLoad(playerid);

callback:: CheckAccount(playerid, auth_session)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid)) return 0;
    if(PT[playerid][pAuthSession] != auth_session || PT[playerid][pLogged]) return 0;

    if(!cache_num_rows())
    {
        CEF_AuthClose(playerid);
        ShowPlayerDialogEx(playerid,
            dialog_REG,
            DIALOG_STYLE_PASSWORD,
            "Регистрация",
            "Добро пожаловать на сервер {FF9945}Unmazing\n{FFFFFF}Введите пароль от 6 до 15 символов.",
            "Далее",
            "Выход"
        );
        return 1;
    }

    PT[playerid][pLoginAttempts] = 3;
    return CEF_AuthSignIn(playerid, DIALOG_STYLE_PASSWORD, "Авторизация", "Введите пароль от аккаунта.", "Войти", "Выход");
}

callback::CheckAccountLogin(playerid, auth_session)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid)) return 0;
    if(PT[playerid][pAuthSession] != auth_session || PT[playerid][pLogged]) return 0;
    PT[playerid][pAuthLoginPending] = false;

    GetPlayerIp(playerid, PI[playerid][pIP], 15);

    if(!cache_num_rows())
    {
        PT[playerid][pLoginAttempts]--;
        if(PT[playerid][pLoginAttempts] <= 0)
        {
            SendClientMessage(playerid, COLOR_RED, "Превышено число попыток входа. Вы будете отключены.");
            Kick(playerid);
            return 1;
        }
        return CEF_AuthSignIn(playerid, DIALOG_STYLE_PASSWORD, "Неверный пароль", "Проверьте пароль и попробуйте ещё раз.", "Повторить", "Выход");
    }

    CEF_AuthClose(playerid);
    cache_get_value_name(0, "mail", PI[playerid][pMail], 32);
    cache_get_value_name_int(0, "promocode", PI[playerid][pPromocodeId]);
    PI[playerid][pPromocode][0] = EOS;

    cache_get_value_name_int(0, "id", PI[playerid][pID]);
    cache_get_value_name_int(0, "cash", PI[playerid][pCash]);
    cache_get_value_name_int(0, "bank", PI[playerid][pBank]);
    cache_get_value_name_int(0, "level", PI[playerid][pLevel]);
    cache_get_value_name_int(0, "exp", PI[playerid][pExp]);
    cache_get_value_name_int(0, "donate", PI[playerid][pDonate]);
    cache_get_value_name_int(0, "sex", PI[playerid][pSex]);
    cache_get_value_name_int(0, "skin", PI[playerid][pSkin]);
    cache_get_value_name(0, "birth_date", PI[playerid][pBirthDate], 12);
    if(!strlen(PI[playerid][pBirthDate])) format(PI[playerid][pBirthDate], 12, "01.01.2000");
    PI[playerid][pHasPassport] = true;
    cache_get_value_name_int(0, "license_a", PI[playerid][pLicenseA]);
    cache_get_value_name_int(0, "license_b", PI[playerid][pLicenseB]);
    cache_get_value_name_int(0, "license_c", PI[playerid][pLicenseC]);
    cache_get_value_name_int(0, "license_weapon", PI[playerid][pLicenseWeapon]);
    cache_get_value_name_int(0, "license_flight", PI[playerid][pLicenseFlight]);
    cache_get_value_name_int(0, "license_business", PI[playerid][pLicenseBusiness]);
    cache_get_value_name_int(0, "quest", PI[playerid][pQuest]);
    cache_get_value_name_int(0, "quest_progress", PI[playerid][pQuestProgress]);
    cache_get_value_name_int(0, "spawn", PI[playerid][pSpawn]);
    cache_get_value_name_int(0, "leader", PI[playerid][pLeader]);
    cache_get_value_name_int(0, "fraction", PI[playerid][pFraction]);
    cache_get_value_name_int(0, "fraction_skin", PI[playerid][pFractionSkin]);
    cache_get_value_name_int(0, "fraction_rank", PI[playerid][pFractionRank]);
    cache_get_value_name_int(0, "wanted", PI[playerid][pWanted]);
    cache_get_value_name_int(0, "drug_addiction", PI[playerid][pDrugAddiction]);
    cache_get_value_name_int(0, "legality", PI[playerid][pLegality]);
    cache_get_value_name_int(0, "family", PI[playerid][pFamily]);
    cache_get_value_name_int(0, "family_rang", PI[playerid][pFRang]);
    cache_get_value_name_int(0, "porch_house", PI[playerid][pPorchHouse]);
    cache_get_value_name_int(0, "has_mask", PI[playerid][pHasMask]);
    cache_get_value_name_int(0, "casino_chips", gCefCasinoChips[playerid]);
    gCefCasinoLoaded[playerid] = true;
    gCefCasinoFormOpen[playerid] = false;
    cache_get_value_name_int(0, "vip", PI[playerid][pVip]);
    cache_get_value_name_int(0, "vip_expire", PI[playerid][pVipExpire]);
    cache_get_value_name_int(0, "warns", PI[playerid][pWarns]);
    cache_get_value_name_int(0, "suspended", PI[playerid][pSuspended]);
    cache_get_value_name_int(0, "podtdel", PI[playerid][pPodtdel]);
    new arrestTime;
    cache_get_value_name_int(0, "arrest_time", arrestTime);
    LoadArrestTime(playerid, arrestTime);

    PT[playerid][pLastEnter] = getdate();
    PT[playerid][pLogged] = true;
    CEF_FinesLoad(playerid);
    cef_always_listen_keys(playerid, MAIN_BROWSER, true);
    PT[playerid][pLoginAttempts] = 0;

    if(PI[playerid][pSpawn] == 1 && GetPlayerHouseID(playerid) >= 0 || PI[playerid][pSpawn] == 2 && PI[playerid][pFraction] <= 0) PI[playerid][pSpawn] = 0;

    SetPlayerScore(playerid, PI[playerid][pLevel]);
    ResetPlayerMoney(playerid);

    new query[140];
    mysql_format(dbHandle, query, sizeof(query), "SELECT m.*, ( SELECT COUNT(*) FROM messages WHERE recipient_id = m.recipient_id AND message_read = 1 ) AS unread_messages FROM messages m WHERE m.recipient_id = %i ORDER BY m.important DESC, m.date DESC;", PI[playerid][pID]);
    mysql_tquery(dbHandle, query, "LoadMessages", "i", playerid);

    mysql_format(dbHandle, query, sizeof(query), "SELECT * FROM `items` WHERE `item_owner_id` = %i AND `item_type` > 0 AND `item_amount` > 0 AND `item_slot` BETWEEN 0 AND 25 ORDER BY `item_slot` ASC", PI[playerid][pID]);
    new inv_load_serial = CEF_InvLoadBegin(playerid);
    mysql_tquery(dbHandle, query, "LoadPlayerInventory", "iii", playerid, PI[playerid][pID], inv_load_serial);

    StaffRoles_LoadPlayer(playerid);
    Skill_LoadPlayer(playerid);
    CEF_CasesLoad(playerid);
    CEF_ProgressLoad(playerid);
    CEF_CurrencyLoad(playerid);

    mysql_format(dbHandle, query, sizeof(query), "SELECT * FROM `admin` WHERE `admin_id` = %i", PI[playerid][pID]);
    mysql_tquery(dbHandle, query, "LoadPlayerAdmin", "ii", playerid, PT[playerid][pAuthSession]);
    cache_get_value_name_int(0, "warn_count", g_WarnCount[playerid]);
    cache_get_value_name_int(0, "vch_bilyet", PT[playerid][pVchBilyet]);
    LoadPlayerOtdel(playerid);
    if(PI[playerid][pFraction] == 6) LoadVchBilyet(playerid);
    return 1;
}

callback::LoadPlayerAdmin(playerid, auth_session)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid)) return 0;
    if(PT[playerid][pAuthSession] != auth_session || !PT[playerid][pLogged]) return 0;
    if(!cache_num_rows())
    {
        PI[playerid][pAdmin] = 0;
        PI[playerid][pFullAccess] = 0;
        PI[playerid][pPrefix][0] = '\0';
        CEF_AfterLogin(playerid);
        return 0;
    }

    cache_get_value_name(0, "prefix", PI[playerid][pPrefix], 32);
    cache_get_value_name_int(0, "level", PI[playerid][pAdmin]);
    cache_get_value_name_int(0, "fullaccess", PI[playerid][pFullAccess]);
    CEF_AfterLogin(playerid);
    return 1;
}

callback::CheckAlogin(playerid)
{
    if(!cache_num_rows()) return SendErr(playerid, "У вас нет админ прав.");
    ShowPlayerDialogEx(playerid, dialog_ADMIN, DIALOG_STYLE_PASSWORD, "Панель администратора", "Введите админ пароль", "Далее", "Отмена");
    return 1;
}

callback::CheckAloginD(playerid)
{
    if(!cache_num_rows()) return SendErr(playerid, "Пароль неверный.");

    PT[playerid][pAlogged] = true;

    SCMF(playerid, -1, "[Админ-функции] Уровень доступа: %d", PI[playerid][pAdmin]);
    SetAdminHUDActive(playerid, true);
    SetPlayerAir(playerid);
    return 1;
}
callback::CheckEmailExists(playerid)
{
    if (cache_num_rows())
    {
        return ShowPlayerDialogEx(playerid, dialog_REG+1, DIALOG_STYLE_INPUT, "Адрес Почтового ящика занят", "Введите другой адрес электронной почты.", "Принять", "");
    }

    cache_get_value_name(0, "mail", PI[playerid][pMail], 32);
    ShowPlayerDialogEx(playerid, dialog_REG+2, DIALOG_STYLE_MSGBOX, "Выбор пола", "Выберите свой пол", "Мужской", "Женский");
    return 1;
}

stock CEF_RegisterStartCharacter(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) || PT[playerid][pLogged]) return 0;
    TogglePlayerSpectating(playerid, false);
    SetPlayerPos(playerid, -890.1702, -382.2885, 1103.6927);
    SetPlayerFacingAngle(playerid, 272.4342);
    SetPlayerVirtualWorld(playerid, playerid + 1000);
    SetPlayerCameraPos(playerid, -887.808959, -382.165618, 1104.483276);
    SetPlayerCameraLookAt(playerid, -892.762634, -382.178314, 1103.804443);
    TogglePlayerControllable(playerid, 0);
    ChooseRegisterSkin(playerid);
    return 1;
}

callback::OnPlayerRegister(playerid, response, auth_session)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid)) return 0;
    if(PT[playerid][pAuthSession] != auth_session || PT[playerid][pLogged] || PT[playerid][pRegistrationPending]) return 0;

    PI[playerid][pPromocodeId] = 0;
    if(response && strlen(PI[playerid][pPromocode]) > 0)
    {
        if(cache_num_rows() <= 0)
            return ShowPlayerDialogEx(playerid, dialog_REG+2, DIALOG_STYLE_INPUT, "Промокод", "Введите действующий промокод или оставьте поле пустым.", "Далее", "Пропустить");
        cache_get_value_name_int(0, "id", PI[playerid][pPromocodeId]);
    }

    return CEF_RegisterStartCharacter(playerid);
}

forward ApplyRegisterRoom(playerid, auth_session);
public ApplyRegisterRoom(playerid, auth_session)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid)) return 1;
    if(PT[playerid][pAuthSession] != auth_session || PT[playerid][pLogged]) return 1;

    TogglePlayerSpectating(playerid, false);
    SetPlayerPos(playerid, -890.1702, -382.2885, 1103.6927);
    SetPlayerFacingAngle(playerid, 272.4342);
    SetPlayerVirtualWorld(playerid, playerid + 1000);
    SetPlayerCameraPos(playerid, -887.808959, -382.165618, 1104.483276);
    SetPlayerCameraLookAt(playerid, -892.762634, -382.178314, 1103.804443);
    TogglePlayerControllable(playerid, 0);
    return 1;
}


forward OnAccountRegisterInserted(playerid, auth_session, promo_id);
callback::OnAccountRegisterInserted(playerid, auth_session, promo_id)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid)) return 0;
    if(PT[playerid][pAuthSession] != auth_session || !PT[playerid][pRegistrationPending] || PT[playerid][pLogged]) return 0;

    new account_id = cache_insert_id();
    if(account_id <= 0)
    {
        PT[playerid][pRegistrationPending] = false;
        PT[playerid][pIsPlayerChoosingRegisterSkin] = false;
        SendClientMessage(playerid, COLOR_RED, "Не удалось сохранить регистрацию. Попробуйте подключиться ещё раз.");
        Kick(playerid);
        return 1;
    }

    PT[playerid][pRegistrationPending] = false;
    PT[playerid][pIsPlayerChoosingRegisterSkin] = false;
    PT[playerid][pLogged] = true;
    PI[playerid][pID] = account_id;
    PI[playerid][pPromocodeId] = promo_id;

    if(promo_id > 0)
    {
        new promo_query[128];
        mysql_format(dbHandle, promo_query, sizeof promo_query,
            "UPDATE `promocodes` SET `promocode_uses`=`promocode_uses`+1 WHERE `id`=%d", promo_id);
        mysql_tquery(dbHandle, promo_query, "", "");
        SendClientMessage(playerid, COLOR_UNMAZING, "Вы успешно использовали промокод!");
        SCMF(playerid, -1, "На 5-м уровне вам будет начислен бонус %s.", SplitInt(ServerConfig[ServerReferalLevel5Bonus]));
        SCMF(playerid, -1, "На 10-м уровне вам будет начислен бонус %s.", SplitInt(ServerConfig[ServerReferalLevel10Bonus]));
    }

    CEF_FinesLoad(playerid);
    cef_always_listen_keys(playerid, MAIN_BROWSER, true);
    new inv_query[220];
    mysql_format(dbHandle, inv_query, sizeof inv_query,
        "SELECT * FROM `items` WHERE `item_owner_id`=%d AND `item_type`>0 AND `item_amount`>0 AND `item_slot` BETWEEN 0 AND 25 ORDER BY `item_slot` ASC",
        PI[playerid][pID]);
    new inv_load_serial = CEF_InvLoadBegin(playerid);
    mysql_tquery(dbHandle, inv_query, "LoadPlayerInventory", "iii", playerid, PI[playerid][pID], inv_load_serial);

    StaffRoles_LoadPlayer(playerid);
    Skill_LoadPlayer(playerid);
    CEF_CasesLoad(playerid);
    CEF_ProgressLoad(playerid);
    CEF_CurrencyLoad(playerid);

    SendClientMessage(playerid, COLOR_UNMAZING, "Добро пожаловать на сервер Unmazing!");
    SendClientMessage(playerid, COLOR_UNMAZING, "Команды помощи: /help и /ask");
    SendClientMessage(playerid, COLOR_UNMAZING, "Для навигации используйте /gps");
    SetPlayerScore(playerid, PI[playerid][pLevel]);
    PlaySound(playerid, "reg.mp3");
    ShowPlayerDialogEx(playerid, dialog_OK, DIALOG_STYLE_MSGBOX, "Добро пожаловать!",
        "Персонаж создан. После закрытия этого окна вы сможете продолжить игру.", "Хорошо", "");
    SpawnPlayerEx(playerid);
    return 1;
}

stock RegisterPlayer(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) || PT[playerid][pLogged]) return 0;
    if(!PT[playerid][pIsPlayerChoosingRegisterSkin] || PT[playerid][pRegistrationPending]) return 0;
    PT[playerid][pRegistrationPending] = true;

    GetPlayerIp(playerid, PI[playerid][pRegIP], 15);
    GetPlayerIp(playerid, PI[playerid][pIP], 15);
    PI[playerid][pCash] = ServerConfig[ServerBonusMoney];
    PI[playerid][pBank] = 0;
    PI[playerid][pDonate] = 0;
    PI[playerid][pLevel] = ServerConfig[ServerBonusLevel];
    PI[playerid][pExp] = 0;
    PI[playerid][pLegality] = 75;
    PI[playerid][pWanted] = 0;
    PI[playerid][pDrugAddiction] = 0;
    PI[playerid][pQuest] = 0;
    PI[playerid][pQuestProgress] = 0;
    PI[playerid][pSpawn] = 0;
    PI[playerid][pLeader] = 0;
    PI[playerid][pFraction] = 0;
    PI[playerid][pFractionRank] = 0;
    PI[playerid][pFractionSkin] = 0;
    PI[playerid][pFamily] = 0;
    PI[playerid][pFRang] = 0;
    PI[playerid][pJerk] = 0;
    PI[playerid][pPorchHouse] = 0;
    if(PI[playerid][pPromocodeId] < 0) PI[playerid][pPromocodeId] = 0;
    format(PI[playerid][pBirthDate], 12, "01.01.2000");
    PI[playerid][pHasPassport] = true;
    PI[playerid][pLicenseA] = 0;
    PI[playerid][pLicenseB] = 0;
    PI[playerid][pLicenseC] = 0;
    PI[playerid][pLicenseWeapon] = 0;
    PI[playerid][pLicenseFlight] = 0;
    PI[playerid][pLicenseBusiness] = 0;
    if(PI[playerid][pSkin] < 1 || PI[playerid][pSkin] > 311) PI[playerid][pSkin] = (PI[playerid][pSex] == 1) ? 14 : 12;

    new query[1200];
    mysql_format(dbHandle, query, sizeof query,
        "INSERT INTO `accounts` (`name`,`password`,`mail`,`promocode`,`sex`,`skin`,`level`,`exp`,`cash`,`bank`,`donate`,`reg_ip`,`ip`,`quest`,`quest_progress`,`home`,`spawn`,`jerk`,`leader`,`fraction`,`fraction_skin`,`fraction_rank`,`legality`,`wanted`,`drug_addiction`,`family`,`family_rang`,`porch`) VALUES ('%e',MD5('%e'),'',%d,%d,%d,%d,%d,%d,%d,%d,'%e','%e',0,0,0,0,0,0,0,0,0,%d,0,0,0,0,0)",
        PI[playerid][pName], PI[playerid][pPassword], PI[playerid][pPromocodeId], PI[playerid][pSex], PI[playerid][pSkin],
        PI[playerid][pLevel], PI[playerid][pExp], PI[playerid][pCash], PI[playerid][pBank], PI[playerid][pDonate],
        PI[playerid][pRegIP], PI[playerid][pIP], PI[playerid][pLegality]);
    PI[playerid][pPassword][0] = EOS;
    mysql_tquery(dbHandle, query, "OnAccountRegisterInserted", "iii",
        playerid, PT[playerid][pAuthSession], PI[playerid][pPromocodeId]);
    return 1;
}
