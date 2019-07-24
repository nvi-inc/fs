#include <sys/types.h>
#include <sys/times.h>
#include <time.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

void rte_time(it,it6)
int it[5],*it6;
{
     struct tm *ptr;
     time_t clock1, clock2;
     long times();
     struct tms buffer;
     long centisec;

     clock1=time(&clock1);       /* bracket the centi-seconds */
     centisec=times(&buffer); /* unfortunately times returns 1-100 */
                              /* as the start of the second to the end */
     clock2=time(&clock2);

     if(clock2 != clock1)
       centisec=0;               /* the clock changed */
     else
       centisec=(centisec-1)%100;
                                             /* apply offset */
     centisec+=shm_addr->time.offset[01 & shm_addr->time.index];

     if((centisec>99) ) {                   /* fix-up overflow */
       clock2+=centisec/100;
       centisec=centisec%100;
     } else if (centisec<0) {               /* fix-up underflow */
       clock2+=(centisec-99)/100;
       centisec=(100+(centisec%100))%100;
     }

     ptr=gmtime(&clock2);            /* store in rte exec(11 time buffer */
     it[0]=centisec;
     it[1]=ptr->tm_sec;
     it[2]=ptr->tm_min;
     it[3]=ptr->tm_hour;
     it[4]=1+ptr->tm_yday;

     *it6=1900+ptr->tm_year;

     return;
}
