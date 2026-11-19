
cmd:show_hint(playerid)
{

    ShowBHint(playerid, "  ", "  ", "!", 1000, 10000, "      ", "#c42e24", "#fcef74");
}
cmd:hide_hint(playerid)
{
    HideBHint(playerid);
}

cmd:hold(playerid) cef_emit_event(playerid, "game:ShowKeyHold");

cmd:n(playerid) cef_emit_event(playerid, "game:ShowNotification", CEFSTR(""), CEFSTR(" 7 "), CEFSTR("check_circle"), CEFINT(5), CEFSTR("#3c98c0"), CEFSTR("#2b6ea4"), CEFSTR("white"));

cmd:skins(playerid, params[])
{
    extract params -> new type; else return SendErr(playerid, ": /skins [type]\n: 0 - , 1 -  , 2 - .  ");
    cef_emit_event(playerid, "game:openSkinSelector", CEFINT(type));
    return 1;
}

cmd:test_skins(playerid)
{
    new JSON[512];
    format(JSON, sizeof JSON, "[{\"name\":\"\",\"price\":\"28 000\"},{\"name\":\"\",\"price\":\"15 000\"}]");
    cef_emit_event(playerid, "game:setCategories", CEFSTR(JSON));
    cef_emit_event(playerid, "game:openSkinSelector", CEFINT(1));
    return 1;
}

cmd:getcamera(playerid)
{
    if(IsPlayerGrandAdmin(playerid) == 0) return SendClientMessage(playerid,0xFFFFFFAA,"{F8FAFA}  ! {F8FAFA} {FF9900}/menu{F8FAFA}   ");
	new Float:fPX, Float:fPY, Float:fPZ,
        Float:fVX, Float:fVY, Float:fVZ,
        Float:object_x, Float:object_y, Float:object_z;

	new string[200];
    const Float:fScale = 5.0;

    GetPlayerCameraPos(playerid, fPX, fPY, fPZ);
    GetPlayerCameraFrontVector(playerid, fVX, fVY, fVZ);

    object_x = fPX + floatmul(fVX, fScale);
    object_y = fPY + floatmul(fVY, fScale);
    object_z = fPZ + floatmul(fVZ, fScale);

    format(string, sizeof(string), "CameraPos: %f,%f,%f | LookAt: %f,%f,%f",fPX,fPY,fPZ,object_x,object_y,object_z);
    SendClientMessage(playerid, COLOR_WHITE, string);
    print(string);
    return 1;

}
cmd:test_udo(playerid)
{
    CEF_LiveUdo(playerid, playerid);
    return 1;
}
cmd:hide_udo(playerid)
{
    CEFC_DocumentsClosed(playerid);
    return 1;
}


cmd:q(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;
    cef_emit_event(playerid, "game:quit", CEFINT(0));
    SetTimerEx("KickPlayer", 500, false, "i", playerid);
    return 1;
}

forward KickPlayer(playerid);
public KickPlayer(playerid)
{
    if(IsPlayerConnected(playerid)) Kick(playerid);
}

CMD:pass(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;

    if(!strlen(params))
    {
        if(!OpenPassportCEF(playerid))
            return SendErr(playerid, "CEF is required to view the passport.");
        return 1;
    }

    new targetid;
    if(sscanf(params, "i", targetid))
        return SendErr(playerid, "Use: /pass [playerid]");
    return Document_Offer(playerid, targetid, DOC_TYPE_PASSPORT);
}

CMD:lic(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;

    if(!strlen(params))
    {
        if(!OpenLicenseCEF(playerid))
            return SendErr(playerid, "CEF is required to view licenses.");
        return 1;
    }

    new targetid;
    if(sscanf(params, "i", targetid))
        return SendErr(playerid, "Use: /lic [playerid]");
    return Document_Offer(playerid, targetid, DOC_TYPE_LICENSE);
}

CMD:carpass(playerid, params[])
{
    #pragma unused params
    if(!PT[playerid][pLogged]) return 1;

    new vehicleid = GetPlayerVehicleID(playerid);
    if(vehicleid != PI[playerid][pCar]) vehicleid = PI[playerid][pCar];
    if(!IsValidVehicle(vehicleid))
        return SendErr(playerid, "У Вас нет загруженного личного автомобиля.");

    if(!OpenCarpassCEF(playerid))
        return SendErr(playerid, "Для просмотра техпаспорта необходим CEF-плагин.");
    return 1;
}

CMD:closepass(playerid, params[])
{
    #pragma unused params
    ClosePassportCEF(playerid);
    CloseLicenseCEF(playerid);
    CloseCarpassCEF(playerid);
    return 1;
}
