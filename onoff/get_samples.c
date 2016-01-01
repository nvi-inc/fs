#include <stdio.h>
#include <string.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

extern struct fscom *shm_addr;

#include "sample_ds.h"

int get_samples(cont,ip,itpis,intg,rut,accum,accum2,ierr)
     long ip[5];
     int cont[MAX_ONOFF_DET],itpis[MAX_ONOFF_DET], intg, *ierr;
     float rut;
     struct sample *accum, *accum2;
{
  float tpi[MAX_DET],tpi2[MAX_DET],stm;
  struct sample sample, sample2;
  int i,j,it[6], iti[6], itim,non_station,kst1,kst2,station;

  if(brk_chk("onoff")!=0) {
    *ierr=-1;
    return -1;
  }

  non_station=FALSE;
  for(i=0;i<MAX_DET;i++)
    if(itpis[i]!=0) {
      non_station=TRUE;
      break;
    }

  kst1=itpis[MAX_DET+4];
  kst2=itpis[MAX_DET+5];
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
    }
    if(station) {
      if(kst1)
	sample.avg[MAX_DET+4]=shm_addr->user_dev1_value;
      if(kst2)
	sample.avg[MAX_DET+5]=shm_addr->user_dev2_value;
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












