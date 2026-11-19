cmd:mail(playerid)
{
    new query[140];

    mysql_format(dbHandle, query, sizeof(query), "SELECT * FROM `messages` WHERE `recipient_id` = %d ORDER BY `important` DESC, `date` DESC", PI[playerid][pID]);
    mysql_tquery(dbHandle, query, "OnPlayerOpenMessagesMenu", "i", playerid);
    return 1;
}
