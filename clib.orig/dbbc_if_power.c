#include <math.h>
#include <string.h>
#include <stdio.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

double dbbc_if_power(unsigned counts, int como)
{
  double fact;
  if(como < 0 || como > 3)
    fact=1.0;  /*defensive, a bad value is really bad */
  else
    fact=shm_addr->dbbc_if_factors[como];

  //   printf(" como %d fact %f counts %u pow %f\n",
  //   como,fact,counts,65535*pow(10.0,(((int)counts)-65535)/fact));
  return 65535*pow(10.0,(((int)counts)-65535)/fact);
}
