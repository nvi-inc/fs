#include <stdio.h>

#ifdef CONFIG_GPIB
#include <ib.h>
#include <ibP.h>
#else
extern int ibsta;
extern int iberr;
extern int ibcnt;
#endif

#define BSIZE    256

int ibser;
#include "sib.h"

int sib(int hpib, char *buffer, int len_in, int max_out, int timeout)
{

  int lf=0x0a;
  int m1=-1;
  int len, ierr, icount, lenr;
  char locbuf[BSIZE];
  int p100=100;

  ierr = portflush_(&hpib);
  if (ierr<0)
    return -1;

  if(len_in <=0)
    len=strlen(buffer);
  else
    len=len_in;

  ierr = portwrite_(&hpib,buffer,&len);
  if(ierr<0)
    return -2;
  
/* get data read from device */

  if(max_out>0) {
    len=max_out;
    ierr = portread_(&hpib,buffer,&lenr,&len,&m1,&timeout);
    if(ierr<0)
      return -2+ierr;

    /* count */
    
    ierr = portread_(&hpib,locbuf,&lenr,&len,&lf,&p100);
    if(ierr<0)
      return -2+ierr;
  }

/* status */

  len=BSIZE-1;
  ierr = portread_(&hpib,locbuf,&lenr,&len,&lf,&p100);
  if(ierr<0)
    return -2+ierr;

  locbuf[lenr]='\0';
  icount=sscanf(locbuf,"%d\r",&ibsta);
  if(icount !=1)
    return -6;

/* IB error */

  len=BSIZE-1;
  ierr = portread_(&hpib,locbuf,&lenr,&len,&lf,&p100);
  if(ierr<0)
    return -2+ierr;

  locbuf[lenr]='\0';
  icount=sscanf(locbuf,"%d\r",&iberr);
  if(icount !=1)
    return -7;

/* serial error */

  len=BSIZE-1;
  ierr = portread_(&hpib,locbuf,&lenr,&len,&lf,&p100);
  if(ierr<0)
    return -2+ierr;

  locbuf[lenr]='\0';
  icount=sscanf(locbuf,"%d\r",&ibser);
  if(icount !=1)
    return -8;

/* count */

  len=BSIZE-1;
  ierr = portread_(&hpib,locbuf,&lenr,&len,&lf,&p100);
  if(ierr<0)
    return -2+ierr;

  locbuf[lenr]='\0';
  icount=sscanf(locbuf,"%d\r",&ibcnt);
  if(icount !=1)
    return -9;

  return 0;
}
