/* wrdev - write to IEEE device
   It assumes you will use the configuration 'ibboard' for the 
   board. 
   NRV 921202 Changed buffer to char
 */
#include <memory.h>
#include "ugpib.h"
extern int boardid_ext;

void wrdev_(devid,buffer,buflen,error)

int *devid;
/*int *buffer; */
unsigned char *buffer;
int *buflen;  /* length of the message in buffer, characters */
int *error;

{
  int val, len;
  *error = 0;

  val = (XEOS <<8) + 0x0A;
  ibeos(*devid,val);
  memcpy(buffer+*buflen,"\r\n",2);
  len=*buflen+2;
/*
  { int i;
    printf("\n wrdev:");
    for (i=0;i<len;i++)
       printf("%2x ",buffer[i]);
    printf("\n");
  }
*/
  ibwrt(*devid,buffer,len);


/*printf("\n ibsta = %.4xh iberr = %d ibcnt %d\n\n", ibsta,iberr,ibcnt);
*/
  
  if ( (ibsta & 0x4000) != 0) {
    *error = -4;
    return;
  }
  else if ((ibsta & 0x8000) != 0) {
    *error = -8;
    return;
  }

  if (iberr != 0) *error=-10;

}
