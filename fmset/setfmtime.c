/* setfmtime.c - set formatter time */

#include <sys/types.h>   /* data type definition header file */
#include "../include/params.h"

#include "fmset.h"

void setvtime();
void set4time();

extern int rack;
extern int source;

void setfmtime(formtime,delta)
time_t formtime;
int delta;
{

if (nsem_test(NSEM_NAME) != 1) {
  printf("Field System not running - fmset aborting\n");
  rte_sleep(SLEEP_TIME);
  exit(0);
}

  if (source == S2)
    sets2time(formtime+delta);
  else
    if (rack & VLBA)
      setvtime((time_t) (formtime + delta));
    else
      set4time(formtime,delta);

}
