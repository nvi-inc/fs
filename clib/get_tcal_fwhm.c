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
#include <sys/types.h>
#include <math.h>
#include <string.h>

#include "../include/dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

float flux_val();

static float bw[ ]={0.0,0.125,0.250,0.50,1.0,2.0,4.0}; 
static float bw4[ ]={0.0,0.125,16.0,0.50,8.0,2.0,4.0};
static float bw_vlba[ ]={0.0625,0.125,0.25,0.5,1.0,2.0,4.0,8.0,16.0, 32.0};
static float bw_lba[ ]={0.0625,0.125,0.25,0.5,1.0,2.0,4.0,8.0,16.0,32.0,64.0};
static float bw_dbbc[ ]={1.0,2.0,4.0,8.0,16.0,32.0};
static float bw_dbbc3[ ]={2.0,4.0,8.0,16.0,32.0};
static char *lwhat[ ]={
  "1l","2l","3l","4l","5l","6l","7l","8l","9l","al","bl","cl","dl","el","fl","gl",
  "1u","2u","3u","4u","5u","6u","7u","8u","9u","au","bu","cu","du","eu","fu","gu",
"ia","ib","ic","id"};
static char *lwhatm[ ]={
"v1","v2","v3","v4","v5","v6","v7","v8","v9","va","vb","vc","vd","ve",
"i1","i2","i3"};
static char *lwhatl[ ]={
"p1","p2","p3","p4","p5","p6","p7","p8","p9","pa","pb","pc","pd","pe","pf"};
static char ch[ ]={"abcd"};
static char *lwhati[ ]={
  "ifa","ifb","ifc","ifd"};
static char *lwhat3if[ ]={
  "ia","ib","ic","id","ie","if","ig","ih"};

static int zone_table[] = {2, 1, 4,3}; /* DBBC filter Nyquist zones */
static char lets[]="abcdefghijklm";

