#include <sys/types.h>
#include <sys/times.h>
#include <time.h>

int fc_rte_sett__( poFmClock, piFmHs, plCentiSec, pcMode, iLenMode)
time_t *poFmClock;
int *piFmHs;
int *plCentiSec;
char *pcMode;
int iLenMode;
{
   int rte_sett();

   return rte_sett(*poFmClock, *piFmHs, *plCentiSec, pcMode);
}
