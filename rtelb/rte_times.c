/* replacement for system times() that does not fail when times()
 * overflows its type, uses rte_ticks to remove initial offset */

#include <sys/times.h>

clock_t rte_times(struct tms *buf)
{
  int lRawTicks;
  
  rte_ticks(&lRawTicks);
  return lRawTicks;
}
