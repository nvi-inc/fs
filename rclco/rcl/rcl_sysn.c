#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <errno.h>
#include <string.h>
/*
 * System-dependent RCL I/O routines. This is the only file which should
 * need to be changed when porting the RCL interface library to different
 * hardware platforms.
 *
 * This version is for UNIX with internet sockets. 
 * Tested under SunOS 4.1.1 and Linux 1.2.12
 * For Linux compile with LINUX macro defined, otherwise defaults to
 * SunOS 4.x.
 */

#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <fcntl.h>

#include "rcl_def.h"

#include "rcl_sys.h"


/* functions not defined by Unix non-ansi headers */
extern int connect();
extern unsigned long inet_addr(const char* cp);


/* variables local to this module */
static FILE *rcl_infile[RCL_MAX_CONNECT];   /* input stream for socket */
static FILE *rcl_outfile[RCL_MAX_CONNECT];  /* output stream for socket */
static int rcl_socket[RCL_MAX_CONNECT];     /* socket file descriptor, 0 means
                                                 this reference address not 
                                                 open */
static int rcl_unget[RCL_MAX_CONNECT];      /* character to use instead of
                                                 next input character, our
                                                 own version of ungetc().
                                                 -1 means none available. */
static char rcl_hostname[RCL_MAX_CONNECT][80];/* host name for socket */


int rcl_portinit(void)
/*
 * Initialize the socket array used for the RCL.
 */
{
   int i;

   for ( i = 0; i < RCL_MAX_CONNECT; i++ )  {
      rcl_infile[i] = NULL;
      rcl_outfile[i] = NULL;
      rcl_socket[i] = 0;
      rcl_unget[i] = -1;
   }

   return(RCL_ERR_NONE);
}

int rcl_portshutdown(void)
/*
 * Close the sockets used for the RCL.
 * Return value is first error code encountered, but the routine always
 * attempts to execute to completion.
 */
{
   int err;     /* final RCL error code, first error encountered */
   int err2;    /* short-term RCL error code */
   int i;

   err=RCL_ERR_NONE;

   for ( i = 0; i < RCL_MAX_CONNECT; i++ )  {
      err2=rcl_close(i);
      if (err2!=RCL_ERR_NONE  && err2!=RCL_ERR_NETBADREF && err==RCL_ERR_NONE)
         err=err2;
   }

   return(err);
}

