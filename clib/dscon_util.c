/* DSCON interface daemon utilities */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include "../include/params.h"
#include "../include/ds_ds.h"

#define NUL	0x00
#define ACK	0x06
#define BEL	0x07
#define NAK	0x15

/* function prototypes */
void cls_snd();				/* class buffer routines */
int cls_rcv();
void skd_run(), skd_par();

void dscon_snd(lcl,ip)
  struct ds_cmd *lcl;
  long ip[5];
{
  unsigned char buf[6];
  unsigned short header;

   buf[0] = lcl->mnem[0];
   buf[1] = lcl->mnem[1];
   header = ((lcl->type & 0x01) << 15) | (0x01 << 14) |
            ((0x0000 & 0x1F) << 9) | (lcl->cmd & 0x1FF);
   buf[2] = ((header & 0xFF00) >> 8);
   buf[3] = (header & 0x00FF);
   buf[4] = ((lcl->data & 0xFF00) >> 8);
   buf[5] = (lcl->data & 0x00FF);

   ip[0] = 1;
   cls_snd(&ip[1],buf,6,0,0);
   ip[2]++;

   return;
}

int dscon_rcv(lclm,ip)
  struct ds_mon *lclm;
  long int ip[5];
{
   unsigned char buf[3];
   int nchar, dum;

   if ((nchar=cls_rcv(ip[0],&buf,3,&dum,&dum,0,0)) < 0) return(-401);

   lclm->resp = buf[0];
   lclm->data.value = (buf[1] << 8) | buf[2];

   return(lclm->resp!=ACK);
}

int run_dscon(ip)		/* runs DSCON via field system scheduling */
  long ip[5];
{
/* Launch DSCON via Field System scheduling environment, passing class buffer
   commands via IP[].  Wait until DSCON completes, pick up the IP[] class
   buffer return info, and signal if DSCON encountered any problems.       */

  skd_run("dscon",'w',ip);	/* launch DSCON and wait for completion */
  skd_par(ip);			/* pick up parameters returned by DSCON */
  return(ip[2]==0);		/* success if DSCON returns ip[2]=ierr=0 */
}
