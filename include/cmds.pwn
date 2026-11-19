#include "../include/admin/cmds.pwn"
#include "../include/admin/moderation.pwn"
#include "../include/admin/spec_cef.pwn"
#include "../include/staff_roles/cmds.pwn"

#include "../include/houses/cmds.pwn"
#include "../include/vehicles/cmds.pwn"

#include "../include/messages/cmds.pwn"
#include "../include/rent/cmds.pwn"

#include "../include/offers/cmds.pwn"

#include "../include/cef_system/cmds.pwn"

#include "../include/playerr_system/cmds.pwn"
#include "../include/raknet/cmds.pwn"
#include "../include/create_menu/cmds.pwn"
#include "../include/fractions/cmds.pwn"
#include "../include/gps/cmds.pwn"
#include "../include/families/cmds.pwn"

cmd:raknet(playerid)
{
    CallFunctionInScript("raknet", "SendRaknetDataToGameMode", "i", playerid);
    return 1;
}

cmd:new_dialog(playerid)
{
    ShowPlayerDialogEx(playerid, dialog_OK, DIALOG_STYLE_MSGBOX_PICTURE, "Я не знаю", "Посмотрим ладно", "Может", "А нет", "Не может", 3, "diamond_ore.png", "iron_ore.png", "gold_ore.png");
}

