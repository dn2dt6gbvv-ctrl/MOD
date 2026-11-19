#define MAX_PICKUP     1000


enum pickup_info 
{
    P_ID,
    Float: P_POS_X,
    Float: P_POS_Y,
    Float: P_POS_Z,
    P_PICKUP_WORLD,
    P_PICKUP_INT,
    P_PICKUP_AREA
};

new pickup[][pickup_info] = 
{
    {1239, -1577.3916,-2169.6482,2604.8342, 1, 0}
};

enum 
{
    DIALOG_MERIA = 6032
};
