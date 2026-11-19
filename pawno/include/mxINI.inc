














































































  





#if defined _mxINI_included
    #endinput
#endif
#define _mxINI_included





const




#if !defined INI_MAX_OPENED_FILES
    INI_MAX_OPENED_FILES    = 2,
#endif
#if !defined INI_MAX_FILE_SIZE
    INI_MAX_FILE_SIZE       = 65536,
#endif
#if !defined INI_MAX_FILENAME_SIZE
    INI_MAX_FILENAME_SIZE   = 128,
#endif
#if !defined INI_MAX_KEYS_IN_FILE
    INI_MAX_KEYS_IN_FILE    = 2048,
#endif






    INI_INTEGER_SIZE        = 12,
    INI_FLOAT_SIZE          = 40,

    INI_STRING_DELIMITER    = '\n',
    INI_DELIMITER           = '=',





    INI_OK                  =  0,




    INI_FILE_NOT_FOUND      = -1,
    INI_FILE_ALREADY_EXIST  = -2,
    INI_TOO_LARGE_FILE      = -3,
    INI_WRONG_PATH_SIZE     = -4,
    INI_READ_ERROR          = -5,
    INI_WRITE_ERROR         = -6,
    INI_NO_FREE_SLOT        = -7,
    INI_WRONG_SLOT          = -8,
    INI_KEY_NOT_FOUND       = -9,
    INI_WRONG_RETURN_SIZE   = -10,





    cellbytes = cellbits / charbits;








#define INI_SPACE_CHARS ' ', '\t'
#define INI_KEY_STARTS  ' ', '\t', '\r', '\n', '\0'
#define INI_STRING_ENDS '\r', '\n', '\0'
#define INI_NUMBER_ENDS ' ', '\t', '\r', '\n', '\0'





static stock



    _ini_nSlotUsed      [ INI_MAX_OPENED_FILES ],
    _ini_nFileChanged   [ INI_MAX_OPENED_FILES ],
    _ini_nFileBusy      [ INI_MAX_OPENED_FILES ],
    _ini_nFileSize      [ INI_MAX_OPENED_FILES ],
    _ini_nDelimPos      [ INI_MAX_OPENED_FILES ] [ INI_MAX_KEYS_IN_FILE ],
    _ini_nKeysCount     [ INI_MAX_OPENED_FILES ],
    _ini_szFilePath     [ INI_MAX_OPENED_FILES ] [ INI_MAX_FILENAME_SIZE ],
    _ini_szFileContent  [ INI_MAX_OPENED_FILES ] [ INI_MAX_FILE_SIZE char ];




































  

stock ini_createFile ( const szFilePath[], const szDefaultContent[] = "" )
{





    new nFileNameSize = strlen( szFilePath );


    if ( nFileNameSize <= 0 || nFileNameSize >= INI_MAX_FILENAME_SIZE )
        return INI_WRONG_PATH_SIZE;




    if ( fexist( szFilePath ) )
        return INI_FILE_ALREADY_EXIST;

    for ( new slot = 0; slot < INI_MAX_OPENED_FILES; slot++ )
        if
        (
                _ini_nSlotUsed[slot] != 0
            &&  strcmp( szFilePath, _ini_szFilePath[slot], false ) == 0
        )
            return INI_FILE_ALREADY_EXIST;





    new nFileSize = strlen( szDefaultContent );


    if ( nFileSize < 0 || nFileSize >= INI_MAX_FILE_SIZE )
        return INI_TOO_LARGE_FILE;









    for ( new slot = 0; slot < INI_MAX_OPENED_FILES; slot++ )
    {
        if ( _ini_nSlotUsed[slot] != 1 )
        {

            _ini_nSlotUsed[slot]        = 1;
            _ini_nFileChanged[slot]     = 0;
            _ini_nFileSize[slot]        = nFileSize;
            _ini_nKeysCount[slot]       = 0;






            for ( new i = 0;  i < nFileSize && i < INI_MAX_FILE_SIZE;  i++ )
            {
                if (
                        szDefaultContent[i] == INI_DELIMITER
                    &&  _ini_nKeysCount[slot] < INI_MAX_KEYS_IN_FILE
                ) {
                    _ini_nDelimPos[slot][ _ini_nKeysCount[slot] ] = i;
                    _ini_nKeysCount[slot]++;
                }

                _ini_szFileContent[slot]{i} = szDefaultContent[i];
            }

            _ini_szFileContent[slot]{nFileSize} = 0;





            memcpy( _ini_szFilePath[slot], szFilePath, 0, nFileNameSize * cellbytes );

            _ini_szFilePath[slot][nFileNameSize] = 0;



            return slot;
        }
    }








    return INI_NO_FREE_SLOT;

}

















  

