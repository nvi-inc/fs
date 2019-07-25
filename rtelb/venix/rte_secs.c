/* rte_secs.c - find seconds offset from times value */

#include <sys/types.h>
#include <sys/times.h>
#include <time.h>

void rte_rawt();

long rte_secs()
{
     time_t clock1, clock2;
     long centisec;

     clock1=0;
     centisec=1;
     clock2=1;
     while(clock1!=clock2 && ((centisec%100) <2)) {
	clock1=time(&clock1);       /* bracket the centi-seconds */
        rte_rawt(&centisec);
	clock2=time(&clock2);
	rte_sleep((unsigned) 1);
	}
     return (clock2-(centisec/100));
}
