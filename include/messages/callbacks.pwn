callback:: OnPlayerOpenMessagesMenu(playerid)
{
    new row_count = 0;
    cache_get_row_count(row_count);
    if(row_count <= 0) return SendErr(playerid, "Оповещений не найдено.");

    return ShowPlayerDialogEx(playerid, dialog_NOTIFICATION, DIALOG_STYLE_LIST, "Почта", "{e69348}1. {FFFFFF}Непрочитанные сообщения\n{e69348}2. {FFFFFF}Вся почта", "Открыть", "Отмена");











      
}

callback:: OpenPlayerMailBox(playerid, read)
{
    new row_count = 0;
    cache_get_row_count(row_count);
    if(row_count <= 0) return SCMF(playerid, -1, "%s не найдено.", read == 1 ? "Непрочитанных сообщений" : "Сообщений");

    new text[256], mesid, date[32], temp[144], m_s[512] = "{e69348}Отправитель\tДата\tСтатус", message_read;

                                      
    for(new m; m < row_count; m++)
    {
        cache_get_value_name_int(m, "id", mesid);
        cache_get_value_name_int(m, "message_read", message_read);

        if(read != 0 && message_read != read) continue;
        cache_get_value_name(m, "date", date);
        cache_get_value_name(m, "text", text);

        format(temp, sizeof temp, "{e69348}1. {FFFFFF}%d. Система\t%s\t%s", m + 1, date, message_read == 0 ? "Не просмотрено" : "Просмотрено");
        strcat(m_s, temp);
    }
    return ShowPlayerDialogEx(playerid, dialog_NOTIFICATION + 1, DIALOG_STYLE_TABLIST_HEADERS, "Почта", m_s, "Открыть", "Отмена");
}

callback:: OnPlayerReadMessage(playerid, listitem)
{
    if (!cache_num_rows()) return;

    new date[20], str[256], header[32], important, id;

    cache_get_value_name(listitem, "date", date);
    cache_get_value_name(listitem, "text", str);
    cache_get_value_name(listitem, "header", header);
    cache_get_value_name_int(listitem, "important", important);
    cache_get_value_name_int(listitem, "id", id);

    ShowPlayerDialogEx(playerid, dialog_OK, DIALOG_STYLE_MSGBOX, header, str, "Закрыть", "");

    new query[100];
    mysql_format(dbHandle, query, sizeof(query), "UPDATE `messages` SET `message_read` = 1 WHERE `id` = %d", id);
    mysql_tquery(dbHandle, query, "", "");
}

stock SendMessage(acc_id, text[], important = 0, header[] = "Система")
{
    foreach(new i : Player)
    {
        if(acc_id != PI[i][pID]) continue;
        SendClientMessage(i, -1, text);
        return 1;
    }

    new query[312];

    mysql_format(dbHandle,query, sizeof(query), "INSERT INTO `messages` (`recipient_id`, `text`, `date`, `important`, `header`) VALUES (%d, '%e', NOW(), %d, '%e')", acc_id, text, important, header);
    mysql_tquery(dbHandle, query, "", "");
    return 1;
}

callback:: LoadMessages(playerid)
{
    new row_count = 0;
    cache_get_row_count(row_count);
    if(row_count) 
    {
        new text[256], mesid, date[32], unread_messages;

                                             
        cache_get_value_name(0, "date", date);
        cache_get_value_name_int(0, "id", mesid);
        cache_get_value_name_int(0, "unread_messages", unread_messages);
        cache_get_value_name(0, "text", text);

        SCMF(playerid, -1, "{FFFFFF}У вас %d непрочитанных сообщений! Используйте /mail для просмотра.", unread_messages);

        new temp[40];
        format(temp, sizeof temp, "{FFFFFF}Сообщение было отправлено в {e69348}\t\t%s\n{FFFFFF}Отправитель\t\t{e69348}Система\n\nСодержание:\n%s", date, text);
        ShowPlayerDialogEx(playerid, dialog_OK, DIALOG_STYLE_MSGBOX, "Сообщение", temp, "", "Закрыть");

        new query[312];
        mysql_format(dbHandle,query, sizeof(query), "UPDATE `messages` SET `message_read` = 1 WHERE `id` = %d", mesid);
        mysql_tquery(dbHandle, query, "", "");
    }
    else return 0;
    return 1;
}