stock ini_openFile ( const szFilePath[] )
{





    new nFileNameSize = strlen( szFilePath );


    if ( nFileNameSize <= 0 || nFileNameSize >= INI_MAX_FILENAME_SIZE )
        return INI_WRONG_PATH_SIZE;



    if ( ! fexist( szFilePath ) )
        return INI_FILE_NOT_FOUND;




    for ( new slot = 0; slot < INI_MAX_OPENED_FILES; slot++ )
        if
        (
                _ini_nSlotUsed[slot] != 0
            &&  strcmp( szFilePath, _ini_szFilePath[slot], false ) == 0
        )
            return slot;




    new File: pFile = fopen( szFilePath, io_read );

    if ( ! pFile )
        return INI_READ_ERROR;




    new nFileSize = flength( pFile );

    if ( nFileSize >= INI_MAX_FILE_SIZE )
    {
        fclose(pFile);
        return INI_TOO_LARGE_FILE;
    }










    for ( new slot = 0; slot < INI_MAX_OPENED_FILES; slot++ )
    {
        if ( _ini_nSlotUsed[slot] != 1 )
        {

            _ini_nSlotUsed[slot]        = 1;
            _ini_nFileChanged[slot]     = 0;
            _ini_nFileSize[slot]        = nFileSize;
            _ini_nKeysCount[slot]       = 0;






            for ( new i = 0, symbol, nextstr = 1; i < nFileSize && i < INI_MAX_FILE_SIZE; i++ )
            {
                symbol = fgetchar( pFile, 0, false );

                if ( symbol == INI_STRING_DELIMITER )
                    nextstr = 1;

                if (
                        nextstr
                    &&  symbol == INI_DELIMITER
                    &&  _ini_nKeysCount[slot] < INI_MAX_KEYS_IN_FILE
                ) {
                    _ini_nDelimPos[slot][ _ini_nKeysCount[slot] ] = i;
                    _ini_nKeysCount[slot]++;
                    nextstr = 0;
                }

                _ini_szFileContent[slot]{i} = symbol;
            }

            _ini_szFileContent[slot]{nFileSize} = 0;

            fclose(pFile);





            memcpy( _ini_szFilePath[slot], szFilePath, 0, nFileNameSize * cellbytes );

            _ini_szFilePath[slot][nFileNameSize] = 0;



            return slot;
        }
    }










    fclose(pFile);

    return INI_NO_FREE_SLOT;

}
















  

stock ini_closeFile ( nFilePointer )
{
    if
    (
            nFilePointer >= 0
        &&  nFilePointer < INI_MAX_OPENED_FILES
        &&  _ini_nSlotUsed[nFilePointer] != 0
    )
    {
        if ( _ini_nFileChanged[nFilePointer] != 0 )
        {
            new File: pFile = fopen( _ini_szFilePath[nFilePointer], io_write );

            if ( ! pFile )
                return INI_WRITE_ERROR;


            for ( new i = 0;  i < _ini_nFileSize[nFilePointer];  i++ )
                fputchar( pFile, _ini_szFileContent[nFilePointer]{i}, false );

            fclose(pFile);
        }

        _ini_nSlotUsed[nFilePointer] = 0;

        return INI_OK;
    }

    return INI_WRONG_SLOT;
}






































  

stock ini_getString ( nFilePointer, const szKeyName[], szReturnValue[], nSizeOfReturn = sizeof(szReturnValue) )
{

    if
    (
            nFilePointer < 0
        ||  nFilePointer >= INI_MAX_OPENED_FILES
        ||  _ini_nSlotUsed[nFilePointer] != 1
    )
        return INI_WRONG_SLOT;



    if ( nSizeOfReturn <= 0 )
        return INI_WRONG_RETURN_SIZE;



    new nKeyLen = strlen(szKeyName);

    if ( nKeyLen <= 0 )
        return INI_KEY_NOT_FOUND;




    for
    (
        new kPos = 0, curFilePos, found = 0;
        kPos < _ini_nKeysCount[nFilePointer];
        kPos++
    )
    {

        found = 0;

        for
        (
            curFilePos = _ini_nDelimPos[nFilePointer][kPos] - 1;
            curFilePos >= 0;
            curFilePos--
        )
        {
            switch ( _ini_szFileContent[nFilePointer]{curFilePos} )
            {
                case INI_SPACE_CHARS :          continue;
                case INI_STRING_DELIMITER :     break;
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
                ||  _ini_szFileContent[nFilePointer]{curFilePos} != szKeyName[curKeyPos]
                ||  _ini_szFileContent[nFilePointer]{curFilePos} == INI_STRING_DELIMITER
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
                switch ( _ini_szFileContent[nFilePointer]{curFilePos} )
                {
                    case INI_KEY_STARTS : {}
                    default: continue;
                }
            }




            curFilePos = _ini_nDelimPos[nFilePointer][kPos] + 1;


            for ( ; ; curFilePos++ )
            {
                if ( curFilePos >= _ini_nFileSize[nFilePointer] ) break;

                switch ( _ini_szFileContent[nFilePointer]{curFilePos} )
                {
                    case INI_SPACE_CHARS :  continue;
                    default :               break;
                }
            }






            for ( found = 0;  found < nSizeOfReturn;  found++, curFilePos++ )
            {
                switch ( _ini_szFileContent[nFilePointer]{curFilePos} )
                {
                    case INI_STRING_ENDS :
                    {
                        szReturnValue[found] = 0;
                        break;
                    }
                    default :

                        szReturnValue[found] = _ini_szFileContent[nFilePointer]{curFilePos};
                }
            }

            szReturnValue[nSizeOfReturn - 1] = 0;

            return INI_OK;

        }

    }




    return INI_KEY_NOT_FOUND;

}

























  

