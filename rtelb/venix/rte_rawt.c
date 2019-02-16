/* rte_rawt.c - return raw system time in clock HZ */

#include <sys/types.h>
#include <sys/times.h>

void rte_rawt(lRawTime)
int *lRawTime;
{
     int times();
     struct tms buffer;

     *lRawTime=times(&buffer);

     return;
}
