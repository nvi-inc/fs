/* check to make sure motion is done and voltage is updated */

#include <sys/types.h>
#include <sys/times.h>
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

int v2_motion_done(ip)
long ip[5];                          /* ipc array */
{
      struct req_buf buffer;
      struct req_rec request;
      struct res_buf buffer_out;
      struct res_rec response;
      int counts,motion, oorange, time_out;
      struct tms tms_buff;
      long end;

      ini_req(&buffer);                      /* format the buffer */
      memcpy(request.device,DEV_VRC,2);
      request.type=1; 
      request.addr=0x74; add_req(&buffer,&request);
      request.addr=0x73; add_req(&buffer,&request);

      end_req(ip,&buffer);                  /* send buffer and schedule */
      skd_run("mcbcn",'w',ip);
      skd_par(ip);
      if(ip[2] <0) return;

      opn_res(&buffer_out,ip);              /* decode response */

      get_res(&response, &buffer_out);
      oorange=(0x1&response.data) != 0;     /* command out of range */
      time_out = ((1 << 9) & response.data) != 0;

      get_res(&response, &buffer_out);
      motion=(0x10&response.data) != 0;     /* still moving */

      ip[0]=ip[1]=ip[4]=ip[2]=0;
      memcpy(ip+3,"q@",2);

      if(response.state == -1) {
        clr_res(&buffer_out);
        ip[2]=-292;
        return TRUE;
      } else if (oorange)
	ip[2]=-289;
      else if (motion)
        ip[2]=-288;
      else if (time_out)
	ip[2]=-290;

      clr_res(&buffer_out);
      return (!motion) | oorange;
}
