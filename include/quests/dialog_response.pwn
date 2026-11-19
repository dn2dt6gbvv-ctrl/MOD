case dialog_START_QUESTS:
{
    if (!response) return 1;
    if(PI[playerid][pQuest] != listitem) return SendErr(playerid, "Начните выполнение другого квеста!");
    PT[playerid][pQuestTemp] = listitem;
    ShowPlayerDialogEx(playerid, dialog_START_QUESTS+listitem+1, DIALOG_STYLE_MSGBOX, "Матвей. (OOC)", quest[listitem][q_description], quest[listitem][q_button1], quest[listitem][q_button2]);
}
case dialog_START_QUESTS+1:
{
    if (!response) return PT[playerid][pQuestTemp] = -1;
    ShowPlayerDialogEx(playerid, dialog_START_QUESTS+1+10, DIALOG_STYLE_LIST_TEXT, "Матвей. (OOC)", "{c9f600}Имеется ли у тебя опыт игры на различных проектах GTA по сети?\n{ff9945}1.{FFFFFF} Нет, ранее я не играл в GTA по сети\n{ff9945}2.{FFFFFF} Играл, но это было давно\n{ff9945}3. {FFFFFF}Играл, причем давно", "Выбрать", "Назад");
}
case dialog_START_QUESTS+11:
{
    if (!response) return PT[playerid][pQuestTemp] = -1;
    if(!listitem) return ShowPlayerDialogEx(playerid, dialog_START_QUESTS+1+10, DIALOG_STYLE_LIST_TEXT, "Матвей. (OOC)", "{c9f600}Имеется ли у тебя опыт игры на различных проектах GTA по сети?\n{ff9945}1.{FFFFFF} Нет, ранее я не играл в GTA по сети\n{ff9945}2.{FFFFFF} Играл, но это было давно\n{ff9945}3. {FFFFFF}Играл, причем давно", "Выбрать", "Назад");
    
    ApplyDynamicActorAnimation(quest_actor[0], "PED", "IDLE_CHAT", 4.0, false, false, false, false, 5000);
    GiveQuestReward(playerid, PT[playerid][pQuestTemp]);
    PT[playerid][pQuestTemp] = -1;
}
case dialog_MENU_QUEST:
{
    if(!response) return 1;
    switch(listitem)
    {
        case 0: ShowPlayerDialogEx(playerid, dialog_MENU_QUEST+1, DIALOG_STYLE_LIST, "Знакомство с игрой", "{ff9945}1. {FFFFFF}Посмотреть задание текущего квеста\n2{ff9945}. {FFFFFF}Узнать прогресс текущего квеста\n3{ff9945}. {FFFFFF}Местоположение игровых персонажей", "Выбрать", "Закрыть");
        case 1: SendClientMessage(playerid, COLOR_UNMAZING, "Будет добавлено потом.");
    }
}
case dialog_MENU_QUEST+1:
{
    if(!response) return 1;
    switch(listitem)
    {
        case 0: ShowPlayerDialogEx(playerid, dialog_OK, DIALOG_STYLE_MSGBOX, "Текущий квест", quest[PI[playerid][pQuest]][q_description], "Хорошо", "");
        case 1: SendClientMessage(playerid, COLOR_UNMAZING, "Будет добавлено потом.");
        case 2: SendClientMessage(playerid, -1, "Местоположение Матвея было отмечено на карте."), SetPlayerCheckpoint(playerid, 1914.7424,2089.6182,15.8720, 1.0);
    }
    
}
