#if defined _foreach_included
	#endinput
#endif
#define _foreach_included

                                                                                

#define _Y_ITER_ARRAY: _:_Y_ITER_C0:
#define _Y_ITER_ARRAY_SIZE(%1) _:_Y_ITER_C1:_Y_ITER_C2:sizeof %1@YSII_Ag-1

#define _Y_ITER_C0:%0[%1]@YSII_%4g%3) %0@YSII_%4g[%1]%3)
#define _Y_ITER_C1:_Y_ITER_C2:%0[%1]@YSII_Ag%3) %0@YSII_Ag[]%3)
#define _Y_ITER_C2:sizeof%0(%1)@YSII_Ag-1;_:(%2=_Y_ITER_ARRAY:%3(%4)@YSII_Ag[%5])!=_Y_ITER_ARRAY_SIZE(%6);) -1;_:(%2=%3@YSII_Ag(%4,%5))!=-1;)
#define _Y_ITER_C3:%0[%1]@YSII_Cg,%2[%3]@YSII_Ag[%4]={%5} _Y_ITER_C3:%0@YSII_Cg[%1],%0@YSII_Ag[%1][%4]

#define new%0|||%9|||%1:%2||| %9|||%0|||%1|||%2|||
#define Y_FOREACH_THIRD|||%0|||%1|||%2||| %1=Y_FOREACH_FIFTH|||Y_FOREACH_FOURTH|||%1:%2|||
#define Y_FOREACH_FOURTH|||%0=Y_FOREACH_FIFTH|||%1|||%2||| new Y_FOREACH_SIXTH;%0|||Y_FOREACH_SEVENTH|||%2|||
#define Y_FOREACH_SEVENTH|||%9Y_FOREACH_SIXTH;%0|||%1|||%2||| new %0:%1=%0:_Y_ITER_ARRAY_SIZE(%2);_:(%1=_Y_ITER_ARRAY:%2@YSII_Ag[%1])!=_Y_ITER_ARRAY_SIZE(%2);
#define Y_FOREACH_SIXTH;%0|||Y_FOREACH_SEVENTH|||%2||| %0=_Y_ITER_ARRAY_SIZE(%2);_:(%0=_Y_ITER_ARRAY:%2@YSII_Ag[%0])!=_Y_ITER_ARRAY_SIZE(%2);
#define Y_FOREACH_FIFTH|||Y_FOREACH_FOURTH|||%1:%2||| _Y_ITER_ARRAY_SIZE(%2);_:(%1=_Y_ITER_ARRAY:%2@YSII_Ag[%1])!=_Y_ITER_ARRAY_SIZE(%2);
#define Y_FOREACH_SECOND|||Y_FOREACH_THIRD|||%1,%2||| %2=_Y_ITER_ARRAY_SIZE(%1);_:(%2=_Y_ITER_ARRAY:%1@YSII_Ag[%2])!=_Y_ITER_ARRAY_SIZE(%1);






                                                                                

#define IteratorArray:%1[%2]<%3> %1@YSII_Cg[%2],%1@YSII_Ag[%2][%3+1]






                                                                                

#define Iterator:%1<%2> _Y_ITER_C3:%1@YSII_Cg,%1@YSII_Ag[(%2)+1]={(%2)*2,(%2)*2-1,...}













                                                                                

#define Iter_Init(%1) Iter_InitInternal(%1@YSII_Ag,sizeof %1@YSII_Ag,sizeof %1@YSII_Ag[]-1)














                                                                                

#define Iter_Add(%1,%2) Iter_AddInternal(_Y_ITER_ARRAY:%1@YSII_Cg,_Y_ITER_ARRAY:%1@YSII_Ag,%2,_Y_ITER_ARRAY_SIZE(%1))













                                                                                

#define Iter_Free(%1) Iter_FreeInternal(_Y_ITER_ARRAY:%1@YSII_Ag,_Y_ITER_ARRAY_SIZE(%1))














                                                                                

