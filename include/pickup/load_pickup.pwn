for(new i = 0; i < sizeof(pickup); i++)
{
    CreatePickup(pickup[i][P_ID], 23, pickup[i][P_POS_X], pickup[i][P_POS_Y], pickup[i][P_POS_Z], pickup[i][P_PICKUP_WORLD]);
    pickup[i][P_PICKUP_AREA] = CreateDynamicSphere(pickup[i][P_POS_X], pickup[i][P_POS_Y], pickup[i][P_POS_Z], 2.0, pickup[i][P_PICKUP_WORLD]);
}
