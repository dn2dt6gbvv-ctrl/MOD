case dialog_REG: 
{
    if(!response || strlen(inputtext) < 6 || strlen(inputtext) > 15)
        return CEF_AuthSignUp(playerid, DIALOG_STYLE_PASSWORD, "Регистрация", "Добро пожаловать на сервер {FF9945}Unmazing\n{FFFFFF}Пароль должен быть длиной от 6 до 15 символов.", "Далее", "Выход");
    ShowPlayerDialogEx(playerid, dialog_REG+1, DIALOG_STYLE_MSGBOX, "Выбор пола", "Выберите ваш пол", "Мужской", "Женский");
    settext(PI[playerid][pPassword], inputtext);
} 

case dialog_REG+1: 
{
    PI[playerid][pSex] = response;

    ShowPlayerDialogEx(playerid, dialog_REG+2, DIALOG_STYLE_INPUT, "Промокод", "Если Вас на сервер пригласил {FF9945}друг{FFFFFF} или {1e90ff}ютубер{FFFFFF}, или у Вас имеется промокод, \nто Вы можете ввести его в поле ниже, {FF9945}получив за него награду\n\n\
    Вы также можете сделать это после регистрации при помощи команды {99cc00} /menu (7-й пункт) {FFFFFF}до 5-го уровня включительно", "Ввести", "Пропустить");
}

case dialog_REG+2: 
{
    if(response && strlen(inputtext) > 31)
        return ShowPlayerDialogEx(playerid, dialog_REG+2, DIALOG_STYLE_INPUT, "Промокод", "Промокод не должен быть длиннее 31 символа. Его можно пропустить.", "Далее", "Пропустить");
    if(response) settext(PI[playerid][pPromocode], inputtext);
    else PI[playerid][pPromocode][0] = EOS;
    PI[playerid][pPromocodeId] = 0;

    new query[160];
    mysql_format(dbHandle, query, sizeof(query), "SELECT `id` FROM `promocodes` WHERE `promocode_name` = '%e' LIMIT 1", PI[playerid][pPromocode]);
    mysql_tquery(dbHandle, query, "OnPlayerRegister", "iii", playerid, response, PT[playerid][pAuthSession]);
}

case dialog_LOGIN:
{
    if(!response) return Kick(playerid);
    return CEF_AuthSignIn(playerid, DIALOG_STYLE_PASSWORD, "Авторизация", "Введите пароль от аккаунта.", "Войти", "Выход");
}

case dialog_LOGIN + 4:
{
    if(!response) return Kick(playerid);
    if(strcmp(inputtext, SERVER_PASSCODE, false) != 0 || isnull(inputtext))
    {
        PT[playerid][pLoginAttempts]--;
        if(PT[playerid][pLoginAttempts] <= 0)
        {
            SendClientMessage(playerid, COLOR_RED, "Вы исчерпали все попытки ввода кода доступа. Вы будете отключены от сервера.");
            Kick(playerid);
            return 1;
        }
        ShowPlayerDialogEx(playerid, dialog_LOGIN + 4, DIALOG_STYLE_INPUT, "Ошибка", "Неверный код доступа!", "ОК", "Отказаться");
        return 1;
    }

    new query[] = "SELECT `password` FROM `accounts` WHERE `name` = '%e' LIMIT 1";
    new fmt_query[sizeof query + MAX_PLAYER_NAME];

    mysql_format(dbHandle, fmt_query, sizeof(fmt_query), query, PI[playerid][pName]);
    mysql_tquery(dbHandle, fmt_query, "CheckAccount", "ii", playerid, PT[playerid][pAuthSession]);
    return 1;
}
