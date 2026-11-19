















   
stock GetBalanceCSRInt(nicknamecsr[])
{
	new type_data_csr;
	new idscsr[64];
	format(idscsr,sizeof(idscsr),"csr/conf.ini");
	new iniOpencsr;
	iniOpencsr = csr_openFile(idscsr);
	if(iniOpencsr == -1 || iniOpencsr == -2){iniOpencsr = csr_createFile(idscsr);csr_setInteger(iniOpencsr, "TypeCredits",1);}
    csr_getInteger(iniOpencsr, "TypeCredits",type_data_csr);
	csr_closeFile(iniOpencsr);

	new CreditsInt;
	format(idscsr,sizeof(idscsr),"csr/%s.ini",nicknamecsr);
	iniOpencsr = csr_openFile(idscsr);
	if(iniOpencsr == -1 || iniOpencsr == -2) {csr_closeFile(iniOpencsr);return -1;}
	csr_getInteger(iniOpencsr, "CreditsINT",CreditsInt);
	csr_closeFile(iniOpencsr);
	if(type_data_csr == 1){
        return CreditsInt;
	}
	if(type_data_csr == 2){
		return -1;
	}
	return -1;
}
stock GetBalanceCSRFloat(nicknamecsr[])
{
	new type_data_csr;
	new idscsr[64];
	format(idscsr,sizeof(idscsr),"csr/conf.ini");
	new iniOpencsr;
	iniOpencsr = csr_openFile(idscsr);
	if(iniOpencsr == -1 || iniOpencsr == -2){iniOpencsr = csr_createFile(idscsr);csr_setInteger(iniOpencsr, "TypeCredits",1);}
    csr_getInteger(iniOpencsr, "TypeCredits",type_data_csr);
	csr_closeFile(iniOpencsr);

	new Float:CreditsFloat;
	format(idscsr,sizeof(idscsr),"csr/%s.ini",nicknamecsr);
	iniOpencsr = csr_openFile(idscsr);
	if(iniOpencsr == -1 || iniOpencsr == -2) {csr_closeFile(iniOpencsr);return -1;}
	csr_getFloat(iniOpencsr, "CreditsFLOAT",CreditsFloat);
	csr_closeFile(iniOpencsr);
	if(type_data_csr == 1){
        return -1;
	}
	if(type_data_csr == 2){
		return CreditsFloat;
	}
	return -1;
}

stock SetBalanceCSRInt(nicknamecsr[],newbalancecsr)
{
    new iniOpencsr;
    new idscsr[64],balncesusercsr;
	format(idscsr,sizeof(idscsr),"csr/%s.ini",nicknamecsr);
	iniOpencsr = csr_openFile(idscsr);
	if(iniOpencsr == -1 || iniOpencsr == -2) {csr_closeFile(iniOpencsr);return -1;}
	csr_setFloat(iniOpencsr, "CreditsINT",balncesusercsr);
	csr_setInteger(iniOpencsr, "CreditsINT",newbalancecsr);
	csr_closeFile(iniOpencsr);
 	balncesusercsr = newbalancecsr-balncesusercsr;
	new textforlogcsr[256];
	if(balncesusercsr > 0)
	{
		format(textforlogcsr,256,"Donate:%s:+%d",nicknamecsr,balncesusercsr);
	}else{
        format(textforlogcsr,256,"Donate:%s:%d",nicknamecsr,balncesusercsr);
	}
	InputLogsCSR(textforlogcsr);
	return 1;
}
stock SetBalanceCSRFloat(nicknamecsr[],Float:newbalancecsr)
{
    new idscsr[64],Float:balncesusercsr;
	format(idscsr,sizeof(idscsr),"csr/%s.ini",nicknamecsr);
	iniOpencsr = csr_openFile(idscsr);
	if(iniOpencsr == -1 || iniOpencsr == -2) {csr_closeFile(iniOpencsr);return -1;}
	csr_getFloat(iniOpencsr, "CreditsFLOAT",balncesusercsr);
	csr_setFloat(iniOpencsr, "CreditsFLOAT",newbalancecsr);
	csr_closeFile(iniOpencsr);
 	balncesusercsr = newbalancecsr-balncesusercsr;
	new textforlogcsr[256];
	if(balncesusercsr > 0)
	{
		format(textforlogcsr,256,"Donate:%s:+%d",nicknamecsr,balncesusercsr);
	}else{
        format(textforlogcsr,256,"Donate:%s:%d",nicknamecsr,balncesusercsr);
	}
	InputLogsCSR(textforlogcsr);
	return 1;
}

stock GiveBalanceCSRInt(nicknamecsr[],setbalancecsr)
{
    new idscsr[64],balncesusercsr;
	format(idscsr,sizeof(idscsr),"csr/%s.ini",nicknamecsr);
	iniOpencsr = csr_openFile(idscsr);
	if(iniOpencsr == -1 || iniOpencsr == -2) {csr_closeFile(iniOpencsr);return -1;}
	csr_getInteger(iniOpencsr, "CreditsINT",balncesusercsr);
	csr_setInteger(iniOpencsr, "CreditsINT",balncesusercsr+setbalancecsr);
	csr_closeFile(iniOpencsr);
	new textforlogcsr[256];
	if(setbalancecsr > 0)
	{
		format(textforlogcsr,256,"Donate:%s:+%d",nicknamecsr,setbalancecsr);
	}else{
        format(textforlogcsr,256,"Donate:%s:%d",nicknamecsr,setbalancecsr);
	}
	InputLogsCSR(textforlogcsr);
	return 1;
}
stock GiveBalanceCSRFloat(nicknamecsr[],Float:setbalancecsr)
{
    new idscsr[64],FLoat:balncesusercsr;
	format(idscsr,sizeof(idscsr),"csr/%s.ini",nicknamecsr);
	iniOpencsr = csr_openFile(idscsr);
	if(iniOpencsr == -1 || iniOpencsr == -2) {csr_closeFile(iniOpencsr);return -1;}
	csr_getFloat(iniOpencsr, "CreditsFLOAT",balncesusercsr);
	csr_setFloat(iniOpencsr, "CreditsFLOAT",balncesusercsr+setbalancecsr);
	csr_closeFile(iniOpencsr);
	new textforlogcsr[256];
	if(setbalancecsr > 0)
	{
		format(textforlogcsr,256,"Donate:%s:+%.2f",nicknamecsr,setbalancecsr);
	}else{
        format(textforlogcsr,256,"Donate:%s:%.2f",nicknamecsr,setbalancecsr);
	}
	InputLogsCSR(textforlogcsr);
	return 1;
}

