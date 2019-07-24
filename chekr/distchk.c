/* ifd chekr routine */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void distchk_(imod,ierr,icherr)
int *imod;
int *ierr;
int icherr[5];
{
  long ip[5];                           /* ipc parameters */
  int ind;
  struct req_rec request;          /* mcbcn request record */
  struct req_buf buffer;           /* mcbcn request buffer */

  void dist_brk();
  void ini_req(), add_req(), end_req(); /*mcbcn request utilities */
  void skd_run(), skd_par();      /* program scheduling utilities */

  ini_req(&buffer);

  ind=*imod-1;                    /* index for this module */

  if(ind == 0)    /* device mnemonic */
    memcpy(request.device,DEV_VIA,2);
  else
    memcpy(request.device,DEV_VIC,2);
  
  request.type=1;
  request.addr=0x01; add_req(&buffer,&request);
  request.addr=0x02; add_req(&buffer,&request);

  end_req(ip,&buffer);
  skd_run("mcbcn",'w',ip);
  skd_par(ip);

  if(ip[2]<0) {
    *ierr=-201;
    return;
  }

  dist_brk(imod,ip,icherr,ierr);

  return;

}
