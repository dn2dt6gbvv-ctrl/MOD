stock Float:GetDistanceBetweenCoords(Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2)
{
    return floatsqroot( (x2 - x1) * (x2 - x1) + 
                        (y2 - y1) * (y2 - y1) + 
                        (z2 - z1) * (z2 - z1) );
}

stock Converts(number)
{
	new hours = 0, mins = 0, secs = 0, string[30];
	hours = floatround(number / 3600);
	mins = floatround((number / 60) - (hours * 60));
	secs = floatround(number - ((hours * 3600) + (mins * 60)));
	if(hours > 0) format(string, 30, "%d:%02d:%02d", hours, mins, secs);
	else format(string, 30, "%d:%02d", mins, secs);
	return string;
}

stock GetColor(playerid)
{
    new str[8];
	format(str, sizeof(str), "%06x", PI[playerid][pColor] >>> 8);
	return str;
}


stock Float:GetDistBetweenPlayers(p1, p2)
{
    new Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2;
    GetPlayerPos(p1, x1, y1, z1);
    GetPlayerPos(p2, x2, y2, z2);
    return floatsqroot(floatpower(x1 - x2, 2.0) + floatpower(y1 - y2, 2.0) + floatpower(z1 - z2, 2.0));
}

stock ProxDetector(Float:radi, playerid, str[],col1,col2,col3,col4,col5)
{
	new Float:posx, Float:posy, Float:posz, Float:oldposx, Float:oldposy,
		Float:oldposz, Float:tempposx, Float:tempposy, Float:tempposz;
	GetPlayerPos(playerid, oldposx, oldposy, oldposz);
	foreach(new i: Player)
	{
		if(!PT[i][pLogged]) continue;
		GetPlayerPos(i, posx, posy, posz);
		tempposx = (oldposx -posx);
		tempposy = (oldposy -posy);
		tempposz = (oldposz -posz);
		if (((tempposx < radi/16) && (tempposx > -radi/16)) && ((tempposy < radi/16) && (tempposy > -radi/16)) && ((tempposz < radi/16) && (tempposz > -radi/16))) SendClientMessage(i, col1, str);
		else if (((tempposx < radi/8) && (tempposx > -radi/8)) && ((tempposy < radi/8) && (tempposy > -radi/8)) && ((tempposz < radi/8) && (tempposz > -radi/8))) SendClientMessage(i, col2, str);
		else if (((tempposx < radi/4) && (tempposx > -radi/4)) && ((tempposy < radi/4) && (tempposy > -radi/4)) && ((tempposz < radi/4) && (tempposz > -radi/4))) SendClientMessage(i, col3, str);
		else if (((tempposx < radi/2) && (tempposx > -radi/2)) && ((tempposy < radi/2) && (tempposy > -radi/2)) && ((tempposz < radi/2) && (tempposz > -radi/2))) SendClientMessage(i, col4, str);
		else if (((tempposx < radi) && (tempposx > -radi)) && ((tempposy < radi) && (tempposy > -radi)) && ((tempposz < radi) && (tempposz > -radi))) SendClientMessage(i, col5, str);
	}
	return 1;
}
forward SetRandomWeather();
public SetRandomWeather()
{
	new fmt_msg[55];
	new rand = random(sizeof weather);
	
	SendClientMessageToAll(0x3399FFFF, "[ ]");
	
	format(fmt_msg, sizeof fmt_msg, "   %s {99CC00}(+%d )", weather[rand][weather_name], weather[rand][weather_degrees]);
	SendClientMessageToAll(-1, fmt_msg);
	
	SetWeather(weather[rand][weather_id]);
	return 1;
}
stock ad_timer(i)
{   
    switch(i)
    {
        case 0:
        {
            SendClientMessageToAll(0xFFCC00FF,"_______________________________________________________________________________________________");
            SendClientMessageToAll(0xFFCC00FF,"                                                                                               ");
            SendClientMessageToAll(0xFFFFFFFF,"  2 000 ?  {FFCC00}         ");
            SendClientMessageToAll(0xFFFFFFFF,"( 5-         10  )");
            SendClientMessageToAll(0xFFFFFFFF,"    1 000      {FFCC00}awesome-online.com");
            SendClientMessageToAll(0xFFFFFFFF,"     {FFCC00}  \"VK\"");
            SendClientMessageToAll(0xFFCC00FF,"_______________________________________________________________________________________________");
        }
        case 1:
        {
            SendClientMessageToAll(0xFFCC00FF,"_______________________________________________________________________________________________");
            SendClientMessageToAll(0xFFCC00FF,"                                                                                               ");
            SendClientMessageToAll(0xFFFFFFFF," !      - {FFCC00}/drop []");
            SendClientMessageToAll(0xFFFFFFFF,"    //      ");
            SendClientMessageToAll(0xFFFFFFFF,"   :   (/)    ()");
            SendClientMessageToAll(0xFFCC00FF,"_______________________________________________________________________________________________");
        }
    }
}
stock SplitInt(value)
{
    new string[100]; 
    string[0] = '\0';
    
    if (value == 0) {
        string = "0";
        return string;
    }
    
    new billions = value / 1000000000;
    new millions = (value % 1000000000) / 1000000;
    new thousands = (value % 1000000) / 1000;
    new ones = value % 1000;

    if (billions > 0) {
        format(string, sizeof(string), "%d ", billions);
        if (millions > 0 || thousands > 0 || ones > 0) {
            strcat(string, " ");
        }
    }
    
    if (millions > 0) {
        new temp[32];
        format(temp, sizeof(temp), "%d .", millions);
        strcat(string, temp);
        if (thousands > 0 || ones > 0) {
            strcat(string, " ");
        }
    }
    
    if (thousands > 0) {
        new temp[32];
        format(temp, sizeof(temp), "%d .", thousands);
        strcat(string, temp);
        if (ones > 0) {
            strcat(string, " ");
        }
    }
    
    if (ones > 0) {
        new temp[32];
        format(temp, sizeof(temp), "%d .", ones);
        strcat(string, temp);
    }
    
    return string;
}

stock RandomEX(min, max)
{
	new a = random(max - min) + min;
	return a;
}

stock GeneratePassword(password[], len)
{
    new const charmap[] = {
        'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
        'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z',
        '0','1','2','3','4','5','6','7','8','9'
    };

    for(new i = 0; i < len - 1; i++)
    {
        password[i] = charmap[RandomEX(0, sizeof charmap - 1)];
    }
}

stock strcpy(dest[], const source[], maxlength = sizeof dest)
    return strcat((dest[0] = EOS, dest), source, maxlength);

    

stock GetVarAsString(param)
{
    new string[6];
    if(param <= 0) string = "";
    else format(string, sizeof string, "%d", param);

    return string;
}
