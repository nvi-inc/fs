#include <errno.h>
#include <sys/time.h>
#include <sys/resource.h>

int rte_prior(ivalue)
int ivalue;
{
     int iret;

     errno=0;
     iret=getpriority(PRIO_PROCESS, 0);
     if(errno != 0) {
       perror("rte_prior: getting priority");
       iret= 0;
     }
     if( -1 == setpriority(PRIO_PROCESS, 0, ivalue))
/*
       perror("rte_prior: setting priority");
*/
  
     return iret;
}
