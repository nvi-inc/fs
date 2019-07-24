/* chekr rec routine */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void recchk_(icherr,ierr)
int icherr[];
int *ierr;
{
  long ip[5];                           /* ipc parameters */
  struct req_rec request;       /* mcbcn request record */
  struct req_buf buffer;        /* mcbcn request buffer */
  struct vst_cmd lcl;
  struct venable_cmd lcv;        /* general recording structure */

  char *arg_next();

  void rec_brk();
  void ini_req(), add_req(), end_req(); /*mcbcn request utilities */
  void skd_run(), skd_par();      /* program scheduling utilities */

  ini_req(&buffer);

  memcpy(request.device,DEV_VRC,2);    /* device mnemonic */

  request.type=1;
  request.addr=0x81; add_req(&buffer,&request);
  request.addr=0x73; add_req(&buffer,&request);
  request.addr=0xb1; add_req(&buffer,&request);
  request.addr=0xb5; add_req(&buffer,&request);
  request.addr=0xb6; add_req(&buffer,&request);
  request.addr=0x30; add_req(&buffer,&request);

  end_req(ip,&buffer);
  skd_run("mcbcn",'w',ip);
  skd_par(ip);

  if (ip[2]<0) {
    *ierr=-201;
    return;
  }

  rec_brk(icherr,ierr,ip);

  return;

}
