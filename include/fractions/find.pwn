#if defined _FIND_OTDEL_INCLUDED
    #endinput
#endif
#define _FIND_OTDEL_INCLUDED

#define DIALOG_OTDEL_MAIN       4500
#define DIALOG_OTDEL_LIST       4501
#define DIALOG_OTDEL_ADD        4502
#define DIALOG_OTDEL_KICK       4503
#define DIALOG_OTDEL_LSELECT    4504
#define DIALOG_OTDEL_LMAIN      4505
#define DIALOG_OTDEL_CADMIN_FID 4511
#define DIALOG_OTDEL_CADMIN_MAX 4512
#define DIALOG_OTDEL_CADMIN_NAM 4513
#define DIALOG_OTDEL_DADMIN_FID 4514
#define DIALOG_OTDEL_DADMIN_IDX 4515

enum E_OTDEL {
    otdel_ID, otdel_FractionID, otdel_Name[32],
    otdel_MaxMembers, otdel_ChiefDBID,
    otdel_Dep1DBID, otdel_Dep2DBID, otdel_Dep3DBID,
    otdel_MemberCount
}
new g_Otdel[11][10][E_OTDEL];
new g_OtdelCount[11];
new g_PlayerOtdelID[MAX_PLAYERS]  = {-1, ...};
new g_OtdelTarget[MAX_PLAYERS]    = {-1, ...};
new g_AdminFrac[MAX_PLAYERS];
new g_AdminMax[MAX_PLAYERS];
new PI_Otdel[MAX_PLAYERS];
new g_OtdelSendIdx[MAX_PLAYERS];

stock GetOtdelIdxByID(fractionid, otdelDbId) {
    for(new i=0;i<g_OtdelCount[fractionid];i++)
        if(g_Otdel[fractionid][i][otdel_ID]==otdelDbId) return i;
    return -1;
}
stock GetPlayerOtdelIdx(playerid) {
    new frac=PI[playerid][pFraction];
    if(frac<1||frac>10) return -1;
    return GetOtdelIdxByID(frac,g_PlayerOtdelID[playerid]);
}
stock IsOtdelChiefOrDep(playerid) {
    new idx=GetPlayerOtdelIdx(playerid);
    if(idx<0) return false;
    new frac=PI[playerid][pFraction],dbid=PI[playerid][pID];
    if(g_Otdel[frac][idx][otdel_ChiefDBID]==dbid) return true;
    if(g_Otdel[frac][idx][otdel_Dep1DBID]==dbid)  return true;
    if(g_Otdel[frac][idx][otdel_Dep2DBID]==dbid)  return true;
    if(g_Otdel[frac][idx][otdel_Dep3DBID]==dbid)  return true;
    return false;
}
stock IsColonel(playerid) {
    if(PI[playerid][pLeader]==1) return true;
    new frac=PI[playerid][pFraction];
    if(PI[playerid][pFractionRank]>=Fraction[frac][fMax_ranks]-1) return true;
    return false;
}
stock OtdelRadio(fractionid, const msg[]) {
    foreach(new i:Player) {
        if(!PT[i][pLogged]||!PT[i][pDuty]) continue;
        if(PI[i][pFraction]!=fractionid) continue;
        CEFChat_Send(i,"FF4444",msg);
    }
}
stock GetOtdelName(fractionid, otdelDbId, result[], len) {
    new idx=GetOtdelIdxByID(fractionid,otdelDbId);
    if(idx>=0) format(result,len,"%s",g_Otdel[fractionid][idx][otdel_Name]);
    else format(result,len,"Отсутствует");
}


stock Otdel_RemovePlayerSilent(playerid) {
    if(g_PlayerOtdelID[playerid]==-1) return;
    new frac=PI[playerid][pFraction];
    if(frac<1||frac>10) return;
    new otdelId=g_PlayerOtdelID[playerid];
    new idx=GetOtdelIdxByID(frac,otdelId);
    if(idx!=-1 && g_Otdel[frac][idx][otdel_MemberCount]>0)
        g_Otdel[frac][idx][otdel_MemberCount]--;
    g_PlayerOtdelID[playerid]=-1;
    new query[96];
    mysql_format(dbHandle,query,sizeof(query),"DELETE FROM `otdel_members` WHERE `player_id`=%d",PI[playerid][pID]);
    mysql_tquery(dbHandle,query,"","");
}