stock ini_getInteger ( nFilePointer, const szKeyName[], & nReturnValue )
{

    if
    (
            nFilePointer < 0
        ||  nFilePointer >= INI_MAX_OPENED_FILES
        ||  _ini_nSlotUsed[nFilePointer] != 1
    )
        return INI_WRONG_SLOT;




    new nKeyLen = strlen(szKeyName);

    if ( nKeyLen <= 0 )
        return INI_KEY_NOT_FOUND;




    for
    (
        new kPos = 0, curFilePos, found = 0;
        kPos < _ini_nKeysCount[nFilePointer];
        kPos++
    )
    {

        found = 0;

        for
        (
            curFilePos = _ini_nDelimPos[nFilePointer][kPos] - 1;
            curFilePos >= 0;
            curFilePos--
        )
        {
            switch ( _ini_szFileContent[nFilePointer]{curFilePos} )
            {
                case INI_SPACE_CHARS :          continue;
                case INI_STRING_DELIMITER :     break;
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
                ||  _ini_szFileContent[nFilePointer]{curFilePos} != szKeyName[curKeyPos]
                ||  _ini_szFileContent[nFilePointer]{curFilePos} == INI_STRING_DELIMITER
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
                switch ( _ini_szFileContent[nFilePointer]{curFilePos} )
                {
                    case INI_KEY_STARTS : {}
                    default: continue;
                }
            }




            curFilePos = _ini_nDelimPos[nFilePointer][kPos] + 1;


            for ( ; ; curFilePos++ )
            {
                if ( curFilePos >= _ini_nFileSize[nFilePointer] ) break;

                switch ( _ini_szFileContent[nFilePointer]{curFilePos} )
                {
                    case INI_SPACE_CHARS :  continue;
                    default :               break;
                }
            }




            new strValue[INI_INTEGER_SIZE];



            for ( found = 0;  found < INI_INTEGER_SIZE;  found++, curFilePos++ )
            {
                switch ( _ini_szFileContent[nFilePointer]{curFilePos} )
                {
                    case INI_NUMBER_ENDS :
                    {
                        strValue[found] = 0;
                        break;
                    }
                    default :

                        strValue[found] = _ini_szFileContent[nFilePointer]{curFilePos};
                }
            }

            strValue[INI_INTEGER_SIZE - 1] = 0;

            nReturnValue = strval(strValue);

            return INI_OK;

        }

    }




    return INI_KEY_NOT_FOUND;

}

























  

stock ini_getFloat ( nFilePointer, const szKeyName[], & Float: fReturnValue )
{

    if
    (
            nFilePointer < 0
        ||  nFilePointer >= INI_MAX_OPENED_FILES
        ||  _ini_nSlotUsed[nFilePointer] != 1
    )
        return INI_WRONG_SLOT;




    new nKeyLen = strlen(szKeyName);

    if ( nKeyLen <= 0 )
        return INI_KEY_NOT_FOUND;




    for
    (
        new kPos = 0, curFilePos, found = 0;
        kPos < _ini_nKeysCount[nFilePointer];
        kPos++
    )
    {

        found = 0;

        for
        (
            curFilePos = _ini_nDelimPos[nFilePointer][kPos] - 1;
            curFilePos >= 0;
            curFilePos--
        )
        {
            switch ( _ini_szFileContent[nFilePointer]{curFilePos} )
            {
                case INI_SPACE_CHARS :          continue;
                case INI_STRING_DELIMITER :     break;
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
                ||  _ini_szFileContent[nFilePointer]{curFilePos} != szKeyName[curKeyPos]
                ||  _ini_szFileContent[nFilePointer]{curFilePos} == INI_STRING_DELIMITER
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
                switch ( _ini_szFileContent[nFilePointer]{curFilePos} )
                {
                    case INI_KEY_STARTS : {}
                    default: continue;
                }
            }




            curFilePos = _ini_nDelimPos[nFilePointer][kPos] + 1;


            for ( ; ; curFilePos++ )
            {
                if ( curFilePos >= _ini_nFileSize[nFilePointer] ) break;

                switch ( _ini_szFileContent[nFilePointer]{curFilePos} )
                {
                    case INI_SPACE_CHARS :  continue;
                    default :               break;
                }
            }




            new strValue[INI_FLOAT_SIZE];



            for ( found = 0;  found < INI_INTEGER_SIZE;  found++, curFilePos++ )
            {
                switch ( _ini_szFileContent[nFilePointer]{curFilePos} )
                {
                    case INI_NUMBER_ENDS :
                    {
                        strValue[found] = 0;
                        break;
                    }
                    default :

                        strValue[found] = _ini_szFileContent[nFilePointer]{curFilePos};
                }
            }

            strValue[INI_FLOAT_SIZE - 1] = 0;

            fReturnValue = floatstr(strValue);

            return INI_OK;

        }

    }




    return INI_KEY_NOT_FOUND;

}

































  

