#include <signal.h>
#include <math.h>
#include <stdio.h>

#include "../include/dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

extern struct fscom *shm_addr;

#include "sample_ds.h"

int onsor(nwait,ierr)
     int nwait,*ierr;
{

  int it[6];
  double tim,tim2;

  rte_time(it,it+5);
  tim=it[3]*3600.0+it[2]*60.0+it[1]+((double)it[0])/100.;

  rte_time(it,it+5);
  tim2=it[3]*3600.0+it[2]*60.0+it[1]+((double)it[0])/100.;
  if(tim2<tim)
    tim2+=86400.0;

  while(tim+nwait>tim2) {
    if(antcn(5,ierr))
      return -1;

    if(shm_addr->ionsor!=0)
      return 0;

    rte_time(it,it+5);
    tim2=it[3]*3600.0+it[2]*60.0+it[1]+((double)it[0])/100.;
    if(tim2<tim)
      tim2+=86400.0;
  }

  *ierr=-20;
  return -1;
}
