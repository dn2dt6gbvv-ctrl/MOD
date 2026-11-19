
































































                                                                                

#if defined _inc_tdw_vylabel


	#undef _inc_tdw_vylabel
#endif

#if defined _TDW_VH_SYS_3D_TEXT_LABEL
	#endinput
#endif

#define _TDW_VH_SYS_3D_TEXT_LABEL

#include "tdw_vehicle"

#if defined Streamer_IncludeFileVersion && !defined _TDW_VH_DETECT_STREAMER
	#define _TDW_VH_DETECT_STREAMER
#endif




_TDW_STATIC_ENUM enum E_TDW_VH_LABEL_FLAGS(<<= 1)
{
	EI_VH_LABEL_HIDDEN = 1
};




#if defined _TDW_VH_DETECT_STREAMER
	#define TDW_VH_DestroyLabel				DestroyDynamic3DTextLabel
	#define TDW_VH_UpdateLabel				UpdateDynamic3DTextLabelText
#else
	#define TDW_VH_DestroyLabel				Delete3DTextLabel
	#define TDW_VH_UpdateLabel				Update3DTextLabelText
#endif

#if !defined MAX_VEHICLE_LABEL_SIZE
	#define MAX_VEHICLE_LABEL_SIZE			(144)
#endif




static stock
	Text3D:TDW_g_sVehicle@LabelId[MAX_VEHICLES],
	TDW_g_sVehicle@LabelText[MAX_VEHICLES][MAX_VEHICLE_LABEL_SIZE char],
	E_TDW_VH_LABEL_FLAGS:TDW_g_sVehicle@Flags[MAX_VEHICLES char];












                                                                                

stock CreateVehicle3DTextLabel(vehicleid, const label[], color, Float:offset_x,
	Float:offset_y, Float:offset_z, Float:drawdistance, virtualworld,
	bool:testLos = false)
{
	if (0 == IsValidVehicle(vehicleid))
		return 0;

	new
		label_length = strlen(label);

	if (0 == _:(0 < label_length < MAX_VEHICLE_LABEL_SIZE))
		return 0;

	#if defined _TDW_VH_DETECT_STREAMER
		TDW_g_sVehicle@LabelId[vehicleid] = CreateDynamic3DTextLabel(label,
			color, offset_x, offset_y, offset_z, drawdistance, _, vehicleid,
			_:testLos, virtualworld, _, _, _);
	#else
		new Text3D:Create3DTextLabel_ret;

		#emit PUSH.s testLos
		#emit PUSH.s virtualworld
		#emit PUSH.s drawdistance
		#emit PUSH.c 0
		#emit PUSH.c 0
		#emit PUSH.c 0
		#emit PUSH.s color
		#emit PUSH.s label
		#emit PUSH.c 36
		#emit SYSREQ.c Create3DTextLabel

		#emit STOR.s.pri Create3DTextLabel_ret

		#emit PUSH.s offset_z
		#emit PUSH.s offset_y
		#emit PUSH.s offset_x
		#emit PUSH.s vehicleid
		#emit PUSH.pri
		#emit PUSH.c 20
		#emit SYSREQ.c Attach3DTextLabelToVehicle

		#emit STACK 64

		TDW_g_sVehicle@LabelId[vehicleid] = Create3DTextLabel_ret;
	#endif

	strpack(TDW_g_sVehicle@LabelText[vehicleid], label, label_length);

	TDW_g_sVehicle@Flags{vehicleid} = E_TDW_VH_LABEL_FLAGS:0;

	return 1;
}









                                                                                

stock DestroyVehicle3DTextLabel(vehicleid)
{
	return IsValidVehicle(vehicleid)
		? TDW_VH_DestroyLabel(TDW_g_sVehicle@LabelId[vehicleid])
		: INVALID_VEHICLE_ID;
}









                                                                                

stock UpdateVehicle3DTextLabel(vehicleid, const label[], color = -1,
	bool:replace_buffer = false)
{
	if (0 == IsValidVehicle(vehicleid))
		return 0;

	new
		label_length = strlen(label);

	if (0 == _:(0 < label_length < MAX_VEHICLE_LABEL_SIZE))
		return 0;

	#emit PUSH.s label
	#emit PUSH.s color

	#emit CONST.alt TDW_g_sVehicle@LabelId
	#emit LOAD.s.pri vehicleid
	#emit LIDX

	#emit PUSH.pri
	#emit PUSH.c 12
	#if defined _TDW_VH_DETECT_STREAMER
		#emit SYSREQ.c UpdateDynamic3DTextLabelText
	#else
		#emit SYSREQ.c Update3DTextLabelText
	#endif
	#emit STACK 16

	if (replace_buffer)
		strpack(TDW_g_sVehicle@LabelText[vehicleid], label, label_length);

	return 1;
}









                                                                                

stock ShowVehicle3DTextLabel(vehicleid)
{
	if (0 == IsValidVehicle(vehicleid))
		return 0;

	if (TDW_g_sVehicle@Flags{vehicleid} & EI_VH_LABEL_HIDDEN) {
		UpdateVehicle3DTextLabel(vehicleid, TDW_g_sVehicle@LabelText[vehicleid],
			true);
		TDW_g_sVehicle@Flags{vehicleid} ^= EI_VH_LABEL_HIDDEN;
	}

	return 1;
}









                                                                                

stock HideVehicle3DTextLabel(vehicleid)
{
	if (0 == IsValidVehicle(vehicleid))
		return 0;
	if (TDW_g_sVehicle@Flags{vehicleid} & EI_VH_LABEL_HIDDEN)
		return 0;

	UpdateVehicle3DTextLabel(vehicleid, !" ", true);
	TDW_g_sVehicle@Flags{vehicleid} ^= EI_VH_LABEL_HIDDEN;

	return 1;
}









                                                                                

stock Is3DTextLabelHidden(vehicleid)
{
	return IsValidVehicle(vehicleid) &&
		(TDW_g_sVehicle@Flags{vehicleid} & EI_VH_LABEL_HIDDEN);
}




#undef TDW_VH_DestroyLabel
#undef TDW_VH_UpdateLabel
