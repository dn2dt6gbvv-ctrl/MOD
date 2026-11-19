#pragma dynamic 40000
#include <a_samp>
#include <a_mysql>
#include <Pawn.CMD>
#include <sscanf2>
#include <streamer>
#include <foreach>
#include <cef>
#include <crashdetect>
#include <chatclear>
#include <Pawn.RakNet>
#include <PointToPoint>
#include <mxini>
#include <YSF>
#include <fix_Kick>

#include "../include/macroses.pwn"
#include "../include/definitions.pwn"
#include "../include/car_dealship/config.pwn"
#include "../include/cef_amazing/cef_bridge.pwn"
#include "../include/cef_amazing/cef_systems_scaffold.pwn"
#include "../include/cef_amazing/cef_catalog.pwn"
#include "../include/cef_amazing/cef_unmazing_bind.pwn"
#include "../include/cef_amazing/cef_live_systems.pwn"
#include "../include/staff_roles/definitions.pwn"
#include "../include/staff_roles/promo_point.pwn"
#include "../include/offers/definitions.pwn"
#include "../include/cef_system/radial_menu.pwn"
#include "../include/cef_system/chat.pwn"

main() print("Unmazing gamemode");

#include "../include/global/server_config.pwn"
#include "../include/global/dynamic_doors.pwn"

public OnGameModeInit() {
    #include "../include/map_objects.pwn"
    #include "../include/cef_system/subscribings.pwn"
    SetTimer("CEFC_HudTick", 1000, true);
    SetTimer("CEFC_SpeedoTick", 150, true);
    #include "../include/global/server_init.pwn"
    CEF_LiveInit();
    CEF_FinesInit();
    DS_Init();
}

public OnGameModeExit() {
    DS_Shutdown();
    #include "../include/global/server_exit.pwn"
}

callback::ServerUpdate() {
    #include "../include/global/server_update.pwn"
}

#include "../include/fractions/workbook.pwn"
#include "../include/fractions/arrest.pwn"
#include "../include/fractions/zakladki.pwn"
#include "../include/fractions/mining.pwn"
#include "../include/jobs/definitions.pwn"
#include "../include/jobs/compat.pwn"
#include "../include/jobs/schema.pwn"
#include "../include/jobs/skills.pwn"
#include "../include/cef_system/widget.pwn"
#include "../include/jobs/avtobus.pwn"
#include "../include/jobs/factory.pwn"
#include "../include/jobs/mechanic.pwn"
#include "../include/jobs/razvoz.pwn"
#include "../include/cef_amazing/cef_compat.pwn"
#include "../include/callbacks.pwn"
#include "../include/cef_amazing/cef_casino.pwn"
#include "../include/cef_amazing/cef_ops.pwn"
#include "../include/inventory_system/personal_storage.pwn"
#include "../include/cef_amazing/cef_player_trade.pwn"
#include "../include/cef_amazing/cef_cases.pwn"
#include "../include/cef_amazing/cef_progress.pwn"
#include "../include/cef_amazing/cef_needs.pwn"
#include "../include/cef_amazing/cef_donate_shop.pwn"
#include "../include/cef_amazing/cef_tau_meter.pwn"
#include "../include/cef_amazing/cef_fines_radar.pwn"

#include "../include/cef_system/train_crash.pwn"
#include "../include/cef_system/tab_cef.pwn"
#include "../include/cef_amazing/cef_connect_all.pwn"
#include "../include/cef_amazing/cef_hotkeys.pwn"
#include "../include/cef_amazing/cef_all_screens.pwn"
#include "../include/fractions/find.pwn"
#include "../include/cmds.pwn"
#include "../include/fractions/ticket_cef.pwn"
#include "../include/fractions/pps.pwn"
#include "../include/fractions/vch.pwn"
#include "../include/fractions/sos.pwn"
#include "../include/fractions/news.pwn"

#include "../include/fractions/leaderskin.pwn"
#include "../include/fractions/fraction_systems.pwn"
#include "../include/fractions/frisk.pwn"
#include "../include/fractions/fsbpanel.pwn"
#include "../include/fractions/udostoverenie.pwn"


stock LoadOther()
{
    #include "../include/car_dealship/load_car_dealship.pwn"
    #include "../include/jerk/load_jerk.pwn"
    #include "../include/parking/load_parking.pwn"
    #include "../include/quests/load_quests.pwn"
    #include "../include/rent/load_rent.pwn"
    #include "../include/pickup/load_pickup.pwn"
    #include "../include/objects.pwn"
}

#include "../include/time_widget.pwn"
#include "../include/weapons/baton_taser.pwn"

#include "../include/houses/housecreate.pwn"
#include "../include/car_dealship/system.pwn"