stock ini_setString ( nFilePointer, const szKeyName[], const szKeyValue[] )
{

    if
    (
            nFilePointer < 0
        ||  nFilePointer >= INI_MAX_OPENED_FILES
        ||  _ini_nSlotUsed[nFilePointer] != 1
    )
        return INI_WRONG_SLOT;




    new nKeyLen = strlen(szKeyName);

    if ( nKeyLen <= 0 )
        return INI_KEY_NOT_FOUND;




    for
    (
        new kPos = 0, curFilePos, found;
        kPos < _ini_nKeysCount[nFilePointer];
        kPos++
    )
    {

        found = 0;

        for
        (
            curFilePos = _ini_nDelimPos[nFilePointer][kPos] - 1;
            curFilePos >= 0;
            curFilePos--
        )
        {
            switch ( _ini_szFileContent[nFilePointer]{curFilePos} )
            {
                case INI_SPACE_CHARS :          continue;
                case INI_STRING_DELIMITER :     break;
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
                ||  _ini_szFileContent[nFilePointer]{curFilePos} != szKeyName[curKeyPos]
                ||  _ini_szFileContent[nFilePointer]{curFilePos} == INI_STRING_DELIMITER
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
                switch ( _ini_szFileContent[nFilePointer]{curFilePos} )
                {
                    case INI_KEY_STARTS : {}
                    default: continue;
                }
            }




            curFilePos = _ini_nDelimPos[nFilePointer][kPos] + 1;


            for ( ; ; curFilePos++ )
            {
                if ( curFilePos >= _ini_nFileSize[nFilePointer] ) break;

                switch ( _ini_szFileContent[nFilePointer]{curFilePos} )
                {
                    case INI_SPACE_CHARS :  continue;
                    default :               break;
                }
            }




            new nValueLen = strlen(szKeyValue);


            if ( ( curFilePos + nValueLen ) >= INI_MAX_FILE_SIZE )
                return INI_TOO_LARGE_FILE;




            new fileValueStartPos = curFilePos;


            for ( ; ; curFilePos++ )
            {
                if ( curFilePos >= _ini_nFileSize[nFilePointer] ) break;

                switch ( _ini_szFileContent[nFilePointer]{curFilePos} )
                {
                    case INI_STRING_ENDS :  break;
                    default :               continue;
                }
            }


            new filePosOffset = nValueLen - (                                            curFilePos - fileValueStartPos );



            if ( _ini_nFileBusy[nFilePointer] != 0 )
                return INI_WRITE_ERROR;



            _ini_nFileBusy[nFilePointer] = 1;

            if ( filePosOffset != 0 )
            {
                if ( filePosOffset < 0 )
                {
                    for
                    (
                        ;
                        curFilePos < _ini_nFileSize[nFilePointer];
                        curFilePos++
                    )
                        _ini_szFileContent[nFilePointer]{ curFilePos + filePosOffset } =
                            _ini_szFileContent[nFilePointer]{curFilePos};
                }
                else if ( filePosOffset > 0 )
                {
                    new fileValueEndPos = curFilePos;

                    for
                    (
                        curFilePos = _ini_nFileSize[nFilePointer] - 1;
                        curFilePos >= fileValueEndPos;
                        curFilePos--
                    )
                        _ini_szFileContent[nFilePointer]{ curFilePos + filePosOffset } =
                            _ini_szFileContent[nFilePointer]{curFilePos};
                }


                for ( kPos++;  kPos < _ini_nKeysCount[nFilePointer];  kPos++ )
                    _ini_nDelimPos[nFilePointer][kPos] += filePosOffset;

                _ini_nFileSize[nFilePointer] += filePosOffset;
                _ini_szFileContent[nFilePointer]{ _ini_nFileSize[nFilePointer] } = 0;
            }

            curFilePos = fileValueStartPos;
            for
            (
                new valuePos = 0;
                valuePos < nValueLen;
                curFilePos++, valuePos++
            )
                _ini_szFileContent[nFilePointer]{curFilePos} = szKeyValue[valuePos];

            _ini_nFileChanged[nFilePointer]     = 1;
            _ini_nFileBusy[nFilePointer]        = 0;

            return INI_OK;

        }
    }








    new nValueLen = strlen(szKeyValue);


    if ( ( _ini_nFileSize[nFilePointer] + 5 + nKeyLen + nValueLen ) >= INI_MAX_FILE_SIZE )
        return INI_TOO_LARGE_FILE;




    if ( _ini_nFileBusy[nFilePointer] != 0 )
        return INI_WRITE_ERROR;

    _ini_nFileBusy[nFilePointer] = 1;




    if
    (
            _ini_nFileSize[nFilePointer] > 0
        &&  _ini_szFileContent[nFilePointer]{ _ini_nFileSize[nFilePointer] - 1 } != INI_STRING_DELIMITER
    )
    {

        _ini_szFileContent[nFilePointer]{ _ini_nFileSize[nFilePointer] }        = '\r';
        _ini_szFileContent[nFilePointer]{ _ini_nFileSize[nFilePointer] + 1 }    = INI_STRING_DELIMITER;

        _ini_nFileSize[nFilePointer] += 2;
    }

    new curFilePos, strPos;

    for
    (
        curFilePos = _ini_nFileSize[nFilePointer], strPos = 0;
        strPos < nKeyLen;
        curFilePos++, strPos++
    )
        _ini_szFileContent[nFilePointer]{curFilePos} = szKeyName[strPos];

    _ini_szFileContent[nFilePointer]{ curFilePos++ }                = ' ';

    _ini_nDelimPos[nFilePointer][ _ini_nKeysCount[nFilePointer] ]   = curFilePos;
    _ini_nKeysCount[nFilePointer]++;

    _ini_szFileContent[nFilePointer]{ curFilePos++ }                = INI_DELIMITER;
    _ini_szFileContent[nFilePointer]{ curFilePos++ }                = ' ';


    for ( strPos = 0;  strPos < nValueLen;  curFilePos++, strPos++ )
        _ini_szFileContent[nFilePointer]{curFilePos} = szKeyValue[strPos];

    _ini_szFileContent[nFilePointer]{curFilePos}    = 0;
    _ini_nFileSize[nFilePointer]                    = curFilePos;
    _ini_nFileChanged[nFilePointer]                 = 1;
    _ini_nFileBusy[nFilePointer]                    = 0;

    return INI_OK;

}


























  

