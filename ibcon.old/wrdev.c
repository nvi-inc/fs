/*
   It assumes you will use the configuration 'ibboard' for the 
   board. 

 */
#include <memory.h>
#include <string.h>

#ifdef CONFIG_GPIB
#include <ib.h>
#include <ibP.h>
#endif

#define LF		0x0A
#define	TIMEOUT		-4
#define	BUS_ERROR	-8
#define GEN_ERROR	-10
#define	IBCODE		300
#define ASCII		  0
#define BINARY		  1

extern int ID_hpib;

/*----------------------------------------------------------------------*/

void wrdev_(mode,devid,buffer,buflen,error,ipcode)

int *mode,*devid;
long *ipcode;
unsigned char *buffer;
int *buflen;  		/* length of the message in buffer, characters */
int *error;

{
  int val;

  *error = 0;
  *ipcode = 0;

#ifdef CONFIG_GPIB

  ibcmd(ID_hpib,"_?",2);  	/* unaddress all listeners and talkers */
  if ((ibsta & (ERR|TIMO)) != 0)
  {
    *error = -(IBCODE + iberr); 
    memcpy((char *)ipcode,"WC",2);
    return;
  } 

  if ((*mode == 1) || (*mode == 2))
  {
    val = (XEOS <<8) + LF;
    ibeos(*devid,val);			/* send EOI with EOS (LF) character */
    if ((ibsta & (ERR|TIMO)) != 0)
    {
      *error = -(IBCODE  + iberr);
      memcpy((char *)ipcode,"WS",2);
      return;
    }
  
    ibeot(*devid,0);			/* turn off auto EOI transmission */
    if ((ibsta & (ERR|TIMO)) != 0)
    {
      *error = -(IBCODE  + iberr);
      memcpy((char *)ipcode,"WE",2);
      return;
    }

    ibwrt(*devid,buffer,*buflen);
    if ((ibsta & TIMO) != 0)
    {
      *error = TIMEOUT;
      memcpy((char *)ipcode,"W1",2);
      return;
    }
    else if ((ibsta & ERR) != 0)
    {
      *error = -(IBCODE + iberr);
      memcpy((char *)ipcode,"W2",2);
      return;
    }

    ibwrt(*devid,"\r\n",2);
  }
  else
  {
    ibeos(*devid,0);			/* turn off all EOS functionality */
    if ((ibsta & (ERR|TIMO)) != 0)
    {
      *error = -(IBCODE  + iberr);
      memcpy((char *)ipcode,"WT",2);
      return;
    }
  
    ibeot(*devid,1);			/* send EOI auto with last byte */
    if ((ibsta & (ERR|TIMO)) != 0)
    {
      *error = -(IBCODE  + iberr);
      memcpy((char *)ipcode,"WF",2);
      return;
    }
  
    ibwrt(*devid,buffer,*buflen);
  }
  
  if ((ibsta & TIMO) != 0)		/* timeout ? */ 
  {
    *error = -(IBCODE + iberr);
    memcpy((char *)ipcode,"W3",2);
  }  
  else if ((ibsta & ERR) != 0)		/* bus error ? */ 
  {
    *error = -(IBCODE + iberr);
    memcpy((char *)ipcode,"W4",2);
  }

  ibcmd(ID_hpib,"_?",2);  	/* unaddress all listeners and talkers */
  if ((ibsta & (ERR|TIMO)) != 0)
  {
    *error = -(IBCODE + iberr); 
    memcpy((char *)ipcode,"WD",2);
    return;
  } 
#else
    *error = -(IBCODE + 22); 
    return;
#endif
}
