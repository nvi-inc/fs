/* rte_ticks.c - return raw system ticks in clock HZ */

#include <sys/times.h>

void rte_ticks(lRawTicks)
long *lRawTicks;
{
     struct tms buffer;
     
     *lRawTicks=times(&buffer);

     return;
}
