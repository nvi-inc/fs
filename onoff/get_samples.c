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
#include <stdio.h>
#include <string.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

extern struct fscom *shm_addr;

#include "sample_ds.h"

int get_samples(cont,ip,itpis,intg,rut,accum,accum2,ierr)
     int ip[5];
     int cont[MAX_ONOFF_DET],itpis[MAX_ONOFF_DET], intg, *ierr;
     float rut;
     struct sample *accum, *accum2;
{
  float tpi[MAX_ONOFF_DET],tpi2[MAX_ONOFF_DET],stm;
  double dtpi[MAX_ONOFF_DET], dtpi2[MAX_ONOFF_DET];
  struct sample sample, sample2;
  int i,j,it[6], iti[6], itim,non_station,kst1,kst2,station;

  if(brk_chk("onoff")!=0) {
    *ierr=-1;
    return -1;
  }

  non_station=FALSE;
  for(i=0;i<MAX_GLOBAL_DET;i++)
    if(itpis[i]!=0) {
      non_station=TRUE;
      break;
    }

  kst1=itpis[MAX_GLOBAL_DET+4];
  kst2=itpis[MAX_GLOBAL_DET+5];
  station=kst1||kst2;
  
  if(non_station) {
    rte_sleep(101);
  }
  rte_time(iti,iti+5);

  ini_accum(itpis,accum);
  ini_accum(itpis,accum2);

