/*
 * This routine opens the device configuration files that will be
 * used in ibcon. It is called from a loop inside ibcon and opens
 * every device that is going to be used with the field system.
 * Every device is opened at the initialization of ibcon and the
 * configuration files for the devices are located in /dev directory.
 * It assumes you will use the configuration file 'ibboard' for the 
 * board. 
 */

#include <memory.h>
#include <string.h>
#include <errno.h>

#ifdef CONFIG_GPIB
#ifdef NI_DRIVER
#include <sys/ugpib.h>
#else
#include <ib.h>
#include <ibP.h>
#endif
#else
extern int ibsta;
extern int iberr;
extern int ibcnt;
#endif

extern int ibser;
#include "sib.h"

#define NULLPTR (char *) 0
#define IBCODE   300
#define IBSCODE  400

extern int serial;

int opdev_(dev,devlen,devid,error,ipcode,tmo)

int *dev;
int *devlen;
int *devid;
int *error;
long *ipcode;
short *tmo;

{
  int deviceid, ierr;
  char device[65];
  char *nameend;

  *error = 0;
  *ipcode = 0;

  if ((*devlen < 0) || (*devlen > 64)) {
    *error = -203;
    memcpy((char *)ipcode,"DL",2);
    return -1;
  }
  
  nameend = memccpy(device, dev, ' ', *devlen);
  if (nameend != NULLPTR)
    *(nameend-1) = '\0';
  else 
    *(device + *devlen) = '\0';

  if(!serial) {
#ifdef CONFIG_GPIB
    if ( (*devid = ibfind(device)) < 0) { 
      *error = -320;
      memcpy((char*)ipcode,"DF",2);
      return -1;
    }
#else
    *error = -322;
#endif
  } else {
    if(1!=sscanf(device,"dev%d",devid)) {
      *error=-420;
      memcpy((char*)ipcode,"DF",2);
      return -1;
    }
  }
  if(!serial) {
#ifdef CONFIG_GPIB
    ierr=ibtmo(*devid,*tmo);
    if ((ibsta & (ERR|TIMO)) != 0) {
      if(iberr==0)
	logit(NULL,errno,"un");
      *error = -(IBCODE  + iberr);
      memcpy((char*)ipcode,"DT",2);
      return -1;
    }
#else
    *error = -322;
    return -1;
#endif
  }

  if (!serial) {
#ifdef CONFIG_GPIB
    ibeot(*devid,1);			/* send EOI auto with last byte */
    if ((ibsta & (ERR|TIMO)) != 0) {
      if(iberr==0)
	logit(NULL,errno,"un");
      *error = -(IBCODE  + iberr);
      memcpy((char *)ipcode,"DE",2);
      return -1;
    }
#else
    *error = -(IBCODE + 22);
    return -1;
#endif
  }

    if (!serial) {
#ifdef CONFIG_GPIB
      ibeos(*devid,0);		/* turn off all EOS functionality */
      if ((ibsta & (ERR|TIMO)) != 0) {
	if(iberr==0)
	  logit(NULL,errno,"un");
	*error = -(IBCODE + iberr); 
	memcpy((char*)ipcode,"DS",2);
	return(-1);
      }
#else
      *error = -(IBCODE + 22);
      return -1;
#endif
    }
  
  return 0;
}


