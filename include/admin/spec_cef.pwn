
#define SPEC_BROWSER 63
#define SPEC_CEF_LINK "file:///cef/amazing/specmenu/index.html"
new g_SpecTarget[MAX_PLAYERS] = {INVALID_PLAYER_ID, ...};
new g_SpecFilter[MAX_PLAYERS] = {-1, ...};
new bool:g_SpecFrozen[MAX_PLAYERS];
new bool:g_SpecPG[MAX_PLAYERS];
new Float:g_SpecOriginX[MAX_PLAYERS], Float:g_SpecOriginY[MAX_PLAYERS], Float:g_SpecOriginZ[MAX_PLAYERS];
new g_SpecOriginVW[MAX_PLAYERS], g_SpecOriginInterior[MAX_PLAYERS];

stock Spec_SendData(playerid)
{
    new targetid=g_SpecTarget[playerid];
    if(!IsPlayerConnected(targetid) || !PT[targetid][pLogged]) return 0;
    new Float:hp,Float:arm,Float:vx,Float:vy,Float:vz,speed,role[12],fraction[32],family[32];
    GetPlayerHealth(targetid,hp); GetPlayerArmour(targetid,arm);
    GetPlayerVelocity(targetid,vx,vy,vz); speed=floatround(floatsqroot(vx*vx+vy*vy+vz*vz)*180.0);
    if(PI[targetid][pAdmin]>0) format(role,sizeof role,"ADMIN"); else if(PI[targetid][pLeader]>0) format(role,sizeof role,"LEADER"); else format(role,sizeof role,"PLAYER");
    format(fraction,sizeof fraction,"Фракция %d",PI[targetid][pFraction]);
    format(family,sizeof family,"Семья %d",PI[targetid][pFamily]);
    cef_emit_event(playerid,"spec:data",CEFINT(targetid),CEFSTR(PI[targetid][pName]),CEFSTR(role),CEFINT(floatround(hp)),CEFINT(floatround(arm)),CEFINT(PI[targetid][pLevel]),CEFSTR(fraction),CEFINT(PI[targetid][pFractionRank]),CEFSTR(family),CEFINT(PI[targetid][pWanted]),CEFINT(GetPlayerVirtualWorld(targetid)),CEFINT(floatround(speed)),CEFINT(GetPlayerPing(targetid)));
    new vehicle[48];
    if(IsPlayerInAnyVehicle(targetid)) format(vehicle,sizeof vehicle,"ID %d | model %d",GetPlayerVehicleID(targetid),GetVehicleModel(GetPlayerVehicleID(targetid)));
    else format(vehicle,sizeof vehicle,"None");
    cef_emit_event(playerid,"spec:vehicle",CEFSTR(vehicle));
    cef_emit_event(playerid,"spec:freeze",CEFINT(_:g_SpecFrozen[targetid]));
    return 1;
}
forward Spec_SendDataTimer(playerid);
public Spec_SendDataTimer(playerid) return Spec_SendData(playerid);

stock Spec_Start(playerid,targetid)
{
    if(!GetAdminLevel(playerid,1)) return SendErr(playerid,messageUnknownCMD);
    if(!IsPlayerConnected(targetid)||!PT[targetid][pLogged]||targetid==playerid) return SendErr(playerid,"Игрок недоступен.");
    GetPlayerPos(playerid,g_SpecOriginX[playerid],g_SpecOriginY[playerid],g_SpecOriginZ[playerid]);
    g_SpecOriginVW[playerid]=GetPlayerVirtualWorld(playerid);
    g_SpecOriginInterior[playerid]=GetPlayerInterior(playerid);
    g_SpecTarget[playerid]=targetid;
    g_SpecFilter[playerid]=-1;
    TogglePlayerSpectating(playerid,true); PlayerSpectatePlayer(playerid,targetid);
    cef_create_browser(playerid,SPEC_BROWSER,SPEC_CEF_LINK,false,true);
    cef_focus_browser(playerid,SPEC_BROWSER,true);
    cef_always_listen_keys(playerid,SPEC_BROWSER,true);
    SetTimerEx("Spec_SendDataTimer",1000,false,"i",playerid);
    return 1;
}
CMD:spec(playerid,params[]){new id;if(sscanf(params,"i",id))return SendErr(playerid,"Используйте: /spec [id]");return Spec_Start(playerid,id);}
CMD:recon(playerid,params[]){new id;if(sscanf(params,"i",id))return SendErr(playerid,"Используйте: /recon [id]");return Spec_Start(playerid,id);}
CMD:specoff(playerid,params[]){
    #pragma unused params
    if(g_SpecTarget[playerid]!=INVALID_PLAYER_ID){cef_focus_browser(playerid,SPEC_BROWSER,false);cef_hide_browser(playerid,SPEC_BROWSER,true);cef_always_listen_keys(playerid,SPEC_BROWSER,false);cef_emit_event(playerid,"game:showCursor",CEFINT(0));cef_destroy_browser(playerid,SPEC_BROWSER);TogglePlayerSpectating(playerid,false);g_SpecTarget[playerid]=INVALID_PLAYER_ID;g_SpecFilter[playerid]=-1;}
    return 1;
}
CMD:unspec(playerid,params[]){
    #pragma unused params
    if(g_SpecTarget[playerid]!=INVALID_PLAYER_ID){cef_focus_browser(playerid,SPEC_BROWSER,false);cef_hide_browser(playerid,SPEC_BROWSER,true);cef_always_listen_keys(playerid,SPEC_BROWSER,false);cef_emit_event(playerid,"game:showCursor",CEFINT(0));cef_destroy_browser(playerid,SPEC_BROWSER);TogglePlayerSpectating(playerid,false);g_SpecTarget[playerid]=INVALID_PLAYER_ID;g_SpecFilter[playerid]=-1;}
    return 1;
}

