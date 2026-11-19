#define MAX_BUSSTOPS    30
#define BUSSTOP_DRAW_DIST 20.0

new Text3D:g_BusStopLabel[MAX_BUSSTOPS];
new g_TotalBusStops = 0;

enum E_BUSSTOP {
    bs_Name[32],
    Float:bs_X,
    Float:bs_Y,
    Float:bs_Z
}

new g_BusStops[][E_BUSSTOP] = {
    {"Батырева",          1918.2964, 2129.5378, 16.0676},
    {"Батырева",          1918.6002, 2150.7100, 16.0575},
    {"Батырева",          1878.6208, 2114.2524, 16.0391},
    {"Батырева",          1114.5432,  935.0676,  4.4647},
    {"г. Арзамас",         767.5344,  794.1661, 12.0000},
    {"г. Арзамас",         743.1337,  780.8137, 12.0000},
    {"г. Арзамас",         795.6710,  994.4689, 12.1922},
    {"г. Арзамас",         776.0533, 1019.8367, 12.0000},
    {"г. Арзамас",         654.7696, 1059.9474, 12.1789},
    {"г. Арзамас",         589.2813, 1108.1234, 12.1797},
    {"г. Арзамас",         519.3200, 1675.8831, 12.0000},
    {"г. Арзамас",        1634.5233, 2945.0037, 12.1797},
    {"г. Арзамас",        1699.1631, 2977.1592, 12.1797},
    {"г. Арзамас",        1766.6364, 2482.4331, 16.1328},
    {"г. Арзамас",        1872.3091, 2365.1301, 16.1328},
    {"г. Арзамас",        1845.8606, 2348.1580, 16.1328},
    {"г. Арзамас",        2255.9792, 1339.3408, 11.9281},
    {"г. Арзамас",        2314.6609, 1045.1744, 16.2804},
    {"Южный",             2890.0320, -131.8062, 25.0466},
    {"Южный",             2769.6636, -516.7909, 24.1921}
};

stock CreateBusStopLabels()
{
    g_TotalBusStops = sizeof(g_BusStops);

    for (new i = 0; i < g_TotalBusStops; i++)
    {
        new labelText[128];
        format(labelText, sizeof(labelText),
            "{FFFFFF}Остановка\n{FFD700}%s\n{AAAAAA}Посмотреть маршрут — /route",
            g_BusStops[i][bs_Name]
        );

        g_BusStopLabel[i] = Create3DTextLabel(
            labelText,
            0xFFFFFFFF,
            g_BusStops[i][bs_X],
            g_BusStops[i][bs_Y],
            g_BusStops[i][bs_Z] + 1.2,
            BUSSTOP_DRAW_DIST,
            0,
            1
        );
    }

    printf("[BusStops] Создано %d остановок.", g_TotalBusStops);
}

stock DestroyBusStopLabels()
{
    for (new i = 0; i < g_TotalBusStops; i++)
    {
        if (g_BusStopLabel[i] != Text3D:INVALID_3DTEXT_ID)
        {
            Delete3DTextLabel(g_BusStopLabel[i]);
            g_BusStopLabel[i] = Text3D:INVALID_3DTEXT_ID;
        }
    }
}
