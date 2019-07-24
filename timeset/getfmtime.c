/* getfmtime.c - get formatter time */

#include <sys/types.h>   /* data type definition header file */
#include "../include/params.h"

void getvtime();
void get4time();
extern int rack;

void getfmtime(unixtime,unixhs,formtime,formhs)
time_t *unixtime; /* system time received from mcbcn */
int    *unixhs;
time_t *formtime; /* formatter time received from mcbcn */
int    *formhs;
{
   if(rack&VLBA)
	getvtime(unixtime,unixhs,formtime,formhs);
   else
	get4time(unixtime,unixhs,formtime,formhs);
}
