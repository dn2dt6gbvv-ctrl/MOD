

#define UNMAZING_ASI_SYNC_COLOR (0x01010100)
#define UNMAZING_ASI_PERM_PUBLIC (100478)
#define UNMAZING_ASI_PERM_ALL    (131071)

new bool:gUnmazingInvisible[MAX_PLAYERS];
new gUnmazingPogon[MAX_PLAYERS];
new gUnmazingPatch[MAX_PLAYERS];
new bool:gUnmazingHandlingActive[MAX_VEHICLES];
new Float:gUnmazingStageAccel[MAX_VEHICLES];
new Float:gUnmazingStageVelocity[MAX_VEHICLES];
new Float:gUnmazingStageTraction[MAX_VEHICLES];
new Float:gUnmazingStageBrake[MAX_VEHICLES];
new Float:gUnmazingPneuma[MAX_VEHICLES];
new Float:gUnmazingSteering[MAX_VEHICLES];
new gUnmazingBrakeLevel[MAX_VEHICLES];

stock UnmazingASI_SendHidden(playerid, const message[])
{
    if(!IsPlayerConnected(playerid)) return 0;
    return SendClientMessage(playerid, UNMAZING_ASI_SYNC_COLOR, message);
}

stock UnmazingASI_SendPermissions(playerid, bool:fullAccess = false)
{
    new packet[48];
    format(packet, sizeof(packet), "@@AMZPERM:%d", fullAccess ? UNMAZING_ASI_PERM_ALL : UNMAZING_ASI_PERM_PUBLIC);
    return UnmazingASI_SendHidden(playerid, packet);
}

stock bool:UnmazingASI_IsLocalCommand(const text[])
{
    new command[35], length;
    while(text[length] != EOS && text[length] != ' ' && text[length] != '\t' && length < sizeof(command)-1)
    {
        command[length] = text[length];
        length++;
    }
    command[length] = EOS;
    return
        !strcmp(command,"/air_speed",true) ||
        !strcmp(command,"/atagon",true) || !strcmp(command,"/atagoff",true) ||
        !strcmp(command,"/gps3d",true) || !strcmp(command,"/gps3doff",true) || !strcmp(command,"/text3dtest",true) ||
        !strcmp(command,"/plates",true) || !strcmp(command,"/platename",true) ||
        !strcmp(command,"/aplate",true) || !strcmp(command,"/adminplate",true) || !strcmp(command,"/plateoff",true) ||
        !strcmp(command,"/neonon",true) || !strcmp(command,"/neonoff",true) ||
        !strcmp(command,"/headlightson",true) || !strcmp(command,"/headlightsoff",true) ||
        !strcmp(command,"/faron",true) || !strcmp(command,"/faroff",true) ||
        !strcmp(command,"/strobon",true) || !strcmp(command,"/strobeoff",true) || !strcmp(command,"/stroboff",true) ||
        !strcmp(command,"/gradon",true) || !strcmp(command,"/gradienton",true) ||
        !strcmp(command,"/gradoff",true) || !strcmp(command,"/gradientoff",true) ||
        !strcmp(command,"/rainbowon",true) || !strcmp(command,"/rainbowoff",true) || !strcmp(command,"/raduga",true) ||
        !strcmp(command,"/smokeon",true) || !strcmp(command,"/smokeoff",true) ||
        !strcmp(command,"/tinton",true) || !strcmp(command,"/tintoff",true) || !strcmp(command,"/carfxoff",true) ||
        !strcmp(command,"/masktest",true) || !strcmp(command,"/masktestoff",true) ||
        !strcmp(command,"/pogontest",true) || !strcmp(command,"/pogontestoff",true) ||
        !strcmp(command,"/stage",true) || !strcmp(command,"/brakes",true) ||
        !strcmp(command,"/pneuma",true) || !strcmp(command,"/pneuma_height",true) ||
        !strcmp(command,"/wheelturn",true) || !strcmp(command,"/handlingoff",true);
}

stock bool:UnmazingASI_IsEmotionTrigger(const text[])
{
    return
        !strcmp(text,"Упс",true) || !strcmp(text,"Пиздец",true) ||
        !strcmp(text,")",false) || !strcmp(text,"))",false) ||
        !strcmp(text,"(",false) || !strcmp(text,"((",false) ||
        !strcmp(text,"ого",true) || !strcmp(text,"хм",true) ||
        !strcmp(text,"<3",false) || !strcmp(text,"+",false) ||
        !strcmp(text,"+++",false) || !strcmp(text,"=",false) ||
        !strcmp(text,"===",false) || !strcmp(text,"-",false) ||
        !strcmp(text,":*",false);
}

