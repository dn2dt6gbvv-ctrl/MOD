




























#if defined _cef_bridge_included
    #endinput
#endif
#define _cef_bridge_included

#define CEF_CASINO_RATE_BUY  1000
#define CEF_CASINO_RATE_SELL 1000
#define CEF_CASINO_MAX_TRADE 50000

forward CEF_EcoShopResponse(playerid, const arguments[]);
forward CEF_HotkeyHandle(player_id, const arguments[]);
forward CEF_InvItemActionHandle(player_id, const arguments[]);
forward CEF_HotkeyGameKey(playerid, key);
forward CEF_AdminPanelClose(playerid);
forward CEF_SupportClose(playerid);
forward CEF_AuthClose(playerid);
forward CEF_AuthSignIn(playerid, style, const title[], const text[], const b1[], const b2[]);
forward CEF_AuthSignUp(playerid, style, title[], text[], b1[], b2[]);
forward CEF_EcoGasResponse(playerid, const arguments[]);
forward CEF_EcoJobResponse(playerid, const arguments[]);




#define CEF_BROWSER_MAIN     MAIN_BROWSER
#define CEF_URL              "http://cef/index.html"




#define CEF_JSON_SIZE        8192
#define CEF_EVENT_SIZE       64




enum e_CEF_PLAYER {
    bool:cef_ready,
    bool:cef_visible,
    cef_scene[32]
}
new gCef[MAX_PLAYERS][e_CEF_PLAYER];






stock CEF_MarkPlayerReady(player_id)
{
    gCef[player_id][cef_ready] = true;
    CEF_SubscribeAll();
    return 1;
}

stock CEF_MarkPlayerReset(player_id)
{
    gCef[player_id][cef_ready] = false;
    gCef[player_id][cef_visible] = false;
    gCef[player_id][cef_scene][0] = EOS;
    return 1;
}

stock CEF_OnMainBrowserReady(player_id)
{
    gCef[player_id][cef_ready] = true;
    CEF_SubscribeAll();
    CEF_SendEmpty(player_id, "cef_app_ready");
    return 1;
}




forward CEF_Send(player_id, const event[], const json[]);
public CEF_Send(player_id, const event[], const json[])
{
    if (!IsPlayerConnected(player_id) || !gCef[player_id][cef_ready]) return 0;

    cef_emit_event(player_id, event, CEFSTR(json));
    return 1;
}


stock CEF_SendEmpty(player_id, const event[])
{
    return CEF_Send(player_id, event, "{}");
}


stock CEF_Show(player_id, bool:focus = false)
{
    if (focus) cef_focus_browser(player_id, CEF_BROWSER_MAIN, true);
    gCef[player_id][cef_visible] = true;
}

stock CEF_Hide(player_id)
{
    cef_focus_browser(player_id, CEF_BROWSER_MAIN, false);
    gCef[player_id][cef_visible] = false;
}

stock CEF_Focus(player_id, bool:on)
{
    cef_focus_browser(player_id, CEF_BROWSER_MAIN, on);
}


stock CEF_OpenScreen(player_id, const event[], const json[])
{
    CEF_Show(player_id, false);
    CEF_Send(player_id, event, json);

    strmid(gCef[player_id][cef_scene], event, 0, 31);
    return 1;
}







forward CEF_OnUIEvent(player_id, const event[], const arguments[]);


stock CEF_NowIso()
{
    new y, m, d, h, mi, s, out[24];
    getdate(y, m, d); gettime(h, mi, s);
    format(out, sizeof out, "%04d-%02d-%02dT%02d:%02d:%02d", y, m, d, h, mi, s);
    return out;
}

new bool:gCefSubscribed = false;

