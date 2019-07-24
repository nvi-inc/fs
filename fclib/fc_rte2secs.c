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

void fc_rte2secs_(it,seconds)
int it[6];
long *seconds;
{
 
  rte2secs(it,seconds);

}