stock UnmazingASI_RouteCefInput(playerid, const text[])
{
    if(!strlen(text)) return 0;
    if(!UnmazingASI_IsLocalCommand(text) && !UnmazingASI_IsEmotionTrigger(text)) return 0;
    new packet[144];
    format(packet, sizeof(packet), "@@AMZINPUT:%s", text);
    UnmazingASI_SendHidden(playerid, packet);
    return 1;
}

stock UnmazingASI_SendInvisToViewer(viewerid, playerid, bool:hidden)
{
    new packet[48];
    format(packet, sizeof(packet), hidden ? ("@@AMZINVIS:HIDE:%d") : ("@@AMZINVIS:SHOW:%d"), playerid);
    return UnmazingASI_SendHidden(viewerid, packet);
}

stock UnmazingASI_SetInvisible(playerid, bool:enabled)
{
    gUnmazingInvisible[playerid] = enabled;
    new packet[48];
    format(packet, sizeof(packet), "@@AMZINVIS:SELF:%d", enabled ? 1 : 0);
    UnmazingASI_SendHidden(playerid, packet);
    foreach(new viewerid : Player)
    {
        if(viewerid == playerid) continue;
        UnmazingASI_SendInvisToViewer(viewerid, playerid, enabled);
    }
    return 1;
}

stock UnmazingASI_SendMaskToViewer(viewerid, playerid, bool:enabled)
{
    new packet[64];
    if(enabled) format(packet, sizeof(packet), "@@AMZMASK:S:%d:%d", playerid, PI[playerid][pID]);
    else format(packet, sizeof(packet), "@@AMZMASK:H:%d", playerid);
    return UnmazingASI_SendHidden(viewerid, packet);
}

stock UnmazingASI_SetMask(playerid, bool:enabled)
{
    PI[playerid][pMasked] = enabled ? 1 : 0;
    new legacy[64];
    if(enabled) format(legacy, sizeof(legacy), "{SMASK}SYNC:%d:%d", playerid, PI[playerid][pID]);
    else format(legacy, sizeof(legacy), "{SMASK}CLR:%d", playerid);
    SendClientMessageToAll(-1, legacy);
    foreach(new viewerid : Player) UnmazingASI_SendMaskToViewer(viewerid, playerid, enabled);
    UpdatePlayerTag(playerid);
    return 1;
}

stock UnmazingASI_SendUniformToViewer(viewerid, playerid)
{
    new packet[64];
    if(gUnmazingPogon[playerid] >= 0)
    {
        format(packet, sizeof(packet), "@@AMZPOGON:S:%d:%d", playerid, gUnmazingPogon[playerid]);
        UnmazingASI_SendHidden(viewerid, packet);
    }
    if(gUnmazingPatch[playerid] >= 0)
    {
        format(packet, sizeof(packet), "@@AMZPATCH:S:%d:%d", playerid, gUnmazingPatch[playerid]);
        UnmazingASI_SendHidden(viewerid, packet);
    }
    return 1;
}

stock UnmazingASI_SendHandlingToViewer(viewerid, vehicleid)
{
    if(!gUnmazingHandlingActive[vehicleid]) return 0;
    new packet[144];
    format(packet, sizeof(packet), "@@AMZSTAGE:S:%d:%f:%f:%f:%f", vehicleid,
        gUnmazingStageAccel[vehicleid], gUnmazingStageVelocity[vehicleid],
        gUnmazingStageTraction[vehicleid], gUnmazingStageBrake[vehicleid]);
    UnmazingASI_SendHidden(viewerid, packet);
    format(packet, sizeof(packet), "@@AMZPNEUMA:S:%d:%f", vehicleid, gUnmazingPneuma[vehicleid]);
    UnmazingASI_SendHidden(viewerid, packet);
    format(packet, sizeof(packet), "@@AMZSTEER:S:%d:%f", vehicleid, gUnmazingSteering[vehicleid]);
    UnmazingASI_SendHidden(viewerid, packet);
    format(packet, sizeof(packet), "@@AMZBRAKE:S:%d:%d", vehicleid, gUnmazingBrakeLevel[vehicleid]);
    UnmazingASI_SendHidden(viewerid, packet);
    return 1;
}

