
#include <sys/times.h>
#include <sys/time.h>
#include <time.h>
#include <unistd.h>

struct timeval   tp;
struct timezone  tzp;
struct tm        *tme;

int idate (month,day,year)

int *month, *day, *year;

{
      gettimeofday(&tp,&tzp);
      tme = gmtime(&tp.tv_sec);
      *month = tme->tm_mon + 1;
      *day   = tme->tm_mday;
      *year  = tme->tm_year;

}
