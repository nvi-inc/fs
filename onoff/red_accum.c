#include <math.h>

#include "../include/params.h"

#include "sample_ds.h"

void red_accum(itpis,accum)
int itpis[MAX_ONOFF_DET];
struct sample *accum;
{
  int j;

  /* average is already in final form */

  /* calculate sigma of the average from data Mean-square scatter */

  if(accum->count>1) {
    for(j=0;j<MAX_ONOFF_DET;j++)
      if(itpis[j]!=0) 
	accum->sig[j]=sqrt(accum->sig[j]/(accum->count-1));
  } else { /* for this useless case, assume error is 0.33% */
    for(j=0;j<MAX_ONOFF_DET;j++)
      if(itpis[j]!=0)
	accum->sig[j]=fabs(accum->avg[j])*0.0033;
  }
}

