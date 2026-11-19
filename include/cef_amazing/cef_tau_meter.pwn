#if defined _cef_tau_meter_included
    #endinput
#endif
#define _cef_tau_meter_included






























#define CEF_TAU_KEY_EXIT        1
#define CEF_TAU_KEY_START       2
#define CEF_TAU_KEY_COMPLETE    3
#define CEF_TAU_KEY_CALIB_DONE  4
#define CEF_TAU_KEY_GLASS       5


#define CEF_TAU_PLACE_CALIB     0
#define CEF_TAU_PLACE_FRONT     1
#define CEF_TAU_PLACE_SIDE      2

#define CEF_TAU_CHARGE_MAX      100
#define CEF_TAU_CHARGE_MIN      3
#define CEF_TAU_CHARGE_USE      2

new gCefTauOpen[MAX_PLAYERS];
new gCefTauVeh[MAX_PLAYERS];
new gCefTintPct[MAX_VEHICLES];
new gCefTauCharge[MAX_PLAYERS];
new gCefTauCalib[MAX_PLAYERS];
new gCefTauMeasures[MAX_PLAYERS];

stock CEF_TintPctFromAlpha(a)
{
    new pct;
    if(a < 0) a = 0;
    if(a > 255) a = 255;
    pct = 100 - (a * 100 / 255);
    if(pct < 1) pct = 1;
    if(pct > 100) pct = 100;
    return pct;
}

stock CEF_TintAlphaFromPct(pct)
{
    new a;
    if(pct < 1) pct = 1;
    if(pct > 100) pct = 100;
    a = (100 - pct) * 255 / 100;
    if(a < 0) a = 0;
    if(a > 255) a = 255;
    return a;
}

stock CEF_TintPercent(vehicleid)
{
    if(vehicleid < 1 || vehicleid >= MAX_VEHICLES || !IsValidVehicle(vehicleid)) return 100;
    if(gCefTintPct[vehicleid] > 0 && gCefTintPct[vehicleid] <= 100) return gCefTintPct[vehicleid];
    if(CI[vehicleid][vToningToggled]) return CEF_TintPctFromAlpha(CI[vehicleid][vToningA]);
    return 100;
}

stock CEF_TintApplyAll(vehicleid, r, g, b, a)
{
    if(vehicleid < 1 || vehicleid >= MAX_VEHICLES || !IsValidVehicle(vehicleid)) return 0;
    if(r < 0) r = 0; if(r > 255) r = 255;
    if(g < 0) g = 0; if(g > 255) g = 255;
    if(b < 0) b = 0; if(b > 255) b = 255;
    if(a < 0) a = 0; if(a > 255) a = 255;
    CI[vehicleid][vToningR] = r;
    CI[vehicleid][vToningG] = g;
    CI[vehicleid][vToningB] = b;
    CI[vehicleid][vToningA] = a;
    CI[vehicleid][vToningToggled] = (a > 8) ? true : false;
    gCefTintPct[vehicleid] = CEF_TintPctFromAlpha(a);
    foreach(new i : Player)
    {
        if(!PT[i][pLogged]) continue;
        SetVehicleToning(i, vehicleid, r, g, b, a);
    }
    return 1;
}

stock CEF_TintSetPercent(vehicleid, pct)
{
    new a, r, g, b;
    if(pct < 1) pct = 1;
    if(pct > 100) pct = 100;
    if(vehicleid < 1 || vehicleid >= MAX_VEHICLES || !IsValidVehicle(vehicleid)) return 0;
    gCefTintPct[vehicleid] = pct;
    a = CEF_TintAlphaFromPct(pct);
    r = CI[vehicleid][vToningR];
    g = CI[vehicleid][vToningG];
    b = CI[vehicleid][vToningB];
    if(!CI[vehicleid][vToningToggled] && r + g + b == 0)
    {
        r = 10; g = 10; b = 10;
    }
    return CEF_TintApplyAll(vehicleid, r, g, b, a);
}

stock CEF_TauNearestVehicle(playerid)
{
    new vid, i, Float:px, Float:py, Float:pz, Float:vx, Float:vy, Float:vz, Float:d, Float:best;
    vid = GetPlayerVehicleID(playerid);
    if(vid > 0 && IsValidVehicle(vid)) return vid;
    GetPlayerPos(playerid, px, py, pz);
    best = 8.0;
    vid = 0;
    for(i = 1; i < MAX_VEHICLES; i++)
    {
        if(!IsValidVehicle(i)) continue;
        GetVehiclePos(i, vx, vy, vz);
        d = floatsqroot((px - vx) * (px - vx) + (py - vy) * (py - vy) + (pz - vz) * (pz - vz));
        if(d < best)
        {
            best = d;
            vid = i;
        }
    }
    return vid;
}


