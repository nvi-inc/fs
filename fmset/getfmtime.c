/* getfmtime.c - get formatter time */

#include <sys/types.h>   /* data type definition header file */
#include "../include/params.h"

#include "fmset.h"

void getvtime();
void get4time();
extern int rack;

void getfmtime(unixtime,unixhs,fstime,fshs,formtime,formhs)
time_t *unixtime; /* computer time */
int    *unixhs;
time_t *fstime; /* field system time */
int    *fshs;
time_t *formtime; /* formatter time */
int    *formhs;
{
  if (nsem_test(NSEM_NAME) != 1) {
    printf("Field System not running - fmset aborting\n");
    rte_sleep(SLEEP_TIME);
    exit(0);
  }

   if(rack&VLBA)
	getvtime(unixtime,unixhs,fstime,fshs,formtime,formhs);
   else {
	get4time(unixtime,unixhs,fstime,fshs,formtime,formhs);
        if(*formhs > 4 || *formhs < 95) {
           if( *formhs < 92)
             rte_sleep((long) (92-*formhs));
	   get4time(unixtime,unixhs,fstime,fshs,formtime,formhs);
        }
   }
}
