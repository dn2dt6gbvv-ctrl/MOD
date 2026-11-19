case dialog_SETSPAWN:
{
    if(!response) return 1;

    switch(listitem)
    {
        case 0:
        {
            SendClientMessage(playerid, COLOR_UNMAZING, "Вы выбрали вокзал местом спавна.");
        }
        case 1:
        {
            if(GetPlayerHouseID(playerid) == 0) return SendErr(playerid, "У Вас нет дома!");
            
            SendClientMessage(playerid, COLOR_UNMAZING, "Вы выбрали свой дом местом спавна.");
        }
        case 2:
        {
            if(PI[playerid][pFraction] <= 0) return SendErr(playerid, "Вы не состоите в организации!");
            
            SendClientMessage(playerid, COLOR_UNMAZING, "Вы выбрали организацию местом спавна.");
        }
    }
    PI[playerid][pSpawn] = listitem;
}
case dialog_MENU:
{
    if(!response) return 0;








    switch(listitem)
    {
        case 0:
        {
            new string[712]; 
            format(string, sizeof string, 
            "{FFFFFF}Имя\t{e69348}%s\n{FFFFFF}Пол\t{e69348}%s\n{FFFFFF}Уровень\t{e69348}%d (%d/%d)\n\n\
            {FFFFFF}Наличные\t{e69348}%s руб.\n{FFFFFF}Деньги в банке\t{e69348}%s руб.\n\
            {FFFFFF}Телефон\t{e69348}%s\n{FFFFFF}Мобильный счет\t{e69348}%s\n\n\
            {FFFFFF}Военный билет\t{e69348}%s\n{FFFFFF}Розыск\t{e69348}%s\n{FFFFFF}Законопослушность\t{e69348}%d\n{FFFFFF}Наркозависимость\t{e69348}%s\n{FFFFFF}Бизнес\t{e69348}%s\n\n\
            {FFFFFF}Организация\t{e69348}%s\n\n\
            {FFFFFF}Работа\t{e69348}%s\n{FFFFFF}Проживание\t{e69348}%s\n{FFFFFF}Семья\t{e69348}%s", 
            GetName(playerid),
            PI[playerid][pSex] ? "Мужской" : "Женский",
            PI[playerid][pLevel], PI[playerid][pExp], PI[playerid][pExp] * 4,
            SplitInt(PI[playerid][pCash]), SplitInt(PI[playerid][pBank]),
            "Нет", "0 руб.",
            PT[playerid][pVchBilyet] ? "Имеется" : "Отсутствует",
            GetVarAsString(PI[playerid][pWanted]), PI[playerid][pLegality], GetVarAsString(PI[playerid][pDrugAddiction]), "Нет",
            Fraction[PI[playerid][pFraction]][fName],
            "Нет",
            GetVarAsString(GetPlayerHouseID(playerid)),
            "Нет (ID: 0)");

            ShowPlayerDialogEx(playerid, dialog_MENU + 10, DIALOG_STYLE_MSGBOX, "Статистика персонажа", string, "Назад", "");
        }
        case 1:
        {
            ShowPlayerDialogEx(playerid, dialog_MENU + 1, DIALOG_STYLE_LIST, "Команды сервера", 
           "{e69348}1. {FFFFFF}Команды организаций\n\
            {e69348}2. {FFFFFF}Команды работ\n\
            {e69348}3. {FFFFFF}Команды семьи\n\
            {e69348}4. {FFFFFF}Команды имущества\n\
            {e69348}5. {FFFFFF}Команды обещения\n\
            {e69348}6. {FFFFFF}Остальные команды", 
            "Выбрать", "Назад");
        }
    }
}