stock InputLogsCSR(logtext[])
{
	new hourcsr,minutecsr,secondcsr,yearcsr,monthcsr,daycsr;
	gettime(hourcsr, minutecsr, secondcsr);
	getdate(yearcsr, monthcsr, daycsr);
	new stringcsr[255], stringcsr2[128], File: logs_csr;
	format(stringcsr2, sizeof(stringcsr2), "csr/logs2.txt");
	logs_csr = fopen(stringcsr2, io_append);
	format(stringcsr, sizeof(stringcsr), "%s(%d:%d:%d|%d.%d.%d)\n",logtext,hourcsr,minutecsr,secondcsr,daycsr,monthcsr,yearcsr);
	fwrite(logs_csr, stringcsr);
	fclose(logs_csr);
	return 1;
}
stock SetNameCSR(nicknamecsrold,nicknamecsrnew)
{
    new idscsr[64];
	format(idscsr,sizeof(idscsr),"csr/%s.ini",nicknamecsrold);
	iniOpencsr = csr_openFile(idscsr);
	if(iniOpencsr == -1 || iniOpencsr == -2) {csr_closeFile(iniOpencsr);return -1;}
    format(idscsr,sizeof(idscsr),"csr/%s.ini",nicknamecsrnew);
	csr_rename_file (iniOpencsr,idscsr,1);
	csr_closeFile(iniOpencsr);
}




#if defined _mxCSR_included
    #endinput
#endif
#define _mxCSR_included





const




    CSR_MAX_OPENED_FILES    = 2,
    CSR_MAX_FILE_SIZE       = 65536,
    CSR_MAX_FILENAME_SIZE   = 128,
    CSR_MAX_KEYS_IN_FILE    = 2048,






    CSR_INTEGER_SIZE        = 12,
    CSR_FLOAT_SIZE          = 40,

    CSR_STRING_DELIMITER    = '\n',
    CSR_DELIMITER           = '=',





    CSR_OK                  =  0,




    CSR_FILE_NOT_FOUND      = -1,
    CSR_FILE_ALREADY_EXIST  = -2,
    CSR_TOO_LARGE_FILE      = -3,
    CSR_WRONG_PATH_SIZE     = -4,
    CSR_READ_ERROR          = -5,
    CSR_WRITE_ERROR         = -6,
    CSR_NO_FREE_SLOT        = -7,
    CSR_WRONG_SLOT          = -8,
    CSR_KEY_NOT_FOUND       = -9,
    CSR_WRONG_RETURN_SIZE   = -10,





    cellbytes = cellbits / charbits;








#define CSR_SPACE_CHAR  ' ', '\t'
#define CSR_KEY_STARTS  ' ', '\t', '\r', '\n', '\0'
#define CSR_STRING_ENDS '\r', '\n', '\0'
#define CSR_NUMBER_ENDS ' ', '\t', '\r', '\n', '\0'





static stock



    _csr_nSlotUsed      [ CSR_MAX_OPENED_FILES ],
    _csr_nFileChanged   [ CSR_MAX_OPENED_FILES ],
    _csr_nFileBusy      [ CSR_MAX_OPENED_FILES ],
    _csr_nFileSize      [ CSR_MAX_OPENED_FILES ],
    _csr_nDelimPos      [ CSR_MAX_OPENED_FILES ] [ CSR_MAX_KEYS_IN_FILE ],
    _csr_nKeysCount     [ CSR_MAX_OPENED_FILES ],
    _csr_szFilePath     [ CSR_MAX_OPENED_FILES ] [ CSR_MAX_FILENAME_SIZE ],
    _csr_szFileContent  [ CSR_MAX_OPENED_FILES ] [ CSR_MAX_FILE_SIZE char ];

































  
stock csr_rename_file ( file_id, new_file_name[], delete_old_file = 1 )
{

    if ( file_id < 0 || file_id >= MAX_OPENED_FILES || fUsed == 0 )
        return INI_WRONG_FILE_ID;


    if ( delete_old_file )
    {

        new fName[MAX_FILENAME_SIZE];
        getproperty( STORE_MACHINE, _, file_id, fName );
        strunpack( fName, fName );


        fremove(fName);
    }


    setproperty( STORE_MACHINE, _, file_id, new_file_name );


    fChanged = 1;

    return CSR_OK;
}
stock csr_createFile ( szFilePath[], szDefaultContent[] = "" )
{





    new nFileNameSize = strlen( szFilePath );


    if ( nFileNameSize <= 0 || nFileNameSize >= CSR_MAX_FILENAME_SIZE )
        return CSR_WRONG_PATH_SIZE;




    if ( fexist( szFilePath ) )
        return CSR_FILE_ALREADY_EXIST;

    for ( new slot = 0; slot < CSR_MAX_OPENED_FILES; slot++ )
        if
        (
                _csr_nSlotUsed[slot] != 0
            &&  strcmp( szFilePath, _csr_szFilePath[slot], false ) == 0
        )
            return CSR_FILE_ALREADY_EXIST;





    new nFileSize = strlen( szDefaultContent );


    if ( nFileSize < 0 || nFileSize >= CSR_MAX_FILE_SIZE )
        return CSR_TOO_LARGE_FILE;









    for ( new slot = 0; slot < CSR_MAX_OPENED_FILES; slot++ )
    {
        if ( _csr_nSlotUsed[slot] != 1 )
        {

            _csr_nSlotUsed[slot]        = 1;
            _csr_nFileChanged[slot]     = 0;
            _csr_nFileSize[slot]        = nFileSize;
            _csr_nKeysCount[slot]       = 0;






            for ( new i = 0;  i < nFileSize && i < CSR_MAX_FILE_SIZE;  i++ )
            {
                if (
                        szDefaultContent[i] == CSR_DELIMITER
                    &&  _csr_nKeysCount[slot] < CSR_MAX_KEYS_IN_FILE
                ) {
                    _csr_nDelimPos[slot][ _csr_nKeysCount[slot] ] = i;
                    _csr_nKeysCount[slot]++;
                }

                _csr_szFileContent[slot]{i} = szDefaultContent[i];
            }

            _csr_szFileContent[slot]{nFileSize} = 0;





            memcpy( _csr_szFilePath[slot], szFilePath, 0, nFileNameSize * cellbytes );

            _csr_szFilePath[slot][nFileNameSize] = 0;



            return slot;
        }
    }








    return CSR_NO_FREE_SLOT;

}














  

