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

#ifdef CONFIG_GPIB
#include <ib.h>
#include <ibP.h>
#endif

#define NULLPTR (char *) 0

void opdev_(dev,devlen,devid,error,ipcode)

int *dev;
int *devlen;
int *devid;
int *error;
long *ipcode;

{
  int deviceid;
  char device[65];
  char *nameend;

  *error = 0;
  *ipcode = 0;

  if ((*devlen < 0) || (*devlen > 64))
  {
    *error = -3;
    memcpy((char *)ipcode,"DL",2);
    return;
  }
  
  nameend = memccpy(device, dev, ' ', *devlen);
  if (nameend != NULLPTR)
    *(nameend-1) = '\0';
  else 
    *(device + *devlen) = '\0';

#ifdef CONFIG_GPIB
  if ( (*devid = ibfind(device)) < 0) 
  { 
   *error = -320;
   memcpy((char*)ipcode,"DF",2);
  }
#else
   *error = -322;
#endif
}

