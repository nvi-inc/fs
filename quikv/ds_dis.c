/* ds SNAP command display */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include "../include/params.h"
#include "../include/fs_types.h"

/* function prototypes */
void cls_snd();				/* class buffer utilities */
int dscon_rcv();			/* DSCON interface utilities */
void ds_mon();

void ds_dis(command,itask,ip)
struct cmd_ds *command;
int itask;
int ip[5];
{
      int ierr, count, i;
      struct ds_mon lclm;
      char output[80];

      /* retrieve the response data */

      if ((ierr=dscon_rcv(&lclm,ip))) goto error;

      /* format output buffer */

      strcpy(output,command->name);
      strcat(output,"/");

      count=0;
      while ( count>=0 ) {
        if (count>0) strcat(output,",");
        count++;
        ds_mon(output,&count,&lclm);
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
      memcpy(ip+3,"ds",2);
      return;
}
