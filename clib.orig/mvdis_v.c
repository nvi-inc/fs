/* log formatting for vlba et and rw/ff commands */
#include <string.h>
#include "../include/params.h"
#include "../include/res_ds.h"

void mvdis_v(ip,ibuf,nch)
long ip[5];
char *ibuf;
int *nch;
{
      struct res_buf buffer_out;
      struct res_rec response;
      int some;                 /* did we get anything */

      ibuf[*nch-1]='\0';
      opn_res(&buffer_out,ip);
      get_res(&response, &buffer_out);
      some=FALSE;
      while( response.state != -1) {
        some=TRUE;
        strcat(ibuf,"ack,");
        *nch+=4;
        get_res(&response, &buffer_out);
      }
      if(some) (*nch)--;    /* delete trailing comma */

      clr_res(&buffer_out);
      ip[0]=ip[1]=ip[2]=0;
      return;
}
