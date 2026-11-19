#if defined _cef_unmazing_bind_included
    #endinput
#endif
#define _cef_unmazing_bind_included




stock CEF_JsonNick(playerid, dest[], size = sizeof dest)
{
    new nick[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nick, sizeof nick);
    CEF_JsonEscape(nick, dest, size);
    return 1;
}

stock CEF_OpenAccountHud(playerid)
{
    CEF_AccountStats(playerid, PI[playerid][pCash], PI[playerid][pBank], PI[playerid][pLevel], PI[playerid][pExp], PI[playerid][pWanted]);
    return 1;
}

stock CEF_OpenChat(playerid)
{
    CEF_ChatInit(playerid);
    CEF_ChatAddMessage(playerid, "CEF chat ready", "FFFFFF", false);
    return 1;
}

stock CEF_OpenPaydayDemo(playerid)
{
    new bankStr[32];
    format(bankStr, sizeof bankStr, "%d", PI[playerid][pBank]);
    CEF_ChatAddPayday(playerid, 45000, 0, 0, 0, 0, -4500, -1200, 0, 0, bankStr);
    return 1;
}

stock CEF_OpenUdoFSB(playerid)
{
    new nick[MAX_PLAYER_NAME], json[CEF_JSON_SIZE];
    CEF_JsonEscape(GetName(playerid), nick);
    format(json, sizeof json,
        "{\"type\":6,\"documentId\":550001,\"personalId\":90125,\"directorSignature\":\"A. V. Smirnov\",\"nickname\":\"%s\",\"fractionId\":2,\"rankId\":8,\"skinId\":%d,\"issuedDate\":%d}",
        nick, GetPlayerSkin(playerid), gettime());
    cef_emit_event(playerid, "cef_documents_open", CEFSTR(json));
    return 1;
}

stock CEF_OpenUdoMVD(playerid)
{
    new nick[MAX_PLAYER_NAME], json[CEF_JSON_SIZE];
    CEF_JsonEscape(GetName(playerid), nick);
    format(json, sizeof json,
        "{\"type\":7,\"documentId\":660002,\"personalId\":90226,\"directorSignature\":\"I. I. Petrov\",\"nickname\":\"%s\",\"fractionId\":3,\"rankId\":9,\"skinId\":%d,\"issuedDate\":%d}",
        nick, GetPlayerSkin(playerid), gettime());
    cef_emit_event(playerid, "cef_documents_open", CEFSTR(json));
    return 1;
}

stock CEF_OpenPassportCef(playerid)
{
    new nick[MAX_PLAYER_NAME], json[CEF_JSON_SIZE];
    CEF_JsonNick(playerid, nick);
    format(json, sizeof json,
        "{\"type\":1,\"data\":{\"nickname\":\"%s\",\"regDate\":\"2024-01-01 12:00:00\",\"birthDate\":\"%s\",\"documentId\":%d}}",
        nick, PI[playerid][pBirthDate], PI[playerid][pID]);
    CEF_OpenScreen(playerid, "cef_documents_open", json);
    return 1;
}

stock CEF_OpenLicensesCef(playerid)
{
    new json[CEF_JSON_SIZE];
    format(json, sizeof json,
        "{\"type\":5,\"data\":{\"licenses\":[{\"type\":1,\"validUntil\":\"12.12.2030\"},{\"type\":2,\"validUntil\":\"12.12.2030\"}]}}");
    CEF_OpenScreen(playerid, "cef_documents_open", json);
    return 1;
}

stock CEF_OpenPlateCef(playerid)
{
    CEF_PlateOpen(playerid, 1, "A123BC", 77, PI[playerid][pCash], 5000);
    return 1;
}

stock CEF_OpenRadialCef(playerid)
{
    CEF_RadialOpen(playerid, "[{\"key\":\"inv\",\"title\":\"INV\"},{\"key\":\"pass\",\"title\":\"Pass\"},{\"key\":\"lic\",\"title\":\"Lic\"},{\"key\":\"udo\",\"title\":\"Udo\"},{\"key\":\"anim\",\"title\":\"Anim\"},{\"key\":\"ads\",\"title\":\"Ads\"},{\"key\":\"support\",\"title\":\"Rep\"},{\"key\":\"map\",\"title\":\"Map\"},{\"key\":\"job\",\"title\":\"Job\"},{\"key\":\"bank\",\"title\":\"Bank\"}]");
    return 1;
}

