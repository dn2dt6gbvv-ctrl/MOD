#if defined STRLIB_INC
	#endinput
#endif
#define STRLIB_INC

#include <a_samp>

#if !defined STRLIB_BUFFER_SIZE
	#define STRLIB_BUFFER_SIZE  2048
#endif

#if !defined STRLIB_RETURN_SIZE
	#define STRLIB_RETURN_SIZE  128
#endif

#if !defined STRLIB_USE_FORMATEX
	#if defined __fmt_funcinc
		#if !defined FormatSpecifier
			#error Please include formatex before strlib.
		#endif
	
		#define STRLIB_USE_FORMATEX  true
	#else
		#define STRLIB_USE_FORMATEX  false
	#endif
#endif

                               
enum trim_edges {
	trim_left  = 1,
	trim_right = 2,
	trim_both = trim_left | trim_right
};

                             
enum string_edges {
	edge_left  = 1,
	edge_right = 2,
	edge_both = edge_left | edge_right
};

  
                              
  
              
                                
                                
  
           
                          
   
forward sprintf(const fmat[], {Float, _}:...);

  
                                      
  
              
                           
  
           
                                       
   
forward strgetfirstc(const string[]);

  
                                                     
  
              
                           
                                        
  
           
                                                          
   
forward strgetc(const string[], index);

  
                            
  
              
                           
  
           
                                      
   
forward strsize(const string[]);

  
                                 
  
              
                           
  
           
                                    
   
forward bool:isempty(const string[]);

  
                       
  
              
                               
                                
                                                                       
  
           
                                    
   
forward bool:isequal(const str1[], const str2[], bool:ignorecase = false);

  
                                                                   
  
              
                               
                                
                                                                       
  
           
                                               
                                                                                        
   
forward strdistance(const str1[], const str2[], bool:ignorecase = false);

  
                                       
   
              
                                                                                
                                         
                                                              
                                     
                                                                             
                                                                                
                                                                                                 
                                                                                                   
  
           
                                                              
   
forward strexplode(output[][], const input[], const delimiter[] = !",", limit = cellmax, bool:trim = true, bool:ignorecase = false, size1 = sizeof(output), size2 = sizeof(output[]));

  
                                  
  
              
                                                                
                                  
                                                                  
                                      
  
           
            
   
forward strimplode(const glue[], output[], maxlength = sizeof(output), ...);

  
                                                                        
  
              
                                                       
                                       
                                                           
                                                                                                
                                                                   
                                                                         
                                                                  
  
           
                                               
   
forward strreplace(string[], const search[], const replacement[], bool:ignorecase = false, pos = 0, limit = -1, maxlength = sizeof(string));

  
                                                                   
  
              
                                   
                                                                                                       
                                                                                       
  
           
            
   
forward strtrim(string[], const chars[] = !"", string_edges:edge = edge_both);

  
                                       
  
              
                                  
                                           
                                                                     
                                                                                      
                                                            
                                                                  
                                                                  
                             
   
forward strpad(string[], length, const substr[] = !" ", string_edges:edge = edge_both, bool:trim_first = true, const trim_chars[] = !"", maxlength = sizeof(string), const input[] = !"");

  
                                          
  
              
                                          
                                                        
                                            
                                                                  
   
forward strwrap(const left[], string[], const right[], maxlength = sizeof(string));

  
                    
  
              
                                            
                                      
                                                                
                                                                                                                 
  
           
                                                    
   
forward strcount(const string[], const sub[], bool:ignorecase = false, bool:count_overlapped = false);

  
                                            
  
              
                                          
                                  
                                                                                                     
                                                                  
  
           
                                     
   
forward bool:strfromliteral(output[], const input[], &pos = 0, maxlength = sizeof(output));

  
                                                   
  
              
                                          
                                             
                                                                  
  
           
            
   
forward strtoliteral(output[], const input[], maxlength = sizeof(output), bool:paranoid = true);

  
                                
  
                                                        
  
              
                                          
                                       
                                                                  
                                                                  
  
           
            
   
forward strfrombin(output[], const input[], inputlength = sizeof(input), maxlength = sizeof(output));

  
                                
  
                                                        
  
              
                                          
                                       
                                                                  
  
           
                                        
   
forward strtobin(output[], const input[], maxlength = sizeof(output));

  
                                                 
  
              
                                                              
                                           
                                             
                                                       
                                                              
   
forward strcatmid(dest[], const source[], start = 0, end = -1, maxlength = sizeof(dest));

  
                                                                   
                          
  
              
                                  
                                     
                                                              
   
forward utf8encode(dest[], const source[], maxlength = sizeof(dest));

  
                                                                        
                           
  
              
                                  
                                     
                                                              
   
forward utf8decode(dest[], const source[], maxlength = sizeof(dest));

  
                         
  
              
                                    
                                    
                                                                   
   
