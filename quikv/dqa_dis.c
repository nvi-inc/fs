/* vlba dqa display */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#define MAX_OUT 256

void dqa_dis(command,itask,ip)
struct cmd_ds *command;
int itask;
long ip[5];
{
      struct dqa_cmd lclc;
      struct dqa_mon lclm;
      int ind,kcom,i,ich, ierr, count;
      unsigned iarray[ 36];
      struct res_buf buffer;
      struct res_rec response;
      void get_res();
      char output[MAX_OUT];
      float rate;
      int ivalue, ifm, qadrive;

      qadrive=shm_addr->vform.qa.drive;

      kcom= command->argv[0] != NULL &&
            *command->argv[0] == '?' && command->argv[1] == NULL;

      if ((!kcom) && command->equal == '=') {
         logmsg(output,command,ip);
         return;
      } else if(kcom)
         memcpy(&lclc,&shm_addr->dqa,sizeof(lclc));
      else {

/* command parameters are stored in memory for this command */

         memcpy(&lclc,&shm_addr->dqa,sizeof(lclc)); 
	 ivalue=shm_addr->vrepro[qadrive].track[0];
	 lclm.a.track=ivalue;
	 if(-1 < ivalue && ivalue <2)
	   ivalue=shm_addr->systracks[qadrive].track[ivalue];
	 else if (33 < ivalue && ivalue < 36 )
	   ivalue=shm_addr->systracks[qadrive].track[ivalue-32];
	 if(shm_addr->equip.rack==VLBA) {
	   if(ivalue < 2 || 33 < ivalue)
	     ifm=-1;
	   else if(ivalue%2==0)
	     ifm=15+ivalue/2;
	   else
	     ifm=(ivalue-3)/2;
	   if(ifm>=0)
	     lclm.a.bbc=shm_addr->vform.codes[ifm];
	   else
	     lclm.a.bbc=-1;
	 } else { /* MK4 or VLBA4 */ 
	   ivalue=ivalue-2;
	   if (0 <= ivalue && ivalue <= 63)
	     lclm.a.bbc=shm_addr->form4.codes[ivalue];
	   else
	     lclm.a.bbc=-1;
	 }

	 ivalue=shm_addr->vrepro[qadrive].track[1];
	 lclm.b.track=ivalue;
	 if(-1 < ivalue && ivalue < 2)
	   ivalue=shm_addr->systracks[qadrive].track[ivalue];
	 else if (33 < ivalue && ivalue < 36)
	   ivalue=shm_addr->systracks[qadrive].track[ivalue-32];
	 if(shm_addr->equip.rack==VLBA) {
	   if(ivalue < 2 || 33 < ivalue)
	     ifm=-1;
	   else if(ivalue%2==0)
	     ifm=15+ivalue/2;
	   else
	     ifm=(ivalue-3)/2;
	   if(ifm>=0)
	     lclm.b.bbc=shm_addr->vform.codes[ifm];
	   else
	     lclm.b.bbc=-1;
	 } else { /* MK4 or VLBA4 */ 
	   ivalue=ivalue-2;
	   if (0 <= ivalue && ivalue <= 63)
	     lclm.b.bbc=shm_addr->form4.codes[ivalue];
	   else
	     lclm.b.bbc=-1;
	 }

         opn_res(&buffer,ip);
         get_res(&response, &buffer);
         get_res(&response, &buffer);        /* fetch index set responses */
         get_res(&response, &buffer);
         for (i=0;i<36;i++) {                /* array contents */
	   get_res(&response, &buffer); iarray[ i]=response.data;
	 }
         mcCAdqa(&lclm,iarray);
         if(response.state == -1) {
	   clr_res(&buffer);
	   ierr=-401;
	   goto error;
         }
         clr_res(&buffer);
       }
      
      /* format output buffer */
      
      strcpy(output,command->name);
      strcat(output,"/");
      
      count=0;
      while( count>= 0) {
        if (count > 0) strcat(output,",");
        count++;
        dqa_enc(output,&count,&lclc);
      }

      rate=(1<<(0x7 & shm_addr->vform.rate))*250e3;     /* sample rate */
      if(!kcom) {
        count=0;
        while( count>= 0) {
        if (count > 0) strcat(output,",");
          count++;
          dqa_mon(output,&count,&lclm,lclc.dur,rate);
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
      memcpy(ip+3,"vq",2);
      return;
}
