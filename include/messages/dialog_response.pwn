case dialog_NOTIFICATION:
{
    if(!response) return 0;

    new query[160];
    mysql_format(dbHandle, query, sizeof(query),
        "SELECT * FROM `messages` WHERE `recipient_id` = %d ORDER BY `important` DESC, `date` DESC", PI[playerid][pID]);
    mysql_tquery(dbHandle, query, "OpenPlayerMailBox", "ii", playerid, listitem == 1 ? 1 : 0);

    return 1;
}

case dialog_NOTIFICATION + 1:
{
    new query[160];
    if(!response)
    {
        mysql_format(dbHandle, query, sizeof(query), "SELECT * FROM `messages` WHERE `recipient_id` = %d ORDER BY `important` DESC, `date` DESC", PI[playerid][pID]);
        mysql_tquery(dbHandle, query, "OnPlayerOpenMessagesMenu", "i", playerid);
        return 1;
    }

    mysql_format(dbHandle, query, sizeof(query),
        "SELECT * FROM `messages` WHERE `recipient_id` = %d ORDER BY `important` DESC, `date` DESC", PI[playerid][pID]);
    mysql_tquery(dbHandle, query, "OnPlayerReadMessage", "ii", playerid, listitem);
    return 1;
}
