#include "../include/params.h"

#include "sample_ds.h"

void inc_accum(itpis,accum,sample)
int itpis[MAX_ONOFF_DET];
struct sample *accum, *sample;
{
  int j;
  double t;

  t= ++accum->count;

  /* recursive mean for time value */

  accum->stm=accum->stm*(t-1)/t+sample->stm/t;

  for(j=0;j<MAX_ONOFF_DET;j++)
    if(itpis[j]!=0) {
  /* recursive mean for samples */
      accum->avg[j]=accum->avg[j]*(t-1)/t+sample->avg[j]/t;
  /* recursive mean sqaure scatter for samples */
      if(accum->count > 1)
	accum->sig[j]=accum->sig[j]*(t-1)/t+
	  (sample->avg[j]-accum->avg[j])*(sample->avg[j]-accum->avg[j])/(t-1);
    }
}