stock CEF_SubscribeAll()
{
    if(gCefSubscribed) return 1;
    gCefSubscribed = true;


    cef_subscribe("cef_app_started", "CEVC_AppStarted");
    cef_subscribe("cef_app_ready",   "CEVC_AppReady");
    cef_subscribe("on_menu_closed", "CEVC_MenuClosed");
    cef_subscribe("perks_response", "CEVC_Perks");
    cef_subscribe("cef_perks_response", "CEVC_Perks");
    cef_subscribe("daily_task_reset", "CEVC_Tasks");
    cef_subscribe("cef_prize_menu_response", "CEVC_Prizes");
    cef_subscribe("cef_rpc_bank",       "CEVC_RpcBank");
    cef_subscribe("cef_rpc_documents",  "CEVC_RpcDocs");
    cef_subscribe("cef_rpc_shop",       "CEVC_RpcShop");
    cef_subscribe("cef_rpc_car_service","CEVC_RpcService");
    cef_subscribe("cef_rpc_auth",       "CEVC_RpcAuth");
    cef_subscribe("cef_rpc_cases", "CEVR_00");
    cef_subscribe("cef_rpc_casino", "CEVR_01");
    cef_subscribe("cef_rpc_christmas_tree", "CEVR_02");
    cef_subscribe("cef_rpc_cleaning_extermination", "CEVR_03");
    cef_subscribe("cef_rpc_cleaning_washing", "CEVR_04");
    cef_subscribe("cef_rpc_event_market", "CEVR_05");
    cef_subscribe("cef_rpc_food_delivery", "CEVR_06");
    cef_subscribe("cef_rpc_letter_building", "CEVR_07");
    cef_subscribe("cef_rpc_lock_picking", "CEVR_08");
    cef_subscribe("cef_rpc_pin_code", "CEVR_09");
    cef_subscribe("cef_rpc_season_pass", "CEVR_10");
    cef_subscribe("cef_rpc_spells_drawing", "CEVR_11");
    cef_subscribe("cef_rpc_stalker_pda", "CEVR_12");
    cef_subscribe("cef_rpc_tau_meter", "CEVR_13");
    cef_subscribe("cef_rpc_trade_store", "CEVR_14");
    cef_subscribe("cef_rpc_trc_newspaper_article", "CEVR_15");
    cef_subscribe("cef_rpc_wires_hacking", "CEVR_16");
    cef_subscribe("cef_hotkey",          "CEVC_Hotkey");
    cef_subscribe("cef_inv_item_action",  "CEVC_InvItemAction");
    cef_subscribe("cef_fines_pay", "CEVC_FinesPay");
    cef_subscribe("cef_fines_pay_all", "CEVC_FinesPayAll");
    cef_subscribe("cef_fines_close", "CEVC_FinesClose");
    cef_subscribe("cef_radar_place", "CEVC_RadarPlace");
    cef_subscribe("cef_radar_remove", "CEVC_RadarRemove");
    cef_subscribe("cef_radar_close", "CEVC_RadarClose");
    cef_subscribe("cef_inventory_use", "CEVC_InventoryUse");
    cef_subscribe("cef_inventory_drop", "CEVC_InventoryDrop");
    cef_subscribe("cef_inventory_give", "CEVC_InventoryGive");
    cef_subscribe("cef_inventory_move", "CEVC_InventoryMove");
    cef_subscribe("cef_inventory_rotate", "CEVC_InventoryRotate");
    cef_subscribe("cef_inventory_close", "CEVC_InventoryClosed");
    cef_subscribe("cef_inventory_closed", "CEVC_InventoryClosed");

    cef_subscribe("cef_ads_edit_response", "CEV_01");
    cef_subscribe("cef_device_settings_response", "CEV_02");
    cef_subscribe("cef_emotes_menu_response", "CEV_03");
    cef_subscribe("cef_esc_response", "CEV_04");
    cef_subscribe("cef_first_cam_settings_response", "CEV_05");
    cef_subscribe("cef_frc_members_list_response", "CEV_06");
    cef_subscribe("cef_fullscreen_hint_response", "CEV_07");
    cef_subscribe("cef_fullscreen_text_response", "CEV_08");
    cef_subscribe("cef_games_info_response", "CEV_09");
    cef_subscribe("cef_games_runner_response", "CEV_10");
    cef_subscribe("cef_gs_fueling_menu_response", "CEV_11");
    cef_subscribe("cef_guess_event_response", "CEV_12");
    cef_subscribe("cef_knockdown_screen_response", "CEV_13");
    cef_subscribe("cef_halloween_response", "CEV_14");
    cef_subscribe("cef_hunter_game_response", "CEV_15");
    cef_subscribe("cef_lock_turning_response", "CEV_16");
    cef_subscribe("cef_magic_battle_response", "CEV_17");
    cef_subscribe("cef_music_player_response", "CEV_18");
    cef_subscribe("cef_newyear_darkzone_inv_response", "CEV_19");
    cef_subscribe("cef_notary_response", "CEV_20");
    cef_subscribe("cef_object_inspection_response", "CEV_21");
    cef_subscribe("cef_pin_code_response", "CEV_22");
    cef_subscribe("cef_press_on_time_game_response", "CEV_23");
    cef_subscribe("cef_prize_menu_response", "CEV_24");
    cef_subscribe("cef_quest_dialogs_response", "CEV_25");
    cef_subscribe("cef_quick_map_response", "CEV_26");
    cef_subscribe("cef_quick_time_events_response", "CEV_27");
    cef_subscribe("cef_ratings_response", "CEV_28");
    cef_subscribe("cef_reaction_game_response", "CEV_29");
    cef_subscribe("cef_sawmill_response", "CEV_30");
    cef_subscribe("cef_screenshot_viewer_response", "CEV_31");
    cef_subscribe("cef_shop_selector_response", "CEV_32");
    cef_subscribe("cef_shoulder_straps_response", "CEV_33");
    cef_subscribe("cef_skin_selector_response", "CEV_34");
    cef_subscribe("cef_skin_viewer_response", "CEV_35");
    cef_subscribe("cef_tutorial_response", "CEV_36");
    cef_subscribe("cef_car_service_response", "CEV_37");
    cef_subscribe("cef_cargo_aggregator_response", "CEV_38");
    cef_subscribe("cef_admin_panel_response", "CEV_39");
    cef_subscribe("cef_bank_response", "CEV_40");
    cef_subscribe("cef_atm_response", "CEV_41");
    cef_subscribe("cef_video_player_response", "CEV_42");
    cef_subscribe("cef_voice_chat_settings_response", "CEV_43");
    cef_subscribe("cef_dialogs_response", "CEV_44");
    cef_subscribe("cef_license_plate_response", "CEV_45");
    cef_subscribe("cef_tablet_note_response", "CEV_46");
    cef_subscribe("cef_event_market_response", "CEV_47");
    cef_subscribe("cef_inventory_ui_response", "CEV_48");
    cef_subscribe("cef_tools_response", "CEV_49");
    cef_subscribe("cef_books_response", "CEV_50");
    cef_subscribe("cef_fractions_contest_response", "CEV_51");
    cef_subscribe("cef_shop_menu_response", "CEV_52");
    cef_subscribe("cef_animations_menu_response", "CEV_53");
    cef_subscribe("cef_mini_battle_pass_response", "CEV_54");
    cef_subscribe("cef_trash_exchanger_response", "CEV_55");
    cef_subscribe("cef_trade_response", "CEV_56");
    cef_subscribe("cef_weapons_sound_response", "CEV_57");
    cef_subscribe("cef_support_response", "CEV_58");
    cef_subscribe("cef_perks_response", "CEV_59");
    cef_subscribe("cef_car_pneumo_control_response", "CEV_60");
    cef_subscribe("cef_job_crafting_response", "CEV_61");
    cef_subscribe("cef_mining_farm_response", "CEV_62");
    cef_subscribe("cef_radial_menu_response", "CEV_63");
    cef_subscribe("cef_sys_notification_response", "CEV_64");
    cef_subscribe("cef_weapon_storage_response", "CEV_65");
    cef_subscribe("cef_stalker_armory_response", "CEV_66");
    cef_subscribe("cef_stalker_buyer_response", "CEV_67");
    cef_subscribe("cef_stalker_comb_hack_response", "CEV_68");
    cef_subscribe("cef_stalker_converter_response", "CEV_69");
    cef_subscribe("cef_stalker_craft_response", "CEV_70");
    cef_subscribe("cef_stalker_lost_items_response", "CEV_71");
    cef_subscribe("cef_stalker_pda_response", "CEV_72");
    cef_subscribe("cef_stalker_raid_loadout_response", "CEV_73");
    cef_subscribe("cef_stalker_raid_lobbies_response", "CEV_74");
    cef_subscribe("cef_stalker_teleporter_response", "CEV_75");
    cef_subscribe("cef_stalker_wires_hack_response", "CEV_76");
    cef_subscribe("cef_stlk_artfct_dtctr_response", "CEV_77");
    cef_subscribe("cef_stlk_equipment_response", "CEV_78");
    cef_subscribe("cef_stlk_location_selector_response", "CEV_79");
    cef_subscribe("cef_stlk_radio_receiver_response", "CEV_80");
    cef_subscribe("cef_stlk_vehicle_repair_response", "CEV_81");
    cef_subscribe("cef_leaderboard_response", "CEV_82");
    cef_subscribe("cef_chat_response", "CEV_83");
    return 1;
}


