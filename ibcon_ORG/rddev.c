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
#ifdef NI_DRIVER
#include <sys/ugpib.h>
#else
#ifdef REV_3
#include <gpib/ib.h>
#else
#include <ib.h>
#include <ibP.h>
#endif
#endif
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
#define IBCODE		300
#define IBSCODE		300
#define ASCII		  0
#define BINARY		  1

extern int ID_hpib;
extern int serial;

static int ascii_last=-1;

/*-------------------------------------------------------------------------*/

int rddev_(mode,devid,buf,buflen,error, ipcode, timeout, no_after, kecho,
	   interface_clear_after_read)

/* rddev returns the count of the number of bytes read, if there are
   no errors.

   The mode flag indicates ASCII (0) or BINARY (1) data reads.
 
   If an error occurs, *error is set to -4 for a timeout, -8 for a bus
   error. If a bus error occurs, rddev returns the system error variable.
*/
int *mode,*devid;
long *ipcode;
unsigned char *buf;
int *buflen;  /* buffer length in characters */
int *error;
int *timeout;
int *no_after;
int *kecho;
int *interface_clear_after_read;
{
  int i;
  int iret, ierr;
  unsigned char lret;
  int val, icopy;
  long centisec[2];

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

  if (serial) {
    ierr=sib(ID_hpib,"tmo 3\r",-1,0,100,0,centisec);
    if(ierr<0) {
      if(ierr==-1 || ierr==-2 || ierr==-5)
	logit(NULL,errno,"un");
      *error = -520+ierr;
      memcpy((char *)ipcode,"RT",2);
      return -1;
    } else if(ibsta&(S_ERR|S_TIMO)) {
      if(ibser!=0)
	logita(NULL,-(540 + ibser),"ib","RT");
      *error = -(IBSCODE + iberr);
      memcpy((char *)ipcode,"RT",2);
      return -1;
    }
  }

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
    ierr=sib(ID_hpib,"cm \n_?\r",-1,0,100,0,centisec);
    if(ierr<0) {
      if(ierr==-1 || ierr==-2 || ierr==-5)
	logit(NULL,errno,"un");
      *error = -520+ierr;
      memcpy((char *)ipcode,"RC",2);
      return -1;
    } else if(ibsta&(S_ERR|S_TIMO)) {
      if(ibser!=0)
	logita(NULL,-(540 + ibser),"ib","RC");
      *error = -(IBSCODE + iberr);
      memcpy((char *)ipcode,"RC",2);
      return -1;
    }
  }
#endif

  if (*mode == 0 && (ascii_last!=1 || !serial)) {
    if (!serial) {
#ifdef CONFIG_GPIB
#if defined(REV_3) || defined(NI_DRIVER)
      val = REOS | LF;
#else
      val = (REOS << 8) + LF;
#endif
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
      ierr=sib(ID_hpib,"eos R 10\r",-1,0,100,0,centisec);
      if(ierr<0) {
	if(ierr==-1 || ierr==-2 || ierr==-5)
	  logit(NULL,errno,"un");
	*error = -520+ierr;
	memcpy((char *)ipcode,"RS",2);
	return -1;
      } else if(ibsta&(S_ERR|S_TIMO)) {
	if(ibser!=0)
	  logita(NULL,-(540 + ibser),"ib","RS");
	*error = -(IBSCODE + iberr);
	memcpy((char *)ipcode,"RS",2);
	return -1;
      }
    }
    ascii_last=1;
  } else if (*mode != 0 && (ascii_last != 0 || !serial)) {
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
      ierr=sib(ID_hpib,"eos D\r",-1,0,100,0,centisec);
      if(ierr<0) {
	if(ierr==-1 || ierr==-2 || ierr==-5)
	  logit(NULL,errno,"un");
	*error = -520+ierr;
	memcpy((char *)ipcode,"RT",2);
	return -1;
      } else if(ibsta&(S_ERR|S_TIMO)) {
	if(ibser!=0)
	  logita(NULL,-(540 + ibser),"ib","RT");
	*error = -(IBSCODE + iberr);
	memcpy((char *)ipcode,"RT",2);
	return -1;
      }
    }
    ascii_last=0;
  }

  if (!serial) {
#ifdef CONFIG_GPIB
    ibrd(*devid,buf,*buflen);
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
    sprintf(buf,"rd #%d %d\r",*buflen,*devid);
    ierr=sib(ID_hpib,buf,-1,*buflen,*timeout,0,centisec);
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
	logita(NULL,-(540 + ibser),"ib","RE");
      *error = -(IBSCODE + iberr);
      memcpy((char *)ipcode,"RE",2);
      return(-1);
    }
  }
  if(*kecho)
    echo_out('r',*mode,*devid,buf,ibcnt);

  iret = ibcnt;

  if ((!serial)&&(!*no_after)) {
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
#if 0
  } else {
    ierr=sib(ID_hpib,"cm \n_?\r",-1,0,100,0,centisec);
    if(ierr<0) {
      if(ierr==-1 || ierr==-2 || ierr==-5)
	logit(NULL,errno,"un");
      *error = -520+ierr;
      memcpy((char *)ipcode,"RD",2);
      return -1;
    } else if(ibsta&(S_ERR|S_TIMO)) {
      if(ibser!=0)
	logita(NULL,-(540 + ibser),"ib","RD");
      *error = -(IBSCODE + iberr);
      memcpy((char *)ipcode,"RD",2);
      return -1;
    }
#endif
  }
/* send an interface clear, making the hpib controller-in-chage */

  if (!serial && (*interface_clear_after_read)) {
#ifdef CONFIG_GPIB
/* this is the only way to become CIC */
    if (ibsic(ID_hpib)&ERR) {
      if(iberr==0)
	logit(NULL,errno,"un");
      *error = -(IBCODE + iberr);
      memcpy((char *)ipcode,"RI",2);
      return -1;
    }
#else
    *error = -(IBCODE + 22);
    return -1;
#endif
  } else if (*interface_clear_after_read){
  /* some devices don't like this */
    ierr=sib(ID_hpib,"si\r",-1,0,200,0,centisec);
    if(ierr<0) {
      if(ierr==-1 || ierr==-2 || ierr==-5)
	logit(NULL,errno,"un");
      *error = -520+ierr;
      memcpy((char *)ipcode,"RI",2);
      return -1;
    } else if(ibsta&S_ERR) {
      if(iberr==0)
      if(ibser!=0)
	logita(NULL,-(540 + ibser),"ib","RI");
      *error = -(IBSCODE + iberr);
      memcpy((char *)ipcode,"RI",2);
      return -1;
    }
  }

  if (*mode == 0) {  
    if (iret <= 0)
      return (0);
    else
      lret = buf[iret-1];
    
    while ((iret > 0) && (strchr("\r\n",lret) != 0))
      lret = buf[--iret-1];
  }

  return(iret);

}
