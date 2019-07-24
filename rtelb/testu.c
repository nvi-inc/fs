#include <sys/types.h>
#include <sys/times.h>
#include <time.h>
#include <string.h>
#include <stdio.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

void main()
{
     struct tm *ptr;
     time_t clock1, clock2, clocksave;
     long times();
     struct tms buffer;
     long centisec, lAddHs, centisave, centi;
     int iIndex;
     double rte_offt(), dAddHs;
     int i;

     clock1=time(&clock1);       /* bracket the centi-seconds */
     centisec=times(&buffer); /* unfortunately times returns 1-100 */
                              /* as the start of the second to the end */
     clock2=time(&clock2);

     centi=centisec;
     if(clock2 != clock1)
       centisec=0;               /* the clock changed */
     else
       centisec=(centisec-1)%100;
     clocksave=clock2;
     centisave=centisec;
     for (;;) {
     clock1=time(&clock1);       /* bracket the centi-seconds */
     centisec=times(&buffer); /* unfortunately times returns 1-100 */
                              /* as the start of the second to the end */
     clock2=time(&clock2);

     centi=centisec;
     if(clock2 != clock1)
       centisec=0;               /* the clock changed */
     else
       centisec=(centisec-1)%100;

     if(centisec == 0 && clocksave == clock2 && centisave != centisec){
        printf("clock1 %12d centisec %4d clock2 %12d\n",clock1,centisec,clock2);
        printf("clocksave %12d centisav %4d centi %12d\n",clocksave,centisave,centi);
     }
     clocksave=clock2;
     centisave=centisec;
     }
}