forward strurldecode(output[], const input[], maxlength = sizeof(output));

  
                       
  
              
                                    
                                    
                                                                   
                                                          
   
forward strurlencode(output[], const input[], maxlength = sizeof(output), bool:pack = false);

                                        
forward ret_strcatmid(const string[], const source[], start = 0, end = -1);
forward ret_strfrombin(const input[], inputlength = sizeof(input));
forward ret_strimplode(const glue[], ...);
forward ret_strreplace(const string[], const search[], const replacement[], bool:ignorecase = false, pos = 0, limit = -1);
forward ret_strfromliteral(const input[], &pos = 0);
forward ret_strtoliteral(const input[], bool:paranoid = true);
forward ret_strtrim(const string[], const chars[] = !"", string_edges:edge = edge_both);
forward ret_strpad(const string[], length, const substr[] = !" ", string_edges:edge = edge_both, bool:trim_first = true, const trim_chars[] = !"");
forward ret_strwrap(const left[], const string[], const right[]);
forward ret_strurldecode(const input[]);
forward ret_strurlencode(const input[], bool:pack = false);
forward ret_utf8encode(const input[]);
forward ret_utf8decode(const input[]);

                               
forward ret_strpack(const source[]);
forward ret_strunpack(const source[]);
forward ret_strcat(const string1[], const string2[]);
forward ret_strmid(const source[], start, end);
forward ret_strins(const string[], const substr[], pos, maxlength = sizeof(string));
forward ret_strdel(const string[], start, end);
forward ret_valstr(value, bool:pack = false);

forward ret_GetPlayerName(playerid, bool:pack = false);


stock
	                              
	g_StrlibBuffer[2048]
;

                              
forward _strlib_funcinc();
public _strlib_funcinc() {
	new temp[1];
	
	format(!temp, 0, !temp);
	strcat(temp, temp);
	strpack(temp, temp);
	strunpack(temp, temp);
}

                     
static stock RedirectArgument(arg, ...) {
	#emit LOAD.S.pri  0
	#emit ADD.C       12
	#emit LOAD.S.alt  arg
	#emit SHL.C.alt   2
	#emit ADD
	#emit MOVE.alt
	#emit LOAD.S.pri  16
	#emit STOR.I
}

static stock CopyArgumentToHeap(arg, bool:pack = false, const argptr[] = "") {
	new arg_address, address;
	
	#emit LOAD.S.pri  0
	#emit ADD.C       12
	#emit LOAD.S.alt  arg
	#emit SHL.C.alt   2
	#emit ADD
	#emit LOAD.I
	#emit STOR.S.pri  arg_address
	#emit STOR.S.pri  argptr
	
	if (pack) {
		new bytes = ((strlen(argptr) + 1 + 3) / 4) * 4;
		
		#emit LCTRL       2
		#emit STOR.S.pri  address
		#emit LOAD.S.alt  bytes
		#emit ADD
		#emit SCTRL       2
		
		                                                          
		#emit LOAD.S.pri  bytes
		#emit SHR.C.pri   2
		#emit PUSH.pri
		
		#emit PUSH.S      arg_address
		#emit PUSH.S      address
		
		#emit PUSH.C      12
		
		#emit SYSREQ.C    strpack
		#emit STACK       16
	} else {
		new bytes = (strlen(argptr) + 1) * 4;
		
		#emit LCTRL       2
		#emit STOR.S.pri  address
		#emit LOAD.S.alt  bytes
		#emit ADD
		#emit SCTRL       2
		
		                                                            
		#emit LOAD.S.pri  bytes
		#emit SHR.C.pri   2
		#emit PUSH.pri
		
		#emit PUSH.S      arg_address
		#emit PUSH.S      address
		
		#emit PUSH.C      12
		
		#emit SYSREQ.C    strunpack
		#emit STACK       16
	}
	
	#emit LOAD.S.pri  0
	#emit ADD.C       12
	#emit LOAD.S.alt  arg
	#emit SHL.C.alt   2
	#emit ADD
	#emit MOVE.alt
	#emit LOAD.S.pri  address
	#emit STOR.I
	
	return address;
}

static stock RestoreHeapToAddress(address) {
	#emit LOAD.S.pri  address
	#emit SCTRL       2
}

static stock IsOverlapping(const str1[], size1 = sizeof(str1), const str2[], size2 = sizeof(str2)) {
	new addr1, addr2;
	
	if (size1 == -1) {
		size1 = strsize(str1);
	} else {
		size1 *= 4;
	}
	
	if (size2 == -1) {
		size2 = strsize(str2);
	} else {
		size2 *= 4;
	}
	
	#emit LOAD.S.pri  str1
	#emit STOR.S.pri  addr1
	#emit LOAD.S.pri  str2
	#emit STOR.S.pri  addr2

	return (addr1 < addr2 + size2) && (addr2 < addr1 + size1);
}

                   
#if !defined ispacked
    #define ispacked(%1) \
        ((%1)[0] > 255)
#endif

stock strgetfirstc(const string[]) {
	return ispacked(string) ? string{0} : string[0];
}

stock strgetc(const string[], index) {
	if (index < 0)
		return '\0';
	
	new len = strlen(string);
	
	if (index >= len)
		return '\0';
	
	return ispacked(string) ? string{index} : string[index];
}

stock strsize(const string[]) {
	new len = strlen(string);
	
	if (ispacked(string))
		return len + 1;
	
	return (len + 1) * 4;
}

stock bool:isempty(const string[]) {
	if (ispacked(string))
		return string{0} == '\0';
	else
		return string[0] == '\0';
}

stock bool:isequal(const str1[], const str2[], bool:ignorecase = false) {
    new
        c1 = (str1[0] > 255) ? str1{0} : str1[0],
        c2 = (str2[0] > 255) ? str2{0} : str2[0]
    ;

    if (!c1 != !c2)
        return false;

    return !strcmp(str1, str2, ignorecase);
}