stock csr_openFile ( szFilePath[] )
{





    new nFileNameSize = strlen( szFilePath );


    if ( nFileNameSize <= 0 || nFileNameSize >= CSR_MAX_FILENAME_SIZE )
        return CSR_WRONG_PATH_SIZE;



    if ( ! fexist( szFilePath ) )
        return CSR_FILE_NOT_FOUND;




    for ( new slot = 0; slot < CSR_MAX_OPENED_FILES; slot++ )
        if
        (
                _csr_nSlotUsed[slot] != 0
            &&  strcmp( szFilePath, _csr_szFilePath[slot], false ) == 0
        )
            return slot;




    new File: pFile = fopen( szFilePath, io_read );

    if ( ! pFile )
        return CSR_READ_ERROR;




    new nFileSize = flength( pFile );

    if ( nFileSize >= CSR_MAX_FILE_SIZE )
    {
        fclose(pFile);
        return CSR_TOO_LARGE_FILE;
    }










    for ( new slot = 0; slot < CSR_MAX_OPENED_FILES; slot++ )
    {
        if ( _csr_nSlotUsed[slot] != 1 )
        {

            _csr_nSlotUsed[slot]        = 1;
            _csr_nFileChanged[slot]     = 0;
            _csr_nFileSize[slot]        = nFileSize;
            _csr_nKeysCount[slot]       = 0;






            for ( new i = 0, symbol, nextstr = 1; i < nFileSize && i < CSR_MAX_FILE_SIZE; i++ )
            {
                symbol = fgetchar( pFile, 0, false );

                if ( symbol == CSR_STRING_DELIMITER )
                    nextstr = 1;

                if (
                        nextstr
                    &&  symbol == CSR_DELIMITER
                    &&  _csr_nKeysCount[slot] < CSR_MAX_KEYS_IN_FILE
                ) {
                    _csr_nDelimPos[slot][ _csr_nKeysCount[slot] ] = i;
                    _csr_nKeysCount[slot]++;
                    nextstr = 0;
                }

                _csr_szFileContent[slot]{i} = symbol;
            }

            _csr_szFileContent[slot]{nFileSize} = 0;

            fclose(pFile);





            memcpy( _csr_szFilePath[slot], szFilePath, 0, nFileNameSize * cellbytes );

            _csr_szFilePath[slot][nFileNameSize] = 0;



            return slot;
        }
    }










    fclose(pFile);

    return CSR_NO_FREE_SLOT;

}













  

stock csr_closeFile ( nFilePointer )
{
    if
    (
            nFilePointer >= 0
        &&  nFilePointer < CSR_MAX_OPENED_FILES
        &&  _csr_nSlotUsed[nFilePointer] != 0
    )
    {
        if ( _csr_nFileChanged[nFilePointer] != 0 )
        {
            new File: pFile = fopen( _csr_szFilePath[nFilePointer], io_write );

            if ( ! pFile )
                return CSR_WRITE_ERROR;


            for ( new i = 0;  i < _csr_nFileSize[nFilePointer];  i++ )
                fputchar( pFile, _csr_szFileContent[nFilePointer]{i}, false );

            fclose(pFile);
        }

        _csr_nSlotUsed[nFilePointer] = 0;

        return CSR_OK;
    }

    return CSR_WRONG_SLOT;
}
































  

stock csr_getString ( nFilePointer, szKeyName[], szReturnValue[], nSizeOfReturn = sizeof(szReturnValue) )
{

    if
    (
            nFilePointer < 0
        ||  nFilePointer >= CSR_MAX_OPENED_FILES
        ||  _csr_nSlotUsed[nFilePointer] != 1
    )
        return CSR_WRONG_SLOT;



    if ( nSizeOfReturn <= 0 )
        return CSR_WRONG_RETURN_SIZE;



    new nKeyLen = strlen(szKeyName);

    if ( nKeyLen <= 0 )
        return CSR_KEY_NOT_FOUND;




    for
    (
        new kPos = 0, curFilePos, found = 0;
        kPos < _csr_nKeysCount[nFilePointer];
        kPos++
    )
    {

        found = 0;

        for
        (
            curFilePos = _csr_nDelimPos[nFilePointer][kPos] - 1;
            curFilePos >= 0;
            curFilePos--
        )
        {
            switch ( _csr_szFileContent[nFilePointer]{curFilePos} )
            {
                case CSR_SPACE_CHAR :           continue;
                case CSR_STRING_DELIMITER :     break;
                default :
                {
                    found = 1;
                    break;
                }
            }
        }


        if ( found != 1 ) continue;




        for ( new curKeyPos = nKeyLen - 1;  curKeyPos >= 0;  curFilePos--, curKeyPos-- )
        {
            if
            (
                    curFilePos < 0
                ||  _csr_szFileContent[nFilePointer]{curFilePos} != szKeyName[curKeyPos]
                ||  _csr_szFileContent[nFilePointer]{curFilePos} == CSR_STRING_DELIMITER
            )
            {
                found = 0;
                break;
            }
        }



        if ( found != 0 )
        {

            if ( curFilePos >= 0 )
            {
                switch ( _csr_szFileContent[nFilePointer]{curFilePos} )
                {
                    case CSR_KEY_STARTS : {}
                    default: continue;
                }
            }




            curFilePos = _csr_nDelimPos[nFilePointer][kPos] + 1;


            for ( ; ; curFilePos++ )
            {
                if ( curFilePos >= _csr_nFileSize[nFilePointer] ) break;

                switch ( _csr_szFileContent[nFilePointer]{curFilePos} )
                {
                    case CSR_SPACE_CHAR :   continue;
                    default :               break;
                }
            }






            for ( found = 0;  found < nSizeOfReturn;  found++, curFilePos++ )
            {
                switch ( _csr_szFileContent[nFilePointer]{curFilePos} )
                {
                    case CSR_STRING_ENDS :
                    {
                        szReturnValue[found] = 0;
                        break;
                    }
                    default :

                        szReturnValue[found] = _csr_szFileContent[nFilePointer]{curFilePos};
                }
            }

            szReturnValue[nSizeOfReturn - 1] = 0;

            return CSR_OK;

        }

    }




    return CSR_KEY_NOT_FOUND;

}




















  

