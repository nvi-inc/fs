/* lba module detector queries for fivpt */
/* two routines: dscon_d identifies the module to be sampled */
/* dscon_v samples it */
/* call dscon_d first to set-up sampling and then dscon_v can be */
/* called repititively for samples */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

long lba_tpi_from_level(unsigned short level);

static struct ds_cmd lcl;                 /* request record set-up by _d */
                                          /* and used _v */
static char dev[2];                       /* saved device name */
static short ifp;			  /* saved ifp number */

void dscon_d(device, ierr,ip)
char device[2];                        /* device mnemonic */
int *ierr;                             /* error return, -1 if no such device */
                                       /*                0 okay              */
long ip[5];
{
     if (device[0]!='p'||!isxdigit(device[1])) {
        *ierr = -1;
        return;
     }
     sscanf(device+1,"%1hx",&ifp); ifp-=1;
     lcl.type = DS_MON;
     strcpy(lcl.mnem,shm_addr->das[ifp/2].ds_mnem);
     lcl.cmd = 160 + (ifp%2 * 32) + 29;
     dev[0]=device[0];
     dev[1]=device[1];

    return;
}     

/* get dataset device voltage request */

void dscon_v(dtpi,ip)
double *dtpi;                      /* return counts */
long ip[5];
{
    struct ds_mon lclm;

    /* transmit request setup by dscon_d */
    dscon_snd(&lcl,ip);
    run_dscon(ip);
    if(ip[2]<0) {
      cls_clr(ip[0]);
      return;
    }

    if(dscon_rcv(&lclm,ip)) {
      if(shm_addr->das[ifp/2].ifp[0].initialised)
        shm_addr->das[ifp/2].ifp[0].initialised = -1;
      if(shm_addr->das[ifp/2].ifp[1].initialised)
        shm_addr->das[ifp/2].ifp[1].initialised = -1;
       cls_clr(ip[0]);
       ip[2]=-90;
       memcpy(ip+3,"fp",2);
       return;
    } else {
      *dtpi=lba_tpi_from_level(lclm.data.value);
    }
    cls_clr(ip[0]);

    return;
}
