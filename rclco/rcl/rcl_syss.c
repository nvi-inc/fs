#include <stdio.h>
#include <stdlib.h>
#include <dos.h>

#include "rcl_def.h"
#include "..\comio.h"

#include "rcl_sys.h"


/*
 * System-dependent serial I/O routines. This is the only file which should
 * need to be changed when porting the RCL interface library to different
 * hardware platforms.
 *
 * This version is for MSDOS with the comio.c serial driver.
 */


int rcl_portinit(void)
/*
 * Initialize the serial port used for the RCL. It should be set to
 * 8 bits, no parity, one stop bit.
 */
{
   int err;

   TTinit();
   err=ttopen();            /* open comm port */
   if (err==-1)
      return(RCL_ERR_IO);

   return(RCL_ERR_NONE);
}

int rcl_setbaud(int baudrate)
/*
 * Set the baud rate of the serial port used for the RCL.
 */
{
   extern unsigned int speed;        /* BAUD rate in comio.c */
   int err;

   err=ttclose();           /* close comm port */
   if (err==-1)
      return(RCL_ERR_IO);

   speed=baudrate;          /* set new baud rate */

   err=ttopen();            /* re-open comm port to update baud rate */
   if (err==-1)
      return(RCL_ERR_IO);

   return(RCL_ERR_NONE);
}

int rcl_portshutdown(void)
/*
 * Close the serial port used for the RCL.
 */
{
   int err;

   err=ttclose();           /* close comm port */
   if (err==-1)
      return(RCL_ERR_IO);

   return(RCL_ERR_NONE);
}

int rcl_delay(int msec)
/*
 * Delay for 'msec' milliseconds.
 */
{
   delay(msec);

   return(RCL_ERR_NONE);
}

int rcl_getch(int addr, unsigned char* c)
/*
 * Input one character from the RCL serial port. 
 * Wait if none is available.
 * 'addr' is unused, included for compatibility with rcl_sysn.c.
 */
{
   *c=ttinc();

   return(RCL_ERR_NONE);
}

ibool rcl_checkch(int addr)
/*
 * Check if any characters are ready to input from the RCL serial port.
 * If so, return TRUE, otherwise return FALSE.
 * 'addr' is unused, included for compatibility with rcl_sysn.c.
 */
{
   return(ttchk()>0);
}

int rcl_putch(int addr, unsigned char c)
/*
 * Output one character to the RCL serial port.
 * 'addr' is unused, included for compatibility with rcl_sysn.c.
 */
{
   ttoc(c);

   return(RCL_ERR_NONE);
}

int rcl_flushout(int addr)
/*
 * Flush the RCL serial port output buffer, i.e. force any buffered output
 * to be sent immediately.
 * 'addr' is unused, included for compatibility with rcl_sysn.c.
 */
{
   /* do nothing, comio routines don't need flush */
   return(RCL_ERR_NONE);
}