stock ini_setInteger ( nFilePointer, const szKeyName[], nKeyValue )
{

    if
    (
            nFilePointer < 0
        ||  nFilePointer >= INI_MAX_OPENED_FILES
        ||  _ini_nSlotUsed[nFilePointer] != 1
    )
        return INI_WRONG_SLOT;




    new nKeyLen = strlen(szKeyName);

    if ( nKeyLen <= 0 )
        return INI_KEY_NOT_FOUND;




    for
    (
        new kPos = 0, curFilePos, found;
        kPos < _ini_nKeysCount[nFilePointer];
        kPos++
    )
    {

        found = 0;

        for
        (
            curFilePos = _ini_nDelimPos[nFilePointer][kPos] - 1;
            curFilePos >= 0;
            curFilePos--
        )
        {
            switch ( _ini_szFileContent[nFilePointer]{curFilePos} )
            {
                case INI_SPACE_CHARS :          continue;
                case INI_STRING_DELIMITER :     break;
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
                ||  _ini_szFileContent[nFilePointer]{curFilePos} != szKeyName[curKeyPos]
                ||  _ini_szFileContent[nFilePointer]{curFilePos} == INI_STRING_DELIMITER
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
                switch ( _ini_szFileContent[nFilePointer]{curFilePos} )
                {
                    case INI_KEY_STARTS : {}
                    default: continue;
                }
            }




            curFilePos = _ini_nDelimPos[nFilePointer][kPos] + 1;


            for ( ; ; curFilePos++ )
            {
                if ( curFilePos >= _ini_nFileSize[nFilePointer] ) break;

                switch ( _ini_szFileContent[nFilePointer]{curFilePos} )
                {
                    case INI_SPACE_CHARS :  continue;
                    default :               break;
                }
            }




            new szKeyValue[INI_INTEGER_SIZE];
            format( szKeyValue, INI_INTEGER_SIZE, "%i", nKeyValue );




            new nValueLen = strlen(szKeyValue);


            if ( ( curFilePos + nValueLen ) >= INI_MAX_FILE_SIZE )
                return INI_TOO_LARGE_FILE;




            new fileValueStartPos = curFilePos;


            for ( ; ; curFilePos++ )
            {
                if ( curFilePos >= _ini_nFileSize[nFilePointer] ) break;

                switch ( _ini_szFileContent[nFilePointer]{curFilePos} )
                {
                    case INI_NUMBER_ENDS :  break;
                    default :               continue;
                }
            }


            new filePosOffset = nValueLen - (                                            curFilePos - fileValueStartPos );



            if ( _ini_nFileBusy[nFilePointer] != 0 )
                return INI_WRITE_ERROR;



            _ini_nFileBusy[nFilePointer] = 1;

            if ( filePosOffset != 0 )
            {
                if ( filePosOffset < 0 )
                {
                    for
                    (
                        ;
                        curFilePos < _ini_nFileSize[nFilePointer];
                        curFilePos++
                    )
                        _ini_szFileContent[nFilePointer]{ curFilePos + filePosOffset } =
                            _ini_szFileContent[nFilePointer]{curFilePos};
                }
                else if ( filePosOffset > 0 )
                {
                    new fileValueEndPos = curFilePos;

                    for
                    (
                        curFilePos = _ini_nFileSize[nFilePointer] - 1;
                        curFilePos >= fileValueEndPos;
                        curFilePos--
                    )
                        _ini_szFileContent[nFilePointer]{ curFilePos + filePosOffset } =
                            _ini_szFileContent[nFilePointer]{curFilePos};
                }


                for ( kPos++;  kPos < _ini_nKeysCount[nFilePointer];  kPos++ )
                    _ini_nDelimPos[nFilePointer][kPos] += filePosOffset;

                _ini_nFileSize[nFilePointer] += filePosOffset;
                _ini_szFileContent[nFilePointer]{ _ini_nFileSize[nFilePointer] } = 0;
            }

            curFilePos = fileValueStartPos;
            for
            (
                new valuePos = 0;
                valuePos < nValueLen;
                curFilePos++, valuePos++
            )
                _ini_szFileContent[nFilePointer]{curFilePos} = szKeyValue[valuePos];

            _ini_nFileChanged[nFilePointer]     = 1;
            _ini_nFileBusy[nFilePointer]        = 0;

            return INI_OK;

        }
    }








    new szKeyValue[INI_INTEGER_SIZE];
    format( szKeyValue, INI_INTEGER_SIZE, "%i", nKeyValue );




    new nValueLen = strlen(szKeyValue);


    if ( ( _ini_nFileSize[nFilePointer] + 5 + nKeyLen + nValueLen ) >= INI_MAX_FILE_SIZE )
        return INI_TOO_LARGE_FILE;




    if ( _ini_nFileBusy[nFilePointer] != 0 )
        return INI_WRITE_ERROR;

    _ini_nFileBusy[nFilePointer] = 1;




    if
    (
            _ini_nFileSize[nFilePointer] > 0
        &&  _ini_szFileContent[nFilePointer]{ _ini_nFileSize[nFilePointer] - 1 } != INI_STRING_DELIMITER
    )
    {

        _ini_szFileContent[nFilePointer]{ _ini_nFileSize[nFilePointer] }        = '\r';
        _ini_szFileContent[nFilePointer]{ _ini_nFileSize[nFilePointer] + 1 }    = INI_STRING_DELIMITER;

        _ini_nFileSize[nFilePointer] += 2;
    }

    new curFilePos, strPos;

    for
    (
        curFilePos = _ini_nFileSize[nFilePointer], strPos = 0;
        strPos < nKeyLen;
        curFilePos++, strPos++
    )
        _ini_szFileContent[nFilePointer]{curFilePos} = szKeyName[strPos];

    _ini_szFileContent[nFilePointer]{ curFilePos++ }                = ' ';

    _ini_nDelimPos[nFilePointer][ _ini_nKeysCount[nFilePointer] ]   = curFilePos;
    _ini_nKeysCount[nFilePointer]++;

    _ini_szFileContent[nFilePointer]{ curFilePos++ }                = INI_DELIMITER;
    _ini_szFileContent[nFilePointer]{ curFilePos++ }                = ' ';


    for ( strPos = 0;  strPos < nValueLen;  curFilePos++, strPos++ )
        _ini_szFileContent[nFilePointer]{curFilePos} = szKeyValue[strPos];

    _ini_szFileContent[nFilePointer]{curFilePos}    = 0;
    _ini_nFileSize[nFilePointer]                    = curFilePos;
    _ini_nFileChanged[nFilePointer]                 = 1;
    _ini_nFileBusy[nFilePointer]                    = 0;

    return INI_OK;

}


























  

