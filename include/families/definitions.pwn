#define MAX_FAMILY           1000
#define MAX_FAMILY_RANK      10
#define MAX_FAMILY_NAME      32

enum FamilyStruct
{
    famID,
    famName[32],
    famLeader,
    famMaxRanks,
    famRankName[10],
    famMembersCount,
    famVouchers,
    famRank[32],
    famtHouse,
    famHouse,
    famWarn,
    famBank
}
new Family[MAX_FAMILY][FamilyStruct];
new totalFamily;

new PlayerFamLeaderName[MAX_PLAYERS][32];

#define GetFamilyName(%0) Family[%0][famName]

enum
{
    DIALOG_FAMILY_CREATE = 7000,
    DIALOG_FAMILY_MENU,
    DIALOG_FAMILY_INFO,
    DIALOG_FAMILY_RANG,
    DIALOG_FAMILY_NONE,
};
