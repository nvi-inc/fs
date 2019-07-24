/* tape movement for vlba recorder */

#include <stdio.h> 
#include <string.h> 
#include <limits.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/macro.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void rwff_v(ip,isub)
long ip[5];
int *isub;
{
      int first;

      struct req_buf buffer;
      struct req_rec request;
      struct venable_cmd lcl;
 
      void venable81mc();

      ini_req(&buffer);                      /* format the buffer */
      memcpy(request.device,"rc",2);

      request.type=0;
      memcpy(&lcl,&shm_addr->venable,sizeof(lcl));
      lcl.general=0;                  /* turn off record */
      venable81mc(&request.data,&lcl);
      request.addr=0x81;
      add_req(&buffer,&request);
      memcpy(&shm_addr->venable,&lcl,sizeof(lcl));

      request.addr=0xb6;  /* enable low tape */
      shm_addr->lowtp=1;
      request.data=0x01; 
      add_req(&buffer,&request);
 
      switch (*isub) {
        case 3:            /* rw */
          request.addr=0xb5; 
          request.data=bits16on(16) & (shm_addr->iskdtpsd*100);
          add_req(&buffer,&request);
          request.addr=0xb1; request.data=0x00; 
          add_req(&buffer,&request);
          break;
        case 4:            /* ff */
          request.addr=0xb5; 
          request.data=bits16on(16) & (shm_addr->iskdtpsd*100);
          add_req(&buffer,&request);
          request.addr=0xb1; request.data=0x01; 
          add_req(&buffer,&request);
          break;
        case 5:            /* srw */
          request.addr=0xb5; 
          request.data=bits16on(16) & (shm_addr->imaxtpsd*100);
          add_req(&buffer,&request);
          request.addr=0xb1; request.data=0x00; 
          add_req(&buffer,&request);
          break;
        case 6:            /* sff */
          request.addr=0xb5; 
          request.data=bits16on(16) & (shm_addr->imaxtpsd*100);
          add_req(&buffer,&request);
          request.addr=0xb1; request.data=0x01; 
          add_req(&buffer,&request);
          break;
        default:
          return;
          break;
      }

      end_req(ip,&buffer);                /* send buffer and schedule */
      skd_run("mcbcn",'w',ip);
      skd_par(ip);
      return;
}