int rcl_open(const char* hostname, int* addr, char* errmsg)
/*
 * Open a new socket to use for the RCL, and attempt a connection. Up to
 * 32 RCL devices can be active at any one time. When connected via the 
 * network, the usual RCL device address used for serial connections is 
 * redundant since the network address uniquely identifies each RCL device.
 * This routine returns an integer descriptor from 0 to RCL_MAX_CONNECT which
 * should be used in place of the device's RCL address as the first parameter
 * in all RCL command function calls in rcl_cmd.c.
 * 'hostname' is the internet host name of the RCL targert system to connect
 *            to, e.g. bullseye.sgl.ists.ca
 * 'addr' returns an index number to be used in place of the RCL address. Pass
 *        this reference address as the first parameter to the routines in
 *        rcl_cmd.c.
 * 'errmsg' returns a one-line error description since the error code is often
 *          not very descriptive (e.g. many errors returns RCL_ERR_NETIO).
 *          Pass NULL to ignore.
 * Return value is error code. 
 */
{
   extern int sys_nerr;             /* number of SunOS error messages */
#ifndef LINUX
   extern char *sys_errlist[];      /* SunOS error messages */
#endif
   int result;              /* Unix return code */
   struct sockaddr_in sa;
   struct hostent *phost;
   char buffer[256];        /* buffer to use for reply string from RCL device */
   int i;                   /* socket table index */

   if (errmsg!=NULL)
      errmsg[0]=(char)NULL;

   /* find a free entry in the socket table */
   for ( i = 0; i < RCL_MAX_CONNECT; i++ )  {
      if (rcl_socket[i] == 0)
         break;
   }
   if (i>=RCL_MAX_CONNECT)  {
      if (errmsg!=NULL)  {
         sprintf(errmsg,"No more network connections can be opened");
      }
      return(RCL_ERR_NETMAXCON);
   }

   if ((rcl_socket[i] = socket(AF_INET, SOCK_STREAM, 0)) == -1)  {
      if (errmsg!=NULL && errno>=0 && errno<sys_nerr)  {
         /* Get system error message. This may not port easily to other Unix
              systems, so if necessary just comment it out. */
         strcpy(errmsg, sys_errlist[errno]);
      }
      rcl_socket[i] = 0;
      return(RCL_ERR_NETIO);
   }

   /* show one more socket active (will be decremented again by rcl_close()
        if error below) */
   RclSocketCnt++;

   bzero(&sa, sizeof(sa));
   sa.sin_family = AF_INET;
   sa.sin_port = htons(1025);  /* use port number 1025, chosen arbitrarily */

   /* Decode a.b.c.d numeric IP address, if illegal must be a host name */
   sa.sin_addr.s_addr = inet_addr(hostname);
   if (sa.sin_addr.s_addr == -1L)  {    /* -1 is invalid address notation, */
      phost = gethostbyname(hostname);         /* so look for host's name. */
      if (phost == NULL)  {
         if (errmsg!=NULL)  {
            if (h_errno == HOST_NOT_FOUND)
               sprintf(errmsg,"Unknown host name");
            else
               sprintf(errmsg,"Error code %d from gethostbyname()",h_errno);
         }
         rcl_close(i);

         if (h_errno == HOST_NOT_FOUND)
            return(RCL_ERR_NETBADHOST);
         else
            return(RCL_ERR_NETIO);
      }
      bcopy((char *) phost->h_addr, (char *) &sa.sin_addr, phost->h_length);
   }

   /* establish connection with target RCL device */
   result = connect(rcl_socket[i], (struct sockaddr *) &sa, sizeof(sa));
   if (result == -1)  {
      if (errmsg!=NULL && errno>=0 && errno<sys_nerr)  {
         strcpy(errmsg, sys_errlist[errno]);
      }
      rcl_close(i);
      return(RCL_ERR_NETIO);
   }

   rcl_infile[i] = fdopen(rcl_socket[i], "r");
   if (rcl_infile[i] == NULL)  {
      if (errmsg!=NULL && errno>=0 && errno<sys_nerr)  {
         strcpy(errmsg, sys_errlist[errno]);
      }
      rcl_close(i);
      return(RCL_ERR_IO);
   }

   rcl_outfile[i] = fdopen(rcl_socket[i], "w");
   if (rcl_outfile[i] == NULL)  {
      if (errmsg!=NULL && errno>=0 && errno<sys_nerr)  {
         strcpy(errmsg, sys_errlist[errno]);
      }
      rcl_close(i);
      return(RCL_ERR_IO);
   }

   /* The RCL target device always returns a one-line message terminated by a
        newline immediately after connection is established. This is either
        an error message or the letters "OK" to indicate connection 
        successful. */
   buffer[0] = '\0';
   fgets(&buffer[0], 255, rcl_infile[i]);  /* get one-line message (includes
                                                newline character) */ 

   if (strcmp(buffer,"OK\n") != 0)  {
      if (errmsg!=NULL)  {
         strcpy(errmsg,buffer);
      }
      rcl_close(i);
      return(RCL_ERR_NETIO);
   }

   /* set hostname for reference */
   strcpy(rcl_hostname[i],hostname);

   *addr = i;
   return(RCL_ERR_NONE);
}

