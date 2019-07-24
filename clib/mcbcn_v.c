/* vlba module detector queries for fivpt */
/* two routines: mcbcn_d identifies the module to be sampled */
/* mcbcn_v samples it */
/* call mcbcn_d first to set-up sampling and then mcbcn_v can be */
/* called repititively for samples */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/fs_types.h"

static struct req_rec request;            /* request record set-up by _d */
                                          /* and used _v */
static char dev[2];                       /* saved device name */
static unsigned word2;                    /* saved bbc gain control */

void mcbcn_d(device, ierr,ip)
char device[2];                        /* device mnemonic */
int *ierr;                             /* error return, -1 if no such device */
                                       /*                0 okay              */
long ip[5];
{
    struct req_rec request1;
    struct req_buf buffer;
    struct res_buf buff_res;
    struct res_rec response;

     dtlkup(&request,device,ierr);
     dev[0]=device[0];
     dev[1]=device[1];
     if(*ierr !=0 ||strchr("123456789abcde",dev[0])==NULL )
       return;

/* now lock bbc gain in manual */
/* first retrieve existing gain MAN/AGC control */

    ini_req(&buffer);              /* initialize structure */

         /* copy and modify request already set-up by mcbcn_d */

    memcpy(&request1,&request,sizeof(request1));
    request1.addr = 0x02;
    add_req(&buffer,&request1);
    end_req(ip,&buffer);
    skd_run("mcbcn",'w',ip);
    skd_par(ip);
    if(ip[2]<0) {
      cls_clr(ip[0]);
      return;
    }

    opn_res(&buff_res,ip);
    get_res(&response,&buff_res);
    word2 = response.data;
    if(response.state == -1) {
      ip[2]=-94;
      memcpy(ip+3,"fp",2);
    }
    clr_res(&buff_res);

/* now set it in MAN for sure */
       
    ini_req(&buffer);              /* initialize structure */

    request1.type = 0;
    request1.data = (word2 & 0xFEFF);
    add_req(&buffer,&request1);
    end_req(ip,&buffer);
    skd_run("mcbcn",'w',ip);
    skd_par(ip);
    if(ip[2]<0) {
      cls_clr(ip[0]);
      return;
    }

    opn_res(&buff_res,ip);
    get_res(&response,&buff_res);
    if(response.state == -1) {
      ip[2]=-95;
      memcpy(ip+3,"fp",2);
    }
    clr_res(&buff_res);
    return;
}     

/* get mcb device voltage request */

void mcbcn_v(dtpi,ip)
double *dtpi;                      /* return counts */
long ip[5];
{
    struct req_buf buffer;
    struct res_buf buff_res;
    struct res_rec response;

    ini_req(&buffer);              /* initialize structure */
    add_req(&buffer,&request);     /* use request already set-up by mcbcn_d */
    end_req(ip,&buffer);
    skd_run("mcbcn",'w',ip);
    skd_par(ip);
    if(ip[2]<0) {
      cls_clr(ip[0]);
      return;
    }

    opn_res(&buff_res,ip);
    get_res(&response,&buff_res);
    *dtpi=(double) (unsigned) response.data;
    if(response.state == -1) {
      ip[2]=-90;
      memcpy(ip+3,"fp",2);
    }
    clr_res(&buff_res);
    return;
}

/* restore bbc gain */

void mcbcn_r(ip)
long ip[5];
{
    struct req_buf buffer;
    struct res_buf buff_res;
    struct res_rec response;
    struct req_rec request1;

    ip[2]=0;
    if(strchr("123456789abcde",dev[0])==NULL)
       return;

    ini_req(&buffer);              /* initialize structure */

    memcpy(&request1,&request,sizeof(request1));
    request1.type = 0;
    request1.addr = 0x02;
    request1.data = word2;

    add_req(&buffer,&request1);
    end_req(ip,&buffer);
    skd_run("mcbcn",'w',ip);
    skd_par(ip);
    if(ip[2]<0) {
      cls_clr(ip[0]);
      return;
    }

    opn_res(&buff_res,ip);
    get_res(&response,&buff_res);
    if(response.state == -1) {
      ip[2]=-96;
      memcpy(ip+3,"fp",2);
    }
    clr_res(&buff_res);
    return;
}
