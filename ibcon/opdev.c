/*
 * This routine opens the device configuration files that will be
 * used in ibcon. It is called from a loop inside ibcon and opens
 * every device that is going to be used with the field system.
 * Every device is opened at the initialization of ibcon and the
 * configuration files for the devices are located in /dev directory.
 * It assumes you will use the configuration file 'ibboard' for the 
 * board. 
 *
 * The following configuration files use the default settings and have
 * the additional settings as described:
 *
 *  ib2: This file is used for the cable counter:
 *       PAD: 2        !! address 2 on the device
 *       EOS: a        !! hex for line feed, end character of output
 *       REOS          !! device flag turned on for reading EOS
 *
 *  ib11: This file is used for the spectrum analyzer:
 *       PAD: 11       !! address 11 on the device
 *       EOS: d        !! hex for carriage return, end character of output
 *       XEOS          !! device flag turned on for writing EOS
 */
#include <memory.h>
#include "ugpib.h"
#define NULLPTR (char *) 0

void opdev_(dev,devlen,devid,error)

int *dev;
int *devlen;
int *devid;
int *error;

{
  int deviceid;
  char device[65];
  char *nameend;

  *error = 0;
  if ((*devlen < 0) || (*devlen > 64)){
    *error = -3;
    return;
  }
  nameend = memccpy(device, dev, ' ', *devlen);
  if (nameend != NULLPTR)
    *(nameend-1) = '\0';
  else *(device + *devlen) = '\0';

  if ( (*devid = ibfind(device)) < 0) { 
    erroroutd("couldn't 'ibfind()' %s\n",dev);
    *error=-8;
    return;
  }
}

erroroutd(msg)
char *msg;
{
  printf("\n opdev error detected while %s",msg);
  printf("\n ibsta = %.4xh iberr = %d ibcnt %d\n", ibsta,iberr,ibcnt);
}
