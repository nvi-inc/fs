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

static char ch[ ]={"123456789abcde"};
static char *lwhat[ ]={
"1l","2l","3l","4l","5l","6l","7l","8l","9l","al","bl","cl","dl","el",
"1u","2u","3u","4u","5u","6u","7u","8u","9u","au","bu","cu","du","eu",
"ia","ib","ic","id"};

void tpi_vlba(ip,itpis_vlba,isub)                    /* sample tpi(s) */
long ip[5];                                     /* ipc array */
int itpis_vlba[MAX_DET]; /* detector selection array */
                      /* in order: L: bbc1...bbc14, U: bbc1...bbc14(U)       */
                      /*           ia, ib, ic, id; value: 0=don't use, 1=use */
int isub;
{
    struct req_buf buffer;
    struct req_rec request;
    int i;

    ini_req(&buffer);
    request.type=21;

    if(isub!=8) {
      for (i=0;i<MAX_DET;i++) {
	if(1==itpis_vlba[i]) {
	  if(i<(2*MAX_BBC)) {                   /* bbc(s): */
	    request.device[0]='b';
	    request.device[1]=ch[i%MAX_BBC];                /* '1'-'e' */
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
	  request.device[1]=ch[i%MAX_BBC];                /* '1'-'e' */
	  
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
long ip[5];                                    /* ipc array */
int itpis_vlba[MAX_DET]; /* device selection array, see tpi_vlba for details */
int isubin;                /* which task: 3=tpi, 4=tpical, 7=tpzero */
char *ibuf;              /* out array, formatted results placed here */
int *nch;                /* next available char index in ibuf on entry */
                         /* the total count on exit, counts from 1 , not 0 */
int ilen;                /* number of characters ibuf can hold, ignored */
{
    struct res_buf buffer_out;
    struct res_rec response;
    long *ptr;
    int i,j,iclass,nrec,lenstart,isub;

    isub=abs(isubin);

    opn_res(&buffer_out,ip);

    switch (isub) {                        /* set the pointer for the type */
       case 3: ptr=shm_addr->tpi; break;
       case 4: ptr=shm_addr->tpical; break;
       case 7: ptr=shm_addr->tpizero; break;
       case 8: ptr=shm_addr->tpigain; break;
       default: ptr=shm_addr->tpi; break;    /* just being defensive */
    };


    if(isub!=8) {
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
    for(j=-1;j<4;j++) {
      int k;
      for(k=0;k<MAX_BBC*2;k++) {
	i=14*(k%2)+k/2;
	if(itpis_vlba[ i] == 1 && shm_addr->bbc[i%14].source==j) {
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
	  } else if (isub==8 && ptr[i] >0xFE) {
	    strcat(ibuf,"$$$,");
	  } else {
	    int2str(ibuf,ptr[i],5);
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
	  int2str(ibuf,ptr[i],5);
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

void tsys_vlba(ip,itpis_vlba,ibuf,nch,caltmp)
long ip[5];                                    /* ipc array */
int itpis_vlba[MAX_DET]; /* device selection array, see tpi_vlba for details */
char *ibuf;              /* out array, formatted results placed here */
int *nch;                /* next available char index in ibuf on entry */
                         /* the total count on exit, counts from 1 , not 0 */
float caltmp[4];
{
  int i,j, inext,iclass,nrec, ind,lenstart;
  float tpi,tpic,tpiz;

  for (i=0;i<MAX_DET;i++) {
    if(itpis_vlba[ i] == 1) {
      int kskip;
      kskip=i<2*MAX_BBC&&
	(shm_addr->bbc[i%14].source<0||shm_addr->bbc[i%14].source>3);
      tpi=shm_addr->tpi[ i];             /* various pieces */
      tpic=shm_addr->tpical[ i];
      tpiz=shm_addr->tpizero[ i];        /* avoid overflow | div-by-0 */
      if(kskip)
	shm_addr->systmp[ i]=-1.0;
      else if(fabs((double)(tpic-tpi))<0.5 || tpic > 65534 || tpi > 65534
	     || tpiz < 1 )
	shm_addr->systmp[ i]=1e9;
      else {
	int ind;
	if(i<2*MAX_BBC)
	  ind=shm_addr->bbc[i%14].source;
	else 
	  ind=i-2*MAX_BBC;
	shm_addr->systmp[ i]=(tpi-tpiz)*caltmp[ind]/(tpic-tpi);
      }
      if(shm_addr->systmp[ i]>999999.95 || shm_addr->systmp[ i] <0.0)
	logita(NULL,-211,"qk",lwhat[i]);
    }
  }

  ibuf[*nch-1]='\0';              /* NULL terminate to make STRING */
  lenstart=strlen(ibuf);
  iclass=0;
  nrec=0;
  for(j=-1;j<4;j++) {
    int k;
    for(k=0;k<MAX_BBC*2;k++) {
      if(k%2==0)
	i=k/2;
      else
	i=14+k/2;
      if(itpis_vlba[ i] == 1 && shm_addr->bbc[i%14].source==j) {
	if(strlen(ibuf)>60) {
	  cls_snd(&iclass,ibuf,strlen(ibuf)-1,0,0);
	  nrec=nrec+1;
	  ibuf[lenstart]=0;
	}
	strcat(ibuf,lwhat[i]);
	strcat(ibuf,",");
	flt2str(ibuf,shm_addr->systmp[ i],8,1);
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
      flt2str(ibuf,shm_addr->systmp[ i],8,1);
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
