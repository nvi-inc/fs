/* chekr formatter routine */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void vformchk_(icherr,ierr)
int icherr[5];
int *ierr;
{
  long ip[5];                           /* ipc parameters */
  int i, j;
  int  aux_track;
  unsigned long iptr;
  struct req_rec request;        /* mcbcn request record */
  struct req_buf buffer;         /* mcbcn request buffer */

  void vform_brk();
  void ini_req(), add_req(), end_req(); /*mcbcn request utilities */
  void skd_run(), skd_par();      /* program scheduling utilities */

  ini_req(&buffer);

  memcpy(request.device,DEV_VFM,2);    /* device mnemonic */

  request.type=0;                      /* set indirect track address */
  request.data=0;
  request.addr=0xD0; add_req(&buffer,&request);
  request.addr=0xD1; add_req(&buffer,&request);

  request.type=1; request.addr=0xD2;   /* get 32 track assignements */
  for (i=0;i<32;i++)
     add_req(&buffer,&request);

  request.addr=0x8D; add_req(&buffer,&request); /* low track enables */
  request.addr=0x8E; add_req(&buffer,&request); /* high track enables */
  request.addr=0x8F; add_req(&buffer,&request); /* system track enables*/
  request.addr=0x90; add_req(&buffer,&request);
  request.addr=0x91; add_req(&buffer,&request);
  request.addr=0x99; add_req(&buffer,&request);
  request.addr=0x9A; add_req(&buffer,&request);
  request.addr=0xAD; add_req(&buffer,&request);

  goto skip_aux;
  for (i=0;i<28;i++) {                   /* 28 tracks of aux data */
    if(i<14) aux_track=i+1; /* calculate formatter track number */
    else aux_track=i+3;

    iptr=aux_track*16;                   /* indirect address */

    request.type=0;                      /* set aux buffer address */
    request.data=0xFFFF & (iptr>>16);    /* msw */
    request.addr=0xD4; add_req(&buffer,&request);

    request.data=0xFFFF & iptr;          /* lsw */
    request.addr=0xD5; add_req(&buffer,&request);

    request.type=1;                      /* fetch aux data */
    request.addr=0xD6;
    for (j=0;j<4;j++) add_req(&buffer,&request);  /* 4 words per track */
  }
skip_aux:

  end_req(ip,&buffer);
  skd_run("mcbcn",'w',ip);
  skd_par(ip);

  if(ip[2]<0) {
    *ierr=-201;
    return;
  }

  vform_brk(ip,icherr,ierr);

  return;

}
