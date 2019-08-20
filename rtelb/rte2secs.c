/*
 * This subroutine will figure out how many seconds
 * for the given date since January 1, 1970 GMT.
 */
#include <stdio.h>
#include <string.h>
#include <errno.h>

#define LEAP_SECS	366*86400L
#define NONLEAP_SECS	365*86400L
#define DAY_SECS	86400L
#define HR_SECS		3600L
#define MIN_SECS	60L

void rte2secs(it,seconds)
int it[6];
int *seconds;
{
 
  int year,numleap,nonleap;

  if ((it[5]< 1970) || it[5]>2038 || (it[5] == 2038 && it[4]> 1)) {
    /* overflow long (32-bit) int */
    *seconds=-1;
/* don't abort for now, mark IV formatter problems
    fprintf(stderr,"rte2secs: date outside range %d %d\n",it[5],it[4]);
      exit(-1);
*/
    return;
  }
  
  year= it[5]-1970;

  numleap = (year+1)/4; /* number of leap years (before this year) since 1970 */
  nonleap = year-numleap; /* number of non leap years */

  /* not Y2038 compliant */
  *seconds = (nonleap*NONLEAP_SECS) + (numleap*LEAP_SECS)+
           (DAY_SECS*(it[4]-1))+(HR_SECS*it[3])+(MIN_SECS*it[2])+it[1];

  return;
}



