/* rec decode */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

void rec_brk(icherr,ierr,ip)
int icherr[];
int *ierr;
long ip[5];
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
  long time;
  int kmove_time;

  opn_res(&buffer,ip);
  get_res(&response, &buffer); mc81venable(&lcle, response.data);
  get_res(&response, &buffer); mc73tape(&lcltm, response.data);
  get_res(&response, &buffer); mcb1vst(&lcls, response.data);
  get_res(&response, &buffer); mcb5vst(&lcls, response.data);
  get_res(&response, &buffer); mcb6tape(&lclt, response.data);
  get_res(&response, &buffer); mc30tape(&lcltm, response.data);
  if(response.state == -1) {
     clr_res(&buffer);
     *ierr=-201;
     return;
  }

  clr_res(&buffer);

  feet[0]='\0';
  int2str(feet,lcltm.foot,-5,1); 
  memcpy(shm_addr->LFEET_FS,feet,5);

  if ((lcltm.stat & 0x02)!=0)
     shm_addr->ICAPTP = 1; /* drive is moving */
  else
     shm_addr->ICAPTP = 0;

  if ((lcltm.stat & 0x40) == 0)
     shm_addr->IRDYTP = 1;  /* tape is ready */
  else
     shm_addr->IRDYTP = 0;

  if (shm_addr->check.vkenable) {
     if (shm_addr->venable.general==1) {
         for (i=0;i<4;i++) {
           if (lcle.group[i]!=shm_addr->venable.group[i])
               icherr[0]=1;
         }
     } else {
         for (i=0;i<4;i++) {
           if (lcle.group[i]!=0)
               icherr[0]=1;
         }
     }
  }

  rte_rawt(&time);
  kmove_time = shm_addr->check.rc_mv_tm+1000 < time;
  if (shm_addr->check.vkmove && kmove_time) {
      if (shm_addr->ispeed !=lcls.speed)
        icherr[2]=1;
      if(shm_addr->ispeed != 0) {
        if (shm_addr->ICAPTP ==0)
           icherr[1]=1;
        if (shm_addr->idirtp != lcls.dir)
           icherr[3]=1;
      } else {
        if (shm_addr->ICAPTP == 1)
           icherr[4]=1;
      }
      if(shm_addr->IRDYTP == 1 && shm_addr->KHALT==0 &&
          memcmp(shm_addr->LSKD,"none    ",8)!=0)
           icherr[5]=1;
  }

  if (shm_addr->check.vkenable && shm_addr->check.vkmove) {
      if (shm_addr->venable.general==1 && shm_addr->ispeed != 0) {
         icherr[7]=1;
         for (i=0;i<4;i++) {
           if (lcle.group[i]!=0)
               icherr[7]=0;
         }
      }
  }

  if (shm_addr->check.vklowtape)
     if (lclt.set!=shm_addr->lowtp)
        icherr[6]=1;

  return;

}