case dialog_MENU + 1:
{
    if(!response) return ShowPlayerMenuDialog(playerid);
    switch(listitem)
    {
        case 0:
        {
            new frac_string[MAX_FRACTIONS_NAME * MAX_FRACTIONS] = "{e69348}1. {FFFFFF}Для всех организаций\n";
            new temp_string[MAX_FRACTIONS_NAME * 2];

            new i;
            for(i = 1; i < totalFractions; i++)
            {
                format(temp_string, sizeof temp_string, "{e69348}%d. {FFFFFF}%s\n", i + 1, GetFractionName(i));
                strcat(frac_string, temp_string);
            }

            format(temp_string, sizeof temp_string,"{e69348}%d. {FFFFFF}Лидерам и заместителям", i + 1);
            strcat(frac_string, temp_string);

            ShowPlayerDialogEx(playerid, dialog_MENU + 10, DIALOG_STYLE_LIST, "Команды организаций", frac_string, "Выбрать", "Назад");
        }
    }
}

case dialog_MENU + 10:
{
    ShowPlayerMenuDialog(playerid);
}
case dialog_PASS_FIRSTNAME:
{
    if(!response) return 1;

    new len = strlen(inputtext);
    while(len > 0 && (inputtext[len - 1] == ' ' || inputtext[len - 1] == '\r' || inputtext[len - 1] == '\n' || inputtext[len - 1] == '\t'))
    {
        inputtext[len - 1] = '\0';
        len--;
    }

    if(len < 2 || len > 24)
    {
        SendErr(playerid, "Некорректная длина! Имя должно быть от 2 до 24 символов.");
        return ShowPlayerDialogEx(playerid, dialog_PASS_FIRSTNAME, DIALOG_STYLE_INPUT, 
            "{e69348}ПОЛУЧЕНИЕ ПАСПОРТА | ШАГ 1", 
            "{FFFFFF}Введите Ваше {e69348}Имя{FFFFFF} английскими буквами:\n\n{99cc00}Пример: Ivan", 
            "Далее", "Выход");
    }

    for(new i = 0; i < len; i++)
    {
        if(!((inputtext[i] >= 'A' && inputtext[i] <= 'Z') || (inputtext[i] >= 'a' && inputtext[i] <= 'z')))
        {
            SendErr(playerid, "Недопустимые символы! Используйте только английские буквы (A-Z, a-z).");
            return ShowPlayerDialogEx(playerid, dialog_PASS_FIRSTNAME, DIALOG_STYLE_INPUT, 
                "{e69348}ПОЛУЧЕНИЕ ПАСПОРТА | ШАГ 1", 
                "{FFFFFF}Введите Ваше {e69348}Имя{FFFFFF} английскими буквами:\n\n{99cc00}Пример: Ivan", 
                "Далее", "Выход");
        }
    }

    strmid(PI[playerid][pRuFirstName], inputtext, 0, len, 32);
    ShowPlayerDialogEx(playerid, dialog_PASS_LASTNAME, DIALOG_STYLE_INPUT, 
        "{e69348}ПОЛУЧЕНИЕ ПАСПОРТА | ШАГ 2", 
        "{FFFFFF}Введите Вашу {e69348}Фамилию{FFFFFF} английскими буквами:\n\n{99cc00}Пример: Ivanov", 
        "Далее", "Назад");
}

