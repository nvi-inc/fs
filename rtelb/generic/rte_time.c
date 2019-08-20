#include <sys/types.h>
#include <sys/times.h>
#include <time.h>

void rte_time(it,it6)
int it[5],*it6;
{
     struct tm *ptr;
     time_t clock1, clock2;
     int times();
     struct tms buffer;
     int centisec;

     clock1=time(&clock1);
     centisec=times(&buffer);
     clock2=time(&clock2);
     if(clock2 != clock1) centisec=0; else centisec=(centisec-1)%100;
     ptr=gmtime(&clock2);

     it[0]=centisec;
     it[1]=ptr->tm_sec;
     it[2]=ptr->tm_min;
     it[3]=ptr->tm_hour;
     it[4]=1+ptr->tm_yday;

     *it6=1900+ptr->tm_year;

     return;
}
