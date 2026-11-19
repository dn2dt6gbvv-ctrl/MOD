#if defined _DYNAMIC_DOORS_INCLUDED
    #endinput
#endif
#define _DYNAMIC_DOORS_INCLUDED

#define MAX_DYN_DOORS           256
#define DD_TYPE_DOOR            0
#define DD_TYPE_GATE            1
#define DD_TYPE_BARRIER         2
#define DOOR_SWING_SPEED        3.0
#define GATE_MOVE_SPEED         2.2
#define BARRIER_MOVE_SPEED      2.8
#define DOOR_INTERACT_RADIUS    2.80
#define GATE_INTERACT_RADIUS    10.0
#define DOOR_HINT_RADIUS        3.20
#define GATE_HINT_RADIUS        12.0
#define GATE_DEFAULT_DIST       6.50
#define DOOR_SWING_ANGLE        90.0

enum E_DYN_DOOR
{
    dd_ID,
    dd_Name[64],
    dd_Model,
    dd_Type,
    dd_Side,
    Float:dd_Speed,
    Float:dd_X,
    Float:dd_Y,
    Float:dd_Z,
    Float:dd_RX,
    Float:dd_RY,
    Float:dd_RZ,
    Float:dd_OpenX,
    Float:dd_OpenY,
    Float:dd_OpenZ,
    Float:dd_OpenRX,
    Float:dd_OpenRY,
    Float:dd_OpenRZ,
    dd_FractionID,
    dd_VW,
    dd_Interior,
    dd_Object,
    dd_Area,
    bool:dd_IsOpen,
    bool:dd_Moving
}

new g_Doors[MAX_DYN_DOORS][E_DYN_DOOR];
new g_DoorCount = 0;
new g_DoorEditIdx[MAX_PLAYERS] = {-1, ...};
new g_DoorEditKind[MAX_PLAYERS];
new g_DoorHintIdx[MAX_PLAYERS] = {-1, ...};
new g_DoorSeedCursor = 0;
new bool:g_DoorSeedAttempted = false;

enum E_DD_SEED
{
    dds_model,
    Float:dds_x,
    Float:dds_y,
    Float:dds_z,
    Float:dds_rx,
    Float:dds_ry,
    Float:dds_rz,
    dds_frac,
    dds_side
}

static const DynDoorSeed[][E_DD_SEED] =
{
    {11963, 1608.6390, 1204.5400, 1662.7900, 0.0000, -0.0000, 0.0000, 2, 1},
    {11963, 1618.9970, 1204.5370, 1662.8070, 0.0000, -0.0000, 0.0000, 2, 1},
    {11963, 1620.3540, 1199.3010, 1662.7970, 0.0000, -0.0000, 179.4583, 2, 1},
    {11963, 1628.8680, 1204.5200, 1662.7970, 0.0000, 0.0000, 180.0000, 2, 1},
    {11963, 1627.5190, 1199.3420, 1662.8070, 0.0000, -0.0000, 0.0000, 2, 1},
    {11963, 1636.0470, 1204.5140, 1662.8170, 0.0000, -0.0000, 0.0000, 2, 1},
    {11963, 1636.0570, 1199.3480, 1662.7970, 0.0000, -0.0000, 0.0000, 2, 1},
    {7499, 1426.3251, -2019.7889, 1955.4281, 0.0000, -0.0000, 0.0000, 0, 1},
    {7499, 1432.9552, -2014.7777, 1955.4286, 0.0000, 0.0000, -90.0000, 0, 1},
    {17618, -1786.6092, -1890.2264, 1603.2373, 0.0000, 0.0000, -90.0000, 0, 1},
    {17618, -1789.1046, -1888.8278, 1603.2371, 0.0000, -0.0000, 0.0000, 0, 1},
    {17618, -1769.2056, -1888.8231, 1603.2368, 0.0000, -0.0000, 0.0000, 0, 1},
    {17618, -1762.7040, -1888.8254, 1603.2305, 0.0000, -0.0000, 0.0000, 0, 1},
    {17618, -1762.7039, -1891.4930, 1603.2302, 0.0000, -0.0000, 0.0000, 0, 1},
    {17618, -1762.7037, -1886.1575, 1603.2304, 0.0000, -0.0000, 0.0000, 0, 1},
    {17618, -1783.7082, -1886.2263, 1603.2372, 0.0000, -0.0000, 90.0000, 0, 1},
    {17618, -1775.7082, -1886.2264, 1603.2368, 0.0000, -0.0000, 90.0000, 0, 1},
    {17618, -1778.6095, -1890.2295, 1603.2368, 0.0000, 0.0000, -90.0000, 0, 1},
    {17618, -1794.9840, -1892.8248, 1603.2374, 0.0000, 0.0000, 0.0000, 0, 1},
    {12576, 845.8531, 1012.3784, 2501.3403, 0.0000, 0.0000, -90.0000, 6, 1},
    {12576, 879.4763, 1014.7259, 2501.3403, 0.0000, -0.0000, 180.0000, 6, 1},
    {12576, 873.4832, 1014.7259, 2501.3403, 0.0000, -0.0000, 180.0000, 6, 1},
    {17082, -694.3277, 160.3535, 1501.2947, 0.0000, -0.0000, 0.0000, 6, 1},
    {18419, 1540.2007, 810.2416, 1901.3258, 0.0000, 0.0000, -90.0000, 4, 1},
    {18419, 1571.5095, 830.2480, 1901.3258, 0.0000, -0.0000, 0.0000, 4, 1},
    {18419, 1532.9081, 810.2416, 1901.3258, 0.0000, 0.0000, -90.0000, 4, 1},
    {18419, 1529.1454, 811.7900, 1901.3258, 0.0000, -0.0000, 180.0000, 4, 1},
    {18419, 1536.5654, 816.2042, 1901.3258, 0.0000, 0.0000, -90.0000, 4, 1},
    {18419, 1571.5095, 822.8838, 1901.3258, 0.0000, -0.0000, 0.0000, 4, 1},
    {18419, 1557.0245, 813.0119, 1901.3258, 0.0000, -0.0000, 0.0000, 4, 1},
    {18419, 1544.9795, 813.0129, 1901.3258, 0.0000, -0.0000, 0.0000, 4, 1},
    {18419, 1561.7163, 813.3396, 1901.3258, 0.0000, 0.0000, -90.0000, 4, 1},
    {18419, 1571.5095, 810.1204, 1901.3258, 0.0000, -0.0000, 0.0000, 4, 1},
    {18419, 1565.9419, 810.1309, 1901.3258, 0.0000, -0.0000, 0.0000, 4, 1},
    {18417, 1293.8573, 1063.4755, 2161.3333, 0.0000, -0.0000, 90.0000, 3, 1},
    {18417, 1285.0804, 1058.9205, 2161.3333, 0.0000, -0.0000, 90.0000, 3, 1},
    {18417, 1285.0804, 1063.4901, 2161.3333, 0.0000, -0.0000, 90.0000, 3, 1},
    {18417, 1293.7712, 1057.1149, 2161.3333, 0.0000, -0.0000, 0.0000, 3, 1},
    {18417, 1312.6605, 1057.1155, 2161.3333, 0.0000, -0.0000, 0.0000, 3, 1},
    {18417, 1316.8901, 1064.4008, 2161.3333, 0.0000, -0.0000, 0.0000, 3, 1},
    {18417, 1297.9595, 1062.1174, 2161.3333, 0.0000, -0.0000, 0.0000, 3, 1},
    {18413, 1122.1128, 1461.2446, 2161.3633, 0.0000, -0.0000, 0.0000, 5, 1},
    {18413, 1095.3351, 1463.1772, 2161.3633, 0.0000, -0.0000, 90.0000, 5, 1},
    {18413, 1095.3339, 1457.0940, 2161.3633, 0.0000, -0.0000, 90.0000, 5, 1},
    {18413, 1079.1436, 1457.0940, 2161.3633, 0.0000, -0.0000, 90.0000, 5, 1},
    {18413, 1142.8185, 1457.0940, 2161.3633, 0.0000, -0.0000, 90.0000, 5, 1},
    {18413, 1126.6312, 1457.0940, 2161.3633, 0.0000, -0.0000, 90.0000, 5, 1},
    {18413, 1126.6338, 1463.1772, 2161.3633, 0.0000, -0.0000, 90.0000, 5, 1},
    {18413, 1142.8185, 1463.1772, 2161.3633, 0.0000, -0.0000, 90.0000, 5, 1},
    {18413, 1079.1436, 1463.1772, 2161.3633, 0.0000, -0.0000, 90.0000, 5, 1},
    {18413, 1097.6616, 1461.2432, 2161.3633, 0.0000, -0.0000, 0.0000, 5, 1},
    {18414, 1097.6616, 1458.9851, 2161.3635, 0.0000, -0.0000, 0.0000, 5, 1},
    {18414, 1140.5604, 1463.1772, 2161.3635, 0.0000, -0.0000, 90.0000, 5, 1},
    {18414, 1124.3732, 1457.0940, 2161.3635, 0.0000, -0.0000, 90.0000, 5, 1},
    {18414, 1122.1128, 1458.9866, 2161.3635, 0.0000, -0.0000, 0.0000, 5, 1},
    {18414, 1124.3757, 1463.1772, 2161.3635, 0.0000, -0.0000, 90.0000, 5, 1},
    {18414, 1076.8855, 1463.1772, 2161.3635, 0.0000, -0.0000, 90.0000, 5, 1},
    {18414, 1093.0758, 1457.0940, 2161.3635, 0.0000, -0.0000, 90.0000, 5, 1},
    {18414, 1076.8855, 1457.0940, 2161.3635, 0.0000, -0.0000, 90.0000, 5, 1},
    {18414, 1093.0770, 1463.1772, 2161.3635, 0.0000, -0.0000, 90.0000, 5, 1},
    {18414, 1140.5604, 1457.0940, 2161.3635, 0.0000, -0.0000, 90.0000, 5, 1},
    {18415, 1105.8117, 1477.6883, 2161.3635, 0.0000, 0.0000, -90.0000, 5, 1},
    {18415, 1103.3910, 1480.2651, 2161.3633, 0.0000, -0.0000, 0.0000, 5, 1},
    {18415, 1153.1149, 1463.2064, 2161.3630, 0.0000, -0.0000, 0.0000, 5, 1}
};

