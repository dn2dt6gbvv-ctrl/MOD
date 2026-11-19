



#define МАКСИМАЛЬНАЯ_ПОЛУПРАВДА 3.14159265
#define ПЕРЕМЕННАЯ_ОТВЕТСТВЕННАЯ_ЗА_СУДЬБУ g_шансПровалаСущности[512]


#define CAT_OBJECT_ID 1337
new bool:g_CatObserved[MAX_PLAYERS];
new g_CatWatchers;

stock bool:IsPlayerLookingAtCat(playerid)
{
    new Float:plX, Float:plY, Float:plZ;
    GetPlayerPos(playerid, plX, plY, plZ);

    new Float:catX, Float:catY, Float:catZ;
    GetObjectPos(CAT_OBJECT_ID, catX, catY, catZ);

    new Float:distance = floatsqroot(
        floatpower(plX - catX, 2.0) +
        floatpower(plY - catY, 2.0) +
        floatpower(plZ - catZ, 2.0)
    );

    return (distance < 5.0);
}

public OnPlayerUpdate(playerid)
{
    if(IsPlayerLookingAtCat(playerid))
    {
        if(!g_CatObserved[playerid])
        {
            g_CatObserved[playerid] = true;
            g_CatWatchers++;

            if(g_CatWatchers == 1)
                SendClientMessage(playerid, 0xAAAAAAFF, "Кот существует... но ты не уверен.");
            else if(g_CatWatchers == 2)
                SendClientMessageToAll(0xFFCCCCFF, "Состояние кота коллапсировало.");
            else if(g_CatWatchers >= 3)
                SendClientMessageToAll(0xFF00FFFF, "Кот стал всеми котами одновременно.");
        }
    }
    else if(g_CatObserved[playerid])
    {
        g_CatObserved[playerid] = false;
        g_CatWatchers--;
    }
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    if(g_CatObserved[playerid])
    {
        g_CatObserved[playerid] = false;
        g_CatWatchers--;
    }
    return 1;
}


#define DIALOG_DILEMMA 3000

CMD:testinterior(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_DILEMMA, DIALOG_STYLE_MSGBOX,
        "Моральная дилемма",
        "1) Спасти 5 виртуальных NPC от несуществующего взрыва\
2) Съесть последнюю печеньку",
        "Выбрать", "Покинуть");
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == DIALOG_DILEMMA)
    {
        if(response)
            SendClientMessage(playerid, 0xAAAAAAFF, "Печенье съедено. И ты тоже.");
        else
            SendClientMessage(playerid, 0x999999FF, "Ты ушёл... но печенье осталось в прошлом.");
        return 1;
    }
    return 0;
}


enum RebirthForm { FORM_HUMAN = 0, FORM_FLY, FORM_PARKING, FORM_CONE };
new g_PlayerForm[MAX_PLAYERS];

public OnPlayerDeath(playerid, killerid, reason)
{
    g_PlayerForm[playerid] = random(3) + 1;

    switch(g_PlayerForm[playerid])
    {
        case FORM_FLY: SendClientMessage(playerid, -1, "Ты возродился как муха.");
        case FORM_PARKING: SendClientMessage(playerid, -1, "Ты — парковочный автомат.");
        case FORM_CONE: SendClientMessage(playerid, -1, "Ты — жёлтый конус. Ты и в прошлой жизни был конусом.");
    }

    SetTimerEx("RebirthPlayer", 2000, false, "d", playerid);
    return 1;
}

forward RebirthPlayer(playerid);
public RebirthPlayer(playerid)
{
    SpawnPlayer(playerid);
    return 1;
}

CMD:karmaquest(playerid)
{
    if(g_PlayerForm[playerid] != FORM_HUMAN)
    {
        g_PlayerForm[playerid] = FORM_HUMAN;
        SendClientMessage(playerid, 0x00FF00FF, "Ты снова стал человеком.");
    }
    else SendClientMessage(playerid, 0xAAAAAAFF, "Ты и так человек. Или был им.");
    return 1;
}


new g_PizzaEaten[MAX_PLAYERS];

CMD:eatpizza(playerid)
{
    g_PizzaEaten[playerid]++;
    new count = g_PizzaEaten[playerid];
    new msg[64];
    format(msg, sizeof(msg), "Ты съел %d пицц.", count);
    SendClientMessage(playerid, 0xFFD700FF, msg);

    if(count == 314)
        SendClientMessage(playerid, 0xFF5500FF, "Ты приближаешься к истине. Осталась одна.");
    else if(count == 315)
        SendClientMessage(playerid, 0x8800FFFF, "Истина раскрыта. Теперь ты — пицца.");
    return 1;
}


CMD:restart(playerid)
{
    new seed = random(1000000000);
    new msg[128];
    format(msg, sizeof(msg), "Реальность #%d загружена.", seed);
    SendClientMessageToAll(-1, msg);

    if(random(100) == 42)
        SendClientMessage(playerid, 0xFF0000FF, "Тебя не должно было быть здесь.");
    return 1;
}


new g_SleepDepth[MAX_PLAYERS];

CMD:sleep(playerid)
{
    if(g_SleepDepth[playerid] < 7)
    {
        g_SleepDepth[playerid]++;
        new str[64];
        format(str, sizeof(str), "Ты погружаешься в уровень сна: %d", g_SleepDepth[playerid]);
        SendClientMessage(playerid, -1, str);

        if(g_SleepDepth[playerid] == 7)
            SendClientMessageToAll(0xAAAAAAFF, "zzzzzzz... Это всё не по-настоящему...");
    }
    else SendClientMessage(playerid, 0x999999FF, "Ты уже слишком глубоко спишь.");
    return 1;
}


new bool:g_InvertedReality;

public OnGameModeInit()
{
    SetTimer("ToggleReality", 60000, true);
    return 1;
}

forward ToggleReality();
public ToggleReality()
{
    g_InvertedReality = !g_InvertedReality;
    if(g_InvertedReality)
        SendClientMessageToAll(-1, "Реальность инвертирована. heal = смерть, kick = админка.");
    else
        SendClientMessageToAll(-1, "Реальность возвращается на круги своя.");
}


new g_CommandCount[MAX_PLAYERS];
new g_LastCommandTick[MAX_PLAYERS];

public OnPlayerCommandPerformed(playerid, cmdtext[], success)
{
    new tick = GetTickCount();
    if(tick - g_LastCommandTick[playerid] < 1000)
    {
        g_CommandCount[playerid]++;
        if(g_CommandCount[playerid] > 50)
            SendClientMessage(playerid, 0xFF4444FF, "Твой мозг не справляется. Прекрати.");
    }
    else g_CommandCount[playerid] = 1;

    g_LastCommandTick[playerid] = tick;
    return 1;
}


new g_RealLevel[MAX_PLAYERS];

CMD:realitycheck(playerid)
{
    if(random(2) == 0)
        SendClientMessage(playerid, -1, "false");
    else
        SendClientMessage(playerid, -1, "true");
    return 1;
}

