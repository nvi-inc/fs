#ifndef COMIO_DEFD
#define COMIO_DEFD

/* Define MAIN for main definition, leave undefined for external definition. */

#include "ext_init.h"

#undef  FLOW_ENABLE               /* define to enable XON/XOFF flow control */

#define MDMDAT1 0x03F8            /* Address of modem port 1 data */
#define MDMSTS1 0x03FD            /* Address of modem port 1 status  */
#define MDMCOM1 0x03FB            /* Address of modem port 1 command */
#define MDMDAT2 0x02F8            /* Address of modem port 2 data */
#define MDMSTS2 0x02FD            /* Address of modem port 2 status */
#define MDMCOM2 0x02FB            /* Address of modem port 2 command */
#define MDMINTV 0x000C            /* Com 1 interrupt vector */
#define MDINTV2 0x000B            /* Com 2 interrupt vector */
#define MDMINTO 0x0EF             /* Mask to enable IRQ3 for port 1 */
#define MDINTO2 0x0F7             /* Mask to enable IRQ4 for port 2 */
#define MDMINTC 0x010             /* Mask to Disable IRQ4 for port 1 */
#define MDINTC2 0x008             /* Mask to Disable IRQ3 for port 2 */
#define INTCONT 0x0021            /* 8259 interrupt controller ICW2-3 */
#define INTCON1 0x0020            /* Address of 8259 ICW1 */

#define COM_BUFF_SIZE 1024        /* Communications port buffer size */
#ifdef FLOW_ENABLE
# define XOFFPT  COM_BUFF_SIZE*3/4 /* chars in buff before sending XOFF */
# define XONPT   COM_BUFF_SIZE*1/4 /* chars in buff to send XON after XOFF */
# define XOFF    0x13              /* XOFF value */
# define XON     0x11              /* XON value */
#endif


/*****************************************************************************/
/* Types                                                                     */

typedef struct {                  /* struct to hold current com port info */
    unsigned int mddat;             /* 8250 data register */
    unsigned int mdstat;            /* 8250 line-status register */
    unsigned int mdcom;             /* 8250 line-control register */
    unsigned char mden;             /* 8259 IRQ enable mask */
    unsigned char mddis;            /* 8259 IRQ disable mask */
    unsigned char mdintv;           /* Interrupt for selected com port */
} mdminfo ;


/*****************************************************************************/
/* Global Data                                                               */

EXTERN unsigned int port;         /* COM port */
EXTERN unsigned int speed;        /* BAUD rate */
EXTERN char parity[5];            /* Parity setting */
EXTERN unsigned int databits;     /* Number of Data bits */
EXTERN unsigned int stopbits;     /* Number of Stop bits */


/*****************************************************************************/
/* Function prototypes                                                       */

void TTinit( void );              /* Initialize the communications system */
int ttopen( void );               /* Open a port for communications */
int ttclose( void );              /* Close the communications port */
int ttchk( void );                /* Return count of received characters */
void ttoc( unsigned char );       /* Output a character to the com port */
int ttinc( void );                /* Input a character from circular buffer */
void ttflui( void );              /* Flush circular buffer of characters */
int dobaud( unsigned int );       /* Set the baud rate for the port */
void coms( int );                 /* Establish modem data */
void serini( void );              /* Initialize the com port for interrupts */
void serrst( void );              /* Reset the com port to original settings */
void interrupt serint( void );    /* Com port receiver ISR */


#endif /* COMIO_DEFD */
