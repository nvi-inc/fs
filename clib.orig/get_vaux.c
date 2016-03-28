/* parity command utilities to support vlba drives and racks */

#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

void set_vrptrk(itrk, ip,indxtp) /* set vlba reproduce tracks */
int itrk[2];              /* Mark III tracks requested */
long ip[5];               /* ipc array */
int indxtp;
{
  struct req_buf buffer;
  struct req_rec request;
  int indx;
   
  ini_req(&buffer);              /* build a request to set tracks */

  indx=indxtp-1;

  if(indx == 0) {
    memcpy(request.device,"r1",2);
    
  } else if(indx == 1) {
    memcpy(request.device,"r2",2);
  } else {
    ip[2]=-505;
    memcpy("q<",ip+4,2);
    return;
  }

  shm_addr->vrepro[indx].track[0]=itrk[0];     /* update shared memory */
  shm_addr->vrepro[indx].track[1]=itrk[1];

  request.type=0; 
  request.addr=0x90;
  vrepro90mc(&request.data,shm_addr->vrepro+indx); add_req(&buffer,&request);

  request.addr=0x91;
  vrepro91mc(&request.data,shm_addr->vrepro+indx); add_req(&buffer,&request);

  end_req(ip,&buffer);            /* send it */
  skd_run("mcbcn",'w',ip);
  skd_par(ip);

  if(ip[0] !=0) cls_clr(ip[0]);
  return;
}
void get_verate(jperr,jsync,jbits,itrk,itper,ip)
/* retrieve vlba error counts */
long jperr[2];            /* returned parity errors */
long jsync[2];            /* returned re-sync counts */
long jbits[2];            /* returned bits processed */
int itrk[2];              /* Mark III tracks that are set-up */
int itper;                /* time period to sample for, 10s milliseconds */
long ip[5];
{
  struct req_buf buffer;
  struct req_rec request;
  struct res_buf buff_out;
  struct res_rec response;
  struct dqa_mon lclm;
  unsigned iarray[36];
  int i;
   
  for (i=0;i<36;i++)
     iarray[ i]=0;

  ini_req(&buffer);

  memcpy(request.device,DEV_VFM,2);
  request.type=0;                  /*start analysis */
  request.addr=0x88;
  request.data=0x8001;
  add_req(&buffer,&request);
  end_req(ip,&buffer);
  skd_run("mcbcn",'w',ip);
  skd_par(ip);
  if(ip[2]<0) return;
  cls_clr(ip[0]);

  rte_sleep((unsigned)itper);   /* wait requested time */

  ini_req(&buffer);                        /* stop analysis */
  request.data=0x8000;
  add_req(&buffer,&request);
  end_req(ip,&buffer);
  skd_run("mcbcn",'w',ip);
  skd_par(ip);
  if(ip[2]<0) return;
  cls_clr(ip[0]);

  ini_req(&buffer);                                 /* retrieve results */
  request.data=0;                                   /* set array index */
  request.addr=0xC8; add_req(&buffer,&request);
  request.addr=0xC9; add_req(&buffer,&request);

  request.type=1;                                   /* fetch array */
  request.addr=0xCA;
  for (i=0;i<4;i++)
     add_req(&buffer, &request);

  request.type=0;
  request.data=0;                                   /* set array index */
  request.addr=0xC8; add_req(&buffer,&request);
  request.data=12;                                   /* set array index */
  request.addr=0xC9; add_req(&buffer,&request);

  request.type=1;                                   /* fetch array */
  request.addr=0xCA;
  for (i=0;i<4;i++)
     add_req(&buffer, &request);

  request.type=0;
  request.data=0;                                   /* set array index */
  request.addr=0xC8; add_req(&buffer,&request);
  request.data=28;                                   /* set array index */
  request.addr=0xC9; add_req(&buffer,&request);

  request.type=1;                                   /* fetch array */
  request.addr=0xCA;
  for (i=0;i<8;i++)
     add_req(&buffer, &request);

  end_req(ip,&buffer);
  skd_run("mcbcn",'w',ip);
  skd_par(ip);
  if(ip[2]<0) return;

  opn_res(&buffer,ip);
  get_res(&response, &buffer);        /* fetch index set responses */
  get_res(&response, &buffer);
  for (i=0;i<4;i++) {                /* array contents */
     get_res(&response, &buffer); iarray[ i]=response.data;
  }

  get_res(&response, &buffer);        /* fetch index set responses */
  get_res(&response, &buffer);
  for (i=12;i<16;i++) {                /* array contents */
     get_res(&response, &buffer); iarray[ i]=response.data;
  }

  get_res(&response, &buffer);        /* fetch index set responses */
  get_res(&response, &buffer);
  for (i=28;i<36;i++) {              /* array contents */
    long unsigned tx;
    get_res(&response, &buffer); iarray[i]=response.data;
  }

  mcCAdqa(&lclm,iarray);
  if(response.state == -1) {
     clr_res(&buffer);
     ip[2]=-401;
     memcpy(ip+3,"vp",2);
     return;
  }
  clr_res(&buffer);

  jperr[0]=lclm.a.parity;            /* return requested info only */
  jperr[1]=lclm.b.parity;
  jsync[0]=lclm.a.resync;
  jsync[1]=lclm.b.resync;
  jbits[0]=lclm.a.num_bits;
  jbits[1]=lclm.b.num_bits;
  ip[2]=0;
  return;
}
void get_vaux(iaux,itrk,ip) /* check if aux data is correct */
int iaux[2];  /* returned, 1=no match, 0=match, -1=this channel not checked */
int itrk[2];  /* tracks are selected reproduce, 0=no track selected */
long ip[5];   /* ipc array */

