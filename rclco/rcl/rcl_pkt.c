#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#include "rcl_def.h"
#include "rcl_sys.h"

#include "rcl_pkt.h"


/*
 * Recorder Control Link "master" side packet assembly/disassembly routines.
 * The "master" side sends commands while the "slave" side (e.g. S2) carries
 * out the commands and issues responses.
 */


/*
 * Variables local to this module ('static'). 
 */
static unsigned char rcl_seq = 0;    /* sequence number for packet protocol */


int rcl_init(void)
/*
 * Configures the RCL RS232 port.
 */
{
   int err;        /* error return code */

   err=rcl_portinit();
   if (err!=RCL_ERR_NONE)  {
      fprintf(stderr,"Couldn't initialize RCL port in rcl_init()\n");
      return(err);
   }
   err=rcl_setbaud(RCL_BAUDRATE);
   if (err!=RCL_ERR_NONE)  {
      fprintf(stderr,"Couldn't set RCL port baud rate to %d in rcl_init()\n",
                                                                 RCL_BAUDRATE);
      return(err);
   }

   return(RCL_ERR_NONE);
}

int rcl_shutdown(void)
{
   int err;

   err=rcl_portshutdown();
   if (err!=RCL_ERR_NONE)  {
      fprintf(stderr,"Couldn't shut down RCL port in rcl_shutdown()\n");
   }

   return(err);
}

int rcl_getchar(int addr, unsigned char* c, int timeout)
/*
 * Reads a character from the RCL (RS232) port. Blocks until a character
 * is received, or until 'timeout' in milliseconds is exceeded.
 * The timeout should be a multiple of 50 milliseconds.
 * A timeout value of -1 indicates an infinite timeout.
 * Return value is error code.
 */
{
   int err;
   unsigned char result;
   int timecount;           /* timeout counter */

   if (timeout!=-1)  {
      timecount=timeout/50;
      while (!rcl_checkch(addr))  {
         if (timecount<=0)
            return(RCL_ERR_TIMEOUT);
         rcl_delay(50);                  /* wait 50 ms */
         timecount--;
      }
   }
   err=rcl_getch(addr, &result);
   if (err!=RCL_ERR_NONE)
      return(err);

   if (RclDebug>=2)  {
      printf(" 0x%02x",result);
      fflush(stdout);
   }

   *c=result;

   return(RCL_ERR_NONE);
}

int rcl_putchar(int addr, unsigned char c)
/*
 * Writes a character to the RCL (RS232) port. 
 */
{
   int err;

   err=rcl_putch(addr, c);

   return(err);
}

void rcl_clearbuf(int addr)
/*
 * Empties the RCL input buffer by reading and throwing away all
 * characters. Should never block, but just in case we give up after
 * RCL_JUNKCHARS_MAX characters.
 */
{
   int err;
   unsigned char dummy;       /* character bit bucket */
   int junk_chars;            /* count of junk characters */

   junk_chars=0;
   while (rcl_checkch(addr))  {
      err=rcl_getch(addr, &dummy);
      if (err!=RCL_ERR_NONE)
         return;                /* error!? */

      if (junk_chars++>RCL_JUNKCHARS_MAX)  {
         printf("*** rcl_clearbuf(): RCL slave device spewing junk!!\n");
         return;
      }

      if (RclDebug>=2)  {
         printf(" 0x%02x",dummy);
         fflush(stdout);
      }
   }
}

int rcl_packet_read(int addr, int* code, char* data, int maxlength,
                    int* length, int timeout)
