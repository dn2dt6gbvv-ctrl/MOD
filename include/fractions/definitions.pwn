#define MAX_FRACTIONS           17
#define MAX_FRACTIONS_RANK      12
#define MAX_FRACTION_ITEMS      20
#define MAX_FRACTION_VEHICLES   20
#define MAX_FRACTIONS_NAME      32

#define DIALOG_SOS_MAIN 4300
#define DIALOG_SOS_LIST 4301

#define DIALOG_ESS_NURSE      4400
#define DIALOG_SURRENDER      4401
#define DIALOG_LEADERGIFT     4402
#define DIALOG_LPANEL_MAIN    4410
#define DIALOG_LPANEL_FIRE    4411
#define DIALOG_LPANEL_WARN    4412
#define DIALOG_LPANEL_UNWARN  4413
#define DIALOG_LPANEL_LIST    4414
#define DIALOG_LPANEL_INFO    4415

#define DIALOG_NEWS_LIST   581
#define DIALOG_NEWS_CREATE 571
new g_NewsSlotMap[MAX_PLAYERS][22];

new g_ChaseTarget[MAX_PLAYERS];
new g_ChaseTimer[MAX_PLAYERS];
new g_ChaseOfficer[MAX_PLAYERS];
new bool:g_IsChased[MAX_PLAYERS];


new g_WantedCooldown[MAX_PLAYERS];
new g_WantedMapIcon[MAX_PLAYERS];
enum Fractions
{
    fName[MAX_FRACTIONS_NAME],
    fType,
    fTotalMembers,
    fMax_ranks,
    fSkinMale[MAX_FRACTIONS_RANK],
    fSkinFemale[MAX_FRACTIONS_RANK],
    fSalary[MAX_FRACTIONS_RANK],
    fDressPickup,
    fDressPickupModel,
    fArmouryPickup,
    fArmouryPickupModel
}

new Fraction[MAX_FRACTIONS][Fractions];
new totalFractions;

new Fraction_Rank[MAX_FRACTIONS][MAX_FRACTIONS_RANK][MAX_FRACTIONS_NAME];

new Float:Fractions_Spawn[MAX_FRACTIONS][4];
new Float:Fractions_Dress[MAX_FRACTIONS][3];
new Float:Fractions_Armoury[MAX_FRACTIONS][3];

enum
{
    FI_TYPE_NONE = 0,
    FI_TYPE_WEAPON = 1,
    FI_TYPE_INV = 2,
}

enum fItems
{
    fiFractionID,
    fiType,
    fiName[MAX_FRACTIONS_NAME],
    fiServerID,
    fiMaxAmount,
    fiRankAccess,
    fiCount
}

new Fraction_Items[MAX_FRACTIONS][MAX_FRACTION_ITEMS][fItems];
new totalFractionItems[MAX_FRACTIONS];

enum fVehicles
{
    fvFractionID,
    fvDBID,
    fvModel,
    fvServerID,
    Float:fvSpawnX,
    Float:fvSpawnY,
    Float:fvSpawnZ,
    Float:fvSpawnA,
    fvColor1,
    fvColor2
}

new Fraction_Vehicles[MAX_FRACTIONS][MAX_FRACTION_VEHICLES][fVehicles];
new totalFractionVehicles[MAX_FRACTIONS] = 0;



enum {
    FRACTION_NONE,
    FRACTION_GOVERMENT,
    FRACTION_FSB,
    FRACTION_TRAFFIC_PATROL_POLICE,
    FRACTION_PATROL_POLICE,
    FRACTION_HOSPITAL,
    FRACTION_MILITARY,
    FRACTION_BIKERS,
    FRACTION_SKINHEADS,
    FRACTION_RU_MAFIA,
    FRACTION_KV_MAFIA,
    FRACTION_OPG_YUZHNAYA,
    FRACTION_OPG_OREKHOVSKAYA,
    FRACTION_OPG_SOLNTSEVSKAYA,
    FRACTION_CHECHEN_MAFIA,
    FRACTION_TRK_UNMAZING,
    FRACTION_SK
}

#define GetFractionName(%0) Fraction[%0][fName]

enum CUFF
{
	pCuffer,
	pCuffee
}
new pCuff[MAX_PLAYERS][CUFF];

new FollowBy[MAX_PLAYERS] = {MAX_PLAYERS, ...};
new TimerForPlayer[MAX_PLAYERS] = {MAX_PLAYERS, ...};
#define MAX_FRACTION_SKINS 10

