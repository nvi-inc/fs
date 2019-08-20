/* k4 vc bw display */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#define MAX_OUT 256

void k4vcbw_dis(command,itask,ip)
struct cmd_ds *command;
int itask;
int ip[5];
{
  struct k4vcbw_cmd lclc;
  int kcom, i, ierr, count;
  char output[MAX_OUT];

  kcom= command->argv[0] != NULL &&
    *command->argv[0] == '?' && command->argv[1] == NULL;

  if ((!kcom) && command->equal == '=') {
    if(ip[0]!=0) {
      cls_clr(ip[0]);
      ip[0]=0;
    }
    ip[1]=0;
    return;
  } else if (kcom){
    memcpy(&lclc,&shm_addr->k4vcbw,sizeof(lclc));
  } else {
    k4vcbw_res_q(&lclc,ip,itask);
    if(ip[1]!=0) {
      cls_clr(ip[0]);
      ip[0]=ip[1]=0;
    }
    if(ip[2]!=0) {
      ierr=ip[2];
      goto error;
    }
  }

   /* format output buffer */

  strcpy(output,command->name);
  strcat(output,"/");

  count=0;
  while( count>= 0) {
    if (count > 0) strcat(output,",");
    count++;
    k4vcbw_enc(output,&count,&lclc,itask);
  }
  if(strlen(output)>0) output[strlen(output)-1]='\0';
  
  for (i=0;i<5;i++) ip[i]=0;
  cls_snd(&ip[0],output,strlen(output),0,0);
  ip[1]=1;

  return;
  
 error:
  ip[0]=0;
  ip[1]=0;
  ip[2]=ierr;
  memcpy(ip+3,"ki",2);
  return;
}