static const DynDoor_RemoveModels[] = {
    11963, 18417, 18419, 18413, 18414, 18415, 12576, 7499, 17082, 17618, 7398, 17606, 17610
};

stock Float:DynDoor_NormAngle(Float:a)
{
    while(a >= 360.0) a -= 360.0;
    while(a < 0.0) a += 360.0;
    return a;
}

stock Float:DynDoor_Radius(idx)
{
    if(g_Doors[idx][dd_Type] == DD_TYPE_DOOR) return DOOR_INTERACT_RADIUS;
    return GATE_INTERACT_RADIUS;
}

stock Float:DynDoor_HintRadius(idx)
{
    if(g_Doors[idx][dd_Type] == DD_TYPE_DOOR) return DOOR_HINT_RADIUS;
    return GATE_HINT_RADIUS;
}

stock Float:DynDoor_DefaultSpeed(type)
{
    if(type == DD_TYPE_GATE) return GATE_MOVE_SPEED;
    if(type == DD_TYPE_BARRIER) return BARRIER_MOVE_SPEED;
    return DOOR_SWING_SPEED;
}

stock DynDoor_TypeName(type, dest[], size)
{
    if(type == DD_TYPE_GATE) format(dest, size, "ворота");
    else if(type == DD_TYPE_BARRIER) format(dest, size, "шлагбаум");
    else format(dest, size, "дверь");
    return 1;
}

stock DynDoor_NameByModel(model, dest[], size)
{
    switch(model)
    {
        case 11963: format(dest, size, "Дверь ФСБ");
        case 18417, 18593: format(dest, size, "Дверь ДПС");
        case 18419, 18591, 18418: format(dest, size, "Дверь ППС");
        case 18413, 18414, 18415, 18592: format(dest, size, "Дверь ЕСС");
        case 12576, 17082, 11389: format(dest, size, "Дверь ВЧ");
        case 7398: format(dest, size, "Дверь КПЗ");
        case 7499, 17606, 17610, 17618: format(dest, size, "Дверь ФСИН");
        case 5288, 5289: format(dest, size, "Ворота ФСБ");
        case 14090, 14091, 14092, 14093, 12549: format(dest, size, "Ворота ВЧ");
        case 5157: format(dest, size, "Ворота полиции");
        case 5158, 11499, 11383: format(dest, size, "Шлагбаум");
        default: format(dest, size, "Дверь");
    }
    return 1;
}

stock DynDoor_ComputeOpen(idx)
{
    new type = g_Doors[idx][dd_Type];
    new Float:x = g_Doors[idx][dd_X], Float:y = g_Doors[idx][dd_Y], Float:z = g_Doors[idx][dd_Z];
    new Float:rx = g_Doors[idx][dd_RX], Float:ry = g_Doors[idx][dd_RY], Float:rz = g_Doors[idx][dd_RZ];
    new side = g_Doors[idx][dd_Side];
    if(side == 0) side = 1;

    if(type == DD_TYPE_DOOR)
    {
        g_Doors[idx][dd_OpenX] = x + 0.004;
        g_Doors[idx][dd_OpenY] = y;
        g_Doors[idx][dd_OpenZ] = z;
        g_Doors[idx][dd_OpenRX] = rx;
        g_Doors[idx][dd_OpenRY] = ry;
        g_Doors[idx][dd_OpenRZ] = DynDoor_NormAngle(rz + DOOR_SWING_ANGLE * float(side));
    }
    else if(type == DD_TYPE_BARRIER)
    {
        g_Doors[idx][dd_OpenX] = x + 0.004;
        g_Doors[idx][dd_OpenY] = y;
        g_Doors[idx][dd_OpenZ] = z;
        g_Doors[idx][dd_OpenRX] = rx - 80.0;
        g_Doors[idx][dd_OpenRY] = ry;
        g_Doors[idx][dd_OpenRZ] = rz;
    }
    else
    {
        new Float:dist = GATE_DEFAULT_DIST;
        g_Doors[idx][dd_OpenX] = x + dist * floatsin(-rz, degrees);
        g_Doors[idx][dd_OpenY] = y + dist * floatcos(-rz, degrees);
        g_Doors[idx][dd_OpenZ] = z;
        g_Doors[idx][dd_OpenRX] = rx;
        g_Doors[idx][dd_OpenRY] = ry;
        g_Doors[idx][dd_OpenRZ] = rz;
    }
    return 1;
}