case dialog_PASS_LASTNAME:
{
    if(!response) 
    {
        return ShowPlayerDialogEx(playerid, dialog_PASS_FIRSTNAME, DIALOG_STYLE_INPUT, 
            "{e69348}ПОЛУЧЕНИЕ ПАСПОРТА | ШАГ 1", 
            "{FFFFFF}Введите Ваше {e69348}Имя{FFFFFF} английскими буквами:\n\n{99cc00}Пример: Ivan", 
            "Далее", "Выход");
    }
    new len = strlen(inputtext);
    while(len > 0 && (inputtext[len - 1] == ' ' || inputtext[len - 1] == '\r' || inputtext[len - 1] == '\n' || inputtext[len - 1] == '\t'))
    {
        inputtext[len - 1] = '\0';
        len--;
    }

    if(len < 2 || len > 24)
    {
        SendErr(playerid, "Некорректная длина! Фамилия должна быть от 2 до 24 символов.");
        return ShowPlayerDialogEx(playerid, dialog_PASS_LASTNAME, DIALOG_STYLE_INPUT, 
            "{e69348}ПОЛУЧЕНИЕ ПАСПОРТА | ШАГ 2", 
            "{FFFFFF}Введите Вашу {e69348}Фамилию{FFFFFF} английскими буквами:\n\n{99cc00}Пример: Ivanov", 
            "Далее", "Назад");
    }
    for(new i = 0; i < len; i++)
    {
        if(!((inputtext[i] >= 'A' && inputtext[i] <= 'Z') || (inputtext[i] >= 'a' && inputtext[i] <= 'z')))
        {
            SendErr(playerid, "Недопустимые символы! Используйте только английские буквы (A-Z, a-z).");
            return ShowPlayerDialogEx(playerid, dialog_PASS_LASTNAME, DIALOG_STYLE_INPUT, 
                "{e69348}ПОЛУЧЕНИЕ ПАСПОРТА | ШАГ 2", 
                "{FFFFFF}Введите Вашу {e69348}Фамилию{FFFFFF} английскими буквами:\n\n{99cc00}Пример: Ivanov", 
                "Далее", "Назад");
        }
    }
    strmid(PI[playerid][pRuLastName], inputtext, 0, len, 32);
    ShowPlayerDialogEx(playerid, dialog_PASS_DATE, DIALOG_STYLE_INPUT, 
        "{e69348}ПОЛУЧЕНИЕ ПАСПОРТА | ШАГ 3", 
        "{FFFFFF}Введите Вашу дату рождения в формате {99cc00}ДД.ММ.ГГГГ\n\n{FFFFFF}Пример: 15.05.2000", 
        "Далее", "Назад");
}

case dialog_PASS_DATE:
{
    if(!response) 
    {
        return ShowPlayerDialogEx(playerid, dialog_PASS_LASTNAME, DIALOG_STYLE_INPUT, 
            "{e69348}ПОЛУЧЕНИЕ ПАСПОРТА | ШАГ 2", 
            "{FFFFFF}Введите Вашу {e69348}Фамилию{FFFFFF} английскими буквами:\n\n{99cc00}Пример: Ivanov", 
            "Далее", "Назад");
    }

    new len = strlen(inputtext);
    while(len > 0 && (inputtext[len - 1] == ' ' || inputtext[len - 1] == '\r' || inputtext[len - 1] == '\n' || inputtext[len - 1] == '\t'))
    {
        inputtext[len - 1] = '\0';
        len--;
    }

    if(len != 10 || inputtext[2] != '.' || inputtext[5] != '.')
    {
        SendErr(playerid, "Неверный формат даты! Используйте ДД.ММ.ГГГГ");
        return ShowPlayerDialogEx(playerid, dialog_PASS_DATE, DIALOG_STYLE_INPUT, 
            "{e69348}ПОЛУЧЕНИЕ ПАСПОРТА | ШАГ 3", 
            "{FFFFFF}Введите Вашу дату рождения в формате {99cc00}ДД.ММ.ГГГГ\n\n{FFFFFF}Пример: 15.05.2000", 
            "Далее", "Назад");
    }

    strmid(PI[playerid][pBirthDate], inputtext, 0, 12, 12);
    PI[playerid][pHasPassport] = true;

    ShowPlayerDialogEx(playerid, dialog_PASS_FINISH, DIALOG_STYLE_MSGBOX, 
        "{e69348}Успех!", 
        "{FFFFFF}Поздравляем! Вы успешно заполнили бланки и получили свой паспорт.\n\n\
        Посмотреть его в любой момент можно командой: {99cc00}/test_pass", 
        "Отлично", "");
}
