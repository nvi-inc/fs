#include <rtx.h>
#include <signal.h>

int rtalarm();

unsigned rte_alarm( centisec)
unsigned centisec;
{
    int time, gran;

/* fetch granularity in micro-seconds */

    if(centisec==0) {
      if(-1==rtalarm(RT_ALARM_CANCEL,time,SIGALRM)) {
        perror("rte_alarm, canceling");
        exit(-1);
      }
      return( 0);
    }
    if(-1==(gran=rtalarm(RT_ALARM_GETGRAN,time,SIGALRM))) {
      perror("rte_alarm, getting granularity");
      exit(-1);
   }

   time=((10000*(long)centisec)+gran-1)/gran;  /* time to wait in clock tics */

    if(-1==rtalarm(RT_ALARM_ONCE,time,SIGALRM)) {
      perror("rte_alarm, setting alarm");
      printf(" RT_ %d time %d SIG %d\n",RT_ALARM_ONCE,time,SIGALRM);
      exit(-1);
    }
    return(0);
}
