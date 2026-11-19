
forward DebugPosTick(playerid, tick);
public DebugPosTick(playerid, tick)
{
    if(!IsPlayerConnected(playerid)) return 1;

    new Float:px, Float:py, Float:pz;
    new Float:cx, Float:cy, Float:cz;
    new Float:fx, Float:fy, Float:fz;

    GetPlayerPos(playerid, px, py, pz);
    GetPlayerCameraPos(playerid, cx, cy, cz);
    GetPlayerCameraFrontVector(playerid, fx, fy, fz);

    printf("[DEBUGPOS] t=%04d tick=%d pos=(%.2f,%.2f,%.2f) cam=(%.2f,%.2f,%.2f) front=(%.3f,%.3f,%.3f) world=%d camMode=%d logged=%d cefLoaded=%d",
        tick * 200, GetTickCount(),
        px, py, pz,
        cx, cy, cz,
        fx, fy, fz,
        GetPlayerVirtualWorld(playerid),
        GetPlayerCameraMode(playerid),
        PT[playerid][pLogged],
        PT[playerid][pCefLoaded]);

    if(tick < 50)
        SetTimerEx("DebugPosTick", 200, false, "ii", playerid, tick + 1);
    return 1;
}
