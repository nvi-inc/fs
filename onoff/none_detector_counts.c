/*
 * Copyright (c) 2025 NVI, Inc.
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

int none_detector_counts(buff,sbuff,rut,label,intp,azoff,eloff)
  char *buff;
  int sbuff;
  float rut;
  char *label;
  int intp;
  double azoff, eloff;
{
  int k;
  int iti[6];
  float stm;

  rte_sleep(101);
  rte_time(iti,iti+5);
  stm=iti[3]*3600.0+iti[2]*60.0+iti[1]+((double) iti[0])/100.;
  if(stm < rut)
    stm+=86400.0;
  stm-=rut;
  stm+=(intp+1)*0.5;

  for (k=0;k<intp;k++) {
    rte_sleep(101);
    if(brk_chk("onoff")!=0) {
      return -1;
    }
  }
  strcpy(buff,label);
  strcat(buff," ");
  sprintf(buff+strlen(buff),"%7.1lf %9.5lf %9.5lf",
      stm,azoff*RAD2DEG,eloff*RAD2DEG);
  strcat(buff," ");
  buff[strlen(buff)+4]=0;
  memcpy(buff+strlen(buff),"none",4);
  strcat(buff," ");
  if(intp==1) {
    flt2str(buff,0.0,-7,0);
    buff[strlen(buff)-1]=0;
  } else {
    flt2str(buff,0.0,-8,1);
    strcat(buff," ");
    flt2str(buff,0.0,-8,1);
  }
  logit_nd(buff,0,NULL);
  return 0;
}
