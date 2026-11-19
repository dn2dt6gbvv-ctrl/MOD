case DIALOG_FAMILY_CREATE:
{
    if(!response) return 1;

    if(PI[playerid][pFamily] != 0) return SendErr(playerid, "Вы состоите уже в семье!");
    if(PI[playerid][pCash] < 3000000) return SendErr(playerid, "У вас недостаточно денег для создание семьи!");
    
    if(strlen(inputtext) < 4 || strlen(inputtext) > 24) 
    {
        SendErr(playerid, "Название семьи должно быть от 4 до 24 символов.");
        return ShowCreateFamilyDialog(playerid);
    }
    
    totalFamily++;
    new query[256];
    mysql_format(dbHandle, query, sizeof(query), "INSERT INTO family (id, family_name, leader, max_rang, members_family) VALUES ('%i','%s', %d, '5', '1')", totalFamily, inputtext, PI[playerid][pID]);
    mysql_tquery(dbHandle, query, "", "");

    PI[playerid][pFamily] = totalFamily;
    PI[playerid][pFRang] = 5;

    ShowPlayerDialogEx
    (
        playerid, DIALOG_FAMILY_NONE, DIALOG_STYLE_MSGBOX, 
        "Важная информация", 
        "{ffffff}Первым делом Вы должны настроить доступы для рангов в Вашей семье\n\
        {90af3a}Используйте /fmenu - Управление рангами - Управление доступов рангов\n\n\
        {ffffff}Внимательно изучите пункты и выставите ограничительные ранги\n\
        {ff6600}Игнорирования этого этапа может привести к различным проблемам", "Закрыть",""
    );
    TransferMoney(-1, playerid, -3000000, "Создание семьи");
    return 1;
}
case DIALOG_FAMILY_NONE:
{
    if(!response) return 1; if(response) return 1;
    return 1;
}
case DIALOG_FAMILY_MENU:
{
    if(PI[playerid][pFamily] == 0) return SendErr(playerid, "Вы не состоите в семье!");
    if(!response) return 1;

    new query[75];

    switch(listitem)
    {
        case 0: ShowFamilyInfo(playerid);
        case 1:
        {
            format(query, sizeof query, "SELECT id, name, family_rang FROM accounts WHERE family = %d", PI[playerid][pFamily]);
            mysql_tquery(dbHandle, query, "ShowFamilyMembers", "i", playerid);
        }
        case 3:
        {
            format(query, sizeof query, "SELECT max_rang FROM family WHERE id = %d", PI[playerid][pFamily]);
            mysql_tquery(dbHandle, query, "ShowFamilyRang", "i", playerid);
        }
        default: return 1;
    }
}
