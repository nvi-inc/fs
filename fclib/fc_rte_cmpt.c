#include <sys/types.h>
#include <sys/times.h>
#include <time.h>

void fc_rte_cmpt__(poClock,plCentiSec)
time_t *poClock;
int *plCentiSec;
{
     void rte_cmpt();

     rte_cmpt(poClock,plCentiSec);

     return;
}