int rcl_close(int addr)
/*
 * Closes a particular socket used for RCL. This would theoretically involve
 * f-closing the two I/O streams rcl_outfile[] and rcl_infile[] *and* closing
 * the socket descriptor, however they all share the same file descriptor
 * so we can actually call close()/fclose() only once. We choose to call it
 * for rcl_outfile[] since there may be characters to flush.
 * Return value is first error code encountered, but the routine always
 * attempts to execute to completion.
 */
{
   int err;     /* final RCL error code, first error encountered */
   int result;  /* Unix return code */

   if (addr<0 || addr>=RCL_MAX_CONNECT || rcl_socket[addr] == 0)  {
      return(RCL_ERR_NETBADREF);
   }

   err = RCL_ERR_NONE;      /* assume no error until one occurs */

   if (rcl_outfile[addr] != NULL)  {
      result = fclose(rcl_outfile[addr]);
      if (result != 0)  {
         if (err==RCL_ERR_NONE)
            err=RCL_ERR_IO;
      }
      rcl_outfile[addr] = NULL;
   }

   if (rcl_infile[addr] != NULL)  {
      /* don't call fclose(), descriptor already closed */
      rcl_infile[addr] = NULL;
   }

   rcl_socket[addr] = 0;
   rcl_unget[addr] = -1;
   rcl_hostname[addr][0] = (char)NULL;
   RclSocketCnt--;

   return(err);
}

int rcl_setbaud(int baudrate)
/*
 * Set the baud rate of the socket used for the RCL.  Null operation.
 */
{
   return(RCL_ERR_NONE);
}

int rcl_delay(int msec)
/*
 * Delay for 'msec' milliseconds.
 */
{
   usleep(msec*1000L);

   return(RCL_ERR_NONE);
}

int rcl_getch(int addr, unsigned char* c)
/*
 * Input one character from the RCL input buffer
 * Wait if none is available.
 * Return value is local error code.
 */
{
   int result;

   if (addr>=0 && addr<RCL_MAX_CONNECT && rcl_socket[addr] != 0
                                       && rcl_infile[addr] != NULL)  {
      if (rcl_unget[addr] != -1)  {       /* use unget character if avail */
         result = rcl_unget[addr];
         rcl_unget[addr] = -1;
      }
      else  {
         result = fgetc(rcl_infile[addr]);
      }

	if (result == EOF) {
         rcl_close(addr);
         return(RCL_ERR_NETREMCLS);
      }
      else  {
         *c = (unsigned char) result;
         return(RCL_ERR_NONE);
      }
   }
   else  {
      return(RCL_ERR_NETBADREF);
   }
}

