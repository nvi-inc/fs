/* tpi support utilities for VLBA rack */
/* tpi_vlba formats the buffers and runs mcbcn to get data */
/* tpput_vlba stores the result in fscom and formats the output */
/* tsys_vlba does tsys calculations for tsysX commands */

#include <math.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

static char ch[ ]={"123456789abcdefg"};
static char *lwhat[ ]={
"1l","2l","3l","4l","5l","6l","7l","8l","9l","al","bl","cl","dl","el","fl","gl",
"1u","2u","3u","4u","5u","6u","7u","8u","9u","au","bu","cu","du","eu","fu","gu",
"ia","ib","ic","id"};

void tpi_vlba(ip,itpis_vlba,isub)                    /* sample tpi(s) */
int ip[5];                                     /* ipc array */
int itpis_vlba[MAX_DET]; /* detector selection array */
                      /* in order: L: bbc1...bbc16, U: bbc1...bbc16(U)       */
                      /*           ia, ib, ic, id; value: 0=don't use, 1=use */
int isub;
{
    struct req_buf buffer;
    struct req_rec request;
    int i;

    ini_req(&buffer);
    request.type=21;

    if(isub!=8 && isub !=9) {
      for (i=0;i<MAX_DET;i++) {
	if(1==itpis_vlba[i]) {
	  if(i<(2*MAX_BBC)) {                   /* bbc(s): */
	    request.device[0]='b';
	    request.device[1]=ch[i%MAX_BBC];                /* '1'-'g' */
	  } else {                              /* ifd(s): */
	    request.device[0]='i';
	    request.device[1]=ch[((i-2*MAX_BBC)/2)*2+9];   /* 'a' or 'c' */
	  }
#if 0
	  if(0==(i%2)) request.addr=0x06;        /* USB or ia or ic */
	  else request.addr=0x07;                /* LSB or ib or id */
#endif
	  if (i<MAX_BBC || (i>=2*MAX_BBC && 1==(i%2)))
	    request.addr=0x07;
	  else
	    request.addr=0x06;
	  
	  add_req(&buffer,&request);
	}
      }
    } else {
      for(i=0;i<MAX_BBC;i++) {
	if(1==itpis_vlba[i]||1==itpis_vlba[i+MAX_BBC]) {
	  request.device[0]='b';
	  request.device[1]=ch[i%MAX_BBC];                /* '1'-'g' */
	  
	  request.addr=0x05;
  
	  add_req(&buffer,&request);
	}
      }
      for(i=2*MAX_BBC;i<MAX_DET;i++) {
	if(1==itpis_vlba[i]) {
	  request.device[0]='i';
	  request.device[1]=ch[((i-2*MAX_BBC)/2)*2+9];   /* 'a' or 'c' */
	  
	  if(1==(i%2))
	    request.addr=0x07;
	  else
	    request.addr=0x06;
	  
	  add_req(&buffer,&request);
	}
      }
    }
    end_req(ip,&buffer);                /* end request buffer and do it */
    skd_run("mcbcn",'w',ip);
    skd_par(ip);

    return;
}
    
void tpput_vlba(ip,itpis_vlba,isubin,ibuf,nch,ilen) /* put results of tpi */
int ip[5];                                    /* ipc array */
int itpis_vlba[MAX_DET]; /* device selection array, see tpi_vlba for details */
int isubin;                /* which task: 3=tpi, 4=tpical, 7=tpzero */
char *ibuf;              /* out array, formatted results placed here */
int *nch;                /* next available char index in ibuf on entry */
                         /* the total count on exit, counts from 1 , not 0 */
