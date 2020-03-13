/*
 * Copyright (c) 2020 NVI, Inc.
 *
 * This file is part of VLBI Field System
 * (see http://github.com/nvi-inc/fs).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dos.h>

#include "comio.h"


/*****************************************************************************/
/* Local Static Data                                                         */

static char buffer[COM_BUFF_SIZE];/* Circular buffer */
static char *inptr;               /* Pointer to input point of circular buff*/
static char *outptr;              /* Pointer to output point of circular buff*/
static int  count = 0;            /* Number of characters in buffer */

static mdminfo modem;             /* current com port info */

void interrupt (*oldvec)();       /* Vector of previous com interrupt */
static int portin = 0;            /* Flag to indicate com port is open */
#ifdef FLOW_ENABLE
static int xofsnt = 0;            /* Flag to indicate an XOFF transmitted */
static int xofrcv = 0;            /* Flag to indicate an XOFF received */
#endif

/*****************************************************************************/

/*  T T I N I T  -- Initialize the communications system */

void TTinit() {

    /* set default values. Note: the bootup default baud rate for RCLCO
         is controlled by RCL_BAUDRATE in rcl/rcl_def.h. */
    port = 1;
    speed = 9600;
    strcpy(parity,"NONE");
    databits = 8;
    stopbits = 1;
}


/*  T T O P E N  -- Open the communications port */

int ttopen() {
    if (portin == 0) {            /* Ignore call if already open */
        switch (port) {
            case 1:
                coms(1);             /* COM 1 */
                break;
            case 2:
                coms(2);             /* COM 2 */
                break;
            default:                 /* others not supported, return error */
                return(-1);
        }
        dobaud(speed);               /* Set baud rate */
        serini();                    /* enable interrupt handler */
    }
    return(0);                    /* return success */
}


/*  T T C L O S E --  Close the communications port  */

int ttclose() {
    if (portin != 0)              /* Ignore if port is already closed */
        serrst();                    /* otherwise disable interrupts */
    return(0);                    /* return success */
}




/* T T C H K  --  Return a count of characters at the serial port */

int ttchk() {
    return( count );              /* return maintained count */
}


/* T T O C -- Output a character to the current serial port */

void ttoc( unsigned char c ) {

    while( (inportb(modem.mdstat) & 0x20) == 0 )
       ;                          /* Wait til transmitter is ready */
    outportb(modem.mddat,c);      /* then output the character */
}


/* T T F L U I  --  Clear the input buffer of characters */


void ttflui() {

#ifdef FLOW_ENABLE
    if (xofsnt){                  /* Check if XON should be sent after XOFF */
       xofsnt = 0;                  /* if so then reset XOFF sent status */
       ttoc(XON);                   /* and send the XON */
       }
#endif
    disable();                    /* NO interrupts allowed now */
    inptr = outptr = buffer;      /* Reset input out output pointers */
    count = 0;                    /* Set received characters count to 0 */
    enable();                     /* Now interrupts are ok */
}


/* T T I N C  -- Read a character from serial ports circular buffer */

int ttinc() {
    int c;
    register char * ptr;

#ifdef FLOW_ENABLE
    if (count < XONPT && xofsnt){ /* Check if XON should be sent after XOFF */
       xofsnt = 0;                  /* if so then reset XOFF sent status */
       ttoc(XON);                   /* and send the XON */
       }
#endif

    while (count <= 0)            /* If no characters have arrived then */
        ;                            /* wait til one arrives */

    ptr = outptr;                 /* Save address of buffer output point */

    c = *ptr++;                   /* Get this character and increment ptr */

                                  /* See if circular buff should be wrapped */
    if (ptr == &buffer[COM_BUFF_SIZE])
        ptr = buffer;                /* if so then save new output point */

    disable();                    /* NO interrupts allowed now */
    outptr = ptr;                 /* Save the address of output point */
    count--;                      /* Decrement count of received characters */
    enable();                     /* Interrupts can continue now */

    return(c);                    /* Return the received character */
}


/* D O B A U D  --  Set the baud rate for the current port */

int dobaud( unsigned int baudrate ) {
   unsigned char portval;
   unsigned char blo, bhi;
   switch (baudrate) {            /* Get 8250 baud rate divisor values */
       case 50:     bhi = 0x9;  blo = 0x00;  break;
       case 75:     bhi = 0x6;  blo = 0x00;  break;
       case 110:    bhi = 0x4;  blo = 0x17;  break;
       case 150:    bhi = 0x3;  blo = 0x00;  break;
       case 300:    bhi = 0x1;  blo = 0x80;  break;
       case 600:    bhi = 0x0;  blo = 0xC0;  break;
       case 1200:   bhi = 0x0;  blo = 0x60;  break;
       case 1800:   bhi = 0x0;  blo = 0x40;  break;
       case 2000:   bhi = 0x0;  blo = 0x3A;  break;
       case 2400:   bhi = 0x0;  blo = 0x30;  break;
       case 4800:   bhi = 0x0;  blo = 0x18;  break;
       case 9600:   bhi = 0x0;  blo = 0x0C;  break;
       case 19200:  bhi = 0x0;  blo = 0x06;  break;
       case 38400U: bhi = 0x0;  blo = 0x03;  break;
       case 57600U: bhi = 0x0;  blo = 0x02;  break;

       default:                   /* Return failure if baud unsupported */
           return(-1);
   }

   portval = inportb(modem.mdcom);/* Save current value of command register */

                                  /* In order to set the baud rate the */
                                  /* high bit of command data register is */
   outportb(modem.mdcom,portval | 0x80 ); /* set before sending baud data */

   outportb(modem.mddat,blo);     /* Set LSB Baud-Rate divisor for baud */
   outportb(modem.mddat + 1,bhi); /* Set MSB Baud-Rate divisor for baud */

   outportb(modem.mdcom,portval); /* Reset original command register value */

   return(0);                     /* Return success */
}


