#include <stdio.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

extern struct fscom *shm_addr;

#include "sample_ds.h"

int get_samples(ip,itpis,intg,rut,accum,ierr)
     long ip[5];
     int itpis[MAX_DET], intg, *ierr;
     float rut;
     struct sample *accum;
{
  float tpi[MAX_DET],stm;
     struct sample sample;
  int i,j,it[6], iti[6], itim;

  if(brk_chk("onoff")!=0) {
    *ierr=-1;
    return -1;
  }

  rte_sleep(101);
  rte_time(iti,iti+5);

  ini_accum(itpis,accum);
  for(i=0;i<intg;i++) {
    if(brk_chk("onoff")!=0) {
      *ierr=-1;
      return -1;
    }
    rte_time(it,it+5);
    itim=(it[1]-iti[1])*100+it[0]-iti[0]+101;
    if (itim<0)
      itim=itim+6000;
    if(itim>0)
      rte_sleep(itim);

    if(shm_addr->equip.rack==MK3||shm_addr->equip.rack==MK4) {
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
    }

    rte_time(iti,iti+5);
    stm=iti[3]*3600.0+iti[2]*60.0+iti[1]+((double) iti[0])/100.;
    if(stm < rut)
      stm+=86400.0;

    if(shm_addr->equip.rack==MK3||shm_addr->equip.rack==MK4) {
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
    }
      sample.stm=stm-rut;

    inc_accum(itpis,accum,&sample);
  }
  
  red_accum(itpis,accum);
  return 0;

}












