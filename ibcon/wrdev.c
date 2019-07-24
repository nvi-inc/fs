/*
 * It assumes you will use the configuration 'ibboard' for the 
 * board. 
 */
#include <memory.h>
#include "ugpib.h"
extern int boardid;

void wrdev_(devid,buffer,buflen,error)

int *devid;
/*int *buffer; */
char *buffer;
int *buflen; 
int *error;

{

  ibcmd(boardid,"?_",2);      /* send UNT, UNL first */

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

  ibcmd(boardid,"?_",2);      /* send UNT, UNL at end */
}
