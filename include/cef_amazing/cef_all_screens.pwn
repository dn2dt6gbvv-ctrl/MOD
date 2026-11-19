













#if defined _CEF_ALL_SCREENS_INCLUDED
    #endinput
#endif
#define _CEF_ALL_SCREENS_INCLUDED

#define CEF_SCREEN_COUNT 48
#define CEF_GROUP_COUNT  32
#define CEF_SCREEN_PW    2863




static const gCefScreenEvent[48][40] = {
    "cef_admin_notification_show",
    "cef_amazing_pass_show",
    "cef_dooms_day_modal_show",
    "cef_drift_race_show",
    "cef_effects_list_show",
    "cef_extra_hint_info_show",
    "cef_free_roulette_show",
    "cef_games_hud_show",
    "cef_games_info_show",
    "cef_guess_event_open",
    "cef_halloween_stinger_show",
    "cef_interactive_actions_list_show",
    "cef_loading_screen_show",
    "cef_newyear_darkzone_inv_show",
    "cef_notary_show",
    "cef_press_on_time_game_open",
    "cef_ratings_show",
    "cef_reaction_game_open",
    "cef_scoreboard_show",
    "cef_session_time_show",
    "cef_shop_selector_show",
    "cef_trc_newspaper_article_open",
    "cef_tutorial_show",
    "cef_cargo_aggregator_open",
    "cef_video_player_show",
    "cef_traffic_notice_show",
    "cef_fractions_contest_open",
    "cef_spells_drawing_open",
    "cef_support_overlay_show",
    "cef_sys_notification_show",
    "cef_stalker_comb_hack_open",
    "cef_stalker_pda_open",
    "cef_stlk_artifact_detector_open",
    "cef_stlk_blog_show",
    "cef_stlk_buyer_show",
    "cef_stlk_capture_show",
    "cef_stlk_converter_show",
    "cef_stlk_craft_show",
    "cef_stlk_equipment_show",
    "cef_stlk_lobbies_show",
    "cef_stlk_location_selector_show",
    "cef_stlk_lost_items_show",
    "cef_stlk_notifications_show",
    "cef_stlk_npc_msg_show",
    "cef_stlk_radio_receiver_open",
    "cef_stlk_raid_loadout_show",
    "cef_stlk_teleporter_show",
    "cef_stlk_veh_repair_show"
};

static const gCefScreenClose[48][40] = {
    "",
    "cef_amazing_pass_hide",
    "cef_dooms_day_modal_hide",
    "",
    "cef_effects_list_hide",
    "cef_extra_hint_info_hide",
    "cef_free_roulette_hide",
    "cef_games_hud_hide",
    "cef_games_info_hide",
    "",
    "",
    "cef_interactive_actions_list_hide",
    "cef_loading_screen_hide",
    "cef_newyear_darkzone_inv_hide",
    "cef_notary_hide",
    "",
    "cef_ratings_hide",
    "",
    "cef_scoreboard_hide",
    "cef_session_time_hide",
    "cef_shop_selector_hide",
    "",
    "cef_tutorial_hide",
    "",
    "cef_video_player_hide",
    "cef_traffic_notice_hide",
    "",
    "",
    "cef_support_overlay_hide",
    "cef_sys_notification_hide",
    "",
    "",
    "",
    "cef_stlk_blog_hide",
    "",
    "cef_stlk_capture_hide",
    "cef_stlk_converter_hide",
    "cef_stlk_craft_hide",
    "cef_stlk_equipment_hide",
    "cef_stlk_lobbies_hide",
    "cef_stlk_location_selector_hide",
    "cef_stlk_lost_items_hide",
    "cef_stlk_notifications_hide",
    "cef_stlk_npc_msg_hide",
    "",
    "cef_stlk_raid_loadout_hide",
    "cef_stlk_teleporter_hide",
    ""
};

