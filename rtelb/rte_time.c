/* rte_time.c - return rte format time buffer */

#include <sys/types.h>
#include <time.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

void rte_rawt();
void rte_fixt();

void rte_time(it,it6)
int it[5],*it6;
{
     struct tm *ptr;
     time_t clock;
     int clock32;
     int centisec;

     rte_rawt(&centisec);  /* retrieve the raw time */

//     rte_fixt(&clock, &centisec);	/* correct for clock drift model */
     rte_fixt(&clock32, &centisec);	/* correct for clock drift model */
     clock=clock32;

     ptr=gmtime(&clock);            /* store in rte exec(11 time buffer */
     it[0] = centisec%100;
     it[1]=ptr->tm_sec;
     it[2]=ptr->tm_min;
     it[3]=ptr->tm_hour;
     it[4]=1+ptr->tm_yday;

     *it6=1900+ptr->tm_year;

     return;
}
