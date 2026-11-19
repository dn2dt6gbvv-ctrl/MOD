
new g_TicketTarget[MAX_PLAYERS] = {-1, ...};

stock ShowTicketCEF(officerId, targetId)
{
    if (!cef_player_has_plugin(officerId) || !PT[officerId][pCefLoaded]) return 0;
    g_TicketTarget[officerId] = targetId;
    cef_create_browser(officerId, TICKET_BROWSER, TICKET_BROWSER_LINK, false, true);
    cef_always_listen_keys(officerId, TICKET_BROWSER, true);
    return 1;
}

forward TicketCEFReady(playerid);
public TicketCEFReady(playerid)
{
    if (!IsPlayerConnected(playerid)) return 1;
    new targetId = g_TicketTarget[playerid];
    if (!IsPlayerConnected(targetId)) {
        CEFChat_Send(playerid, "FF4444", "Игрок вышел с сервера!");
        CloseTicketCEF(playerid);
        return 1;
    }
    new targetName[MAX_PLAYER_NAME];
    GetPlayerName(targetId, targetName, sizeof(targetName));
    cef_emit_event(playerid, "ticket:open",
        CEFINT(targetId),
        CEFSTR(targetName)
    );
    return 1;
}

callback::OnTicketConfirm(playerid, const arguments[])
{
    printf("[TICKET] confirm args: '%s'", arguments);

    new article_num[16], article_title[200], fine;
    new tmp[220];
    sscanf(arguments, "s[16]s[220]", article_num, tmp);

    new pos = strlen(tmp);
    while(pos > 0 && tmp[pos-1] != ' ') pos--;
    fine = strval(tmp[pos]);
    strmid(article_title, tmp, 0, pos > 0 ? pos-1 : pos);

    printf("[TICKET] num='%s' fine=%d title='%s'", article_num, fine, article_title);

    new targetId = g_TicketTarget[playerid];
    if (!IsPlayerConnected(targetId)) {
        CEFChat_Send(playerid, "FF4444", "Игрок вышел с сервера!");
        CloseTicketCEF(playerid);
        return 1;
    }

    new reason[64];
    format(reason, sizeof reason, "Ст.%s %s", article_num, article_title);
    if(!CEF_PlayerCanIssueFine(playerid)) return SendErr(playerid, "Выписывать штрафы может полиция с 3-го звания.");
    if(fine < 100) fine = 100;
    if(fine > CEF_FineRankLimit(playerid))
        return SendErr(playerid, "Сумма штрафа превышает лимит вашего звания.");
    CEF_FineIssueByOfficer(playerid, targetId, fine, reason);

    new radio[256];
    new fractionid = PI[playerid][pFraction];
    format(radio, sizeof(radio), "[R] %s выписал штраф %s на сумму %d руб. Ст.%s.",
        GetName(playerid), GetName(targetId), fine, article_num);
    foreach(new i : Player) {
        if (PI[i][pFraction] != fractionid) continue;
        if (!PT[i][pDuty]) continue;
        SendClientMessage(i, COLOR_RADIO, radio);
    }

    CloseTicketCEF(playerid);
    return 1;
}

callback::OnTicketClose(playerid, const arguments[])
{
    CloseTicketCEF(playerid);
    return 1;
}

stock CloseTicketCEF(playerid)
{
    cef_focus_browser(playerid, TICKET_BROWSER, false);
    cef_destroy_browser(playerid, TICKET_BROWSER);
    g_TicketTarget[playerid] = -1;
    return 1;
}

cmd:ticket(playerid, params[])
{
    printf("[TICKET] cmd entered by %d frac=%d duty=%d",
        playerid, PI[playerid][pFraction], PT[playerid][pDuty]);

    if (!PT[playerid][pLogged]) return 1;
    new frac = PI[playerid][pFraction];
    if (frac != 2 && frac != 3 && frac != 4)
        return SendErr(playerid, "Команда доступна только сотрудникам ФСБ, ДПС и ППС!");
    if (!PT[playerid][pDuty])
        return SendErr(playerid, "Вы должны начать рабочий день!");
    new id_str[8];
    if (sscanf(params, "s[8]", id_str))
        return SendErr(playerid, "Использование: /ticket [ID]");
    new targetid = strval(id_str);
    if (!IsPlayerConnected(targetid))
        return SendErr(playerid, "Игрок не найден!");

    printf("[TICKET] cmd called by %d, target=%d, plugin=%d, cefloaded=%d",
        playerid, targetid,
        cef_player_has_plugin(playerid),
        PT[playerid][pCefLoaded]);

    ShowTicketCEF(playerid, targetid);
    return 1;
}