stock ini_setFloat ( nFilePointer, const szKeyName[], Float: fKeyValue )
{

    if
    (
            nFilePointer < 0
        ||  nFilePointer >= INI_MAX_OPENED_FILES
        ||  _ini_nSlotUsed[nFilePointer] != 1
    )
        return INI_WRONG_SLOT;




    new nKeyLen = strlen(szKeyName);

    if ( nKeyLen <= 0 )
        return INI_KEY_NOT_FOUND;




    for
    (
        new kPos = 0, curFilePos, found;
        kPos < _ini_nKeysCount[nFilePointer];
        kPos++
    )
    {

        found = 0;

        for
        (
            curFilePos = _ini_nDelimPos[nFilePointer][kPos] - 1;
            curFilePos >= 0;
            curFilePos--
        )
        {
            switch ( _ini_szFileContent[nFilePointer]{curFilePos} )
            {
                case INI_SPACE_CHARS :          continue;
                case INI_STRING_DELIMITER :     break;
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
                ||  _ini_szFileContent[nFilePointer]{curFilePos} != szKeyName[curKeyPos]
                ||  _ini_szFileContent[nFilePointer]{curFilePos} == INI_STRING_DELIMITER
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
                switch ( _ini_szFileContent[nFilePointer]{curFilePos} )
                {
                    case INI_KEY_STARTS : {}
                    default: continue;
                }
            }




            curFilePos = _ini_nDelimPos[nFilePointer][kPos] + 1;


            for ( ; ; curFilePos++ )
            {
                if ( curFilePos >= _ini_nFileSize[nFilePointer] ) break;

                switch ( _ini_szFileContent[nFilePointer]{curFilePos} )
                {
                    case INI_SPACE_CHARS :  continue;
                    default :               break;
                }
            }




            new szKeyValue[INI_FLOAT_SIZE];
            format( szKeyValue, INI_FLOAT_SIZE, "%f", fKeyValue );




            new nValueLen = strlen(szKeyValue);


            if ( ( curFilePos + nValueLen ) >= INI_MAX_FILE_SIZE )
                return INI_TOO_LARGE_FILE;




            new fileValueStartPos = curFilePos;


            for ( ; ; curFilePos++ )
            {
                if ( curFilePos >= _ini_nFileSize[nFilePointer] ) break;

                switch ( _ini_szFileContent[nFilePointer]{curFilePos} )
                {
                    case INI_NUMBER_ENDS :  break;
                    default :               continue;
                }
            }


            new filePosOffset = nValueLen - (                                            curFilePos - fileValueStartPos );



            if ( _ini_nFileBusy[nFilePointer] != 0 )
                return INI_WRITE_ERROR;



            _ini_nFileBusy[nFilePointer] = 1;

            if ( filePosOffset != 0 )
            {
                if ( filePosOffset < 0 )
                {
                    for
                    (
                        ;
                        curFilePos < _ini_nFileSize[nFilePointer];
                        curFilePos++
                    )
                        _ini_szFileContent[nFilePointer]{ curFilePos + filePosOffset } =
                            _ini_szFileContent[nFilePointer]{curFilePos};
                }
                else if ( filePosOffset > 0 )
                {
                    new fileValueEndPos = curFilePos;

                    for
                    (
                        curFilePos = _ini_nFileSize[nFilePointer] - 1;
                        curFilePos >= fileValueEndPos;
                        curFilePos--
                    )
                        _ini_szFileContent[nFilePointer]{ curFilePos + filePosOffset } =
                            _ini_szFileContent[nFilePointer]{curFilePos};
                }


                for ( kPos++;  kPos < _ini_nKeysCount[nFilePointer];  kPos++ )
                    _ini_nDelimPos[nFilePointer][kPos] += filePosOffset;

                _ini_nFileSize[nFilePointer] += filePosOffset;
                _ini_szFileContent[nFilePointer]{ _ini_nFileSize[nFilePointer] } = 0;
            }

            curFilePos = fileValueStartPos;
            for
            (
                new valuePos = 0;
                valuePos < nValueLen;
                curFilePos++, valuePos++
            )
                _ini_szFileContent[nFilePointer]{curFilePos} = szKeyValue[valuePos];

            _ini_nFileChanged[nFilePointer]     = 1;
            _ini_nFileBusy[nFilePointer]        = 0;

            return INI_OK;

        }
    }








    new szKeyValue[INI_FLOAT_SIZE];
    format( szKeyValue, INI_FLOAT_SIZE, "%f", fKeyValue );




    new nValueLen = strlen(szKeyValue);


    if ( ( _ini_nFileSize[nFilePointer] + 5 + nKeyLen + nValueLen ) >= INI_MAX_FILE_SIZE )
        return INI_TOO_LARGE_FILE;




    if ( _ini_nFileBusy[nFilePointer] != 0 )
        return INI_WRITE_ERROR;

    _ini_nFileBusy[nFilePointer] = 1;




    if
    (
            _ini_nFileSize[nFilePointer] > 0
        &&  _ini_szFileContent[nFilePointer]{ _ini_nFileSize[nFilePointer] - 1 } != INI_STRING_DELIMITER
    )
    {

        _ini_szFileContent[nFilePointer]{ _ini_nFileSize[nFilePointer] }        = '\r';
        _ini_szFileContent[nFilePointer]{ _ini_nFileSize[nFilePointer] + 1 }    = INI_STRING_DELIMITER;

        _ini_nFileSize[nFilePointer] += 2;
    }

    new curFilePos, strPos;

    for
    (
        curFilePos = _ini_nFileSize[nFilePointer], strPos = 0;
        strPos < nKeyLen;
        curFilePos++, strPos++
    )
        _ini_szFileContent[nFilePointer]{curFilePos} = szKeyName[strPos];

    _ini_szFileContent[nFilePointer]{ curFilePos++ }                = ' ';

    _ini_nDelimPos[nFilePointer][ _ini_nKeysCount[nFilePointer] ]   = curFilePos;
    _ini_nKeysCount[nFilePointer]++;

    _ini_szFileContent[nFilePointer]{ curFilePos++ }                = INI_DELIMITER;
    _ini_szFileContent[nFilePointer]{ curFilePos++ }                = ' ';


    for ( strPos = 0;  strPos < nValueLen;  curFilePos++, strPos++ )
        _ini_szFileContent[nFilePointer]{curFilePos} = szKeyValue[strPos];

    _ini_szFileContent[nFilePointer]{curFilePos}    = 0;
    _ini_nFileSize[nFilePointer]                    = curFilePos;
    _ini_nFileChanged[nFilePointer]                 = 1;
    _ini_nFileBusy[nFilePointer]                    = 0;

    return INI_OK;

}























  