/*  C O M S  --  Set up the modem structure for the specified com port */

void coms( int portid ) {

    if (portid == 1) {            /* Port data for COM 1 */
        modem.mddat = MDMDAT1;       /* Port 1 Data register */
        modem.mdstat = MDMSTS1;      /* Port 1 Status register */
        modem.mdcom = MDMCOM1;       /* Port 1 Command register */
        modem.mddis = MDMINTC;       /* Port 1 8259 IRQ4 disable mask */
        modem.mden = MDMINTO;        /* Port 1 8259 IRQ4 enable mask */
        modem.mdintv = MDMINTV;      /* Port 1 interrupt number */
    }
    else if (portid == 2) {       /* Port data for COM 2 */
        modem.mddat = MDMDAT2;       /* Port 2 Data register */
        modem.mdstat = MDMSTS2;      /* Port 2 Status register */
        modem.mdcom = MDMCOM2;       /* Port 2 Command register */
        modem.mddis = MDINTC2;       /* Port 2 8259 IRQ4 disable mask */
        modem.mden = MDINTO2;        /* Port 2 8259 IRQ4 enable mask */
        modem.mdintv = MDINTV2;      /* Port 2 interrupt number */
    }
}

/* S E R I N I  -- initialize the serial port for interrupts */

void serini() {
    unsigned char portval;

    if (portin == 0) {            /* Ignore if already open */
        portin = 1;                  /* save port open status */
        inptr = outptr = buffer;     /* set circular buffer pointers */
        count = 0;                   /* indicate no characters received */
        oldvec=getvect(modem.mdintv);/* save old com interrupt */
        setvect(modem.mdintv,serint);/* set SERINT as communications ISR */

        portval = 0;              /* Byte value to output to the Line */
                                  /* Control Register (LCR) to set the */
                                  /* Parity, Stopbits, Databits */
                                  /* Start out with all bits zero */

        if (strcmp(parity,"EVEN") == 0)
           portval |= 0x8;        /* Set bit 3 on for odd parity */
        else if (strcmp(parity,"ODD") == 0)
           portval |= 0x18;       /* Set bits 3 and 4 on for even parity */
                                  /* Leave bits 3 and 4 off for no parity */


        if (stopbits == 2)        /* Set bit 2 on if 2 Stopbits are used */
           portval |= 0x4;
                                  /* Leave bit 2 off for 1 Stopbit */

        if (databits == 6)        /* Set bit 0 on for 6 data bits */
           portval |= 0x1;
        else if (databits == 7)   /* Set bit 1 on for 7 data bits */
           portval |= 0x2;
        else if (databits == 8)   /* Set bits 0 and 1 on for 8 data bits */
           portval |= 0x3;
                                  /* Leave bits 0 and 1 off for 5 data bits */

        outportb(modem.mdcom,portval);  /* Output the settings to the LCR */


        outportb(modem.mdcom + 1,0xb); /* Assert OUT2, RTS, DTR */

        inportb(modem.mddat);        /* Clear any left over characters */
        outportb(modem.mddat+1,0x1); /* Enable receiver interrupts */

        portval = inportb(INTCONT);  /* Read 8259 interrupt enable mask */
        outportb(INTCONT,modem.mden & portval); /*Set bit on for com IRQ */
    }
}


/* S E R R S T -- Reset serial port interrupts */

void serrst() {
    unsigned char portval;

    if (portin != 0) {            /* Ignore if interrupts already disabled */
        portin = 0;                    /* save port closed status */
        portval = inportb(INTCONT);    /* Read 8259 interrupt enable mask */
        outportb(INTCONT,modem.mddis | portval);/*Set bit off for com IRQ */
        setvect(modem.mdintv,oldvec);  /* return original interrupt vector */
    }
}


/*  S E R I N T  -- Serial interrupt handler, recieves incoming characters */

void interrupt serint() {

nextchar:
    *inptr++=inportb(modem.mddat);/* Quickly read arriving character */
    count++;                      /* Increment received count */

#ifdef FLOW_ENABLE
    if (count > XOFFPT && xofsnt != 1){ /* If buffer almost full then */
       ttoc(XOFF);                /* send an XOFF */
       xofsnt = 1;                /* and save XOFF sent status */
       }
#endif
    disable();                    /* NO interrupts are allowed while */
                                  /* new input pointer is stored */
    if (inptr == &buffer[COM_BUFF_SIZE]) /* At end of circular buff? */
       inptr = buffer;                /* if so then save new output point */

    enable();                     /* Interrupts ok now */

#if 0
    /* check if another character is available */
    if( (inportb(modem.mdstat) & 0x01) != 0 )
       goto nextchar;
#endif

    outportb(0x20,0x20);          /* send End Of Interrupt to 8259 */
}

