#ifndef _STATS_INCLUDE
#define _STATS_INCLUDE

#include <math.h>

typedef struct statistics
       {
        double Min, Max;
        double SumX, SumXX;
        double Mean, Rms, StdDev;
        int    Nbr;
        int    Valid;
        char   Title[25];
       } STATS;

void StatsInit(  STATS *Stats , char *Title );
int  StatsAdd(   STATS *Stats , double Data );
void StatsReset( STATS *Stats );
int  StatsSolve( STATS *Stats );

#endif
