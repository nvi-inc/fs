#include <math.h>
#include <stdio.h>

#include "../include/dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"

#include "sample_ds.h"

void wcounts(label,azoff,eloff,onoff,accum)
     char *label;
     double azoff,eloff;
     struct onoff_cmd *onoff;
     struct sample *accum;
{
  char buff[256];
  int i, kfirst;

  buff[0]=0;

  kfirst=TRUE;

  for(i=0;i<MAX_ONOFF_DET;i++) {
    if(onoff->itpis[i]==0)
      continue;

    if((onoff->intp==1 &&strlen(buff)>70)
       ||(onoff->intp!=1 &&strlen(buff)>61)
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
    buff[strlen(buff)+2]=0;
    memcpy(buff+strlen(buff),onoff->devices[i].lwhat,2);
    strcat(buff," ");
    if(onoff->intp==1) {
      flt2str(buff,(float) accum->avg[i],-7,0);
      buff[strlen(buff)-1]=0;
    } else {
      flt2str(buff,(float) accum->avg[i],-8,1);
      strcat(buff," ");
      flt2str(buff,(float) accum->sig[i],-8,1);
    }
  }
  if(strlen(buff)!=0)
    logit(buff,0,NULL);

}