ibool rcl_checkch(int addr)
/*
 * Check if any characters are ready to input from the RCL input buffer
 * If so, return TRUE, otherwise return FALSE. We also return TRUE if
 * there are no characters available but a read request would return an
 * error without blocking. This forces a subsequent read request to receive
 * and handle the error (typically a broken connection in the case of sockets).
 * If this routine returns TRUE, the caller should always follow it with a
 * call to rcl_getch().
 *
 * This routine exists because
 * of the way things are/were structured for serial I/O in the VxWorks and
 * MSDOS environments where the RCL grew up (MSDOS for RCLCO). Unfortunately
 * checking if any characters are ready to be input is a little harder in
 * a Unix/network environment. We handle it in a kludgey way by performing
 * a non-blocking read of one character & passing the character to rcl_getch()
 * via the rcl_unget[] one-character buffer. We would rather use something
 * like the following (from the fkbhit() function), but it doesn't work for
 * sockets (FIONREAD operation is not supported, as tested on SunOS 4.1.1).
 * Oh well.
 * 
 *    int code;
 *    long int bytes_avail;
 *
 *    if (rcl_infile[addr]->_cnt > 0)
 *       return(TRUE);
 *
 *    code = ioctl(fileno(rcl_infile[addr]),FIONREAD, (caddr_t) &bytes_avail);
 *
 *    return(code!=-1 && bytes_avail>0);
 */
{
   int result;      /* Unix system function return value */
   char c;          /* character read from socket */
   int errno_save;  /* holder for errno in case changes */

   if (addr>=0 && addr<RCL_MAX_CONNECT && rcl_socket[addr] != 0
                                       && rcl_infile[addr] != NULL)  {
      /* first check if any characters in unget buffer */ 
      if (rcl_unget[addr] != -1)
         return(TRUE);

      /* check if any characters in stdio buffer */ 
#ifdef LINUX
      if (rcl_infile[addr]->_IO_read_ptr != rcl_infile[addr]->_IO_read_end)
#else
      /* SunOS 4.x */
      if (rcl_infile[addr]->_cnt > 0)
#endif  /* LINUX */
         return(TRUE);

      /* set socket descriptor for non-blocking read and try to read a
           character */
      if (fcntl(rcl_socket[addr], F_SETFL, O_NDELAY) == -1)  {
         perror("rcl_checkch(): Error from fcntl(,,O_NDELAY)");
         return(FALSE);
      }

      result = read(rcl_socket[addr], &c, 1);     /* read one char */
      errno_save = errno;

      /* set socket descriptor back to normal blocking read */
      if (fcntl(rcl_socket[addr], F_SETFL, 0) == -1)  {
         perror("rcl_checkch(): Error from fcntl(,,0)");
      }

      if (result <= 0)  {
         /* Error occurred, return FALSE if EWOULDBLOCK (the error we expected)
              and TRUE if some other error that should get caught by the 
              next real read attempt. Thus we can take proper local action
              such as closing the socket. */
         if (errno_save==EWOULDBLOCK)
            return(FALSE);
         else
            return(TRUE);
      }

      /* No error occurred, put the character we got in the unget buffer and
           return TRUE. We could use ungetc() but don't because it causes
           too many portability problems and may be unreliable. It's also
           probably much less efficient. */
      rcl_unget[addr] = (int)c & 0xff;

      return(TRUE);
   }

   /* invalid reference address!? */
   return(TRUE);
}

int rcl_putch(int addr, unsigned char c)
/*
 * Output one character to the RCL output buffer
 */
{
   if (addr>=0 && addr<RCL_MAX_CONNECT && rcl_outfile[addr] != NULL)  {
      if (fputc(c, rcl_outfile[addr]) == EOF)  {
         rcl_close(addr);
         return(RCL_ERR_NETREMCLS);
      }
      else  {
         return(RCL_ERR_NONE);
      }
   }
   else  {
      return(RCL_ERR_NETBADREF);
   }
}

int rcl_flushout(int addr)
/*
 * Flush the RCL output buffer, i.e. force any buffered output
 * to be sent immediately.
 */
{
   if (addr>=0 && addr<RCL_MAX_CONNECT && rcl_socket[addr] != 0
                                       && rcl_outfile[addr] != NULL)  {
      if (fflush(rcl_outfile[addr]) == EOF)  {
         rcl_close(addr);
         return(RCL_ERR_NETREMCLS);
      }
      else  {
         return(RCL_ERR_NONE);
      }
   }
   else  {
      return(RCL_ERR_NETBADREF);
   }
}

void rcl_open_list(int* num, int addrs[])
/*
 * Returns a list of the reference addresses currently open.
 * 'num' returns the number of currently open connections, 0 if no connections
 *       open.
 * 'addrs' returns a list of open addresses. The array size should be at least
 *         RCL_MAX_CONNECT.
 */
{
   int i;            /* socket table index (reference address) */

   *num=0;

   /* find used entries in the socket table */
   for ( i=0; i<RCL_MAX_CONNECT; i++ )  {
      if (rcl_socket[i] != 0)
         addrs[(*num)++]=i;
   }
}

const char* rcl_addr_to_hostname(int addr)
/*
 * Returns the host name for a currently open reference address.
 * Returns empty string ("") if connection not open.
 */
{
   if (addr==RCL_ADDR_BROADCAST)
      return("broadcast");

   if (addr<0 || addr>=RCL_ADDR_MASTER || rcl_socket[addr] == 0)
      return("");

   return(rcl_hostname[addr]);
}