/* 
 * Reads a correctly-formed packet from the Recorder Control Link.
 * Times out if any individual character takes longer than 'timeout' 
 * milliseconds to receive, or if more than RCL_JUNKCHARS_MAX are received
 * that are not part of a valid packet. The second case prevents calling
 * tasks from hanging if an RCL slave device for some reason is spewing a
 * continuous stream of junk. 
 * 'addr' is the address of the RCL device to read packet from, or the
 *        socket index returned by rcl_open() if using a network connection.
 *        This parameter is only really used for network connections.
 * 'code' returns the command/response code of the received packet.
 * 'data' returns the data portion of the received packet.
 * 'maxlength' specifies the maximum size of the 'data' buffer. Any data
 *             longer than 'maxlength' is truncated. If 'maxlength' is 
 *             RCL_PKT_MAX then truncation will never occur.
 * 'length' returns the length of the received 'data' buffer *before*
 *          truncation. Thus the actual length is min(*length,maxlength).
 * 'timeout' specifies a read timeout in milliseconds. This should be a
 *           multiple of 50 milliseconds. A value of -1 indicates an infinite
 *           timeout.
 */
{
   int err;
   int pos;
   int len;               /* received packet length */
   int trunclen;          /* data buffer length after truncation */
   int junk_chars;        /* count of junk characters (not precise) */
   unsigned char c;
   unsigned char ch,cl;   /* hi/low byte of 16-bit quantity */
   long int chksum;       /* accumulator for checksum */
   static unsigned char packet[RCL_PKT_MAX+2];
                          /* entire packet, incl SOT & EOT (static so we don't
                               use up too much stack space) */

   junk_chars=0;
restart:             /* branch point for silent discarding of packet */
   /* wait for an SOT character */
   do  {
      err=rcl_getchar(addr, &c, timeout);
      if (err!=RCL_ERR_NONE)  {
         return(err);
      }
      if (junk_chars++>RCL_JUNKCHARS_MAX)  {
         printf("*** rcl_packet_read(): RCL slave device spewing junk!!\n");
         return(RCL_ERR_TIMEOUT);
      }
   }  while(c!=RCL_SOT);

   /* get packet length hi byte (note: cannot equal 1, so no need to
        de-stuff SOTs */
   err=rcl_getchar(addr, &ch, timeout);
   if (err!=RCL_ERR_NONE)  {
      return(err);
   }
   
restart2:
   chksum=ch;              /* initialize chksum */

   /* get packet length low byte */
   err=rcl_getchar(addr, &cl, timeout);
   if (err!=RCL_ERR_NONE)  {
      return(err);
   }
   /* de-stuff SOTs, in case low-byte of length == 1 */
   if (cl==RCL_SOT)  {
      err=rcl_getchar(addr, &c, timeout);
      if (err!=RCL_ERR_NONE)  {
         return(err);
      }
      if (c!=RCL_SOT)  {
         /* assume c is hi length byte of new packet */
         ch=c;
         goto restart2;
      }
   }
   chksum+=cl;
   
   len=(((int)ch<<8) & 0xff00) + cl - RCL_PKT_FUDGE;

   /* check length in allowed range */
   if (len<RCL_PKT_MIN || len>RCL_PKT_MAX)
      goto restart;

   /* Read rest of packet, up to and including EOT. We leave a 3 byte space
        at the start for SOT and len even though these are not written
        into the buffer. This is to help us get our counting right. */
   for (pos=3; pos<len+2; pos++)  {    /* the '+2' is for SOT & EOT */
      err=rcl_getchar(addr, &c, timeout);
      if (err!=RCL_ERR_NONE)  {
         return(err);
      }
      junk_chars++;

      if (c==RCL_SOT)  {
         err=rcl_getchar(addr, &c, timeout);
         if (err!=RCL_ERR_NONE)  {
            return(err);
         }
         if (c!=RCL_SOT)  {
            /* assume c is hi length byte of new packet */
            ch=c;
            goto restart2;
         }
      }
      /* Add to checksum. Include all bytes except chksum and EOT */
      if (pos<len-1)
         chksum+=c;

      packet[pos]=c;
   }

   /* verify checksum */
   ch=packet[len-1];
   cl=packet[len];
   if ((((int)ch<<8) & 0xff00) + cl != (chksum & 0xffff))
      goto restart;           /* checksum error, discard packet */

   /* check address */
   if (packet[3]!=RCL_ADDR_MASTER && packet[3]!=RCL_ADDR_BROADCAST)
      goto restart;           /* bad address, discard packet. */

   /* ensure that EOT character was received */
   if (packet[len+1]!=RCL_EOT)
      goto restart;           /* no EOT, discard packet */

   /* Command considered valid from this point on */

   /* check sequence number */
   if (rcl_seq!=packet[5])  {
      /* sequence number does not match last command sent, so discard packet */
      goto restart;           /* get next command */
   }

   *code=packet[4];           /* extract command code */
   *length=len-7;             /* get length of data portion */

   trunclen=*length;
   if (maxlength<trunclen)
      trunclen=maxlength;

   if (trunclen>0)
      memcpy(data,packet+6,trunclen);
   
   return(RCL_ERR_NONE);          /* done */
}

