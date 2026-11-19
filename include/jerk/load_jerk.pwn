jerkReception = CreateDynamicSphere(500.7222, 726.0360, 1279.6061, 1.0);
CreatePickup(1239, 23, 500.7222, 726.0360, 1279.6061, -1);

for(new i = 0; i < sizeof(jerkArea); i++)
{
    jerkArea[i][jerk_area] = CreateDynamicSphere(jerkArea[i][jerk_x], jerkArea[i][jerk_y], jerkArea[i][jerk_z], 2.0);
}
