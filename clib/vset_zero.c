/* vlba attenuator adjustment utilities for fivpt */
/* three routines: vget_att retrieves the current att set-up */
/*                 vset_zero maximizes atten, (zero signal) */
/*                 vrst_att restores original levels */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

static struct dist_cmd lclsave[2];     /* saved if states */

void vget_att(lwho,ip)
char lwho[2];
long ip[5];
{
    struct req_buf buffer;
    struct req_rec request;
    struct res_buf buff_res;
    struct res_rec response;

  /* get the current attenuator settings */

    ini_req(&buffer);              /* initialize structure */

    request.type=1;
    request.addr=0x01;
    memcpy(request.device,"ia",2);
    add_req(&buffer,&request);     

    memcpy(request.device,"ic",2);
    add_req(&buffer,&request);     

    end_req(ip,&buffer);
    skd_run("mcbcn",'w',ip);
    skd_par(ip);
    if(ip[2]<0) {
      cls_clr(ip[0]);
      return;
    }

    opn_res(&buff_res,ip);
    get_res(&response,&buff_res);
    mc01dist(&lclsave[0],response.data);          /* save 'ia' set-up */

    get_res(&response,&buff_res);
    mc01dist(&lclsave[1],response.data);          /* save 'ic' set-up */

    if(response.state == -1) {
      clr_res(&buff_res);
      ip[2]=-91;
      memcpy(ip+3,lwho,2);
    }
    clr_res(&buff_res);
    ip[2]=0;
    return;
}

void vset_zero(lwho,ip)            /* max. atten. (zeroes signal) */
char lwho[2];
long ip[5];
{
    struct req_buf buffer;
    struct req_rec request;
    struct res_buf buff_res;
    struct res_rec response;
    struct dist_cmd lcl;

    ini_req(&buffer);
    request.type=0;
    request.addr=0x01;

    memcpy(request.device,"ia",2);             /* set 'ia' atten */
    memcpy(&lcl,&lclsave[0],sizeof(lcl));
    lcl.atten[ 0]=1;             
    lcl.atten[ 1]=1;
    dist01mc(&request.data,&lcl);
    add_req(&buffer,&request);     

    memcpy(request.device,"ic",2);             /* set 'ic' atten */
    memcpy(&lcl,&lclsave[1],sizeof(lcl));
    lcl.atten[ 0]=1;             
    lcl.atten[ 1]=1;
    dist01mc(&request.data,&lcl);
    add_req(&buffer,&request);     
    
    end_req(ip,&buffer);
    skd_run("mcbcn",'w',ip);
    skd_par(ip);
    if(ip[2]<0) {
      cls_clr(ip[0]);
      return;
    }

    opn_res(&buff_res,ip);
    get_res(&response,&buff_res);
    get_res(&response,&buff_res);

    if(response.state == -1) {
      clr_res(&buff_res);
      ip[2]=-92;
      memcpy(ip+3,lwho,2);
    }
    clr_res(&buff_res);
    ip[2]=0;
    return;
}
void vrst_att(lwho,ip)            /* restore attenuators */
char lwho[2];
long ip[5];
{
    struct req_buf buffer;
    struct req_rec request;
    struct res_buf buff_res;
    struct res_rec response;
    struct dist_cmd lcl;

    ini_req(&buffer);
    request.type=0;
    request.addr=0x01;

    memcpy(request.device,"ia",2);             /* set 'ia' atten */
    memcpy(&lcl,&lclsave[0],sizeof(lcl));
    dist01mc(&request.data,&lcl);
    add_req(&buffer,&request);     

    memcpy(request.device,"ic",2);             /* set 'ic' atten */
    memcpy(&lcl,&lclsave[1],sizeof(lcl));
    dist01mc(&request.data,&lcl);
    add_req(&buffer,&request);     
    
    end_req(ip,&buffer);
    skd_run("mcbcn",'w',ip);
    skd_par(ip);
    if(ip[2]<0) {
      cls_clr(ip[0]);
      return;
    }

    opn_res(&buff_res,ip);
    get_res(&response,&buff_res);
    get_res(&response,&buff_res);

    if(response.state == -1) {
      clr_res(&buff_res);
      ip[2]=-93;
      memcpy(ip+3,lwho,2);
    }
    clr_res(&buff_res);
    ip[2]=0;
    return;
}
