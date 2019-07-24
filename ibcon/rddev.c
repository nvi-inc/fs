/*
 * The device drivers have already been opened.
 * Note the buffer size BSIZE for the reading command. This
 * must be a large number to force usage of DMA otherwise, if
 * a timeout situation occurs, the computer system will lockup
 * until the timeout happens.
 NRV 921124 Added external board ID reference (got in opbrd) and
            call to ibcmd to do an "untalk" to the board before reading.
 */
#include <memory.h>
#include <stdio.h>
#include "ugpib.h"
#define  BSIZE 256   /* this size for DMA */
extern int boardid_ext;

int rddev_(devid,buffer,buflen,error)

/* rddev returns the count of the number of bytes read, if there are
   no errors. 
   If an error occurs, *error is set to -4 for a timeout, -8 for a bus
   error. If a bus error occurs, rddev returns the system error variable.
*/
int *devid;
unsigned char *buffer;
int *buflen;  /* buffer length in characters */
int *error;

{
  int i;
  int iret;
  unsigned char locbuf[BSIZE];
  int val, icopy;

  *error = 0;

  for (i=0; i<BSIZE; i++)
    locbuf[i] = 0;

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
  ibcmd(boardid_ext,"_?",1);  /* Send UNT UNL */
/*printf("\n ibsta = %.4xh iberr = %d ibcnt %d\n", ibsta,iberr,ibcnt);*/

  val = (REOS << 8) +0x0a;
  ibeos(*devid,val);
  ibrd(*devid,locbuf,BSIZE);

/*  printf("\n ibsta = %.4xh iberr = %d ibcnt %d\n", ibsta,iberr,ibcnt); */

  if ( (ibsta & 0x4000) != 0) {
    *error = -4;
    return;
  }
  else if ((ibsta & 0x8000) != 0) {
    *error = -8; 
    return(iberr);
  }

  iret = ibcnt;
  while(iret > 0 &&
     (locbuf[iret-1] == 0 || locbuf[iret-1] == '\r' || locbuf[iret-1]== '\n'))
        iret--;

  icopy=iret;
  if(iret > *buflen)
     icopy=*buflen;
  memcpy(buffer,locbuf,icopy);

/*
 { int i; for (i=0;i<iret;i++) printf("%2x ",buffer[i]); } 
  printf("\n");
*/

  return(iret);
}
