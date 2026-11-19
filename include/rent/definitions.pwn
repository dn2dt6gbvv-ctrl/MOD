#define MAX_RENT 50

enum arendInfo
{
	Float: p_arenda_X,
	Float: p_arenda_Y,
	Float: p_arenda_Z,
	p_arenda_car,
	p_arenda_price, 
    p_area,
    p_vw,
    p_dbId
};

new ArendInfo[MAX_RENT][arendInfo];
new totalRent;

new gRentPickup[MAX_RENT];
new Text3D:gRentLabel[MAX_RENT];