stock CEF_TauEnsureState(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS) return 0;
    if(gCefTauCharge[playerid] < 0)
    {
        gCefTauCharge[playerid] = CEF_TAU_CHARGE_MAX;
        gCefTauCalib[playerid] = 0;
        gCefTauMeasures[playerid] = 0;
    }
    if(gCefTauCharge[playerid] > CEF_TAU_CHARGE_MAX) gCefTauCharge[playerid] = CEF_TAU_CHARGE_MAX;
    if(gCefTauCharge[playerid] < CEF_TAU_CHARGE_MIN) gCefTauCharge[playerid] = CEF_TAU_CHARGE_MIN;
    return gCefTauCharge[playerid];
}



stock CEF_TauReadPlace(playerid, vehicleid, place)
{
    new pct, jitter, val;
    if(place == CEF_TAU_PLACE_CALIB) return 100;
    pct = 100;
    if(vehicleid > 0 && IsValidVehicle(vehicleid))
    {
        pct = CEF_TintPercent(vehicleid);
        if(place == CEF_TAU_PLACE_SIDE && pct > 20) pct -= 15;
    }

    gCefTauMeasures[playerid]++;
    jitter = (gCefTauMeasures[playerid] * 7 + place * 3) % 3;
    val = pct - jitter;
    if(val < 1) val = 1;
    if(val > 100) val = 100;
    return val;
}




stock CEF_TauBuildJson(playerid, vehicleid, dest[], size)
{
    new pct, model, legal, charge;
    pct = 100;
    model = 0;
    legal = 1;
    if(vehicleid > 0 && IsValidVehicle(vehicleid))
    {
        pct = CEF_TintPercent(vehicleid);
        model = GetVehicleModel(vehicleid);
        legal = (pct >= 70) ? 1 : 0;
    }
    charge = CEF_TauEnsureState(playerid);
    format(dest, size,
        "{\"isCalibrated\":%s,\"chargeLevel\":%d,\"percent\":%d,\"value\":%d,\"light\":%d,\"legal\":%d,\"vehicleId\":%d,\"model\":%d}",
        gCefTauCalib[playerid] ? ("true") : ("false"), charge, pct, pct, pct, legal, vehicleid, model);
    #pragma unused playerid
    return pct;
}

stock CEF_TauMeterClose(playerid)
{
    gCefTauOpen[playerid] = 0;
    gCefTauVeh[playerid] = 0;
    CEF_SendEmpty(playerid, "cef_tau_meter_close");
    CEF_Focus(playerid, false);
    return 1;
}

stock CEF_TauMeterOpen(playerid)
{
    static json[320];
    new vid, pct;
    if(!IsPlayerConnected(playerid) || !PT[playerid][pLogged]) return 0;
    CEF_TauEnsureState(playerid);
    vid = CEF_TauNearestVehicle(playerid);
    gCefTauVeh[playerid] = vid;
    gCefTauOpen[playerid] = 1;
    pct = CEF_TauBuildJson(playerid, vid, json, sizeof json);
    CEF_MarkPlayerReady(playerid);
    CEF_Send(playerid, "cef_tau_meter_open", json);
    CEF_Focus(playerid, true);
    if(!vid) CEFC_Notify(playerid, "Рядом нет машины — прибор покажет эталонные 100%.", "hint");
    else
    {
        static msg[96];
        format(msg, sizeof msg, "Светопропускание: %d%% (по ГОСТ >= 70).", pct);
        CEFC_Notify(playerid, msg, (pct >= 70) ? ("success") : ("error"));
    }
    return 1;
}


stock CEF_TauDrain(playerid)
{
    new charge;
    charge = CEF_TauEnsureState(playerid) - CEF_TAU_CHARGE_USE;
    if(charge < CEF_TAU_CHARGE_MIN) charge = CEF_TAU_CHARGE_MIN;
    gCefTauCharge[playerid] = charge;
    return charge;
}


