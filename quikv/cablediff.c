/* cablediff snap command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>
#include <math.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#define MAX_OUT 256

void cablediff(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;
int ip[5];                           /* ipc parameters */
{
      int ierr, i;
      char output[MAX_OUT],*start, csign;
      float diff;
      unsigned int ldiff;

      if (command->equal == '=') {
	ierr=-100;
	goto error;
      }

      strcpy(output,command->name);
      strcat(output,"/");

      for (i=0;i<5;i++) ip[i]=0;

      diff=shm_addr->cablevl-shm_addr->cablev;
      csign=diff>0.0?'+':'-';
      if(fabs(diff) < 0.5e-7) {
	snprintf(output+strlen(output),sizeof(output)-strlen(output)-1,
		 "0.0e-6,0");
      } else if(fabs(diff)>=1.0) {
        snprintf(output+strlen(output),sizeof(output)-strlen(output)-1,
                 "%e,%c",fabs(diff),csign);
      } else {
	ldiff=fabs(diff)*1e7+0.5;
	snprintf(output+strlen(output),sizeof(output)-strlen(output)-1,
		 "%d.%de-6,%c",ldiff/10,abs(ldiff)%10,csign);
      }

      cls_snd(&ip[0],output,strlen(output),0,0);
      ip[1]++;
      
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"wc",2);
      return;
}