forward LoadOtdelSystem();
public LoadOtdelSystem() {
    mysql_tquery(dbHandle,"SELECT * FROM `fraction_otdels` ORDER BY `fraction_id`,`id`","OnOtdelSystemLoaded","");
    return 1;
}
forward OnOtdelSystemLoaded();
public OnOtdelSystemLoaded() {
    for(new f=0;f<11;f++) g_OtdelCount[f]=0;
    new rows=cache_num_rows();
    for(new i=0;i<rows;i++) {
        new fid,name[32],dbid,maxm,chief,d1,d2,d3;
        cache_get_value_name_int(i,"id",dbid);
        cache_get_value_name_int(i,"fraction_id",fid);
        cache_get_value_name(i,"otdel_name",name,32);
        cache_get_value_name_int(i,"max_members",maxm);
        cache_get_value_name_int(i,"chief_id",chief);
        cache_get_value_name_int(i,"dep1_id",d1);
        cache_get_value_name_int(i,"dep2_id",d2);
        cache_get_value_name_int(i,"dep3_id",d3);
        if(fid<1||fid>10||g_OtdelCount[fid]>=10) continue;
        new idx=g_OtdelCount[fid];
        g_Otdel[fid][idx][otdel_ID]=dbid;
        g_Otdel[fid][idx][otdel_FractionID]=fid;
        format(g_Otdel[fid][idx][otdel_Name],32,"%s",name);
        g_Otdel[fid][idx][otdel_MaxMembers]=maxm?maxm:20;
        g_Otdel[fid][idx][otdel_ChiefDBID]=chief;
        g_Otdel[fid][idx][otdel_Dep1DBID]=d1;
        g_Otdel[fid][idx][otdel_Dep2DBID]=d2;
        g_Otdel[fid][idx][otdel_Dep3DBID]=d3;
        g_Otdel[fid][idx][otdel_MemberCount]=0;
        g_OtdelCount[fid]++;
    }
    mysql_tquery(dbHandle,"SELECT * FROM `otdel_members`","OnOtdelMembersLoaded","");
    return 1;
}
forward OnOtdelMembersLoaded();
public OnOtdelMembersLoaded() {
    new rows=cache_num_rows();
    for(new i=0;i<rows;i++) {
        new fid,oid;
        cache_get_value_name_int(i,"fraction_id",fid);
        cache_get_value_name_int(i,"otdel_id",oid);
        if(fid<1||fid>10) continue;
        new idx=GetOtdelIdxByID(fid,oid);
        if(idx!=-1) g_Otdel[fid][idx][otdel_MemberCount]++;
    }
    printf("[OtdelSystem] Загружено %d записей.",rows);
    return 1;
}
stock LoadPlayerOtdel(playerid) {
    new query[96];
    mysql_format(dbHandle,query,sizeof(query),
        "SELECT `otdel_id` FROM `otdel_members` WHERE `player_id`=%d LIMIT 1",PI[playerid][pID]);
    mysql_tquery(dbHandle,query,"OnPlayerOtdelLoaded","i",playerid);
}
forward OnPlayerOtdelLoaded(playerid);
public OnPlayerOtdelLoaded(playerid) {
    if(!IsPlayerConnected(playerid)) return 1;
    if(!cache_num_rows()){g_PlayerOtdelID[playerid]=-1;return 1;}
    cache_get_value_name_int(0,"otdel_id",g_PlayerOtdelID[playerid]);
    return 1;
}
forward LoadFractionOtdels();
public LoadFractionOtdels(){LoadOtdelSystem();return 1;}
stock InitPlayerOtdel(playerid){g_PlayerOtdelID[playerid]=-1;PI_Otdel[playerid]=-1;}


cmd:find(playerid, params[]) {
    if(!PT[playerid][pLogged]) return 1;
    if(PI[playerid][pFraction]==FRACTION_NONE) return SendErr(playerid,"Вы не состоите в организации!");
    cef_create_browser(playerid,FIND_BROWSER,FIND_BROWSER_LINK,false,true);
    cef_focus_browser(playerid,FIND_BROWSER,true);
    cef_always_listen_keys(playerid,FIND_BROWSER,true);
    TogglePlayerControllable(playerid,0);
    return 1;
}
callback::OnFindReady(playerid,const arguments[]){SendFINDData(playerid);return 1;}
forward SendFINDData(playerid);
public SendFINDData(playerid) {
    if(!IsPlayerConnected(playerid)) return 1;
    new fractionid=PI[playerid][pFraction];
    new statsTotal=0,statsActive=0,statsVacation=0,statsSuspended=0;
    foreach(new i:Player){
        if(PI[i][pFraction]!=fractionid) continue;
        statsTotal++;
        if(PI[i][pSuspended]>0) statsSuspended++;
        else if(PT[i][pDuty]) statsActive++;
        else statsVacation++;
    }
    new statsJson[256];
    format(statsJson,sizeof statsJson,
        "{\"fractionName\":\"%s\",\"stats\":{\"total\":%d,\"active\":%d,\"vacation\":%d,\"suspended\":%d}}",
        Fraction[fractionid][fName],statsTotal,statsActive,statsVacation,statsSuspended);
    cef_emit_event(playerid,"find:stats",CEFSTR(statsJson));
    for(new i=0;i<Fraction[fractionid][fMax_ranks];i++)
        cef_emit_event(playerid,"find:addrank",CEFSTR(Fraction_Rank[fractionid][i]));
    for(new i=0;i<g_OtdelCount[fractionid];i++)
        cef_emit_event(playerid,"find:adddept",CEFSTR(g_Otdel[fractionid][i][otdel_Name]));
    foreach(new i:Player){
        if(PI[i][pFraction]!=fractionid) continue;
        new rankIdx=PI[i][pFractionRank]-1,rankName[32];
        if(rankIdx>=0&&rankIdx<Fraction[fractionid][fMax_ranks])
            format(rankName,sizeof rankName,"%s",Fraction_Rank[fractionid][rankIdx]);
        else format(rankName,sizeof rankName,"Ранг %d",rankIdx+1);
        new otdelName[32];
        GetOtdelName(fractionid,g_PlayerOtdelID[i],otdelName,sizeof(otdelName));
        new status[16];
        if(PI[i][pSuspended]>0) format(status,sizeof status,"Отстранен");
        else if(PT[i][pDuty]) format(status,sizeof status,"На работе");
        else format(status,sizeof status,"На выходном");
        new memberJson[256];
        format(memberJson,sizeof memberJson,
            "{\"id\":%d,\"name\":\"%s\",\"rank\":\"%s\",\"status\":\"%s\",\"dept\":\"%s\",\"afk\":%d}",
            i,PI[i][pName],rankName,status,otdelName,PI[i][pAFK]);
        cef_emit_event(playerid,"find:addmember",CEFSTR(memberJson));
    }
    cef_emit_event(playerid,"find:done",CEFINT(1));
    return 1;
}
forward CloseFIND(playerid);
public CloseFIND(playerid){
    cef_focus_browser(playerid,FIND_BROWSER,false);
    cef_hide_browser(playerid,FIND_BROWSER,true);
    cef_destroy_browser(playerid,FIND_BROWSER);
    TogglePlayerControllable(playerid,1);
    cef_emit_event(playerid,"game:showCursor",CEFINT(0));
    return 1;
}
callback::OnCloseFIND(playerid,const arguments[]){CloseFIND(playerid);return 1;}


