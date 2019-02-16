#include <sys/types.h>
#include <sys/times.h>
#include <time.h>

void fc_rte_fixt__(poClock,plCentiSec)
time_t *poClock;
int *plCentiSec;
{
     void rte_fixt();

     rte_fixt(poClock,plCentiSec);

     return;
}
