case dialog_FIXCAR:
{
    if(!response) return 1;
    new query[140];

    mysql_format(dbHandle, query, sizeof(query), "SELECT * FROM `cars` WHERE `owner_id` = %d", PI[playerid][pID]);
    mysql_tquery(dbHandle, query, "OnPlayerFixCarSelected", "ii", playerid, listitem);
}
