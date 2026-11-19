for(new i = 0; i < sizeof car_dealship_static_car; ++i)
{
    car_dealship_static_car[i][cs_id] = AddStaticVehicleEx(car_dealship_static_car[i][cs_model], car_dealship_static_car[i][cs_x], car_dealship_static_car[i][cs_y], car_dealship_static_car[i][cs_z], car_dealship_static_car[i][cs_r], 1, 1, 3600);
    SetVehicleParamsCarDoors(car_dealship_static_car[i][cs_id], 0, 0, 0, 0);
}
