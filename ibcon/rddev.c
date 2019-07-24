/*
 * The device drivers have already been opened.
 * NRV 921124 Added external board ID reference (got in opbrd) and
            call to ibcmd to do an "untalk" to the board before reading.
 */
#include <memory.h>
#include <string.h>
#include <stdio.h>
#include "sys/ugpib.h"

#define	LF		0x0A
#define TIMEOUT		-4
#define BUS_ERROR	-8
#define HPIBERR		-20
#define BSIZE 		256   /* this size for DMA */
#define IBCODE		300
#define ASCII		  0
#define BINARY		  1

extern int ID_hpib;

/*-------------------------------------------------------------------------*/

int rddev_(mode,devid,buffer,buflen,error, ipcode)

/* rddev returns the count of the number of bytes read, if there are
   no errors.

   The mode flag indicates ASCII (0) or BINARY (1) data reads.
 
   If an error occurs, *error is set to -4 for a timeout, -8 for a bus
   error. If a bus error occurs, rddev returns the system error variable.
*/
int *mode,*devid;
long *ipcode;
unsigned char *buffer;
int *buflen;  /* buffer length in characters */
int *error;

{
  int i;
  int iret;
  unsigned char lret,locbuf[BSIZE];
  int val, icopy;

  *error = 0;
  *ipcode = 0;

/* 
 * The termination character (line feed, 0x0A) is set in the
 * configuration file for the device located in /dev directory.
 * The read command is set to terminate on the EOS value. This is set
 * in the configuration file along with the device flag REOS. 
 * The DMA parameter in the configuration file (ibboard) for the board 
 * must be turned on (set to 1) for the read to work properly. The number
 * of characters to be read with the ibrd command must also be set high, 
 * 256 in this case works.
 */

  ibcmd(ID_hpib,"_?",1);  	/* unaddress all listeners and talkers */
  if ((ibsta & (ERR|TIMO)) != 0)
  {
    *error = -(IBCODE + iberr); 
    memcpy((char *)ipcode,"RC",2);
    return(-1);
  } 

  if ((*mode == 1) || (*mode == 2))
  {
    val = (REOS << 8) + LF;
    ibeos(*devid,val);		/* set to read until REOS+EOS is detected */

    if ((ibsta & (ERR|TIMO)) != 0)
    {
      *error = -(IBCODE + iberr); 
      memcpy((char*)ipcode,"RS",2);
      return(-1);
    }
  }
  else
  {
    ibeos(*devid,0);		/* turn off all EOS detection */
    if ((ibsta & (ERR|TIMO)) != 0)
    {
      *error = -(IBCODE + iberr); 
      memcpy((char*)ipcode,"RT",2);
      return(-1);
    }
  }

  ibrd(*devid,locbuf,BSIZE);	/* addr device to TALK, board to LISTEN */

  if ((ibsta & TIMO) != 0)	/* has the device timed out? */ 
  {
    *error = TIMEOUT;
    memcpy((char *)ipcode,"RE",2);
    return(-1);
  } 
  else if ((ibsta & ERR) != 0) 	/* if not, some other type of error */
  {
    *error = -(IBCODE + iberr);
    memcpy((char *)ipcode,"RB",2);
    return(-1);
  }

  iret = ibcnt;

  ibcmd(ID_hpib,"_?",1);  	/* unaddress all listeners and talkers */
  if ((ibsta & (ERR|TIMO)) != 0)
  {
    *error = -(IBCODE + iberr); 
    memcpy((char *)ipcode,"RD",2);
    return(-1);
  }

  if ((*mode == 1) || (*mode == 2))
  {  
    if (iret <= 0)
      return (0);
    else
      lret = locbuf[iret-1];

    while ((iret > 0) && (strchr("\r\n\0",lret) != 0))
      lret = locbuf[--iret-1];
  }

  icopy=iret;
  if(iret > *buflen)
    icopy=*buflen;

  memcpy(buffer,locbuf,icopy);

  return(iret);
}