static const gCefScreenPayload[48][2863] = {
    "{}",
    "{}",
    "{\"headerLabel\": \"\\u0412 \\u041f\\u0420\\u041e\\u0426\\u0415\\u0421\\u0421\\u0415\", \"text\": \"\\u0413\\u043e\\u0442\\u043e\\u0432\\u044b \\u043f\\u043e\\u0433\\u0440\\u0443\\u0437\\u0438\\u0442\\u044c\\u0441\\u044f \\u0432 \\u0445\\u0430\\u043e\\u0441? \\u0418\\u043c\\u0435\\u043d\\u043d\\u043e \\u0432 \\u044d\\u0442\\u0443 \\u043d\\u043e\\u0447\\u044c \\u043e\\u0442\\u043c\\u0435\\u043d\\u044f\\u044e\\u0442\\u0441\\u044f {FFFF00}\\u0431\\u043e\\u043b\\u044c\\u0448\\u0438\\u043d\\u0441\\u0442\\u0432\\u043e\\n\\u0438\\u0433\\u0440\\u043e\\u0432\\u044b\\u0445 \\u043f\\u0440\\u0430\\u0432\\u0438\\u043b \\u0438 \\u0442\\u0432\\u043e\\u0440\\u0438\\u0442\\u0441\\u044f \\u0432\\u0441\\u0435\\u0434\\u043e\\u0437\\u0432\\u043e\\u043b\\u0435\\u043d\\u043d\\u043e\\u0441\\u0442\\u044c!\", \"timeInfo\": \"\\u0421\\u0443\\u0434\\u043d\\u0430\\u044f \\u043d\\u043e\\u0447\\u044c \\u043f\\u0440\\u043e\\u0434\\u043b\\u0438\\u0442\\u0441\\u044f \\u0441 21:00 \\u0434\\u043e 00:00 \\u043f\\u043e \\u041c\\u0421\\u041a\"}",
    "{\"raceType\": 1, \"trackName\": \"\\u041f\\u043e\\u0440\\u0442 \\u041b\\u043e\\u0441-\\u0421\\u0430\\u043d\\u0442\\u043e\\u0441\", \"score\": 1250, \"scoreOpponent\": 0, \"time\": 300}",
    "{}",
    "{}",
    "{}",
    "{}",
    "{}",
    "{}",
    "{}",
    "{\"actions\": \"\\u0421\\u0435\\u0441\\u0442\\u044c \\u0432 \\u0442\\u0440\\u0430\\u043d\\u0441\\u043f\\u043e\\u0440\\u0442`\\u041e\\u0442\\u043a\\u0440\\u044b\\u0442\\u044c \\u0438\\u043d\\u0432\\u0435\\u043d\\u0442\\u0430\\u0440\\u044c`\\u041f\\u043e\\u0437\\u0432\\u0430\\u0442\\u044c \\u0438\\u0433\\u0440\\u043e\\u043a\\u0430\", \"selectedIndex\": 0, \"key\": \"E\", \"x\": 0.54, \"y\": 0.51}",
    "{}",
    "{}",
    "{}",
    "{}",
    "{}",
    "{}",
    "{}",
    "{}",
    "{}",
    "{}",
    "{\"text\": \"\\u0414\\u043e\\u0431\\u0440\\u043e \\u043f\\u043e\\u0436\\u0430\\u043b\\u043e\\u0432\\u0430\\u0442\\u044c! \\u041d\\u0430\\u0436\\u043c\\u0438\\u0442\\u0435 <l>F3</l> \\u2014 \\u043f\\u043e\\u043c\\u043e\\u0449\\u044c, <l>TAB</l> \\u2014 \\u0438\\u043d\\u0432\\u0435\\u043d\\u0442\\u0430\\u0440\\u044c, <l>F6</l> \\u2014 \\u0447\\u0430\\u0442.\", \"step\": 1, \"steps\": 3}",
    "{\"state\": {\"activeOrderId\": 1, \"hasOwnTruck\": true, \"currentSkill\": 500}, \"orders\": [[1, 10, 1, 2139, 24, 281, 0, 30256, 19289, 97530, 1439], [2, 10, 11, 36241, 3, 604, 1, 5165, 4905, 13280, 2391], [3, 3, 8, 39953, 1, 574, 0, 94850, 86181, 92924, 5064], [4, 6, 3, 29939, 19, 284, 0, 21926, 92506, 56392, 3387], [5, 4, 2, 14610, 11, 104, 0, 50797, 13676, 48052, 3417], [6, 9, 4, 3347, 24, 470, 0, 50615, 11328, 73357, 3001], [7, 13, 10, 41035, 12, 591, 0, 93349, 10116, 7006, 6017], [8, 3, 12, 19465, 3, 875, 0, 14238, 50823, 37434, 4314], [9, 10, 13, 24409, 6, 379, 1, 28460, 88841, 35993, 6349], [10, 14, 10, 42969, 3, 623, 0, 71010, 96568, 33087, 1938], [11, 7, 6, 18191, 21, 704, 0, 90733, 43504, 8331, 2476], [12, 13, 0, 21173, 13, 274, 0, 28653, 75341, 95098, 3177], [13, 3, 10, 33217, 13, 905, 1, 19726, 35718, 19301, 2620], [14, 11, 8, 35822, 9, 764, 1, 77484, 53350, 48447, 2396], [15, 2, 8, 32843, 3, 773, 0, 15371, 21033, 83240, 1910], [16, 12, 10, 28166, 20, 65, 1, 51019, 79104, 62348, 4934], [17, 4, 8, 1252, 22, 738, 0, 90353, 71381, 99419, 2785], [18, 12, 10, 22793, 4, 300, 1, 21730, 60470, 1425, 6515], [19, 14, 11, 17761, 17, 780, 0, 67542, 14947, 82959, 3044], [20, 13, 10, 33770, 20, 203, 0, 50009, 22174, 71697, 6978], [21, 14, 8, 537, 20, 331, 1, 3552, 15662, 48576, 3119], [22, 3, 0, 16285, 19, 969, 0, 12226, 96932, 64699, 1166], [23, 12, 8, 8741, 5, 675, 1, 73063, 22643, 35741, 4922], [24, 13, 9, 28230, 7, 951, 0, 94447, 41857, 53296, 6102], [25, 10, 5, 29211, 17, 462, 0, 33493, 30451, 9392, 3369], [26, 0, 9, 36801, 8, 602, 0, 1942, 10305, 93778, 5769], [27, 0, 3, 4917, 2, 880, 1, 10287, 68391, 32195, 2881], [28, 10, 7, 14540, 18, 135, 1, 32850, 62993, 54354, 2159], [29, 1, 1, 43687, 14, 362, 1, 54883, 62213, 96561, 1043], [30, 10, 10, 42848, 4, 62, 1, 96448, 45473, 15322, 2636], [31, 3, 3, 35646, 15, 143, 1, 25050, 37509, 61637, 2646], [32, 13, 14, 5440, 15, 827, 0, 7630, 86477, 71855, 720], [33, 1, 14, 49885, 8, 170, 1, 64653, 64092, 29016, 3885], [34, 14, 0, 11289, 13, 2, 1, 35760, 60638, 38388, 4065], [35, 11, 11, 36922, 22, 735, 1, 21289, 25890, 39890, 2383], [36, 0, 9, 48717, 18, 62, 1, 8492, 7572, 77569, 4505], [37, 8, 14, 35307, 6, 58, 0, 25356, 9981, 78992, 1156], [38, 10, 13, 15914, 13, 122, 0, 76880, 78924, 6209, 5673], [39, 1, 6, 43581, 19, 578, 1, 35179, 27772, 88782, 6467], [40, 5, 3, 17907, 13, 134, 1, 60929, 42441, 99548, 1194]], \"demands\": {\"endsIn\": 420, \"maxAward\": 87, \"cargos\": [18, 23, 10, 20, 21, 17]}, \"ratings\": {\"period\": {\"start\": 15, \"end\": 18}, \"companies\": [[\"Company #1\", 10, 59], [\"Company #2\", 637, 73], [\"Company #3\", 103, 10], [\"Company #4\", 551, 28], [\"Company #5\", 519, 34], [\"Company #6\", 136, 45], [\"Company #7\", 903, 9], [\"Company #8\", 901, 32], [\"Company #9\", 379, 37], [\"Company #10\", 162, 57]]}}",
    "{\"url\": \"assets/videos/previews/fluffy.mp4\"}",
    "{}",
    "{}",
    "{}",
    "{}",
    "{\"text\": \"\\u0422\\u0435\\u0441\\u0442\\u043e\\u0432\\u043e\\u0435 \\u0441\\u0438\\u0441\\u0442\\u0435\\u043c\\u043d\\u043e\\u0435 \\u0443\\u0432\\u0435\\u0434\\u043e\\u043c\\u043b\\u0435\\u043d\\u0438\\u0435\", \"type\": \"info\"}",
    "{}",
    "{}",
    "{}",
    "{}",
    "{}",
    "{}",
    "{}",
    "{}",
    "{}",
    "{}",
    "{}",
    "{}",
    "{}",
    "{}",
    "{}",
    "{}",
    "{}",
    "{}"
};

