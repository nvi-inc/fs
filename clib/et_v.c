/* end tape movement for vlba recorder */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void et_v(ip,indxtp)
int ip[5];
int indxtp;
{
      struct req_buf buffer;
      struct req_rec request;
      struct vst_cmd lcl;
      struct venable_cmd lclve;
      int ichold,indx;

      if(shm_addr->equip.rack == MK4 || shm_addr->equip.rack == VLBA4 ) {
	setMK4FMrec(0,ip);
	if(ip[2]<0)
	  return;
      }

      ichold = -99;

      ini_req(&buffer);                      /* format the buffer */
      if(indxtp == 1) {
	memcpy(request.device,"r1",2);
      } else if(indxtp == 2) {
	memcpy(request.device,"r2",2);
      } else {
	ip[2]=-505;
	memcpy("q<",ip+4,2);
	return;
      }
      indx=indxtp-1;
	
      request.type=0;
      memcpy(&lclve,&shm_addr->venable[indx],sizeof(lclve));
      lclve.general=0;                  /* turn off record */
      shm_addr->venable[indx].general=0;
      venable81mc(&request.data,&lclve);
      request.addr=0x81;
      add_req(&buffer,&request);

      request.type=0;
      request.addr=0xb0; request.data=0x01  ; add_req(&buffer,&request);
      lcl.cips=0;
      request.addr=0xb5; 
      vstb5mc(&request.data,&lcl); add_req(&buffer,&request);

/* update common */

      ichold=shm_addr->check.rec[indx];
      shm_addr->check.rec[indx]=0;
      shm_addr->ispeed[indx]=-3;
      shm_addr->cips[indx]=0;
      shm_addr->idirtp[indx] = -1;

      end_req(ip,&buffer);                /* send buffer and schedule */
      skd_run("mcbcn",'w',ip);
      skd_par(ip);

      if (ichold != -99) {
        shm_addr->check.vkmove[indx] = TRUE;
        rte_rawt(shm_addr->check.rc_mv_tm+indx);
        if (ichold >= 0)
           ichold=ichold % 1000 + 1;
        shm_addr->check.rec[indx]=ichold;
      } 

      return;
}
