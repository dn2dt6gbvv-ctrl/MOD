cmd:fmenu(playerid)
{
    if(PI[playerid][pFamily] == 0) return SendErr(playerid, "Вы не состоите в семье!");

    ShowPlayerDialogEx
    (
        playerid, DIALOG_FAMILY_MENU , DIALOG_STYLE_LIST, 
        "СЕМЬЯ", 
        "Информация о семье\n\
        {e69348}1. {ffffff}Управление членами семьи\n\
        {e69348}2. {ffffff}Управление транспортом\n\
        {e69348}3. {ffffff}Управление рангами\n\
        {e69348}4. {ffffff}Уведомление семьи\n\
        {e69348}5. {ffffff}История общака\n\
        {e69348}6. {ffffff}Предупреждение семьи\n\
        {e69348}Ваучеры семьи\n\
        {8e3132}Ежедневные задания", 
        "Выбрать", "Отмена"
    );
    return 1;
}