callback::OnSpecReady(playerid,const arguments[])
{
    #pragma unused arguments
    Spec_SendData(playerid);
    return 1;
}
callback::OnSpecNavigate(playerid,const arguments[])
{
    new dir=strval(arguments),start=g_SpecTarget[playerid],id=start;
    for(new n=0;n<MAX_PLAYERS;n++){id+=dir;if(id<0)id=MAX_PLAYERS-1;if(id>=MAX_PLAYERS)id=0;if(id!=playerid&&IsPlayerConnected(id)&&PT[id][pLogged]&&(g_SpecFilter[playerid]<0||PI[id][pFraction]==g_SpecFilter[playerid])){g_SpecTarget[playerid]=id;PlayerSpectatePlayer(playerid,id);Spec_SendData(playerid);break;}}
    return 1;
}

callback::OnSpecFilter(playerid,const arguments[])
{
    new filterid=strval(arguments),count=0,id;
    if(filterid < -1 || filterid >= MAX_FRACTIONS) return 1;
    g_SpecFilter[playerid]=filterid;
    for(id=0;id<MAX_PLAYERS;id++) if(id!=playerid&&IsPlayerConnected(id)&&PT[id][pLogged]&&(filterid<0||PI[id][pFraction]==filterid)) count++;
    cef_emit_event(playerid,"spec:filter_count",CEFINT(count));
    if(count<=0){g_SpecTarget[playerid]=INVALID_PLAYER_ID;cef_emit_event(playerid,"spec:empty",CEFSTR("No online players in this fraction."));return 1;}
    if(g_SpecTarget[playerid]==INVALID_PLAYER_ID || (g_SpecFilter[playerid]>=0&&PI[g_SpecTarget[playerid]][pFraction]!=g_SpecFilter[playerid]))
    {
        for(id=0;id<MAX_PLAYERS;id++) if(id!=playerid&&IsPlayerConnected(id)&&PT[id][pLogged]&&(g_SpecFilter[playerid]<0||PI[id][pFraction]==g_SpecFilter[playerid])){g_SpecTarget[playerid]=id;PlayerSpectatePlayer(playerid,id);break;}
    }
    Spec_SendData(playerid);
    return 1;
}
callback::OnSpecAction(playerid,const arguments[])
{
    new act[24],targetid;
    if(sscanf(arguments,"s[24]i",act,targetid))return 1;
    if(!GetAdminLevel(playerid,1))return 1;
    new Float:x,Float:y,Float:z;
    new vehicleid,text[320];
    if(!strcmp(act,"EXIT",true))
    {
        cef_focus_browser(playerid,SPEC_BROWSER,false);cef_hide_browser(playerid,SPEC_BROWSER,true);cef_always_listen_keys(playerid,SPEC_BROWSER,false);cef_emit_event(playerid,"game:showCursor",CEFINT(0));cef_destroy_browser(playerid,SPEC_BROWSER);TogglePlayerSpectating(playerid,false);g_SpecTarget[playerid]=INVALID_PLAYER_ID;g_SpecFilter[playerid]=-1;return 1;
    }
    if(targetid!=g_SpecTarget[playerid]||!IsPlayerConnected(targetid)||!PT[targetid][pLogged])return 1;
    if(!strcmp(act,"MOVE",true)){GetPlayerPos(targetid,x,y,z);SetPlayerPos(targetid,x+3.0,y,z);}
    else if(!strcmp(act,"FLIP",true)){vehicleid=GetPlayerVehicleID(targetid);if(vehicleid>0){GetVehiclePos(vehicleid,x,y,z);SetVehiclePos(vehicleid,x,y,z+0.5);SetVehicleZAngle(vehicleid,0.0);}}
    else if(!strcmp(act,"GRUZ",true))
    {
        vehicleid=0;
        for(new v=1;v<MAX_VEHICLES;v++)
        {
            if(IsValidVehicle(v)) { vehicleid=v; break; }
        }
        if(vehicleid>0) PutPlayerInVehicle(targetid,vehicleid,1);
    }
    else if(!strcmp(act,"FIXVEH",true)){vehicleid=GetPlayerVehicleID(targetid);if(vehicleid>0)RepairVehicle(vehicleid);}
    else if(!strcmp(act,"GET",true)){SetPlayerVirtualWorld(targetid,g_SpecOriginVW[playerid]);SetPlayerInterior(targetid,g_SpecOriginInterior[playerid]);SetPlayerPos(targetid,g_SpecOriginX[playerid]+1.0,g_SpecOriginY[playerid],g_SpecOriginZ[playerid]);}
    else if(!strcmp(act,"UP",true)){GetPlayerPos(targetid,x,y,z);SetPlayerPos(targetid,x,y,z+2.0);}
    else if(!strcmp(act,"DOWN",true)){GetPlayerPos(targetid,x,y,z);SetPlayerPos(targetid,x,y,z-2.0);}
    else if(!strcmp(act,"GOTO",true)){GetPlayerPos(targetid,x,y,z);new world=GetPlayerVirtualWorld(targetid),interior=GetPlayerInterior(targetid);cef_focus_browser(playerid,SPEC_BROWSER,false);cef_hide_browser(playerid,SPEC_BROWSER,true);cef_always_listen_keys(playerid,SPEC_BROWSER,false);cef_emit_event(playerid,"game:showCursor",CEFINT(0));cef_destroy_browser(playerid,SPEC_BROWSER);TogglePlayerSpectating(playerid,false);SetPlayerVirtualWorld(playerid,world);SetPlayerInterior(playerid,interior);SetPlayerPos(playerid,x+1.0,y,z);g_SpecTarget[playerid]=INVALID_PLAYER_ID;return 1;}
    else if(!strcmp(act,"SPAWN",true)){SpawnPlayerEx(targetid);UpdatePlayerTag(targetid);SyncTagPanelAccess(targetid);g_SpecFrozen[targetid]=false;}
    else if(!strcmp(act,"FREEZE",true)){TogglePlayerControllable(targetid,false);g_SpecFrozen[targetid]=true;}
    else if(!strcmp(act,"UNFREEZE",true)){TogglePlayerControllable(targetid,true);g_SpecFrozen[targetid]=false;}
    else if(!strcmp(act,"DELGUN",true))ResetPlayerWeapons(targetid);
    else if(!strcmp(act,"PG",true)){g_SpecPG[targetid]=!g_SpecPG[targetid];if(g_SpecPG[targetid])cef_emit_event(playerid,"spec:toast",CEFSTR("[SPEC] PG mark enabled."));else cef_emit_event(playerid,"spec:toast",CEFSTR("[SPEC] PG mark removed."));}
    else if(!strcmp(act,"NICK",true)){format(text,sizeof text,"Name: %s\nID: %d",PI[targetid][pName],targetid);cef_emit_event(playerid,"spec:info",CEFSTR("SPEC / NICK"),CEFSTR(text));}
    else if(!strcmp(act,"STATS",true)){format(text,sizeof text,"Name: %s\nLevel: %d\nMoney: $%d\nBank: $%d\nPing: %d ms",PI[targetid][pName],PI[targetid][pLevel],PI[targetid][pCash],PI[targetid][pBank],GetPlayerPing(targetid));cef_emit_event(playerid,"spec:info",CEFSTR("SPEC / STATS"),CEFSTR(text));}
    else if(!strcmp(act,"GETINFO",true)){format(text,sizeof text,"Account ID: %d\nAdmin: %d\nLeader: %d\nFraction: %d\nRank: %d\nSkin: %d",PI[targetid][pID],PI[targetid][pAdmin],PI[targetid][pLeader],PI[targetid][pFraction],PI[targetid][pFractionRank],GetPlayerSkin(targetid));cef_emit_event(playerid,"spec:info",CEFSTR("SPEC / GETINFO"),CEFSTR(text));}
    else if(!strcmp(act,"INFOPUNISH",true)){format(text,sizeof text,"Warnings: %d\nSuspended: %d\nWanted: %d\nMute: %d sec\nFrozen: %d\nPG mark: %d",PI[targetid][pWarns],PI[targetid][pSuspended],PI[targetid][pWanted],PT[targetid][pMuteTime],_:g_SpecFrozen[targetid],_:g_SpecPG[targetid]);cef_emit_event(playerid,"spec:info",CEFSTR("SPEC / INFOPUNISH"),CEFSTR(text));}
    else if(!strcmp(act,"TIME",true)){new hour,minute,second;gettime(hour,minute,second);format(text,sizeof text,"Server time: %02d:%02d:%02d\nAFK: %d sec\nPing: %d ms",hour,minute,second,PI[targetid][pAFK],GetPlayerPing(targetid));cef_emit_event(playerid,"spec:info",CEFSTR("SPEC / TIME"),CEFSTR(text));}
    Spec_SendData(playerid);return 1;
}
