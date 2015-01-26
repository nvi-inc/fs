/* bbc chekr routine */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

static char device[]={"b1b2b3b4b5b6b7b8b9babbbcbdbebfbg"};
                       /* device menemonics */
                       /* -1 marks end of array only */
void bbchk_(imod,icherr,ierr)
int *imod;
int icherr[10];
int *ierr;
{
  long ip[5];                           /* ipc parameters */
  int ind;
  struct req_rec request;      /* mcbcn request record */
  struct req_buf buffer;       /* mcbcn request buffer */

  void bbc_brk();
  void ini_req(), add_req(), end_req(); /*mcbcn request utilities */
  void skd_run(), skd_par();      /* program scheduling utilities */

  ini_req(&buffer);

  ind=*imod-1;                    /* index for this module */

  request.device[0]=device[ind*2];    /* device mnemonic */
  request.device[1]=device[ind*2+1];

  request.type=1;
  request.addr=0x00; add_req(&buffer,&request);
  request.addr=0x01; add_req(&buffer,&request);
  request.addr=0x02; add_req(&buffer,&request);
  request.addr=0x03; add_req(&buffer,&request);
  request.addr=0x04; add_req(&buffer,&request);
/*  request.addr=0x05; add_req(&buffer,&request);
  not implemented yet
*/
  request.addr=0x06; add_req(&buffer,&request);
  request.addr=0x07; add_req(&buffer,&request);

  end_req(ip,&buffer);
  nsem_take("fsctl",0);
  skd_run("mcbcn",'w',ip);
  nsem_put("fsctl");
  skd_par(ip);

  if (ip[2]<0) {  
    shm_addr->bbc_tpi[ind][0]=65536;
    shm_addr->bbc_tpi[ind][1]=65536;
    logita(NULL,ip[2],ip+3,ip+4);
    *ierr=-201;
    return;
  }

  bbc_brk(*imod,ip,icherr,ierr);

  return;
}
