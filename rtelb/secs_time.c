/* secs_time.c - return rte time format from UNIX time  */

#include <stdlib.h>
#include <sys/time.h>
#include <unistd.h>
#include <time.h>

void secs_times(it,it6)
int it[5],it6;

{
     struct tm *ptr;
     time_t secs;
     struct timeval tv;

     if(0!= gettimeofday(&tv, NULL)) {
       perror("getting timeofday in secs_time, fatal\n");
       exit(-1);
     }
     secs=tv.tv_sec;

     ptr=gmtime(&secs);
                          /* store in rte exec(11 time buffer */

     it[0]=tv.tv_usec/10000;
     it[1]=ptr->tm_sec;
     it[2]=ptr->tm_min;
     it[3]=ptr->tm_hour;
     it[4]=1+ptr->tm_yday;

     it6=1900+ptr->tm_year;

     return;
}
