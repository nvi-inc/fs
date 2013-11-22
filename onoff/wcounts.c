#include <math.h>
#include <stdio.h>
#include <string.h>

#include "../include/dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"

#include "sample_ds.h"

void wcounts(label,azoff,eloff,onoff,accum, rack)
     char *label;
     double azoff,eloff;
     struct onoff_cmd *onoff;
     struct sample *accum;
     int rack;
{
  char buff[256];
  int i, kfirst;

  buff[0]=0;

  kfirst=TRUE;

  for(i=0;i<MAX_ONOFF_DET;i++) {
    if(onoff->itpis[i]==0)
      continue;

    if(
       (rack!=RDBE && ((onoff->intp==1 &&strlen(buff)>70)
		       ||(onoff->intp!=1 &&strlen(buff)>61))) ||
       (rack==RDBE && ((onoff->intp==1 &&strlen(buff)>68)
		       ||(onoff->intp!=1 &&strlen(buff)>59)))
       ){
      logit(buff,0,NULL);
      buff[0]=0;
    }
    
    if(strlen(buff)==0) {
      strcpy(buff,label);
	strcat(buff," ");
	sprintf(buff+strlen(buff),"%7.1lf %9.5lf %9.5lf",
		accum->stm,azoff*RAD2DEG,eloff*RAD2DEG);
      /*      if(kfirst) {
	strcat(buff," ");
	sprintf(buff+strlen(buff),"%7.1lf %9.5lf %9.5lf",
		accum->stm,azoff*RAD2DEG,eloff*RAD2DEG);
	kfirst=FALSE;
      }
      */
    }

    strcat(buff," ");
    buff[strlen(buff)+4]=0;
    memcpy(buff+strlen(buff),onoff->devices[i].lwhat,4);
    strcat(buff," ");
    if(onoff->intp==1) {
      if(rack!=RDBE)
	flt2str(buff,(float) accum->avg[i],-7,0);
      else
	dble2str(buff,       accum->avg[i],-9,0);
      buff[strlen(buff)-1]=0;
    } else {
      if(rack!=RDBE)
	flt2str(buff,(float) accum->avg[i],-8,1);
      else
	dble2str(buff,       accum->avg[i],-9,1);
      strcat(buff," ");
      if(rack!=RDBE)
	flt2str(buff,(float) accum->sig[i],-8,1);
      else
	dble2str(buff,       accum->sig[i],-9,1);
    }
  }
  if(strlen(buff)!=0)
    logit(buff,0,NULL);

}



