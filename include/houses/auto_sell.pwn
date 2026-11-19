        for(new h; h < total_houses; h++)
        {
            if(strcmp(House[h][hOwner], "None", true) == 0 || House[h][hOwnerID] == 0) continue;
            House[h][hHours]--;

            new query[128];
            if(House[h][hHours] <= 0)
            {
                new owner_id = GetPlayerID(House[h][hOwner]);
                if(owner_id != INVALID_PLAYER_ID && PT[owner_id][pLogged] == true) 
                {
                    PI[owner_id][pSpawn] = 0;
                    PI[owner_id][pCash] += House[h][hPrice]/2;
                }

                mysql_format(dbHandle,query, sizeof(query), "UPDATE `accounts` SET `home`= 0, `cash` = `cash` + %d, `spawn` = 0 WHERE `id` = %u", House[h][hPrice]/2, House[h][hOwnerID]);
                mysql_tquery(dbHandle, query, "", "");
                
                SendMessage(House[h][hOwnerID], "Ваш дом был продан за неуплату налогов.", 1);
            
                new house_text[128];
                format(house_text, sizeof house_text, "Дом %d был продан государству за неуплату налогов.", House[h][hID]);
                SendClientMessageToAll(-1, house_text);

                settext(House[h][hOwner], "None");
                House[h][hHours] = 0;

                SetPickupModel(House[h][hPickup], 11776);
                DestroyDynamicMapIcon(House[h][hMapIcon]); House[h][hMapIcon] = CreateDynamicMapIcon(House[h][hPos_x], House[h][hPos_y], House[h][hPos_z], 31, 0,-1,-1,-1,150.0);  

                mysql_format(dbHandle,query, sizeof(query), "UPDATE `houses` SET `owner_id`= 0 WHERE `id` = %u", House[h][hID]);
                mysql_tquery(dbHandle, query, "", "");
            }
            else
            { 
                mysql_format(dbHandle,query, sizeof(query), "UPDATE `houses` SET `hours`= %d WHERE `id` = %u", House[h][hHours], House[h][hID]);
                mysql_tquery(dbHandle, query, "", "");
            }
        }
