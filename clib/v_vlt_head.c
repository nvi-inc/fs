/* move vlba2 head stack */

#include <sys/types.h>
#include <sys/times.h>
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

void v_vlt_head__(ihead,volt,ip)
int *ihead;                     /* head 1-4 */
float *volt;                   /* voltage of head */
long ip[5];                    /* ipc array */
{
      struct req_buf buffer;           /* request buffer */
      struct req_rec request;          /* reqeust record */
      struct res_buf buffer_out;       /* response buffer */
      struct res_rec response;         /* respones record */
      struct tms tms_buff;
      int motion, time_out, counts;
      long end;

      ini_req(&buffer);                /* initialize */
      memcpy(request.device,DEV_VRC,2);

      request.type=0;
      request.addr=0xC3; request.data=*ihead & 0x3;   /* head */
      add_req(&buffer, &request);

      request.addr=0xCE; request.data=1;   /* read position */
      add_req(&buffer, &request);

      request.type=1;

      request.addr=0x73;
      add_req(&buffer, &request);

      request.addr=0x74;
      add_req(&buffer, &request);

      request.addr=0x43;
      add_req(&buffer, &request);

      end_req(ip,&buffer);                  /* send buffer and schedule */
      skd_run("mcbcn",'w',ip);
      skd_par(ip);
      if(ip[2] <0) return;

      opn_res(&buffer_out,ip);              /* decode response */
      get_res(&response, &buffer_out);
      get_res(&response, &buffer_out);
      get_res(&response, &buffer_out);
      motion=(0x4&response.data) != 0;     /* still moving */

      get_res(&response, &buffer_out);

      time_out = ((1 << 9) & response.data) != 0;

      get_res(&response, &buffer_out);
      counts=0xFFFF & response.data;
      if((counts & 0x8000)!=0) counts|=~0xFFFF;   /*sign extend */
      *volt=counts*1e-3;

      ip[0]=ip[1]=ip[4]=ip[2]=0;
      memcpy(ip+3,"q@",2);

      if(response.state == -1) {
        clr_res(&buffer_out);
        ip[2]=-293;
      } else if (motion)
        ip[2]=-288;
      else if (time_out)
        ip[2]=-290;

       clr_res(&buffer_out);

       return;
}




