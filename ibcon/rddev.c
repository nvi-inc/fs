/*
 * The device drivers have already been opened.
 * NRV 921124 Added external board ID reference (got in opbrd) and
            call to ibcmd to do an "untalk" to the board before reading.
 */
#include <memory.h>
#include <string.h>
#include <stdio.h>
#include <errno.h>

#ifdef CONFIG_GPIB
#include <ib.h>
#include <ibP.h>
#else
extern int ibsta;
extern int iberr;
extern int ibcnt;
#endif

extern int ibser;
#include "sib.h"

#define	LF		0x0A
#define TIMEOUT		-4
#define BUS_ERROR	-8
#define HPIBERR		-20
#define BSIZE 		256   /* this size for DMA */
#define IBCODE		300
#define IBSCODE		300
#define ASCII		  0
#define BINARY		  1

extern int ID_hpib;
extern int serial;

static int ascii_last=-1;
static int read_size;

/*-------------------------------------------------------------------------*/

int rddev_(mode,devid,buffer,buflen,error, ipcode, timeout)

/* rddev returns the count of the number of bytes read, if there are
   no errors.

   The mode flag indicates ASCII (1) or BINARY (3) data reads.
 
   If an error occurs, *error is set to -4 for a timeout, -8 for a bus
   error. If a bus error occurs, rddev returns the system error variable.
*/
int *mode,*devid;
long *ipcode;
unsigned char *buffer;
int *buflen;  /* buffer length in characters */
int *error;
int *timeout;

