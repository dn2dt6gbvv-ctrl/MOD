  
  
                                                  
                       
                        
  

#define GENERAL_COLOR      	0xEEEEEEFF
#define LOCAL_TALK_COLOR    0xD0D0D0FF
#define SPEECH_BUBBLE_COLOR	0xEEEEEEFF
#define ACTION_COLOR     	0xC2A2DAAA
#define CMD_USAGE_COLOR     0xBFC0C2FF
#define MEGAPHONE_COLOR		0xFFFF00AA
#define WHISPER_COLOR		0xFFFF00AA
#define OOC_COLOR			0xE0FFFFAA
#define ADMIN_ACTION_COLOR  0xDAA2ACAA

#define TALK_DISTANCE   	30.0
#define SHOUT_DISTANCE  	60.0
#define LOW_DISTANCE    	5.0
#define ACTION_DISTANCE 	30.0
#define MEGAPHONE_DISTANCE  70.0

#define CHAT_BUBBLE_TIME 	6000

#define ACTION_ME           1
#define ACTION_DO           2

                                               
                                     

stock PlayerMessage(playerid, color, message[])
{
     SendClientMessage(playerid, color, message);
}

                                               
                                     

stock GlobalMessage(color, message[])
{
     SendClientMessageToAll(color, message);
}

                                               

stock CmdUsageMessage(playerid, message[])
{
 	new msg[256+1];
	format(msg,256,"[{BFC0C2}usage{EEEEEE}] %s", message);
	SendClientMessage(playerid, GENERAL_COLOR, msg);
}

                                               

stock CmdErrorMessage(playerid, message[])
{
    new msg[256+1];
	format(msg,256,"[{E0C0C0}error{EEEEEE}] %s", message);
	SendClientMessage(playerid, GENERAL_COLOR, msg);
}

                                               

stock CmdAdminMessage(playerid, message[])
{
	new msg[256+1];
	format(msg,256,"[{5050EE}admin{EEEEEE}] %s", message);
	SendClientMessage(playerid, GENERAL_COLOR, msg);
}

                                               

stock AdminActionMessage(playerid, message[])
{
	PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
	SendClientMessage(playerid, ADMIN_ACTION_COLOR, message);		
}

                                               
                                                         
                                   

stock LocalMessage(Float:dist, playerid, color, message[], chatbubble=0)
{
	if(!strlen(message)) return;

	if(IsPlayerConnected(playerid))
	{
		new Float:fPlayerX, Float:fPlayerY, Float:fPlayerZ;
		new Float:fPlayerToPlayerDist;
		
		                            
		PlayerMessage(playerid, color, message);
		
		                                         
		if(chatbubble) {
			SetPlayerChatBubble(playerid, message, color, dist, CHAT_BUBBLE_TIME);
		}

		GetPlayerPos(playerid, fPlayerX, fPlayerY, fPlayerZ);
		
		for(new i = 0; i < MAX_PLAYERS; i++) {                    
		    if(IsPlayerConnected(i) && (i != playerid) && IsPlayerStreamedIn(playerid,i)) {
		        fPlayerToPlayerDist = GetPlayerDistanceFromPoint(i, fPlayerX, fPlayerY, fPlayerZ);
				if(fPlayerToPlayerDist < dist) {                                                     
					PlayerMessage(i, color, message);
				}
			}
		}
	}
}

                                               
                                                                      
                                   

stock TalkMessage(Float:dist, playerid, prefix[], message[])
{
    new PlayerName[MAX_PLAYER_NAME+1];
	new Msg[256+1];
	new MsgWithName[256+1];
	
	if(!strlen(message)) return;

	if(IsPlayerConnected(playerid))
	{
		new Float:fPlayerX, Float:fPlayerY, Float:fPlayerZ;
		new Float:fPlayerToPlayerDist;
		new Float:fNormDistance;
		new ColorScale;
		new ColorValue;

		GetPlayerName(playerid, PlayerName, sizeof(PlayerName));
		if(strlen(prefix)) {
			format(Msg, sizeof(Msg), "%s %s", prefix, message);
		} else {
		    format(Msg, sizeof(Msg), "%s", message);
		}
		
		format(MsgWithName, sizeof(MsgWithName), "%s: %s", PlayerName, Msg);

        SetPlayerChatBubble(playerid, Msg, SPEECH_BUBBLE_COLOR, dist, CHAT_BUBBLE_TIME);
		
		                             
		PlayerMessage(playerid, LOCAL_TALK_COLOR, MsgWithName);

		GetPlayerPos(playerid, fPlayerX, fPlayerY, fPlayerZ);

		for(new i = 0; i < MAX_PLAYERS; i++) {                    
		    if(IsPlayerConnected(i) && (i != playerid) && IsPlayerStreamedIn(playerid,i)) {
		        fPlayerToPlayerDist = GetPlayerDistanceFromPoint(i, fPlayerX, fPlayerY, fPlayerZ);
				if(fPlayerToPlayerDist < dist) {                                                     
					                                            
					fNormDistance = 1.0 - (fPlayerToPlayerDist / dist);
  					if(fNormDistance > 0.75) ColorScale = 220;
					else ColorScale = floatround(96.0 + (128.0 * fNormDistance));
					ColorValue = 0x000000FF | ColorScale << 24 | ColorScale << 16 | ColorScale << 8;
					PlayerMessage(i, ColorValue, MsgWithName);
				}
			}
		}
	}
}

                                               