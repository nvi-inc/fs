/*
 * just returns ibcnt value for error processing
 */
#include <memory.h>

#ifdef CONFIG_GPIB
#include <ib.h>
#include <ibP.h>
#endif

void get_ibcnt__(ibret)
unsigned int *ibret;
{
#ifdef CONFIG_GPIB
  *ibret = ibcnt;
#else
  *ibret = 0;
#endif
  return;
}
