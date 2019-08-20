/*
 * The device drivers have already been opened.
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

/*-------------------------------------------------------------------------*/

int iclrdev_(devid,error, ipcode, timeout, kecho)

/* iclrdev clear the specified device or the whole bus
 
   If an error occurs, *error is set to -4 for a timeout, -8 for a bus
   error. If a bus error occurs, statbrd returns the system error variable.
*/
int *devid;
int *ipcode;
int *error;
int *timeout;
int *kecho;
{
  int i;
  int iret, ierr;
  unsigned char lret;
  int val, icopy;
  int ibsta1;
  int value;
  char buf[20];
  int centisec[2];

  *error = 0;
  *ipcode = 0;

  if (!serial) {
#ifdef CONFIG_GPIB
    if(*devid<=0)
      ibsic(ID_hpib);
    else
      ibclr(*devid);    
    if ((ibsta & TIMO) != 0) {	/* has the device timed out? */ 
      value=-1;
    } else if ((ibsta & ERR) != 0) { /* if not, some other type of error */
      if(iberr==0)
	logit(NULL,errno,"un");
      *error = -(IBCODE + iberr);
      memcpy((char *)ipcode,"IC",2);
      return(-1);
    } else {
      if(*kecho)
	echo_out('c',0,*devid,"INTERFACE CLEAR",15);
    }
#else
    *error = -(IBCODE + 22);
    return -1;
#endif
  } else {
    if(*devid<=0)
      strcpy(buf,"sic\r");
    else
      sprintf(buf,"clr %d\r",*devid);
    ierr=sib(ID_hpib,buf,-1,0,*timeout,0,centisec);
    if(ierr<0) {
      if(ierr==-1 || ierr==-2 || ierr==-5)
	logit(NULL,errno,"un");
      *error = -520+ierr;
      memcpy((char *)ipcode,"IC",2);
      return -1;
    } else if ((ibsta & S_TIMO) != 0) {      /* has the device timed out? */ 
      value=-1;
    } else if ((ibsta & S_ERR) != 0) { /* if not, some other type of error */
      if(ibser!=0)
	logita(NULL,-(540 + ibser),"ib","IC");
      *error = -(IBSCODE + iberr);
      memcpy((char *)ipcode,"IC",2);
      return(-1);
    } else
      if(*kecho) {
	echo_out('c',0,*devid,"INTERFACE CLEAR",15);
      }
  }

  return 0;
}
