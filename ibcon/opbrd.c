/*
 * This routine opens the device driver for the ibcon routines.
 * It uses the configuration file defined in the dev.ctl file for the 
 * board located in /dev directory. This configuration file uses all
 * the default settings except for the DMA which should be 1 for on. 
 */
#include <memory.h>
#include "ugpib.h"
#define NULLPTR (char *) 0
int boardid;

void opbrd_(dev,devlen,error)

int *dev;
int *devlen;
int *error;

{
  char device[65];
  char *nameend;

  *error=0;

  if ((*devlen < 0) || (*devlen > 64)){
    *error = -3;
    return;
  }
  nameend = memccpy(device, dev, ' ', *devlen);
  if (nameend != NULLPTR)
    *(nameend-1) = '\0';
  else *(device + *devlen) = '\0';

  if ( (boardid = ibfind(device)) < 0) { 
    errorop("couldn't 'ibfind()' %s\n",dev);
    *error=-8;
    return;
  }

  if (ibonl(boardid,1)&(ERR|TIMO)) {
    errorop("couldn't initialize board\n");
    *error=-8;
  }

  if (ibsic(boardid,1)&(ERR|TIMO)) {
    errorop("couldn't execute interface clear\n");
    *error=-8;
  }

}

errorop(msg)
char *msg;
{
  printf("\n opbrd error detected while %s",msg);
  printf("\n ibsta = %.4xh iberr = %d ibcnt %d\n", ibsta,iberr,ibcnt);
}