stock DynDoor_OnPlayerConnect(playerid)
{
    g_DoorEditIdx[playerid] = -1;
    g_DoorEditKind[playerid] = 0;
    g_DoorHintIdx[playerid] = -1;
    for(new i = 0; i < sizeof(DynDoor_RemoveModels); i++)
        RemoveBuildingForPlayer(playerid, DynDoor_RemoveModels[i], 0.0, 0.0, 0.0, 20000.0);
    return 1;
}

stock DynDoor_ResetSlot(idx)
{
    g_Doors[idx][dd_ID] = 0;
    g_Doors[idx][dd_Name][0] = EOS;
    g_Doors[idx][dd_Model] = 0;
    g_Doors[idx][dd_Type] = DD_TYPE_DOOR;
    g_Doors[idx][dd_Side] = 1;
    g_Doors[idx][dd_Speed] = DOOR_SWING_SPEED;
    g_Doors[idx][dd_X] = 0.0;
    g_Doors[idx][dd_Y] = 0.0;
    g_Doors[idx][dd_Z] = 0.0;
    g_Doors[idx][dd_RX] = 0.0;
    g_Doors[idx][dd_RY] = 0.0;
    g_Doors[idx][dd_RZ] = 0.0;
    g_Doors[idx][dd_OpenX] = 0.0;
    g_Doors[idx][dd_OpenY] = 0.0;
    g_Doors[idx][dd_OpenZ] = 0.0;
    g_Doors[idx][dd_OpenRX] = 0.0;
    g_Doors[idx][dd_OpenRY] = 0.0;
    g_Doors[idx][dd_OpenRZ] = 0.0;
    g_Doors[idx][dd_FractionID] = 0;
    g_Doors[idx][dd_VW] = -1;
    g_Doors[idx][dd_Interior] = -1;
    g_Doors[idx][dd_Object] = 0;
    g_Doors[idx][dd_Area] = -1;
    g_Doors[idx][dd_IsOpen] = false;
    g_Doors[idx][dd_Moving] = false;
    return 1;
}

stock DynDoor_FindById(doorid)
{
    for(new i = 0; i < g_DoorCount; i++)
    {
        if(g_Doors[i][dd_ID] == doorid) return i;
    }
    return -1;
}

stock DynDoor_FindByObject(objectid)
{
    if(objectid <= 0) return -1;
    for(new i = 0; i < g_DoorCount; i++)
    {
        if(g_Doors[i][dd_Object] == objectid) return i;
    }
    return -1;
}

stock DynDoor_DestroyObject(idx)
{
    if(idx < 0 || idx >= MAX_DYN_DOORS) return 0;
    if(g_Doors[idx][dd_Object] > 0)
    {
        DestroyDynamicObject(g_Doors[idx][dd_Object]);
        g_Doors[idx][dd_Object] = 0;
    }
    if(g_Doors[idx][dd_Area] != -1)
    {
        DestroyDynamicArea(g_Doors[idx][dd_Area]);
        g_Doors[idx][dd_Area] = -1;
    }
    g_Doors[idx][dd_IsOpen] = false;
    g_Doors[idx][dd_Moving] = false;
    return 1;
}

stock DynDoor_CanOpen(playerid, idx)
{
    if(!PT[playerid][pLogged]) return 0;
    if(GetAdminLevel(playerid, 1)) return 1;
    new frac = g_Doors[idx][dd_FractionID];
    if(frac <= 0) return 1;
    if(PI[playerid][pFraction] == frac) return 1;
    return 0;
}

stock DynDoor_Spawn(idx)
{
    if(idx < 0 || idx >= g_DoorCount) return 0;
    DynDoor_DestroyObject(idx);

    new vw = g_Doors[idx][dd_VW];
    new interior = g_Doors[idx][dd_Interior];

    g_Doors[idx][dd_Object] = CreateDynamicObject(
        g_Doors[idx][dd_Model],
        g_Doors[idx][dd_X], g_Doors[idx][dd_Y], g_Doors[idx][dd_Z],
        g_Doors[idx][dd_RX], g_Doors[idx][dd_RY], g_Doors[idx][dd_RZ],
        vw, interior, -1, 200.0, 200.0
    );
    g_Doors[idx][dd_Area] = CreateDynamicSphere(
        g_Doors[idx][dd_X], g_Doors[idx][dd_Y], g_Doors[idx][dd_Z],
        DynDoor_HintRadius(idx), vw, interior, -1
    );
    g_Doors[idx][dd_IsOpen] = false;
    g_Doors[idx][dd_Moving] = false;
    return 1;
}

stock DynDoor_ShowHint(playerid)
{
    cef_emit_event(playerid, "game:ShowHint", CEFSTR("E"), CEFINT(2500));
    return 1;
}

stock DynDoor_OnEnterArea(playerid, areaid)
{
    if(!PT[playerid][pLogged]) return 0;
    for(new i = 0; i < g_DoorCount; i++)
    {
        if(g_Doors[i][dd_Area] == areaid && g_Doors[i][dd_Area] != -1)
        {
            g_DoorHintIdx[playerid] = i;
            DynDoor_ShowHint(playerid);
            return 1;
        }
    }
    return 0;
}

stock DynDoor_HintTick(playerid)
{
    if(!IsPlayerConnected(playerid) || !PT[playerid][pLogged]) return 0;
    new pstate = GetPlayerState(playerid);
    if(pstate != PLAYER_STATE_ONFOOT && pstate != PLAYER_STATE_DRIVER) return 0;

    new vw = GetPlayerVirtualWorld(playerid);
    new interior = GetPlayerInterior(playerid);
    new nearest = -1;
    new Float:best = 99999.0;

    for(new i = 0; i < g_DoorCount; i++)
    {
        if(g_Doors[i][dd_Object] <= 0) continue;
        if(g_Doors[i][dd_VW] != -1 && g_Doors[i][dd_VW] != vw) continue;
        if(g_Doors[i][dd_Interior] != -1 && g_Doors[i][dd_Interior] != interior) continue;
        if(g_Doors[i][dd_Type] == DD_TYPE_DOOR && pstate != PLAYER_STATE_ONFOOT) continue;

        new Float:d1 = GetPlayerDistanceFromPoint(playerid, g_Doors[i][dd_X], g_Doors[i][dd_Y], g_Doors[i][dd_Z]);
        new Float:d2 = GetPlayerDistanceFromPoint(playerid, g_Doors[i][dd_OpenX], g_Doors[i][dd_OpenY], g_Doors[i][dd_OpenZ]);
        new Float:d = d1;
        if(d2 < d) d = d2;
        if(d <= DynDoor_HintRadius(i) && d < best)
        {
            best = d;
            nearest = i;
        }
    }

    if(nearest == -1)
    {
        g_DoorHintIdx[playerid] = -1;
        return 0;
    }
    g_DoorHintIdx[playerid] = nearest;
    DynDoor_ShowHint(playerid);
    return 1;
}

