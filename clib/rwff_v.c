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

void rwff_v(ip,isub,ierr)
long ip[5];
int *isub;
int *ierr;
{
      int first;
      int lerr;
      int verr;
      int ichold;
      int vacuum();

      int i;

      struct req_buf buffer;
      struct req_rec request;
      struct venable_cmd lcl;
 
      void venable81mc();

      *ierr = 0;
      lerr = 0;
      verr = vacuum(&lerr);
      if (verr<0) { 
        /* vacuum not ready or other error trying to read recorder */
        if (verr==-1) *ierr = -301;
        if (verr==-2) *ierr = -302;
        return;
      }
      else if (lerr!=0) { 
        *ierr=-303;
        return;
      }

      if(shm_addr->equip.rack == MK4 || shm_addr->equip.rack == VLBA4  ||
	 shm_addr->equip.rack == K4MK4) {
	setMK4FMrec(0,ip);
	if(ip[2]<0)
	  return;
      }

      ichold= -99;                    /* check vlaue holder */

      ini_req(&buffer);                      /* format the buffer */
      memcpy(request.device,"rc",2);

      request.type=0;
      memcpy(&lcl,&shm_addr->venable,sizeof(lcl));
      lcl.general=0;                  /* turn off record */
      shm_addr->venable.general=0;
      venable81mc(&request.data,&lcl);
      request.addr=0x81;
      add_req(&buffer,&request);

      request.addr=0xb6;  /* enable low tape */
      shm_addr->lowtp=1;
      request.data=0x01; 
      add_req(&buffer,&request);
 
      ichold=shm_addr->check.rec;
      shm_addr->check.rec=0;
      
      switch (*isub) {
        case 3:            /* rw */
          request.addr=0xb5; 
          if (shm_addr->iskdtpsd == -2) {
            request.data=bits16on(16) & (int)(360*100.0);
          } else if (shm_addr->iskdtpsd == -1) {
            request.data=bits16on(16) & (int)(330*100.0);
          } else {
            request.data=bits16on(16) & (int)(270*100.0);
          }
          shm_addr->ispeed=-3;
	  shm_addr->cips=request.data;
          add_req(&buffer,&request);
          request.addr=0xb1; request.data=0x00; 
          add_req(&buffer,&request);
          shm_addr->idirtp=0;
          break;
        case 4:            /* ff */
          request.addr=0xb5; 
          if (shm_addr->iskdtpsd == -2) {
            request.data=bits16on(16) & (int)(360*100.0);
          } else if (shm_addr->iskdtpsd == -1) {
            request.data=bits16on(16) & (int)(330*100.0);
          } else {
            request.data=bits16on(16) & (int)(270*100.0);
          }
          shm_addr->ispeed=-3;
	  shm_addr->cips=request.data;
          add_req(&buffer,&request);
          request.addr=0xb1; request.data=0x01; 
          add_req(&buffer,&request);
          shm_addr->idirtp=1;
          break;
        case 5:            /* srw */
          request.addr=0xb5; 
          if (shm_addr->imaxtpsd == -2) {
            request.data=bits16on(16) & (int)(360*100.0);
          } else if (shm_addr->imaxtpsd == -1) {
            request.data=bits16on(16) & (int)(330*100.0);
          } else {
            request.data=bits16on(16) & (int)(270*100.0);
          }
          shm_addr->ispeed=-3;
	  shm_addr->cips=request.data;
          add_req(&buffer,&request);
          request.addr=0xb1; request.data=0x00; 
          add_req(&buffer,&request);
          shm_addr->idirtp=0;
          break;
        case 6:            /* sff */
          request.addr=0xb5; 
          if (shm_addr->imaxtpsd == -2) {
            request.data=bits16on(16) & (int)(360*100.0);
          } else if (shm_addr->imaxtpsd == -1) {
            request.data=bits16on(16) & (int)(330*100.0);
          } else {
            request.data=bits16on(16) & (int)(270*100.0);
          }
          shm_addr->ispeed=-3;
	  shm_addr->cips=request.data;
          add_req(&buffer,&request);
          request.addr=0xb1; request.data=0x01; 
          add_req(&buffer,&request);
          shm_addr->idirtp=1;
          break;
        default:
          return;
          break;
      }

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
