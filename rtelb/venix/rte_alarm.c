#include <rtx.h>
#include <signal.h>

int rtalarm();

unsigned rte_alarm( centisec)
unsigned centisec;
{
    int time, gran;

    if(centisec==0) {
      if(-1==rtalarm(RT_ALARM_CANCEL,time,SIGALRM)) {
        perror("rte_alarm, canceling");
        exit(-1);
      }
      return( 0);
    }

/* fetch granularity in micro-seconds */

    if(-1==(gran=rtalarm(RT_ALARM_GETGRAN,time,SIGALRM))) {
      perror("rte_alarm, getting granularity");
      exit(-1);
   }
   if(gran != 10000) {
      perror("rte_alarm, granularity != 10000");
      exit(-1);
   }

     time=centisec;
     if(0>(int)centisec) /* correct for unsigned overflows so we at least
                           won't abend */
        time=((unsigned) ~0)>>1;

    if(-1==rtalarm(RT_ALARM_ONCE,time,SIGALRM)) {
      perror("rte_alarm, setting alarm");
      printf(" RT_ %d time %d SIG %d\n",RT_ALARM_ONCE,time,SIGALRM);
      exit(-1);
    }
    return(0);
}