#define dialog_FRACTION_CLOTHES        (5121) 
new g_FractionSkins[11][MAX_FRACTION_SKINS] = {
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {106, 165, 165, 165, 106, 0, 0, 0, 0, 0},
    {163, 165, 166, 167, 175, 285, 286, 0, 0, 0},
    {106, 280, 281, 282, 283, 284, 266, 0, 0, 0},
    {12, 76, 106, 133, 153, 158, 265, 267, 288, 0},
    {70, 148, 274, 275, 276, 0, 0, 0, 0, 0},
    {61, 73, 179, 180, 183, 185, 186, 191, 206, 0},
    {114, 115, 116, 192, 193, 292, 0, 0, 0, 0},
    {122, 123, 124, 126, 0, 0, 0, 0, 0, 0},
    {46, 98, 121, 125, 0, 0, 0, 0, 0, 0},
    {114, 115, 116, 193, 293, 0, 0, 0, 0, 0}
};
new g_FriskTarget[MAX_PLAYERS]  = {-1, ...};
new g_FriskOfficer[MAX_PLAYERS] = {-1, ...};

new Float:pogonLeft_Pos[6] = {0.03, 0.0, 0.0, 0.0, 90.0, 0.0};
new Float:pogonRight_Pos[6] = {0.03, 0.0, 0.0, 0.0, -90.0, 0.0};

new g_BeaconObject[MAX_PLAYERS]   = {-1, ...};
new bool:g_BeaconActive[MAX_PLAYERS];
new bool:g_BeaconEditing[MAX_PLAYERS];
new Float:g_BeaconPos[MAX_PLAYERS][3];
new g_BeaconCarID[MAX_PLAYERS]    = {-1, ...};
#define SURRENDER_MINUTES_PER_STAR 3
#define LEADER_GIFT_AMOUNT    30000000
#define GOV_COLOR             0x1A237EFF
#define BEACON_OBJECT_ID      18646

#define DIALOG_OTDEL_MAIN       4500
#define DIALOG_OTDEL_LIST       4501
#define DIALOG_OTDEL_ADD        4502
#define DIALOG_OTDEL_KICK       4503
#define DIALOG_OTDEL_LSELECT    4504
#define DIALOG_OTDEL_LMAIN      4505
#define DIALOG_OTDEL_CADMIN     4510
#define DIALOG_OTDEL_CADMIN_FID 4511
#define DIALOG_OTDEL_CADMIN_MAX 4512
#define DIALOG_OTDEL_CADMIN_NAM 4513
#define DIALOG_OTDEL_DADMIN_FID 4514
#define DIALOG_OTDEL_DADMIN_IDX 4515


#define DIALOG_VCH_PSYCH    4600
#define DIALOG_VCH_USTAV    4650
#define DIALOG_VCH_BILYET   4700
#define DIALOG_VCH_POST_CREATE 4710

#define PPS_SCLAD_X 1572.9598
#define PPS_SCLAD_Y 825.3992
#define PPS_SCLAD_Z 1901.2372

#define GAI_SCLAD_X 1326.7102
#define GAI_SCLAD_Y 1057.2644
#define GAI_SCLAD_Z 2161.2371

#define VCH_SCLAD_X 876.5472
#define VCH_SCLAD_Y 1020.5288
#define VCH_SCLAD_Z 2501.2371

new bool:g_FsbWarehouseOpen[MAX_PLAYERS];
new bool:g_PpsWarehouseOpen[MAX_PLAYERS];
new bool:g_VchWarehouseOpen[MAX_PLAYERS];
new g_FsbWarehousePickup = -1;
new g_PpsWarehousePickup = -1;
new g_GaiWarehousePickup = -1;
new g_VchWarehousePickup = -1;


#define CHASE_RADIUS            50.0
#define CHASE_BREAK_DISTANCE    2000.0
#define CHASE_DIST_CHECK        5000  
#define CHASE_LIST_MAX          50
#define DIALOG_CHASE_LIST       4340
#define DIALOG_CHASE_STOP       4341

#if !defined CHASE_DURATION
    #define CHASE_DURATION 600
#endif

new g_ChaseDistanceTimer[MAX_PLAYERS] = {-1, ...};
new g_ChaseListTargets[MAX_PLAYERS][CHASE_LIST_MAX];
new g_ChaseListCount[MAX_PLAYERS] = {0, ...};
new bool:g_HasBag[MAX_PLAYERS] = {false, ...};

#define DIALOG_MINE_START   4600
#define DIALOG_MINE_ENTER   4601
