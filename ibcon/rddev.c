/*
 * The device drivers have already been opened.
 * Note the buffer size BSIZE for the reading command. This
 * must be a large number to force usage of DMA otherwise, if
 * a timeout situation occurs, the computer system will lockup
 * until the timeout happens.
 */
#include <memory.h>
#include "ugpib.h"
#define  BSIZE 256   /* this size for DMA */
extern int boardid;

int rddev_(devid,buffer,buflen,error)

int *devid;
int *buffer;
int *buflen;
int *error;

{
  int i;
  int iret;
  int locbuf[BSIZE];

  *error = 0;

  for (i=0; i<BSIZE; i++)
    locbuf[i] = 0;
  ibcmd(boardid,"_?",2);      /* send UNL, UNT first */

/* 
 * The termination character (line feed, hex a) is set in the
 * configuration file for the device located in /dev directory.
 * The read command is set to terminate on the EOS value. This is set
 * in the configuration file along with the device flag REOS. 
 * The DMA parameter in the configuration file (ibboard) for the board 
 * must be turned on (set to 1) for the read to work properly. The number
 * of characters to be read with the ibrd command must also be set high, 
 * 256 in this case works.
 */
  ibrd(*devid,locbuf,BSIZE);
/*printf("\n ibsta = %.4xh iberr = %d ibcnt %d\n", ibsta,iberr,ibcnt);*/

  if ( (ibsta & 0x4000) != 0) {
    *error = -4;
    return;
  }
  else if ((ibsta & 0x8000) != 0) {
    *error = -8;
    return(iberr);
  }
  iret = ibcnt;

  i=0;
  while(i<ibcnt && i < *buflen) {
    buffer[i] = locbuf[i];
    i++;
  }

/* { int i,j; 
  char *hexid;
  hexid = (char*)buffer;
  for (i=0;i<ibcnt;i++) {
    printf("%x ",*hexid);
    hexid++;
  }
  printf("\n");
}
*/

  ibcmd(boardid,"_?",2);      /* send UNL, UNT at end */

  return(iret);
}
