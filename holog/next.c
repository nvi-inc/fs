#include <stddef.h>
#include <string.h>
#include <math.h>
#include "../include/dpi.h"

next(buff,azo,elo,sbuff)
     char *buff;
     double azo, elo;
     size_t sbuff;
{

  strcpy(buff,"Next ");
  jr2as((float) azo*RAD2DEG,buff,-9,5,sbuff);
  strcat(buff," ");
  jr2as((float) elo*RAD2DEG,buff,-9,5,sbuff);
  logit(buff,0,NULL);
  return;
}