int ilen;                /* number of characters ibuf can hold, ignored */
{
    struct res_buf buffer_out;
    struct res_rec response;
    int *ptr;
    int i,j,iclass,nrec,lenstart,isub;
    int tpigainlocal[MAX_DET];

    isub=abs(isubin);

    opn_res(&buffer_out,ip);

    switch (isub) {                        /* set the pointer for the type */
       case 3: ptr=shm_addr->tpi; break;
       case 4: ptr=shm_addr->tpical; break;
       case 7: ptr=shm_addr->tpizero; break;
       case 8:
	 if(isubin>0)
	   ptr=shm_addr->tpigain;
	 else
	   ptr=tpigainlocal;
	 break;
       case 9:
	 if(isubin>0)
	   ptr=shm_addr->tpidiffgain;
	 else
	   ptr=tpigainlocal;
	 break;
       default: ptr=tpigainlocal; break;  /* just being defensive */
    };


    if(isub!=8 && isub!=9) {
      for (i=0;i<MAX_DET;i++) {
	if(itpis_vlba[ i] == 1) {
	  get_res(&response,&buffer_out);
	  if(response.code==1)
	    ptr[i]=response.data;
	  else
	    ptr[i]=response.code;
	}
      }
    } else {
      for (i=0;i<MAX_BBC;i++) {
	if(itpis_vlba[ i] == 1||itpis_vlba[ i+MAX_BBC] == 1) {
	  get_res(&response,&buffer_out);
	  if(response.code==1) {
	    if(itpis_vlba[ i] ==1)
	      ptr[i]=response.data&0xFF;
	    if(itpis_vlba[ i+MAX_BBC]==1) 
	      ptr[i+MAX_BBC]=(response.data>>8)&0xFF;
	  } else {
	    if(itpis_vlba[ i] ==1)
	      ptr[i]=response.code;
	    if(itpis_vlba[ i+MAX_BBC]==1)
	      ptr[i+MAX_BBC]=response.code;
	  }
	}
      }
      for (i=2*MAX_BBC;i<MAX_DET;i++) {
	if(itpis_vlba[ i] == 1) {
	  get_res(&response,&buffer_out);
	  if(response.code==1)
	    ptr[i]=response.data;
	  else
	    ptr[i]=response.code;
	}
      }
    }
    if(response.state == -1) {
       clr_res(&buffer_out);
       ip[2]=-401;
       memcpy(ip+3,"qk",2);
       return;
    }
    clr_res(&buffer_out);

    ibuf[*nch-1]='\0';              /* NULL terminate to make STRING */
    lenstart=strlen(ibuf);
    iclass=0;
    nrec=0;
    for(j=-1;j<MAX_IF;j++) {
      int k;
      for(k=0;k<MAX_BBC*2;k++) {
	i=MAX_BBC*(k%2)+k/2;
	if(itpis_vlba[ i] == 1 && shm_addr->bbc[i%MAX_BBC].source==j) {
	  if(strlen(ibuf)>60) {
	    if(isubin > 0) {
	      cls_snd(&iclass,ibuf,strlen(ibuf)-1,0,0);
	      nrec=nrec+1;
	    } else {
	      ibuf[strlen(ibuf)-1]=0;
	      logit(ibuf,0,NULL);
	    }
	    ibuf[lenstart]=0;
	  }
	  strcat(ibuf,lwhat[i]);
	  strcat(ibuf,",");
	  if(ptr[i] >65534) {
	    strcat(ibuf,"$$$$$,");
	  } else {
	    int2str(ibuf,ptr[i],5,0);
	    strcat(ibuf,",");
	  }
	}
      }
      if(j==-1)
	continue;
      i=2*MAX_BBC+j;
      if(itpis_vlba[i]!=0) {
	if(strlen(ibuf)>60) {
	    if(isubin > 0) {
	      cls_snd(&iclass,ibuf,strlen(ibuf)-1,0,0);
	      nrec=nrec+1;
	    } else {
	      ibuf[strlen(ibuf)-1]=0;
	      logit(ibuf,0,NULL);
	    }
	  ibuf[lenstart]=0;
	}
	strcat(ibuf,lwhat[i]);
	strcat(ibuf,",");
	if(ptr[i] > 65534 ) {
	  strcat(ibuf,"$$$$$,");
	} else {
	  int2str(ibuf,ptr[i],5,0);
	  strcat(ibuf,",");
	}
      }
      if(ibuf[lenstart]!=0) {
	if(isubin > 0) {
	  cls_snd(&iclass,ibuf,strlen(ibuf)-1,0,0);
	  nrec=nrec+1;
	} else {
	  ibuf[strlen(ibuf)-1]=0;
	  logit(ibuf,0,NULL);
	}
	ibuf[lenstart]=0;
      }
    }
    ip[0]=iclass;
    ip[1]=nrec;
    ip[2]=0;
    return;
}

void tsys_vlba(ip,itpis_vlba,ibuf,nch,itask)
int ip[5];                                    /* ipc array */
int itpis_vlba[MAX_DET]; /* device selection array, see tpi_vlba for details */
char *ibuf;              /* out array, formatted results placed here */
int *nch;                /* next available char index in ibuf on entry */
                         /* the total count on exit, counts from 1 , not 0 */