{
  int i;
  int iret, ierr;
  unsigned char lret,locbuf[BSIZE];
  int val, icopy;

  *error = 0;
  *ipcode = 0;

/* 
 * The termination character (line feed, 0x0A) is set in the
 * configuration file for the device located in /dev directory.
 * The read command is set to terminate on the EOS value. This is set
 * in the configuration file along with the device flag REOS. 
 * The DMA parameter in the configuration file (ibboard) for the board 
 * must be turned on (set to 1) for the read to work properly. The number
 * of characters to be read with the ibrd command must also be set high, 
 * 256 in this case works.
 */

#if 0
  if(!serial) {
#ifdef CONFIG_GPIB
    ibcmd(ID_hpib,"_?",2);  	/* unaddress all listeners and talkers */
    if ((ibsta & (ERR|TIMO)) != 0) {
      if(iberr==0)
	logit(NULL,errno,"un");
      *error = -(IBCODE + iberr); 
      memcpy((char *)ipcode,"RC",2);
      return(-1);
    } 
#else
    *error = -(IBCODE + 22);
    return -1;
#endif
  } else {
    ierr=sib(ID_hpib,"cm \n_?\r",0,0,100);
    if(ierr<0) {
      if(ierr==-1 || ierr==-2 || ierr==-5)
	logit(NULL,errno,"un");
      *error = -520+ierr;
      memcpy((char *)ipcode,"RC",2);
      return -1;
    } else if(ibsta&(S_ERR|S_TIMO)) {
      if(ibser!=0)
	logit(NULL,-(540 + ibser),"RC");
      *error = -(IBSCODE + iberr);
      memcpy((char *)ipcode,"RC",2);
      return -1;
    }
  }
#endif

  if (*mode == 1 && ascii_last!=1) {
    if (!serial) {
#ifdef CONFIG_GPIB
      val = (REOS << 8) + LF;
      ibeos(*devid,val);        /* set to read until REOS+EOS is detected */
      if ((ibsta & (ERR|TIMO)) != 0) {
	if(iberr==0)
	  logit(NULL,errno,"un");
	*error = -(IBCODE + iberr); 
	memcpy((char*)ipcode,"RS",2);
	return(-1);
      }
#else
      *error = -(IBCODE + 22);
      return -1;
#endif
    } else {
      ierr=sib(ID_hpib,"eos R 10\r",0,0,100);
      if(ierr<0) {
	if(ierr==-1 || ierr==-2 || ierr==-5)
	  logit(NULL,errno,"un");
	*error = -520+ierr;
	memcpy((char *)ipcode,"RS",2);
	return -1;
      } else if(ibsta&(S_ERR|S_TIMO)) {
	if(ibser!=0)
	  logit(NULL,-(540 + ibser),"RS");
	*error = -(IBSCODE + iberr);
	memcpy((char *)ipcode,"RS",2);
	return -1;
      }
    }
    ascii_last=1;
    read_size=30;
  } else if (*mode != 1 && ascii_last != 0) {
    if (!serial) {
#ifdef CONFIG_GPIB
      ibeos(*devid,0);		/* turn off all EOS detection */
      if ((ibsta & (ERR|TIMO)) != 0) {
	if(iberr==0)
	  logit(NULL,errno,"un");
	*error = -(IBCODE + iberr); 
	memcpy((char*)ipcode,"RT",2);
	return(-1);
      }
#else
      *error = -(IBCODE + 22);
      return -1;
#endif
    } else {
      ierr=sib(ID_hpib,"eos D\r",0,0,100);
      if(ierr<0) {
	if(ierr==-1 || ierr==-2 || ierr==-5)
	  logit(NULL,errno,"un");
	*error = -520+ierr;
	memcpy((char *)ipcode,"RT",2);
	return -1;
      } else if(ibsta&(S_ERR|S_TIMO)) {
	if(ibser!=0)
	  logit(NULL,-(540 + ibser),"RT");
	*error = -(IBSCODE + iberr);
	memcpy((char *)ipcode,"RT",2);
	return -1;
      }
    }
    ascii_last=0;
    read_size=BSIZE;
  }

  if (!serial) {
#ifdef CONFIG_GPIB
    ibrd(*devid,locbuf,BSIZE);    
    if ((ibsta & TIMO) != 0) {	/* has the device timed out? */ 
      *error = TIMEOUT;
      memcpy((char *)ipcode,"RE",2);
      return(-1);
    } else if ((ibsta & ERR) != 0) { /* if not, some other type of error */
      if(iberr==0)
	logit(NULL,errno,"un");
      *error = -(IBCODE + iberr);
      memcpy((char *)ipcode,"RE",2);
      return(-1);
    }
#else
    *error = -(IBCODE + 22);
    return -1;
#endif
  } else {
    sprintf(locbuf,"rd #%d %d\r",read_size,*devid);
    ierr=sib(ID_hpib,locbuf,0,read_size,*timeout);
    if(ierr<0) {
      if(ierr==-1 || ierr==-2 || ierr==-5)
	logit(NULL,errno,"un");
      *error = -520+ierr;
      memcpy((char *)ipcode,"RE",2);
      return -1;
    } else if ((ibsta & S_TIMO) != 0) {      /* has the device timed out? */ 
      *error = TIMEOUT;
      memcpy((char *)ipcode,"RE",2);
      return(-1);
    } else if ((ibsta & S_ERR) != 0) { /* if not, some other type of error */
      if(ibser!=0)
	logit(NULL,-(540 + ibser),"RE");
      *error = -(IBSCODE + iberr);
      memcpy((char *)ipcode,"RE",2);
      return(-1);
    }
  }

  iret = ibcnt;

#if 0
  if (!serial) {
#ifdef CONFIG_GPIB
    ibcmd(ID_hpib,"_?",2);  	/* unaddress all listeners and talkers */
    if ((ibsta & (ERR|TIMO)) != 0) {
      if(iberr==0)
	logit(NULL,errno,"un");
      *error = -(IBCODE + iberr); 
      memcpy((char *)ipcode,"RD",2);
      return(-1);
    }
#else
    *error = -(IBCODE + 22);
    return -1;
#endif
  } else {
    ierr=sib(ID_hpib,"cm \n_?\r",0,0,100);
    if(ierr<0) {
      if(ierr==-1 || ierr==-2 || ierr==-5)
	logit(NULL,errno,"un");
      *error = -520+ierr;
      memcpy((char *)ipcode,"RD",2);
      return -1;
    } else if(ibsta&(S_ERR|S_TIMO)) {
      if(ibser!=0)
	logit(NULL,-(540 + ibser),"RD");
      *error = -(IBSCODE + iberr);
      memcpy((char *)ipcode,"RD",2);
      return -1;
    }
  }
#endif

  if (*mode == 1) {  
    if (iret <= 0)
      return (0);
    else
      lret = locbuf[iret-1];
    
    while ((iret > 0) && (strchr("\r\n",lret) != 0))
      lret = locbuf[--iret-1];
  }

  icopy=iret;
  if(iret > *buflen)
    icopy=*buflen;

  memcpy(buffer,locbuf,icopy);

  return(iret);

}