stock ini_removeKey ( nFilePointer, const szKeyName[] )
{

    if
    (
            nFilePointer < 0
        ||  nFilePointer >= INI_MAX_OPENED_FILES
        ||  _ini_nSlotUsed[nFilePointer] != 1
    )
        return INI_WRONG_SLOT;




    new nKeyLen = strlen(szKeyName);

    if ( nKeyLen <= 0 )
        return INI_KEY_NOT_FOUND;




    for
    (
        new kPos = 0, curFilePos, found;
        kPos < _ini_nKeysCount[nFilePointer];
        kPos++
    )
    {

        found = 0;

        for
        (
            curFilePos = _ini_nDelimPos[nFilePointer][kPos] - 1;
            curFilePos >= 0;
            curFilePos--
        )
        {
            switch ( _ini_szFileContent[nFilePointer]{curFilePos} )
            {
                case INI_SPACE_CHARS :          continue;
                case INI_STRING_DELIMITER :     break;
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
                ||  _ini_szFileContent[nFilePointer]{curFilePos} != szKeyName[curKeyPos]
                ||  _ini_szFileContent[nFilePointer]{curFilePos} == INI_STRING_DELIMITER
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
                switch ( _ini_szFileContent[nFilePointer]{curFilePos} )
                {
                    case INI_KEY_STARTS : {}
                    default: continue;
                }
            }



            new keyStartPos = ( curFilePos <= 0 ) ? 0 : curFilePos + 1;




            curFilePos = _ini_nDelimPos[nFilePointer][kPos] + 1;


            for ( ; ; curFilePos++ )
            {
                if ( curFilePos >= _ini_nFileSize[nFilePointer] ) break;

                switch ( _ini_szFileContent[nFilePointer]{curFilePos} )
                {
                    case INI_SPACE_CHARS :  continue;
                    default :               break;
                }
            }





            for ( ; ; curFilePos++ )
            {
                if ( curFilePos >= _ini_nFileSize[nFilePointer] ) break;

                switch ( _ini_szFileContent[nFilePointer]{curFilePos} )
                {
                    case INI_STRING_ENDS :  break;
                    default :               continue;
                }
            }


            new filePosOffset = keyStartPos - curFilePos;



            if ( _ini_nFileBusy[nFilePointer] != 0 )
                return INI_WRITE_ERROR;



            _ini_nFileBusy[nFilePointer] = 1;


            for ( ; curFilePos <= _ini_nFileSize[nFilePointer]; curFilePos++ )
                _ini_szFileContent[nFilePointer]{ curFilePos + filePosOffset } =
                    _ini_szFileContent[nFilePointer]{curFilePos};


            for ( ;  kPos < _ini_nKeysCount[nFilePointer];  kPos++ )
                _ini_nDelimPos[nFilePointer][kPos] = _ini_nDelimPos[nFilePointer][kPos + 1] + filePosOffset;

            _ini_nKeysCount[nFilePointer]--;
            _ini_nFileSize[nFilePointer] += filePosOffset;
            _ini_szFileContent[nFilePointer]{ _ini_nFileSize[nFilePointer] } = 0;

            _ini_nFileChanged[nFilePointer]     = 1;
            _ini_nFileBusy[nFilePointer]        = 0;

            return INI_OK;

        }
    }








    return INI_KEY_NOT_FOUND;

}


































  

