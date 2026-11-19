gettime(global_hour, global_minute, global_second);

if(global_minute == 00 && global_second == 00)
{
    if(global_hour == 0)
    {
        mysql_tquery(dbHandle, "UPDATE `accounts` SET `jerk` = '0' WHERE `jerk` > '0'", "");
        foreach(new i : Player)
        {
            if(PI[i][pJerk] > 0) PI[i][pJerk] = 0;
        }
    }
    SetWorldTime(global_hour);
    #include "../include/houses/auto_sell.pwn"
}
if(global_minute == 15 && global_second == 00 || global_minute == 30 && global_second == 00 || global_minute == 45 && global_second == 00 || global_minute == 00 && global_second == 00)
{
    new r = random(2);
    ad_timer(r);
}
if(global_hour == 6)
{
    if(global_minute == 0 && global_second == 0)
    {
        SendClientMessageToAll(COLOR_UNMAZING, "¬нимание, через 5 минут будет технический рестарт сервера!");
    }

    if(global_minute == 5 && global_second == 0)
    {
        SendClientMessageToAll(-1, "ѕроисходит технический рестарт сервера!");
        foreach(new i : Player) 
        {
            Kick(i);
        }
        IsServerRestarting = true;
    }

    if(global_minute == 5 && global_second == 15)
    {
        print("The GMX command was called!");
        SendRconCommand("gmx");
    }
}
CheckNewsTimer();
if(global_second == 0) CheckTrainCrashTime();
if(global_second == 0) CleanExpiredSOS();
