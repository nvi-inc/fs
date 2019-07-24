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

void mcbcn_d(device, ierr)
char device[2];                        /* device mnemonic */
int *ierr;                             /* error return, -1 if no such device */
                                       /*                0 okay              */
{
     dtlkup(&request,device,ierr);
     return;
}     

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