stock strdistance(const str1[], const str2[], bool:ignorecase = false) {
	                                                
	if(isequal(str1, str2, ignorecase))
		return 0;

	static data[128][128];

	new bool:pack1 = ispacked(str1),
		bool:pack2 = ispacked(str2);

	new size1 = strlen(str1),
		size2 = strlen(str2);

	                                                                                                   
	if (size1 == 0)
		return size2;

	if (size2 == 0)
		return size1;

	                        
	for (new i; i <= size1; i++)
		data[i][0] = i;

	for (new j; j <= size2; j++)
		data[0][j] = j;

	                                                                                                           
	for (new j = 1; j <= size2; j++) {
		for (new i = 1; i <= size1; i++) {
			new char1 = pack1 ? str1{i - 1} : str1[i - 1],
				char2 = pack2 ? str2{j - 1} : str2[j - 1];

			                                        
			if(ignorecase) {
				if (65 <= char1 <= 90)
					char1 += 32;

				if (65 <= char2 <= 90)
					char2 += 32;
			}

			if (char1 == char2)
				data[i][j] = data[i - 1][j - 1];
			else {
				new l1 = data[i - 1][j] + 1,
				l2 = data[i][j - 1] + 1,
				l3 = data[i - 1][j - 1] + 1;

				l2 = (l1 > l2 ? l2 : l1);
				data[i][j] = (l3 > l2 ? l2 : l3);
			}
		}
	}

	return data[size1][size2];
}

stock strimplode(const glue[], output[], maxlength = sizeof(output), ...) {
	new args = numargs();
	
	                    
	output[0] = '\0';
	
	                                                            
	for (new arg = 3; arg < args; arg++) {
		                                                   
		if (arg != 3)
			strcat(output, glue, maxlength);
		
		                                                                                       
		{
			                                        
			#emit LCTRL       5
			#emit ADD.C       12
			#emit LOAD.S.alt  arg
			#emit SHL.C.alt   2
			#emit ADD
			#emit LOAD.I
			
			                                                      
			#emit PUSH.S      maxlength
			#emit PUSH.pri
			#emit PUSH.S      output
			
			                          
			#emit PUSH.C      12
			
			              
			#emit SYSREQ.C    strcat
			
			                    
			#emit STACK       16
		}
	}
}

stock strexplode(output[][], const input[], const delimiter[] = !",", limit = cellmax, bool:trim = true, bool:ignorecase = false, size1 = sizeof(output), size2 = sizeof(output[])) {
	if (!size1 || !size2) {
		printf("(strexplode) ERROR: size1 = %d, size2 = %d. Can't be 0.", size1, size2);
		
		return 0;
	}
	
	if (isempty(delimiter)) {
		print(!"(strexplode) ERROR: delimiter is empty.");
		
		return 0;
	}
	
	if (trim) {
		new i = -1;
		
		if (ispacked(input)) {
			while (input{++i}) {
				if (input{i} > ' ') {
					i = -1;
					
					break;
				}
			}
		} else {
			while (input[++i]) {
				if (input[i] > ' ') {
					i = -1;
					
					break;
				}
			}
		}
		
		if (i != -1)
			return 0;
	} else if (isempty(input)) {
		return 0;
	}
	
	if (limit == 0) {
		return 0;
	} else if (limit == cellmax) {
		limit = 0;
	}
	
	new
		     pos = 0,
		     next,
		bool:packed = ispacked(input),
		     dlen = strlen(delimiter),
		     count = 0,
		     end
	;
	
	while (pos != -1) {
		++count;
		
		if (limit > 0 && count >= limit) {
			next = -1;
		} else {
			next = strfind(input, delimiter, ignorecase, pos);
		}
		
		end = (next == -1) ? cellmax : next;
		
		if (trim) {
			if (end == cellmax)
				end = strlen(input);
			
			if (packed) {
				while (0 < input{pos} <= ' ') pos++;
				while (end > 0 && input{end - 1} <= ' ') end--;
			} else {
				while (0 < input[pos] <= ' ') pos++;
				while (end > 0 && input[end - 1] <= ' ') end--;
			}
		}
		
		strmid(output[count - 1], input, pos, end, size2);
		
		if (count >= size1 || next == -1 || (limit < 0 && count >= -limit))
			break;
		
		pos = next + dlen;
	}
	
	return count;
}

stock strreplace(string[], const search[], const replacement[], bool:ignorecase = false, pos = 0, limit = -1, maxlength = sizeof(string)) {
                                                
    if (limit == 0)
        return 0;
    
    new
             sublen = strlen(search),
             replen = strlen(replacement),
        bool:packed = ispacked(string),
             maxlen = maxlength,
             len = strlen(string),
             count = 0
    ;
    
    
                                                                                                                   
                                                                                        
    if (packed)
        maxlen *= 4;
    
                                                                         
    if (!sublen)
        return 0;
    
                                                                                                  
    while (-1 != (pos = strfind(string, search, ignorecase, pos))) {
                                     
        strdel(string, pos, pos + sublen);
        
        len -= sublen;
        
                                                                                                     
        if (replen && len + replen < maxlen) {
            strins(string, replacement, pos, maxlength);
            
            pos += replen;
            len += replen;
        }
        
                                                                              
        if (limit != -1 && ++count >= limit)
            break;
    }
    
    return count;
}

