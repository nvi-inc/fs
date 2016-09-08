/* fserr_cls.c - special buffer passing to/from "fserr"
   because we can't use class system here to avoid potential
   deadlock, - single buffer only 
*/

#include <string.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

extern struct fscom *shm_addr;

void fserr_snd(char *buf, int nchars)
{

  if(nchars>sizeof(shm_addr->fserr_cls.buf))
    nchars=sizeof(shm_addr->fserr_cls.buf);

  memcpy(shm_addr->fserr_cls.buf, buf, nchars);
  shm_addr->fserr_cls.nchars=nchars;

  return;
}

int fserr_rcv(char *buf, int nchars)
{

  if(nchars > shm_addr->fserr_cls.nchars)
    nchars=shm_addr->fserr_cls.nchars;

  memcpy(buf, shm_addr->fserr_cls.buf, nchars);

  return nchars;
}