stock csr_getInteger ( nFilePointer, szKeyName[], & nReturnValue )
{

    if
    (
            nFilePointer < 0
        ||  nFilePointer >= CSR_MAX_OPENED_FILES
        ||  _csr_nSlotUsed[nFilePointer] != 1
    )
        return CSR_WRONG_SLOT;




    new nKeyLen = strlen(szKeyName);

    if ( nKeyLen <= 0 )
        return CSR_KEY_NOT_FOUND;




    for
    (
        new kPos = 0, curFilePos, found = 0;
        kPos < _csr_nKeysCount[nFilePointer];
        kPos++
    )
    {

        found = 0;

        for
        (
            curFilePos = _csr_nDelimPos[nFilePointer][kPos] - 1;
            curFilePos >= 0;
            curFilePos--
        )
        {
            switch ( _csr_szFileContent[nFilePointer]{curFilePos} )
            {
                case CSR_SPACE_CHAR :           continue;
                case CSR_STRING_DELIMITER :     break;
                default :
                {
                    found = 1;
                    break;
                }
            }
        }


        if ( found != 1 ) continue;




        for ( new curKeyPos = nKeyLen - 1;  curKeyPos >= 0;  curFilePos--, curKeyPos-- )
        {
            if
            (
                    curFilePos < 0
                ||  _csr_szFileContent[nFilePointer]{curFilePos} != szKeyName[curKeyPos]
                ||  _csr_szFileContent[nFilePointer]{curFilePos} == CSR_STRING_DELIMITER
            )
            {
                found = 0;
                break;
            }
        }



        if ( found != 0 )
        {

            if ( curFilePos >= 0 )
            {
                switch ( _csr_szFileContent[nFilePointer]{curFilePos} )
                {
                    case CSR_KEY_STARTS : {}
                    default: continue;
                }
            }




            curFilePos = _csr_nDelimPos[nFilePointer][kPos] + 1;


            for ( ; ; curFilePos++ )
            {
                if ( curFilePos >= _csr_nFileSize[nFilePointer] ) break;

                switch ( _csr_szFileContent[nFilePointer]{curFilePos} )
                {
                    case CSR_SPACE_CHAR :   continue;
                    default :               break;
                }
            }




            new strValue[CSR_INTEGER_SIZE];



            for ( found = 0;  found < CSR_INTEGER_SIZE;  found++, curFilePos++ )
            {
                switch ( _csr_szFileContent[nFilePointer]{curFilePos} )
                {
                    case CSR_NUMBER_ENDS :
                    {
                        strValue[found] = 0;
                        break;
                    }
                    default :

                        strValue[found] = _csr_szFileContent[nFilePointer]{curFilePos};
                }
            }

            strValue[CSR_INTEGER_SIZE - 1] = 0;

            nReturnValue = strval(strValue);

            return CSR_OK;

        }

    }




    return CSR_KEY_NOT_FOUND;

}




















  

stock csr_getFloat ( nFilePointer, szKeyName[], & Float: fReturnValue )
{

    if
    (
            nFilePointer < 0
        ||  nFilePointer >= CSR_MAX_OPENED_FILES
        ||  _csr_nSlotUsed[nFilePointer] != 1
    )
        return CSR_WRONG_SLOT;




    new nKeyLen = strlen(szKeyName);

    if ( nKeyLen <= 0 )
        return CSR_KEY_NOT_FOUND;




    for
    (
        new kPos = 0, curFilePos, found = 0;
        kPos < _csr_nKeysCount[nFilePointer];
        kPos++
    )
    {

        found = 0;

        for
        (
            curFilePos = _csr_nDelimPos[nFilePointer][kPos] - 1;
            curFilePos >= 0;
            curFilePos--
        )
        {
            switch ( _csr_szFileContent[nFilePointer]{curFilePos} )
            {
                case CSR_SPACE_CHAR :           continue;
                case CSR_STRING_DELIMITER :     break;
                default :
                {
                    found = 1;
                    break;
                }
            }
        }


        if ( found != 1 ) continue;




        for ( new curKeyPos = nKeyLen - 1;  curKeyPos >= 0;  curFilePos--, curKeyPos-- )
        {
            if
            (
                    curFilePos < 0
                ||  _csr_szFileContent[nFilePointer]{curFilePos} != szKeyName[curKeyPos]
                ||  _csr_szFileContent[nFilePointer]{curFilePos} == CSR_STRING_DELIMITER
            )
            {
                found = 0;
                break;
            }
        }



        if ( found != 0 )
        {

            if ( curFilePos >= 0 )
            {
                switch ( _csr_szFileContent[nFilePointer]{curFilePos} )
                {
                    case CSR_KEY_STARTS : {}
                    default: continue;
                }
            }




            curFilePos = _csr_nDelimPos[nFilePointer][kPos] + 1;


            for ( ; ; curFilePos++ )
            {
                if ( curFilePos >= _csr_nFileSize[nFilePointer] ) break;

                switch ( _csr_szFileContent[nFilePointer]{curFilePos} )
                {
                    case CSR_SPACE_CHAR :   continue;
                    default :               break;
                }
            }




            new strValue[CSR_FLOAT_SIZE];



            for ( found = 0;  found < CSR_INTEGER_SIZE;  found++, curFilePos++ )
            {
                switch ( _csr_szFileContent[nFilePointer]{curFilePos} )
                {
                    case CSR_NUMBER_ENDS :
                    {
                        strValue[found] = 0;
                        break;
                    }
                    default :

                        strValue[found] = _csr_szFileContent[nFilePointer]{curFilePos};
                }
            }

            strValue[CSR_FLOAT_SIZE - 1] = 0;

            fReturnValue = floatstr(strValue);

            return CSR_OK;

        }

    }




    return CSR_KEY_NOT_FOUND;

}




























  

