#define DIALOG_NEED           30781
#define DIALOG_CEF_TRADE_MONEY 30782
forward CEF_NeedsDialog(playerid, response, listitem);
new gCefCasinoChips[MAX_PLAYERS];
new bool:gCefCasinoLoaded[MAX_PLAYERS];
new bool:gCefCasinoFormOpen[MAX_PLAYERS];
#define DIALOG_CEF_PERKS      30780
#define DIALOG_CEF_CASES      30778
#define DIALOG_CEF_CASES_BUY  30779
#define SendClientMessage(%0,%1,%2)     CEFC_ChatBoth(%0,%1,%2)
#define SendClientMessageToAll(%0,%1)   CEFC_ChatBothAll(%0,%1)
#define DIALOG_CEF_SPAWN 30777
#define MAIN_BROWSER 1
#define MAIN_CEF_BROWSER_LINK "file:///cef/spa/index.html"
#define FSB_BROWSER 2

#define FSB_CEF_LINK ""
#define FIND_BROWSER 3
#define FIND_BROWSER_LINK "file:///cef/amazing/find/index.html"
#define RADIAL_BROWSER 52
#define RADIAL_CEF_LINK "file:///cef/amazing/RadMenu/radmenu.html"
#define BIZINFO_BROWSER 6
#define BIZINFO_CEF_LINK "file:///cef/amazing/bizinfo.html"
#define WAREHOUSE_FSB_BROWSER 7
#define WAREHOUSE_FSB_CEF_LINK "file:///cef/amazing/fractions/sclad/fsbsclad.html"
#define LEADERSKIN_BROWSER  12
#define LEADERSKIN_LINK     "file:///cef/amazing/leaderskin/index.html"
#define CHASE_BROWSER       9
#define CHASE_CEF_LINK      "file:///cef/amazing/presledka/index.html"
#define CHASE_DURATION      600
#define SYSNOTIF_BROWSER    10
#define SYSNOTIF_CEF_LINK   "file:///cef/amazing/SystemNotificationModule/index.html"
#define CHAT_BROWSER          11
#define CHAT_CEF_BROWSER_LINK "file:///cef/amazing/chat/index.html"
#define TICKET_BROWSER      20
#define TICKET_BROWSER_LINK "file:///cef/amazing/ticket/index.html"
#define FRISK_BROWSER        21
#define FRISK_CEF_LINK       "file:///cef/amazing/frisk/index.html"
#define dialog_PLAYER_FRISK  (dialog_FRACTION_WAREHOUSE + 2)
#define TIME_BROWSER  22
#define TIME_CEF_LINK "file:///cef/amazing/time/index.html"
#define HINT_BROWSER          23
#define HINT_CEF_LINK         "file:///cef/amazing/hint/index.html"
#define OTDEL_BROWSER           24
#define OTDEL_CEF_LINK          "file:///cef/amazing/otdel.html"
#define PPS_WAREHOUSE_BROWSER 8
#define PPS_WAREHOUSE_LINK "file:///cef/amazing/fractions/sclad/ppsgai.html"
#define VCH_WAREHOUSE_BROWSER 9
#define VCH_WAREHOUSE_LINK "file:///cef/amazing/fractions/sclad/vhsclad.html"
#define UDO_BROWSER      25
#define UDO_FSB_CEF_LINK "file:///cef/amazing/udo/fsb.html"
#define UDO_MVD_CEF_LINK "file:///cef/amazing/udo/mvd.html"

#define UDO_CEF_LINK     UDO_FSB_CEF_LINK
#define LPANEL_BROWSER      55
#define LPANEL_CEF_LINK     "file:///cef/amazing/lpanel.html"
#define FSBPANEL_BROWSER     53
#define FSBPANEL_BROWSER_LINK "file:///cef/amazing/fsbpanel.html"
#define VB_BROWSER      26
#define VB_CEF_LINK     "file:///cef/amazing/fractions/vb/vb.html"
#define TICKET_BROWSER      20
#define TICKET_BROWSER_LINK "file:///cef/amazing/ticket/index.html"
#define LEADERSKIN_BROWSER    12
#define LEADERSKIN_LINK       "file:///cef/amazing/leaderskin/index.html"
#define BAG_BROWSER     60

#define BAG_CEF_LINK    ""
#define BAG_RANGE       3.0
#define HOUSECREATE_BROWSER  27
#define HOUSECREATE_CEF_LINK "file:///cef/amazing/housecreate/index.html"
#define ZAKLADKI_BROWSER     35
#define ZAKLADKI_CEF_LINK    "file:///cef/amazing/ckrim/zakladki/index.html"
#define MINING_BROWSER      36
#define MINING_CEF_LINK     "file:///cef/amazing/job/index.html"
#define PASSPORT_BROWSER     61
#define PASSPORT_CEF_LINK    "file:///cef/amazing/passport/index.html"
#define CARPASS_BROWSER      62
#define CARPASS_CEF_LINK     "file:///cef/amazing/carpass/index.html"
#define LICENSE_BROWSER      64
#define LICENSE_CEF_LINK     "file:///cef/amazing/license/index.html"
#define DOCUMENT_OFFER_BROWSER 65
#define DOCUMENT_OFFER_CEF_LINK "file:///cef/amazing/docoffer/index.html"
#define JOB_WIDGET_BROWSER 70
#define JOB_WIDGET_CEF_LINK "file:///cef/amazing/job/job_widget/index.html"
#define SKILL_BROWSER 71
#define SKILL_CEF_LINK "file:///cef/amazing/job/skill.html"
#define AVTOBUS_BROWSER 72
#define AVTOBUS_CEF_LINK "file:///cef/amazing/job/cefavtobus/index.html"
#define FACTORY_BROWSER 73
#define FACTORY_CEF_LINK "file:///cef/amazing/job/factory/index.html"


enum
{
    DIALOG_RESPONSE_CANCEL  = 0,
    DIALOG_RESPONSE_OK      = 1,
    DIALOG_RESPONSE_MIDDLE  = 2
}
new g_LeaderSkinTarget[MAX_PLAYERS] = {-1, ...};