stock strtrim(string[], const chars[] = !"", string_edges:edge = edge_both) {
	new bool:packed = ispacked(string);
	
	                                       
	if (!strgetfirstc(chars)) {
		                                   
		if (edge & edge_left) {
			new i = 0;
			
			if (packed)
				while (0 < string{i} <= ' ') i++;
			else
				while (0 < string[i] <= ' ') i++;
			
			if (i) {
				strdel(string, 0, i);
			}
		}
		
		                                    
		if (edge & edge_right) {
			new i = strlen(string);
			
			if (i) {
				if (packed) {
					while (--i && 0 < string{i} <= ' ') {}
					
					string{i + 1} = '\0';
				} else {
					while (--i && 0 < string[i] <= ' ') {}
					
					string[i + 1] = '\0';
				}
			}
		}
	} else {
		                                   
		if (edge & edge_left) {
			new i = 0, sub[2];
			
			if (packed) {
				while ((sub[0] = string{i})) {
					if (strfind(chars, sub) == -1)
						break;
					
					i++;
				}
				
				if (i) {
					strdel(string, 0, i);
				}
			} else {
				while ((sub[0] = string[i])) {
					if (strfind(chars, sub) == -1)
						break;
					
					i++;
				}
				
				if (i) strdel(string, 0, i);
			}
		}
		
		                                    
		if (edge & edge_right) {
			new i = strlen(string), sub[2];
			
			if (i >= 0) {
				if (packed) {
					while (i--) {
						sub[0] = string{i};
						
						if (strfind(chars, sub) == -1)
							break;
					}
					
					string{i + 1} = '\0';
				} else {
					while (i--) {
						sub[0] = string[i];
						
						if (strfind(chars, sub) == -1)
							break;
					}
					
					string[i + 1] = '\0';
				}
			}
		}
	}
}

stock strpad(string[], length, const substr[] = !" ", string_edges:edge = edge_both, bool:trim_first = true, const trim_chars[] = !"", maxlength = sizeof(string), const input[] = !"") {
	if (trim_first) {
		strtrim(string, trim_chars, edge);
	}
	
	new
		     heap,
		     length_left = 0,
		     length_right = 0,
		     len = strlen(string),
		     sublen = strlen(substr),
		bool:packed,
		bool:subpacked = ispacked(substr)
	;
	
	if (len > length)
		return;
	else
		length -= len;
	
	                                     
	#emit LOAD.S.pri  string
	#emit STOR.S.pri  input
	
	                                                                      
	heap = CopyArgumentToHeap(7);
	
	string[0] = '\0';
	len = 0;
	
	switch (edge) {
		case edge_left:
			length_left = length;
		case edge_right:
			length_right = length;
		default:
			length_left = length / 2, length_right = length - length_left;
	}
	
	if (length_left) {
		while (len < length_left) {
			if (subpacked)
				strcat(string, substr, length_left * 4);
			else
				strcat(string, substr, length_left + 1);
		
			len += sublen;
		}
	
		if (subpacked)
			string{length_left} = 0;
	}
	
	strcat(string, input, maxlength);
	
	if (length_right) {
		len = strlen(string);
		length_right += len;
		packed = ispacked(string);
		
		while (len < length_right) {
			if (packed)
				strcat(string, substr, length_right / 4 + 1);
			else
				strcat(string, substr, length_right + 1);
		
			len += sublen;
		}
		
		if (packed)
			string{length_right + 1} = 0;
	}
	
	RestoreHeapToAddress(heap);
}

stock strwrap(const left[], string[], const right[], maxlength = sizeof(string)) {
	strins(string, left, 0, maxlength);
	strcat(string, right, maxlength);
}

stock strcount(const string[], const sub[], bool:ignorecase = false, bool:count_overlapped = false) {
	new
		increment = count_overlapped ? 1 : strlen(sub),
		pos = -increment,
		count = 0
	;
	
	
	while (-1 != (pos = strfind(string, sub, ignorecase, pos + increment)))
		count++;
	
	return count;
}

stock bool:strfromliteral(output[], const input[], &pos = 0, maxlength = sizeof(output)) {
	new
		     length = strlen(input),
			 c,
			 outlen = 0,
		     heap = 0
	;

	                               
	if (!length)
		return true;
	
	if (IsOverlapping(output, maxlength, input, -1))
		heap = CopyArgumentToHeap(1);
	
	output[0] = '\0';
	
	if (input[0] == '"')
		pos++;

	for (;; pos++) {
		if (outlen >= maxlength - 1 || pos >= length)
			break;
		
		c = input[pos];
		
		switch (c) {
			               
			case '"': break;
			case '\\': {}
			default: {
				output[outlen++] = c;

				continue;
			}
		}

		                                          
		if (pos == length - 1)
			goto return_false;

		                                                       
		c = input[++pos];

		switch (c) {
			case '"',
			    '\'',
			    '\\',
			     '%': output[outlen++] = c;
			case 'a': output[outlen++] = '\a';
			case 'b': output[outlen++] = '\b';
			case 'e': output[outlen++] = '\e';
			case 'f': output[outlen++] = '\f';
			case 'r': output[outlen++] = '\r';
			case 'n': output[outlen++] = '\n';
			case 't': output[outlen++] = '\t';
			case 'v': output[outlen++] = '\v';
			
			case 'x': {
				new val = 0;

				                                   
				if (c == length - 1)
					goto return_false;

				while ((c = input[pos + 1])) {
					if ('a' <= c <= 'f' || 'A' <= c <= 'F') {
						val = (val << 4) + (tolower(c) - 'a' + 10);
					} else if ('0' <= c <= '9') {
						val = (val << 4) + (c - '0');
					} else {
						break;
					}

					pos++;
				}

				if (c == ';')
					pos++;

				output[outlen++] = val;
			}
			
			case '0' .. '9': {
				new val = 0;

				while ((c = input[pos])) {
					if ('0' <= c <= '9') {
						val = val * 10 + (c - '0');
					} else {
						break;
					}

					pos++;
				}

				if (c != ';') pos--;

				output[outlen++] = val;
			}
			
			default: {
				goto return_false;
			}
		}
	}

	output[outlen] = '\0';
	
	pos++;
	
	new bool:ret = true;
	#pragma unused ret

	goto return_true;
return_false:
	ret = false;
return_true:

	if (heap)
		RestoreHeapToAddress(heap);

	return ret;
}