stock UnmazingASI_SyncHandling(vehicleid)
{
    foreach(new viewerid : Player)
        if(IsVehicleStreamedIn(vehicleid, viewerid)) UnmazingASI_SendHandlingToViewer(viewerid, vehicleid);
    return 1;
}

stock UnmazingASI_OnPlayerConnect(playerid)
{
    new tagPacket[48];
    format(tagPacket, sizeof(tagPacket), "@@AMZADMINTAG:H:%d", playerid);
    foreach(new tagViewer : Player) UnmazingASI_SendHidden(tagViewer, tagPacket);
    format(tagPacket, sizeof(tagPacket), "@@AMZBLACK:H:%d", playerid);
    foreach(new tagViewer2 : Player) UnmazingASI_SendHidden(tagViewer2, tagPacket);
    gUnmazingInvisible[playerid] = false;
    gUnmazingPogon[playerid] = -1;
    gUnmazingPatch[playerid] = -1;
    UnmazingASI_SendHidden(playerid, "@@AMZPERM:0");
    return 1;
}

stock UnmazingASI_OnPlayerDisconnect(playerid)
{
    if(gUnmazingInvisible[playerid])
        foreach(new viewerid : Player) if(viewerid != playerid) UnmazingASI_SendInvisToViewer(viewerid, playerid, false);
    new packet[48];
    format(packet, sizeof(packet), "@@AMZPOGON:H:%d", playerid);
    foreach(new viewerid : Player) UnmazingASI_SendHidden(viewerid, packet);
    format(packet, sizeof(packet), "@@AMZPATCH:H:%d", playerid);
    foreach(new viewerid : Player) UnmazingASI_SendHidden(viewerid, packet);
    format(packet, sizeof(packet), "@@AMZADMINTAG:H:%d", playerid);
    foreach(new tagViewer : Player) UnmazingASI_SendHidden(tagViewer, packet);
    format(packet, sizeof(packet), "@@AMZBLACK:H:%d", playerid);
    foreach(new tagViewer2 : Player) UnmazingASI_SendHidden(tagViewer2, packet);
    gUnmazingInvisible[playerid] = false;
    gUnmazingPogon[playerid] = -1;
    gUnmazingPatch[playerid] = -1;
    return 1;
}

stock UnmazingASI_OnPlayerStreamIn(playerid, forplayerid)
{
    if(gUnmazingInvisible[playerid]) UnmazingASI_SendInvisToViewer(forplayerid, playerid, true);
    if(PI[playerid][pMasked]) UnmazingASI_SendMaskToViewer(forplayerid, playerid, true);
    UnmazingASI_SendUniformToViewer(forplayerid, playerid);
    UnmazingASI_SendTagsToViewer(forplayerid, playerid);
    return 1;
}

stock UnmazingASI_OnPlayerStreamOut(playerid, forplayerid)
{
    UnmazingASI_SendInvisToViewer(forplayerid, playerid, false);
    UnmazingASI_SendMaskToViewer(forplayerid, playerid, false);
    return 1;
}

stock UnmazingASI_OnVehicleStreamIn(vehicleid, forplayerid)
{
    return UnmazingASI_SendHandlingToViewer(forplayerid, vehicleid);
}

CMD:unmazingready(playerid)
{
    if(!PT[playerid][pLogged]) return 1;
    UnmazingASI_SendPermissions(playerid, PT[playerid][pAlogged] && PI[playerid][pAdmin] > 0);
    SyncMasksForPlayer(playerid);
    SyncAllTagsForPlayer(playerid);
    CEFChat_Send(playerid, "FFFFFF", "[UNMAZING ASI] Клиент подключен, команды активированы.", "Система");
    printf("[UNMAZING ASI] ready handshake playerid=%d", playerid);
    return 1;
}

CMD:invis(playerid, params[]) return callcmd::inviz(playerid, params);

CMD:mask(playerid)
{
    if(!PI[playerid][pHasMask]) return SendClientMessage(playerid, COLOR_RED, "У Вас нет маски.");
    UnmazingASI_SetMask(playerid, PI[playerid][pMasked] ? false : true);
    return SendClientMessage(playerid, -1, PI[playerid][pMasked] ? ("Маска надета.") : ("Маска снята."));
}

