/* k4 recorder rec display */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#include "../include/k4rec_ds.h"

#define MAX_OUT 256

void k4rec_dis(command,ip)
struct cmd_ds *command;
long ip[5];
{
  int data[3];
  int i, ierr, count;
  char output[MAX_OUT];
  struct k4rec_mon lclm;

  if (command->equal == '=') {
    if(ip[0]!=0) {
      cls_clr(ip[0]);
      ip[0]=0;
    }
    ip[1]=0;
    return;
  } else {
    k4rec_res_q(&lclm,ip);
    if(ip[1]!=0) {
      cls_clr(ip[0]);
      ip[0]=ip[1]=0;
    }
    strncpy(shm_addr->k4tape_sqn,lclm.pos,sizeof(shm_addr->k4tape_sqn));
  }

   /* format output buffer */

  strcpy(output,command->name);
  strcat(output,"/");

  for (i=0;i<5;i++)
    ip[i]=0;

  count=0;
  while( count>= 0) {
    if (count != 0)
      strcat(output,",");
    count++;
    k4rec_mon(output,&count,&lclm);
  }
  if(strlen(output)>0) output[strlen(output)-1]='\0';
  
  cls_snd(&ip[0],output,strlen(output),0,0);
  ip[1]++;
  
  return;
  
 error:
  ip[0]=0;
  ip[1]=0;
  ip[2]=ierr;
  memcpy(ip+3,"kr",2);
  return;
}