stock strtoliteral(output[], const input[], maxlength = sizeof(output), bool:paranoid = true) {
	new i, c, outlen, heap = 0;
	
	if (IsOverlapping(output, maxlength, input, -1))
		heap = CopyArgumentToHeap(1);
	
	output[outlen++] = '"';

	for (i = 0; (c = input[i]); i++) {
		if (maxlength - outlen <= 3) {
			outlen = min(outlen, maxlength - 2);
			
			break;
		}
		
		switch (c) {
			case ' ', '!', '#' .. '[', ']', '^' .. '~':
				output[outlen++] = c;

			case  '"': strunpack(output[outlen], !"\\\"", 3), outlen += 2;
			case '\a': strunpack(output[outlen], !"\\a" , 3), outlen += 2;
			case '\b': strunpack(output[outlen], !"\\b" , 3), outlen += 2;
			case '\e': strunpack(output[outlen], !"\\e" , 3), outlen += 2;
			case '\f': strunpack(output[outlen], !"\\f" , 3), outlen += 2;
			case '\r': strunpack(output[outlen], !"\\r" , 3), outlen += 2;
			case '\n': strunpack(output[outlen], !"\\n" , 3), outlen += 2;
			case '\t': strunpack(output[outlen], !"\\t" , 3), outlen += 2;
			case '\v': strunpack(output[outlen], !"\\v" , 3), outlen += 2;
			case '\\': strunpack(output[outlen], !"\\\\" , 3), outlen += 2;
			
			default: {
				if (!paranoid && 0x80 <= c <= 0xFF) {
					output[outlen++] = c;
					continue;
				}
				
				if (maxlength - outlen <= 8)
					break;
				
				format(output[outlen], 7, "\\x%03x;", c);

				outlen += 6;
			}
		}
	}

	output[outlen++] = '"';
	output[outlen] = '\0';
	
	if (heap)
		RestoreHeapToAddress(heap);
}

stock strfrombin(output[], const input[], inputlength = sizeof(input), maxlength = sizeof(output)) {
	static const hex_chars[] = "0123456789ABCDEF";
	new outlen = 0, heap = 0;
	
	if (IsOverlapping(output, maxlength, input, -1))
		heap = CopyArgumentToHeap(1);
	
	for (new i = 0; i < inputlength; i++) {
		if (maxlength - outlen <= 7) {
			outlen = min(outlen, maxlength - 1);
			
			break;
		}
		
		new input_cell = input[i];
		
		output[outlen++] = hex_chars[(input_cell             ) >>> 28];
		output[outlen++] = hex_chars[(input_cell & 0x0F000000) >>> 24];
		output[outlen++] = hex_chars[(input_cell & 0x00F00000) >>> 20];
		output[outlen++] = hex_chars[(input_cell & 0x000F0000) >>> 16];
		output[outlen++] = hex_chars[(input_cell & 0x0000F000) >>> 12];
		output[outlen++] = hex_chars[(input_cell & 0x00000F00) >>>  8];
		output[outlen++] = hex_chars[(input_cell & 0x000000F0) >>>  4];
		output[outlen++] = hex_chars[(input_cell & 0x0000000F)       ];
	}
	
	output[outlen] = '\0';
	
	if (heap)
		RestoreHeapToAddress(heap);
}

stock strtobin(output[], const input[], maxlength = sizeof(output)) {
	new len = strlen(input), outlen = 0, heap = 0;
	
	if (IsOverlapping(output, maxlength, input, -1))
		heap = CopyArgumentToHeap(1);
	
	for (new i = 0; i < len;) {
		if (outlen >= maxlength || i > len - 8) {
			break;
		}
		
		new c, out = 0;
		
		#define ADD_OUT(%1) \
			c = input[i++]; out |= (('a' <= c <= 'f' || 'A' <= c <= 'F') ? (tolower(c) - 'a' + 10) : (c - '0')) << %1
		
		ADD_OUT(28);
		ADD_OUT(24);
		ADD_OUT(20);
		ADD_OUT(16);
		ADD_OUT(12);
		ADD_OUT(8);
		ADD_OUT(4);
		ADD_OUT(0);
		
		#undef ADD_OUT
		
		output[outlen++] = out;
	}
	
	if (heap)
		RestoreHeapToAddress(heap);
	
	return outlen;
}

