#include <stdio.h> 
#include <sys/types.h>
#include <math.h>

#include "../include/dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

float flux_val();

static float bw[ ]={0.0,0.125,0.250,0.50,1.0,2.0,4.0}; 
static float bw4[ ]={0.0,0.125,16.0,0.50,8.0,2.0,4.0};
static float bw_vlba[ ]={0.0625,0.125,0.25,0.5,1.0,2.0,4.0,8.0,16.0};
static char *lwhat[ ]={
"1l","2l","3l","4l","5l","6l","7l","8l","9l","al","bl","cl","dl","el",
"1u","2u","3u","4u","5u","6u","7u","8u","9u","au","bu","cu","du","eu",
"ia","ib","ic","id"};
static char *lwhatm[ ]={
"v1","v2","v3","v4","v5","v6","v7","v8","v9","va","vb","vc","vd","ve",
"i1","i2","i3"};

void get_tcal_fwhm(device,tcal,fwhm,epoch,flux,corr,ssize,ierr)
char device[2];
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

  ifchain=0;
  *ierr=0;

  if(shm_addr->equip.rack==MK3||shm_addr->equip.rack==MK4) {
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
	      vcf=vcf-vcbw*0.5;
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
	    long bbc2freq();
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
  }
  if(ifchain!=0) {
    get_gain_par(ifchain,center,fwhm,&dpfu,NULL,tcal);
  } else {
    *fwhm=-1.0;
    *tcal=-1.0;
  }

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