CMD:setpogon(playerid, params[])
{
    if(!PT[playerid][pAlogged] || PI[playerid][pAdmin] < 1) return SendClientMessage(playerid, COLOR_RED, "Команда доступна администратору.");
    new targetid, textureid;
    if(sscanf(params, "ii", targetid, textureid) || !IsPlayerConnected(targetid) || textureid < -1 || textureid > 154)
        return SendClientMessage(playerid, COLOR_RED, "Используйте: /setpogon <id> <-1..154>.");
    gUnmazingPogon[targetid] = textureid;
    new packet[64];
    format(packet, sizeof(packet), textureid < 0 ? ("@@AMZPOGON:H:%d") : ("@@AMZPOGON:S:%d:%d"), targetid, textureid);
    foreach(new viewerid : Player) UnmazingASI_SendHidden(viewerid, packet);
    return 1;
}

CMD:givepatch(playerid, params[])
{
    if(!PT[playerid][pAlogged] || PI[playerid][pAdmin] < 1) return SendClientMessage(playerid, COLOR_RED, "Команда доступна администратору.");
    new targetid, textureid;
    if(sscanf(params, "ii", targetid, textureid) || !IsPlayerConnected(targetid) || (textureid != -1 && (textureid < 25 || textureid > 30)))
        return SendClientMessage(playerid, COLOR_RED, "Используйте: /givepatch <id> <-1 или 25..30>.");
    gUnmazingPatch[targetid] = textureid;
    new packet[64];
    format(packet, sizeof(packet), textureid < 0 ? ("@@AMZPATCH:H:%d") : ("@@AMZPATCH:S:%d:%d"), targetid, textureid);
    foreach(new viewerid : Player) UnmazingASI_SendHidden(viewerid, packet);
    return 1;
}

CMD:set_vehicle_stage(playerid, params[])
{
    if(!PT[playerid][pAlogged] || PI[playerid][pAdmin] < 1) return SendClientMessage(playerid, COLOR_RED, "Команда доступна администратору.");
    new vehicleid;
    new Float:accel, Float:velocity, Float:traction, Float:brake;
    if(sscanf(params, "iffff", vehicleid, accel, velocity, traction, brake) || !IsValidVehicle(vehicleid))
        return SendClientMessage(playerid, COLOR_RED, "Используйте: /set_vehicle_stage <veh> <accel> <velocity> <traction> <brake>.");
    gUnmazingHandlingActive[vehicleid] = true;
    gUnmazingStageAccel[vehicleid] = accel;
    gUnmazingStageVelocity[vehicleid] = velocity;
    gUnmazingStageTraction[vehicleid] = traction;
    gUnmazingStageBrake[vehicleid] = brake;
    UnmazingASI_SyncHandling(vehicleid);
    return 1;
}

CMD:setpneuma(playerid, params[])
{
    if(!PT[playerid][pAlogged] || PI[playerid][pAdmin] < 1) return SendClientMessage(playerid, COLOR_RED, "Команда доступна администратору.");
    new vehicleid; new Float:value;
    if(sscanf(params, "if", vehicleid, value) || !IsValidVehicle(vehicleid) || value < -0.25 || value > 0.25)
        return SendClientMessage(playerid, COLOR_RED, "Используйте: /setpneuma <veh> <-0.25..0.25>.");
    gUnmazingHandlingActive[vehicleid] = true; gUnmazingPneuma[vehicleid] = value;
    UnmazingASI_SyncHandling(vehicleid); return 1;
}

CMD:setwheelturn(playerid, params[])
{
    if(!PT[playerid][pAlogged] || PI[playerid][pAdmin] < 1) return SendClientMessage(playerid, COLOR_RED, "Команда доступна администратору.");
    new vehicleid; new Float:value;
    if(sscanf(params, "if", vehicleid, value) || !IsValidVehicle(vehicleid) || value < 10.0 || value > 75.0)
        return SendClientMessage(playerid, COLOR_RED, "Используйте: /setwheelturn <veh> <10..75>.");
    gUnmazingHandlingActive[vehicleid] = true; gUnmazingSteering[vehicleid] = value;
    UnmazingASI_SyncHandling(vehicleid); return 1;
}

CMD:setbrakes(playerid, params[])
{
    if(!PT[playerid][pAlogged] || PI[playerid][pAdmin] < 1) return SendClientMessage(playerid, COLOR_RED, "Команда доступна администратору.");
    new vehicleid, level;
    if(sscanf(params, "ii", vehicleid, level) || !IsValidVehicle(vehicleid) || level < 0 || level > 3)
        return SendClientMessage(playerid, COLOR_RED, "Используйте: /setbrakes <veh> <0..3>.");
    gUnmazingHandlingActive[vehicleid] = true; gUnmazingBrakeLevel[vehicleid] = level;
    UnmazingASI_SyncHandling(vehicleid); return 1;
}

