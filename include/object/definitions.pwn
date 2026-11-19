#define MAX_CREATE_OBJECTS 200

enum obj_INFO
{
	objID,
	objName[30],
	objModel,
	Float:objPosX,
	Float:objPosY,
	Float:objPosZ,
	Float:objRotX,
	Float:objRotY,
	Float:objRotZ
}

new
	ObjInfo[MAX_CREATE_OBJECTS][obj_INFO],
	TOTALOBJECTS,
	EditObjectPlayer[MAX_PLAYERS],
	ObjectNamePlayer[MAX_PLAYERS][30];