stock strurlencode(output[], const input[], maxlength = sizeof(output), bool:pack = false) {
	static const hex_chars[] = "0123456789ABCDEF";
	
	new
		     len = strlen(input),
		bool:packed = ispacked(input),
		     outlen = 0,
		     heap = 0
	;
	
	if (IsOverlapping(output, maxlength, input, -1))
		heap = CopyArgumentToHeap(1, packed);
	
	if (pack)
		maxlength *= 4;
	
	for (new i = 0; i < len; i++) {	
		if (maxlength - outlen <= 1)
			break;
		
		new c = packed ? input{i} : input[i];
		
		switch (c) {
			case 'a' .. 'z', 'A' .. 'Z', '0' .. '9', '_': {
				if (pack)
					output{outlen++} = c;
				else
					output[outlen++] = c;
			}
			
			case ' ': {
				if (pack)
					output{outlen++} = '+';
				else
					output[outlen++] = '+';
			}
			
			default: {
				if (maxlength - outlen <= 3)
					break;
				
				if (pack) {
					output{outlen++} = '%';
					output{outlen++} = hex_chars[(c & 0xF0) >>> 4];
					output{outlen++} = hex_chars[c & 0x0F];
				} else {
					output[outlen++] = '%';
					output[outlen++] = hex_chars[(c & 0xF0) >>> 4];
					output[outlen++] = hex_chars[c & 0x0F];
				}
			}
		}
	}
	
	if (pack)
		output{outlen} = '\0';
	else
		output[outlen] = '\0';
	
	if (heap)
		RestoreHeapToAddress(heap);
}

stock strurldecode(output[], const input[], maxlength = sizeof(output)) {
	new prev_pos = 0, pos = 0, inputlen = strlen(input), len, heap = 0;
	
	if (IsOverlapping(output, maxlength, input, -1))
		heap = CopyArgumentToHeap(1);
	
	output[0] = '\0';
	
	while (-1 != (pos = strfind(input, "%", _, pos))) {
		static str[2];
		new c;
		
		if (prev_pos != pos) {
			len = strlen(output);
			
			strcatmid(output, input, prev_pos, pos, maxlength);
			strreplace(output, "+", " ", _, len, _, maxlength);
		}
		
		if (inputlen < pos + 3)
			goto func_end;
		
		str[0] = 0;
		
		c = input[pos + 1]; str[0] |= (('a' <= c <= 'f' || 'A' <= c <= 'F') ? (tolower(c) - 'a' + 10) : (c - '0')) << 4;
		c = input[pos + 2]; str[0] |= (('a' <= c <= 'f' || 'A' <= c <= 'F') ? (tolower(c) - 'a' + 10) : (c - '0'));
		
		strcat(output, str, maxlength);
		
		prev_pos = (pos += 3);
	}
	
	len = strlen(output);
	
	strcatmid(output, input, prev_pos, _, maxlength);
	strreplace(output, "+", " ", _, len, _, maxlength);

func_end:
	if (heap)
		RestoreHeapToAddress(heap);
}

stock strcatmid(dest[], const source[], start = 0, end = -1, maxlength = sizeof(dest)) {
	new heap = 0;
	
	if (IsOverlapping(dest, maxlength, source, -1))
		heap = CopyArgumentToHeap(1);
	
	if (start == 0 && end == -1) {
		strcat(dest, source, maxlength);
	} else {
		if (end == -1)
			end = strlen(source);
		
		if (ispacked(dest)) {
			new len = strlen(dest);
			
			if (ispacked(source)) {
				strunpack(g_StrlibBuffer, source);
			
				strcat(dest, g_StrlibBuffer[start], min(maxlength, (len + end - start) / 4 + 1));
			} else {	
				strcat(dest, source[start], min(maxlength, (len + end - start) / 4 + 1));
			}
			
			dest{len + end - start} = '\0';
		} else {
			if (ispacked(source)) {
				strunpack(g_StrlibBuffer, source);
			
				strcat(dest, g_StrlibBuffer[start], min(maxlength, strlen(dest) + end - start + 1));
			} else {	
				strcat(dest, source[start], min(maxlength, strlen(dest) + end - start + 1));
			}
		}
	}
	
	if (heap)
		RestoreHeapToAddress(heap);
}