#define Iter_Remove(%1,%2) Iter_RemoveInternal(_Y_ITER_ARRAY:%1@YSII_Cg,_Y_ITER_ARRAY:%1@YSII_Ag,%2,_Y_ITER_ARRAY_SIZE(%1))














                                                                                

#define Iter_Contains(%1,%2) Iter_ContainsInternal(_Y_ITER_ARRAY:%1@YSII_Ag,%2,_Y_ITER_ARRAY_SIZE(%1))

















                                                                                

#define Iter_SafeRemove(%1,%2,%3) Iter_SafeRemoveInternal(_Y_ITER_ARRAY:%1@YSII_Cg,_Y_ITER_ARRAY:%1@YSII_Ag,%2,%3,_Y_ITER_ARRAY_SIZE(%1))













                                                                                

#define Iter_Random(%1) Iter_RandomInternal(_Y_ITER_ARRAY:%1@YSII_Cg,_Y_ITER_ARRAY:%1@YSII_Ag,_Y_ITER_ARRAY_SIZE(%1))













                                                                                

#define Iter_Count(%1) (_Y_ITER_ARRAY:%1@YSII_Cg)













                                                                                

#define Iter_Clear(%1) Iter_ClearInternal(_Y_ITER_ARRAY:%1@YSII_Cg,_Y_ITER_ARRAY:%1@YSII_Ag,_Y_ITER_ARRAY_SIZE(%1))














                                                                                

#define foreach%1(%0) for(new Y_FOREACH_SECOND|||Y_FOREACH_THIRD|||%0|||)











                                                                                

#define foreachex(%1,%2) foreach(%2:%1)












                                                                                

stock Iter_RandomInternal(count, array[], size)
{
	if(count == 0) return -1;
	new rnd = random(count), cur = array[size];
	while(cur != size)
	{
		if(rnd-- == 0) return cur;
		cur = array[cur];
	}
	return -1;
}
















                                                                                

stock Iter_FreeInternal(array[], size)
{
	for(new i; i != size; ++i)
	{
		if(array[i] > size) return i;
	}
	return -1;
}















                                                                                

stock Iter_AddInternal(&count, array[], value, size)
{
	if(0 <= value < size && array[value] > size)
	{
		new last = size, next = array[last];
		while(next < value)
		{
			last = next;
			next = array[last];
		}
		array[last] = value;
		array[value] = next;
		++count;
		return 1;
	}
	return 0;
}












                                                                                

stock Iter_RemoveInternal(&count, array[], value, size)
{
	new last;
	return Iter_SafeRemoveInternal(count, array, value, last, size);
}














                                                                                

stock Iter_SafeRemoveInternal(&count, array[], value, &last, size)
{
	if(0 <= value < size && array[value] <= size)
	{
		last = size;
		new next = array[last];
		while(next != value)
		{
			last = next;
			next = array[last];
		}
		array[last] = array[value];
		array[value] = size + 1;
		--count;
		return 1;
	}
	return 0;
}












                                                                                

stock Iter_ContainsInternal(array[], value, size) return 0 <= value < size && array[value] <= size;












                                                                                

stock Iter_ClearInternal(&count, array[], size)
{
	for(new i, t = size + 1; i < size; ++i) array[i] = t;
	array[size] = size;
	count = 0;
	return 1;
}













                                                                                

stock Iter_InitInternal(arr[][], s0, s1)
{
	for(new i, t = s1 + 1; i < s0; ++i)
	{
		for(new j; j < s1; ++j) arr[i][j] = t;
		arr[i][s1] = s1;
	}
	return 1;
}












                                                                                

stock Iter_PrevInternal(array[], size, slot)
{
	if(0 <= slot <= size && array[slot] <= size)
	{
		for(new last = slot; last--; )
		{
			if(array[last] == slot) return last;
		}
	}
	return size;
}










                                                                                

#define Iter_Begin(%1) (_Y_ITER_ARRAY_SIZE(%1))










                                                                                

#define Iter_End(%1) (_Y_ITER_ARRAY_SIZE(%1))










                                                                                

#define Iter_First(%1) (_Y_ITER_ARRAY:%1@YSII_Ag[_Y_ITER_ARRAY_SIZE(%1)])










                                                                                

