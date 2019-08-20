/* move vlba2 head stack */

#include <sys/types.h>
#include <sys/times.h>
#include <string.h>
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

void v2_vlt_head(ihead,volt,ip,indxtp)
int ihead;                     /* head 1-4 */
float *volt;                   /* voltage of head */
int ip[5];                    /* ipc array */
int indxtp;
{
      struct req_buf buffer;           /* request buffer */
      struct req_rec request;          /* reqeust record */
      struct res_buf buffer_out;       /* response buffer */
      struct res_rec response;         /* respones record */
      struct tms tms_buff;
      int motion, time_out, ivolt;
      int end;
      int indx;

      if(indxtp == 1) {
	indx=0;
      } else if(indxtp == 2) {
	indx=1;
      } else {
	ip[2]=-505;
	memcpy("q<",ip+4,2);
	return;
      }

      ini_req(&buffer);                /* initialize */
      if(indx == 0)
	memcpy(request.device,"r1",2);
      else 
	memcpy(request.device,"r2",2);

      request.type=0;
      request.addr=0xC3; request.data=ihead & 0x3;   /* head */
      add_req(&buffer, &request);

      request.type=1;

      request.addr=0x73;
      add_req(&buffer, &request);

      request.addr=0x74;
      add_req(&buffer, &request);

      request.addr=0x42;
      add_req(&buffer, &request);

      end_req(ip,&buffer);                  /* send buffer and schedule */
      skd_run("mcbcn",'w',ip);
      skd_par(ip);
      if(ip[2] <0) return;

      opn_res(&buffer_out,ip);              /* decode response */
      get_res(&response, &buffer_out);
      get_res(&response, &buffer_out);
      motion=(0x4&response.data) != 0;     /* still moving */

      get_res(&response, &buffer_out);

      time_out = ((1 << 9) & response.data) != 0;

      get_res(&response, &buffer_out);
      ivolt=response.data;
      if (ivolt > 0 && 0x8000 & ivolt )
	ivolt |= ~0xffff;
      *volt=ivolt;

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




