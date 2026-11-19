  
                                                                
                                                               
  
                
                                                                          
                                                        
                                                         
                                                       
  
                                                        
            
                                                                          
                                                      
            
  
                                                            
   

#if defined _cef_hud_included
	#endinput
#endif
#define _cef_hud_included

#include <a_samp>
#include <cef>

#define CEF_HUD_BROWSER_ID  9700
#define CEF_HUD_TICK_MS     100

static stock bool:GH_CefHudReady[MAX_PLAYERS];
static stock bool:GH_CefHudInVeh[MAX_PLAYERS];
static stock GH_CefHudLastFuel[MAX_PLAYERS];
static stock GH_CefHudLastState[MAX_PLAYERS];
static stock GH_CefHudTimer = -1;

forward Float:CefHud_GetVehicleFuel(vehicleid);
stock Float:CefHud_ReadFuel(vehicleid)
{
	if (funcidx("CefHud_GetVehicleFuel") == -1) return -1.0;
	new r = CallLocalFunction("CefHud_GetVehicleFuel", "i", vehicleid);
	return Float:r;
}

                                                                       
public OnCefInitialize(player_id, success)
{
	if (!success)
	{
		GH_CefHudReady[player_id] = false;
		return 1;
	}

	GH_CefHudReady[player_id] = true;
	GH_CefHudInVeh[player_id] = false;
	GH_CefHudLastFuel[player_id] = cellmin;
	GH_CefHudLastState[player_id] = cellmin;

	cef_create_browser(player_id, CEF_HUD_BROWSER_ID, "speedometer/index.html", false, false);

	if (GH_CefHudTimer == -1)
		GH_CefHudTimer = SetTimer("CefHud_Tick", CEF_HUD_TICK_MS, true);

	                                                    
	if (funcidx("OnCefInvReady") != -1)
		CallLocalFunction("OnCefInvReady", "ii", player_id, success);
	if (funcidx("OnCefCaseReady") != -1)
		CallLocalFunction("OnCefCaseReady", "ii", player_id, success);

	return 1;
}

                                      
public OnCefBrowserCreated(player_id, browser_id, status_code)
{
	                                                            
	                                                      
	return 1;
}

forward CefHud_Tick();
public CefHud_Tick()
{
	new Float:v[3];

	for (new i = 0; i < MAX_PLAYERS; i++)
	{
		if (!GH_CefHudReady[i] || !IsPlayerConnected(i)) continue;

		new vid = GetPlayerVehicleID(i);

		if (vid == 0 || GetPlayerVehicleSeat(i) != 0)
		{
			if (GH_CefHudInVeh[i])
			{
				GH_CefHudInVeh[i] = false;
				cef_emit_event(i, "hud:vehicle",
					CEFFLOAT(0.0), CEFINT(0), CEFINT(0), CEFFLOAT(0.0),
					CEFINT(0), CEFINT(0), CEFINT(0), CEFINT(0));
			}
			continue;
		}

		GH_CefHudInVeh[i] = true;

		GetVehicleVelocity(vid, v[0], v[1], v[2]);
		new Float:kmh = floatsqroot(v[0]*v[0] + v[1]*v[1] + v[2]*v[2]) * 180.0;

		cef_emit_event(i, "hud:vehicle",
			CEFFLOAT(kmh), CEFINT(1), CEFINT(1), CEFFLOAT(GetVehicleHealth(vid)),
			CEFINT(1), CEFINT(GetVehicleModel(vid)), CEFINT(0), CEFINT(1));

		new Float:f = CefHud_ReadFuel(vid);
		new fi = floatround(f);

		if (fi != GH_CefHudLastFuel[i])
		{
			GH_CefHudLastFuel[i] = fi;
			cef_emit_event(i, "hud:fuel", CEFFLOAT(f));
		}

		new eng, lgt, alm, drs, bnt, bot, obj;
		GetVehicleParamsEx(vid, eng, lgt, alm, drs, bnt, bot, obj);
		new st = (eng + 1) + (lgt + 1) * 3 + (drs + 1) * 9;
		if (st != GH_CefHudLastState[i])
		{
			GH_CefHudLastState[i] = st;
			cef_emit_event(i, "hud:state", CEFINT(eng), CEFINT(lgt), CEFINT(drs));
		}
	}
}