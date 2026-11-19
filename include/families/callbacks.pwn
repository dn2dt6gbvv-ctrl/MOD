callback::LoadFamily()
{
    new time = GetTickCount(), rows = cache_num_rows();
    totalFamily = 0;
    new str[1024];
    if(rows)
	{
        for(new idx = 0; idx < rows; idx++)
		{
            cache_get_value_name_int(idx, "id", Family[idx][famID]);
            cache_get_value_name(idx, "family_name", Family[idx][famName], 32);
            cache_get_value_name_int(idx, "leader", Family[idx][famLeader]);
            cache_get_value_name_int(idx, "max_rang", Family[idx][famMaxRanks]);

            cache_get_value_name_int(idx, "members_family", Family[idx][famMembersCount]);
            cache_get_value_name_int(idx, "vouchers", Family[idx][famVouchers]);
            cache_get_value_name_int(idx, "house", Family[idx][famHouse]);
            cache_get_value_name_int(idx, "house_type", Family[idx][famtHouse]);

            cache_get_value_name_int(idx, "bank", Family[idx][famBank]);
            cache_get_value_name_int(idx, "warn", Family[idx][famWarn]);

            for(new i = 1; i <= Family[idx][famMaxRanks]; i++)
            {
                str = "";
                format(str, sizeof str, "rank%i_name", i);
                cache_get_value_name(idx, str, Family[idx][famRank], 32);
                printf(str);
            }
            totalFamily++;
        }
    }
    printf("[LoadFamily] Было загружено %d фракций(-я/и) за %d мс.", totalFamily, GetTickCount() - time);
    return 1;
}

stock ShowCreateFamilyDialog(playerid)
{
    ShowPlayerDialogEx
    (
        playerid, DIALOG_FAMILY_CREATE, DIALOG_STYLE_INPUT, 
        "СОЗДАНИЕ СЕМЬИ", 
        "{ffffff}Вы действительно хотите создать семью?\n\
        Стоимость: {2b6417}3 миллиона рублей\n\n\
        {ff6600}Предупреждение: передача денег через общак семьи запрещена\n\
        {ffffff}т.к. это считается махинацией с игровой валютой\n\n\
        Наказание могут получить все соучастники (вплоть до деактивации)\n\n\
        Название семьи не должно содержать:\n\
        - Нецензурные выражения\n\
        - Оскорбительные фразы\n\
        - Рекламу\n\n\
        В случае, если нарушен один из вышеперечисленных пунктов семьи может быть удалена\n\n\
        Введите название в строке ниже:", 
        "Создать", "Отмена"
    );
    return 1;
}
callback::ShowFamilyInfo(playerid)
{
    new idx = PI[playerid][pFamily];

    new query[75];
	format(query, sizeof query, "SELECT name FROM accounts WHERE id='%d'", Family[idx-1][famLeader]);
    mysql_tquery(dbHandle, query, "check_fleader", "i", playerid);
    return 1;
}
callback::ShowFamilyRang(playerid)
{
    new rows = cache_num_rows();

    new str[500];
    new fmt_str[45],
        text[1024];

    new idx = rows;

    cache_get_value_name_int(0, "id", Family[idx-1][famID]); 
    cache_get_value_name_int(0, "max_rang", Family[idx-1][famMaxRanks]);
    for(new j = 1; j < 10; j++)
    {
        for(new i = 1; i < 10; i++)
        {
            format(str, sizeof str, "rank%i_name", i);
            cache_get_value_name(0, str, Family[idx][famRank], 32);
        }
        format(fmt_str, sizeof fmt_str, "\n{e69348}%i.{ffffff}%s", j, Family[idx-1][famRank]);
		strcat(text, fmt_str);
    }
    ShowPlayerDialogEx(playerid, dialog_OK, DIALOG_STYLE_LIST, "ЧЛЕНЫ СЕМЬИ", fmt_str, "ВЫБРАТЬ", "ЗАКРЫТЬ");
    return 1;
}
callback::ShowFamilyMembers(playerid)
{
    if(PI[playerid][pFamily] == -1) return SendErr(playerid, "Вы не состоите в семье");

    new rows = cache_num_rows();
    
    new idx, j = rows;
    new str[44];

    new fmt_str[100];
    new text[1024];

    for(idx = 0; idx < j; idx ++)
	{
        cache_get_value_name_int(idx, "id", PI[j][pID]);
		cache_get_value_name(idx, "name", PI[j][pName], 32);
        cache_get_value_name_int(idx, "family_rang", PI[j][pFRang]);

		for(new i = 1; i <= Family[j-1][famMaxRanks]; i++)
        {
            str = "";
            format(str, sizeof str, "rank%i_name", PI[PI[j][pID]][pFRang]);
            cache_get_value_name(idx, str, Family[j-1][famRank], 32);
        }
		format(fmt_str, sizeof fmt_str, "\t\t\t\n%s\t%s", PI[j][pName], Family[j-1][famRank]);
		strcat(text, fmt_str);
	}



    ShowPlayerDialogEx(playerid, dialog_OK, DIALOG_STYLE_TABLIST_HEADERS, "ЧЛЕНЫ СЕМЬИ", fmt_str, "ВЫБРАТЬ", "ЗАКРЫТЬ", "ДАЛЕЕ");
    SCMF(playerid, -1, "Было показано %d членов семьи", j);

    return 1;
}
callback:: check_fleader(playerid)
{
    if(cache_num_rows())
	{
        cache_get_value_name(0, "name", PlayerFamLeaderName[playerid], 32);

        new idx = PI[playerid][pFamily];
        new str_type[100],
            str_int[100];

        switch(Family[idx-1][famtHouse])
        {
            case -1: format(str_type, sizeof str_type, "{ffffff}");
            case 1: format(str_type, sizeof str_type, "{ffffff}Семейный особняк");
            case 2: format(str_type, sizeof str_type, "{ffffff}Общежите");
        }

        switch(Family[idx-1][famHouse])
        {
            case -1: format(str_int, sizeof str_int, "");
            default: format(str_int, sizeof str_int, "{95c20e}%d", Family[idx-1][famHouse]);
        }

        new fmt_global[500];
        format
        (
            fmt_global,
            sizeof fmt_global,
            "{ffffff}Название\t{e69348}%s(№%i)\n\
            {ffffff}Глава\t{DD99FF}%s\n\
            {ffffff}Членов семьи\t{4F84BA}%i чел.\n\
            {ffffff}Баланс общака\t{95c20e}%s\n\
            {ffffff}Предупреждения\t{e69348}0/5\n\
            %s\t%s", 
            GetFamilyName(idx-1), 
            idx, 
            PlayerFamLeaderName[playerid],
            Family[idx-1][famMembersCount],
            SplitInt(Family[idx-1][famBank]),
            Family[idx-1][famWarn],
            str_type,
            str_int
        );
        ShowPlayerDialogEx(playerid, DIALOG_FAMILY_INFO, DIALOG_STYLE_MSGBOX, "СЕМЬЯ", fmt_global, "Закрыть","");
    }
    return 1;
}