stock DynDoor_Toggle(playerid, idx)
{
    if(idx < 0 || idx >= g_DoorCount) return 0;
    if(g_Doors[idx][dd_Object] <= 0) return 0;
    if(g_Doors[idx][dd_Moving]) return 1;

    new Float:speed = g_Doors[idx][dd_Speed];
    if(speed < 0.4) speed = DynDoor_DefaultSpeed(g_Doors[idx][dd_Type]);

    new msg[96];
    if(!g_Doors[idx][dd_IsOpen])
    {
        MoveDynamicObject(g_Doors[idx][dd_Object],
            g_Doors[idx][dd_OpenX], g_Doors[idx][dd_OpenY], g_Doors[idx][dd_OpenZ],
            speed,
            g_Doors[idx][dd_OpenRX], g_Doors[idx][dd_OpenRY], g_Doors[idx][dd_OpenRZ]);
        g_Doors[idx][dd_IsOpen] = true;
        g_Doors[idx][dd_Moving] = true;
        format(msg, sizeof(msg), "[Дверь] %s открыт(а). Нажмите E, чтобы закрыть.", g_Doors[idx][dd_Name]);
        CEFChat_Send(playerid, "54B367", msg);
    }
    else
    {
        MoveDynamicObject(g_Doors[idx][dd_Object],
            g_Doors[idx][dd_X], g_Doors[idx][dd_Y], g_Doors[idx][dd_Z],
            speed,
            g_Doors[idx][dd_RX], g_Doors[idx][dd_RY], g_Doors[idx][dd_RZ]);
        g_Doors[idx][dd_IsOpen] = false;
        g_Doors[idx][dd_Moving] = true;
        format(msg, sizeof(msg), "[Дверь] %s закрыт(а).", g_Doors[idx][dd_Name]);
        CEFChat_Send(playerid, "FF4444", msg);
    }
    PlayerPlaySound(playerid, 1130, 0.0, 0.0, 0.0);
    return 1;
}

stock DynDoor_TryUse(playerid)
{
    if(!IsPlayerConnected(playerid) || !PT[playerid][pLogged]) return 0;
    new pstate = GetPlayerState(playerid);
    if(pstate != PLAYER_STATE_ONFOOT && pstate != PLAYER_STATE_DRIVER) return 0;

    new vw = GetPlayerVirtualWorld(playerid);
    new interior = GetPlayerInterior(playerid);
    new nearest = -1;
    new Float:best = 99999.0;

    for(new i = 0; i < g_DoorCount; i++)
    {
        if(g_Doors[i][dd_Object] <= 0) continue;
        if(g_Doors[i][dd_VW] != -1 && g_Doors[i][dd_VW] != vw) continue;
        if(g_Doors[i][dd_Interior] != -1 && g_Doors[i][dd_Interior] != interior) continue;
        if(g_Doors[i][dd_Type] == DD_TYPE_DOOR && pstate != PLAYER_STATE_ONFOOT) continue;

        new Float:d1 = GetPlayerDistanceFromPoint(playerid, g_Doors[i][dd_X], g_Doors[i][dd_Y], g_Doors[i][dd_Z]);
        new Float:d2 = GetPlayerDistanceFromPoint(playerid, g_Doors[i][dd_OpenX], g_Doors[i][dd_OpenY], g_Doors[i][dd_OpenZ]);
        new Float:d = d1;
        if(d2 < d) d = d2;
        if(d <= DynDoor_Radius(i) && d < best)
        {
            best = d;
            nearest = i;
        }
    }

    if(nearest == -1) return 0;
    if(!DynDoor_CanOpen(playerid, nearest))
    {
        CEFChat_Send(playerid, "FF4444", "У вас нет доступа к этой двери.");
        return 1;
    }
    DynDoor_Toggle(playerid, nearest);
    return 1;
}

stock DynDoor_ClearAll()
{
    for(new i = 0; i < g_DoorCount; i++) DynDoor_DestroyObject(i);
    g_DoorCount = 0;
    return 1;
}

stock InitDynamicDoors()
{
    mysql_tquery(dbHandle, "CREATE TABLE IF NOT EXISTS `dynamic_doors` (\
        `id` INT NOT NULL AUTO_INCREMENT,\
        `name` VARCHAR(64) NOT NULL DEFAULT 'Дверь',\
        `model` INT NOT NULL DEFAULT 11963,\
        `type` TINYINT NOT NULL DEFAULT 0,\
        `side` TINYINT NOT NULL DEFAULT 1,\
        `speed` FLOAT NOT NULL DEFAULT 3.0,\
        `x` FLOAT NOT NULL DEFAULT 0,\
        `y` FLOAT NOT NULL DEFAULT 0,\
        `z` FLOAT NOT NULL DEFAULT 0,\
        `rx` FLOAT NOT NULL DEFAULT 0,\
        `ry` FLOAT NOT NULL DEFAULT 0,\
        `rz` FLOAT NOT NULL DEFAULT 0,\
        `open_x` FLOAT NOT NULL DEFAULT 0,\
        `open_y` FLOAT NOT NULL DEFAULT 0,\
        `open_z` FLOAT NOT NULL DEFAULT 0,\
        `open_rx` FLOAT NOT NULL DEFAULT 0,\
        `open_ry` FLOAT NOT NULL DEFAULT 0,\
        `open_rz` FLOAT NOT NULL DEFAULT 0,\
        `fraction_id` INT NOT NULL DEFAULT 0,\
        `vw` INT NOT NULL DEFAULT -1,\
        `interior` INT NOT NULL DEFAULT -1,\
        PRIMARY KEY (`id`)\
    ) ENGINE=InnoDB DEFAULT CHARSET=cp1251 COLLATE=cp1251_general_ci;", "DynDoors_OnSchema", "");
    return 1;
}

forward DynDoors_OnSchema();
public DynDoors_OnSchema()
{
    mysql_tquery(dbHandle, "ALTER TABLE `dynamic_doors` ADD COLUMN `type` TINYINT NOT NULL DEFAULT 0", "DynDoors_OnAlter1", "");
    return 1;
}

forward DynDoors_OnAlter1();
public DynDoors_OnAlter1()
{
    mysql_tquery(dbHandle, "ALTER TABLE `dynamic_doors` ADD COLUMN `side` TINYINT NOT NULL DEFAULT 1", "DynDoors_OnAlter2", "");
    return 1;
}

forward DynDoors_OnAlter2();
public DynDoors_OnAlter2()
{
    mysql_tquery(dbHandle, "ALTER TABLE `dynamic_doors` ADD COLUMN `speed` FLOAT NOT NULL DEFAULT 3.0", "DynDoors_OnAlter3", "");
    return 1;
}

forward DynDoors_OnAlter3();
public DynDoors_OnAlter3()
{
    mysql_tquery(dbHandle, "SELECT * FROM `dynamic_doors` ORDER BY `id` ASC", "OnDynDoorsLoaded", "");
    return 1;
}

forward LoadDynamicDoors();
public LoadDynamicDoors()
{
    mysql_tquery(dbHandle, "SELECT * FROM `dynamic_doors` ORDER BY `id` ASC", "OnDynDoorsLoaded", "");
    return 1;
}

