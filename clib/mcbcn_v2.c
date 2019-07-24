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

void mcbcn_d2(device1, device2, ierr)
char device1[2],device2[2];             /* device mnemonics */
int *ierr;                             /* error return, -1 if no such device */
                                       /*                0 okay              */
{
    dtlkup( &request[0],device1,ierr);
    if(*ierr!=0) return;
    dtlkup( &request[1],device2,ierr);
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
