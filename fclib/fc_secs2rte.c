/*
 * This subroutine will figure out how the rte time buffer
 * for the UNIX time measured from January 1, 1970 GMT.
 */
#include <sys/types.h>

void fc_secs2rte_(seconds,it)
int it[6];
time_t *seconds;
{
 
  rte2secs(seconds,it);

}
