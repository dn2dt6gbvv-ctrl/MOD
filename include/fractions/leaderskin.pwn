
new const LeaderSkins[][10] = {
    {0,0,0,0,0,0,0,0,0,0},
    {227,211,187,164,130,141,147,59,295,0},
    {163, 166, 167, 286, 165, 285, 175, 184, 203, 0},
    {106,282,281,266,284,280,283,0,0,0},
    {106,288,158,133,267,12,265,76,153,0},
    {70,148,274,275,276,0,0,0,0,0},
    {61,73,206,179,191,180,183,185,186,0},
    {193,114,115,116,292,0,0,0,0,0},
    {122,123,124,126,0,0,0,0,0,0},
    {98,46,121,125,0,0,0,0,0,0},
    {193,114,115,116,292,0,0,0,0,0}
};

stock ShowLeaderSkinSelector(leaderid, targetid)
{
    if (!cef_player_has_plugin(leaderid) || !PT[leaderid][pCefLoaded]) return 0;

    new fractionid = PI[leaderid][pFraction];
    if (fractionid < 1 || fractionid > 10) return 0;


    if (PI[targetid][pFraction] != fractionid) {
        CEFChat_Send(leaderid, "FF4444", "Игрок не состоит в вашей организации.");
        return 0;
    }

    g_LeaderSkinTarget[leaderid] = targetid;
    PT[leaderid][pLeaderSkinFrac] = fractionid;

    cef_create_browser(leaderid, LEADERSKIN_BROWSER, LEADERSKIN_LINK, false, true);
    cef_always_listen_keys(leaderid, LEADERSKIN_BROWSER, true);
    return 1;
}

forward SendLeaderSkinData(playerid);
public SendLeaderSkinData(playerid)
{
    if(!IsPlayerConnected(playerid)) return;
    new targetName[MAX_PLAYER_NAME];
    new targetid = g_LeaderSkinTarget[playerid];
    if(IsPlayerConnected(targetid)) GetPlayerName(targetid, targetName, sizeof(targetName));
    cef_emit_event(playerid, "leaderskin:open",
        CEFINT(PT[playerid][pLeaderSkinFrac]),
        CEFINT(targetid),
        CEFSTR(targetName)
    );
}

callback::OnLeaderSkinSelect(playerid, const arguments[])
{
    if (!PT[playerid][pLogged]) return 1;

    new fractionid = PI[playerid][pFraction];
    if (fractionid < 1) return 1;

    new targetid, skinid;
    sscanf(arguments, "dd", targetid, skinid);

    if (!IsPlayerConnected(targetid)) {
        CEFChat_Send(playerid, "FF4444", "Игрок уже не в сети.");
        return closeLeaderSkin(playerid);
    }

    if (PI[targetid][pFraction] != fractionid) {
        CEFChat_Send(playerid, "FF4444", "Игрок не в вашей организации.");
        return closeLeaderSkin(playerid);
    }

    new bool:valid = false;
    for (new i = 0; i < 10; i++) {
        if (LeaderSkins[fractionid][i] == skinid) { valid = true; break; }
    }
    if (!valid) {
        CEFChat_Send(playerid, "FF4444", "Неверный скин для этой фракции.");
        return 1;
    }

    PI[targetid][pFractionSkin] = skinid;
    SetPlayerSkin(targetid, skinid);

    new query[128];
    mysql_format(dbHandle, query, sizeof(query),
        "UPDATE `accounts` SET `fraction_skin` = %d WHERE `id` = %d",
        skinid, PI[targetid][pID]);
    mysql_tquery(dbHandle, query, "", "");

    new msg[128];
    format(msg, sizeof(msg), "Лидер %s выдал вам скин.", GetName(playerid));
    CEFChat_Send(targetid, "54B367", msg);
    CEFChat_Send(playerid, "54B367", "Скин успешно выдан.");

    return closeLeaderSkin(playerid);
}

callback::OnLeaderSkinClose(playerid, const arguments[])
{
    return closeLeaderSkin(playerid);
}

stock closeLeaderSkin(playerid)
{
    cef_focus_browser(playerid, LEADERSKIN_BROWSER, false);
    cef_destroy_browser(playerid, LEADERSKIN_BROWSER);
    g_LeaderSkinTarget[playerid] = -1;
    PT[playerid][pLeaderSkinFrac] = 0;
    return 1;
}

cmd:changeskin(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;
    new fractionid = PI[playerid][pFraction];
    if(!fractionid) return SendErr(playerid, "Вы не состоите в организации.");
    if(PI[playerid][pFractionRank] != Fraction[fractionid][fMax_ranks])
        return SendErr(playerid, "Только лидер организации может выдавать скины.");

    new targetid;
    if(sscanf(params, "u", targetid)) return SendErr(playerid, "Использование: /changeskin [ID игрока]");
    if(!IsPlayerConnected(targetid)) return SendErr(playerid, "Игрок не в сети.");
    if(PI[targetid][pFraction] != fractionid) return SendErr(playerid, "Игрок не в вашей организации.");
    if(!ProxDetectorS(3.0, playerid, targetid)) return SendErr(playerid, "Вы слишком далеко от игрока.");
    ShowLeaderSkinSelector(playerid, targetid);
    return 1;
}