static const gCefGroupKey[32][32] = {
    "admin_notification",
    "amazing_pass",
    "dooms_day_modal",
    "drift_race",
    "effects_list",
    "extra_hint_info",
    "free_roulette",
    "games_hud",
    "games_info",
    "guess_event",
    "halloween_stinger",
    "interactive_actions_list",
    "loading_screen",
    "newyear_darkzone_inv",
    "notary",
    "press_on_time_game",
    "ratings",
    "reaction_game",
    "scoreboard",
    "session_time",
    "shop_selector",
    "trc_newspaper_article",
    "tutorial",
    "cargo_aggregator",
    "video_player",
    "traffic_notice",
    "fractions_contest",
    "spells_drawing",
    "support_overlay",
    "sys_notification",
    "stalker",
    "stlk"
};

static const gCefGroupEvent[32][40] = {
    "cef_admin_notification_show",
    "cef_amazing_pass_show",
    "cef_dooms_day_modal_show",
    "cef_drift_race_show",
    "cef_effects_list_show",
    "cef_extra_hint_info_show",
    "cef_free_roulette_show",
    "cef_games_hud_show",
    "cef_games_info_show",
    "cef_guess_event_open",
    "cef_halloween_stinger_show",
    "cef_interactive_actions_list_show",
    "cef_loading_screen_show",
    "cef_newyear_darkzone_inv_show",
    "cef_notary_show",
    "cef_press_on_time_game_open",
    "cef_ratings_show",
    "cef_reaction_game_open",
    "cef_scoreboard_show",
    "cef_session_time_show",
    "cef_shop_selector_show",
    "cef_trc_newspaper_article_open",
    "cef_tutorial_show",
    "cef_cargo_aggregator_open",
    "cef_video_player_show",
    "cef_traffic_notice_show",
    "cef_fractions_contest_open",
    "cef_spells_drawing_open",
    "cef_support_overlay_show",
    "cef_sys_notification_show",
    "cef_stalker_comb_hack_open",
    "cef_stlk_artifact_detector_open"
};




