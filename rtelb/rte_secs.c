/* rte_secs.c - find seconds offset from times value */

#include <sys/types.h>
#include <sys/times.h>
#include <time.h>

void rte_rawt();

long rte_secs()
{
     time_t clock1, clock2;
     long centisec;

     rte_ticks(&centisec);
     clock2=time(&clock2);

     return (clock2-(centisec/100));

}
