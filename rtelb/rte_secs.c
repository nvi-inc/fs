/* rte_secs.c - find seconds offset from times value */

#include <sys/times.h>
#include <sys/time.h>
#include <time.h>
#include <errno.h>

long rte_secs(long *usec_off,unsigned long *ticks_off,int *error, int *perrno)
{
  struct tms buf;
  struct timeval tv;
  clock_t ticks;

  ticks=times(&buf);
  if(ticks == (clock_t) -1) {
    perror("rte_secs, using times()");
    *error = -1;
    *perrno=errno;
    return 0;
  }

  if(0!= gettimeofday(&tv, NULL)) {
    perror("rte_secs, using gettimeofday()");
    *error = -2;
    *perrno=errno;
    return 0;
  }

  *error=0;
  *perrno=0;
  *ticks_off=(unsigned long) ticks;
  *usec_off=tv.tv_usec;
  return tv.tv_sec;

}
