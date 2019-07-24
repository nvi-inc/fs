#include <ieeefp.h>

void rte_fpmask()  /* disable exceptions */
{
    fp_except mask;

    mask=0;
    mask=fpsetmask(mask);
}
