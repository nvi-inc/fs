/* move vlba2 head stack */

#include <sys/types.h>
#include <sys/times.h>
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

void v2_head_vmov(ihead,volt,ip)
int ihead;                     /* head 1-4 */
float volt;                    /* voltage to set head to */
long ip[5];                    /* ipc array */
{
      struct req_buf buffer;           /* request buffer */
      struct req_rec request;          /* reqeust record */
      struct res_buf buffer_out;       /* response buffer */
      struct res_rec response;         /* respones record */
      struct tms tms_buff;
      long end;

      ini_req(&buffer);                /* initialize */
      memcpy(request.device,DEV_VRC,2);

      request.type=1;         /* clear out-of-range bit before we start */
      request.addr=0x74;
      add_req(&buffer, &request);

      request.type=0;

      request.addr=0xC3; request.data=ihead & 0x3;   /* head */
      add_req(&buffer, &request);
                                                     /* motion */
      request.addr=0xC6; 
      if(volt >0)
        request.data=volt+.5;
      else if (volt <0)
        request.data=volt-.5;
      add_req(&buffer, &request);

      end_req(ip,&buffer);                  /* send buffer and schedule */
      skd_run("mcbcn",'w',ip);
      skd_par(ip);
      if(ip[2] <0) return;

      opn_res(&buffer_out,ip);              /* decode response */
      get_res(&response, &buffer_out);
      get_res(&response, &buffer_out);

      ip[0]=ip[1]=0;
      if(response.state == -1) {
        clr_res(&buffer_out);
        ip[2]=-294;
        memcpy(ip+3,"q@",2);
        ip[4]=0;
        return;
      }

       clr_res(&buffer_out);
       ip[2]=0;

       rte_sleep( 12); /*wait for vlba2 drive to set "moving" bit on */

       end=times(&tms_buff)+1502;  /* give it at most 15 seconds to complete*/
       while(end>times(&tms_buff) && !v2_motion_done(ip))
           rte_sleep(50);
       if(ip[2]<0) return;        /* error or still moving */

       return;                    /* okay */
}