stock OpenOtdelCEF(playerid) {
    if(!cef_player_has_plugin(playerid)) return;
    if(!PT[playerid][pCefLoaded]) return;
    cef_create_browser(playerid,OTDEL_BROWSER,OTDEL_CEF_LINK,false,true);
    cef_focus_browser(playerid,OTDEL_BROWSER,true);
    cef_always_listen_keys(playerid,OTDEL_BROWSER,true);
    TogglePlayerControllable(playerid,0);
}
stock CloseOtdelCEF(playerid) {
    cef_focus_browser(playerid,OTDEL_BROWSER,false);
    cef_hide_browser(playerid,OTDEL_BROWSER,true);
    cef_destroy_browser(playerid,OTDEL_BROWSER);
    TogglePlayerControllable(playerid,1);
}

forward OtdelCEFReady(playerid);
public OtdelCEFReady(playerid) {
    if(!IsPlayerConnected(playerid)) return 1;
    new frac=PI[playerid][pFraction];
    if(frac<1){CloseOtdelCEF(playerid);return 1;}
    if(IsColonel(playerid)) {
        if(g_OtdelCount[frac]==0){
            CloseOtdelCEF(playerid);
            CEFChat_Send(playerid,"FF4444","В организации нет отделов. Используйте /create_otdel");
            return 1;
        }
        cef_emit_event(playerid,"otdel:count",CEFSTR("1"));
        g_OtdelSendIdx[playerid]=0;
        SetTimerEx("OtdelSendNext",100,false,"i",playerid);
        return 1;
    }
    if(IsOtdelChiefOrDep(playerid)) {
        new idx=GetPlayerOtdelIdx(playerid);
        if(idx<0){CloseOtdelCEF(playerid);return 1;}
        g_OtdelTarget[playerid]=idx;
        new dbid=PI[playerid][pID];
        new isChief=(g_Otdel[frac][idx][otdel_ChiefDBID]==dbid);
        new canChief=IsColonel(playerid)?1:0;
        new canDep=(isChief||IsColonel(playerid))?1:0;
        new canDisband=IsColonel(playerid)?1:0;
        new json[256];
        format(json,sizeof(json),"{\"name\":\"%s\",\"canChief\":%d,\"canDep\":%d,\"canDisband\":%d}",
            g_Otdel[frac][idx][otdel_Name],canChief,canDep,canDisband);
        cef_emit_event(playerid,"otdel:open_main",CEFSTR(json));
        return 1;
    }
    new idx=GetPlayerOtdelIdx(playerid);
    if(idx<0){CloseOtdelCEF(playerid);CEFChat_Send(playerid,"FF4444","Вы не состоите в отделе.");return 1;}
    new chiefName[32]="Нет";
    foreach(new i:Player){
        if(PI[i][pID]==g_Otdel[frac][idx][otdel_ChiefDBID]){
            format(chiefName,32,"%s",PI[i][pName]);break;
        }
    }
    new json[256];
    format(json,sizeof(json),"{\"name\":\"%s\",\"members\":%d,\"maxMembers\":%d,\"chief\":\"%s\"}",
        g_Otdel[frac][idx][otdel_Name],g_Otdel[frac][idx][otdel_MemberCount],
        g_Otdel[frac][idx][otdel_MaxMembers],chiefName);
    cef_emit_event(playerid,"otdel:open_view",CEFSTR(json));
    return 1;
}

forward OtdelSendNext(playerid);
public OtdelSendNext(playerid) {
    if(!IsPlayerConnected(playerid)) return 1;
    new frac=PI[playerid][pFraction];
    new i=g_OtdelSendIdx[playerid];
    if(i>=g_OtdelCount[frac]) {
        cef_emit_event(playerid,"otdel:open_select",CEFSTR("1"));
        return 1;
    }
    new entry[64];
    format(entry,sizeof(entry),"{\"n\":\"%s\"}",g_Otdel[frac][i][otdel_Name]);
    cef_emit_event(playerid,"otdel:add_otdel",CEFSTR(entry));
    g_OtdelSendIdx[playerid]++;
    SetTimerEx("OtdelSendNext",100,false,"i",playerid);
    return 1;
}