stock ini_getErrorInfo ( nErrorCode )
{
    new error_ms[200] = "Ошибок нет";

    if ( nErrorCode >= 0 ) return error_ms;

    switch ( nErrorCode )
    {
        case INI_FILE_NOT_FOUND :     error_ms = "INI файл, указанный в `ini_openFile`, не существует, возможно, указан неверный путь к нему";
        case INI_FILE_ALREADY_EXIST : error_ms = "INI файл, указанный в `ini_createFile`, уже существует, укажите другое имя/путь к файлу";
        case INI_TOO_LARGE_FILE :     error_ms = "Невозможно добавить новый ключ в INI файл, т.к. размер INI файла превысит допустимый лимит в " #INI_MAX_FILE_SIZE " символ(ов), или будет превышен лимит в " #INI_MAX_KEYS_IN_FILE " ключей";
        case INI_WRONG_PATH_SIZE :    error_ms = "Длина пути к INI файлу, указанного в `ini_openFile` / `ini_createFile`, превышает лимит в " #INI_MAX_FILENAME_SIZE " символ(ов)";
        case INI_READ_ERROR :         error_ms = "Ошибка при чтении INI файла с диска, возможно, файл занят другим процессом";
        case INI_WRITE_ERROR :        error_ms = "Ошибка при записи содержимого INI файла на диск, возможно, файл занят другим процессом";
        case INI_NO_FREE_SLOT :       error_ms = "Лимит в " #INI_MAX_OPENED_FILES " одновременно открытых INI файлов исчерпан, поэтому открыть/создать еще 1 файл нельзя, пока не закрыт хоть 1 из открытых файлов";
        case INI_WRONG_SLOT :         error_ms = "Указан неверный ID открытого INI файла, возможно, при открытии INI файла произошла ошибка, поэтому вместо ID файла вы получили код ошибки";
        case INI_KEY_NOT_FOUND :      error_ms = "Указанный ключ не найден в открытом INI файле";
        case INI_WRONG_RETURN_SIZE :  error_ms = "При попытке чтения строкового значения из INI файла, последний параметр `nSizeOfReturn` в `ini_getString` оказался <= 0, укажите вручную значение > 0 для него";
        default:                      error_ms = "Неизвестная ошибка";
    }

    return error_ms;
}