stock DynDoor_ApplyRow(row, idx)
{
    cache_get_value_name_int(row, "id", g_Doors[idx][dd_ID]);
    cache_get_value_name(row, "name", g_Doors[idx][dd_Name], 64);
    cache_get_value_name_int(row, "model", g_Doors[idx][dd_Model]);
    cache_get_value_name_int(row, "type", g_Doors[idx][dd_Type]);
    cache_get_value_name_int(row, "side", g_Doors[idx][dd_Side]);
    cache_get_value_name_float(row, "speed", g_Doors[idx][dd_Speed]);
    cache_get_value_name_float(row, "x", g_Doors[idx][dd_X]);
    cache_get_value_name_float(row, "y", g_Doors[idx][dd_Y]);
    cache_get_value_name_float(row, "z", g_Doors[idx][dd_Z]);
    cache_get_value_name_float(row, "rx", g_Doors[idx][dd_RX]);
    cache_get_value_name_float(row, "ry", g_Doors[idx][dd_RY]);
    cache_get_value_name_float(row, "rz", g_Doors[idx][dd_RZ]);
    cache_get_value_name_float(row, "open_x", g_Doors[idx][dd_OpenX]);
    cache_get_value_name_float(row, "open_y", g_Doors[idx][dd_OpenY]);
    cache_get_value_name_float(row, "open_z", g_Doors[idx][dd_OpenZ]);
    cache_get_value_name_float(row, "open_rx", g_Doors[idx][dd_OpenRX]);
    cache_get_value_name_float(row, "open_ry", g_Doors[idx][dd_OpenRY]);
    cache_get_value_name_float(row, "open_rz", g_Doors[idx][dd_OpenRZ]);
    cache_get_value_name_int(row, "fraction_id", g_Doors[idx][dd_FractionID]);
    cache_get_value_name_int(row, "vw", g_Doors[idx][dd_VW]);
    cache_get_value_name_int(row, "interior", g_Doors[idx][dd_Interior]);
    if(g_Doors[idx][dd_Side] == 0) g_Doors[idx][dd_Side] = 1;
    if(g_Doors[idx][dd_Speed] < 0.4) g_Doors[idx][dd_Speed] = DynDoor_DefaultSpeed(g_Doors[idx][dd_Type]);
    if(g_Doors[idx][dd_Type] == DD_TYPE_DOOR || g_Doors[idx][dd_Type] == DD_TYPE_BARRIER)
        DynDoor_ComputeOpen(idx);
    else if(g_Doors[idx][dd_OpenX] == 0.0 && g_Doors[idx][dd_OpenY] == 0.0 && g_Doors[idx][dd_OpenZ] == 0.0)
        DynDoor_ComputeOpen(idx);
    return 1;
}

forward OnDynDoorsLoaded();
public OnDynDoorsLoaded()
{
    DynDoor_ClearAll();
    new rows = cache_num_rows();
    if(rows == 0)
    {
        if(g_DoorSeedAttempted)
        {
            print("[DynDoors] Seed produced 0 rows, skip retry.");
            return 1;
        }
        g_DoorSeedAttempted = true;
        print("[DynDoors] Table empty, seeding Amazing interiors...");
        g_DoorSeedCursor = 0;
        DynDoor_SeedNext();
        return 1;
    }
    for(new i = 0; i < rows && g_DoorCount < MAX_DYN_DOORS; i++)
    {
        new idx = g_DoorCount;
        DynDoor_ResetSlot(idx);
        DynDoor_ApplyRow(i, idx);
        g_DoorCount++;
        DynDoor_Spawn(idx);
    }
    printf("[DynDoors] Loaded doors: %d", g_DoorCount);
    return 1;
}

stock DynDoor_SeedNext()
{
    if(g_DoorSeedCursor >= sizeof(DynDoorSeed))
    {
        mysql_tquery(dbHandle, "SELECT * FROM `dynamic_doors` ORDER BY `id` ASC", "OnDynDoorsLoaded", "");
        return 1;
    }
    new i = g_DoorSeedCursor;
    new name[64], query[720];
    DynDoor_NameByModel(DynDoorSeed[i][dds_model], name, sizeof(name));

    new Float:x = DynDoorSeed[i][dds_x];
    new Float:y = DynDoorSeed[i][dds_y];
    new Float:z = DynDoorSeed[i][dds_z];
    new Float:rx = DynDoorSeed[i][dds_rx];
    new Float:ry = DynDoorSeed[i][dds_ry];
    new Float:rz = DynDoorSeed[i][dds_rz];
    new side = DynDoorSeed[i][dds_side];
    new Float:ox = x + 0.004;
    new Float:oy = y;
    new Float:oz = z;
    new Float:orx = rx;
    new Float:ory = ry;
    new Float:orz = DynDoor_NormAngle(rz + DOOR_SWING_ANGLE * float(side));

    mysql_format(dbHandle, query, sizeof(query),
        "INSERT INTO `dynamic_doors` (`name`,`model`,`type`,`side`,`speed`,`x`,`y`,`z`,`rx`,`ry`,`rz`,`open_x`,`open_y`,`open_z`,`open_rx`,`open_ry`,`open_rz`,`fraction_id`,`vw`,`interior`) VALUES ('%e',%d,0,%d,%.2f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%d,-1,-1)",
        name, DynDoorSeed[i][dds_model], side, DOOR_SWING_SPEED,
        x, y, z, rx, ry, rz, ox, oy, oz, orx, ory, orz,
        DynDoorSeed[i][dds_frac]);
    mysql_tquery(dbHandle, query, "DynDoor_OnSeeded", "");
    return 1;
}

forward DynDoor_OnSeeded();
public DynDoor_OnSeeded()
{
    g_DoorSeedCursor++;
    DynDoor_SeedNext();
    return 1;
}

stock DynDoor_Save(idx)
{
    if(idx < 0 || idx >= g_DoorCount) return 0;
    new query[800];
    mysql_format(dbHandle, query, sizeof(query),
        "UPDATE `dynamic_doors` SET `name`='%e',`model`=%d,`type`=%d,`side`=%d,`speed`=%.2f,`x`=%.4f,`y`=%.4f,`z`=%.4f,`rx`=%.4f,`ry`=%.4f,`rz`=%.4f,`open_x`=%.4f,`open_y`=%.4f,`open_z`=%.4f,`open_rx`=%.4f,`open_ry`=%.4f,`open_rz`=%.4f,`fraction_id`=%d,`vw`=%d,`interior`=%d WHERE `id`=%d",
        g_Doors[idx][dd_Name], g_Doors[idx][dd_Model], g_Doors[idx][dd_Type], g_Doors[idx][dd_Side], g_Doors[idx][dd_Speed],
        g_Doors[idx][dd_X], g_Doors[idx][dd_Y], g_Doors[idx][dd_Z],
        g_Doors[idx][dd_RX], g_Doors[idx][dd_RY], g_Doors[idx][dd_RZ],
        g_Doors[idx][dd_OpenX], g_Doors[idx][dd_OpenY], g_Doors[idx][dd_OpenZ],
        g_Doors[idx][dd_OpenRX], g_Doors[idx][dd_OpenRY], g_Doors[idx][dd_OpenRZ],
        g_Doors[idx][dd_FractionID], g_Doors[idx][dd_VW], g_Doors[idx][dd_Interior],
        g_Doors[idx][dd_ID]);
    mysql_tquery(dbHandle, query, "", "");
    return 1;
}

