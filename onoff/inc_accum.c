#include "../include/params.h"

#include "sample_ds.h"

void inc_accum(itpis,accum,sample)
int itpis[MAX_DET];
struct sample *accum, *sample;
{
  int j;
  double dri,dim1;

  dri=1.0/(double) ++(accum->count);
  dim1=accum->count-1;

  accum->stm=(accum->stm*dim1+sample->stm)*dri;

  for(j=0;j<MAX_DET;j++)
    if(itpis[j]!=0) {
      accum->avg[j]=(accum->avg[j]*dim1+sample->avg[j])*dri;
      accum->sig[j]=(accum->sig[j]*dim1+sample->avg[j]*sample->avg[j])*dri;
    }
}

