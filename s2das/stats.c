#include "stats.h"
#include <float.h>

void StatsInit( STATS *Stats , char *Title )
{
 StatsReset( Stats );
 strcpy( Stats->Title , Title );
}
void StatsReset( STATS *Stats )
{
 Stats->Valid = 0;
 Stats->Min   =  DBL_MAX;
 Stats->Max   = -DBL_MAX;
 Stats->SumX  = Stats->SumXX = 0.0;
 Stats->Mean  = Stats->Rms = Stats->StdDev = 0.0;
 Stats->Nbr   = 0;
 Stats->Valid = 1;
}
int StatsAdd( STATS *Stats , double Data )
{
 Stats->Valid = 0;

 if( Data < Stats->Min ) Stats->Min = Data;
 if( Data > Stats->Max ) Stats->Max = Data;
 Stats->SumX  += Data;
 Stats->SumXX += Data * Data;
 Stats->Nbr++;

 Stats->Valid = 1;
 return Stats->Nbr;
}
int StatsSolve( STATS *Stats )
{
 if( Stats->Nbr < 1 ) return 0;

 Stats->Mean = Stats->SumX / Stats->Nbr;
 if( Stats->SumXX > 0.0 )
    Stats->Rms = sqrt( Stats->SumXX / Stats->Nbr );
 if( Stats->Nbr > 1 )
   {
    Stats->StdDev  = Stats->SumX;
    Stats->StdDev *= Stats->StdDev;
    Stats->StdDev /= Stats->Nbr;
    Stats->StdDev  = Stats->SumXX - Stats->StdDev;
    Stats->StdDev /= Stats->Nbr - 1;

    Stats->StdDev = ( Stats->StdDev > 0.0 ) ? sqrt( Stats->StdDev ) : 0.0;
   }
 return 1;
}


