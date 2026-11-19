CMD:unrent(playerid)
{
	if(!PI[playerid][pArendID]) return SendClientMessage(playerid, COLOR_RED, "Вы не арендуете транспорт или находитесь слишком далеко от него");
	
	ShowPlayerDialogEx(playerid, dialog_AREND+1, DIALOG_STYLE_MSGBOX, "Завершение аренды транспорта", "Вы уверены, что хотите завершить аренду текущего транспорта?", "Завершить", "Закрыть");
	return 1;
}
