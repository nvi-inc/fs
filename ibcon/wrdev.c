/* wrdev - write to IEEE device
   It assumes you will use the configuration 'ibboard' for the 
   board. 
   NRV 921202 Changed buffer to char
 */
#include <memory.h>
#include "ugpib.h"

void wrdev_(devid,buffer,buflen,error)

int *devid;
/*int *buffer; */
unsigned char *buffer;
int *buflen;  /* length of the message in buffer, characters */
int *error;

{
  *error = 0;

  ibwrt(*devid,buffer,*buflen);

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
