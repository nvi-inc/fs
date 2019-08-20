/* vsi4 display */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#define MAX_OUT 256
#define MAX_BUF 256

void vsi4_dis(command,itask,ip)
struct cmd_ds *command;
int itask;
int ip[5];
{
      struct vsi4_cmd lclc;
      struct vsi4_mon lclm;
      int ind,kcom,i,j,ich, ierr, count, nrec, nchar, idum, icount;
      int iclass;

      char output[MAX_OUT];
      char buff[MAX_BUF];

      ind=itask-1;

      kcom= command->argv[0] != NULL &&
            *command->argv[0] == '?' && command->argv[1] == NULL;

      if ((!kcom) && command->equal == '=') {
         logmatmsgfm(output,command,ip);
         return;
      } else if(kcom)
         memcpy(&lclc,&shm_addr->vsi4,sizeof(lclc));
      else {
	iclass=ip[0];
	nrec=ip[1];
	
	nchar=cls_rcv(iclass,buff,MAX_BUF,&idum,&idum,0,0);
	ma2vsi4(&lclc,&lclm,buff);
	cls_clr(iclass);
      }

   /* format output buffer */

      strcpy(output,command->name);
      strcat(output,"/");

      count=0;
      while( count>= 0) {
        if (count > 0) strcat(output,",");
        count++;
        vsi4_enc(output,&count,&lclc);
      }

      if(!kcom) {
        count=0;
        while( count>= 0) {
        if (count > 0) strcat(output,",");
          count++;
          vsi4_mon(output,&count,&lclm);
        }
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
      memcpy(ip+3,"v4",2);
      return;
}
