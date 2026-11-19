






   
 
#if defined _zones_included
        #endinput
#endif
#define _zones_included
#pragma library samp
#include <a_samp>
 
#define MAX_ZONE_NAME 28
 
#define GetCityName(%0) g_sa_city[%0][SZ_NAME]
#define GetZoneName(%0)	g_sa_zones[%0][SZ_NAME]

 

 



 

 

 
enum E_SA_ZONE_STRUCT
{
	SZ_NAME[MAX_ZONE_NAME],
	Float:SZ_AREA[6]
};
 
new const 
	g_sa_zones[][E_SA_ZONE_STRUCT] =
{

	



































































































































































































































































































































































                                                                                   
	{"[нет данных]",                {0.0, 0.0, 0.0, 0.0, 0.0, 0.0}}
};

new const
	g_sa_city[][E_SA_ZONE_STRUCT] =
{
	{"Гарель", 						{2167.0, -339.0, -242.90, 2700.0, 0.0, 900.0}},
	{"Новый Арзамас", 				{-1541.0, -601.0, -242.90, 1821.0, 1.0, 900.00}},
	{"Эдово", 						{-2691.0, 2536.0, -242.90, -2335.0, 2977.0, 900.00}},
	{"Аэропорт Лыткарино", 			{-2588.0, 446.0, -242.90, -2354.0, 510.0, 900.00}},
	{"Нижегородск", 				{-2905.0, 1273.0, -242.90, -2228.0, 2121.0, 900.00}},
	{"Гоночный трек", 				{-2068.0, 1253.0, -242.90, -1374.0, 2060.0, 900.00}},
	{"Завод", 						{-1126.0, 2159.0, -242.90, -1021.0, 2255.0, 900.00}},
	{"Арзамас", 					{-434.0, 1.0, -242.90, 917.0, 1097.0, 900.00}},
	{"Арзамас", 					{-198.0, 1097.0, -242.90, 631.0, 2029.0, 900.00}},
	{"Арзамас", 					{-685.0, 899.0, -242.90, -434.0, 1032.0, 900.00}},
	{"Батырево", 					{1715.0, 1837.0, -242.90, 2005.0, 2609.0, 900.00}},
	{"Батырево", 					{1921.0, 1732.0, -242.90, 2015.0, 1837.0, 900.00}},
	{"Аэропорт Батырево", 			{1098.0, 1516.0, -242.90, 1921.0, 1837.0, 900.00}},
	{"Роговичи", 					{1741.0, 1311.0, -242.90, 2362.0, 1516.0, 900.00}},
	{"Лыткарино", 					{-2682.0, -268.0, -242.90, -1964.0, 356.0, 900.00}},








                                                                                         
	{"[нет данных]",                {0.0, 0.0, 0.0, 0.0, 0.0, 0.0}}
};


 






   
 
stock GetPlayer2DZone(playerid, dest[], len)
{
	new zone_idx;
	new Float:x, Float:y, Float:z;
	
	GetPlayerPos(playerid, x, y, z);
	zone_idx = Get2DZone(x, y, z);
	
	return format(dest, len, g_sa_zones[zone_idx][SZ_NAME], 0);
}

stock Get2DZone(Float: x, Float: y)
{
	new zone_idx = sizeof(g_sa_zones) - 1;
	for(new i = 0; i != sizeof(g_sa_zones)-1; i ++)
	{
		if(!(x >= g_sa_zones[i][SZ_AREA][0] && x <= g_sa_zones[i][SZ_AREA][3] && y >= g_sa_zones[i][SZ_AREA][1] && y <= g_sa_zones[i][SZ_AREA][4]))
		{
			continue;
		}
		
		zone_idx = i;
		break;
	}
	return zone_idx;
}

stock GetPlayer2DCity(playerid, dest[], len = sizeof dest)
{
	new city_idx;
	new Float:x, Float:y, Float:z;
	
	GetPlayerPos(playerid, x, y, z);
	city_idx = Get2DCity(x, y, z);
	
	return format(dest, len, g_sa_city[city_idx][SZ_NAME], 0);
}

stock Get2DCity(Float: x, Float: y)
{
	new city_idx = sizeof(g_sa_city) - 1;
	for(new i = 0; i != sizeof(g_sa_city)-1; i ++)
	{
		if(!(x >= g_sa_city[i][SZ_AREA][0] && x <= g_sa_city[i][SZ_AREA][3] && y >= g_sa_city[i][SZ_AREA][1] && y <= g_sa_city[i][SZ_AREA][4]))
		{
			continue;
		}
		
		city_idx = i;
		break;
	}
	return city_idx;
}


 






   
 
stock GetPlayer3DZone(playerid, zone[], len)
{
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	for(new i = 0; i != sizeof(g_sa_zones); i++ )
	{
		if(x >= g_sa_zones[i][SZ_AREA][0] && x <= g_sa_zones[i][SZ_AREA][3] && y >= g_sa_zones[i][SZ_AREA][1] && y <= g_sa_zones[i][SZ_AREA][4] && z >= g_sa_zones[i][SZ_AREA][2] && z <= g_sa_zones[i][SZ_AREA][5])
		{
			return format(zone, len, g_sa_zones[i][SZ_NAME], 0);
		}
	}
	return 0;
}
 

 





   

stock IsPlayerInZone(playerid, zone[])
{
	new TmpZone[MAX_ZONE_NAME];
	GetPlayer3DZone(playerid, TmpZone, sizeof(TmpZone));
	for(new i = 0; i != sizeof(g_sa_zones); i++)
	{
		if(strfind(TmpZone, zone, true) != -1)
			return 1;
	}
	return 0;
}
