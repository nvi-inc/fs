
/*
 * This routine opens the device driver for the ibcon routines.
 * It uses the configuration file defined in the dev.ctl file for the 
 * board located in /dev directory. This configuration file uses all
 * the default settings except for the DMA which should be 1 for on. 
   NRV 921124 Added external boardid for rddev to use.
 */
#include <memory.h>
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

#define NULLPTR (char *) 0
#define	IBCODE	300
#define IBSCODE 400

int ID_hpib;
int serial;

int opbrd_(dev,devlen,error,ipcode)

int *dev;
int *devlen;
int *error;
long *ipcode;

{
  char device[65];
  char *nameend;
  int ierr;
  long centisec[2];

  *error=0;
  *ipcode = 0;

  if ((*devlen < 0) || (*devlen > 64))
  {
    *error = -202;
    memcpy((char *)ipcode,"BL",2);
    return -1;
  }

  nameend = memccpy(device, dev, ' ', *devlen);
  if (nameend != NULLPTR)
    *(nameend-1) = '\0';
  else 
    *(device + *devlen) = '\0';

/* find the device and assign a file descriptor */

  if(strcmp(device,"board")==0) {
#ifdef CONFIG_GPIB
    ID_hpib = ibfind(device);
    if(ID_hpib < 0 ) {
      if(iberr==0)
	logit(NULL,errno,"un");
      *error = -(IBCODE + iberr);
      memcpy((char *)ipcode,"BF",2);
      return -1;
    }
    serial=0;
#else
    *error = -(IBCODE + 22);
    return -1;
#endif
  } else {
    long baud;
    int len, parity, bits, stop;
    len = strlen(device);
    baud=38400;
    parity=0;
    bits=8;
    stop=1;
    ierr = portopen_(&ID_hpib,device,&len,&baud,&parity,&bits,&stop);
    if(ierr <0) {
      if(ierr==-2 || ierr==-3 || (-7 < ierr && ierr < -11))
	 logit(NULL,errno,"un");
      *error=-500+ierr;
      memcpy((char *)ipcode,"BP",2);
      return -1;
    }
    serial=1;
  }

/* put the hpib board 'on-line' and return ibsta as status */

  if(!serial) {
#ifdef CONFIG_GPIB
#ifdef REV_2
/* this causes some problem for rev 1 */
    ierr=ibonl(ID_hpib,1);
#else
    ierr=0;
#endif
    if (ierr&ERR) {
      if(iberr==0)
	logit(NULL,errno,"un");
      *error = -(IBCODE + iberr);
      memcpy((char *)ipcode,"BO",2);
      return -1;
    }
#else
    *error = -(IBCODE + 22);
    return -1;
#endif
  } else {
    ierr=sib(ID_hpib,"\ro 1\r",-1,0,0,0,centisec);
    if(ierr==-2||ierr==-1 || ierr==-5) {
      *error = -520+ierr;
      memcpy((char *)ipcode,"BO",2);
      return -1;
    }
  }

  if (serial) {
    ierr=sib(ID_hpib,"st c n\r",-1,0,100,0,centisec);
    if(ierr<0) {
      if(ierr==-1 || ierr==-2 || ierr==-5)
	logit(NULL,errno,"un");
      *error = -520+ierr;
      memcpy((char *)ipcode,"BN",2);
      return -1;
    } else if(ibsta&(S_ERR|S_TIMO)) {
      if(ibser!=0)
	logita(NULL,-(540 + ibser),"ib","BN");
      *error = -(IBSCODE + iberr);
      memcpy((char *)ipcode,"BN",2);
      return -1;
    }
  }
  if (serial) {
    ierr=sib(ID_hpib,"spi 0\r",-1,0,100,0,centisec);
    if(ierr<0) {
      if(ierr==-1 || ierr==-2 || ierr==-5)
	logit(NULL,errno,"un");
      *error = -520+ierr;
      memcpy((char *)ipcode,"BN",2);
      return -1;
    } else if(ibsta&(S_ERR|S_TIMO)) {
      if(ibser!=0)
	logita(NULL,-(540 + ibser),"ib","BN");
      *error = -(IBSCODE + iberr);
      memcpy((char *)ipcode,"BN",2);
      return -1;
    }
  }

/* send an interface clear, making the hpib controller-in-chage */

  if (!serial) {
#ifdef CONFIG_GPIB
/* this is the only way to become CIC */
    if (ibsic(ID_hpib)&ERR) {
      if(iberr==0)
	logit(NULL,errno,"un");
      *error = -(IBCODE + iberr);
      memcpy((char *)ipcode,"BS",2);
      return -1;
    }
#else
    *error = -(IBCODE + 22);
    return -1;
#endif
  } else {
/* some devices don't like this
    ierr=sib(ID_hpib,"si\r",-1,0,200,0,centisec);
    if(ierr<0) {
      if(ierr==-1 || ierr==-2 || ierr==-5)
	logit(NULL,errno,"un");
      *error = -520+ierr;
      memcpy((char *)ipcode,"BS",2);
      return -1;
    } else if(ibsta&S_ERR) {
      if(iberr==0)
      if(ibser!=0)
	logita(NULL,-(540 + ibser),"ib","BS");
      *error = -(IBSCODE + iberr);
      memcpy((char *)ipcode,"BS",2);
      return -1;
    }
*/
  }

  if(serial) {
    ierr=sib(ID_hpib,"eot 1\r",-1,0,100,0,centisec);
      if(ierr<0) {
	if(ierr==-1 || ierr==-2 || ierr==-5)
	  logit(NULL,errno,"un");
	*error = -520+ierr;
	memcpy((char *)ipcode,"BE",2);
	return -1;
      } else if(ibsta&(S_ERR|S_TIMO)) {
	if(ibser!=0)
	  logita(NULL,-(540 + ibser),"ib","BE");
	*error = -(IBSCODE + iberr);
	memcpy((char *)ipcode,"BE",2);
	return -1;
      }
  }

  if (serial) {
    ierr=sib(ID_hpib,"eos D\r",-1,0,100,0,centisec);
    if(ierr<0) {
      if(ierr==-1 || ierr==-2 || ierr==-5)
	logit(NULL,errno,"un");
      *error = -520+ierr;
      memcpy((char *)ipcode,"BT",2);
      return -1;
    } else if(ibsta&(S_ERR|S_TIMO)) {
      if(ibser!=0)
	logita(NULL,-(540 + ibser),"ib","BT");
      *error = -(IBSCODE + iberr);
      memcpy((char *)ipcode,"BT",2);
      return -1;
    }
  }

  if (serial) {
    ierr=sib(ID_hpib,"tmo 3\r",-1,0,100,0,centisec);
    if(ierr<0) {
      if(ierr==-1 || ierr==-2 || ierr==-5)
        logit(NULL,errno,"un");
      *error = -520+ierr;
      memcpy((char *)ipcode,"BU",2);
      return -1;
    } else if(ibsta&(S_ERR|S_TIMO)) {
      if(ibser!=0)
        logita(NULL,-(540 + ibser),"ib","BU");
      *error = -(IBSCODE + iberr);
      memcpy((char *)ipcode,"BU",2);
      return -1;
    }
  }

  return serial;
}
