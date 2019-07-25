#include <signal.h>
#include <sys/types.h>
#include <sys/times.h>
#include <time.h>

void usleep();

unsigned rte_sleep( centisec)
unsigned centisec;
{
     clock_t times();
     struct tms buffer;
     long wait, end;

     end=times(&buffer)+centisec;

     wait=end-times(&buffer);        /* must be a signed int for comparison */
     while(wait>0) {
       if(wait>214748)
         wait=214748;
       usleep((unsigned) wait*10000);
       wait=end-times(&buffer);
     }

     return( (unsigned) 0);
}
