#define MAX_SERVER_NAME 32
#define MAX_SERVER_SITE 56
#define MAX_SERVER_VERSION 8

new bool: IsServerRestarting;
new const SERVER_PASSCODE[] = "AgnlLJiqVXAUJyrHqieQABMUTYzV4625";

#define MAX_DATABASE_HOST 20
#define MAX_DATABASE_USER 30
#define MAX_DATABASE_DATABASE 30
#define MAX_DATABASE_PASSWORD 56

new MySQL: dbHandle;

new global_hour, global_minute, global_second;

new format_string[144];

enum E_SERVER_CONFIG
{
    ServerSite[MAX_SERVER_SITE],
    ServerName[MAX_SERVER_NAME],
    ServerVersion[MAX_SERVER_VERSION],
    ServerBonusMoney,
    ServerBonusLevel,
    ServerReferalLevel5Bonus,
    ServerReferalLevel10Bonus,
    ServerHost[MAX_DATABASE_HOST],
    ServerUser[MAX_DATABASE_USER],
    ServerDatabase[MAX_DATABASE_DATABASE],
    ServerPassword[MAX_DATABASE_PASSWORD]
};

new ServerConfig[E_SERVER_CONFIG];

stock ReadDataBaseConfig()
{
    new file = ini_openFile("database_settings.ini");
    ini_getString(file, "server_host", ServerConfig[ServerHost], sizeof(ServerConfig[ServerHost]));
    ini_getString(file, "server_user", ServerConfig[ServerUser], sizeof(ServerConfig[ServerUser]));
    ini_getString(file, "server_database", ServerConfig[ServerDatabase], sizeof(ServerConfig[ServerDatabase]));
    ini_getString(file, "server_password", ServerConfig[ServerPassword], sizeof(ServerConfig[ServerPassword]));


    dbHandle = mysql_connect(
        ServerConfig[ServerHost],
        ServerConfig[ServerUser],
        ServerConfig[ServerPassword],
        ServerConfig[ServerDatabase]
    );

    printf("mysql_connect(%s, %s, %s, %s)", ServerConfig[ServerHost], ServerConfig[ServerUser], ServerConfig[ServerPassword], ServerConfig[ServerDatabase]);
    ini_closeFile(file);
}

callback::LoadServerConfig()
{
    new rows, gametext[60];
    if(cache_get_row_count(rows) <= 0)
    {
        print("[LoadServerConfig]                             .");
        SendRconCommand("exit");
        return 0;
    }

    cache_get_value_name(0, "server_site", ServerConfig[ServerSite]);
    cache_get_value_name(0, "server_name", ServerConfig[ServerName]);
    cache_get_value_name(0, "server_version", ServerConfig[ServerVersion]);
    cache_get_value_name_int(0, "server_bonus_money", ServerConfig[ServerBonusMoney]);
    cache_get_value_name_int(0, "server_bonus_lvl", ServerConfig[ServerBonusLevel]);
    cache_get_value_name_int(0, "referal_5_lvl_bonus", ServerConfig[ServerReferalLevel5Bonus]);
    cache_get_value_name_int(0, "referal_10_lvl_bonus", ServerConfig[ServerReferalLevel10Bonus]);
    
    format(gametext, sizeof gametext, "language %02d:%02d:%02d [%s]", global_hour, global_minute, global_second, ServerConfig[ServerVersion]);
    SendRconCommand(gametext);

    format(gametext, sizeof gametext, "hostname %s / %s [BLACK]", ServerConfig[ServerSite], ServerConfig[ServerName]);
    SendRconCommand(gametext);

    format(gametext, sizeof gametext, "RolePlay [%s]", ServerConfig[ServerVersion]);
    SetGameModeText(gametext);
    return 1;
}