stock csr_setString ( nFilePointer, szKeyName[], szKeyValue[] )
{

    if
    (
            nFilePointer < 0
        ||  nFilePointer >= CSR_MAX_OPENED_FILES
        ||  _csr_nSlotUsed[nFilePointer] != 1
    )
        return CSR_WRONG_SLOT;




    new nKeyLen = strlen(szKeyName);

    if ( nKeyLen <= 0 )
        return CSR_KEY_NOT_FOUND;




    for
    (
        new kPos = 0, curFilePos, found;
        kPos < _csr_nKeysCount[nFilePointer];
        kPos++
    )
    {

        found = 0;

        for
        (
            curFilePos = _csr_nDelimPos[nFilePointer][kPos] - 1;
            curFilePos >= 0;
            curFilePos--
        )
        {
            switch ( _csr_szFileContent[nFilePointer]{curFilePos} )
            {
                case CSR_SPACE_CHAR :           continue;
                case CSR_STRING_DELIMITER :     break;
                default :
                {
                    found = 1;
                    break;
                }
            }
        }


        if ( found != 1 ) continue;




        for ( new curKeyPos = nKeyLen - 1;  curKeyPos >= 0;  curFilePos--, curKeyPos-- )
        {
            if
            (
                    curFilePos < 0
                ||  _csr_szFileContent[nFilePointer]{curFilePos} != szKeyName[curKeyPos]
                ||  _csr_szFileContent[nFilePointer]{curFilePos} == CSR_STRING_DELIMITER
            )
            {
                found = 0;
                break;
            }
        }


        if ( found != 0 )
        {

            if ( curFilePos >= 0 )
            {
                switch ( _csr_szFileContent[nFilePointer]{curFilePos} )
                {
                    case CSR_KEY_STARTS : {}
                    default: continue;
                }
            }




            curFilePos = _csr_nDelimPos[nFilePointer][kPos] + 1;


            for ( ; ; curFilePos++ )
            {
                if ( curFilePos >= _csr_nFileSize[nFilePointer] ) break;

                switch ( _csr_szFileContent[nFilePointer]{curFilePos} )
                {
                    case CSR_SPACE_CHAR :   continue;
                    default :               break;
                }
            }




            new nValueLen = strlen(szKeyValue);


            if ( ( curFilePos + nValueLen ) >= CSR_MAX_FILE_SIZE )
                return CSR_TOO_LARGE_FILE;




            new fileValueStartPos = curFilePos;


            for ( ; ; curFilePos++ )
            {
                if ( curFilePos >= _csr_nFileSize[nFilePointer] ) break;

                switch ( _csr_szFileContent[nFilePointer]{curFilePos} )
                {
                    case CSR_STRING_ENDS :  break;
                    default :               continue;
                }
            }


            new filePosOffset = nValueLen - (                          curFilePos - fileValueStartPos );



            if ( _csr_nFileBusy[nFilePointer] != 0 )
                return CSR_WRITE_ERROR;



            _csr_nFileBusy[nFilePointer] = 1;

            if ( filePosOffset != 0 )
            {
                if ( filePosOffset < 0 )
                {
                    for
                    (
                        ;
                        curFilePos < _csr_nFileSize[nFilePointer];
                        curFilePos++
                    )
                        _csr_szFileContent[nFilePointer]{ curFilePos + filePosOffset } =
                            _csr_szFileContent[nFilePointer]{curFilePos};
                }
                else if ( filePosOffset > 0 )
                {
                    new fileValueEndPos = curFilePos;

                    for
                    (
                        curFilePos = _csr_nFileSize[nFilePointer] - 1;
                        curFilePos >= fileValueEndPos;
                        curFilePos--
                    )
                        _csr_szFileContent[nFilePointer]{ curFilePos + filePosOffset } =
                            _csr_szFileContent[nFilePointer]{curFilePos};
                }


                for ( kPos++;  kPos < _csr_nKeysCount[nFilePointer];  kPos++ )
                    _csr_nDelimPos[nFilePointer][kPos] += filePosOffset;

                _csr_nFileSize[nFilePointer] += filePosOffset;
                _csr_szFileContent[nFilePointer]{ _csr_nFileSize[nFilePointer] } = 0;
            }

            curFilePos = fileValueStartPos;
            for
            (
                new valuePos = 0;
                valuePos < nValueLen;
                curFilePos++, valuePos++
            )
                _csr_szFileContent[nFilePointer]{curFilePos} = szKeyValue[valuePos];

            _csr_nFileChanged[nFilePointer]     = 1;
            _csr_nFileBusy[nFilePointer]        = 0;

            return CSR_OK;

        }
    }








    new nValueLen = strlen(szKeyValue);


    if ( ( _csr_nFileSize[nFilePointer] + 5 + nKeyLen + nValueLen ) >= CSR_MAX_FILE_SIZE )
        return CSR_TOO_LARGE_FILE;




    if ( _csr_nFileBusy[nFilePointer] != 0 )
        return CSR_WRITE_ERROR;

    _csr_nFileBusy[nFilePointer] = 1;




    if
    (
            _csr_nFileSize[nFilePointer] > 0
        &&  _csr_szFileContent[nFilePointer]{ _csr_nFileSize[nFilePointer] - 1 } != CSR_STRING_DELIMITER
    )
    {

        _csr_szFileContent[nFilePointer]{ _csr_nFileSize[nFilePointer] }        = '\r';
        _csr_szFileContent[nFilePointer]{ _csr_nFileSize[nFilePointer] + 1 }    = CSR_STRING_DELIMITER;

        _csr_nFileSize[nFilePointer] += 2;
    }

    new curFilePos, strPos;

    for
    (
        curFilePos = _csr_nFileSize[nFilePointer], strPos = 0;
        strPos < nKeyLen;
        curFilePos++, strPos++
    )
        _csr_szFileContent[nFilePointer]{curFilePos} = szKeyName[strPos];

    _csr_szFileContent[nFilePointer]{ curFilePos++ }                = ' ';

    _csr_nDelimPos[nFilePointer][ _csr_nKeysCount[nFilePointer] ]   = curFilePos;
    _csr_nKeysCount[nFilePointer]++;

    _csr_szFileContent[nFilePointer]{ curFilePos++ }                = CSR_DELIMITER;
    _csr_szFileContent[nFilePointer]{ curFilePos++ }                = ' ';


    for ( strPos = 0;  strPos < nValueLen;  curFilePos++, strPos++ )
        _csr_szFileContent[nFilePointer]{curFilePos} = szKeyValue[strPos];

    _csr_szFileContent[nFilePointer]{curFilePos}    = 0;
    _csr_nFileSize[nFilePointer]                    = curFilePos;
    _csr_nFileChanged[nFilePointer]                 = 1;
    _csr_nFileBusy[nFilePointer]                    = 0;

    return CSR_OK;

}





















  