int rcl_packet_write(int addr, int code, const char* data, int length)
/* 
 * Writes a correctly formed packet to the Recorder Control Link.
 * 'addr' is the desired RCL device address, or the socket index returned by
 *        rcl_open() if using a network connection. 
 * 'code' is the command/response code to use (0-255).
 * 'data' is the data portion of the packet. It can be passed as NULL if 
 *        'length' is 0.
 * 'length' is the length of the 'data' buffer. The value -1 is a special case
 *          and indicates that the previous packet should be retransmitted,
 *          in which case 'code' and 'data' are not used, and should be NULL
 *          ('addr' will also not be used unless it refers to a network socket
 *          connection).
 */
{
   int err;
   int pos;
   int len;                   /* length of packet, not including SOT and EOT */
   unsigned char c;
   long int chksum;           /* accumulator for checksum */
   int addr_send;             /* address to put in packet */
   static unsigned char packet[RCL_PKT_MAX+2];
                              /* entire packet, incl SOT & EOT. We make it
                                   static so it can be retransmitted. */

   /* Determine what address to actually send in the packet. When using a
        serial port, the address to send ('addr_send') is the same as the
        'addr' parameter. When using a network connection, the broadcast
        address is sent instead. We assume a network connection is being
        used if any sockets have been opened. */ 
   if (RclSocketCnt>0)  {
      addr_send = RCL_ADDR_BROADCAST;
   }
   else  {
      addr_send = addr;
      addr = 0;       /* this will not be used, but we still pass it below */

      /* Discard any characters received since last reply, must be garbage.
           We don't do this in the network case because it confuses error
           handling on socket reads. */
      rcl_clearbuf(addr);
   }

   if (length==-1)  {
      /* retransmit previous packet */
      len=(((int)packet[1]<<8) & 0xff00) + packet[2] - RCL_PKT_FUDGE;
      goto retransmit;
   }

   len=length+7;                  /* 7 extra bytes, not counting SOT and EOT */
   assert(len<=RCL_PKT_MAX && len>=RCL_PKT_MIN);
   packet[1]=((len+RCL_PKT_FUDGE)>>8) & 0xff;     /* hi byte */
   packet[2]=(len+RCL_PKT_FUDGE) & 0xff;          /* low byte */

   assert(addr_send<=255 && addr_send>=0);
   packet[3]=addr_send;

   assert(code<=255 && code>=0);
   packet[4]=code;                /* command code */

   packet[5]=++rcl_seq;           /* new sequence number */

   if (length>0)
      memcpy(packet+6,data,length);

   packet[len+1]=RCL_EOT;

retransmit:       /* function parameters may be invalid after this point */
   err=rcl_putchar(addr, RCL_SOT);
   if (err!=RCL_ERR_NONE)  {
      return(err);
   }

   chksum=0;
   for (pos=1; pos<len+2; pos++)  {
      /* special case for checksum */
      if (pos==len-1)
         c=(chksum>>8) & 0xff;      /* hi byte */
      else if (pos==len)
         c=chksum & 0xff;           /* low byte */
      else
         c=packet[pos];

      err=rcl_putchar(addr, c);
      if (err!=RCL_ERR_NONE)  {
         return(err);
      }

      if (c==RCL_SOT)  {
         err=rcl_putchar(addr, c);
         if (err!=RCL_ERR_NONE)  {
            return(err);
         }
      }
      /* Add to checksum. Include all bytes except chksum and EOT */
      if (pos<len-1)
         chksum+=c;
   }

   rcl_flushout(addr);        /* flush to make packet get sent */

   return(RCL_ERR_NONE);
}

