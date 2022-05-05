/*
 * Copyright (c) 2020 NVI, Inc.
 *
 * This file is part of VLBI Field System
 * (see http://github.com/nvi-inc/fs).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
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
int ip[5];
int *isub;
int *ierr;
{
      int first;
      int lerr;
      int verr;
      int ichold;
      int vacuum();

      int i,indx;

      struct req_buf buffer;
      struct req_rec request;
      struct venable_cmd lcl;
 
      void venable81mc();

      if(*isub<10) 
	indx=0;
      else
	indx=1;

      *ierr = 0;
      lerr = 0;
      verr = vacuum(&lerr,indx);
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
      if(indx==0) 
	memcpy(request.device,"r1",2);
      else
	memcpy(request.device,"r2",2);

      request.type=0;
      memcpy(&lcl,&shm_addr->venable[indx],sizeof(lcl));
      lcl.general=0;                  /* turn off record */
      shm_addr->venable[indx].general=0;
      venable81mc(&request.data,&lcl);
      request.addr=0x81;
      add_req(&buffer,&request);

      request.addr=0xb6;  /* enable low tape */
      shm_addr->lowtp[indx]=1;
      request.data=0x01; 
      add_req(&buffer,&request);
 
      ichold=shm_addr->check.rec[indx];
      shm_addr->check.rec[indx]=0;
      
      switch (*isub%10) {
        case 3:            /* rw */
          request.addr=0xb5; 
          if (shm_addr->iskdtpsd[indx] == -2) {
            request.data=bits16on(16) & (int)(360*100.0);
          } else if (shm_addr->iskdtpsd[indx] == -1) {
            request.data=bits16on(16) & (int)(330*100.0);
          } else {
            request.data=bits16on(16) & (int)(270*100.0);
          }
          shm_addr->ispeed[indx]=-3;
	  shm_addr->cips[indx]=request.data;
          add_req(&buffer,&request);
          request.addr=0xb1; request.data=0x00; 
          add_req(&buffer,&request);
          shm_addr->idirtp[indx]=0;
          break;
        case 4:            /* ff */
          request.addr=0xb5; 
          if (shm_addr->iskdtpsd[indx] == -2) {
            request.data=bits16on(16) & (int)(360*100.0);
          } else if (shm_addr->iskdtpsd[indx] == -1) {
            request.data=bits16on(16) & (int)(330*100.0);
          } else {
            request.data=bits16on(16) & (int)(270*100.0);
          }
          shm_addr->ispeed[indx]=-3;
	  shm_addr->cips[indx]=request.data;
          add_req(&buffer,&request);
          request.addr=0xb1; request.data=0x01; 
          add_req(&buffer,&request);
          shm_addr->idirtp[indx]=1;
          break;
        case 5:            /* srw */
          request.addr=0xb5; 
          if (shm_addr->imaxtpsd[indx] == -2) {
            request.data=bits16on(16) & (int)(360*100.0);
          } else if (shm_addr->imaxtpsd[indx] == -1) {
            request.data=bits16on(16) & (int)(330*100.0);
          } else {
            request.data=bits16on(16) & (int)(270*100.0);
          }
          shm_addr->ispeed[indx]=-3;
	  shm_addr->cips[indx]=request.data;
          add_req(&buffer,&request);
          request.addr=0xb1; request.data=0x00; 
          add_req(&buffer,&request);
          shm_addr->idirtp[indx]=0;
          break;
        case 6:            /* sff */
          request.addr=0xb5; 
          if (shm_addr->imaxtpsd[indx] == -2) {
            request.data=bits16on(16) & (int)(360*100.0);
          } else if (shm_addr->imaxtpsd[indx] == -1) {
            request.data=bits16on(16) & (int)(330*100.0);
          } else {
            request.data=bits16on(16) & (int)(270*100.0);
          }
          shm_addr->ispeed[indx]=-3;
	  shm_addr->cips[indx]=request.data;
          add_req(&buffer,&request);
          request.addr=0xb1; request.data=0x01; 
          add_req(&buffer,&request);
          shm_addr->idirtp[indx]=1;
          break;
        default:
          return;
          break;
      }

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