stock csr_setInteger ( nFilePointer, szKeyName[], nKeyValue )
{

    if
    (
            nFilePointer < 0
        ||  nFilePointer >= CSR_MAX_OPENED_FILES
        ||  _csr_nSlotUsed[nFilePointer] != 1
    )
        return CSR_WRONG_SLOT;




    new nKeyLen = strlen(szKeyName);

    if ( nKeyLen <= 0 )
        return CSR_KEY_NOT_FOUND;




    for
    (
        new kPos = 0, curFilePos, found;
        kPos < _csr_nKeysCount[nFilePointer];
        kPos++
    )
    {

        found = 0;

        for
        (
            curFilePos = _csr_nDelimPos[nFilePointer][kPos] - 1;
            curFilePos >= 0;
            curFilePos--
        )
        {
            switch ( _csr_szFileContent[nFilePointer]{curFilePos} )
            {
                case CSR_SPACE_CHAR :           continue;
                case CSR_STRING_DELIMITER :     break;
                default :
                {
                    found = 1;
                    break;
                }
            }
        }


        if ( found != 1 ) continue;




        for ( new curKeyPos = nKeyLen - 1;  curKeyPos >= 0;  curFilePos--, curKeyPos-- )
        {
            if
            (
                    curFilePos < 0
                ||  _csr_szFileContent[nFilePointer]{curFilePos} != szKeyName[curKeyPos]
                ||  _csr_szFileContent[nFilePointer]{curFilePos} == CSR_STRING_DELIMITER
            )
            {
                found = 0;
                break;
            }
        }


        if ( found != 0 )
        {

            if ( curFilePos >= 0 )
            {
                switch ( _csr_szFileContent[nFilePointer]{curFilePos} )
                {
                    case CSR_KEY_STARTS : {}
                    default: continue;
                }
            }




            curFilePos = _csr_nDelimPos[nFilePointer][kPos] + 1;


            for ( ; ; curFilePos++ )
            {
                if ( curFilePos >= _csr_nFileSize[nFilePointer] ) break;

                switch ( _csr_szFileContent[nFilePointer]{curFilePos} )
                {
                    case CSR_SPACE_CHAR :   continue;
                    default :               break;
                }
            }




            new szKeyValue[CSR_INTEGER_SIZE];
            format( szKeyValue, CSR_INTEGER_SIZE, "%i", nKeyValue );




            new nValueLen = strlen(szKeyValue);


            if ( ( curFilePos + nValueLen ) >= CSR_MAX_FILE_SIZE )
                return CSR_TOO_LARGE_FILE;




            new fileValueStartPos = curFilePos;


            for ( ; ; curFilePos++ )
            {
                if ( curFilePos >= _csr_nFileSize[nFilePointer] ) break;

                switch ( _csr_szFileContent[nFilePointer]{curFilePos} )
                {
                    case CSR_NUMBER_ENDS :  break;
                    default :               continue;
                }
            }


            new filePosOffset = nValueLen - (                          curFilePos - fileValueStartPos );



            if ( _csr_nFileBusy[nFilePointer] != 0 )
                return CSR_WRITE_ERROR;



            _csr_nFileBusy[nFilePointer] = 1;

            if ( filePosOffset != 0 )
            {
                if ( filePosOffset < 0 )
                {
                    for
                    (
                        ;
                        curFilePos < _csr_nFileSize[nFilePointer];
                        curFilePos++
                    )
                        _csr_szFileContent[nFilePointer]{ curFilePos + filePosOffset } =
                            _csr_szFileContent[nFilePointer]{curFilePos};
                }
                else if ( filePosOffset > 0 )
                {
                    new fileValueEndPos = curFilePos;

                    for
                    (
                        curFilePos = _csr_nFileSize[nFilePointer] - 1;
                        curFilePos >= fileValueEndPos;
                        curFilePos--
                    )
                        _csr_szFileContent[nFilePointer]{ curFilePos + filePosOffset } =
                            _csr_szFileContent[nFilePointer]{curFilePos};
                }


                for ( kPos++;  kPos < _csr_nKeysCount[nFilePointer];  kPos++ )
                    _csr_nDelimPos[nFilePointer][kPos] += filePosOffset;

                _csr_nFileSize[nFilePointer] += filePosOffset;
                _csr_szFileContent[nFilePointer]{ _csr_nFileSize[nFilePointer] } = 0;
            }

            curFilePos = fileValueStartPos;
            for
            (
                new valuePos = 0;
                valuePos < nValueLen;
                curFilePos++, valuePos++
            )
                _csr_szFileContent[nFilePointer]{curFilePos} = szKeyValue[valuePos];

            _csr_nFileChanged[nFilePointer]     = 1;
            _csr_nFileBusy[nFilePointer]        = 0;

            return CSR_OK;

        }
    }








    new szKeyValue[CSR_INTEGER_SIZE];
    format( szKeyValue, CSR_INTEGER_SIZE, "%i", nKeyValue );




    new nValueLen = strlen(szKeyValue);


    if ( ( _csr_nFileSize[nFilePointer] + 5 + nKeyLen + nValueLen ) >= CSR_MAX_FILE_SIZE )
        return CSR_TOO_LARGE_FILE;




    if ( _csr_nFileBusy[nFilePointer] != 0 )
        return CSR_WRITE_ERROR;

    _csr_nFileBusy[nFilePointer] = 1;




    if
    (
            _csr_nFileSize[nFilePointer] > 0
        &&  _csr_szFileContent[nFilePointer]{ _csr_nFileSize[nFilePointer] - 1 } != CSR_STRING_DELIMITER
    )
    {

        _csr_szFileContent[nFilePointer]{ _csr_nFileSize[nFilePointer] }        = '\r';
        _csr_szFileContent[nFilePointer]{ _csr_nFileSize[nFilePointer] + 1 }    = CSR_STRING_DELIMITER;

        _csr_nFileSize[nFilePointer] += 2;
    }

    new curFilePos, strPos;

    for
    (
        curFilePos = _csr_nFileSize[nFilePointer], strPos = 0;
        strPos < nKeyLen;
        curFilePos++, strPos++
    )
        _csr_szFileContent[nFilePointer]{curFilePos} = szKeyName[strPos];

    _csr_szFileContent[nFilePointer]{ curFilePos++ }                = ' ';

    _csr_nDelimPos[nFilePointer][ _csr_nKeysCount[nFilePointer] ]   = curFilePos;
    _csr_nKeysCount[nFilePointer]++;

    _csr_szFileContent[nFilePointer]{ curFilePos++ }                = CSR_DELIMITER;
    _csr_szFileContent[nFilePointer]{ curFilePos++ }                = ' ';


    for ( strPos = 0;  strPos < nValueLen;  curFilePos++, strPos++ )
        _csr_szFileContent[nFilePointer]{curFilePos} = szKeyValue[strPos];

    _csr_szFileContent[nFilePointer]{curFilePos}    = 0;
    _csr_nFileSize[nFilePointer]                    = curFilePos;
    _csr_nFileChanged[nFilePointer]                 = 1;
    _csr_nFileBusy[nFilePointer]                    = 0;

    return CSR_OK;

}





















  