stock DynDoor_BeginCreate(playerid, model, fracid, name[], type, side, Float:dist)
{
    if(g_DoorCount >= MAX_DYN_DOORS) return SendErr(playerid, "Достигнут лимит дверей.");
    if(model < 1 || model > 20000) return SendErr(playerid, "Некорректная модель объекта.");
    if(fracid < 0 || fracid >= MAX_FRACTIONS) return SendErr(playerid, "Некорректный ID фракции (0 = все).");
    if(side != -1 && side != 1) side = 1;
    if(dist < 1.0) dist = GATE_DEFAULT_DIST;

    new Float:x, Float:y, Float:z, Float:a;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);

    new Float:ox, Float:oy, Float:oz, Float:orx, Float:ory, Float:orz;
    if(type == DD_TYPE_DOOR)
    {
        ox = x + 0.004; oy = y; oz = z;
        orx = 0.0; ory = 0.0; orz = DynDoor_NormAngle(a + DOOR_SWING_ANGLE * float(side));
    }
    else if(type == DD_TYPE_BARRIER)
    {
        ox = x + 0.004; oy = y; oz = z;
        orx = -80.0; ory = 0.0; orz = a;
    }
    else
    {
        ox = x + dist * floatsin(-a, degrees);
        oy = y + dist * floatcos(-a, degrees);
        oz = z;
        orx = 0.0; ory = 0.0; orz = a;
    }

    SetPVarString(playerid, "dd_name", name);
    SetPVarInt(playerid, "dd_model", model);
    SetPVarInt(playerid, "dd_type", type);
    SetPVarInt(playerid, "dd_side", side);
    SetPVarFloat(playerid, "dd_speed", DynDoor_DefaultSpeed(type));
    SetPVarFloat(playerid, "dd_x", x);
    SetPVarFloat(playerid, "dd_y", y);
    SetPVarFloat(playerid, "dd_z", z);
    SetPVarFloat(playerid, "dd_rx", 0.0);
    SetPVarFloat(playerid, "dd_ry", 0.0);
    SetPVarFloat(playerid, "dd_rz", a);
    SetPVarFloat(playerid, "dd_ox", ox);
    SetPVarFloat(playerid, "dd_oy", oy);
    SetPVarFloat(playerid, "dd_oz", oz);
    SetPVarFloat(playerid, "dd_orx", orx);
    SetPVarFloat(playerid, "dd_ory", ory);
    SetPVarFloat(playerid, "dd_orz", orz);
    SetPVarInt(playerid, "dd_frac", fracid);
    SetPVarInt(playerid, "dd_vw", GetPlayerVirtualWorld(playerid));
    SetPVarInt(playerid, "dd_int", GetPlayerInterior(playerid));

    new query[800];
    mysql_format(dbHandle, query, sizeof(query),
        "INSERT INTO `dynamic_doors` (`name`,`model`,`type`,`side`,`speed`,`x`,`y`,`z`,`rx`,`ry`,`rz`,`open_x`,`open_y`,`open_z`,`open_rx`,`open_ry`,`open_rz`,`fraction_id`,`vw`,`interior`) VALUES ('%e',%d,%d,%d,%.2f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%d,%d,%d)",
        name, model, type, side, DynDoor_DefaultSpeed(type),
        x, y, z, 0.0, 0.0, a, ox, oy, oz, orx, ory, orz,
        fracid, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid));
    mysql_tquery(dbHandle, query, "OnDynDoorCreated", "i", playerid);
    return 1;
}

forward OnDynDoorCreated(playerid);
public OnDynDoorCreated(playerid)
{
    if(!IsPlayerConnected(playerid)) return 1;
    new idx = g_DoorCount;
    if(idx >= MAX_DYN_DOORS) return SendErr(playerid, "Достигнут лимит дверей.");

    DynDoor_ResetSlot(idx);
    g_Doors[idx][dd_ID] = cache_insert_id();
    GetPVarString(playerid, "dd_name", g_Doors[idx][dd_Name], 64);
    g_Doors[idx][dd_Model] = GetPVarInt(playerid, "dd_model");
    g_Doors[idx][dd_Type] = GetPVarInt(playerid, "dd_type");
    g_Doors[idx][dd_Side] = GetPVarInt(playerid, "dd_side");
    g_Doors[idx][dd_Speed] = GetPVarFloat(playerid, "dd_speed");
    g_Doors[idx][dd_X] = GetPVarFloat(playerid, "dd_x");
    g_Doors[idx][dd_Y] = GetPVarFloat(playerid, "dd_y");
    g_Doors[idx][dd_Z] = GetPVarFloat(playerid, "dd_z");
    g_Doors[idx][dd_RX] = GetPVarFloat(playerid, "dd_rx");
    g_Doors[idx][dd_RY] = GetPVarFloat(playerid, "dd_ry");
    g_Doors[idx][dd_RZ] = GetPVarFloat(playerid, "dd_rz");
    g_Doors[idx][dd_OpenX] = GetPVarFloat(playerid, "dd_ox");
    g_Doors[idx][dd_OpenY] = GetPVarFloat(playerid, "dd_oy");
    g_Doors[idx][dd_OpenZ] = GetPVarFloat(playerid, "dd_oz");
    g_Doors[idx][dd_OpenRX] = GetPVarFloat(playerid, "dd_orx");
    g_Doors[idx][dd_OpenRY] = GetPVarFloat(playerid, "dd_ory");
    g_Doors[idx][dd_OpenRZ] = GetPVarFloat(playerid, "dd_orz");
    g_Doors[idx][dd_FractionID] = GetPVarInt(playerid, "dd_frac");
    g_Doors[idx][dd_VW] = GetPVarInt(playerid, "dd_vw");
    g_Doors[idx][dd_Interior] = GetPVarInt(playerid, "dd_int");
    g_DoorCount++;
    DynDoor_Spawn(idx);

    new tname[24], msg[160];
    DynDoor_TypeName(g_Doors[idx][dd_Type], tname, sizeof(tname));
    format(msg, sizeof(msg), "%s создан(а). ID: %d. E открывает и закрывает. При необходимости /setdooropen %d", tname, g_Doors[idx][dd_ID], g_Doors[idx][dd_ID]);
    CEFChat_Send(playerid, "54B367", msg);
    return 1;
}

public OnDynamicObjectMoved(objectid)
{
    new idx = DynDoor_FindByObject(objectid);
    if(idx != -1) g_Doors[idx][dd_Moving] = false;
    return 1;
}

public OnPlayerEditDynamicObject(playerid, objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz)
{
    new idx = g_DoorEditIdx[playerid];
    if(idx < 0 || idx >= g_DoorCount) return 0;
    if(g_Doors[idx][dd_Object] != objectid) return 0;

    if(response == EDIT_RESPONSE_UPDATE) return 1;

    if(response == EDIT_RESPONSE_CANCEL)
    {
        DynDoor_Spawn(idx);
        g_DoorEditIdx[playerid] = -1;
        CEFChat_Send(playerid, "FF4444", "Редактирование двери отменено.");
        return 1;
    }

    if(response == EDIT_RESPONSE_FINAL)
    {
        if(g_DoorEditKind[playerid] == 1)
        {
            g_Doors[idx][dd_OpenX] = x;
            g_Doors[idx][dd_OpenY] = y;
            g_Doors[idx][dd_OpenZ] = z;
            g_Doors[idx][dd_OpenRX] = rx;
            g_Doors[idx][dd_OpenRY] = ry;
            g_Doors[idx][dd_OpenRZ] = rz;
        }
        else
        {
            g_Doors[idx][dd_X] = x;
            g_Doors[idx][dd_Y] = y;
            g_Doors[idx][dd_Z] = z;
            g_Doors[idx][dd_RX] = rx;
            g_Doors[idx][dd_RY] = ry;
            g_Doors[idx][dd_RZ] = rz;
            if(g_Doors[idx][dd_Type] != DD_TYPE_GATE)
                DynDoor_ComputeOpen(idx);
        }
        DynDoor_Save(idx);
        DynDoor_Spawn(idx);
        g_DoorEditIdx[playerid] = -1;
        CEFChat_Send(playerid, "54B367", "Позиция двери сохранена.");
        return 1;
    }
    return 1;
}

