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

  { int i;
    static char addrs[]={"_?$@"};
    for (i=0;i<sizeof(addrs)-1;i++) {
       ibcmd(ID_hpib,addrs+i,1);
       rte_sleep( 10);

       if ((ibsta & (ERR|TIMO)) != 0)
       {
       *error = -(IBCODE + iberr); 
       memcpy((char *)ipcode,"WC",2);
       return;
       }
    }
  } 

  if ((*mode == 1) || (*mode == 2))
  {
    val = (XEOS <<8) + LF;
    ibeos(ID_hpib,val);			/* send EOI with EOS (LF) character */
    if ((ibsta & (ERR|TIMO)) != 0)
    {
      *error = -(IBCODE  + iberr);
      memcpy((char *)ipcode,"WS",2);
      return;
    }
  
    ibeot(ID_hpib,0);			/* turn off auto EOI transmission */
    if ((ibsta & (ERR|TIMO)) != 0)
    {
      *error = -(IBCODE  + iberr);
      memcpy((char *)ipcode,"WE",2);
      return;
    }

    {int i;
     for (i=0; i<*buflen; i++) {
      ibwrt(ID_hpib,buffer+i,1);
      rte_sleep( 10);
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
    }
   }

    { int i;
      static char ech[]={"\r\n_?"};
      for (i=0; i<sizeof(ech)-1;i++) {
        ibwrt(ID_hpib,ech+i,1);
	rte_sleep( 10);
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
      }
    }

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
  
#else
    *error = -(IBCODE + 22); 
    return;
#endif
}
