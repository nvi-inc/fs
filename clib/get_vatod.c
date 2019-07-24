/* get a/d channels for VLBA narrow track heads */
/* channels are choosen to be synonymous with Mark III */

#include <sys/types.h>
#include <sys/times.h>
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

static int rel_addr[ ]={0x51,0x54,0x52,0x55,0x57,0x53,0x56,0x58};
    /* rel_addr gives the VLBA monitor point for the equiv. M3 channel */
    /* except for channel 1 and 2 with the LVDT on, this requires active */
    /*     measurement */

void get_vatod(ichan,volts,ip)
int ichan;                           /* M3 style channel number */
float *volts;                        /* pointer to store result */
long ip[5];                          /* ipc array */
{
      struct req_buf buffer;
      struct req_rec request;
      struct res_buf buffer_out;
      struct res_rec response;
      int counts;
      struct tms tms_buff;
      long end;

      if(ichan<1 || ichan >(sizeof(rel_addr)/sizeof(int))) {
          ip[0]=ip[1]=0;
          ip[2]=-283;
          memcpy(ip+3,"q@",2);
          ip[4]=0;
          return;
      }

      ini_req(&buffer);                      /* format the buffer */
      memcpy(request.device,DEV_VRC,2);
      request.type=1; 

      if(shm_addr->klvdt_fs && (ichan == 1 || ichan ==2)) {
        lvdonn_v(1,ip);
        if(ip[2]<0) return;
        rte_sleep( 5);
      } 

      request.addr=rel_addr[ichan-1];
      add_req(&buffer,&request);

      end_req(ip,&buffer);                  /* send buffer and schedule */
      skd_run("mcbcn",'w',ip);
      skd_par(ip);
      if(ip[2] <0) return;

      opn_res(&buffer_out,ip);              /* decode response */
      get_res(&response, &buffer_out);
      counts=0xFFF & response.data;
      if((counts & 0x800)!=0) counts|=~0xFFF;   /*sign extend */
      *volts=counts*4.8828125e-3;

      ip[0]=ip[1]=ip[4]=ip[2]=0;
      memcpy(ip+3,"q@",2);

      if(response.state == -1) {
        clr_res(&buffer_out);
        ip[2]=-284;
        return;
      } 

       clr_res(&buffer_out);
       return;
}