cmd:createdoor(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;
    if(!GetAdminLevel(playerid, 5)) return SendErr(playerid, messageUnknownCMD);
    new model, fracid, side, name[64];
    side = 1;
    if(sscanf(params, "dds[64]D(1)", model, fracid, name, side))
        return SendErr(playerid, "Использование: /createdoor [модель] [фракция] [название] [сторона 1/-1]");
    if(!strlen(name)) DynDoor_NameByModel(model, name, sizeof(name));
    return DynDoor_BeginCreate(playerid, model, fracid, name, DD_TYPE_DOOR, side, 0.0);
}

cmd:amazingdoor(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;
    if(!GetAdminLevel(playerid, 5)) return SendErr(playerid, messageUnknownCMD);
    new model, fracid, side, name[64];
    side = 1;
    if(sscanf(params, "dds[64]D(1)", model, fracid, name, side))
        return SendErr(playerid, "Использование: /amazingdoor [модель] [фракция] [название] [сторона 1/-1]");
    if(!strlen(name)) DynDoor_NameByModel(model, name, sizeof(name));
    return DynDoor_BeginCreate(playerid, model, fracid, name, DD_TYPE_DOOR, side, 0.0);
}

cmd:creategate(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;
    if(!GetAdminLevel(playerid, 5)) return SendErr(playerid, messageUnknownCMD);
    new model, fracid, name[64];
    new Float:dist = GATE_DEFAULT_DIST;
    if(sscanf(params, "dds[64]F(6.5)", model, fracid, name, dist))
        return SendErr(playerid, "Использование: /creategate [модель] [фракция] [название] [дистанция]");
    if(!strlen(name)) format(name, sizeof(name), "Ворота");
    return DynDoor_BeginCreate(playerid, model, fracid, name, DD_TYPE_GATE, 1, dist);
}

cmd:amazinggate(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;
    if(!GetAdminLevel(playerid, 5)) return SendErr(playerid, messageUnknownCMD);
    new model, fracid, name[64];
    new Float:dist = GATE_DEFAULT_DIST;
    if(sscanf(params, "dds[64]F(6.5)", model, fracid, name, dist))
        return SendErr(playerid, "Использование: /amazinggate [модель] [фракция] [название] [дистанция]");
    if(!strlen(name)) format(name, sizeof(name), "Ворота");
    return DynDoor_BeginCreate(playerid, model, fracid, name, DD_TYPE_GATE, 1, dist);
}

cmd:createbarrier(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;
    if(!GetAdminLevel(playerid, 5)) return SendErr(playerid, messageUnknownCMD);
    new model, fracid, name[64];
    if(sscanf(params, "dds[64]", model, fracid, name))
        return SendErr(playerid, "Использование: /createbarrier [модель] [фракция] [название]");
    if(!strlen(name)) format(name, sizeof(name), "Шлагбаум");
    return DynDoor_BeginCreate(playerid, model, fracid, name, DD_TYPE_BARRIER, 1, 0.0);
}

cmd:setdooropen(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;
    if(!GetAdminLevel(playerid, 5)) return SendErr(playerid, messageUnknownCMD);
    new doorid;
    if(sscanf(params, "d", doorid)) return SendErr(playerid, "Использование: /setdooropen [id]");
    new idx = DynDoor_FindById(doorid);
    if(idx == -1) return SendErr(playerid, "Дверь не найдена.");
    if(g_Doors[idx][dd_Object] <= 0) return SendErr(playerid, "Объект двери не создан.");
    g_DoorEditIdx[playerid] = idx;
    g_DoorEditKind[playerid] = 1;
    EditDynamicObject(playerid, g_Doors[idx][dd_Object]);
    CEFChat_Send(playerid, "54B367", "Поставьте объект в ОТКРЫТУЮ позицию и сохраните.");
    return 1;
}

cmd:setdoorclosed(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;
    if(!GetAdminLevel(playerid, 5)) return SendErr(playerid, messageUnknownCMD);
    new doorid;
    if(sscanf(params, "d", doorid)) return SendErr(playerid, "Использование: /setdoorclosed [id]");
    new idx = DynDoor_FindById(doorid);
    if(idx == -1) return SendErr(playerid, "Дверь не найдена.");
    if(g_Doors[idx][dd_Object] <= 0) return SendErr(playerid, "Объект двери не создан.");
    g_DoorEditIdx[playerid] = idx;
    g_DoorEditKind[playerid] = 0;
    EditDynamicObject(playerid, g_Doors[idx][dd_Object]);
    CEFChat_Send(playerid, "54B367", "Поставьте объект в ЗАКРЫТУЮ позицию и сохраните.");
    return 1;
}

cmd:editdoor(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;
    if(!GetAdminLevel(playerid, 5)) return SendErr(playerid, messageUnknownCMD);
    new doorid;
    if(sscanf(params, "d", doorid)) return SendErr(playerid, "Использование: /editdoor [id]");
    new idx = DynDoor_FindById(doorid);
    if(idx == -1) return SendErr(playerid, "Дверь не найдена.");
    if(g_Doors[idx][dd_Object] <= 0) return SendErr(playerid, "Объект двери не создан.");
    g_DoorEditIdx[playerid] = idx;
    g_DoorEditKind[playerid] = 0;
    EditDynamicObject(playerid, g_Doors[idx][dd_Object]);
    CEFChat_Send(playerid, "54B367", "Редактируйте закрытую позицию. ESC отмена, галочка сохранить.");
    return 1;
}

cmd:deletedoor(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;
    if(!GetAdminLevel(playerid, 5)) return SendErr(playerid, messageUnknownCMD);
    new doorid;
    if(sscanf(params, "d", doorid)) return SendErr(playerid, "Использование: /deletedoor [id]");
    new found = DynDoor_FindById(doorid);
    if(found == -1) return SendErr(playerid, "Дверь не найдена.");

    DynDoor_DestroyObject(found);
    new query[96];
    mysql_format(dbHandle, query, sizeof(query), "DELETE FROM `dynamic_doors` WHERE `id`=%d", doorid);
    mysql_tquery(dbHandle, query, "", "");
    for(new i = found; i < g_DoorCount - 1; i++) g_Doors[i] = g_Doors[i + 1];
    DynDoor_ResetSlot(g_DoorCount - 1);
    g_DoorCount--;
    CEFChat_Send(playerid, "54B367", "Дверь удалена.");
    return 1;
}

