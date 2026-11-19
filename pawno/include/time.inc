



   
#if defined _time_included
  #endinput
#endif
#define _time_included
#pragma library Time

native gettime(&hour=0, &minute=0, &second=0);
native getdate(&year=0, &month=0, &day=0);
native tickcount(&granularity=0);
