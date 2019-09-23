#include <math.h>

#include "../include/params.h"

#include "sample_ds.h"

void red_accum(itpis,accum)
int itpis[MAX_ONOFF_DET];
struct sample *accum;
{
  int j;
  double drdrm1;

/* average is already in final form */

/* calculate sigma as the average of squares minus square of average */

  if(accum->count>1) {
    drdrm1=((double) accum->count)/((double) (accum->count-1));
    for(j=0;j<MAX_ONOFF_DET;j++) {
      if(itpis[j]!=0) {
	double num;
	num=accum->sig[j]-accum->avg[j]*accum->avg[j];
	if(num <=0.0) 
	  accum->sig[j]=0.0;
	else
	  accum->sig[j]= sqrt(fabs(num)*drdrm1);
      }
    }
  } else {
/* only one point so assume sigma is from RMS of +/-0.5% */
    for(j=0;j<MAX_ONOFF_DET;j++) {
      if(itpis[j]!=0)
       accum->sig[j]=fabs(accum->avg[j])*0.0033;
    }
  }
}