void get_tcal_fwhm(device,tcal,fwhm,epoch,flux,corr,ssize,ierr)
char device[4];
float *tcal;
float *fwhm;
float epoch;
float *flux;
float *corr;
float *ssize;
int *ierr;
{
  int ifchain,i,j;
  double center;
  float vcf,vcbw,dpfu,gain;
  char lsorna[10];
  int det;
  int k, filter, zone;
  char idevice[4];

  ifchain=0;
  *ierr=0;

  if(strncmp(device,"u",1) == 0) {
    if(strncmp(device,"u5",2) == 0)
      ifchain=MAX_LO+5;
    else if(strncmp(device,"u6",2) == 0)
      ifchain=MAX_LO+6;

    if(ifchain!=0) {
    center=shm_addr->user_device.center[ifchain-(1+MAX_LO)];
    switch(shm_addr->user_device.sideband[ifchain-(1+MAX_LO)]) {
    case 1:
      center=shm_addr->user_device.lo[ifchain-(1+MAX_LO)]+center;
      break;
    case 2:
      center=shm_addr->user_device.lo[ifchain-(1+MAX_LO)]-center;
      break;
    default:
      *ierr=-302;
	goto error;
	break;
      }
    } else {
      *ierr=-309;
      goto error;
    }
  } else if(shm_addr->equip.rack==MK3||shm_addr->equip.rack==MK4
	    ||shm_addr->equip.rack==LBA4) {
    for(i=0;i<sizeof(lwhatm)/sizeof(char *);i++) {
      if(strncmp(device,lwhatm[i],2)==0) {
	if(i<14) {
	  ifchain=abs(shm_addr->ifp2vc[i]);
	  if(ifchain<1||ifchain>3)
		ifchain=0;
	  if(ifchain!=0) {
	    vcf=shm_addr->freqvc[i];
	    if(shm_addr->ibwvc[i]==0)
	      vcbw=shm_addr->extbwvc[i];
	    else if(shm_addr->equip.rack==MK3)
	      vcbw=bw[shm_addr->ibwvc[i]];
	    else if(shm_addr->equip.rack==MK4)
	      vcbw=bw4[shm_addr->ibwvc[i]];
	    switch (shm_addr->ITPIVC[i]&0x7) {
	    case 0: /* dual */
	      vcf=vcf;
	      break;
	    case 1: /* lsb */
	      vcf=vcf-vcbw*0.5;
	      break;
	    case 2: /* usb */
	      vcf=vcf+vcbw*0.5;
	      break;
	    default:
	      *ierr=-301;
	      goto error;
	      break;
	    }
	    switch(shm_addr->lo.sideband[ifchain-1]) {
	    case 1:
	      center=shm_addr->lo.lo[ifchain-1]+vcf;
	      break;
	    case 2:
	      center=shm_addr->lo.lo[ifchain-1]-vcf;
	      break;
	    default:
	      *ierr=-302;
	      goto error;
	      break;
	    }
	  } else {
	    *ierr=-303;
	    goto error;
	  }
	} else if(14 == i || i == 15) {
	  ifchain=i-13;
	  switch (shm_addr->lo.sideband[ifchain-1]) {
	      case 1:
		center=shm_addr->lo.lo[ifchain-1]+(500.+100.)*0.5;
		break;
	      case 2:
		center=shm_addr->lo.lo[ifchain-1]-(500.+100.)*0.5;
		break;
	      default:
		*ierr=-302;
		goto error;
		break;
	  }
	} else if(i == 16) {
	  float upper;
	  ifchain=i-13;
	  if(shm_addr->imixif3==1)
	    upper=400.0;
	  else
	    upper=500.0;
	  switch (shm_addr->lo.sideband[ifchain-1]) {
	  case 1:
	    center=shm_addr->lo.lo[ifchain-1]+(upper+100.)*0.5;
	    break;
	  case 2:
	    center=shm_addr->lo.lo[ifchain-1]-(upper+100.)*0.5;
	    break;
	  default:
	    *ierr=-302;
	    goto error;
	    break;
	  }
	}
	break;
      }
    }
  } else if(shm_addr->equip.rack==VLBA||shm_addr->equip.rack==VLBA4) {
    for(i=0;i<sizeof(lwhat)/sizeof(char *);i++) {
      if(strncmp(device,lwhat[i],2)==0) {
	if(i<2*MAX_BBC) {
	  ifchain=shm_addr->bbc[i%MAX_BBC].source+1;
	  if(ifchain<1||ifchain>4)
	    ifchain=0;
	  if(ifchain!=0) {
	    int bbc2freq();
	    float freq, bbcbw;
	    
	    freq=bbc2freq(shm_addr->bbc[i%MAX_BBC].freq)/100.0;
	    bbcbw=bw_vlba[shm_addr->bbc[i%MAX_BBC].bw[1-(i/MAX_BBC)]];
	    if(i<MAX_BBC)
	      freq-=bbcbw*.5;
	    else
	      freq+=bbcbw*.5;
	    switch(shm_addr->lo.sideband[ifchain-1]) {
	    case 1:
	      center=shm_addr->lo.lo[ifchain-1]+freq;
	      break;
	    case 2:
	      center=shm_addr->lo.lo[ifchain-1]-freq;
	      break;
	    default:
	      *ierr=-302;
	      goto error;
	      break;
	    }
	  } else {
	    *ierr=-306;
	    goto error;
	  }
	} else if(MAX_BBC*2 <= i && i< MAX_DET) {
	  ifchain=i-MAX_BBC*2+1;
	  switch (shm_addr->lo.sideband[ifchain-1]) {
	  case 1:
	    center=shm_addr->lo.lo[ifchain-1]+(500.+1000.)*0.5;
	    break;
	  case 2:
	    center=shm_addr->lo.lo[ifchain-1]-(500.+1000.)*0.5;
	    break;
	  default:
	    *ierr=-302;
	    goto error;
	    break;
	  }
	}
	break;
      }
    }
  } else if(shm_addr->equip.rack==LBA) {
    for(i=0;i<sizeof(lwhatl)/sizeof(char *);i++) {
      if(strncmp(device,lwhatl[i],2)==0 && i<2*shm_addr->n_das) {
	ifchain=shm_addr->das[i/2].ifp[i%2].source+1;
	if(ifchain<1||ifchain>4)
	  ifchain=0;
	if(ifchain!=0) {
	  float ifpf, ifpbw;
	    
	  ifpf=shm_addr->das[i/2].ifp[i%2].frequency;
	  ifpbw=bw_lba[shm_addr->das[i/2].ifp[i%2].bandwidth];
	  switch(shm_addr->das[i/2].ifp[i%2].filter_mode) {
	  case _SCB:
	  case _ACB:
	  case _SC1:
	  case _AC1:
	    /* Centre band - centred on IFP frequency */
	    break;
	  case _DSB:
	  case _DS2:
	    /* Standard double sideband - LSB or DSB, depends on setting */
	    if(shm_addr->das[i/2].ifp[i%2].ft.digout.setting)
	      ifpf-=ifpbw*.5;
	    else
	      ifpf+=ifpbw*.5;
	    break;
	  case _DS4:
	    /* Outer double sideband - LSB or DSB, depends on setting */
	    if(shm_addr->das[i/2].ifp[i%2].ft.digout.setting)
	      ifpf-=ifpbw*1.5;	/* Valid only for 8MHz BW */
	    else
	      ifpf+=ifpbw*1.5;	/* Valid only for 8MHz BW */
	    break;
	  case _DS6:
	    /* Extreme outer double sideband - LSB or DSB, depends on setting */
	    if(shm_addr->das[i/2].ifp[i%2].ft.digout.setting)
	      ifpf-=ifpbw*2.5;	/* Valid only for 8MHz BW */
	    else
	      ifpf+=ifpbw*2.5;	/* Valid only for 8MHz BW */
	    break;
	  default:
	    *ierr=-304;
	    goto error;
	    break;
	  }
	  switch(shm_addr->lo.sideband[ifchain-1]) {
	  case 1:
	    center=shm_addr->lo.lo[ifchain-1]+ifpf;
	    break;
	  case 2:
	    center=shm_addr->lo.lo[ifchain-1]-ifpf;
	    break;
	  default:
	    *ierr=-302;
	    goto error;
	    break;
	  }
	} else {
	  *ierr=-306;
	  goto error;
	}
	break;
      }
    }
  } else if(shm_addr->equip.rack==DBBC && 
	    (shm_addr->equip.rack_type == DBBC_DDC ||
	     shm_addr->equip.rack_type == DBBC_DDC_FILA10G)
	    ){
    for(i=0;i<sizeof(lwhat)/sizeof(char *);i++) {
      if(strncmp(device,lwhat[i],2)==0) {
	if(i<2*MAX_DBBC_BBC) {
	  ifchain=shm_addr->dbbcnn[i%MAX_DBBC_BBC].source+1;
	  if(ifchain<1||ifchain>4)
	    ifchain=0;
	  if(ifchain!=0) {
	    float freq, bbcbw;
	    
	    freq=shm_addr->dbbcnn[i%MAX_DBBC_BBC].freq/1.e6;
	    bbcbw=bw_dbbc[shm_addr->dbbcnn[i%MAX_DBBC_BBC].bw];
	    if(i<MAX_DBBC_BBC)
	      freq-=bbcbw*.5;
	    else
	      freq+=bbcbw*.5;
	    switch(shm_addr->lo.sideband[ifchain-1]) {
	    case 1:
	      center=shm_addr->lo.lo[ifchain-1]+freq;
	      break;
	    case 2:
	      center=shm_addr->lo.lo[ifchain-1]-freq;
	      break;
	    default:
	      *ierr=-302;
	      goto error;
	      break;
	    }
	  } else {
	    *ierr=-306;
	    goto error;
	  }
	} else if(MAX_DBBC_BBC*2 <= i && i< MAX_DBBC_DET) {
	  float upper, lower;

	  ifchain=i-MAX_DBBC_BBC*2+1;
	  switch(shm_addr->dbbcifx[ifchain-1].filter) {
	  case 1:  lower= 512; upper=1024; break;
	  case 2:  lower=  10; upper= 512; break;
	  case 3:  lower=1536; upper=2048; break;
	  case 4:  lower=1024; upper=1536; break;
	  case 5:  lower=1200; upper=1800; break;
	  case 6:  lower=   0; upper=1024; break;
	  default: *ierr=-307; goto error; break;
	  }

	  switch (shm_addr->lo.sideband[ifchain-1]) {
	  case 1:
	    center=shm_addr->lo.lo[ifchain-1]+(lower+upper)*0.5;
	    break;
	  case 2:
	    center=shm_addr->lo.lo[ifchain-1]-(lower+upper)*0.5;
	    break;
	  default:
	    *ierr=-302;
	    goto error;
	    break;
	  }
	}
	break;
      }
    }
  } else if(shm_addr->equip.rack==DBBC && 
	    (shm_addr->equip.rack_type == DBBC_PFB ||
	     shm_addr->equip.rack_type == DBBC_PFB_FILA10G)  ){

    for(i=0;i<shm_addr->dbbc_cond_mods;i++) {
      for(j=0;j<shm_addr->dbbc_como_cores[i];j++) {
	for(k=1;k<16;k++) {
	  snprintf(idevice,4,"%c%02d",ch[i],k+j*16);
	  if(strncmp(idevice,device,3)==0) {
	    float freq;

	    ifchain=i+1;
	    freq=k*32; /* center */

	    filter=shm_addr->dbbcifx[ifchain-1].filter;
	    if(filter <1 || filter >4) {
	      *ierr=-307;
	      goto error;
	    }
	    zone=zone_table[filter-1];
	    if(1==zone%2) /*odd zone */
	      freq=(zone-1)*512+freq;
	    else /* even */
	      freq=zone*512-freq;

	    switch(shm_addr->lo.sideband[ifchain-1]) {
	    case 1:
	      center=shm_addr->lo.lo[ifchain-1]+freq;
	      break;
	    case 2:
	      center=shm_addr->lo.lo[ifchain-1]-freq;
	      break;
	    default:
	      *ierr=-302;
	      goto error;
	      break;
	    }
	    goto end;
	  }
	}
      }

      if(strncmp(device,lwhati[i],3)==0) {
	float upper, lower;
	
	ifchain=i+1;
	switch(shm_addr->dbbcifx[ifchain-1].filter) {
	case 1:  lower= 512; upper=1024; break;
	case 2:  lower=  10; upper= 512; break;
	case 3:  lower=1536; upper=2048; break;
	case 4:  lower=1024; upper=1536; break;
	case 5:  lower=1200; upper=1800; break;
	case 6:  lower=   0; upper=1024; break;
	default: *ierr=-307; goto error; break;
	}
	
	switch (shm_addr->lo.sideband[ifchain-1]) {
	case 1:
	  center=shm_addr->lo.lo[ifchain-1]+(lower+upper)*0.5;
	  break;
	case 2:
	  center=shm_addr->lo.lo[ifchain-1]-(lower+upper)*0.5;
	  break;
	default:
	  *ierr=-302;
	  goto error;
	  break;
	}
	goto end;
      }
    }    
  } else if(shm_addr->equip.rack==RDBE) {
    int iscan, ifc, irdbe, ichan;
    char *prdbe, crdbe;

    iscan=sscanf(device,"%2d%1c%1d",&ichan,&crdbe,&ifc);
//    printf(" iscan %d ichan %d crdbe %c ifc %d\n",iscan,ichan,crdbe,ifc);
    prdbe=strchr(lets,crdbe);
    if(prdbe!=NULL)
      irdbe=prdbe-lets;
    ifchain=1+irdbe*MAX_RDBE_IF+ifc;
//    printf(" ifchain1 %d\n",ifchain);
    if(iscan!=3 ||
       prdbe == NULL || irdbe <0 || irdbe >= MAX_RDBE ||
       ifc < 0 || ifc >= MAX_RDBE_IF)
      ifchain=0;
    if(ifchain!=0 && 0 <= ichan && ichan <= MAX_RDBE_CH) {
      center=shm_addr->lo.lo[ifchain-1]+1024-32*ichan;
    } else {
      *ierr=-306;
      goto error;
    }
  } else if(shm_addr->equip.rack==DBBC3) {
    det=-1;
    for(i=0;i<sizeof(lwhat3if)/sizeof(char *);i++) {
      if(strncmp(device,lwhat3if[i],2)==0) {
	det=2*MAX_DBBC3_BBC+i;
	break;
      }
    }
    if(det<0) {
      det=atoi(device);
      if(det<1||det>MAX_DBBC3_BBC)
	det=-1;
      else if(device[3]=='u')
	det+=MAX_DBBC3_BBC;
      det--;
    }
    if(-1 < det && det<2*MAX_DBBC3_BBC) {
      ifchain=shm_addr->dbbc3_bbcnn[det%MAX_DBBC3_BBC].source+1;
      if(ifchain<1||ifchain>8)
	ifchain=0;
      if(ifchain!=0) {
	float freq, bbcbw;
	
	freq=shm_addr->dbbcnn[det%MAX_DBBC3_BBC].freq/1.e6;
	bbcbw=bw_dbbc3[shm_addr->dbbc3_bbcnn[det%MAX_DBBC3_BBC].bw];
	if(det<MAX_DBBC3_BBC)
	  freq-=bbcbw*.5;
	else
	  freq+=bbcbw*.5;
	switch(shm_addr->lo.sideband[ifchain-1]) {
	case 1:
	  center=shm_addr->lo.lo[ifchain-1]+freq;
	  break;
	case 2:
	  center=shm_addr->lo.lo[ifchain-1]-freq;
	  break;
	default:
	  *ierr=-302;
	  goto error;
	  break;
	}
      } else {
	*ierr=-306;
	goto error;
      }
    } else if(MAX_DBBC3_BBC*2 <= det && det< MAX_DBBC3_DET) {
      float upper, lower;
      
      ifchain=det-MAX_DBBC3_BBC*2+1;
      
      switch (shm_addr->lo.sideband[ifchain-1]) {
      case 1:
	center=shm_addr->lo.lo[ifchain-1]+4096.0*0.5;
	break;
      case 2:
	center=shm_addr->lo.lo[ifchain-1]-4096.0*0.5;
	break;
      default:
	*ierr=-302;
	goto error;
	break;
      }
    }
  }

  end:
  if(ifchain==0) { /* not found */
    *ierr=-308;
    *fwhm=-1.0;
    *tcal=-1.0;
    goto error;
  }
  get_gain_par(ifchain,center,fwhm,&dpfu,NULL,tcal);

  if(epoch <0.0)
    return;

  memcpy(lsorna,shm_addr->lsorna,sizeof(lsorna)-1);
  lsorna[sizeof(lsorna)-1]=0;
  for(j=0;j<sizeof(lsorna)-1;j++)
    if(lsorna[j]==' ') {
      lsorna[j]=0;
      break;
    }

  *flux=flux_val(lsorna,&shm_addr->flux,center, epoch,*fwhm,corr,ssize);

 error:
  return;
}
