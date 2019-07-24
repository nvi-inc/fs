/*
 * This subroutine will figure out how many seconds
 * for the given date since January 1, 1970 GMT.
 * The result is needed to set the computer clock.
 * UNIX requires this figure!!
 */
#include <stdio.h>
#include <string.h>
#include <errno.h>
#define LEAP_SECS	31622400
#define NONLEAP_SECS	31536000
#define DAY_SECS	86400
#define HR_SECS		3600
#define MIN_SECS	60

void numsc_(hr,min,sec,csec,doy,year,error)

int *hr;
int *min;
int *sec;
int *csec;
int *doy;
int *year;
int *error;

{
 
int locyear, figureyear;
int numleap, nonleap;
int leap;
long numsec;

  if (*year < 1970) {
    *error = -1;
    return;
  }
  
  leap = 0;

  locyear= *year-1972;
  if (*year % 4 == 0 ) leap=1;  /* leap year?, good until 2100 */
  numleap = locyear/4;   /* number of leap years since 1970 */
  nonleap = locyear-numleap;  /* number of non leap years since 1970 */

/* printf(" figureyear: %d\n nonleap: %d\n numleap %d\n", figureyear,nonleap,
numleap); 
printf(" leapyear %d\n",leap);
*/

  numsec = (nonleap*NONLEAP_SECS) + (numleap*LEAP_SECS);
  numsec = numsec+(DAY_SECS*(*doy-1))+(HR_SECS*(*hr))+(MIN_SECS*(*min))
                 +(*sec);
  *error = stime(&numsec);
  if (*error < 0) perror();
}
