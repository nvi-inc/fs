/* turn off lvdt for vlba recorder */

#include <string.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

void lvdofn_v(ip,indxtp)
long ip[5];
int indxtp;
{
      struct req_buf buffer;
      struct req_rec request;
      struct res_buf buffer_out;
      struct res_rec response;
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

      if(shm_addr->reccpu[indx]==162) {
	ip[0]=ip[1]=ip[2]=0;
	return;
      }
      shm_addr->klvdt_fs[indx]=0;
      ini_req(&buffer);                      /* format the buffer */
      if(indx == 0)
	memcpy(request.device,"r1",2);
      else 
	memcpy(request.device,"r2",2);
      request.type=0;
      request.addr=0xE0; request.data=0xB0  ; add_req(&buffer,&request);
      request.addr=0xE1; request.data=0x12  ; add_req(&buffer,&request);

                                             /* or bit ON to turn off LVDT */
      request.addr=0xE3; request.data=0x0100; add_req(&buffer,&request);

      end_req(ip,&buffer);                /* send buffer and schedule */
      skd_run("mcbcn",'w',ip);
      skd_par(ip);
      if(ip[2] <0) return;

      opn_res(&buffer_out,ip);            /* check for correct # of reponses */
      get_res(&response, &buffer_out);
      get_res(&response, &buffer_out);
      get_res(&response, &buffer_out);
      if(response.state == -1) {
        clr_res(&buffer_out);
        ip[0]=ip[1]=0;
        ip[2]=-286;
        memcpy(ip+3,"q@",2);
        ip[4]=0;
        return;
      }

       clr_res(&buffer_out);
       ip[0]=ip[1]=ip[2]=0;
       return;
}



