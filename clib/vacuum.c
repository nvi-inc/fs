/* vlba recorder vacuum check */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

static char device[]={"rc"};           /* device menemonics */

int vacuum(ierr)
int *ierr;
{
  int lierr;
  long ip[5];
  struct req_rec request;       /* mcbcn request record */
  struct req_buf buffer;        /* mcbcn request buffer */
  struct res_buf rbuffer;
  struct res_rec response;
  struct tape_mon lcl;

  void get_res(), opn_res();
  void mc73tape();     /* tape utility */
  void ini_req(), add_req(), end_req(); /*mcbcn request utilities */
  void skd_run(), skd_par();      /* program scheduling utilities */

  ini_req(&buffer);

  memcpy(request.device,device,2);    /* device mnemonic */

  request.type=1;
  request.addr=0x73; add_req(&buffer,&request);

  end_req(ip,&buffer);
  skd_run("mcbcn",'w',ip);
  skd_par(ip);

  if(ip[2]<0) return;

  opn_res(&rbuffer,ip);
  get_res(&response, &rbuffer); mc73tape(&lcl, response.data);
  if (response.state == -1) {
    clr_res(&rbuffer);
    *ierr=-401;
    return;
  }
  clr_res(&rbuffer);

  if ((lcl.stat & 0x40) == 0) { 
     /* vacuum not ready */
    lierr = -1;
    shm_addr->IRDYTP = 1;
  }
  else if ((lcl.stat & 0x01)==1) {
    /* error present */
    lierr = -2;
    shm_addr->IRDYTP = 1;
  }
  else {                             /* vacuum is ready */
    lierr = 0;
    shm_addr->IRDYTP = 0;
  }

  return lierr;
}
