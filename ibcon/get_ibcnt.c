/*
 * just returns ibcnt value for error processing
 */
#include <memory.h>
#include "sys/ugpib.h"

void get_ibcnt_(ibret)
unsigned int *ibret;
{
  *ibret = ibcnt;
  return;
}