stock CEF_ScreenIndex(const event[])
{
    new buf[64];
    for (new i = 0; i < CEF_SCREEN_COUNT; i++)
        if (!strcmp(gCefScreenEvent[i], event, false)) return i;
    for (new i = 0; i < CEF_SCREEN_COUNT; i++)
    {
        strmid(buf, gCefScreenEvent[i], 4, strlen(gCefScreenEvent[i]), 64);
        if (!strcmp(buf, event, false)) return i;
    }
    return -1;
}

stock CEF_GroupIndex(const key[])
{
    for (new i = 0; i < CEF_GROUP_COUNT; i++)
        if (!strcmp(gCefGroupKey[i], key, false)) return i;
    return -1;
}




stock CEF_ScreenOpen(player_id, idx)
{
    if (idx < 0 || idx >= CEF_SCREEN_COUNT) return 0;
    CEF_OpenScreen(player_id, gCefScreenEvent[idx], gCefScreenPayload[idx]);
    return 1;
}

stock CEF_ScreenOpenNamed(player_id, const event[])
{
    return CEF_ScreenOpen(player_id, CEF_ScreenIndex(event));
}

stock CEF_ScreenClose(player_id, idx)
{
    if (idx < 0 || idx >= CEF_SCREEN_COUNT) return 0;
    if (gCefScreenClose[idx][0] == EOS) return 0;
    CEF_Send(player_id, gCefScreenClose[idx], "{}");
    return 1;
}

stock CEF_ScreenCloseCurrent(player_id)
{

    return CEF_ScreenClose(player_id, CEF_ScreenIndex(gCef[player_id][cef_scene]));
}




stock CEF_GroupOpen(player_id, const key[])
{
    new gi = CEF_GroupIndex(key);
    if (gi < 0) return 0;
    return CEF_ScreenOpenNamed(player_id, gCefGroupEvent[gi]);
}




forward CEV_84(player_id, const arguments[]);
forward CEV_85(player_id, const arguments[]);
forward CEV_86(player_id, const arguments[]);
forward CEV_87(player_id, const arguments[]);
forward CEV_88(player_id, const arguments[]);
forward CEV_89(player_id, const arguments[]);
forward CEV_90(player_id, const arguments[]);

