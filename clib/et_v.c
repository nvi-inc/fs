/* end tape movement for vlba recorder */

#include "../include/req_ds.h"
#include "../include/res_ds.h"

void et_v(ip)
long ip[5];
{
      struct req_buf buffer;
      struct req_rec request;

      ini_req(&buffer);                      /* format the buffer */
      memcpy(request.device,"rc",2);
      request.type=0;
      request.addr=0xb0; request.data=0x01  ; add_req(&buffer,&request);

      end_req(ip,&buffer);                /* send buffer and schedule */
      skd_run("mcbcn",'w',ip);
      skd_par(ip);
      return;
}