/* arrays iaux and itrk are indexed by channel a=0, b=1 */
/* it is an error if the formatter is not configured for aux capture */
/* it is also an error if the aux configured for capture  (a or b) does */
/*    not have a selected track (itrk array) */
{
  struct req_buf buffer;
  struct req_rec request;
  struct res_buf buff_out;
  struct res_rec response;
  struct capture_mon lclm;
  int iab;
   
  switch (shm_addr->vform.qa.chan) {  /* check module set-up */
    case 3:                           /* a aux */
        if(itrk[0]==0) {              /* caller doesn't want a */
          ip[2]=-402;
          memcpy(ip+3,"vp",2);
          return;
        }
        iab=0;
        break;
    case 7:                           /* b aux */
        if(itrk[1]==0) {              /* caller doesn't want b */
          ip[2]=-403;   
          memcpy(ip+3,"vp",2);
          return;
        }
        iab=1;
        break;
    default:                          /* we aren't set-up for aux */
        ip[2]=-404;
        memcpy(ip+3,"vp",2);
        return;
  }

  ini_req(&buffer);

  memcpy(request.device,DEV_VFM,2);

  request.type=0;                  /* start capture */
  request.addr=0x89;
  request.data=0x8001;
  add_req(&buffer,&request);
  end_req(ip,&buffer);
  skd_run("mcbcn",'w',ip);
  skd_par(ip);
  if(ip[2]<0) return;
  cls_clr(ip[0]);

  rte_sleep((unsigned)2);   /* wait the shortest time */

  ini_req(&buffer);                                 /* retrieve results */
  request.data=1;                                   /* set array index */
  request.addr=0x48; add_req(&buffer,&request);
  request.addr=0x49; add_req(&buffer,&request);

  end_req(ip,&buffer);
  skd_run("mcbcn",'w',ip);
  skd_par(ip);
  if(ip[2]<0) return;

  opn_res(&buffer,ip);
  get_res(&response, &buffer); mc48capture(&lclm,&response);
  get_res(&response, &buffer); mc49capture(&lclm,&response);

  if(response.state == -1) {
     clr_res(&buffer);
     ip[2]=-402;
     memcpy(ip+3,"vp",2);
     return;
  }
  clr_res(&buffer);
  
  iaux[iab]=0;
  iaux[1-iab]=-1;
  if(lclm.general.word1 != shm_addr->vform.aux[0][1] ||
     lclm.general.word2 != shm_addr->vform.aux[0][2] )
      iaux[iab]=1;
  
  return;
}