stock utf8encode(dest[], const source[], maxlength = sizeof(dest)) {
	new heap = 0;
	
	if (IsOverlapping(dest, maxlength, source, -1)) {
		heap = CopyArgumentToHeap(1);
	}
	
	new len = strlen(source);
	new packed = ispacked(source);
	
	dest[0] = '\0';
	
	new idx = 0;
	
	for (new i = 0; i < len; i++) {
		new c = packed ? source{i} : source[i];
		
		if (c >= 0x80) {
			if (c > 0x4000000) {
				         
				dest[idx++] = 0b11111100 | ((c >>> 30) & 0b00000001);
				dest[idx++] = 0b10000000 | ((c >>> 24) & 0b00111111);
				dest[idx++] = 0b10000000 | ((c >>> 18) & 0b00111111);
				dest[idx++] = 0b10000000 | ((c >>> 12) & 0b00111111);
				dest[idx++] = 0b10000000 | ((c >>> 6) & 0b00111111);
				dest[idx++] = 0b10000000 | (c & 0b00111111);
			} else if (c > 0x200000) {
				         
				dest[idx++] = 0b11111000 | ((c >>> 24) & 0b00000011);
				dest[idx++] = 0b10000000 | ((c >>> 18) & 0b00111111);
				dest[idx++] = 0b10000000 | ((c >>> 12) & 0b00111111);
				dest[idx++] = 0b10000000 | ((c >>> 6) & 0b00111111);
				dest[idx++] = 0b10000000 | (c & 0b00111111);
			} else if (c > 0x10000) {
				         
				dest[idx++] = 0b11110000 | ((c >>> 18) & 0b00000111);
				dest[idx++] = 0b10000000 | ((c >>> 12) & 0b00111111);
				dest[idx++] = 0b10000000 | ((c >>> 6) & 0b00111111);
				dest[idx++] = 0b10000000 | (c & 0b00111111);
			} else if (c > 0x800) {
				         
				dest[idx++] = 0b11100000 | ((c >>> 12) & 0b00001111);
				dest[idx++] = 0b10000000 | ((c >>> 6) & 0b00111111);
				dest[idx++] = 0b10000000 | (c & 0b00111111);
			} else {
				         
				dest[idx++] = 0b11000000 | ((c >>> 6) & 0b00011111);
				dest[idx++] = 0b10000000 | (c & 0b00111111);
				
			}
		} else if (c > 0) {
			dest[idx++] = c;
		}
	}
	
	dest[idx] = '\0';
	
	if (heap) {
		RestoreHeapToAddress(heap);
	}
}

stock utf8decode(dest[], const source[], maxlength = sizeof(dest)) {
	new heap = 0;
	
	if (IsOverlapping(dest, maxlength, source, -1)) {
		heap = CopyArgumentToHeap(1);
	}
	
	new len = strlen(source);
	
	dest[0] = '\0';
	
	new idx = 0;
	
	for (new i = 0; i < len; i++) {
		new c = source[i];
		
		if (c & 0b10000000) {
			if (c & 0b11100000 == 0b11000000) {
				         
				if (i + 1 >= len) continue;
				
				dest[idx++] = (c & 0b00011111) << 6 | (source[++i] & 0b00111111);
			} else if (c & 0b11110000 == 0b11100000) {
				         
				if (i + 2 >= len) continue;
				
				dest[idx++] = (c & 0b00001111) << 12 |
				              (source[++i] & 0b00111111) << 6 |
				              (source[++i] & 0b00111111);
			} else if (c & 0b11111000 == 0b11110000) {
				         
				if (i + 3 >= len) continue;
				
				dest[idx++] = (c & 0b00000111) << 18 |
				              (source[++i] & 0b00111111) << 12 |
				              (source[++i] & 0b00111111) << 6 |
				              (source[++i] & 0b00111111);
			} else if (c & 0b11111100 == 0b11111000) {
				         
				if (i + 4 >= len) continue;
				
				dest[idx++] = (c & 0b00000011) << 24 |
				              (source[++i] & 0b00111111) << 18 |
				              (source[++i] & 0b00111111) << 12 |
				              (source[++i] & 0b00111111) << 6 |
				              (source[++i] & 0b00111111);
			} else if (c & 0b11111110 == 0b11111100) {
				         
				if (i + 5 >= len) continue;
				
				dest[idx++] = (c & 0b00000001) << 30 |
				              (source[++i] & 0b00111111) << 24 |
				              (source[++i] & 0b00111111) << 18 |
				              (source[++i] & 0b00111111) << 12 |
				              (source[++i] & 0b00111111) << 6 |
				              (source[++i] & 0b00111111);
			}
		} else {
			dest[idx++] = c;
		}
	}
	
	dest[idx] = 0;
	
	if (heap) {
		RestoreHeapToAddress(heap);
	}
}


stock ret_strcatmid(const string[], const source[], start = 0, end = -1) {
	new output[STRLIB_RETURN_SIZE];
	
	strcat(output, string);
	
	strcatmid(output, source, start, end);
	
	return output;
}

stock ret_strfrombin(const input[], inputlength = sizeof(input)) {
	new output[STRLIB_RETURN_SIZE];
	
	strfrombin(output, input, inputlength);
	
	return output;
}

stock ret_strimplode(const glue[], ...) {
	new output[STRLIB_RETURN_SIZE];
	const maxlength = sizeof(output);
	new args = numargs();
	
	                                                            
	for (new arg = 1; arg < args; arg++) {
		                                                   
		if (arg != 1)
			strcat(output, glue, maxlength);
		
		                                                                                       
		{
			                                        
			#emit LCTRL       5
			#emit ADD.C       12
			#emit LOAD.S.alt  arg
			#emit SHL.C.alt   2
			#emit ADD
			#emit LOAD.I
			
			                                                      
			#emit PUSH.C      maxlength
			#emit PUSH.pri
			#emit PUSH.ADR    output
			
			                          
			#emit PUSH.C      12
			
			              
			#emit SYSREQ.C    strcat
			
			                    
			#emit STACK       16
		}
	}
	
	                                                             
	#emit LOAD.S.pri  8
	#emit ADD.C       12
	#emit MOVE.alt
	#emit LCTRL       5
	#emit ADD
	#emit LOAD.I
	#emit STOR.S.pri  20
	
	return output;
}

stock ret_strreplace(const string[], const search[], const replacement[], bool:ignorecase = false, pos = 0, limit = -1) {
	new output[STRLIB_RETURN_SIZE];
	
	strcat(output, string);
	
	strreplace(output, search, replacement, ignorecase, pos, limit);
	
	return output;
}

