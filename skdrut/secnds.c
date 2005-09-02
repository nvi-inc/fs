/* 04.06.21 AEM adds #include <time.h> */

#include <time.h>
#include <sys/time.h>
#include <unistd.h>

extern struct timeval   tp;
extern struct timezone  tzp;
extern struct tm        *tme;

float secnds(offset)
float *offset;
{
      gettimeofday(&tp,&tzp);
      tme = gmtime(&tp.tv_sec);
      return((tme->tm_hour * 3600.0) + (tme->tm_min * 60.0) +
             (tme->tm_sec) + (*offset));
}
