#include <rtx.h>

int rte_prior(ivalue)
int ivalue;
{
     int iret,level;

     iret=rtpriority(RT_PRI_GET,level);
     if(iret==-1) {
       perror("getting old priority");
       exit(-1);
     }
     if(ivalue>-1 && ivalue <128)
       level=ivalue;
     else
       level=RT_PRI_OFF;

     if(rtpriority(RT_PRI_SET, level)==-1) {
       perror("setting priority");
       exit(-1);
     }

     return iret;
}
