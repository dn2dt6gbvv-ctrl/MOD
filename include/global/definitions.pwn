#define COLOR_GRAY      0xCECECEFF
#define COLOR_UNMAZING   0xe69348FF
#define COLOR_RED       0xff6347FF
#define COLOR_WHITE     0xFFFFFFFF
#define COLOR_LIME	 	0x99cc00FF
#define COLOR_BLUE	 	0x1e90ffFF
#define COLOR_RADIO 0x54b367FF
#define COLOR_DEPT  0xff8282FF


enum 
	E_WEATHER_DATA
{
	weather_name[15],
	weather_id,
	weather_degrees
};
 
new 
	weather[][E_WEATHER_DATA] = 
{
	{"В области ожидается ясная погода", 18, 22},
	{"В области ожидается туман", 9, 15},
	{"В области ожидается гроза", 8, 17},
	{"В области ожидается ясная погода", 3, 21},
	{"В области ожидается ясная погода", 1, 23}
};
new g_SuTarget[MAX_PLAYERS];
new g_SuArticleName[MAX_PLAYERS][64];
new g_SuWantedLevel[MAX_PLAYERS];
new g_SuChapterId[MAX_PLAYERS];  

