/*
 * Copyright (c) 2020-2021, 2023, 2025 NVI, Inc.
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
/* onoff snap command */

#include <math.h>
#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

static char hex[]= "0123456789abcdef";
static char det[] = "dlu34567";
static float bw[ ]={0.0,0.125,0.250,0.50,1.0,2.0,4.0}; 
static float bw4[ ]={0.0,0.125,16.0,0.50,8.0,2.0,4.0};
static float bw_vlba[ ]={0.0625,0.125,0.25,0.5,1.0,2.0,4.0,8.0,16.0,32.0};
static float bw_lba[ ]={0.0625,0.125,0.25,0.5,1.0,2.0,4.0,8.0,16.0,32.0,64.0};
static float bw_dbbc[ ]={1.0,2.0,4.0,8.0,16.0,32.0,64.0};
static float bw_dbbc3[ ]={0.0,2.0,4.0,8.0,16.0,32.0,64.0,128.0};
static int zone_table[] = {2, 1, 4,3}; /* DBBC filter Nyquist zones */

float flux_val();

void onoff(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;
int ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ichold, i, count, j;
      int verr;
      char *ptr;
      struct onoff_cmd lcl;
      int it[6];
      char lsorna[sizeof(shm_addr->lsorna)+1];
      float epoch,corr,ssize;

      int onoff_dec();                 /* parsing utilities */
      char *arg_next();

      void onoffc_dis();

      void skd_run(), skd_par();      /* program scheduling utilities */

      ierr=0;

      if (command->equal != '=') {           /* run onoff */
	int set;
	if ( 1 == nsem_test("onoff") || 1 == nsem_test("fivpt") ||
	     1 == nsem_test("holog") ) {
	  ierr=-305;
	  goto error;
	}
	set=FALSE;
	for (i=0;i<MAX_ONOFF_DET;i++) {
	  set= set ||(shm_addr->onoff.itpis[i]!=0);
	}
	if(!set && !shm_addr->onoff.none_detector) {
	  ierr=-304;
	  goto error;
	}
	memcpy(&lcl,&shm_addr->onoff,sizeof(lcl));
	if(lcl.none_detector)
         lcl.ssize=0;
	else if(shm_addr->equip.rack==MK3||shm_addr->equip.rack==MK4||shm_addr->equip.rack==LBA4) {
	  float vcf,vcbw,extbw;
	  lcl.fwhm=-1.0;
	  for (i=0;i<14;i++)
	    if(lcl.itpis[i]!=0){
	      lcl.devices[i].ifchain=abs(shm_addr->ifp2vc[i]);
	      if(lcl.devices[i].ifchain<1||lcl.devices[i].ifchain>3)
		lcl.devices[i].ifchain=0;
	      lcl.devices[i].lwhat[0]=hex[i+1];
	      if(shm_addr->ITPIVC[i]==-1)
		lcl.devices[i].lwhat[1]='x';
	      else
		lcl.devices[i].lwhat[1]=det[shm_addr->ITPIVC[i]&0x7];
	      if(lcl.devices[i].ifchain!=0) {
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
		  ierr=-301;
		  goto error;
		  break;
		}
		switch(shm_addr->lo.sideband[lcl.devices[i].ifchain-1]) {
		case 1:
		  lcl.devices[i].center=
		    shm_addr->lo.lo[lcl.devices[i].ifchain-1]+vcf;
		  break;
		case 2:
		  lcl.devices[i].center=
		    shm_addr->lo.lo[lcl.devices[i].ifchain-1]-vcf;
		  break;
		default:
		  ierr=-302;
		  goto error;
		  break;
		}
	      } else {
		ierr=-303;
		goto error;
	      }
	    }
	  for (i=14;i<16;i++)
	    if(lcl.itpis[i]!=0) {
	      lcl.devices[i].ifchain=i-13;
	      lcl.devices[i].lwhat[0]='i';
	      lcl.devices[i].lwhat[1]=hex[i-13];
	      switch (shm_addr->lo.sideband[lcl.devices[i].ifchain-1]) {
	      case 1:
		lcl.devices[i].center=
		  shm_addr->lo.lo[lcl.devices[i].ifchain-1]+(500.+100.)*0.5;
		break;
	      case 2:
		lcl.devices[i].center=
		  shm_addr->lo.lo[lcl.devices[i].ifchain-1]-(500.+100.)*0.5;
		break;
	      default:
		ierr=-302;
		goto error;
		break;
	      }
	    }
	  for (i=16;i<17;i++)
	    if(lcl.itpis[i]!=0) {
	      float upper;
	      lcl.devices[i].ifchain=i-13;
	      lcl.devices[i].lwhat[0]='i';
	      lcl.devices[i].lwhat[1]=hex[i-13];
	      if(shm_addr->imixif3==1)
		upper=400.0;
	      else
		upper=500.0;
	      switch (shm_addr->lo.sideband[lcl.devices[i].ifchain-1]) {
	      case 1:
		lcl.devices[i].center=
		  shm_addr->lo.lo[lcl.devices[i].ifchain-1]+(upper+100.)*0.5;
		break;
	      case 2:
		lcl.devices[i].center=
		  shm_addr->lo.lo[lcl.devices[i].ifchain-1]-(upper+100.)*0.5;
		break;
	      default:
		ierr=-302;
		goto error;
		break;
	      }
	    }
	} else if(shm_addr->equip.rack==VLBA||shm_addr->equip.rack==VLBA4) {
	  for (i=0;i<MAX_BBC*2;i++) {
	    if(lcl.itpis[i]!=0) {
	      lcl.devices[i].ifchain=shm_addr->bbc[i%MAX_BBC].source+1;
	      if(lcl.devices[i].ifchain<1||lcl.devices[i].ifchain>4)
		lcl.devices[i].ifchain=0;
	      if(lcl.devices[i].ifchain!=0) {
		int bbc2freq();
		float freq, bbcbw;
		
		freq=bbc2freq(shm_addr->bbc[i%MAX_BBC].freq)/100.0;
		bbcbw=bw_vlba[shm_addr->bbc[i%MAX_BBC].bw[1-(i/MAX_BBC)]];
		if(i<MAX_BBC)
		  freq-=bbcbw*.5;
		else
		  freq+=bbcbw*.5;
		switch(shm_addr->lo.sideband[lcl.devices[i].ifchain-1]) {
		case 1:
		  lcl.devices[i].center=
		    shm_addr->lo.lo[lcl.devices[i].ifchain-1]+freq;
		  break;
		case 2:
		  lcl.devices[i].center=
		    shm_addr->lo.lo[lcl.devices[i].ifchain-1]-freq;
		  break;
		default:
		  ierr=-302;
		  goto error;
		  break;
		}
	      } else {
		ierr=-306;
		goto error;
	      }
	    }
	  }
	  for (i=MAX_BBC*2;i<MAX_DET;i++) {
	    if(lcl.itpis[i]!=0) {
	      lcl.devices[i].ifchain=i-MAX_BBC*2+1;
	      switch (shm_addr->lo.sideband[lcl.devices[i].ifchain-1]) {
	      case 1:
		lcl.devices[i].center=
		  shm_addr->lo.lo[lcl.devices[i].ifchain-1]+(500.+1000.)*0.5;
		break;
	      case 2:
		lcl.devices[i].center=
		  shm_addr->lo.lo[lcl.devices[i].ifchain-1]-(500.+1000.)*0.5;
		break;
	      default:
		ierr=-302;
		goto error;
		break;
	      }
	    }
	  }
	} else if(shm_addr->equip.rack==LBA) {
	  for (i=0;i<2*shm_addr->n_das;i++) {
	    if(lcl.itpis[i]!=0) {
	      lcl.devices[i].ifchain=shm_addr->das[i/2].ifp[i%2].source+1;
	      if(lcl.devices[i].ifchain<1||lcl.devices[i].ifchain>4)
		lcl.devices[i].ifchain=0;
	      if(lcl.devices[i].ifchain!=0) {
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
		  /* Double sideband - LSB or DSB, depends on setting */
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
		  /* Extreme double sideband - LSB or DSB, depends on setting */
		  if(shm_addr->das[i/2].ifp[i%2].ft.digout.setting)
		    ifpf-=ifpbw*2.5;	/* Valid only for 8MHz BW */
		  else
		    ifpf+=ifpbw*2.5;	/* Valid only for 8MHz BW */
		  break;
		default:
		  ierr=-301;
		  goto error;
		  break;
		}
		switch(shm_addr->lo.sideband[lcl.devices[i].ifchain-1]) {
		case 1:
		  lcl.devices[i].center=
		    shm_addr->lo.lo[lcl.devices[i].ifchain-1]+ifpf;
		  break;
		case 2:
		  lcl.devices[i].center=
		    shm_addr->lo.lo[lcl.devices[i].ifchain-1]-ifpf;
		  break;
		default:
		  ierr=-302;
		  goto error;
		  break;
		}
	      } else {
		ierr=-306;
		goto error;
	      }
	    }
	  }
	} else if(shm_addr->equip.rack==DBBC &&
	    (shm_addr->equip.rack_type == DBBC_DDC ||
	     shm_addr->equip.rack_type == DBBC_DDC_FILA10G)) {
	  for (i=0;i<MAX_DBBC_BBC*2;i++) {
	    if(lcl.itpis[i]!=0) {
	      lcl.devices[i].ifchain=shm_addr->dbbcnn[i%MAX_DBBC_BBC].source+1;
	      if(lcl.devices[i].ifchain<1||lcl.devices[i].ifchain>4)
		lcl.devices[i].ifchain=0;
	      if(lcl.devices[i].ifchain!=0) {
		int bbc2freq();
		float freq, bbcbw;
		
		freq=shm_addr->dbbcnn[i%MAX_BBC].freq/1.0e6;
		bbcbw=bw_dbbc[shm_addr->dbbcnn[i%MAX_BBC].bw];
		if(i<MAX_DBBC_BBC)
		  freq-=bbcbw*.5;
		else
		  freq+=bbcbw*.5;
		switch(shm_addr->lo.sideband[lcl.devices[i].ifchain-1]) {
		case 1:
		  lcl.devices[i].center=
		    shm_addr->lo.lo[lcl.devices[i].ifchain-1]+freq;
		  break;
		case 2:
		  lcl.devices[i].center=
		    shm_addr->lo.lo[lcl.devices[i].ifchain-1]-freq;
		  break;
		default:
		  ierr=-302;
		  goto error;
		  break;
		}
	      } else {
		ierr=-306;
		goto error;
	      }
	    }
	  }
	  for (i=MAX_DBBC_BBC*2;i<MAX_DBBC_DET;i++) {
	    if(lcl.itpis[i]!=0) {
	      float upper, lower;

	      lcl.devices[i].ifchain=i-MAX_DBBC_BBC*2+1;

	      switch(shm_addr->dbbcifx[lcl.devices[i].ifchain-1].filter) {
	      case 1:  lower= 512; upper=1024; break;
	      case 2:  lower=  10; upper= 512; break;
	      case 3:  lower=1536; upper=2048; break;
	      case 4:  lower=1024; upper=1536; break;
	      case 5:  lower=1200; upper=1800; break;
	      case 6:  lower=   0; upper=1024; break;
	      default: ierr=-308; goto error; break;
	      }

	      switch (shm_addr->lo.sideband[lcl.devices[i].ifchain-1]) {
	      case 1:
		lcl.devices[i].center=shm_addr->lo.lo[lcl.devices[i].ifchain-1]+
		  (lower+upper)*0.5;
		break;
	      case 2:
		lcl.devices[i].center=shm_addr->lo.lo[lcl.devices[i].ifchain-1]-
		  (lower+upper)*0.5;
		break;
	      default:
		ierr=-302;
		goto error;
		break;
	      }
	    }
	  }
	} else if(shm_addr->equip.rack==DBBC &&
	    (shm_addr->equip.rack_type == DBBC_PFB ||
	     shm_addr->equip.rack_type == DBBC_PFB_FILA10G)) {
	  int i,j,icore,k,ik,ifchain,filter,zone;
	  icore=0;
	  for(i=0;i<shm_addr->dbbc_cond_mods;i++) {
	    ifchain=i+1;
	    for(j=0;j<shm_addr->dbbc_como_cores[i];j++) {
	      icore++;
	      for(k=1;k<16;k++) {
		ik=k+(icore-1)*16;
		if(1==lcl.itpis[ik]) {
		  lcl.devices[ik].ifchain=ifchain;
		  float freq, center;

		  freq=k*32; /* center */

		  filter=shm_addr->dbbcifx[ifchain-1].filter;
		  if(filter <1 || filter >4) {
		    ierr=-309;
		    goto error;
		  }
		  zone=zone_table[filter-1];
		  if(1==zone%2) /*odd zone */
		    freq=(zone-1)*512+freq;
		  else /* even */
		    freq=zone*512-freq;
		  
		  switch(shm_addr->lo.sideband[ifchain-1]) {
		  case 1:
		    lcl.devices[ik].center=shm_addr->lo.lo[ifchain-1]+freq;
		    break;
		  case 2:
		    lcl.devices[ik].center=shm_addr->lo.lo[ifchain-1]-freq;
		    break;
		  default:
		    ierr=-302;
		    goto error;
		    break;
		  }
		}
	      }
	    }

	    ik=i+MAX_DBBC_PFB;
	    if(lcl.itpis[ik]!=0) {
	      float upper, lower, center;

	      lcl.devices[ik].ifchain=ifchain;
	      switch(shm_addr->dbbcifx[ifchain-1].filter) {
	      case 1:  lower= 512; upper=1024; break;
	      case 2:  lower=  10; upper= 512; break;
	      case 3:  lower=1536; upper=2048; break;
	      case 4:  lower=1024; upper=1536; break;
	      case 5:  lower=1200; upper=1800; break;
	      case 6:  lower=   0; upper=1024; break;
	      default: ierr=-308; goto error; break;
	      }
	
	      switch (shm_addr->lo.sideband[ifchain-1]) {
	      case 1:
		lcl.devices[ik].center=shm_addr->lo.lo[ifchain-1]+
		  (lower+upper)*0.5;
		break;
	      case 2:
		lcl.devices[ik].center=shm_addr->lo.lo[ifchain-1]-
		  (lower+upper)*0.5;
		break;
	      default:
		ierr=-302;
		goto error;
		break;
	      }
	    }
	  }
	} else if(shm_addr->equip.rack==RDBE) {
	  int ifch, ichan, irdbe, ifchain;
	  for(i=0;i<MAX_RDBE_DET;i++) {
	    irdbe=i/(MAX_RDBE_IF*MAX_RDBE_CH);
	    if(shm_addr->rdbe_active[irdbe]) {
	      ifch=(i%(MAX_RDBE_IF*MAX_RDBE_CH))/MAX_RDBE_CH;
	      ifchain=irdbe*MAX_RDBE_IF+ifch+1;
	      if(shm_addr->lo.lo[ifchain-1]<0) {
		ierr=-310;
		goto error;
	      }
	      ichan=(i%(MAX_RDBE_IF*MAX_RDBE_CH))%MAX_RDBE_CH;
	      lcl.devices[i].ifchain=ifchain;
	      lcl.devices[i].center=shm_addr->lo.lo[ifchain-1]+1024-32*ichan;
	    }
	  }
	} else if(shm_addr->equip.rack==DBBC3) {
	  for (i=0;i<MAX_DBBC3_BBC*2;i++) {
	    if(lcl.itpis[i]!=0) {
	      lcl.devices[i].ifchain=
		shm_addr->dbbc3_bbcnn[i%MAX_DBBC3_BBC].source+1;
	      if(lcl.devices[i].ifchain<1||lcl.devices[i].ifchain>MAX_DBBC3_IF)
		lcl.devices[i].ifchain=0;
	      if(lcl.devices[i].ifchain!=0) {
		float freq, bbcbw;
		
		freq=shm_addr->dbbc3_bbcnn[i%MAX_DBBC3_BBC].freq/1.0e6;
		bbcbw=bw_dbbc3[shm_addr->dbbc3_bbcnn[i%MAX_DBBC3_BBC].bw];
		if(i<MAX_DBBC3_BBC)
		  freq-=bbcbw*.5;
		else
		  freq+=bbcbw*.5;
		switch(shm_addr->lo.sideband[lcl.devices[i].ifchain-1]) {
		case 1:
		  lcl.devices[i].center=
		    shm_addr->lo.lo[lcl.devices[i].ifchain-1]+freq;
		  break;
		case 2:
		  lcl.devices[i].center=
		    shm_addr->lo.lo[lcl.devices[i].ifchain-1]-freq;
		  break;
		default:
		  ierr=-302;
		  goto error;
		  break;
		}
	      } else {
		ierr=-306;
		goto error;
	      }
	    }
	  }
	  for (i=MAX_DBBC3_BBC*2;i<MAX_DBBC3_DET;i++) {
	    if(lcl.itpis[i]!=0) {
	      float upper, lower;

	      lcl.devices[i].ifchain=i-MAX_DBBC3_BBC*2+1;

	      switch (shm_addr->lo.sideband[lcl.devices[i].ifchain-1]) {
	      case 1:
		lcl.devices[i].center=shm_addr->lo.lo[lcl.devices[i].ifchain-1]+
		  4096.*0.5;
		break;
	      case 2:
		lcl.devices[i].center=shm_addr->lo.lo[lcl.devices[i].ifchain-1]-
		  4096.0*0.5;
		break;
	      default:
		ierr=-302;
		goto error;
		break;
	      }
	    }
	  }
	}

	/* user devices */
	for (i=MAX_GLOBAL_DET;i<MAX_ONOFF_DET;i++)
	    if(lcl.itpis[i]!=0) {
	      lcl.devices[i].ifchain=i-MAX_GLOBAL_DET+MAX_LO+1;
	      lcl.devices[i].lwhat[0]='u';
	      lcl.devices[i].lwhat[1]=hex[i-MAX_GLOBAL_DET+1];
	      lcl.devices[i].center=
		shm_addr->user_device.center[lcl.devices[i].ifchain-(1+MAX_LO)];
	      switch(shm_addr->user_device.sideband[lcl.devices[i].ifchain-(1+MAX_LO)]) {
	      case 1:
		lcl.devices[i].center=
		  shm_addr->user_device.lo[lcl.devices[i].ifchain-(1+MAX_LO)]
		  +lcl.devices[i].center;
		break;
	      case 2:
		lcl.devices[i].center=
		  shm_addr->user_device.lo[lcl.devices[i].ifchain-(1+MAX_LO)]
		  -lcl.devices[i].center;
		break;
	      default:
/*
		printf(" user device sideband %d ifchain %d \n",
		      shm_addr->user_device.sideband[lcl.devices[i].ifchain-(1+MAX_LO)],
		      lcl.devices[i].ifchain);
*/
		ierr=-302;
		goto error;
		break;
	      }
	    }

	memcpy(lsorna,shm_addr->lsorna,sizeof(lsorna)-1);
	lsorna[sizeof(lsorna)-1]=0;
	for(j=0;j<sizeof(lsorna)-1;j++)
	  if(lsorna[j]==' ') {
	    lsorna[j]=0;
	    break;
	  }
	rte_time(it,it+5);
	epoch=((float) it[5])+((float) it[4])/366.;
	lcl.ssize=0.0;
	for(i=0;i<MAX_ONOFF_DET;i++) {
	  if(lcl.itpis[i]!=0) {
	    int pol,ifchain;
	    ifchain=lcl.devices[i].ifchain;
	    if(1 <= ifchain && ifchain <= MAX_LO) {
	      pol=shm_addr->lo.pol[ifchain-1];
	    } else if (MAX_LO+1 <= ifchain && ifchain <= MAX_LO+6) {
	      pol=shm_addr->user_device.pol[ifchain-(1+MAX_LO)];
	    } 
	    switch(pol) {
	    case 1:
	      lcl.devices[i].pol='r';
	      break;
	    case 2:
	      lcl.devices[i].pol='l';
	      break;
	    default:
	      lcl.devices[i].pol='u';
	      break;
	    }
	    get_gain_par(lcl.devices[i].ifchain,
			 lcl.devices[i].center,
			 &lcl.devices[i].fwhm,
			 &lcl.devices[i].dpfu,
			 &lcl.devices[i].gain,
			 &lcl.devices[i].tcal);
		   
	    lcl.fwhm=lcl.devices[i].fwhm>lcl.fwhm
	      ?lcl.devices[i].fwhm : lcl.fwhm;
	    
	    if(shm_addr->equip.rack==DBBC && shm_addr->dbbc_cont_cal.mode == 1 &&
              lcl.devices[i].lwhat[0] == 'i' && lcl.devices[i].tcal >=0)
		 lcl.devices[i].tcal=-100;

	    lcl.devices[i].flux=flux_val(lsorna,&shm_addr->flux,
					 lcl.devices[i].center,
					 epoch,
					 lcl.devices[i].fwhm,
					 &lcl.devices[i].corr,&ssize);
	    lcl.ssize=lcl.ssize>ssize?lcl.ssize:ssize;
	    if(lcl.devices[i].corr>=1.2) {
              char buff3[120];
              if(0==strncmp("  ",lcl.devices[i].lwhat+2,2))
                snprintf(buff3,sizeof(buff3),"WARNING: Source structure correction greater than 20%% for detector %-2.2s",
                        lcl.devices[i].lwhat);
              else
                snprintf(buff3,sizeof(buff3),"WARNING: Source structure correction greater than 20%% for detector %-4.4s",
                        lcl.devices[i].lwhat);
              logite(buff3,307,"q1");
	    }
	  }
	}

	lcl.setup=TRUE;
	lcl.stop_request=0;
	memcpy(&shm_addr->onoff,&lcl,sizeof(lcl));
	skd_run("onoff",'n',ip);
	ip[0]=ip[1]=ip[2]=0;
	return;
      } else if (command->argv[0]==NULL)
	goto parse;  /* simple equals */
      else if (command->argv[1]==NULL) {/* special cases */
        if (*command->argv[0]=='?') {
          onoff_dis(command,ip);
	  return;
	} else if(0==strcmp(command->argv[0],"stop")){
	  shm_addr->onoff.stop_request=1;
	  skd_run("onoff",'w',ip);
	  ip[0]=ip[1]=ip[2]=0;
          return;
	}
      }
/* if we get this far it is a set-up command so parse it */

parse:
      ilast=0;                                      /* last argv examined */

      memcpy(&lcl,&shm_addr->onoff,sizeof(lcl));
      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=onoff_dec(&lcl,&count, ptr);
        if(ierr !=0 ) goto error;
      }

/* all parameters parsed okay, update common */

      memcpy(&shm_addr->onoff,&lcl,sizeof(lcl));

      ip[0]=ip[1]=ip[2]=0;

      onoff_dis(command,ip);
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"q1",2);
      return;
}