callback::OnOtdelReady(playerid,const arguments[]){OtdelCEFReady(playerid);return 1;}
callback::OnOtdelClose(playerid,const arguments[]){CloseOtdelCEF(playerid);return 1;}

callback::OnOtdelSelect(playerid,const arguments[]) {
    new idx=strval(arguments);
    new frac=PI[playerid][pFraction];
    if(idx>=0&&idx<g_OtdelCount[frac]) g_OtdelTarget[playerid]=idx;
    return 1;
}

callback::OnOtdelInfo(playerid,const arguments[]) {
    new frac=PI[playerid][pFraction];
    new idx=g_OtdelTarget[playerid];
    if(idx<0||idx>=g_OtdelCount[frac]) return 1;
    new chief[32]="Нет",dep1[32]="Нет",dep2[32]="Нет",dep3[32]="Нет";
    foreach(new i:Player){
        if(!PT[i][pLogged]) continue;
        new pid=PI[i][pID];
        if(pid==g_Otdel[frac][idx][otdel_ChiefDBID]) format(chief,32,"%s",PI[i][pName]);
        if(pid==g_Otdel[frac][idx][otdel_Dep1DBID])  format(dep1,32,"%s",PI[i][pName]);
        if(pid==g_Otdel[frac][idx][otdel_Dep2DBID])  format(dep2,32,"%s",PI[i][pName]);
        if(pid==g_Otdel[frac][idx][otdel_Dep3DBID])  format(dep3,32,"%s",PI[i][pName]);
    }
    new json[512];
    format(json,sizeof(json),
        "{\"name\":\"%s\",\"members\":%d,\"maxMembers\":%d,\"chief\":\"%s\",\"dep1\":\"%s\",\"dep2\":\"%s\",\"dep3\":\"%s\"}",
        g_Otdel[frac][idx][otdel_Name],g_Otdel[frac][idx][otdel_MemberCount],
        g_Otdel[frac][idx][otdel_MaxMembers],chief,dep1,dep2,dep3);
    cef_emit_event(playerid,"otdel:info_result",CEFSTR(json));
    return 1;
}

callback::OnOtdelMembers(playerid,const arguments[]) {
    new frac=PI[playerid][pFraction];
    new idx=g_OtdelTarget[playerid];
    if(idx<0||idx>=g_OtdelCount[frac]) return 1;
    new otdelId=g_Otdel[frac][idx][otdel_ID];
    new query[192];
    mysql_format(dbHandle,query,sizeof(query),
        "SELECT `name`,`fraction_rank` FROM `accounts` WHERE `id` IN (SELECT `player_id` FROM `otdel_members` WHERE `otdel_id`=%d) ORDER BY `fraction_rank` DESC",
        otdelId);
    mysql_tquery(dbHandle,query,"OnOtdelMembersCEF","i",playerid);
    return 1;
}
forward OnOtdelMembersCEF(playerid);
public OnOtdelMembersCEF(playerid) {
    if(!IsPlayerConnected(playerid)) return 1;
    new frac=PI[playerid][pFraction];
    new rows=cache_num_rows();
    if(rows==0){cef_emit_event(playerid,"otdel:members_result",CEFSTR("[]"));return 1;}
    new result[2048];
    strcat(result,"[");
    for(new i=0;i<rows;i++){
        new name[32],rank;
        cache_get_value_name(i,"name",name,sizeof(name));
        cache_get_value_name_int(i,"fraction_rank",rank);
        new rankName[32],rankIdx=rank-1;
        if(rankIdx>=0&&rankIdx<Fraction[frac][fMax_ranks])
            format(rankName,sizeof(rankName),"%s",Fraction_Rank[frac][rankIdx]);
        else format(rankName,sizeof(rankName),"Ранг %d",rank);
        new online=0;
        foreach(new p:Player){
            if(!PT[p][pLogged]) continue;
            if(!strcmp(PI[p][pName],name,true)){online=1;break;}
        }
        new entry[128];
        format(entry,sizeof(entry),"{\"name\":\"%s\",\"rank\":\"%s\",\"online\":%d}",name,rankName,online);
        strcat(result,entry);
        if(i<rows-1) strcat(result,",");
    }
    strcat(result,"]");
    cef_emit_event(playerid,"otdel:members_result",CEFSTR(result));
    return 1;
}

