/* check to make sure motion is done and voltage is updated */

#include <sys/types.h>
#include <sys/times.h>
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

int motion_done(ip)
long ip[5];                          /* ipc array */
{
      struct req_buf buffer;
      struct req_rec request;
      struct res_buf buffer_out;
      struct res_rec response;
      int counts,motion,imotion;
      struct tms tms_buff;
      long end;

      ini_req(&buffer);                      /* format the buffer */
      memcpy(request.device,DEV_VRC,2);
      request.type=1; 
      request.addr=0x73; add_req(&buffer,&request);

      request.type=0; request.addr=0xE0; request.data=0x2;
      add_req(&buffer,&request);

      request.type=0; request.addr=0xE1; request.data=0x830E;
      add_req(&buffer,&request);

      request.type=1; request.addr=0x70; add_req(&buffer,&request);

      end_req(ip,&buffer);                  /* send buffer and schedule */
      skd_run("mcbcn",'w',ip);
      skd_par(ip);
      if(ip[2] <0) return;

      opn_res(&buffer_out,ip);              /* decode response */
      get_res(&response, &buffer_out);
      motion=(0x4&response.data) != 0;     /* still moving */

      get_res(&response, &buffer_out);
      get_res(&response, &buffer_out);
      get_res(&response, &buffer_out);
      motion = motion || response.data != 0;  /* firmware still measuring */

      ip[0]=ip[1]=ip[4]=ip[2]=0;
      memcpy(ip+3,"q@",2);

      if(response.state == -1) {
        clr_res(&buffer_out);
        ip[2]=-284;
        return TRUE;
      } else if (motion)
        ip[2]=-288;

      clr_res(&buffer_out);
      return !motion;
}
