#include "../include/params.h"

#include "sample_ds.h"

void ini_accum(itpis,accum)
int itpis[MAX_ONOFF_DET];
struct sample *accum;
{
  int i;

  accum->count=0;
  accum->stm=0.0;

  for(i=0;i<MAX_ONOFF_DET;i++)
    if(itpis[i]!=0) {
      accum->avg[i]=0.0;
      accum->sig[i]=0.0;
    }
}
