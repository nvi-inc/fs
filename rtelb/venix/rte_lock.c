#include <rtx.h>

void rte_lock(ivalue)
int ivalue;
{
     int cmd;

     if(ivalue)
       cmd=RT_LOCK;
     else
       cmd=RT_UNLOCK;

     if(rtlock(cmd,(unsigned) 0,(unsigned) 0)==-1) {
       perror("controlling memory lock");
       exit(-1);
     }

     return;
}