forward CEV_01(player_id, const arguments[]);
forward CEV_02(player_id, const arguments[]);
forward CEV_03(player_id, const arguments[]);
forward CEV_04(player_id, const arguments[]);
forward CEV_05(player_id, const arguments[]);
forward CEV_06(player_id, const arguments[]);
forward CEV_07(player_id, const arguments[]);
forward CEV_08(player_id, const arguments[]);
forward CEV_09(player_id, const arguments[]);
forward CEV_10(player_id, const arguments[]);
forward CEV_11(player_id, const arguments[]);
forward CEV_12(player_id, const arguments[]);
forward CEV_13(player_id, const arguments[]);
forward CEV_14(player_id, const arguments[]);
forward CEV_15(player_id, const arguments[]);
forward CEV_16(player_id, const arguments[]);
forward CEV_17(player_id, const arguments[]);
forward CEV_18(player_id, const arguments[]);
forward CEV_19(player_id, const arguments[]);
forward CEV_20(player_id, const arguments[]);
forward CEV_21(player_id, const arguments[]);
forward CEV_22(player_id, const arguments[]);
forward CEV_23(player_id, const arguments[]);
forward CEV_24(player_id, const arguments[]);
forward CEV_25(player_id, const arguments[]);
forward CEV_26(player_id, const arguments[]);
forward CEV_27(player_id, const arguments[]);
forward CEV_28(player_id, const arguments[]);
forward CEV_29(player_id, const arguments[]);
forward CEV_30(player_id, const arguments[]);
forward CEV_31(player_id, const arguments[]);
forward CEV_32(player_id, const arguments[]);
forward CEV_33(player_id, const arguments[]);
forward CEV_34(player_id, const arguments[]);
forward CEV_35(player_id, const arguments[]);
forward CEV_36(player_id, const arguments[]);
forward CEV_37(player_id, const arguments[]);
forward CEV_38(player_id, const arguments[]);
forward CEV_39(player_id, const arguments[]);
forward CEV_40(player_id, const arguments[]);
forward CEV_41(player_id, const arguments[]);
forward CEV_42(player_id, const arguments[]);
forward CEV_43(player_id, const arguments[]);
forward CEV_44(player_id, const arguments[]);
forward CEV_45(player_id, const arguments[]);
forward CEV_46(player_id, const arguments[]);
forward CEV_47(player_id, const arguments[]);
forward CEV_48(player_id, const arguments[]);
forward CEV_49(player_id, const arguments[]);
forward CEV_50(player_id, const arguments[]);
forward CEV_51(player_id, const arguments[]);
forward CEV_52(player_id, const arguments[]);
forward CEV_53(player_id, const arguments[]);
forward CEV_54(player_id, const arguments[]);
forward CEV_55(player_id, const arguments[]);
forward CEV_56(player_id, const arguments[]);
forward CEV_57(player_id, const arguments[]);
forward CEV_58(player_id, const arguments[]);
forward CEV_59(player_id, const arguments[]);
forward CEV_60(player_id, const arguments[]);
forward CEV_61(player_id, const arguments[]);
forward CEV_62(player_id, const arguments[]);
forward CEV_63(player_id, const arguments[]);
forward CEV_64(player_id, const arguments[]);
forward CEV_65(player_id, const arguments[]);
forward CEV_66(player_id, const arguments[]);
forward CEV_67(player_id, const arguments[]);
forward CEV_68(player_id, const arguments[]);
forward CEV_69(player_id, const arguments[]);
forward CEV_70(player_id, const arguments[]);
forward CEV_71(player_id, const arguments[]);
forward CEV_72(player_id, const arguments[]);
forward CEV_73(player_id, const arguments[]);
forward CEV_74(player_id, const arguments[]);
forward CEV_75(player_id, const arguments[]);
forward CEV_76(player_id, const arguments[]);
forward CEV_77(player_id, const arguments[]);
forward CEV_78(player_id, const arguments[]);
forward CEV_79(player_id, const arguments[]);
forward CEV_80(player_id, const arguments[]);
forward CEV_81(player_id, const arguments[]);
forward CEV_82(player_id, const arguments[]);
forward CEV_83(player_id, const arguments[]);