callback::OnOtdelAdd(playerid,const arguments[]) {
    new frac=PI[playerid][pFraction];
    new idx=g_OtdelTarget[playerid];
    if(idx<0||idx>=g_OtdelCount[frac]){cef_emit_event(playerid,"otdel:add_result",CEFSTR("{\"error\":\"Otdel ne vybran\"}"));return 1;}
    new targetid=strval(arguments);
    if(!IsPlayerConnected(targetid)||!PT[targetid][pLogged]){cef_emit_event(playerid,"otdel:add_result",CEFSTR("{\"error\":\"Igrok ne najden\"}"));return 1;}
    if(PI[targetid][pFraction]!=frac){cef_emit_event(playerid,"otdel:add_result",CEFSTR("{\"error\":\"Igrok ne v organizacii\"}"));return 1;}
    if(g_PlayerOtdelID[targetid]!=-1){cef_emit_event(playerid,"otdel:add_result",CEFSTR("{\"error\":\"Igrok uzhe v otdele\"}"));return 1;}
    if(g_Otdel[frac][idx][otdel_MemberCount]>=g_Otdel[frac][idx][otdel_MaxMembers]){cef_emit_event(playerid,"otdel:add_result",CEFSTR("{\"error\":\"Otdel zaplnen\"}"));return 1;}
    new otdelId=g_Otdel[frac][idx][otdel_ID];
    g_PlayerOtdelID[targetid]=otdelId;
    g_Otdel[frac][idx][otdel_MemberCount]++;
    new query[192];
    mysql_format(dbHandle,query,sizeof(query),
        "INSERT INTO `otdel_members` (`player_id`,`otdel_id`,`fraction_id`) VALUES (%d,%d,%d) ON DUPLICATE KEY UPDATE `otdel_id`=%d,`fraction_id`=%d",
        PI[targetid][pID],otdelId,frac,otdelId,frac);
    mysql_tquery(dbHandle,query,"","");

    new msg[128];
    format(msg,sizeof(msg),"[R] %s принял %s в отдел %s.",PI[playerid][pName],PI[targetid][pName],g_Otdel[frac][idx][otdel_Name]);
    OtdelRadio(frac,msg);
    CEFChat_Send(targetid,"54B367","Вас приняли в отдел.");
    cef_emit_event(playerid,"otdel:add_result",CEFSTR("{\"ok\":1}"));
    return 1;
}

callback::OnOtdelKick(playerid,const arguments[]) {
    new frac=PI[playerid][pFraction];
    new idx=g_OtdelTarget[playerid];
    if(idx<0||idx>=g_OtdelCount[frac]) return 1;
    new targetid=strval(arguments);
    if(!IsPlayerConnected(targetid)||!PT[targetid][pLogged]){cef_emit_event(playerid,"otdel:kick_result",CEFSTR("{\"error\":\"Igrok ne najden\"}"));return 1;}
    new otdelId=g_Otdel[frac][idx][otdel_ID];
    if(g_PlayerOtdelID[targetid]!=otdelId){cef_emit_event(playerid,"otdel:kick_result",CEFSTR("{\"error\":\"Igrok ne v etom otdele\"}"));return 1;}
    g_PlayerOtdelID[targetid]=-1;
    if(g_Otdel[frac][idx][otdel_MemberCount]>0) g_Otdel[frac][idx][otdel_MemberCount]--;
    new query[96];
    mysql_format(dbHandle,query,sizeof(query),"DELETE FROM `otdel_members` WHERE `player_id`=%d",PI[targetid][pID]);
    mysql_tquery(dbHandle,query,"","");

    new msg[128];
    format(msg,sizeof(msg),"[R] %s исключил %s из отдела %s.",PI[playerid][pName],PI[targetid][pName],g_Otdel[frac][idx][otdel_Name]);
    OtdelRadio(frac,msg);
    CEFChat_Send(targetid,"FF4444","Вас исключили из отдела.");
    cef_emit_event(playerid,"otdel:kick_result",CEFSTR("{\"ok\":1}"));
    return 1;
}

callback::OnOtdelChief(playerid,const arguments[]) {
    new frac=PI[playerid][pFraction];
    new idx=g_OtdelTarget[playerid];
    if(idx<0){cef_emit_event(playerid,"otdel:chief_result",CEFSTR("{\"error\":\"Otdel ne vybran\"}"));return 1;}
    new targetid=-1;
    foreach(new i:Player){if(!PT[i][pLogged])continue;if(!strcmp(PI[i][pName],arguments,true)){targetid=i;break;}}
    if(targetid==-1){cef_emit_event(playerid,"otdel:chief_result",CEFSTR("{\"error\":\"Igrok ne najden\"}"));return 1;}
    if(PI[targetid][pFraction]!=frac){cef_emit_event(playerid,"otdel:chief_result",CEFSTR("{\"error\":\"Igrok ne v organizacii\"}"));return 1;}
    g_Otdel[frac][idx][otdel_ChiefDBID]=PI[targetid][pID];
    new query[96];
    mysql_format(dbHandle,query,sizeof(query),"UPDATE `fraction_otdels` SET `chief_id`=%d WHERE `id`=%d",PI[targetid][pID],g_Otdel[frac][idx][otdel_ID]);
    mysql_tquery(dbHandle,query,"","");
    new msg[128];
    format(msg,sizeof(msg),"[R] %s назначил %s начальником отдела %s.",PI[playerid][pName],arguments,g_Otdel[frac][idx][otdel_Name]);
    OtdelRadio(frac,msg);
    cef_emit_event(playerid,"otdel:chief_result",CEFSTR("{\"ok\":1}"));
    return 1;
}

