#define MAX_PARKING     50
#define PARKING_VW_BASE 100

enum parkingInfo {
    Float:parking_Vx,
    Float:parking_Vy,
    Float:parking_Vz,

    Float:parking_Ex,
    Float:parking_Ey,
    Float:parking_Ez,
    Float:parking_Ea,

    parking_area,

    Float:parking_e_ix,
    Float:parking_e_iy,
    Float:parking_e_iz,
    Float:parking_e_ia,

    Float:parking_e_px,
    Float:parking_e_py,
    Float:parking_e_pz,

    parking_e_area,
    parking_e_area_car,

    Float:parking_e_pick_carX,
    Float:parking_e_pick_carY,
    Float:parking_e_pick_carZ,


    parking_Vw,
    parking_dbId
};

new parking[MAX_PARKING][parkingInfo];
new totalParking;

new gParkPickup[MAX_PARKING][3];

enum parking_places_info {
    Float:parking_Px,
    Float:parking_Py,
    Float:parking_Pz,
    Float:parking_Pa
};

new parking_places[12][parking_places_info] = 
{
    {-2075.8960, -841.7637, 2003.9407, 180.0137}, 
    {-2080.9265, -842.1615, 2004.0565, 180.0849}, 
    {-2087.0605, -841.7936, 2004.0562, 180.3706},  
    {-2092.1809, -841.6678, 2004.0560, 181.4266}, 
    {-2075.8582, -859.7751, 2004.0564, 1.0268},  
    {-2080.7954, -859.4807, 2004.0562, 1.0095},  
    {-2087.1582, -859.9040, 2004.0560, 1.2293}, 
    {-2092.0601, -859.4094, 2004.0562, 0.9790}, 
    {-2109.8240, -841.4391, 2004.0562, 270.9101},  
    {-2109.6758, -846.5154, 2003.9808, 271.1724}, 
    {-2109.4883, -855.5809, 2003.9716, 271.1219}, 
    {-2109.5615, -860.4950, 2003.9550, 271.2323}
};