stock CEF_OpenCasesCef(playerid)
{
    CEF_CasesOpen(playerid, 1);
    return 1;
}

stock CEF_OpenBattlePassCef(playerid)
{
    CEF_BattlePass(playerid, "Mini Battle Pass Autumn 2026", "2026-10-01T20:00:00.000Z", 1450, 2);
    return 1;
}


stock CEF_OpenUdoVCH(playerid)
{
    new nick[MAX_PLAYER_NAME], json[CEF_JSON_SIZE];
    CEF_JsonEscape(GetName(playerid), nick);
    format(json, sizeof json,
        "{\"type\":9,\"documentId\":770003,\"personalId\":90327,\"directorSignature\":\"S. S. Ivanov\",\"nickname\":\"%s\",\"fractionId\":4,\"rankId\":5,\"skinId\":%d,\"issuedDate\":%d}",
        nick, GetPlayerSkin(playerid), gettime());
    cef_emit_event(playerid, "cef_documents_open", CEFSTR(json));
    return 1;
}

stock ShowPlayerCefDoc(playerid, docType)
{
    if(docType == 6) return CEF_OpenUdoFSB(playerid);
    if(docType == 7) return CEF_OpenUdoMVD(playerid);
    if(docType == 9) return CEF_OpenUdoVCH(playerid);
    return CEF_OpenPassportCef(playerid);
}

CMD:cefchat(playerid, params[])
{
    CEF_MarkPlayerReady(playerid);
    CEF_OpenChat(playerid);
    return 1;
}

CMD:cefpd(playerid, params[])
{
    #pragma unused params
    CEF_MarkPlayerReady(playerid);
    CEF_OpenPaydayDemo(playerid);
    return 1;
}

CMD:cefudo(playerid, params[])
{
    CEF_MarkPlayerReady(playerid);
    if(params[0] == '9') ShowPlayerCefDoc(playerid, 9);
    else if(params[0] == '7') ShowPlayerCefDoc(playerid, 7);
    else ShowPlayerCefDoc(playerid, 6);
    return 1;
}

CMD:cefpass(playerid, params[])
{
    #pragma unused params
    CEF_MarkPlayerReady(playerid);
    CEF_OpenPassportCef(playerid);
    return 1;
}

CMD:ceflic(playerid, params[])
{
    #pragma unused params
    CEF_MarkPlayerReady(playerid);
    CEF_OpenLicensesCef(playerid);
    return 1;
}

CMD:cefplate(playerid, params[])
{
    #pragma unused params
    CEF_MarkPlayerReady(playerid);
    CEF_OpenPlateCef(playerid);
    return 1;
}

CMD:cefradial(playerid, params[])
{
    #pragma unused params
    CEF_MarkPlayerReady(playerid);
    CEF_OpenRadialCef(playerid);
    return 1;
}

CMD:cefcase(playerid, params[])
{
    #pragma unused params
    CEF_MarkPlayerReady(playerid);
    CEF_OpenCasesCef(playerid);
    return 1;
}

CMD:cefbp(playerid, params[])
{
    #pragma unused params
    CEF_MarkPlayerReady(playerid);
    CEF_OpenBattlePassCef(playerid);
    return 1;
}

CMD:cefhud(playerid, params[])
{
    #pragma unused params
    CEF_MarkPlayerReady(playerid);
    CEF_OpenAccountHud(playerid);
    return 1;
}

CMD:ceftest(playerid, params[])
{
    #pragma unused params
    if(PI[playerid][pAdmin] < 1) return 1;
    CEF_MarkPlayerReady(playerid);
    CEF_EmitCatalog(playerid);
    SendClientMessage(playerid, 0x54B367FF, "[CEF] catalog emitted");
    return 1;
}
