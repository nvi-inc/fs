/* setfmtime.c - set formatter time */

#include <stdio.h>
#include <sys/types.h>   /* data type definition header file */
#include <stdlib.h>
#include "../include/params.h"

#include "fmset.h"

void setvtime();
void set4time();

extern int rack;
extern int rack_type;
extern int source;
extern int s2type;
extern char s2dev[2][3];
extern int iRDBE;

void setfmtime(formtime,delta,vdif_epoch)
time_t formtime;
int delta;
int vdif_epoch;
{

if (nsem_test(NSEM_NAME) != 1) {
  endwin();
  fprintf(stderr,"Field System not running - fmset aborting\n");
  rte_sleep(SLEEP_TIME);
  exit(0);
}
  if (source == RDBE) 
    setRDBEtime(formtime,delta,vdif_epoch);
  else if (source == MK5 )
    set5btime(formtime,delta);
  else if (source == DBBC
  /* was:
   * rack == DBBC && (rack_type == DBBC_DDC_FILA10G || rack_type == DBBC_PFB_FILA10G) */
	   )
    setfila10gtime(formtime,delta);
  else if (source == S2)
    sets2time(s2dev[s2type],formtime+delta);
  else if (rack & VLBA)
    setvtime((time_t) (formtime + delta));
  else
    set4time(formtime,delta);

}
