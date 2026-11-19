for(new i = 0; i < sizeof(ArendInfo); i++)
{
    ArendInfo[i][p_area] = CreateDynamicSphere(ArendInfo[i][p_arenda_X], ArendInfo[i][p_arenda_Y] ,ArendInfo[i][p_arenda_Z], 1.0);
    CreatePickup(12705, 23, ArendInfo[i][p_arenda_X], ArendInfo[i][p_arenda_Y] ,ArendInfo[i][p_arenda_Z]);
    Create3DTextLabel("Аренда транспорта", -1, ArendInfo[i][p_arenda_X], ArendInfo[i][p_arenda_Y] ,ArendInfo[i][p_arenda_Z]+0.5, 15.0, 0);
}
