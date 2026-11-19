



#if defined _widget_inc
    #endinput
#endif
#define _widget_inc


stock ShowJobWidget(playerid, title[], text[], progress[] = "", bool:show = true) {
    if(!cef_player_has_plugin(playerid) || !PT[playerid][pCefLoaded]) return 0;
    
    printf("[Widget] ShowJobWidget called for %d: title='%s', text='%s', progress='%s', show=%d", 
        playerid, title, text, progress, show);
    
    SetPVarString(playerid, "WidgetTitle", title);
    SetPVarString(playerid, "WidgetText", text);
    SetPVarString(playerid, "WidgetProgress", progress);
    SetPVarInt(playerid, "WidgetShow", show ? 1 : 0);
    
    if(GetPVarInt(playerid, "WidgetBrowserCreated")) {
        printf("[Widget] Browser exists, sending update immediately");
        cef_emit_event(playerid, "job:widget:update", CEFSTR(title), CEFSTR(text), CEFSTR(progress), CEFINT(show ? 1 : 0));
        return 1;
    }
    
    printf("[Widget] Creating browser for %d", playerid);
    cef_create_browser(playerid, JOB_WIDGET_BROWSER, JOB_WIDGET_CEF_LINK, false, true);
    cef_focus_browser(playerid, JOB_WIDGET_BROWSER, false);
    cef_always_listen_keys(playerid, JOB_WIDGET_BROWSER, false);
    cef_emit_event(playerid, "game:showCursor", CEFINT(0));
    SetPVarInt(playerid, "WidgetBrowserCreated", 1);
    
    SetTimerEx("OnJobWidgetReady", 800, false, "i", playerid);
    return 1;
}

stock HideJobWidget(playerid) {
    if(!cef_player_has_plugin(playerid) || !PT[playerid][pCefLoaded]) return 0;
    if(!GetPVarInt(playerid, "WidgetBrowserCreated")) return 0;
    printf("[Widget] HideJobWidget for %d", playerid);
    cef_emit_event(playerid, "job:widget:hide", CEFINT(0));
    cef_emit_event(playerid, "game:showCursor", CEFINT(0));
    return 1;
}

stock DestroyJobWidget(playerid) {
    if(GetPVarInt(playerid, "WidgetBrowserCreated")) {
        printf("[Widget] DestroyJobWidget for %d", playerid);
        cef_destroy_browser(playerid, JOB_WIDGET_BROWSER);
        cef_emit_event(playerid, "game:showCursor", CEFINT(0));
        DeletePVar(playerid, "WidgetBrowserCreated");
        DeletePVar(playerid, "WidgetTitle");
        DeletePVar(playerid, "WidgetText");
        DeletePVar(playerid, "WidgetProgress");
        DeletePVar(playerid, "WidgetShow");
    }
    return 1;
}

forward OnJobWidgetReady(playerid);
public OnJobWidgetReady(playerid) {
    if(!IsPlayerConnected(playerid)) return 1;
    if(!GetPVarInt(playerid, "WidgetBrowserCreated")) return 1;
    printf("[Widget] OnJobWidgetReady for %d", playerid);
    
    new title[64], text[128], progress[32];
    GetPVarString(playerid, "WidgetTitle", title, sizeof(title));
    GetPVarString(playerid, "WidgetText", text, sizeof(text));
    GetPVarString(playerid, "WidgetProgress", progress, sizeof(progress));
    new show = GetPVarInt(playerid, "WidgetShow");
    
    cef_emit_event(playerid, "job:widget:update", CEFSTR(title), CEFSTR(text), CEFSTR(progress), CEFINT(show));
    cef_emit_event(playerid, "game:showCursor", CEFINT(0));
    return 1;
}

CMD:hidewidget(playerid, params[]) {
    HideJobWidget(playerid);
    SendClientMessage(playerid, 0xAAAAAAFF, "Подсказака прогресса скрыта.");
    return 1;
}
