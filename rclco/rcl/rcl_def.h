#ifndef RCL_DEF_DEFD
#define RCL_DEF_DEFD

/*
 * Local constant (macro) and type definitions for the Recorder Control
 * Link (RCL). See also system-independent definitions in rcl.h.
 */

#include "rcl.h"             /* get system-independent definitions */
#include "ext_ircl.h"

#define RCL_BAUDRATE       19200      /* default baud rate to use on RCL serial
                                           port */

#define RCL_MAX_CONNECT    32         /* maximum number of socket connections
                                           allowed */

#define RCL_TIMEOUT        500        /* usual timeout for reading RCL port
                                           in milliseconds. Used for commands
                                           which essentially complete
                                           instantly */
#define RCL_TIMEOUT_TC     1500       /* RCL timeout for transport control
                                           commands such as rewind, in ms */
#define RCL_TIMEOUT_S1     1250       /* RCL timeout for commands whose replies
                                           are synchronized to a 1 Hz tick */
#define RCL_RETRIES        2          /* number of retries before giving up */

#define RCL_JUNKCHARS_MAX  (RCL_PKT_MAX*2+500)
                                      /* number of junk characters before a
                                           timeout is declared, to detect ext.
                                           control computer spewing junk (must
                                           be several times > RCL_PACKET_MAX) */

/* Local error codes. These are positive to distinguish them from error codes
     returned by RCL devices (such as the S2), which are negative. */
#define RCL_ERR_NONE       0   /* No error has occurred */
#define RCL_ERR_OPFAIL     1   /* Operation failed (non-specific error) */
#define RCL_ERR_IO         2   /* I/O error */
#define RCL_ERR_TIMEOUT    3   /* Communications timeout, RCL device probably dead */
#define RCL_ERR_BADVAL     4   /* Parameter value is illegal or out of range */
#define RCL_ERR_BADLEN     5   /* String parameter is too long/short */
#define RCL_ERR_NETIO      6   /* Network I/O error */
#define RCL_ERR_NETBADHOST 7   /* Unknown host name */
#define RCL_ERR_NETBADREF  8   /* No connection open for that reference address */
#define RCL_ERR_NETMAXCON  9   /* No more network connections can be opened */
#define RCL_ERR_NETREMCLS 10   /* Network connection closed by remote host */
/* The following 3 errors should occur only if the external RCL device's
     software is incompatible with this RCL library, and indicate that an
     updated version of the library is required. */ 
#define RCL_ERR_PKTUNEX   11   /* Unexpected response packet from RCL device */
#define RCL_ERR_PKTLEN    12   /* Wrong packet length returned by RCL device */
#define RCL_ERR_PKTFORMAT 13   /* Bad format in packet returned by RCL device */


/* Misc defines */
#ifndef TRUE
# define TRUE   (1==1)
# define FALSE  (1==0)
  typedef int ibool;      /* we don't use 'bool' because curses does */
#endif


/*
 * Global variables
 */
EXTERN int RclDebug  INIT(0);         /* flag to control debug output, 
                                           0 is off, higher numbers give
                                           more output. */

EXTERN int RclNumRetries  INIT(0);    /* cumulative count of RCL retries */

EXTERN int RclSocketCnt  INIT(0);     /* number of socket connections active */


#endif /* not RCL_DEF_DEFD */