int itask;               /* 5=tsys, 6=tpidiff, 10=caltemps */
{
  int i,j, inext,iclass,nrec, lenstart;
  float tpi,tpic,tpiz,tpid;

  for (i=0;i<MAX_DET;i++) {
    if(itpis_vlba[ i] == 1) {
      if(itask==5) {
	int kskip;
	kskip=i<2*MAX_BBC&&
  (shm_addr->bbc[i%MAX_BBC].source<0||shm_addr->bbc[i%MAX_BBC].source>3);
	tpi=shm_addr->tpi[ i];             /* various pieces */
	tpic=shm_addr->tpical[ i];
	tpiz=shm_addr->tpizero[ i];
	tpid=shm_addr->tpidiff[ i];

	if(kskip)         /* avoid overflow | div-by-0 */
	  shm_addr->systmp[ i]=-1.0;
	else if(tpid<0.5 || tpid > 65534.5 || tpi > 65534.5 || tpi < 0.5 ||
		tpiz < 0.5 || (i < 2*MAX_BBC && (
		shm_addr->tpidiffgain[i]==0||shm_addr->tpigain[i]==0)))
	  shm_addr->systmp[ i]=1e9;
	else {
	  float vgdiff,vgtpi;

	  if(i<2*MAX_BBC) {
	    vgdiff=shm_addr->tpidiffgain[i];
	    vgtpi=shm_addr->tpigain[i];
	  } else {
	    vgdiff=1.0;
	    vgtpi=1.0;
	  }

	  shm_addr->systmp[ i]=(tpi/(vgtpi*vgtpi)-tpiz/(vgdiff*vgdiff))*
	    shm_addr->caltemps[ i]/(tpid/(vgdiff*vgdiff));
	}
	if(shm_addr->systmp[ i]>999999.95 || shm_addr->systmp[ i] <0.0)
	  logita(NULL,-211,"qk",lwhat[i]);
      } else if(itask==6) {
	shm_addr->tpidiff[i]=shm_addr->tpical[i]-shm_addr->tpi[i];
	if(shm_addr->tpical[i]>65534.5||
	   shm_addr->tpical[i]<0.5||
	   shm_addr->tpi[i]>65534.5||
	   shm_addr->tpi[i]<0.5)
	  shm_addr->tpidiff[i]=65535;
      } else if(itask==10) {
	int ierr;
	float fwhm, epoch, dum;
	epoch=-1.0;
	get_tcal_fwhm(lwhat[i],&shm_addr->caltemps[i],&fwhm,
		      epoch,&dum, &dum,&dum,&ierr);
	if(ierr!=0) {
	  ip[0]=ip[1]=0;
	  ip[2]=ierr;
	  return;
	}
      }
    }
  }

  ibuf[*nch-1]='\0';              /* NULL terminate to make STRING */
  lenstart=strlen(ibuf);
  iclass=0;
  nrec=0;
  for(j=-1;j<MAX_IF;j++) {
    int k;
    for(k=0;k<MAX_BBC*2;k++) {
      if(k%2==0)
	i=k/2;
      else
	i=MAX_BBC+k/2;
      if(itpis_vlba[ i] == 1 && shm_addr->bbc[i%MAX_BBC].source==j) {
	if(strlen(ibuf)>60) {
	  cls_snd(&iclass,ibuf,strlen(ibuf)-1,0,0);
	  nrec=nrec+1;
	  ibuf[lenstart]=0;
	}
	strcat(ibuf,lwhat[i]);
	strcat(ibuf,",");
	if(itask==5) 
	  flt2str(ibuf,shm_addr->systmp[ i],8,1);
	else if(itask==6) {
	  int2str(ibuf,shm_addr->tpidiff[i],5,0);
	} else if(itask==10) 
	  flt2str(ibuf,shm_addr->caltemps[ i],8,3);

	strcat(ibuf,",");
      }
    }
    if(j==-1)
	continue;
    i=2*MAX_BBC+j;
    if(itpis_vlba[i]!=0) {
      if(strlen(ibuf)>60) {
	cls_snd(&iclass,ibuf,strlen(ibuf)-1,0,0);
	nrec=nrec+1;
	ibuf[lenstart]=0;
      }
      strcat(ibuf,lwhat[i]);
      strcat(ibuf,",");
      if(itask==5) 
	flt2str(ibuf,shm_addr->systmp[ i],8,1);
      else if(itask==6) {
	int2str(ibuf,shm_addr->tpidiff[i],5,0);
      } else if(itask==10) 
	flt2str(ibuf,shm_addr->caltemps[ i],8,3);
      strcat(ibuf,",");
    }
    if(ibuf[lenstart]!=0) {
      cls_snd(&iclass,ibuf,strlen(ibuf)-1,0,0);
      nrec=nrec+1;
      ibuf[lenstart]=0;
    }
  }
  ip[0]=iclass;
  ip[1]=nrec;
  ip[2]=0;
  return;

}
