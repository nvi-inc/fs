#include <rtx.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/times.h>
#include <time.h>

unsigned rtsleep();
int rte_alarm();
void pause();

unsigned rte_sleep( centisec)
unsigned centisec;
{
     long times();
     struct tms buffer;
     long now, end;
     unsigned iret;
     int time,wait;

     end=times(&buffer)+centisec;

/* detect lack of permission by checking granularity */

    if(-1==rtalarm(RT_ALARM_GETGRAN,time,SIGALRM)) {
      perror("rte_sleep, getting granularity");
      exit(-1);
   }
     wait=end-times(&buffer);        /* must be a signed int for comparison */
     while(wait>0) {
       iret=rtsleep((unsigned) wait*10);
       wait=end-times(&buffer);
     }

     rte_fpmask();     /* re-disable fp exceptions after sleep re-enables */
     return( (unsigned) 0);
}
