/* getfmtime.c - get formatter time */

#include <sys/types.h>   /* data type definition header file */
#include "../include/params.h"

#include "fmset.h"

void getvtime();
void get4time();
extern int rack;
extern int source;

void getfmtime(unixtime,unixhs,fstime,fshs,formtime,formhs)
time_t *unixtime; /* computer time */
int    *unixhs;
time_t *fstime; /* field system time */
int    *fshs;
time_t *formtime; /* formatter time */
int    *formhs;
{
  static long off =0;
  long raw, phase,sleep;

  if (nsem_test(NSEM_NAME) != 1) {
    printf("Field System not running - fmset aborting\n");
    rte_sleep(SLEEP_TIME);
    exit(0);
  }

  if (source == S2) {
    gets2time(unixtime,unixhs,fstime,fshs,formtime,formhs);
  } else {
    if(rack&VLBA)
      getvtime(unixtime,unixhs,fstime,fshs,formtime,formhs);
    else {
      sleep=10;
      rte_sleep(sleep);
      rte_rawt(&raw);
      raw%=100;
      sleep=(100+off-raw)%100;
      if(sleep!=0)
	rte_sleep(sleep); 
      get4time(unixtime,unixhs,fstime,fshs,formtime,formhs);
      if(*formhs > -1 || *formhs < 100) {
        phase=(100+*unixhs-*formhs)%100;
	off=phase;
      }
    }
  }
}
