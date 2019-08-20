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

int statbrd_(buf,error, ipcode, timeout, kecho)

/* statbrd returns the bus status byte
 
   If an error occurs, *error is set to -4 for a timeout, -8 for a bus
   error. If a bus error occurs, statbrd returns the system error variable.
*/
unsigned char *buf; /* points to area at least sizeof(int) in extent */
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
  int ivalue;
  int centisec[2];

  *error = 0;
  *ipcode = 0;

  if (!serial) {
#ifdef CONFIG_GPIB
    ibsta1=ibwait(ID_hpib,0);    
    if ((ibsta & TIMO) != 0) {	/* has the device timed out? */ 
      *error = TIMEOUT;
      memcpy((char *)ipcode,"SB",2);
      return(-1);
    } else if ((ibsta & ERR) != 0) { /* if not, some other type of error */
      if(iberr==0)
	logit(NULL,errno,"un");
      *error = -(IBCODE + iberr);
      memcpy((char *)ipcode,"SB",2);
      return(-1);
    }
#else
    *error = -(IBCODE + 22);
    return -1;
#endif
  } else {
    sprintf(buf,"wa 0\r");
    ierr=sib(ID_hpib,buf,-1,0,*timeout,0,centisec);
    if(ierr<0) {
      if(ierr==-1 || ierr==-2 || ierr==-5)
	logit(NULL,errno,"un");
      *error = -520+ierr;
      memcpy((char *)ipcode,"SB",2);
      return -1;
    } else if ((ibsta & S_TIMO) != 0) {      /* has the device timed out? */ 
      *error = TIMEOUT;
      memcpy((char *)ipcode,"SB",2);
      return(-1);
    } else if ((ibsta & S_ERR) != 0) { /* if not, some other type of error */
      if(ibser!=0)
	logita(NULL,-(540 + ibser),"SB");
      *error = -(IBSCODE + iberr);
      memcpy((char *)ipcode,"SB",2);
      return(-1);
    }
  }
  if(*kecho)
    echo_out('r',1,0,&ibsta,sizeof(ibsta));

  ivalue=ibsta;
  memcpy(buf,(char *) &ivalue,sizeof(int));
  return 0;
}