CMD:resethandling(playerid, params[])
{
    if(!PT[playerid][pAlogged] || PI[playerid][pAdmin] < 1) return SendClientMessage(playerid, COLOR_RED, "Команда доступна администратору.");
    new vehicleid;
    if(sscanf(params, "i", vehicleid) || !IsValidVehicle(vehicleid))
        return SendClientMessage(playerid, COLOR_RED, "Используйте: /resethandling <veh>.");
    gUnmazingHandlingActive[vehicleid] = false;
    new packet[48]; format(packet, sizeof(packet), "@@AMZHANDLING:H:%d", vehicleid);
    foreach(new viewerid : Player) if(IsVehicleStreamedIn(vehicleid, viewerid)) UnmazingASI_SendHidden(viewerid, packet);
    return 1;
}


#define UNMAZING_PAUSE_BROWSER_ID (1505)
#define UNMAZING_PAUSE_BROWSER_URL "file:///cef/unmazing/pause/index.html"

stock UnmazingASI_SendTagsToViewer(viewerid, playerid)
{
    if(!IsPlayerConnected(viewerid) || !IsPlayerConnected(playerid)) return 0;
    new packet[64], textureid;
    if(PI[playerid][pAdmin] > 0)
    {
        textureid = PI[playerid][pAdmin] >= 10 ? 12 : PI[playerid][pAdmin];
        if(textureid < 0) textureid = 0;
        if(textureid > 12) textureid = 12;
        format(packet, sizeof(packet), "@@AMZADMINTAG:S:%d:%d", playerid, textureid);
    }
    else format(packet, sizeof(packet), "@@AMZADMINTAG:H:%d", playerid);
    UnmazingASI_SendHidden(viewerid, packet);

    format(packet, sizeof(packet), PI[playerid][pVip] > 0 ? ("@@AMZBLACK:S:%d") : ("@@AMZBLACK:H:%d"), playerid);
    UnmazingASI_SendHidden(viewerid, packet);
    return 1;
}

stock UnmazingASI_SyncTagsForPlayer(playerid)
{
    foreach(new viewerid : Player) UnmazingASI_SendTagsToViewer(viewerid, playerid);
    return 1;
}

forward OnUnmazingPauseReady(playerid, const arguments[]);
public OnUnmazingPauseReady(playerid, const arguments[])
{
    cef_focus_browser(playerid, UNMAZING_PAUSE_BROWSER_ID, false);
    return 1;
}
forward OnUnmazingPauseSettingsRequest(playerid, const arguments[]);
public OnUnmazingPauseSettingsRequest(playerid, const arguments[]) return 1;
forward OnUnmazingPauseOpen(playerid, const arguments[]);
public OnUnmazingPauseOpen(playerid, const arguments[])
{
    SetPVarInt(playerid, "UnmazingPauseOpen", 1);
    cef_focus_browser(playerid, MAIN_BROWSER, false);
    cef_focus_browser(playerid, CHAT_BROWSER, false);
    cef_focus_browser(playerid, UNMAZING_PAUSE_BROWSER_ID, true);
    return 1;
}
forward OnUnmazingPauseClose(playerid, const arguments[]);
public OnUnmazingPauseClose(playerid, const arguments[])
{
    DeletePVar(playerid, "UnmazingPauseOpen");
    cef_focus_browser(playerid, UNMAZING_PAUSE_BROWSER_ID, false);
    cef_always_listen_keys(playerid, UNMAZING_PAUSE_BROWSER_ID, true);
    return 1;
}
forward OnUnmazingPauseReconnect(playerid, const arguments[]);
public OnUnmazingPauseReconnect(playerid, const arguments[])
{
    UnmazingASI_SendHidden(playerid, "@@AMZRECONNECT");
    return 1;
}
forward OnUnmazingPauseExit(playerid, const arguments[]);
public OnUnmazingPauseExit(playerid, const arguments[])
{
    Kick(playerid);
    return 1;
}
forward OnUnmazingPauseSetting(playerid, const arguments[]);
public OnUnmazingPauseSetting(playerid, const arguments[])
{
    new key[64], value[64], packet[144];
    if(sscanf(arguments, "p<|>s[64]s[64]", key, value)) return 1;
    if(strlen(key) < 3 || strlen(key) > 63 || strlen(value) > 63) return 1;
    format(packet, sizeof(packet), "@@AMZSETTING:%s:%s", key, value);
    UnmazingASI_SendHidden(playerid, packet);
    return 1;
}
