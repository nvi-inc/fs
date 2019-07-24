/* getfmtime.c - get formatter time */

#include <sys/types.h>   /* data type definition header file */
#include "../include/params.h"

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
   if(rack&VLBA)
	getvtime(unixtime,unixhs,fstime,fshs,formtime,formhs);
   else
	get4time(unixtime,unixhs,fstime,fshs,formtime,formhs);
}
