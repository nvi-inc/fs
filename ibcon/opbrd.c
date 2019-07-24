/*
 * This routine opens the device driver for the ibcon routines.
 * It uses the configuration file defined in the dev.ctl file for the 
 * board located in /dev directory. This configuration file uses all
 * the default settings except for the DMA which should be 1 for on. 
   NRV 921124 Added external boardid for rddev to use.
 */
#include <memory.h>
#include "sys/ugpib.h"

#define NULLPTR (char *) 0
#define	IBCODE	300

int ID_hpib;

void opbrd_(dev,devlen,error,ipcode)

int *dev;
int *devlen;
int *error;
long *ipcode;

{
  char device[65];
  char *nameend;
  int hpib;

  *error=0;
  *ipcode = 0;

  if ((*devlen < 0) || (*devlen > 64))
  {
    *error = -3;
    memcpy((char *)ipcode,"BL",2);
    return;
  }

  nameend = memccpy(device, dev, ' ', *devlen);
  if (nameend != NULLPTR)
    *(nameend-1) = '\0';
  else 
    *(device + *devlen) = '\0';

/* find the device and assign a file descriptor, returns <0 on error */

  if ( (hpib = ibfind(device)) < 0)
  {  
    *error = -(IBCODE + iberr);
    memcpy((char *)ipcode,"BF",2);
    return;
  }

/* put the hpib board 'on-line' and return ibsta as status */

  if (ibonl(hpib,1)&ERR) 
  {
    *error = -(IBCODE + iberr);
    memcpy((char *)ipcode,"BO",2);
    return;
  }

/* send an interface clear, making the hpib controller-in-chage */
  
  if (ibsic(hpib,1)&ERR) 
  {
    *error = -(IBCODE + iberr);
    memcpy((char *)ipcode,"BS",2);
    return;
  }
/* used as ID for board in other hpib functions */

  ID_hpib = hpib;
}