callback::OnOtdelDep(playerid,const arguments[]) {
    new frac=PI[playerid][pFraction];
    new idx=g_OtdelTarget[playerid];
    if(idx<0){cef_emit_event(playerid,"otdel:dep_result",CEFSTR("{\"error\":\"Otdel ne vybran\"}"));return 1;}
    new tmp[256],slot=0,name[32];
    format(tmp,sizeof(tmp),"%s",arguments);
    new pos=strfind(tmp,"\"slot\":");
    if(pos!=-1) slot=strval(tmp[pos+7]);
    pos=strfind(tmp,"\"name\":\"");
    if(pos!=-1){pos+=8;new end=strfind(tmp,"\"",false,pos);if(end!=-1)strmid(name,tmp,pos,end,sizeof(name));}
    new targetid=-1;
    foreach(new i:Player){if(!PT[i][pLogged])continue;if(!strcmp(PI[i][pName],name,true)){targetid=i;break;}}
    if(targetid==-1){cef_emit_event(playerid,"otdel:dep_result",CEFSTR("{\"error\":\"Igrok ne najden\"}"));return 1;}
    if(PI[targetid][pFraction]!=frac){cef_emit_event(playerid,"otdel:dep_result",CEFSTR("{\"error\":\"Igrok ne v organizacii\"}"));return 1;}
    new colName[16],depDbId=PI[targetid][pID];
    switch(slot){
        case 0:{g_Otdel[frac][idx][otdel_Dep1DBID]=depDbId;colName="dep1_id";}
        case 1:{g_Otdel[frac][idx][otdel_Dep2DBID]=depDbId;colName="dep2_id";}
        case 2:{g_Otdel[frac][idx][otdel_Dep3DBID]=depDbId;colName="dep3_id";}
    }
    new query[128];
    mysql_format(dbHandle,query,sizeof(query),"UPDATE `fraction_otdels` SET `%s`=%d WHERE `id`=%d",colName,depDbId,g_Otdel[frac][idx][otdel_ID]);
    mysql_tquery(dbHandle,query,"","");
    new msg[128];
    format(msg,sizeof(msg),"[R] %s назначил %s заместителем (%d) отдела %s.",PI[playerid][pName],name,slot+1,g_Otdel[frac][idx][otdel_Name]);
    OtdelRadio(frac,msg);
    cef_emit_event(playerid,"otdel:dep_result",CEFSTR("{\"ok\":1}"));
    return 1;
}

callback::OnOtdelDisband(playerid,const arguments[]) {
    new frac=PI[playerid][pFraction];
    new idx=g_OtdelTarget[playerid];
    if(idx<0||idx>=g_OtdelCount[frac]){cef_emit_event(playerid,"otdel:disband_result",CEFSTR("{\"error\":\"Otdel ne vybran\"}"));return 1;}
    if(!IsColonel(playerid)){cef_emit_event(playerid,"otdel:disband_result",CEFSTR("{\"error\":\"Net prav\"}"));return 1;}
    new otdelId=g_Otdel[frac][idx][otdel_ID],otdelName[32];
    format(otdelName,sizeof(otdelName),"%s",g_Otdel[frac][idx][otdel_Name]);
    foreach(new i:Player){if(g_PlayerOtdelID[i]==otdelId)g_PlayerOtdelID[i]=-1;}
    new query[96];
    mysql_format(dbHandle,query,sizeof(query),"DELETE FROM `otdel_members` WHERE `otdel_id`=%d",otdelId);
    mysql_tquery(dbHandle,query,"","");
    mysql_format(dbHandle,query,sizeof(query),"DELETE FROM `fraction_otdels` WHERE `id`=%d",otdelId);
    mysql_tquery(dbHandle,query,"","");
    for(new i=idx;i<g_OtdelCount[frac]-1;i++) g_Otdel[frac][i]=g_Otdel[frac][i+1];
    g_OtdelCount[frac]--;
    g_OtdelTarget[playerid]=-1;
    new msg[128];
    format(msg,sizeof(msg),"[R] %s расформировал отдел %s.",PI[playerid][pName],otdelName);
    OtdelRadio(frac,msg);
    cef_emit_event(playerid,"otdel:disband_result",CEFSTR("{\"ok\":1}"));
    return 1;
}