stock ret_strfromliteral(const input[], &pos = 0) {
	new output[STRLIB_RETURN_SIZE];
	
	strcat(output, input);
	
	strfromliteral(output, input, pos);
	
	return output;
}

stock ret_strtoliteral(const input[], bool:paranoid = true) {
	new output[STRLIB_RETURN_SIZE];
	
	strcat(output, input);
	
	strtoliteral(output, input, paranoid);
	
	return output;
}

stock ret_strtrim(const string[], const chars[] = !"", string_edges:edge = edge_both) {
	new output[STRLIB_RETURN_SIZE];
	
	strcat(output, string);
	
	strtrim(output, chars, edge);
	
	return output;
}

stock ret_strpad(const string[], length, const substr[] = !" ", string_edges:edge = edge_both, bool:trim_first = true, const trim_chars[] = !"") {
	new output[STRLIB_RETURN_SIZE];
	
	strcat(output, string);
	
	strpad(output, length, substr, edge, trim_first, trim_chars);
	
	return output;
}

stock ret_strwrap(const left[], const string[], const right[]) {
	new output[STRLIB_RETURN_SIZE];
	
	strcat(output, left);
	strcat(output, string);
	strcat(output, right);
	
	return output;
}

stock ret_strurldecode(const input[]) {
	new output[STRLIB_RETURN_SIZE];
	
	strcat(output, input);
	
	strurldecode(output, input);
	
	return output;
}

stock ret_strurlencode(const input[], bool:pack = false) {
	new output[STRLIB_RETURN_SIZE];
	
	strcat(output, input);
	
	strurlencode(output, input, _, pack);
	
	return output;
}

stock ret_utf8encode(const input[]) {
	new output[STRLIB_RETURN_SIZE];
	
	utf8encode(output, input);
	
	return output;
}

stock ret_utf8decode(const input[]) {
	new output[STRLIB_RETURN_SIZE];
	
	utf8decode(output, input);
	
	return output;
}

stock ret_strpack(const source[]) {
	new output[STRLIB_RETURN_SIZE];
	
	strpack(output, source);
	
	return output;
}

stock ret_strunpack(const source[]) {
	new output[STRLIB_RETURN_SIZE];
	
	strunpack(output, source);
	
	return output;
}

stock ret_strcat(const string1[], const string2[]) {
	new output[STRLIB_RETURN_SIZE];
	
	strcat(output, string1);
	strcat(output, string2);
	
	return output;
}

stock ret_strmid(const source[], start, end) {
	new output[STRLIB_RETURN_SIZE];
	
	strmid(output, source, start, end);
	
	return output;
}

stock ret_strins(const string[], const substr[], pos, maxlength = sizeof(string)) {
	new output[STRLIB_RETURN_SIZE];
	
	strcat(output, string);
	strins(output, substr, pos);
	
	return output;
}

stock ret_strdel(const string[], start, end) {
	new output[STRLIB_RETURN_SIZE];
	
	strcat(output, string);
	strdel(output, start, end);
	
	return output;
}

stock ret_valstr(value, bool:pack = false) {
	new output[STRLIB_RETURN_SIZE];
	
	format(output, sizeof(output), "%d", value);
	
	if (pack)
		strpack(output, output);
	
	return output;
}

stock ret_GetPlayerName(playerid, bool:pack = false) {
	new output[MAX_PLAYER_NAME];
	
	GetPlayerName(playerid, output, sizeof(output));
	
	if (pack)
		strpack(output, output);
	
	return output;
}

stock sprintf(const fmat[], {Float, _}:...) {
	static output[STRLIB_RETURN_SIZE], frm_header[3], heap;
	
	const output_size = sizeof(output);
	
	if (ispacked(fmat)) {
		heap = CopyArgumentToHeap(0);
	} else {
		heap = 0;
	}{}
	
	                             
	#emit LCTRL      5
	#emit CONST.alt  frm_header
	#emit MOVS       12
	
	                               
	#emit LOAD.S.alt  8

	                                       
	#emit ADD.C    12                          
	#emit SCTRL    4
	
	                      
	#emit PUSH.C      output_size
	
	              
	#emit PUSH.C      output
	
	                          
	#emit MOVE.pri
	#emit ADD.C       8
	#emit PUSH.pri
	
	#if !STRLIB_USE_FORMATEX
		const formatex = 0;                                              
		
		goto do_sysreq;
	#endif

	                                                
	#emit LCTRL       6
	#emit ADD.C       36
	#emit PUSH.pri
	#emit CONST.pri   formatex
	#emit SCTRL       6
	
	#if !STRLIB_USE_FORMATEX
		do_sysreq:
	#endif
	
	                                                                          
	#emit SYSREQ.C    format
	
	                                   
	#emit LCTRL       5
	#emit SCTRL       4
	
	                             
	#emit MOVE.alt
	#emit CONST.pri   frm_header
	#emit MOVS        12
	
	                         
	if (heap) {
		RestoreHeapToAddress(heap);
	}{}
	
	                                                                        
	#emit LOAD.S.pri  8
	#emit ADD.C       12
	#emit MOVE.alt
	#emit LCTRL       5
	#emit ADD
	#emit LOAD.I
	#emit STOR.S.pri  20                          
	
	return output;
	
	                                                   
	#pragma unused fmat
}