stock CEF_TauMeterRpc(playerid, const arguments[], dest[], size)
{
    new key, vid, place, val, charge, precision;
    key = CEF_EcoFindInt(arguments, "key");
    vid = gCefTauVeh[playerid];
    if(vid <= 0) vid = CEF_TauNearestVehicle(playerid);
    if(vid > 0) gCefTauVeh[playerid] = vid;

    switch(key)
    {
        case CEF_TAU_KEY_EXIT:
        {

            CEF_TauMeterClose(playerid);
            format(dest, size, "{}");
        }
        case CEF_TAU_KEY_START:
        {

            charge = CEF_TauDrain(playerid);

            format(dest, size, "{\"chargeLevel\":%d}", charge);
        }
        case CEF_TAU_KEY_COMPLETE:
        {
            place = CEF_EcoFindInt(arguments, "id");
            val = CEF_TauReadPlace(playerid, vid, place);

            format(dest, size, "{\"result\":%d,\"percent\":%d,\"legal\":%d}",
                val, val, (val >= 70) ? (1) : (0));
            if(gCefTauOpen[playerid] && place != CEF_TAU_PLACE_CALIB)
            {
                static msg[112];
                if(val >= 70) format(msg, sizeof msg, "Тау-метр: %d%% — норма (ГОСТ >= 70).", val);
                else format(msg, sizeof msg, "Тау-метр: %d%% — тонировка ниже нормы (ГОСТ >= 70).", val);
                CEFC_Notify(playerid, msg, (val >= 70) ? ("success") : ("error"));
            }
        }
        case CEF_TAU_KEY_CALIB_DONE:
        {

            precision = CEF_EcoFindInt(arguments, "precision");
            if(precision < 0) precision = 0;
            if(precision > 100) precision = 100;

            gCefTauCalib[playerid] = (precision >= 60) ? (1) : (0);
            format(dest, size, "{\"isCalibrated\":%s,\"precision\":%d}",
                gCefTauCalib[playerid] ? ("true") : ("false"), precision);
            if(gCefTauOpen[playerid])
            {
                if(gCefTauCalib[playerid]) CEFC_Notify(playerid, "Прибор откалиброван.", "success");
                else CEFC_Notify(playerid, "Калибровка неудачная — прибор не откалиброван.", "error");
            }
        }
        case CEF_TAU_KEY_GLASS:
        {
            place = CEF_EcoFindInt(arguments, "id");
            format(dest, size, "{\"selected\":%d}", place);
        }
        default:
        {

            format(dest, size, "{\"ok\":0,\"key\":%d}", key);
        }
    }


    if(gCefTauOpen[playerid] && key != CEF_TAU_KEY_EXIT)
    {
        static json[320];
        CEF_TauBuildJson(playerid, vid, json, sizeof json);
        CEF_Send(playerid, "cef_tau_meter_open", json);
    }
    return 1;
}

CMD:taumeter(playerid, params[])
{
    #pragma unused params
    if(!PT[playerid][pLogged]) return 1;
    return CEF_TauMeterOpen(playerid);
}

CMD:testtau(playerid, params[])
{
    #pragma unused params
    if(!PT[playerid][pLogged]) return 1;
    return CEF_TauMeterOpen(playerid);
}


CMD:taucharge(playerid, params[])
{
    new lvl, err[64];
    if(PI[playerid][pAdmin] < 1)
    {
        err = "Команда только для админов";
        return SendErr(playerid, err);
    }
    if(sscanf(params, "d", lvl))
    {
        err = "/taucharge [0-100]  (заряд тау-метра)";
        return SendErr(playerid, err);
    }
    if(lvl < CEF_TAU_CHARGE_MIN) lvl = CEF_TAU_CHARGE_MIN;
    if(lvl > CEF_TAU_CHARGE_MAX) lvl = CEF_TAU_CHARGE_MAX;
    gCefTauCharge[playerid] = lvl;
    CEFC_Notify(playerid, "Заряд тау-метра обновлён.", "success");
    if(gCefTauOpen[playerid]) CEF_TauMeterOpen(playerid);
    return 1;
}


CMD:taucalib(playerid, params[])
{
    new flag, err[64];
    if(PI[playerid][pAdmin] < 1)
    {
        err = "Команда только для админов";
        return SendErr(playerid, err);
    }
    if(sscanf(params, "d", flag))
    {
        err = "/taucalib [0|1]  (0 — сбросить, 1 — откалиброван)";
        return SendErr(playerid, err);
    }
    gCefTauCalib[playerid] = flag ? 1 : 0;
    CEFC_Notify(playerid, flag ? "Прибор откалиброван (принудительно)." : "Калибровка сброшена.", "success");
    if(gCefTauOpen[playerid]) CEF_TauMeterOpen(playerid);
    return 1;
}

CMD:settint(playerid, params[])
{
    new pct, vid, err[64];
    if(PI[playerid][pAdmin] < 1 && PI[playerid][pFraction] != FRACTION_TRAFFIC_PATROL_POLICE)
    {
        err = "Команда не для вас";
        return SendErr(playerid, err);
    }
    if(sscanf(params, "d", pct))
    {
        err = "/settint [0-100]  (светопропускание %)";
        return SendErr(playerid, err);
    }
    vid = CEF_TauNearestVehicle(playerid);
    if(!vid)
    {
        err = "Рядом нет машины";
        return SendErr(playerid, err);
    }
    CEF_TintSetPercent(vid, pct);
    CEFC_Notify(playerid, "Тонировка обновлена на всех.", "success");
    if(gCefTauOpen[playerid]) CEF_TauMeterOpen(playerid);
    return 1;
}