  for(i=0;i<intg;i++) {
    if(brk_chk("onoff")!=0) {
      *ierr=-1;
      return -1;
    }
    if(non_station) {
      rte_time(it,it+5);
      itim=(it[1]-iti[1])*100+it[0]-iti[0]+101;
      if (itim<0)
	itim=itim+6000;
      if(itim>0)
	rte_sleep(itim);
    }

    if(shm_addr->equip.rack==MK3||shm_addr->equip.rack==MK4||shm_addr->equip.rack==LBA4) {
      if(tpi_mark(ip,itpis,ierr))
	return -1;
    } else if(shm_addr->equip.rack==VLBA||shm_addr->equip.rack==VLBA4) {
      tpi_vlba(ip,itpis,1);
      if(ip[2]<0) {
	if(ip[1]!=0)
	  cls_clr(ip[0]);
	logita(NULL,ip[2],ip+3,ip+4);
	*ierr=-16;
	return -1;
      }
    } else if(shm_addr->equip.rack==LBA) {
      tpi_lba(ip,itpis);
      if(ip[2]<0) {
	if(ip[1]!=0)
	  cls_clr(ip[0]);
	logita(NULL,ip[2],ip+3,ip+4);
	*ierr=-16;
	return -1;
      }
    } else if(shm_addr->equip.rack==DBBC &&
	      (shm_addr->equip.rack_type == DBBC_DDC ||
	       shm_addr->equip.rack_type == DBBC_DDC_FILA10G)) {
      tpi_dbbc(ip,itpis);
      if(ip[2]<0) {
	if(ip[1]!=0)
	  cls_clr(ip[0]);
	logita(NULL,ip[2],ip+3,ip+4);
	*ierr=-16;
	return -1;
      }
    } else if(shm_addr->equip.rack==DBBC &&
	      (shm_addr->equip.rack_type == DBBC_PFB ||
	       shm_addr->equip.rack_type == DBBC_PFB_FILA10G)) {
      tpi_dbbc_pfb(ip,itpis);
      if(ip[2]<0) {
	if(ip[1]!=0)
	  cls_clr(ip[0]);
	logita(NULL,ip[2],ip+3,ip+4);
	*ierr=-16;
	return -1;
      }
    } else if(shm_addr->equip.rack==DBBC3) {
      tpi_dbbc3(ip,itpis);
      if(ip[2]<0) {
        if(ip[1]!=0)
          cls_clr(ip[0]);
        logita(NULL,ip[2],ip+3,ip+4);
        *ierr=-16;
        return -1;
      }
    }

    if(station) {
      if(kst1)
	memcpy(shm_addr->user_dev1_name,"u5",2);
      else
	memcpy(shm_addr->user_dev1_name,"  ",2);
      if(kst2)
	memcpy(shm_addr->user_dev2_name,"u6",2);
      else
	memcpy(shm_addr->user_dev2_name,"  ",2);

      if(antcn(8,ierr))
	return -1;
    }

    rte_time(iti,iti+5);
    stm=iti[3]*3600.0+iti[2]*60.0+iti[1]+((double) iti[0])/100.;
    if(stm < rut)
      stm+=86400.0;

    if(shm_addr->equip.rack==MK3||shm_addr->equip.rack==MK4||shm_addr->equip.rack==LBA4) {
      tpget_mark(ip,itpis,tpi);
      for(j=0;j<17;j++)
	if(itpis[j]!=0) {
	  sample.avg[j]=tpi[14+j];
	}
    } else if(shm_addr->equip.rack==VLBA||shm_addr->equip.rack==VLBA4) {
      if(tpget_vlba(ip,itpis,ierr,tpi))
	 return -1;
      for(j=0;j<MAX_DET;j++)
	if(itpis[j]!=0) {
	  sample.avg[j]=tpi[j];
	}
    } else if(shm_addr->equip.rack==LBA) {
      if(tpget_lba(ip,itpis,ierr,tpi))
	 return -1;
      for(j=0;j<MAX_DET;j++)
	if(itpis[j]!=0) {
	  sample.avg[j]=tpi[j];
	}
    } else if(shm_addr->equip.rack==DBBC &&
	      (shm_addr->equip.rack_type == DBBC_DDC ||
	       shm_addr->equip.rack_type == DBBC_DDC_FILA10G)) {
      if(tpget_dbbc(cont,ip,itpis,ierr,tpi,tpi2))
	 return -1;
      for(j=0;j<MAX_DET;j++)
	if(itpis[j]!=0) {
	  sample.avg[j]=tpi[j];
	  sample2.avg[j]=tpi2[j];
	}
    } else if(shm_addr->equip.rack==DBBC &&
	      (shm_addr->equip.rack_type == DBBC_PFB ||
	       shm_addr->equip.rack_type == DBBC_PFB_FILA10G)) {
      if(tpget_dbbc_pfb(ip,itpis,dtpi,ierr))
	 return -1;
      for(j=0;j<MAX_DBBC_PFB_DET;j++)
	if(itpis[j]!=0) {
	  sample.avg[j]=dtpi[j];
	}
    } else if(shm_addr->equip.rack==RDBE) {
      if(tpget_rdbe(cont,ip,itpis,ierr,dtpi,dtpi2))
	return -1;
      for(j=0;j<MAX_RDBE_DET;j++)
	if(itpis[j]!=0) {
	  sample.avg[j]=dtpi[j];
	  sample2.avg[j]=dtpi2[j];
	}
    } else if(shm_addr->equip.rack==DBBC3) {
      if(tpget_dbbc3(cont,ip,itpis,ierr,tpi,tpi2))
	 return -1;
      for(j=0;j<MAX_DBBC3_DET;j++)
	if(itpis[j]!=0) {
	  sample.avg[j]=tpi[j];
	  sample2.avg[j]=tpi2[j];
	}
    }
    if(station) {
      if(kst1)
	sample.avg[MAX_GLOBAL_DET+4]=shm_addr->user_dev1_value;
      if(kst2)
	sample.avg[MAX_GLOBAL_DET+5]=shm_addr->user_dev2_value;
    }

    sample.stm=stm-rut;
    sample2.stm=stm-rut;

    inc_accum(itpis,accum,&sample);
    inc_accum(itpis,accum2,&sample2);
  }
  
  red_accum(itpis,accum);
  red_accum(itpis,accum2);
  return 0;

}












