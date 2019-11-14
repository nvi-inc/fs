/* secs2rte.c - return rte format from UNIX format time  */

#include <sys/types.h>
#include <time.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

void rte_rawt();
void rte_fixt();

void secs2rte(secs,it)
//time_t *secs;
int    *secs;
int it[5];
{
     struct tm *ptr;

     ptr=gmtime(secs);            /* store in rte exec(11 time buffer */
                                  /* assume centiseconds have been set */
     it[1]=ptr->tm_sec;
     it[2]=ptr->tm_min;
     it[3]=ptr->tm_hour;
     it[4]=1+ptr->tm_yday;

     it[5]=1900+ptr->tm_year;

     return;
}
