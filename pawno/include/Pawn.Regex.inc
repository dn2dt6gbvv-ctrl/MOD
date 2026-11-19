
 
#if !defined __cplusplus
	#if defined _pawnregex_included
	  #endinput
	#endif
	#define _pawnregex_included	
#endif

#define PAWNREGEX_INCLUDE_VERSION 112

enum E_REGEX_GRAMMAR
{
	REGEX_ECMASCRIPT,
	REGEX_BASIC,
	REGEX_EXTENDED,
	REGEX_AWK,
	REGEX_GREP,
	REGEX_EGREP
};

enum E_REGEX_FLAG
{
	REGEX_DEFAULT = 1 << 0,
	REGEX_ICASE = 1 << 1,
	REGEX_NOSUBS = 1 << 2,
	REGEX_OPTIMIZE = 1 << 3,
	REGEX_COLLATE = 1 << 4,
};

enum E_MATCH_FLAG
{
	MATCH_DEFAULT = 1 << 0,
	MATCH_NOT_BOL = 1 << 1,
	MATCH_NOT_EOL = 1 << 2,
	MATCH_NOT_BOW = 1 << 3,
	MATCH_NOT_EOW = 1 << 4,
	MATCH_ANY = 1 << 5,
	MATCH_NOT_NULL = 1 << 6,
	MATCH_CONTINUOUS = 1 << 7,

	MATCH_PREV_AVAIL = 1 << 8,
	MATCH_FORMAT_SED = 1 << 9,
	MATCH_FORMAT_NO_COPY = 1 << 10,

	MATCH_FORMAT_FIRST_ONLY = 1 << 11,
};
#if !defined __cplusplus
	public _pawnregex_version = PAWNREGEX_INCLUDE_VERSION;
	#pragma unused _pawnregex_version

	native Regex:Regex_New(const pattern[], E_REGEX_FLAG:flags = REGEX_DEFAULT, E_REGEX_GRAMMAR:grammar = REGEX_ECMASCRIPT) = regex_new;
	native Regex_Delete(&Regex:r) = regex_delete;

	native Regex_Check(const str[], Regex:r, E_MATCH_FLAG:flags = MATCH_DEFAULT) = regex_check;
	native Regex_Match(const str[], Regex:r, &RegexMatch:m, E_MATCH_FLAG:flags = MATCH_DEFAULT) = regex_match;
	native Regex_Search(const str[], Regex:r, &RegexMatch:m, &pos, startpos = 0, E_MATCH_FLAG:flags = MATCH_DEFAULT) = regex_search;
	native Regex_Replace(const str[], Regex:r, const fmt[], dest[], E_MATCH_FLAG:flags = MATCH_DEFAULT, size = sizeof dest) = regex_replace;

	native Match_GetGroup(RegexMatch:m, index, dest[], &length, size = sizeof dest) = match_get_group;
	native Match_Free(&RegexMatch:m) = match_free;

	#pragma deprecated
	native regex:regex_new(const pattern[], E_REGEX_FLAG:flags = REGEX_DEFAULT, E_REGEX_GRAMMAR:grammar = REGEX_ECMASCRIPT);
	#pragma deprecated
	native regex_delete(&regex:r);

	#pragma deprecated
	native regex_check(const str[], regex:r, E_MATCH_FLAG:flags = MATCH_DEFAULT);
	#pragma deprecated
	native regex_match(const str[], regex:r, &match_results:m, E_MATCH_FLAG:flags = MATCH_DEFAULT);
	#pragma deprecated
	native regex_search(const str[], regex:r, &match_results:m, &pos, startpos = 0, E_MATCH_FLAG:flags = MATCH_DEFAULT);
	#pragma deprecated
	native regex_replace(const str[], regex:r, const fmt[], dest[], E_MATCH_FLAG:flags = MATCH_DEFAULT, size = sizeof dest);

	#pragma deprecated
	native match_get_group(match_results:m, index, dest[], &length, size = sizeof dest);
	#pragma deprecated
	native match_free(&match_results:m);
#endif
