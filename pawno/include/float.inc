







   
#if defined _Float_included
  #endinput
#endif
#define _Float_included
#pragma library Float

                                   
enum floatround_method {
  floatround_round,
  floatround_floor,
  floatround_ceil,
  floatround_tozero,
  floatround_unbiased
}
enum anglemode {
  radian,
  degrees,
  grades
}

                                                    
                                                    
native Float:float(value);

                                                    
                                                  
native Float:floatstr(const string[]);

                                                    
                                  
native Float:floatmul(Float:oper1, Float:oper2);

                                                    
                                                    
native Float:floatdiv(Float:dividend, Float:divisor);

                                                    
                             
native Float:floatadd(Float:oper1, Float:oper2);

                                                    
                                           
native Float:floatsub(Float:oper1, Float:oper2);

                                                    
                                           
native Float:floatfract(Float:value);

                                                    
                                        
native floatround(Float:value, floatround_method:method=floatround_round);

                                                    


                                                                        
native floatcmp(Float:oper1, Float:oper2);

                                                    
                                                                               
native Float:floatsqroot(Float:value);

                                                    
                                                          
native Float:floatpower(Float:value, Float:exponent);

                                                    
                          
native Float:floatlog(Float:value, Float:base=10.0);

                                                    

                        
native Float:floatsin(Float:value, anglemode:mode=radian);
native Float:floatcos(Float:value, anglemode:mode=radian);
native Float:floattan(Float:value, anglemode:mode=radian);

                                                    
                               
native Float:floatabs(Float:value);


                                                    
#pragma rational Float

                            
native Float:operator*(Float:oper1, Float:oper2) = floatmul;
native Float:operator/(Float:oper1, Float:oper2) = floatdiv;
native Float:operator+(Float:oper1, Float:oper2) = floatadd;
native Float:operator-(Float:oper1, Float:oper2) = floatsub;
native Float:operator=(oper) = float;

stock Float:operator++(Float:oper)
    return oper+1.0;

stock Float:operator--(Float:oper)
    return oper-1.0;

stock Float:operator-(Float:oper)
    return oper^Float:cellmin;                                                      

stock Float:operator*(Float:oper1, oper2)
    return floatmul(oper1, float(oper2));                               

stock Float:operator/(Float:oper1, oper2)
    return floatdiv(oper1, float(oper2));

stock Float:operator/(oper1, Float:oper2)
    return floatdiv(float(oper1), oper2);

stock Float:operator+(Float:oper1, oper2)
    return floatadd(oper1, float(oper2));                               

stock Float:operator-(Float:oper1, oper2)
    return floatsub(oper1, float(oper2));

stock Float:operator-(oper1, Float:oper2)
    return floatsub(float(oper1), oper2);

stock bool:operator==(Float:oper1, Float:oper2)
    return floatcmp(oper1, oper2) == 0;

stock bool:operator==(Float:oper1, oper2)
    return floatcmp(oper1, float(oper2)) == 0;                           

stock bool:operator!=(Float:oper1, Float:oper2)
    return floatcmp(oper1, oper2) != 0;

stock bool:operator!=(Float:oper1, oper2)
    return floatcmp(oper1, float(oper2)) != 0;                           

stock bool:operator>(Float:oper1, Float:oper2)
    return floatcmp(oper1, oper2) > 0;

stock bool:operator>(Float:oper1, oper2)
    return floatcmp(oper1, float(oper2)) > 0;

stock bool:operator>(oper1, Float:oper2)
    return floatcmp(float(oper1), oper2) > 0;

stock bool:operator>=(Float:oper1, Float:oper2)
    return floatcmp(oper1, oper2) >= 0;

stock bool:operator>=(Float:oper1, oper2)
    return floatcmp(oper1, float(oper2)) >= 0;

stock bool:operator>=(oper1, Float:oper2)
    return floatcmp(float(oper1), oper2) >= 0;

stock bool:operator<(Float:oper1, Float:oper2)
    return floatcmp(oper1, oper2) < 0;

stock bool:operator<(Float:oper1, oper2)
    return floatcmp(oper1, float(oper2)) < 0;

stock bool:operator<(oper1, Float:oper2)
    return floatcmp(float(oper1), oper2) < 0;

stock bool:operator<=(Float:oper1, Float:oper2)
    return floatcmp(oper1, oper2) <= 0;

stock bool:operator<=(Float:oper1, oper2)
    return floatcmp(oper1, float(oper2)) <= 0;

stock bool:operator<=(oper1, Float:oper2)
    return floatcmp(float(oper1), oper2) <= 0;

stock bool:operator!(Float:oper)
    return (_:oper & cellmax) == 0;

                          
forward operator%(Float:oper1, Float:oper2);
forward operator%(Float:oper1, oper2);
forward operator%(oper1, Float:oper2);

