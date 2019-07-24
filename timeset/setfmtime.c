/* setfmtime.c - set formatter time */

#include <sys/types.h>   /* data type definition header file */
#include "../include/params.h"

void setvtime();
void set4time();

extern int rack;

void setfmtime(formtime,delta)
time_t formtime;
int delta;
{

if (rack & VLBA)
	setvtime((time_t) (formtime + delta));
else
	set4time(formtime,delta);

}
