/* getfmtime.c - get formatter time */

#include <stdio.h>
#include <sys/types.h>   /* data type definition header file */

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#include "fmset.h"

void getvtime();
void get4time();
extern int rack;
extern int source;
extern int s2type;
extern char s2dev[2][3];

void getfmtime(unixtime,unixhs,fstime,fshs,formtime,formhs)
time_t *unixtime; /* computer time */
int    *unixhs;
time_t *fstime; /* field system time */
int    *fshs;
time_t *formtime; /* formatter time */
int    *formhs;
{
  static long phase =-1;
  long raw, sleep, rawch;

  if (nsem_test(NSEM_NAME) != 1) {
    endwin();
    fprintf(stderr,"Field System not running - fmset aborting\n");
    rte_sleep(SLEEP_TIME);
    exit(0);
  }

  if (source == S2) {
    gets2time(s2dev[s2type],unixtime,unixhs,fstime,fshs,formtime,formhs);
  } else {
    if(rack&VLBA)
      getvtime(unixtime,unixhs,fstime,fshs,formtime,formhs);
    else {
      rte_sleep(10);
      rte_ticks(&raw);
      sleep=102-(raw%100+phase)%100;
      if(phase >=0) {
	rte_sleep(sleep); 
      }
      get4time(unixtime,unixhs,fstime,fshs,formtime,formhs,&rawch);
      if(*formhs > -1 && *formhs < 100) {
	phase=(100+*formhs-rawch%100)%100;
      }
    }
  }  
}

