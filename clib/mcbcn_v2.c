/* vlba module detector queries for onoff */
/* two routines: mcbcn_d2 identifies two modules to be sampled */
/* mcbcn_v2 samples them */
/* call mcbcn_d2 first to set-up sampling and then mcbcn_v2 can be */
/* called repititively for samples */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/fs_types.h"

static struct req_rec request[2];        /* request records set-up by dtlkup */
static char dev1[2],dev2[2];
static unsigned word2d1,word2d2;
static char bbcs[]={"123456789abcde"};
static int b1, b2;

void mcbcn_d2(device1, device2, ierr, ip)
char device1[2],device2[2];             /* device mnemonics */
int *ierr;                             /* error return, -1 if no such device */
                                       /*                0 okay              */
long ip[5];
{
    struct req_rec request1[2];
    struct req_buf buffer;
    struct res_buf buff_res;
    struct res_rec response;
    static char bbcs[]={"123456789abcde"};

    dtlkup( &request[0],device1,ierr);
    dev1[0]=device1[0];
    dev1[1]=device1[1];
    if(*ierr!=0)
      return;

    dtlkup( &request[1],device2,ierr);
    dev2[0]=device2[0];
    dev2[1]=device2[1];

    b1=strchr(bbcs,dev1[0]) != NULL;
    b2=strchr(bbcs,dev2[0]) != NULL;
    if(*ierr!=0 || (!b1 && !b2) )
       return;

/* retrive gain MAN/AGC control for any BBC's we might be using */

    ini_req(&buffer);              /* initialize structure */
    if(b1) {
      memcpy(&request1[0],&request[0],sizeof(request1[0]));
      request1[0].addr=0x02;
      add_req(&buffer,&request1[0]);  
    }
    if(b2) {
      memcpy(&request1[1],&request[1],sizeof(request1[1]));
      request1[1].addr=0x02;
      add_req(&buffer,&request1[1]);  
    }
    end_req(ip,&buffer);
    skd_run("mcbcn",'w',ip);
    skd_par(ip);
    if(ip[2]<0) {
      cls_clr(ip[0]);
      return;
    }

    opn_res(&buff_res,ip);
    if(b1) {
      get_res(&response,&buff_res);
      word2d1=response.data;
    }
    if(b2) {
      get_res(&response,&buff_res);
      word2d2=response.data;
    }
    if(response.state == -1) {
      ip[2]=-94;
      memcpy(ip+3,"nf",2);
    }
    clr_res(&buff_res);

/* now lock down bbcs to manual */

    ini_req(&buffer);              /* initialize structure */
    if(b1) {
      request1[0].type=0;
      request1[0].data=word2d1 & 0xFEFF;
      add_req(&buffer,&request1[0]);  
    }
    if(b2) {
      request1[1].type=0;
      request1[1].data=word2d2 & 0xFEFF;
      add_req(&buffer,&request1[1]);  
    }
    end_req(ip,&buffer);
    skd_run("mcbcn",'w',ip);
    skd_par(ip);
    if(ip[2]<0) {
      cls_clr(ip[0]);
      return;
    }

    opn_res(&buff_res,ip);
    if(b1) {
      get_res(&response,&buff_res);
    }
    if(b2) {
      get_res(&response,&buff_res);
    }
    if(response.state == -1) {
      ip[2]=-95;
      memcpy(ip+3,"nf",2);
    }
    clr_res(&buff_res);

    return;
}     

void mcbcn_v2(dtpi1,dtpi2,ip)
double *dtpi1,*dtpi2;                      /* return counts */
long ip[5];
{
    struct req_buf buffer;
    struct res_buf buff_res;
    struct res_rec response;

    ini_req(&buffer);              /* initialize structure */
    add_req(&buffer,&request[0]);  /* use request already set-up by mcbcn_d2 */
    add_req(&buffer,&request[1]);
    end_req(ip,&buffer);
    skd_run("mcbcn",'w',ip);
    skd_par(ip);
    if(ip[2]<0) {
      cls_clr(ip[0]);
      return;
    }

    opn_res(&buff_res,ip);
    get_res(&response,&buff_res);
    *dtpi1=(double) (unsigned) response.data;
    get_res(&response,&buff_res);
    *dtpi2=(double) (unsigned) response.data;
    if(response.state == -1) {
      ip[2]=-90;
      memcpy(ip+3,"nf",2);
    }
    clr_res(&buff_res);
    return;
}

void mcbcn_r2(ip)
long ip[5];
{
    struct req_rec request1[2];
    struct req_buf buffer;
    struct res_buf buff_res;
    struct res_rec response;

    if(!b1 && !b2)
       return;

/* reset gains to whatever the were */

    ini_req(&buffer);              /* initialize structure */
    if(b1) {
      memcpy(&request1[0],&request[0],sizeof(request1[0]));
      request1[0].type=0;
      request1[0].addr=0x02;
      request1[0].data=word2d1;
      add_req(&buffer,&request1[0]);  
    }
    if(b2) {
      memcpy(&request1[1],&request[1],sizeof(request1[1]));
      request1[1].type=0;
      request1[1].addr=0x02;
      request1[1].data=word2d2;
      add_req(&buffer,&request1[1]);  
    }
    end_req(ip,&buffer);
    skd_run("mcbcn",'w',ip);
    skd_par(ip);
    if(ip[2]<0) {
      cls_clr(ip[0]);
      return;
    }

    opn_res(&buff_res,ip);
    if(b1) {
      get_res(&response,&buff_res);
    }
    if(b2) {
      get_res(&response,&buff_res);
    }
    if(response.state == -1) {
      ip[2]=-96;
      memcpy(ip+3,"nf",2);
    }
    clr_res(&buff_res);

    return;
}     