stock csr_setFloat ( nFilePointer, szKeyName[], Float: fKeyValue )
{

    if
    (
            nFilePointer < 0
        ||  nFilePointer >= CSR_MAX_OPENED_FILES
        ||  _csr_nSlotUsed[nFilePointer] != 1
    )
        return CSR_WRONG_SLOT;




    new nKeyLen = strlen(szKeyName);

    if ( nKeyLen <= 0 )
        return CSR_KEY_NOT_FOUND;




    for
    (
        new kPos = 0, curFilePos, found;
        kPos < _csr_nKeysCount[nFilePointer];
        kPos++
    )
    {

        found = 0;

        for
        (
            curFilePos = _csr_nDelimPos[nFilePointer][kPos] - 1;
            curFilePos >= 0;
            curFilePos--
        )
        {
            switch ( _csr_szFileContent[nFilePointer]{curFilePos} )
            {
                case CSR_SPACE_CHAR :           continue;
                case CSR_STRING_DELIMITER :     break;
                default :
                {
                    found = 1;
                    break;
                }
            }
        }


        if ( found != 1 ) continue;




        for ( new curKeyPos = nKeyLen - 1;  curKeyPos >= 0;  curFilePos--, curKeyPos-- )
        {
            if
            (
                    curFilePos < 0
                ||  _csr_szFileContent[nFilePointer]{curFilePos} != szKeyName[curKeyPos]
                ||  _csr_szFileContent[nFilePointer]{curFilePos} == CSR_STRING_DELIMITER
            )
            {
                found = 0;
                break;
            }
        }


        if ( found != 0 )
        {

            if ( curFilePos >= 0 )
            {
                switch ( _csr_szFileContent[nFilePointer]{curFilePos} )
                {
                    case CSR_KEY_STARTS : {}
                    default: continue;
                }
            }




            curFilePos = _csr_nDelimPos[nFilePointer][kPos] + 1;


            for ( ; ; curFilePos++ )
            {
                if ( curFilePos >= _csr_nFileSize[nFilePointer] ) break;

                switch ( _csr_szFileContent[nFilePointer]{curFilePos} )
                {
                    case CSR_SPACE_CHAR :   continue;
                    default :               break;
                }
            }




            new szKeyValue[CSR_FLOAT_SIZE];
            format( szKeyValue, CSR_FLOAT_SIZE, "%f", fKeyValue );




            new nValueLen = strlen(szKeyValue);


            if ( ( curFilePos + nValueLen ) >= CSR_MAX_FILE_SIZE )
                return CSR_TOO_LARGE_FILE;




            new fileValueStartPos = curFilePos;


            for ( ; ; curFilePos++ )
            {
                if ( curFilePos >= _csr_nFileSize[nFilePointer] ) break;

                switch ( _csr_szFileContent[nFilePointer]{curFilePos} )
                {
                    case CSR_NUMBER_ENDS :  break;
                    default :               continue;
                }
            }


            new filePosOffset = nValueLen - (                          curFilePos - fileValueStartPos );



            if ( _csr_nFileBusy[nFilePointer] != 0 )
                return CSR_WRITE_ERROR;



            _csr_nFileBusy[nFilePointer] = 1;

            if ( filePosOffset != 0 )
            {
                if ( filePosOffset < 0 )
                {
                    for
                    (
                        ;
                        curFilePos < _csr_nFileSize[nFilePointer];
                        curFilePos++
                    )
                        _csr_szFileContent[nFilePointer]{ curFilePos + filePosOffset } =
                            _csr_szFileContent[nFilePointer]{curFilePos};
                }
                else if ( filePosOffset > 0 )
                {
                    new fileValueEndPos = curFilePos;

                    for
                    (
                        curFilePos = _csr_nFileSize[nFilePointer] - 1;
                        curFilePos >= fileValueEndPos;
                        curFilePos--
                    )
                        _csr_szFileContent[nFilePointer]{ curFilePos + filePosOffset } =
                            _csr_szFileContent[nFilePointer]{curFilePos};
                }


                for ( kPos++;  kPos < _csr_nKeysCount[nFilePointer];  kPos++ )
                    _csr_nDelimPos[nFilePointer][kPos] += filePosOffset;

                _csr_nFileSize[nFilePointer] += filePosOffset;
                _csr_szFileContent[nFilePointer]{ _csr_nFileSize[nFilePointer] } = 0;
            }

            curFilePos = fileValueStartPos;
            for
            (
                new valuePos = 0;
                valuePos < nValueLen;
                curFilePos++, valuePos++
            )
                _csr_szFileContent[nFilePointer]{curFilePos} = szKeyValue[valuePos];

            _csr_nFileChanged[nFilePointer]     = 1;
            _csr_nFileBusy[nFilePointer]        = 0;

            return CSR_OK;

        }
    }








    new szKeyValue[CSR_FLOAT_SIZE];
    format( szKeyValue, CSR_FLOAT_SIZE, "%f", fKeyValue );




    new nValueLen = strlen(szKeyValue);


    if ( ( _csr_nFileSize[nFilePointer] + 5 + nKeyLen + nValueLen ) >= CSR_MAX_FILE_SIZE )
        return CSR_TOO_LARGE_FILE;




    if ( _csr_nFileBusy[nFilePointer] != 0 )
        return CSR_WRITE_ERROR;

    _csr_nFileBusy[nFilePointer] = 1;




    if
    (
            _csr_nFileSize[nFilePointer] > 0
        &&  _csr_szFileContent[nFilePointer]{ _csr_nFileSize[nFilePointer] - 1 } != CSR_STRING_DELIMITER
    )
    {

        _csr_szFileContent[nFilePointer]{ _csr_nFileSize[nFilePointer] }        = '\r';
        _csr_szFileContent[nFilePointer]{ _csr_nFileSize[nFilePointer] + 1 }    = CSR_STRING_DELIMITER;

        _csr_nFileSize[nFilePointer] += 2;
    }

    new curFilePos, strPos;

    for
    (
        curFilePos = _csr_nFileSize[nFilePointer], strPos = 0;
        strPos < nKeyLen;
        curFilePos++, strPos++
    )
        _csr_szFileContent[nFilePointer]{curFilePos} = szKeyName[strPos];

    _csr_szFileContent[nFilePointer]{ curFilePos++ }                = ' ';

    _csr_nDelimPos[nFilePointer][ _csr_nKeysCount[nFilePointer] ]   = curFilePos;
    _csr_nKeysCount[nFilePointer]++;

    _csr_szFileContent[nFilePointer]{ curFilePos++ }                = CSR_DELIMITER;
    _csr_szFileContent[nFilePointer]{ curFilePos++ }                = ' ';


    for ( strPos = 0;  strPos < nValueLen;  curFilePos++, strPos++ )
        _csr_szFileContent[nFilePointer]{curFilePos} = szKeyValue[strPos];

    _csr_szFileContent[nFilePointer]{curFilePos}    = 0;
    _csr_nFileSize[nFilePointer]                    = curFilePos;
    _csr_nFileChanged[nFilePointer]                 = 1;
    _csr_nFileBusy[nFilePointer]                    = 0;

    return CSR_OK;

}


















  

