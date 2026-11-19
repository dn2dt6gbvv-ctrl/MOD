stock GiveQuestReward(playerid, questid)
{
    new string[128] = "Вы выполнили квест. Поговорите с Матвеем, чтобы начать следующее задание\n\n{ff9945}Ваша награда:\n", tmp_str[24];
    if(quest[questid][q_money])
    {
        format(tmp_str, sizeof tmp_str, "{FFFFFF}— %s рублей", SplitInt(quest[questid][q_money]));
        strcat(string, tmp_str);
        TransferMoney(-1, playerid, quest[questid][q_money], "Выполнение квеста");
    }

    if(quest[questid][q_exp])
    {
        format(tmp_str, sizeof tmp_str, "{FFFFFF}— %d EXP", quest[questid][q_exp]);
        strcat(string, tmp_str);
        PI[playerid][pExp] += quest[questid][q_exp];
    }

    if(quest[questid][q_donate])
    {
        format(tmp_str, sizeof tmp_str, "{FFFFFF}— %d амазингов");
        strcat(string, tmp_str);
        PI[playerid][pDonate] += quest[questid][q_donate];
    }
    questid++;
    PI[playerid][pQuest] = questid;
    PI[playerid][pQuestProgress] = 100;
    ShowPlayerDialogEx(playerid, dialog_OK, DIALOG_STYLE_MSGBOX, "Задание выполнено", string, "Выбрать", "Назад");
}

stock LoadStartsQuests(playerid)
{
    new string[512];
    format(string, sizeof string, "Начните выполнение квеста {e69348}\"%s\"{FFFFFF}!\tВыполняя квесты, Вы будете знакомиться с игрой и получать различные подарки!\n", quest[PI[playerid][pQuest]][q_name]);
    
    new tmp_str[56];
    for(new i; i < sizeof quest; i++)
    {
        if(quest[i][q_type] == 1)
        {
            format(tmp_str, sizeof tmp_str, "{ff9945}%d. {FFFFFF}%s\n", i+1, quest[i][q_name]);
            strcat(string, tmp_str); 
        }
    }

    delEscapeChar(string);
    ShowPlayerDialogEx(playerid, dialog_START_QUESTS, DIALOG_STYLE_LIST_TEXT, "Матвей.", string, "Выбрать", "Назад");
    return 1;
}
