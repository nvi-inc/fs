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
     time_t clock1[1000], clock2[1000], clocksave;
     long times();
     struct tms buffer;
     long centisec[1000], lAddHs, centisave;
     int iIndex;
     double rte_offt(), dAddHs;
     int i;

     while(97 >(times(&buffer)%100))
	;
     for (i=0;i<1000;i++) {
     clock1[i]=time(clock1+i);       /* bracket the centi-seconds */
     centisec[i]=times(&buffer); /* unfortunately times returns 1-100 */
                              /* as the start of the second to the end */
     clock2[i]=time(clock2+i);

     }
     for (i=0;i<1000;i++) {
        printf("%12d %4d %12d\n",clock1[i],centisec[i],clock2[i]);
     }
}
