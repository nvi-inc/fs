/* end tape movement for vlba recorder */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void et_v(ip)
long ip[5];
{
      struct req_buf buffer;
      struct req_rec request;
      struct vst_cmd lcl;
      int ichold;

      ichold = -99;

      ini_req(&buffer);                      /* format the buffer */
      memcpy(request.device,"rc",2);
      request.type=0;
      request.addr=0xb0; request.data=0x01  ; add_req(&buffer,&request);
      lcl.cips=0;
      request.addr=0xb5; 
      vstb5mc(&request.data,&lcl); add_req(&buffer,&request);

/* update common */
      
      ichold=shm_addr->check.rec;
      shm_addr->check.rec=0;

      shm_addr->ispeed=-3;
      shm_addr->cips=0;
      shm_addr->idirtp = -1;

      end_req(ip,&buffer);                /* send buffer and schedule */
      skd_run("mcbcn",'w',ip);
      skd_par(ip);

      if (ichold != -99) {
        shm_addr->check.vkmove = TRUE;
        rte_rawt(&shm_addr->check.rc_mv_tm);
        if (ichold >= 0)
           ichold=ichold % 1000 + 1;
        shm_addr->check.rec=ichold;
      }

      return;
}
