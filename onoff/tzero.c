#include <stdio.h>
#include <string.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

extern struct fscom *shm_addr;

#include "sample_ds.h"

int tzero(cont,ip,onoff,rut,accum,ierr)
     int cont[MAX_ONOFF_DET];
     int ip[5];
     struct onoff_cmd *onoff;
     float rut;
     struct sample *accum;
     int *ierr;
{
  int iclass, nrec, i, ifc[4], ierr2;
  short int buf2[80];
  struct req_buf buffer;
  struct req_rec request;
  struct res_buf buff_res;
  struct res_rec response;
  int atten[4], kst1, kst2, kst1z, kst2z;
  struct sample acdum;

  ifc[0]=ifc[1]=ifc[2]=ifc[3]=FALSE;
  ierr2=0;

  kst1=onoff->itpis[MAX_GLOBAL_DET+4];
  if(kst1)
    kst1z=shm_addr->user_device.zero[4];
  kst2=onoff->itpis[MAX_GLOBAL_DET+5];
  if(kst2)
    kst2z=shm_addr->user_device.zero[5];

  if(shm_addr->equip.rack==MK3||shm_addr->equip.rack==MK4||
     shm_addr->equip.rack==LBA4||shm_addr->equip.rack==VLBA||
     shm_addr->equip.rack==VLBA4) {
	  for(i=0;i<MAX_GLOBAL_DET;i++)
		  if(onoff->itpis[i]!=0)
			  ifc[onoff->devices[i].ifchain-1]=TRUE;
  }

  if((kst1 && kst1z)||(kst2 && kst2z))
    scmds("sigoffnf");

  if(shm_addr->equip.rack==MK3||shm_addr->equip.rack==MK4||
     shm_addr->equip.rack==LBA4) {
    iclass=0;
    nrec=0;
    buf2[0]=0;
    if(ifc[0]||ifc[1]) {
      char temp[3];
      memcpy(buf2+1,"if",2);
      memcpy(buf2+2,"00003F3F",8);
      if(shm_addr->inp2if!=0)
	memcpy(((char *)(buf2+2))+2,"8",1);
      if(shm_addr->inp1if!=0)
	memcpy(((char *)(buf2+2))+3,"8",1);
      if(!ifc[1]) {
	snprintf(temp,sizeof(temp),"%2.2X",(shm_addr->iat2if)&0x3F);
	memcpy(((char *)(buf2+2))+4,temp,2);
      }
      if(!ifc[0]) {
	snprintf(temp,sizeof(temp),"%2.2X",(shm_addr->iat1if)&0x3F);
	memcpy(((char *)(buf2+2))+6,temp,2);
      }
      cls_snd(&iclass,buf2,12,0,0); nrec++;
    }
    if(ifc[2]) {
      memcpy(buf2+1,"i3",2);
      memcpy(buf2+2,"00000F3F",8);
      if(shm_addr->ipcalif3==0)
	memcpy(((char *)(buf2+2))+4,"2",1);
      sprintf(((char *)(buf2+2))+5,"%1.1X",0xF
	      &((2-shm_addr->iswif3_fs[0])+
		(2-shm_addr->iswif3_fs[1])*2+
		(2-shm_addr->iswif3_fs[2])*4+
		(2-shm_addr->iswif3_fs[3])*8));
      sprintf(((char *)(buf2+2))+6,"%2.2X",0x7F
	      &(((2-shm_addr->imixif3)<<6)+0x3F));
      cls_snd(&iclass,buf2,12,0,0); nrec++;
    }

    if(matcn(ip,iclass,nrec,&ierr2)) {
      goto restore;
    }
    if(ip[1]!=0) {
      cls_clr(ip[0]);
    }
  } else if(shm_addr->equip.rack==VLBA||shm_addr->equip.rack==VLBA4) {
    ini_req(&buffer);
    request.type=0;
    request.addr=0x01;

    if (ifc[0]||ifc[1]) {
      memcpy(request.device,"ia",2);             /* set 'ia' atten */

      atten[0]=shm_addr->dist[0].atten[0];
      if(ifc[0]) {
        shm_addr->dist[0].atten[ 0]=1;
      }
      atten[1]=shm_addr->dist[0].atten[1];
      if(ifc[1]) {
        shm_addr->dist[0].atten[ 1]=1;
      }
      dist01mc(&request.data,&shm_addr->dist[0]);
      add_req(&buffer,&request);     
    }
    
    if (ifc[2]||ifc[3]) {
      memcpy(request.device,"ic",2);             /* set 'ic' atten */
      atten[2]=shm_addr->dist[1].atten[0];
      if (ifc[2])  {
        shm_addr->dist[1].atten[ 0]=1;
      }
      atten[3]=shm_addr->dist[1].atten[1];
      if (ifc[3])  {
        shm_addr->dist[1].atten[ 1]=1;
      }
      dist01mc(&request.data,&shm_addr->dist[1]);
      add_req(&buffer,&request);     
    }
    
    end_req(ip,&buffer);
    skd_run("mcbcn",'w',ip);
    skd_par(ip);
    if(ip[2]<0) {
      cls_clr(ip[0]);
      logita(NULL,ip[2],ip+3,ip+4);
      ierr2=-12;
      goto restore;
    }

    opn_res(&buff_res,ip);
    if (ifc[0]||ifc[1])
      get_res(&response,&buff_res);
    if (ifc[2]||ifc[3])
      get_res(&response,&buff_res);

    if(response.state == -1) {
      clr_res(&buff_res);
      ierr2=-13;
      goto restore;
    }
    clr_res(&buff_res);
  } else if(shm_addr->equip.rack==LBA  || shm_addr->equip.rack==DBBC  ||
	    shm_addr->equip.rack==RDBE || shm_addr->equip.rack==DBBC3) {
    /* digital detetector - assume tpzero=0 */
  }

  if(shm_addr->equip.rack==MK3||
     shm_addr->equip.rack==MK4||
     shm_addr->equip.rack==LBA4||
     shm_addr->equip.rack==VLBA||
     shm_addr->equip.rack==VLBA4||
     (kst1 && kst1z) || (kst2 && kst2z)) {
    int itpis[MAX_ONOFF_DET]; /* if it is not a digital detector, sample zero */

    for(i=0;i<MAX_ONOFF_DET;i++)
      itpis[i]=onoff->itpis[i];
    if(shm_addr->equip.rack!=MK3&&
       shm_addr->equip.rack!=MK4&&
       shm_addr->equip.rack!=LBA4&&
       shm_addr->equip.rack!=VLBA&&
       shm_addr->equip.rack!=VLBA4) /* doctor up a local copy */
      for(i=0;i<MAX_GLOBAL_DET;i++)
	itpis[i]=0;

    get_samples(cont,ip,itpis,onoff->intp,rut,accum,&acdum,&ierr2);

  }
  if(shm_addr->equip.rack==LBA) {

    /* digital detetector - assume tpzero=0 */
    for (i=0; i<2*shm_addr->n_das; i++) 
      if (onoff->itpis[i]) {
        accum->avg[i]=0.0;
        accum->sig[i]=0.0;
      }
    accum->count=1;

  } else if(shm_addr->equip.rack==DBBC &&
	    (shm_addr->equip.rack_type == DBBC_DDC ||
	     shm_addr->equip.rack_type == DBBC_DDC_FILA10G)) {
    
    /* digital detetector - assume tpzero=0 */
    for (i=0; i<MAX_DBBC_DET; i++) 
      if (onoff->itpis[i]) {
        accum->avg[i]=0.0;
        accum->sig[i]=0.0;
      }
    accum->count=1;
  } else if(shm_addr->equip.rack==DBBC &&
	    (shm_addr->equip.rack_type == DBBC_PFB ||
	     shm_addr->equip.rack_type == DBBC_PFB_FILA10G)) {
    
    /* digital detetector - assume tpzero=0 */
    for (i=0; i<MAX_DBBC_PFB_DET; i++) 
      if (onoff->itpis[i]) {
        accum->avg[i]=0.0;
        accum->sig[i]=0.0;
      }
    accum->count=1;

  } else if(shm_addr->equip.rack==RDBE) {
    /* digital detetector - assume tpzero=0 */
    for (i=0; i<MAX_RDBE_DET; i++) 
      if (onoff->itpis[i]) {
        accum->avg[i]=0.0;
        accum->sig[i]=0.0;
      }
    accum->count=1;

  } else if(shm_addr->equip.rack==DBBC3) {

    /* digital detetector - assume tpzero=0 */
    for (i=0; i<MAX_DBBC3_DET; i++) 
      if (onoff->itpis[i]) {
        accum->avg[i]=0.0;
        accum->sig[i]=0.0;
      }
  }

  if (kst1 && !kst1z) {
    accum->avg[MAX_GLOBAL_DET+4] = 0.0;
    accum->sig[MAX_GLOBAL_DET+4] = 0.0;
    accum->count=1;
    
  }
  if (kst2 && !kst2z) {
    accum->avg[MAX_GLOBAL_DET+5] = 0.0;
    accum->sig[MAX_GLOBAL_DET+5] = 0.0;
    accum->count=1;
  }

 restore:
  if((kst1 && kst1z)||(kst2 && kst2z))
    scmds("sigonnf");

  if(shm_addr->equip.rack==MK3||shm_addr->equip.rack==MK4||shm_addr->equip.rack==LBA4) {
    iclass=0;
    nrec=0;
    buf2[0]=0;
    if(ifc[0]||ifc[1]) {
      memcpy(buf2+1,"if",2);
      memcpy(buf2+2,"00003F3F",8);
      if(shm_addr->inp2if!=0)
	memcpy(((char *)(buf2+2))+2,"8",1);
      if(shm_addr->inp1if!=0)
	memcpy(((char *)(buf2+2))+3,"8",1);
      sprintf(((char *)(buf2+2))+4,"%2.2X",(shm_addr->iat2if)&0x3F);
      sprintf(((char *)(buf2+2))+6,"%2.2X",(shm_addr->iat1if)&0x3F);
      cls_snd(&iclass,buf2,12,0,0); nrec++;
    }
    if(ifc[2]) {
      memcpy(buf2+1,"i3",2);
      memcpy(buf2+2,"00000F3F",8);
      if(shm_addr->ipcalif3==0)
	memcpy(((char *)(buf2+2))+4,"2",1);
      sprintf(((char *)(buf2+2))+5,"%1.1X",0xF
	      &((2-shm_addr->iswif3_fs[0])+
		(2-shm_addr->iswif3_fs[1])*2+
		(2-shm_addr->iswif3_fs[2])*4+
		(2-shm_addr->iswif3_fs[3])*8));
      sprintf(((char *)(buf2+2))+6,"%2.2X",0x7F
	      &(((2-shm_addr->imixif3)<<6)+shm_addr->iat3if));
      cls_snd(&iclass,buf2,12,0,0); nrec++;
    }

    if(matcn(ip,iclass,nrec,ierr))
      goto failed;

    if(ip[1]!=0) {
      cls_clr(ip[0]);
    }
  } else if(shm_addr->equip.rack==VLBA||shm_addr->equip.rack==VLBA4) {
    ini_req(&buffer);
    request.type=0;
    request.addr=0x01;

    if(ifc[0]||ifc[1]) {
      memcpy(request.device,"ia",2);             /* set 'ia' atten */
      shm_addr->dist[0].atten[ 0]=atten[0];
      shm_addr->dist[0].atten[ 1]=atten[1];
      dist01mc(&request.data,&shm_addr->dist[0]);
      add_req(&buffer,&request);     
    }

    if(ifc[2]||ifc[3]) {
      memcpy(request.device,"ic",2);             /* set 'ic' atten */
      shm_addr->dist[1].atten[ 0]=atten[2];
      shm_addr->dist[1].atten[ 1]=atten[3];
      dist01mc(&request.data,&shm_addr->dist[1]);
      add_req(&buffer,&request);     
    }
    
    end_req(ip,&buffer);
    skd_run("mcbcn",'w',ip);
    skd_par(ip);
    if(ip[2]<0) {
      if(ip[1]!=0)
	cls_clr(ip[0]);
      logita(NULL,ip[2],ip+3,ip+4);
      *ierr=-15;
      goto failed;
    }

    opn_res(&buff_res,ip);
    if(ifc[0]||ifc[1])
      get_res(&response,&buff_res);
    if(ifc[2]||ifc[3])
      get_res(&response,&buff_res);

    if(response.state == -1) {
      clr_res(&buff_res);
      *ierr=-14;
      goto failed;
    }
    clr_res(&buff_res);
  } else if(shm_addr->equip.rack==LBA  ||shm_addr->equip.rack==DBBC  ||
	    shm_addr->equip.rack==RDBE ||shm_addr->equip.rack==DBBC3) {
    /* digital detetector - assume tpzero=0 */
  }

  if(ierr2!=0) {
    *ierr=ierr2;
    return -1;
  }
  return 0;

 failed:
  if(ierr2!=0) {
    ip[0]=0;
    ip[1]=0;
    ip[2]=ierr2;
    memcpy(ip+3,"nf",2);
    ip[4]=0;
    logita(NULL,ip[2],ip+3,ip+4);
  }
  ip[0]=0;
  ip[1]=0;
  ip[2]=*ierr;
  memcpy(ip+3,"nf",2);
  ip[4]=0;
  logita(NULL,ip[2],ip+3,ip+4);

  *ierr=-6;
  return -1;
}
