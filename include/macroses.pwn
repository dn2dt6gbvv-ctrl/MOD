#define OFFER_HOUSE     1

#define unLoggedMessage "Вы не авторизированы!"
#define messageUnknownCMD        "{F8FAFA}Команда не обнаружена! {F8FAFA}Используйте {FF9900}/menu {F8FAFA}для просмотра команд."

#if defined MAX_PLAYERS
#undef MAX_PLAYERS
#define MAX_PLAYERS 50
#else
#define MAX_PLAYERS 50
#endif

#define GetName(%0) PI[%0][pName]
#define GetPrefix(%0) PI[%0][pPrefix]

#define callback::%1(%2) forward %1(%2); public %1(%2)
#define settext(%0,%1) strmid(%0,%1,0, 255)

#if !defined IsStringNull
    #define IsStringNull(%1) ((!(%1[0])) || (((%1[0]) == '\1') && (!(%1[1]))))
#endif

#define delEscapeChar(%1) strdel(%1, strlen(%1) - 1, strlen(%1))


native SCM_Native(playerid, color, const message[]) = SendClientMessage;
native SCMA_Native(color, const message[]) = SendClientMessageToAll;


#define SendClientMessage(%0,%1,%2) _SCM(%0,%1,%2)
#define SendClientMessageToAll(%0,%1) _SCMA(%0,%1)
#define SCMF(%0,%1,%2,%3) (format(format_string, 144, %2, %3), _SCM(%0, %1, format_string))

stock _SCM(playerid, color, const message[])
{
    new hex[7];
    format(hex, 7, "%02X%02X%02X",
        (color >> 24) & 0xFF,
        (color >> 16) & 0xFF,
        (color >>  8) & 0xFF
    );
    CEFChat_Send(playerid, hex, message);
    return 1;
}

stock _SCMA(color, const message[])
{
    new hex[7];
    format(hex, 7, "%02X%02X%02X",
        (color >> 24) & 0xFF,
        (color >> 16) & 0xFF,
        (color >>  8) & 0xFF
    );
    CEFChat_SendAll(hex, message);
    return 1;
}

#define COLOR_GRAY      0xCECECEFF
#define COLOR_UNMAZING   0xe69348FF
#define COLOR_RED       0xff6347FF
#define COLOR_WHITE     0xFFFFFFFF
#define COLOR_LIME      0x99cc00FF
#define COLOR_BLUE      0x1e90ffFF
#define COLOR_RADIO     0x54b367FF
#define COLOR_DEPT      0xff8282FF