cmd:otdel(playerid, params[]) {
    if(!PT[playerid][pLogged]) return 1;
    if(PI[playerid][pFraction]<1) return SendErr(playerid,"Вы не в организации.");
    if(!IsOtdelChiefOrDep(playerid)) return SendErr(playerid,"Нет прав. Только начальник и заместитель отдела.");
    OpenOtdelCEF(playerid);
    return 1;
}
cmd:otdel_edit(playerid, params[]) {
    if(!PT[playerid][pLogged]) return 1;
    if(PI[playerid][pFraction]<1) return SendErr(playerid,"Вы не в организации.");
    if(!IsColonel(playerid)) return SendErr(playerid,"Нет прав.");
    OpenOtdelCEF(playerid);
    return 1;
}
cmd:create_otdel(playerid, params[]) {
    if(!PT[playerid][pLogged]) return 1;
    if(PI[playerid][pAdmin]<4) return SendErr(playerid,"Нет прав.");
    new fid,maxm,name[32];
    if(sscanf(params,"dds[32]",fid,maxm,name))
        return SendErr(playerid,"Использование: /create_otdel [id фракции] [макс.чел] [название]");
    if(fid<1||fid>10) return SendErr(playerid,"ID фракции 1-10.");
    if(maxm<=0) maxm=20;
    if(g_OtdelCount[fid]>=10) return SendErr(playerid,"Лимит 10 отделов.");
    g_AdminFrac[playerid]=fid;
    g_AdminMax[playerid]=maxm;
    new query[192];
    mysql_format(dbHandle,query,sizeof(query),"INSERT INTO `fraction_otdels` (`fraction_id`,`otdel_name`,`max_members`) VALUES (%d,'%e',%d)",fid,name,maxm);
    new nameCopy[32];
    format(nameCopy,sizeof(nameCopy),"%s",name);
    mysql_tquery(dbHandle,query,"OnNewOtdelCreated","iis",playerid,fid,nameCopy);
    return 1;
}
cmd:del_otdel(playerid, params[]) {
    if(!PT[playerid][pLogged]) return 1;
    if(PI[playerid][pAdmin]<4) return SendErr(playerid,"Нет прав.");
    new fid,idx;
    if(sscanf(params,"dd",fid,idx))
        return SendErr(playerid,"Использование: /del_otdel [id фракции] [индекс]");
    if(fid<1||fid>10) return SendErr(playerid,"ID фракции 1-10.");
    if(idx<0||idx>=g_OtdelCount[fid]) return SendErr(playerid,"Неверный индекс.");
    new otdelId=g_Otdel[fid][idx][otdel_ID];
    foreach(new i:Player){if(g_PlayerOtdelID[i]==otdelId)g_PlayerOtdelID[i]=-1;}
    new query[96];
    mysql_format(dbHandle,query,sizeof(query),"DELETE FROM `otdel_members` WHERE `otdel_id`=%d",otdelId);
    mysql_tquery(dbHandle,query,"","");
    mysql_format(dbHandle,query,sizeof(query),"DELETE FROM `fraction_otdels` WHERE `id`=%d",otdelId);
    mysql_tquery(dbHandle,query,"","");
    for(new i=idx;i<g_OtdelCount[fid]-1;i++) g_Otdel[fid][i]=g_Otdel[fid][i+1];
    g_OtdelCount[fid]--;
    CEFChat_Send(playerid,"54B367","Отдел удалён.");
    return 1;
}
cmd:list_otdel(playerid, params[]) {
    if(!PT[playerid][pLogged]) return 1;
    new frac=PI[playerid][pFraction];
    if(frac<1) return SendErr(playerid,"Вы не в организации.");
    if(g_OtdelCount[frac]==0) return SendErr(playerid,"В организации нет отделов.");
    new str[512];
    for(new i=0;i<g_OtdelCount[frac];i++){
        new tmp[80];
        format(tmp,sizeof(tmp),"[%d] %s | %d/%d чел.\n",i,g_Otdel[frac][i][otdel_Name],g_Otdel[frac][i][otdel_MemberCount],g_Otdel[frac][i][otdel_MaxMembers]);
        strcat(str,tmp);
    }
    CEFChat_Send(playerid,"AAAAAA",str);
    return 1;
}

