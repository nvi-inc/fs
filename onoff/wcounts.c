/*
 * Copyright (c) 2020 NVI, Inc.
 *
 * This file is part of VLBI Field System
 * (see http://github.com/nvi-inc/fs).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
#include <math.h>
#include <stdio.h>
#include <string.h>

#include "../include/dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

extern struct fscom *shm_addr;

#include "sample_ds.h"

void wcounts(label,azoff,eloff,onoff,accum)
     char *label;
     double azoff,eloff;
     struct onoff_cmd *onoff;
     struct sample *accum;
{
  char buff[256];
  int i, kfirst;
  int dbbc2_pfb;
  int rack;

  rack=shm_addr->equip.rack;

  dbbc2_pfb =shm_addr->equip.rack==DBBC && 
    (shm_addr->equip.rack_type == DBBC_PFB ||
     shm_addr->equip.rack_type == DBBC_PFB_FILA10G);
  buff[0]=0;

  kfirst=TRUE;

  for(i=0;i<MAX_ONOFF_DET;i++) {
    if(onoff->itpis[i]==0)
      continue;

    if(
       (rack==RDBE && ((onoff->intp==1 &&strlen(buff)>68)
		       ||(onoff->intp!=1 &&strlen(buff)>59))) ||
       (dbbc2_pfb && 
        ((onoff->intp==1 &&strlen(buff)>68)
            ||(onoff->intp!=1 &&strlen(buff)>59))) ||
       ((onoff->intp==1 &&strlen(buff)>70)
		       ||(onoff->intp!=1 &&strlen(buff)>61))
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
      if(rack==RDBE) {
	dble2str(buff,       accum->avg[i],-9,0);
      buff[strlen(buff)-1]=0;
      } else if(dbbc2_pfb) {
	dble2str(buff,       accum->avg[i],-8,3);
      } else {
	flt2str(buff,(float) accum->avg[i],-7,0);
      buff[strlen(buff)-1]=0;
      }
    } else {
      if(rack==RDBE) {
	dble2str(buff,       accum->avg[i],-9,1);
	strcat(buff," ");
	dble2str(buff,       accum->sig[i],-9,1);
      } else if(dbbc2_pfb) {
	dble2str(buff,       accum->avg[i],-9,4);
	strcat(buff," ");
	dble2str(buff,       accum->sig[i],-9,4);
      } else {
	flt2str(buff,(float) accum->avg[i],-8,1);
	strcat(buff," ");
	flt2str(buff,(float) accum->sig[i],-8,1);
      }
    }
  }
  if(strlen(buff)!=0)
    logit(buff,0,NULL);

}