#define Iter_Last(%1) Iter_PrevInternal(_Y_ITER_ARRAY:%1@YSII_Ag,_Y_ITER_ARRAY_SIZE(%1),_Y_ITER_ARRAY_SIZE(%1))










                                                                                

#define Iter_Next(%1,%2) (_Y_ITER_ARRAY:%1@YSII_Ag[(%2)])










                                                                                

#define Iter_Prev(%1,%2) Iter_PrevInternal(_Y_ITER_ARRAY:%1@YSII_Ag,_Y_ITER_ARRAY_SIZE(%1),(%2))










                                                                                

#define Iter_InternalArray(%1) (_Y_ITER_ARRAY:%1@YSII_Ag)










                                                                                

#define _Y_ITER_INT_SIZE:%0(%2[%1]@YSII_Ag)) %0(%2@YSII_Ag[]))
#define Iter_InternalSize(%1) (_:_Y_ITER_INT_SIZE:sizeof (%1@YSII_Ag))



#define Iter_GetByIndex(iterator, index, result) \
    do { \
        new _iter_idx = 0; \
        new _iter_found = -1; \
        foreach(new _iter_val : iterator) { \
            if (_iter_idx == index) { \
                _iter_found = _iter_val; \
                break; \
            } \
            _iter_idx++; \
        } \
        (result) = _iter_found; \
    } while(0)


                                                                                

new Iterator:Player<MAX_PLAYERS>;

public OnFilterScriptInit()
{
    Iter_Clear(Player);
    for(new playerid = MAX_PLAYERS; playerid >= 0; playerid--) { if(IsPlayerConnected(playerid) && !Iter_Contains(Player, playerid)) Iter_Add(Player, playerid); }
	#if defined fc_OnFilterScriptInit
		return fc_OnFilterScriptInit();
	#else
	    return 1;
	#endif
}
#if defined _ALS_OnFilterScriptInit
    #undef OnFilterScriptInit
#else
    #define _ALS_OnFilterScriptInit
#endif
#if defined fc_OnFilterScriptInit
	forward fc_OnFilterScriptInit();
#endif
#define OnFilterScriptInit fc_OnFilterScriptInit

public OnGameModeInit()
{
    Iter_Clear(Player);
    for(new playerid = MAX_PLAYERS; playerid >= 0; playerid--) { if(IsPlayerConnected(playerid) && !Iter_Contains(Player, playerid)) Iter_Add(Player, playerid); }
	#if defined fc_OnGameModeInit
		return fc_OnGameModeInit();
	#else
	    return 1;
	#endif
}
#if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#if defined fc_OnGameModeInit
	forward fc_OnGameModeInit();
#endif
#define OnGameModeInit fc_OnGameModeInit

public OnPlayerConnect(playerid)
{
    Iter_Add(Player, playerid);
	#if defined fc_OnPlayerConnect
		return fc_OnPlayerConnect(playerid);
	#else
	    return 1;
	#endif
}
#if defined _ALS_OnPlayerConnect
	#undef OnPlayerConnect
#else
	#define _ALS_OnPlayerConnect
#endif
#if defined fc_OnPlayerConnect
	forward fc_OnPlayerConnect(playerid);
#endif
#define OnPlayerConnect fc_OnPlayerConnect

public OnPlayerDisconnect(playerid, reason)
{
	new id = 1;
    #if defined fc_OnPlayerDisconnect
    	id = fc_OnPlayerDisconnect(playerid, reason);
	#endif
	SetTimerEx("fc_PlayerRemove", 0, 0, "i", playerid);
	return id;
}
#if defined _ALS_OnPlayerDisconnect
	#undef OnPlayerDisconnect
#else
	#define _ALS_OnPlayerDisconnect
#endif
#if defined fc_OnPlayerDisconnect
	forward fc_OnPlayerDisconnect(playerid, reason);
#endif
#define OnPlayerDisconnect fc_OnPlayerDisconnect

forward fc_PlayerRemove(playerid);
public fc_PlayerRemove(playerid) Iter_Remove(Player, playerid);
                                                                                