public CEV_01(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_ads_edit_response", arguments); }
public CEV_02(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_device_settings_response", arguments); }
public CEV_03(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_emotes_menu_response", arguments); }
public CEV_04(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_esc_response", arguments); }
public CEV_05(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_first_cam_settings_response", arguments); }
public CEV_06(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_frc_members_list_response", arguments); }
public CEV_07(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_fullscreen_hint_response", arguments); }
public CEV_08(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_fullscreen_text_response", arguments); }
public CEV_09(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_games_info_response", arguments); }
public CEV_10(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_games_runner_response", arguments); }
public CEV_11(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_gs_fueling_menu_response", arguments); }
public CEV_12(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_guess_event_response", arguments); }
public CEV_13(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_knockdown_screen_response", arguments); }
public CEV_14(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_halloween_response", arguments); }
public CEV_15(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_hunter_game_response", arguments); }
public CEV_16(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_lock_turning_response", arguments); }
public CEV_17(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_magic_battle_response", arguments); }
public CEV_18(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_music_player_response", arguments); }
public CEV_19(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_newyear_darkzone_inv_response", arguments); }
public CEV_20(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_notary_response", arguments); }
public CEV_21(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_object_inspection_response", arguments); }
public CEV_22(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_pin_code_response", arguments); }
public CEV_23(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_press_on_time_game_response", arguments); }
public CEV_24(player_id, const arguments[])   { return CEF_PrizesResponse(player_id, arguments); }
public CEV_25(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_quest_dialogs_response", arguments); }
public CEV_26(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_quick_map_response", arguments); }
public CEV_27(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_quick_time_events_response", arguments); }
public CEV_28(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_ratings_response", arguments); }
public CEV_29(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_reaction_game_response", arguments); }
public CEV_30(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_sawmill_response", arguments); }
public CEV_31(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_screenshot_viewer_response", arguments); }
public CEV_32(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_shop_selector_response", arguments); }
public CEV_33(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_shoulder_straps_response", arguments); }
public CEV_34(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_skin_selector_response", arguments); }
public CEV_35(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_skin_viewer_response", arguments); }
public CEV_36(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_tutorial_response", arguments); }
public CEV_37(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_car_service_response", arguments); }
public CEV_38(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_cargo_aggregator_response", arguments); }
public CEV_39(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_admin_panel_response", arguments); }
public CEV_40(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_bank_response", arguments); }
public CEV_41(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_atm_response", arguments); }
public CEV_42(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_video_player_response", arguments); }
public CEV_43(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_voice_chat_settings_response", arguments); }
public CEV_44(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_dialogs_response", arguments); }
public CEV_45(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_license_plate_response", arguments); }
public CEV_46(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_tablet_note_response", arguments); }
public CEV_47(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_event_market_response", arguments); }
public CEV_48(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_inventory_ui_response", arguments); }
public CEV_49(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_tools_response", arguments); }
public CEV_50(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_books_response", arguments); }
public CEV_51(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_fractions_contest_response", arguments); }
public CEV_52(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_shop_menu_response", arguments); }
public CEV_53(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_animations_menu_response", arguments); }
public CEV_54(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_mini_battle_pass_response", arguments); }
public CEV_55(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_trash_exchanger_response", arguments); }
public CEV_56(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_trade_response", arguments); }
public CEV_57(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_weapons_sound_response", arguments); }
public CEV_58(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_support_response", arguments); }

forward CEVC_Hotkey(player_id, const arguments[]);
public CEVC_Hotkey(player_id, const arguments[]) { return CEF_OnUIEvent(player_id, "cef_hotkey", arguments); }
forward CEVC_InvItemAction(player_id, const arguments[]);
public CEVC_InvItemAction(player_id, const arguments[]) { return CEF_OnUIEvent(player_id, "cef_inv_item_action", arguments); }
public CEV_59(player_id, const arguments[])   { return CEF_PerksResponse(player_id, arguments); }
public CEV_60(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_car_pneumo_control_response", arguments); }
public CEV_61(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_job_crafting_response", arguments); }
public CEV_62(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_mining_farm_response", arguments); }
public CEV_63(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_radial_menu_response", arguments); }
public CEV_64(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_sys_notification_response", arguments); }
public CEV_65(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_weapon_storage_response", arguments); }
public CEV_66(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_stalker_armory_response", arguments); }
public CEV_67(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_stalker_buyer_response", arguments); }
public CEV_68(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_stalker_comb_hack_response", arguments); }
public CEV_69(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_stalker_converter_response", arguments); }
public CEV_70(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_stalker_craft_response", arguments); }
public CEV_71(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_stalker_lost_items_response", arguments); }
public CEV_72(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_stalker_pda_response", arguments); }
public CEV_73(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_stalker_raid_loadout_response", arguments); }
public CEV_74(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_stalker_raid_lobbies_response", arguments); }
public CEV_75(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_stalker_teleporter_response", arguments); }
public CEV_76(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_stalker_wires_hack_response", arguments); }
public CEV_77(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_stlk_artfct_dtctr_response", arguments); }
public CEV_78(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_stlk_equipment_response", arguments); }
public CEV_79(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_stlk_location_selector_response", arguments); }
public CEV_80(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_stlk_radio_receiver_response", arguments); }
public CEV_81(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_stlk_vehicle_repair_response", arguments); }
public CEV_82(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_leaderboard_response", arguments); }
public CEV_83(player_id, const arguments[])   { return CEF_OnUIEvent(player_id, "cef_chat_response", arguments); }







stock CEF_OnUIEvent(player_id, const event[], const arguments[])
{

    if (!strcmp(event, "cef_chat_response", true)) {

        CEF_HandleChatMessage(player_id, arguments);
        return 1;
    }


    if (!strcmp(event, "cef_documents_response", true) || !strcmp(event, "cef_license_plate_response", true)) {

        CEF_HandlePlateAction(player_id, arguments);
        return 1;
    }


    if (!strcmp(event, "cef_radial_menu_response", true)) {

        CEF_HandleRadial(player_id, arguments);
        return 1;
    }


    if (!strcmp(event, "cef_mini_battle_pass_response", true)) {
        CEF_HandleBattlePass(player_id, arguments);
        return 1;
    }




    if (!strcmp(event, "cef_ads_edit_response", true)) {
        CEF_AllUiResponse(player_id, "cef_ads_edit_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_device_settings_response", true)) {
        CEF_AllUiResponse(player_id, "cef_device_settings_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_emotes_menu_response", true)) {
        CEF_AllUiResponse(player_id, "cef_emotes_menu_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_esc_response", true)) {
        CEF_OpsEscResponse(player_id, arguments);
        return 1;
    }
    if (!strcmp(event, "cef_first_cam_settings_response", true)) {
        CEF_AllUiResponse(player_id, "cef_first_cam_settings_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_frc_members_list_response", true)) {
        CEF_OpsMembersResponse(player_id, arguments);
        return 1;
    }
    if (!strcmp(event, "cef_fullscreen_hint_response", true)) {
        CEF_SendEmpty(player_id, "cef_fullscreen_hint_hide");
        return 1;
    }
    if (!strcmp(event, "cef_fullscreen_text_response", true)) {
        CEF_AllUiResponse(player_id, "cef_fullscreen_text_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_games_info_response", true)) {
        CEF_AllUiResponse(player_id, "cef_games_info_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_games_runner_response", true)) {
        CEF_AllUiResponse(player_id, "cef_games_runner_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_gs_fueling_menu_response", true)) {
        CEF_EcoGasResponse(player_id, arguments);
        return 1;
    }
    if (!strcmp(event, "cef_guess_event_response", true)) {
        CEF_AllUiResponse(player_id, "cef_guess_event_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_knockdown_screen_response", true)) {
        CEF_AllUiResponse(player_id, "cef_knockdown_screen_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_halloween_response", true)) {
        CEF_AllUiResponse(player_id, "cef_halloween_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_hunter_game_response", true)) {
        CEF_AllUiResponse(player_id, "cef_hunter_game_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_lock_turning_response", true)) {
        CEF_AllUiResponse(player_id, "cef_lock_turning_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_magic_battle_response", true)) {
        CEF_AllUiResponse(player_id, "cef_magic_battle_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_music_player_response", true)) {
        CEF_AllUiResponse(player_id, "cef_music_player_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_newyear_darkzone_inv_response", true)) {
        CEF_AllUiResponse(player_id, "cef_newyear_darkzone_inv_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_notary_response", true)) {
        CEF_AllUiResponse(player_id, "cef_notary_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_object_inspection_response", true)) {
        CEF_AllUiResponse(player_id, "cef_object_inspection_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_pin_code_response", true)) {
        CEF_AllUiResponse(player_id, "cef_pin_code_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_press_on_time_game_response", true)) {
        CEF_AllUiResponse(player_id, "cef_press_on_time_game_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_prize_menu_response", true)) {
        CEF_AllUiResponse(player_id, "cef_prize_menu_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_quest_dialogs_response", true)) {
        CEF_AllUiResponse(player_id, "cef_quest_dialogs_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_quick_map_response", true)) {
        CEF_AllUiResponse(player_id, "cef_quick_map_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_quick_time_events_response", true)) {
        CEF_AllUiResponse(player_id, "cef_quick_time_events_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_ratings_response", true)) {
        CEF_AllUiResponse(player_id, "cef_ratings_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_reaction_game_response", true)) {
        CEF_AllUiResponse(player_id, "cef_reaction_game_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_sawmill_response", true)) {
        CEF_AllUiResponse(player_id, "cef_sawmill_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_screenshot_viewer_response", true)) {
        CEF_AllUiResponse(player_id, "cef_screenshot_viewer_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_shop_selector_response", true)) {
        CEF_AllUiResponse(player_id, "cef_shop_selector_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_shoulder_straps_response", true)) {
        CEF_AllUiResponse(player_id, "cef_shoulder_straps_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_skin_selector_response", true)) {
        CEF_AllUiResponse(player_id, "cef_skin_selector_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_skin_viewer_response", true)) {
        CEF_AllUiResponse(player_id, "cef_skin_viewer_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_tutorial_response", true)) {
        CEF_AllUiResponse(player_id, "cef_tutorial_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_car_service_response", true)) {
        CEF_OpsServiceResponse(player_id, arguments);
        return 1;
    }
    if (!strcmp(event, "cef_cargo_aggregator_response", true)) {
        CEF_AllUiResponse(player_id, "cef_cargo_aggregator_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_admin_panel_response", true)) {
        CEF_AllUiResponse(player_id, "cef_admin_panel_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_bank_response", true)) {
        CEF_OpsBankResponse(player_id, arguments, false);
        return 1;
    }
    if (!strcmp(event, "cef_atm_response", true)) {
        CEF_OpsBankResponse(player_id, arguments, true);
        return 1;
    }
    if (!strcmp(event, "cef_video_player_response", true)) {
        CEF_AllUiResponse(player_id, "cef_video_player_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_voice_chat_settings_response", true)) {
        CEF_AllUiResponse(player_id, "cef_voice_chat_settings_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_dialogs_response", true)) {
        CEFC_OnDialogResponse(player_id, arguments);
        return 1;
    }
    if (!strcmp(event, "cef_tablet_note_response", true)) {
        CEF_AllUiResponse(player_id, "cef_tablet_note_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_event_market_response", true)) {
        CEF_AllUiResponse(player_id, "cef_event_market_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_inventory_ui_response", true)) {
        CEF_LiveInvResponse(player_id, arguments);
        return 1;
    }
    if (!strcmp(event, "cef_inv_item_action", true)) {
        return CEF_InvItemActionHandle(player_id, arguments);
    }
    if (!strcmp(event, "cef_hotkey", true)) {
        return CEF_HotkeyHandle(player_id, arguments);
    }
    if (!strcmp(event, "cef_tools_response", true)) {
        CEF_AllUiResponse(player_id, "cef_tools_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_books_response", true)) {
        CEF_AllUiResponse(player_id, "cef_books_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_fractions_contest_response", true)) {
        CEF_AllUiResponse(player_id, "cef_fractions_contest_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_shop_menu_response", true)) {
        CEF_EcoShopResponse(player_id, arguments);
        return 1;
    }
    if (!strcmp(event, "cef_animations_menu_response", true)) {
        CEF_AllUiResponse(player_id, "cef_animations_menu_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_trash_exchanger_response", true)) {
        CEF_AllUiResponse(player_id, "cef_trash_exchanger_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_trade_response", true)) {
        CEF_AllUiResponse(player_id, "cef_trade_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_weapons_sound_response", true)) {
        CEF_AllUiResponse(player_id, "cef_weapons_sound_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_support_response", true)) {
        CEF_AllUiResponse(player_id, "cef_support_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_perks_response", true)) {
        CEF_PerksResponse(player_id, arguments);
        return 1;
    }
    if (!strcmp(event, "cef_car_pneumo_control_response", true)) {
        CEF_AllUiResponse(player_id, "cef_car_pneumo_control_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_job_crafting_response", true)) {
        CEF_EcoJobResponse(player_id, arguments);
        return 1;
    }
    if (!strcmp(event, "cef_mining_farm_response", true)) {
        CEF_AllUiResponse(player_id, "cef_mining_farm_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_sys_notification_response", true)) {
        CEF_AllUiResponse(player_id, "cef_sys_notification_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_weapon_storage_response", true)) {
        CEF_OpsStorageResponse(player_id, arguments);
        return 1;
    }
    if (!strcmp(event, "cef_stalker_armory_response", true)) {
        CEF_AllUiResponse(player_id, "cef_stalker_armory_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_stalker_buyer_response", true)) {
        CEF_AllUiResponse(player_id, "cef_stalker_buyer_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_stalker_comb_hack_response", true)) {
        CEF_AllUiResponse(player_id, "cef_stalker_comb_hack_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_stalker_converter_response", true)) {
        CEF_AllUiResponse(player_id, "cef_stalker_converter_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_stalker_craft_response", true)) {
        CEF_AllUiResponse(player_id, "cef_stalker_craft_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_stalker_lost_items_response", true)) {
        CEF_AllUiResponse(player_id, "cef_stalker_lost_items_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_stalker_pda_response", true)) {
        CEF_AllUiResponse(player_id, "cef_stalker_pda_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_stalker_raid_loadout_response", true)) {
        CEF_AllUiResponse(player_id, "cef_stalker_raid_loadout_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_stalker_raid_lobbies_response", true)) {
        CEF_AllUiResponse(player_id, "cef_stalker_raid_lobbies_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_stalker_teleporter_response", true)) {
        CEF_AllUiResponse(player_id, "cef_stalker_teleporter_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_stalker_wires_hack_response", true)) {
        CEF_AllUiResponse(player_id, "cef_stalker_wires_hack_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_stlk_artfct_dtctr_response", true)) {
        CEF_AllUiResponse(player_id, "cef_stlk_artfct_dtctr_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_stlk_equipment_response", true)) {
        CEF_AllUiResponse(player_id, "cef_stlk_equipment_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_stlk_location_selector_response", true)) {
        CEF_AllUiResponse(player_id, "cef_stlk_location_selector_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_stlk_radio_receiver_response", true)) {
        CEF_AllUiResponse(player_id, "cef_stlk_radio_receiver_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_stlk_vehicle_repair_response", true)) {
        CEF_AllUiResponse(player_id, "cef_stlk_vehicle_repair_response", arguments);
        return 1;
    }
    if (!strcmp(event, "cef_leaderboard_response", true)) {
        CEF_OpsTopResponse(player_id, arguments);
        return 1;
    }

    printf("[CEF]  %d   : %s (%s)", player_id, event, arguments);
    return 1;
}

forward CEF_AllUiResponse(playerid, const event[], const arguments[]);
forward CEF_AllSysOpen(playerid, const sys[]);
forward CEF_AllAnimsOpen(playerid);
forward CEF_AllSupportOpen(playerid);
forward CEF_AllAdsOpen(playerid);
forward CEF_AllSkinRegister(playerid);
forward CEF_AllMapToggle(playerid);
forward CEF_AllChatInput(playerid);
forward CEF_AllAdminOpen(playerid);

stock CEF_TODO(player_id, const event[])
{


    static lastTick[MAX_PLAYERS];
    printf("[CEF-STUB] %d: %s (  )", player_id, event);
    if(GetTickCount() - lastTick[player_id] < 1500) return 1;
    lastTick[player_id] = GetTickCount();
    CEFC_Notify(player_id, "     .", "hint", 4000);
    return 1;
}




stock CEF_StrLen(const string[])
{
    new i = 0;
    while (string[i] != EOS) i++;
    return i;
}

stock CEF_Arg(const arguments[], index, dest[], size = 128)
{
    new start = 0, cur = 0, len = CEF_StrLen(arguments), i;
    dest[0] = EOS;
    for (i = 0; i <= len; i++) {
        if (i == len || arguments[i] == ' ') {
            if (cur == index) {
                new n = i - start;
                if (n >= size) n = size - 1;
                strmid(dest, arguments, start, start + n, size);
                return 1;
            }
            cur++;
            start = i + 1;
        }
    }
    return 0;
}

stock CEF_ArgInt(const arguments[], index)
{
    new s[24];
    if (!CEF_Arg(arguments, index, s)) return 0;
    return strval(s);
}



stock CEF_JsonEscape(const src[], dest[], size = sizeof dest)
{
    new j = 0;
    for (new i = 0; src[i] != EOS && j < size - 2; i++) {
        switch (src[i]) {
            case '"': { dest[j++] = '\\'; dest[j++] = '"'; }
            case '\\': { dest[j++] = '\\'; dest[j++] = '\\'; }
            case '\n': { dest[j++] = '\\'; dest[j++] = 'n'; }
            case '\r': { dest[j++] = '\\'; dest[j++] = 'r'; }
            case '\t': { dest[j++] = '\\'; dest[j++] = 't'; }
            default: dest[j++] = src[i];
        }
    }
    dest[j] = EOS;
    return j;
}


stock CEF_PlayerNick(player_id, dest[], size = sizeof dest)
{
    new raw[MAX_PLAYER_NAME], esc[MAX_PLAYER_NAME * 2];
    GetPlayerName(player_id, raw, sizeof raw);
    for (new i = 0; raw[i] != EOS; i++) if (raw[i] == ' ') raw[i] = '_';
    CEF_JsonEscape(raw, esc);
    format(dest, size, "%s", esc);
    return 1;
}








stock CEF_ChatInit(player_id)
{
    CEF_SendEmpty(player_id, "cef_chat_init");
    return 1;
}



stock CEF_ChatAddMessage(player_id, const text[], const color[] = "FFFFFF", bool:highlighted = false)
{
    new esc[512], json[CEF_JSON_SIZE];
    CEF_JsonEscape(text, esc);
    format(json, sizeof json,
        "{\"time\":\"%s\",\"text\":\"%s\",\"textColorString\":\"%s\",\"highlighted\":%s,\"duplicates\":1}",
        CEF_NowIso(), esc, color, highlighted ? "true" : "false");
    return CEF_Send(player_id, "cef_chat_add_message", json);
}



stock CEF_ChatAddPayday(player_id, salary, adminSalary, pension, vip, businessPay, incomeTax, govTax, penalty, bounty, const bank[])
{
    new json[CEF_JSON_SIZE], banks[64];
    CEF_JsonEscape(bank, banks);
    format(json, sizeof json, "{\"time\":\"%s\",\"text\":\"\",\"salary\":%d,\"adminSalary\":%d,\"pension\":%d,\"vip\":%d,\"businessPay\":%d,\"flatBank\":0,\"housePay\":0,\"incomeTax\":%d,\"governmentTax\":%d,\"penalty\":%d,\"bounty\":%d,\"bank\":\"%s\",\"textItems\":[]}", CEF_NowIso(), salary, adminSalary, pension, vip, businessPay, incomeTax, govTax, penalty, bounty, banks);
    return CEF_Send(player_id, "cef_chat_add_payday", json);
}

stock CEF_HandleChatMessage(player_id, const text[])
{
    static msg[160];
    if(!strlen(text)) return 1;

    if(text[0] == 123)
    {
        if(!CEF_JsonStr(text, "text", msg, sizeof msg)) return 1;
    }
    else format(msg, sizeof msg, "%s", text);
    if(!strlen(msg)) return 1;
    PT[player_id][pAntiFlood] = 0;
    CallLocalFunction("CEFC_ChatMarkClosed", "i", player_id);
    if(msg[0] == 47)
    {
        PT[player_id][pAntiFlood] = 0;
        PC_EmulateCommand(player_id, msg);
        return 1;
    }
    return CallLocalFunction("OnPlayerText", "ds", player_id, msg);
}







stock CEF_DocumentsOpen(player_id, type, const dataJson[])
{
    new json[CEF_JSON_SIZE];
    format(json, sizeof json, "{\"type\":%d,\"data\":%s}", type, dataJson);
    CEF_OpenScreen(player_id, "cef_documents_open", json);
    return 1;
}

stock CEF_DocumentsClose(player_id)
{
    CEF_SendEmpty(player_id, "cef_documents_close");
    CEF_Hide(player_id);
    return 1;
}


stock CEF_PlateOpen(player_id, page, const plateNumber[], region, balance, price)
{
    new json[CEF_JSON_SIZE];
    format(json, sizeof json,
        "{\"page\":%d,\"plateNumber\":\"%s\",\"region\":%d,\"balance\":%d,\"price\":%d}",
        page, plateNumber, region, balance, price);
    CEF_OpenScreen(player_id, "cef_license_plate_show", json);
    return 1;
}

stock CEF_HandlePlateAction(player_id, const arguments[])
{
    new action[16], pageStr[8], plate[16], regionStr[8];
    CEF_Arg(arguments, 0, action);
    CEF_Arg(arguments, 1, pageStr);
    CEF_Arg(arguments, 2, plate);
    CEF_Arg(arguments, 3, regionStr);

    #pragma unused player_id, pageStr, plate, regionStr
    return 1;
}




stock CEF_RadialOpen(player_id, const itemsJson[])
{
    new json[CEF_JSON_SIZE];
    format(json, sizeof json, "{\"isFirstStep\":true,\"interaction\":\"main\",\"items\":%s}", itemsJson);
    CEF_Show(player_id, false);
    CEF_Send(player_id, "cef_radial_menu_open", json);
    CEF_Focus(player_id, true);
    return 1;
}

stock CEF_HandleRadial(player_id, const arguments[])
{
    return CEF_LiveRadialClick(player_id, arguments);
}



stock CEF_CasesOpen(player_id, caseType)
{
    new json[64];
    format(json, sizeof json, "{\"caseType\":%d}", caseType);
    CEF_OpenScreen(player_id, "cef_cases_open", json);
    return 1;
}




stock CEF_BattlePass(player_id, const title[], const expiresAt[], points, stage)
{
    new escTitle[128], json[CEF_JSON_SIZE];
    CEF_JsonEscape(title, escTitle);
    format(json, sizeof json, "{\"title\":\"%s\",\"expiresAt\":\"%s\"}", escTitle, expiresAt);
    CEF_Send(player_id, "cef_mini_battle_pass_main_info", json);

    format(json, sizeof json, "{\"design\":0,\"points\":%d,\"stage\":%d,\"claimed\":{}}", points, stage);
    CEF_Send(player_id, "cef_mini_battle_pass_show", json);

    CEF_SendEmpty(player_id, "cef_mini_battle_pass_upd_tasks");
    CEF_Show(player_id, false);
    return 1;
}

stock CEF_HandleBattlePass(player_id, const arguments[])
{
    new action[24];
    CEF_Arg(arguments, 0, action);

    #pragma unused player_id, action
    return 1;
}


stock CEF_AccountStats(player_id, money, bank, level, exp, wanted)
{
    new json[256];
    format(json, sizeof json,
        "{\"money\":%d,\"bank\":%d,\"level\":%d,\"exp\":%d,\"wanted\":%d}", money, bank, level, exp, wanted);
    return CEF_Send(player_id, "update_account_stats", json);
}





stock CEF_CmdChat(playerid, params[])
{
    if (params[0] == EOS) { CEF_Show(playerid, true); CEF_ChatInit(playerid); return 1; }
    CEF_ChatAddMessage(playerid, params);
    return 1;
}

stock CEF_CmdDocuments(playerid, params[])
{

    #pragma unused params
    CEF_Show(playerid, false);
    return 1;
}


















forward CEVC_AppStarted(player_id, const arguments[]);
public  CEVC_AppStarted(player_id, const arguments[])
{
    #pragma unused arguments
    return CEFC_OnAppStarted(player_id);
}
forward CEVC_AppReady(player_id, const arguments[]);
public  CEVC_AppReady(player_id, const arguments[])
{
    #pragma unused arguments
    return CEFC_OnAppReady(player_id);
}
forward CEVC_RpcBank(player_id, const arguments[]);
public  CEVC_RpcBank(player_id, const arguments[]) { return CEFC_OnRpc(player_id, "bank", arguments); }
forward CEVC_RpcDocs(player_id, const arguments[]);
public  CEVC_RpcDocs(player_id, const arguments[]) { return CEFC_OnRpc(player_id, "documents", arguments); }
forward CEVC_RpcShop(player_id, const arguments[]);
public  CEVC_RpcShop(player_id, const arguments[]) { return CEFC_OnRpc(player_id, "shop", arguments); }
forward CEVC_RpcService(player_id, const arguments[]);
public  CEVC_RpcService(player_id, const arguments[]) { return CEFC_OnRpc(player_id, "car_service", arguments); }
forward CEVC_RpcAuth(player_id, const arguments[]);
public  CEVC_RpcAuth(player_id, const arguments[]) { return CEFC_OnRpc(player_id, "auth", arguments); }

forward CEVR_00(player_id, const arguments[]);
public  CEVR_00(player_id, const arguments[]) { return CEFC_OnRpc(player_id, "cases", arguments); }
forward CEVR_01(player_id, const arguments[]);
public  CEVR_01(player_id, const arguments[]) { return CEFC_OnRpc(player_id, "casino", arguments); }
forward CEVR_02(player_id, const arguments[]);
public  CEVR_02(player_id, const arguments[]) { return CEFC_OnRpc(player_id, "christmas_tree", arguments); }
forward CEVR_03(player_id, const arguments[]);
public  CEVR_03(player_id, const arguments[]) { return CEFC_OnRpc(player_id, "cleaning_extermination", arguments); }
forward CEVR_04(player_id, const arguments[]);
public  CEVR_04(player_id, const arguments[]) { return CEFC_OnRpc(player_id, "cleaning_washing", arguments); }
forward CEVR_05(player_id, const arguments[]);
public  CEVR_05(player_id, const arguments[]) { return CEFC_OnRpc(player_id, "event_market", arguments); }
forward CEVR_06(player_id, const arguments[]);
public  CEVR_06(player_id, const arguments[]) { return CEFC_OnRpc(player_id, "food_delivery", arguments); }
forward CEVR_07(player_id, const arguments[]);
public  CEVR_07(player_id, const arguments[]) { return CEFC_OnRpc(player_id, "letter_building", arguments); }
forward CEVR_08(player_id, const arguments[]);
public  CEVR_08(player_id, const arguments[]) { return CEFC_OnRpc(player_id, "lock_picking", arguments); }
forward CEVR_09(player_id, const arguments[]);
public  CEVR_09(player_id, const arguments[]) { return CEFC_OnRpc(player_id, "pin_code", arguments); }
forward CEVR_10(player_id, const arguments[]);
public  CEVR_10(player_id, const arguments[]) { return CEFC_OnRpc(player_id, "season_pass", arguments); }
forward CEVR_11(player_id, const arguments[]);
public  CEVR_11(player_id, const arguments[]) { return CEFC_OnRpc(player_id, "spells_drawing", arguments); }
forward CEVR_12(player_id, const arguments[]);
public  CEVR_12(player_id, const arguments[]) { return CEFC_OnRpc(player_id, "stalker_pda", arguments); }
forward CEVR_13(player_id, const arguments[]);
public  CEVR_13(player_id, const arguments[]) { return CEFC_OnRpc(player_id, "tau_meter", arguments); }
forward CEVR_14(player_id, const arguments[]);
public  CEVR_14(player_id, const arguments[]) { return CEFC_OnRpc(player_id, "trade_store", arguments); }
forward CEVR_15(player_id, const arguments[]);
public  CEVR_15(player_id, const arguments[]) { return CEFC_OnRpc(player_id, "trc_newspaper_article", arguments); }
forward CEVR_16(player_id, const arguments[]);
public  CEVR_16(player_id, const arguments[]) { return CEFC_OnRpc(player_id, "wires_hacking", arguments); }

forward CEVC_MenuClosed(player_id, const arguments[]);
public  CEVC_MenuClosed(player_id, const arguments[])
{
    #pragma unused arguments
    return CEFC_OnMenuClosed(player_id);
}

forward CEVC_Perks(player_id, const arguments[]);
public  CEVC_Perks(player_id, const arguments[]) { return CEF_PerksResponse(player_id, arguments); }
forward CEVC_Tasks(player_id, const arguments[]);
public  CEVC_Tasks(player_id, const arguments[]) { return CEF_TasksResponse(player_id, arguments); }
forward CEVC_Prizes(player_id, const arguments[]);
public  CEVC_Prizes(player_id, const arguments[]) { return CEF_PrizesResponse(player_id, arguments); }
