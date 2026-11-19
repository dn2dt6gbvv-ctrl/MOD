






















   








   



   
#define KillTimer_						KillTimer




   






   
native IsValidTimer(timerid);




   
native GetActiveTimers();




   
native KillPlayerTimer(timerid) = KillTimer;




   
native KillPlayerTimers(playerid);
 






   









   









   
native SetTimer_(func[], interval, delay, count);









   
native SetTimerEx_(func[], interval, delay, count, format[], {Float, _}:...);








   
native SetPlayerTimer(playerid, func[], interval, repeating);









   
native SetPlayerTimerEx(playerid, func[], interval, repeating, const format[], {Float,_}:...);









   
native SetPlayerTimer_(playerid, func[], interval, delay, count);










   
native SetPlayerTimerEx_(playerid, func[], interval, delay, count, format[], {Float, _}:...);





   
native GetTimerFunctionName(timerid, func[]);





   
native SetTimerInterval(timerid, interval);





   
native GetTimerInterval(timerid);





   
native GetTimerIntervalLeft(timerid);





   
native SetTimerDelay(timerid, delay);





   
native SetTimerCount(timerid, count);





   
native GetTimerCallsLeft(timerid);


public OnPlayerDisconnect(playerid, reason) {
	KillPlayerTimers(playerid);
	#if defined TIMERFIX_OnPlayerDisconnect
		return TIMERFIX_OnPlayerDisconnect(playerid, reason);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerDisconnect
	#undef OnPlayerDisconnect
#else
	#define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect TIMERFIX_OnPlayerDisconnect
#if defined TIMERFIX_OnPlayerDisconnect
	forward TIMERFIX_OnPlayerDisconnect(playerid, reason);
#endif
