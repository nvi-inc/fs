#include <signal.h>
#include <sys/types.h>
#include <sys/times.h>
#include <time.h>
#include <unistd.h>

clock_t rte_times(struct tms *buf);

unsigned rte_sleep( centisec)
unsigned centisec;
{
     struct tms buffer;
     unsigned long wait, end, now;
     unsigned int usecs;

     end=rte_times(&buffer)+centisec+1;

     now=rte_times(&buffer);
     while(end > now) {
       wait=end-now;
       if(wait>429496) /* max unsigned we can multiple up to fit */
         wait=429496;
       usecs=wait*10000;
       usleep(usecs);
       now=rte_times(&buffer);
     }

     return( (unsigned) 0);
}