cmd:listdoors(playerid, params[])
{
    #pragma unused params
    if(!PT[playerid][pLogged]) return 1;
    if(!GetAdminLevel(playerid, 5)) return SendErr(playerid, messageUnknownCMD);
    if(g_DoorCount == 0) return SendErr(playerid, "Дверей нет.");
    SendClientMessage(playerid, COLOR_UNMAZING, "----- Динамические двери / ворота -----");
    for(new i = 0; i < g_DoorCount; i++)
    {
        new msg[180], stateStr[16], fracName[MAX_FRACTIONS_NAME], tname[24];
        if(g_Doors[i][dd_IsOpen]) format(stateStr, sizeof(stateStr), "открыта");
        else format(stateStr, sizeof(stateStr), "закрыта");
        if(g_Doors[i][dd_FractionID] > 0 && g_Doors[i][dd_FractionID] < MAX_FRACTIONS)
            format(fracName, sizeof(fracName), "%s", Fraction[g_Doors[i][dd_FractionID]][fName]);
        else format(fracName, sizeof(fracName), "все");
        DynDoor_TypeName(g_Doors[i][dd_Type], tname, sizeof(tname));
        format(msg, sizeof(msg), "[%d] %s | %s | модель %d | фракция %d (%s) | %s | vw %d int %d",
            g_Doors[i][dd_ID], g_Doors[i][dd_Name], tname, g_Doors[i][dd_Model],
            g_Doors[i][dd_FractionID], fracName, stateStr,
            g_Doors[i][dd_VW], g_Doors[i][dd_Interior]);
        SendClientMessage(playerid, -1, msg);
    }
    return 1;
}

cmd:gotodoor(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;
    if(!GetAdminLevel(playerid, 5)) return SendErr(playerid, messageUnknownCMD);
    new doorid;
    if(sscanf(params, "d", doorid)) return SendErr(playerid, "Использование: /gotodoor [id]");
    new idx = DynDoor_FindById(doorid);
    if(idx == -1) return SendErr(playerid, "Дверь не найдена.");
    SetPlayerInterior(playerid, g_Doors[idx][dd_Interior] < 0 ? 0 : g_Doors[idx][dd_Interior]);
    SetPlayerVirtualWorld(playerid, g_Doors[idx][dd_VW] < 0 ? 0 : g_Doors[idx][dd_VW]);
    SetPlayerPos(playerid, g_Doors[idx][dd_X], g_Doors[idx][dd_Y], g_Doors[idx][dd_Z] + 0.5);
    return 1;
}

cmd:doorfrac(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;
    if(!GetAdminLevel(playerid, 5)) return SendErr(playerid, messageUnknownCMD);
    new doorid, fracid;
    if(sscanf(params, "dd", doorid, fracid)) return SendErr(playerid, "Использование: /doorfrac [id] [фракция]");
    if(fracid < 0 || fracid >= MAX_FRACTIONS) return SendErr(playerid, "Некорректный ID фракции.");
    new idx = DynDoor_FindById(doorid);
    if(idx == -1) return SendErr(playerid, "Дверь не найдена.");
    g_Doors[idx][dd_FractionID] = fracid;
    DynDoor_Save(idx);
    CEFChat_Send(playerid, "54B367", "Фракция двери обновлена.");
    return 1;
}

cmd:doormodel(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;
    if(!GetAdminLevel(playerid, 5)) return SendErr(playerid, messageUnknownCMD);
    new doorid, model;
    if(sscanf(params, "dd", doorid, model)) return SendErr(playerid, "Использование: /doormodel [id] [модель]");
    if(model < 1 || model > 20000) return SendErr(playerid, "Некорректная модель.");
    new idx = DynDoor_FindById(doorid);
    if(idx == -1) return SendErr(playerid, "Дверь не найдена.");
    g_Doors[idx][dd_Model] = model;
    DynDoor_Save(idx);
    DynDoor_Spawn(idx);
    CEFChat_Send(playerid, "54B367", "Модель двери обновлена.");
    return 1;
}

cmd:doorside(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;
    if(!GetAdminLevel(playerid, 5)) return SendErr(playerid, messageUnknownCMD);
    new doorid, side;
    if(sscanf(params, "dd", doorid, side)) return SendErr(playerid, "Использование: /doorside [id] [1 или -1]");
    if(side != 1 && side != -1) return SendErr(playerid, "Сторона: 1 или -1.");
    new idx = DynDoor_FindById(doorid);
    if(idx == -1) return SendErr(playerid, "Дверь не найдена.");
    g_Doors[idx][dd_Side] = side;
    DynDoor_ComputeOpen(idx);
    DynDoor_Save(idx);
    DynDoor_Spawn(idx);
    CEFChat_Send(playerid, "54B367", "Сторона распахивания обновлена.");
    return 1;
}

cmd:doortype(playerid, params[])
{
    if(!PT[playerid][pLogged]) return 1;
    if(!GetAdminLevel(playerid, 5)) return SendErr(playerid, messageUnknownCMD);
    new doorid, type;
    if(sscanf(params, "dd", doorid, type)) return SendErr(playerid, "Использование: /doortype [id] [0 дверь / 1 ворота / 2 шлагбаум]");
    if(type < 0 || type > 2) return SendErr(playerid, "Тип: 0 дверь, 1 ворота, 2 шлагбаум.");
    new idx = DynDoor_FindById(doorid);
    if(idx == -1) return SendErr(playerid, "Дверь не найдена.");
    g_Doors[idx][dd_Type] = type;
    g_Doors[idx][dd_Speed] = DynDoor_DefaultSpeed(type);
    DynDoor_ComputeOpen(idx);
    DynDoor_Save(idx);
    DynDoor_Spawn(idx);
    CEFChat_Send(playerid, "54B367", "Тип объекта обновлён.");
    return 1;
}

cmd:doorhelp(playerid, params[])
{
    #pragma unused params
    if(!PT[playerid][pLogged]) return 1;
    if(!GetAdminLevel(playerid, 5)) return SendErr(playerid, messageUnknownCMD);
    SendClientMessage(playerid, COLOR_UNMAZING, "----- Двери и ворота (Amazing) -----");
    SendClientMessage(playerid, -1, "/createdoor [модель] [фракция] [имя] [1/-1]  (распашная, E открыть/закрыть)");
    SendClientMessage(playerid, -1, "/creategate [модель] [фракция] [имя] [дист]   /createbarrier [модель] [фракция] [имя]");
    SendClientMessage(playerid, -1, "/amazingdoor и /amazinggate — те же команды");
    SendClientMessage(playerid, -1, "/setdooropen [id]  /setdoorclosed [id]  /editdoor [id]  /deletedoor [id]");
    SendClientMessage(playerid, -1, "/listdoors  /gotodoor [id]  /doorfrac  /doormodel  /doorside  /doortype");
    SendClientMessage(playerid, -1, "Фракции: 0=все 1=Правительство 2=ФСБ 3=ДПС 4=ППС 5=ЕСС 6=ВЧ");
    SendClientMessage(playerid, -1, "Модели дверей: ФСБ 11963, ДПС 18417, ППС 18419, ЕСС 18413, ВЧ 12576, ФСИН 17618, КПЗ 7398");
    SendClientMessage(playerid, -1, "Ворота: ФСБ 5288/5289, ВЧ 14090, полиция 5157. Шлагбаум: 5158 / 11499");
    SendClientMessage(playerid, -1, "Игрок сам открывает и закрывает на E. Сохраняется в MySQL.");
    return 1;
}
