#include <math.h>

#include "../include/params.h"

#include "sample_ds.h"

void red_accum(itpis,accum)
int itpis[MAX_ONOFF_DET];
struct sample *accum;
{
  int j;
  double drdrm1;

  if(accum->count>1) {
    drdrm1=((double) accum->count)/((double) (accum->count-1));
    for(j=0;j<MAX_ONOFF_DET;j++) {
      if(itpis[j]!=0) {
	double num;
	num=accum->sig[j]-accum->avg[j]*accum->avg[j];
	if(num <0.0) 
	  accum->sig[j]=0.0;
	else
	  accum->sig[j]=
	    sqrt(fabs(accum->sig[j]-accum->avg[j]*accum->avg[j])*drdrm1)
	    /sqrt((double) (accum->count-1));
      }
    }
  } else {
    for(j=0;j<MAX_ONOFF_DET;j++) {
      if(itpis[j]!=0)
	accum->sig[j]=0.33;
    }
  }
}