public CEV_84(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_amazing_pass_response", arguments); }
public CEV_85(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_color_picker_live_response", arguments); }
public CEV_86(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_color_picker_temp_response", arguments); }
public CEV_87(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_color_picker_response", arguments); }
public CEV_88(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_craft_response", arguments); }
public CEV_89(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_dooms_day_response", arguments); }
public CEV_90(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_drift_response", arguments); }










CMD:screen(playerid, params[])
{
    new sub[32], arg[64], line[160];
    sub[0] = EOS; arg[0] = EOS;
    sscanf(params, "s[32]S()[64]", sub, arg);

    if (!sub[0])
    {
        format(line, sizeof line, "[SCREEN] Каталог: %d экранов, %d групп. /screen list | /screen 5 | /screen tutorial_show | /screen close", CEF_SCREEN_COUNT, CEF_GROUP_COUNT);
        SendClientMessage(playerid, 0xFFCC00FF, line);
        return 1;
    }
    if (!strcmp(sub, "list", false))
    {
        new page = strval(arg);
        if (page < 0) page = 0;
        new start = page * 8;
        if (start >= CEF_SCREEN_COUNT) start = 0;
        for (new i = start; i < start + 8 && i < CEF_SCREEN_COUNT; i++)
        {
            format(line, sizeof line, "[SCREEN] %d. %s", i, gCefScreenEvent[i]);
            SendClientMessage(playerid, 0xFFFFFFFF, line);
        }
        format(line, sizeof line, "[SCREEN] стр. %d из %d (/screen list %d — дальше)", page, (CEF_SCREEN_COUNT + 7) / 8 - 1, page + 1);
        SendClientMessage(playerid, 0xFFCC00FF, line);
        return 1;
    }
    if (!strcmp(sub, "groups", false))
    {
        for (new i = 0; i < CEF_GROUP_COUNT && i < 16; i++)
        {
            format(line, sizeof line, "[SCREEN] SYS_%s -> %s", gCefGroupKey[i], gCefGroupEvent[i]);
            SendClientMessage(playerid, 0xFFFFFFFF, line);
        }
#if CEF_GROUP_COUNT > 16
        SendClientMessage(playerid, 0xFFCC00FF, "[SCREEN] ... остальное в gCefGroupKey (cef_all_screens.pwn)");
#endif
        return 1;
    }
    if (!strcmp(sub, "close", false))
    {
        if (arg[0] == EOS)
        {
            if (CEF_ScreenCloseCurrent(playerid)) SendClientMessage(playerid, 0x66FF66FF, "[SCREEN] Текущий экран закрыт.");
            else SendClientMessage(playerid, 0xFF6666FF, "[SCREEN] Нет открытого экрана.");
            return 1;
        }
        new idx = strval(arg);
        if (idx <= 0 && arg[0] != '0') idx = CEF_ScreenIndex(arg);
        if (idx < 0) { SendClientMessage(playerid, 0xFF6666FF, "[SCREEN] Экран не найден."); return 1; }
        if (CEF_ScreenClose(playerid, idx)) SendClientMessage(playerid, 0x66FF66FF, "[SCREEN] Закрыт.");
        else SendClientMessage(playerid, 0xFF6666FF, "[SCREEN] У экрана нет close-события.");
        return 1;
    }
    if (!strcmp(sub, "group", false))
    {
        if (arg[0] == EOS) { SendClientMessage(playerid, 0xFF6666FF, "[SCREEN] /screen group <ключ> (список: /screen groups)"); return 1; }
        if (CEF_GroupOpen(playerid, arg)) SendClientMessage(playerid, 0x66FF66FF, "[SCREEN] Экран группы открыт.");
        else SendClientMessage(playerid, 0xFF6666FF, "[SCREEN] Группа не найдена.");
        return 1;
    }

    new idx = strval(sub);
    if (idx <= 0 && sub[0] != '0') idx = CEF_ScreenIndex(sub);
    if (idx < 0) { SendClientMessage(playerid, 0xFF6666FF, "[SCREEN] Экран не найден. Список: /screen list"); return 1; }
    if (CEF_ScreenOpen(playerid, idx))
    {
        format(line, sizeof line, "[SCREEN] Открыт экран %d: %s", idx, gCefScreenEvent[idx]);
        SendClientMessage(playerid, 0x66FF66FF, line);
    }
    return 1;
}