stock csr_removeKey ( nFilePointer, szKeyName[] )
{

    if
    (
            nFilePointer < 0
        ||  nFilePointer >= CSR_MAX_OPENED_FILES
        ||  _csr_nSlotUsed[nFilePointer] != 1
    )
        return CSR_WRONG_SLOT;




    new nKeyLen = strlen(szKeyName);

    if ( nKeyLen <= 0 )
        return CSR_KEY_NOT_FOUND;




    for
    (
        new kPos = 0, curFilePos, found;
        kPos < _csr_nKeysCount[nFilePointer];
        kPos++
    )
    {

        found = 0;

        for
        (
            curFilePos = _csr_nDelimPos[nFilePointer][kPos] - 1;
            curFilePos >= 0;
            curFilePos--
        )
        {
            switch ( _csr_szFileContent[nFilePointer]{curFilePos} )
            {
                case CSR_SPACE_CHAR :           continue;
                case CSR_STRING_DELIMITER :     break;
                default :
                {
                    found = 1;
                    break;
                }
            }
        }


        if ( found != 1 ) continue;




        for ( new curKeyPos = nKeyLen - 1;  curKeyPos >= 0;  curFilePos--, curKeyPos-- )
        {
            if
            (
                    curFilePos < 0
                ||  _csr_szFileContent[nFilePointer]{curFilePos} != szKeyName[curKeyPos]
                ||  _csr_szFileContent[nFilePointer]{curFilePos} == CSR_STRING_DELIMITER
            )
            {
                found = 0;
                break;
            }
        }


        if ( found != 0 )
        {

            if ( curFilePos >= 0 )
            {
                switch ( _csr_szFileContent[nFilePointer]{curFilePos} )
                {
                    case CSR_KEY_STARTS : {}
                    default: continue;
                }
            }



            new keyStartPos = ( curFilePos <= 0 ) ? 0 : curFilePos + 1;




            curFilePos = _csr_nDelimPos[nFilePointer][kPos] + 1;


            for ( ; ; curFilePos++ )
            {
                if ( curFilePos >= _csr_nFileSize[nFilePointer] ) break;

                switch ( _csr_szFileContent[nFilePointer]{curFilePos} )
                {
                    case CSR_SPACE_CHAR :   continue;
                    default :               break;
                }
            }





            for ( ; ; curFilePos++ )
            {
                if ( curFilePos >= _csr_nFileSize[nFilePointer] ) break;

                switch ( _csr_szFileContent[nFilePointer]{curFilePos} )
                {
                    case CSR_STRING_ENDS :  break;
                    default :               continue;
                }
            }


            new filePosOffset = keyStartPos - curFilePos;



            if ( _csr_nFileBusy[nFilePointer] != 0 )
                return CSR_WRITE_ERROR;



            _csr_nFileBusy[nFilePointer] = 1;


            for ( ; curFilePos <= _csr_nFileSize[nFilePointer]; curFilePos++ )
                _csr_szFileContent[nFilePointer]{ curFilePos + filePosOffset } =
                    _csr_szFileContent[nFilePointer]{curFilePos};


            for ( ;  kPos < _csr_nKeysCount[nFilePointer];  kPos++ )
                _csr_nDelimPos[nFilePointer][kPos] = _csr_nDelimPos[nFilePointer][kPos + 1] + filePosOffset;

            _csr_nKeysCount[nFilePointer]--;
            _csr_nFileSize[nFilePointer] += filePosOffset;
            _csr_szFileContent[nFilePointer]{ _csr_nFileSize[nFilePointer] } = 0;

            _csr_nFileChanged[nFilePointer]     = 1;
            _csr_nFileBusy[nFilePointer]        = 0;

            return CSR_OK;

        }
    }








    return CSR_KEY_NOT_FOUND;

}


























  

stock csr_getErrorInfo ( nErrorCode )
{
    new error_ms[200] = "Ошибок нет";

    if ( nErrorCode >= 0 ) return error_ms;

    switch ( nErrorCode )
    {
        case CSR_FILE_NOT_FOUND :     error_ms = "INI файл, указанный в `csr_openFile`, не существует, возможно, указан неверный путь к нему";
        case CSR_FILE_ALREADY_EXIST : error_ms = "INI файл, указанный в `csr_createFile`, уже существует, укажите другое имя/путь к файлу";
        case CSR_TOO_LARGE_FILE :     error_ms = "Невозможно добавить новый ключ в INI файл, т.к. размер INI файла превысит допустимый лимит в " #CSR_MAX_FILE_SIZE " символ(ов), или будет превышен лимит в " #CSR_MAX_KEYS_IN_FILE " ключей";
        case CSR_WRONG_PATH_SIZE :    error_ms = "Длина пути к INI файлу, указанного в `csr_openFile` / `csr_createFile`, превышает лимит в " #CSR_MAX_FILENAME_SIZE " символ(ов)";
        case CSR_READ_ERROR :         error_ms = "Ошибка при чтении INI файла с диска, возможно, файл занят другим процессом";
        case CSR_WRITE_ERROR :        error_ms = "Ошибка при записи содержимого INI файла на диск, возможно, файл занят другим процессом";
        case CSR_NO_FREE_SLOT :       error_ms = "Лимит в " #CSR_MAX_OPENED_FILES " одновременно открытых INI файлов исчерпан, поэтому открыть/создать еще 1 файл нельзя, пока не закрыт хоть 1 из открытых файлов";
        case CSR_WRONG_SLOT :         error_ms = "Указан неверный ID открытого INI файла, возможно, при открытии INI файла произошла ошибка, поэтому вместо ID файла вы получили код ошибки";
        case CSR_KEY_NOT_FOUND :      error_ms = "Указанный ключ не найден в открытом INI файле";
        case CSR_WRONG_RETURN_SIZE :  error_ms = "При попытке чтения строкового значения из INI файла, последний параметр `nSizeOfReturn` в `csr_getString` оказался <= 0, укажите вручную значение > 0 для него";

        default:                      error_ms = "Неизвестная ошибка";
    }

    return error_ms;
}
