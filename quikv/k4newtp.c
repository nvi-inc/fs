/* K4 NEWTAPE SNAP command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#define MAX_BUF 257

void k4newtp(command,itask,ip)
struct cmd_ds *command;           /* parsed command structure */
int itask;
int ip[5];                       /* ipc parameters */
{
      int i, ireq, itape;
      char *arg_next(), *tpnum, tape[10];
      char cmd[MAX_BUF], output[MAX_BUF];
      char *ptr, *lptr[2], lab[10];
      int ierr, max;
      void skd_run(), skd_par();  /* program scheduling utilities */
      struct k4label_cmd lcl;

      if(shm_addr->equip.drive[0]!=0 && shm_addr->equip.drive[1]!=0)
	if(shm_addr->knewtape[0]!=0) {
	  shm_addr->knewtape[0]=0;
	  ip[0]=ip[1]=0;
	  return;
	}
      
      if(command->equal != '=' ||
	 (shm_addr->equip.drive[0]==K4 &&
	  (shm_addr->equip.drive_type[0]==K41 ||
	   shm_addr->equip.drive_type[0]==K42))) {
	strcpy(output,command->name);
	if(shm_addr->equip.drive[0]!=0 && shm_addr->equip.drive[1]!=0) {
	  if(shm_addr->select==0) {
	    strcat(output,"/to continue, use LABEL1 command");
	  }
	} else
	  strcat(output,"/to continue, use LABEL  command");
        shm_addr->KHALT=1;
	ip[0]=0;
	cls_snd(&ip[0],output,strlen(output),0,0);
	ip[1]=1;
        return;
      }

/* else have a DMS */

      i=0;
      itape=0;
      tpnum=command->argv[0];

      if(tpnum!=NULL)
	while(*tpnum != '\0'){
	  tape[i] = *tpnum;
	  itape = itape*10 + (*tpnum - '0');
	  i++; tpnum++;
	}
      tape[i] = '\0';

/* check label of a tape */

      if(itape>=1 && itape<=8)
        strcpy(cmd,"ucb?");
      else if(itape>=9 && itape<=16)
        strcpy(cmd,"mcb?");
      else
        strcpy(cmd,"lcb?");

      for (i=0;i<5;i++) ip[i]=0;

      ib_req7(ip,"t1",200,cmd);

      skd_run("ibcon",'w',ip);
      skd_par(ip);
      if(ip[2]<0) goto error2;

      strcpy(output,command->name);
      strcat(output,"/");
      max=sizeof(output)-strlen(output)-1;
      if(max>0) 
        ib_res_ascii(output+strlen(output),&max,ip);

      if(itape < 10) {
	strcpy(cmd,"0");
	strcat(cmd,tape);
      } else {
	strcpy(cmd,tape);
      }
      strcat(cmd,"C");
      ptr=strstr(output,cmd);
      i=0;
      while(i<2){
        if(*ptr == ','){
	  lptr[i]=ptr+1;
          i++;  
	}
	ptr++;
      }
      if(*lptr[0] == '0') {
	strcpy(output,command->name);
	strcat(output,"/No tape you requested. Select another one.");
        shm_addr->KHALT=1;
	ip[0]=0;
	cls_snd(&ip[0],output,strlen(output),0,0);
	ip[1]=1;
        return;
      }
      i=0;
      while(*lptr[1] != '\0' && *lptr[1] != ';') {
        lab[i]=*lptr[1];
        i++; lptr[1]++;
      }
      lab[i]='\0';

/*
   store tape label into the shared memory,
   and issue the time-stamp
*/

      strcpy(lcl.label,lab);
      memcpy(&shm_addr->k4label,&lcl,sizeof(lcl));
      strcpy(output,command->name);
      if(shm_addr->equip.drive[0]!=0 && shm_addr->equip.drive[1]!=0) {
	if(shm_addr->select==0) {
	strcat(output,"/LABEL1=");
	}
      } else
	strcat(output,"/LABEL=");
      strcat(output,lab);

/* allow schedule to continue */

      shm_addr->KHALT=0;

/* execute 'MOVE' command */

      strcpy(cmd,"move=");
      if(itape < 10) strcat(cmd,"0");
      strcat(cmd,tape);
      strcat(cmd,"c,dr1");

      for (i=0;i<5;i++) ip[i]=0;

      ib_req2(ip,"t1",cmd);

      skd_run("ibcon",'w',ip);
      skd_par(ip);

      if(ip[2]<0) goto error2;

      for (i=0;i<5;i++) ip[i]=0;
      cls_snd(&ip[0],output,strlen(output),0,0);
      ip[1]=1;
      return;

error1:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"kn",2);
      return;

error2:
      cls_clr(ip[0]);
      ip[0]=ip[1]=0;
      return;
}

