forward OnNewOtdelCreated(playerid, fractionid, const name[]);
public OnNewOtdelCreated(playerid, fractionid, const name[]) {
    if(!IsPlayerConnected(playerid)) return 1;
    new insertId=cache_insert_id();
    new idx=g_OtdelCount[fractionid];
    g_Otdel[fractionid][idx][otdel_ID]=insertId;
    g_Otdel[fractionid][idx][otdel_FractionID]=fractionid;
    format(g_Otdel[fractionid][idx][otdel_Name],32,"%s",name);
    g_Otdel[fractionid][idx][otdel_MaxMembers]=g_AdminMax[playerid];
    g_Otdel[fractionid][idx][otdel_MemberCount]=0;
    g_OtdelCount[fractionid]++;
    new msg[128];
    format(msg,sizeof(msg),"Отдел %s создан. Фракция: %d, Макс: %d, ID: %d",name,fractionid,g_AdminMax[playerid],insertId);
    CEFChat_Send(playerid,"54B367",msg);
    return 1;
}
callback::OnFindAction(playerid, const arguments[])
{
    if(!PT[playerid][pLogged]) return 1;
    if(!CanUseFracCmd(playerid)) {
        CEFChat_Send(playerid, "FF4444", "Нет прав.");
        return 1;
    }

    new action[16];
    new pos = strfind(arguments, "\"action\":\"");
    if(pos == -1) return 1;
    pos += 10;
    new end = strfind(arguments, "\"", false, pos);
    if(end == -1) return 1;
    strmid(action, arguments, pos, end, sizeof(action));


    new targetServerId = -1;
    pos = strfind(arguments, "\"id\":");
    if(pos == -1) return 1;
    pos += 5;
    targetServerId = strval(arguments[pos]);

    if(targetServerId < 0 || targetServerId >= MAX_PLAYERS) return 1;
    if(!IsPlayerConnected(targetServerId) || !PT[targetServerId][pLogged]) {
        CEFChat_Send(playerid, "FF4444", "Игрок не в сети.");
        return 1;
    }

    new frac = PI[playerid][pFraction];
    if(PI[targetServerId][pFraction] != frac) {
        CEFChat_Send(playerid, "FF4444", "Игрок не в вашей организации.");
        return 1;
    }
    if(PI[targetServerId][pFractionRank] >= PI[playerid][pFractionRank]) {
        CEFChat_Send(playerid, "FF4444", "Нельзя применить действие к равному или вышестоящему.");
        return 1;
    }

    new targetName[MAX_PLAYER_NAME];
    GetPlayerName(targetServerId, targetName, sizeof(targetName));

    if(!strcmp(action, "fire", true))
    {

        WB_AddRecord(targetServerId, WB_ACTION_FIRE, PI[targetServerId][pFractionRank], 0, "Уволен через панель", PI[playerid][pName]);
        Otdel_RemovePlayerSilent(targetServerId);
        PI[targetServerId][pFraction]     = 0;
        PI[targetServerId][pFractionRank] = 0;
        PI[targetServerId][pFractionSkin] = 0;
        SetPlayerSkin(targetServerId, PI[targetServerId][pSkin]);
        new query[128];
        mysql_format(dbHandle, query, sizeof(query),
            "UPDATE `accounts` SET `fraction`=0,`fraction_rank`=0,`fraction_skin`=0 WHERE `id`=%d",
            PI[targetServerId][pID]);
        mysql_tquery(dbHandle, query, "", "");
        CEFChat_Send(targetServerId, "FF4444", "Вы были уволены из организации.");
        new msg[128];
        format(msg, sizeof(msg), "Вы уволили %s.", targetName);
        CEFChat_Send(playerid, "54B367", msg);
    }
    else if(!strcmp(action, "warn", true))
    {

        g_WarnCount[targetServerId]++;
        WB_AddRecord(targetServerId, WB_ACTION_WARN, 0, 0, "Выдан через панель", PI[playerid][pName]);
        new msg[128];
        format(msg, sizeof(msg), "Вам выдан выговор через панель. (%d/3)", g_WarnCount[targetServerId]);
        CEFChat_Send(targetServerId, "FF8C00", msg);
        format(msg, sizeof(msg), "Вы выдали выговор %s. (%d/3)", targetName, g_WarnCount[targetServerId]);
        CEFChat_Send(playerid, "AAAAAA", msg);

        if(g_WarnCount[targetServerId] >= 3) {
            WB_AddRecord(targetServerId, WB_ACTION_FIRE, PI[targetServerId][pFractionRank], 0, "3 выговора", PI[playerid][pName]);
            Otdel_RemovePlayerSilent(targetServerId);
            PI[targetServerId][pFraction]     = 0;
            PI[targetServerId][pFractionRank] = 0;
            PI[targetServerId][pFractionSkin] = 0;
            g_WarnCount[targetServerId]       = 0;
            SetPlayerSkin(targetServerId, PI[targetServerId][pSkin]);
            new query[128];
            mysql_format(dbHandle, query, sizeof(query),
                "UPDATE `accounts` SET `fraction`=0,`fraction_rank`=0,`fraction_skin`=0,`warn_count`=0 WHERE `id`=%d",
                PI[targetServerId][pID]);
            mysql_tquery(dbHandle, query, "", "");
            CEFChat_Send(targetServerId, "FF4444", "Вы уволены автоматически за 3 выговора.");
        }
        new query2[96];
        mysql_format(dbHandle, query2, sizeof(query2),
            "UPDATE `accounts` SET `warn_count`=%d WHERE `id`=%d",
            g_WarnCount[targetServerId], PI[targetServerId][pID]);
        mysql_tquery(dbHandle, query2, "", "");
    }
    else if(!strcmp(action, "promote", true))
    {
        new targetRank = PI[targetServerId][pFractionRank];
        if(targetRank >= Fraction[frac][fMax_ranks]) {
            CEFChat_Send(playerid, "FF4444", "Игрок уже на максимальном ранге.");
            return 1;
        }
        if(targetRank >= PI[playerid][pFractionRank] - 1) {
            CEFChat_Send(playerid, "FF4444", "Нельзя повысить до своего ранга.");
            return 1;
        }
        new newRank = targetRank + 1;
        WB_AddRecord(targetServerId, WB_ACTION_RANKUP, targetRank, newRank, "", PI[playerid][pName]);
        PI[targetServerId][pFractionRank] = newRank;
        new query[96];
        mysql_format(dbHandle, query, sizeof(query),
            "UPDATE `accounts` SET `fraction_rank`=%d WHERE `id`=%d",
            newRank, PI[targetServerId][pID]);
        mysql_tquery(dbHandle, query, "", "");
        new rankName[32];
        format(rankName, sizeof(rankName), "%s", Fraction_Rank[frac][newRank-1]);
        new msg[128];
        format(msg, sizeof(msg), "Вы повышены до звания %s.", rankName);
        CEFChat_Send(targetServerId, "54B367", msg);
        format(msg, sizeof(msg), "Вы повысили %s до звания %s.", targetName, rankName);
        CEFChat_Send(playerid, "AAAAAA", msg);
    }
    else if(!strcmp(action, "demote", true))
    {
        new targetRank = PI[targetServerId][pFractionRank];
        if(targetRank <= 1) {
            CEFChat_Send(playerid, "FF4444", "Игрок уже на минимальном ранге.");
            return 1;
        }
        new newRank = targetRank - 1;
        WB_AddRecord(targetServerId, WB_ACTION_RANKDOWN, targetRank, newRank, "", PI[playerid][pName]);
        PI[targetServerId][pFractionRank] = newRank;
        new query[96];
        mysql_format(dbHandle, query, sizeof(query),
            "UPDATE `accounts` SET `fraction_rank`=%d WHERE `id`=%d",
            newRank, PI[targetServerId][pID]);
        mysql_tquery(dbHandle, query, "", "");
        new rankName[32];
        format(rankName, sizeof(rankName), "%s", Fraction_Rank[frac][newRank-1]);
        new msg[128];
        format(msg, sizeof(msg), "Вы понижены до звания %s.", rankName);
        CEFChat_Send(targetServerId, "FF4444", msg);
        format(msg, sizeof(msg), "Вы понизили %s до звания %s.", targetName, rankName);
        CEFChat_Send(playerid, "AAAAAA", msg);
    }

    return 1;
}
