#include <stdio.h>

#ifdef CONFIG_GPIB
#ifdef NI_DRIVER
#include <sys/ugpib.h>
#else
#include <ib.h>
#include <ibP.h>
#endif
#else
int ibsta;
int iberr;
int ibcnt;
#endif

#define BSIZE    256

int ibser;
#include "sib.h"

int sib(int hpib, char *buffer, int len_in, int max_out, int timeout,
	int itime, long centisec[2])
{

  int lf=0x0a;
  int m1=-1,term;
  int len, ierr, icount, lenr;
  char locbuf[BSIZE];
  int p100=100;
  int tim;

  ierr = portflush_(&hpib);
  if (ierr<0)
    return -1;

  if(len_in <0)
    len=strlen(buffer);
  else
    len=len_in;

  if(len>0) {
    if(itime) {
      rte_rawt(centisec);
    }
    ierr = portwrite_(&hpib,buffer,&len);
    if(itime) {
      rte_rawt(centisec+1);
    }
    if(ierr<0)
      return -2;
  }

/* get data read from device */

  if(max_out!=0) {
    if(max_out >0 ) {
      len=max_out;
      term=-1;
    } else {
      len=-max_out;
      term=lf;
    }
    tim=timeout+30;
    ierr = portread_(&hpib,buffer,&lenr,&len,&term,&tim);

    if(ierr<0)
      return -2+ierr;

    if(max_out>0) {

      /* count */
      
      len=BSIZE-1;
      ierr = portread_(&hpib,locbuf,&lenr,&len,&lf,&p100);
      if(ierr<0)
	return -2+ierr;
    }
  }

  if(max_out >=0) {
    /* status */

    len=BSIZE-1;
    tim=timeout+30;
    ierr = portread_(&hpib,locbuf,&lenr,&len,&lf,&tim);
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

  }

  return 0;
}
