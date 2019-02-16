/* rec decode */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

void rec_brk(icherr,ierr,ip,indx,stat)
int icherr[];
int *ierr;
int ip[5];
int indx, stat;
{
  int i;
  void int2str(); 
  char feet[6];
  struct venable_cmd lcle;
  struct vst_cmd lcls;
  struct tape_cmd lclt;
  struct tape_mon lcltm;
  struct res_buf buffer;
  struct res_rec response;
  void get_res();
  int time;
  int kmove_time, kload_time, iend;

  opn_res(&buffer,ip);
  get_res(&response, &buffer); mc73tape(&lcltm, response.data);
  if(stat==0) {
    get_res(&response, &buffer); mc81venable(&lcle, response.data);
    get_res(&response, &buffer); mcb1vst(&lcls, response.data);
    get_res(&response, &buffer); mcb5vst(&lcls, response.data);
    get_res(&response, &buffer); mcb6tape(&lclt, response.data);
  }
  get_res(&response, &buffer); mc30tape(&lcltm, response.data);

  if(response.state == -1) {
     clr_res(&buffer);
     *ierr=-200;
     return;
  }

  clr_res(&buffer);

  feet[0]='\0';
  int2str(feet,lcltm.foot,-5,1); 
  memcpy(shm_addr->LFEET_FS[indx],feet,5);

  if ((lcltm.stat & 0x02)!=0)
     shm_addr->ICAPTP[indx] = 1; /* drive is moving */
  else
     shm_addr->ICAPTP[indx] = 0;

  if ((lcltm.stat & 0x40) == 0)
     shm_addr->IRDYTP[indx] = 1;  /* tape is not ready */
  else
     shm_addr->IRDYTP[indx] = 0;

  if(stat==1)
    return;

  iend=4;
  if(shm_addr->equip.drive[indx]==VLBA4||
     (shm_addr->equip.drive[indx]==VLBA&&
      shm_addr->equip.drive_type[indx]==VLBAB))
    iend=8;
  if (shm_addr->check.vkenable[indx]) {
    if (shm_addr->venable[indx].general==1) {
      for (i=0;i<iend;i++) {
	if (lcle.group[i]!=shm_addr->venable[indx].group[i])
	  icherr[0]=1;
      }
    } else {
      for (i=0;i<iend;i++) {
	if (lcle.group[i]!=0)
	  icherr[0]=1;
      }
    }
  }

  rte_rawt(&time);
  kmove_time = shm_addr->check.rc_mv_tm[indx]+1000 < time;
  if (shm_addr->check.vkmove[indx] && kmove_time) {
      if (shm_addr->cips[indx] !=lcls.cips)
        icherr[2]=1;
      if(shm_addr->cips[indx] != 0) {
        if (shm_addr->ICAPTP[indx] ==0)
           icherr[1]=1;
        if (shm_addr->idirtp[indx] != lcls.dir)
           icherr[3]=1;
      } else {
        if (shm_addr->ICAPTP[indx] == 1)
           icherr[4]=1;
      }
  }

/* tape ready does not seem to be reliable for RECON 4

  kload_time = shm_addr->check.rc_ld_tm[indx]+1000 < time;
  if ((shm_addr->check.vkmove[indx] && kmove_time) ||
      (shm_addr->check.vkload[indx] && kload_time) ) {
      if(shm_addr->IRDYTP[indx] == 1 && shm_addr->KHALT==0 &&
          memcmp(shm_addr->LSKD,"none    ",8)!=0)
           icherr[5]=1;
  }

*/

  if (shm_addr->check.vkenable[indx] && shm_addr->check.vkmove[indx]) {
    if (shm_addr->venable[indx].general==1 &&  shm_addr->cips[indx] != 0) {
      icherr[7]=1;
      iend=4;
      if(shm_addr->equip.drive[indx]==VLBA4||
	 (shm_addr->equip.drive[indx]==VLBA&&
	  shm_addr->equip.drive_type[indx]==VLBAB))
	iend=8;
      for (i=0;i<iend;i++) {
	if (lcle.group[i]!=0)
	  icherr[7]=0;
      }
    }
  }

  if (shm_addr->check.vklowtape[indx])
     if (lclt.set!=shm_addr->lowtp[indx])
        icherr[6]=1;

  return;

}
