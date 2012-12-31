/* tpicd snap command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>


#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void tpicd(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;
long ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ichold, i, count;
      int verr;
      char *ptr;
      struct tpicd_cmd lcl;

      int tpicd_dec();                 /* parsing utilities */
      char *arg_next();

      void tpicd_dis();

      void skd_run(), skd_par();      /* program scheduling utilities */

      if (command->equal != '=') {           /* run pcald */
	  for(i=0;i<MAX_DET;i++)
	    if(0!=shm_addr->tpicd.itpis[i])
	      goto Start;
	  ierr=-302;
	  goto error;
      Start:
	  shm_addr->tpicd.stop_request=0;
	  shm_addr->tpicd.tsys_request=0;
	  skd_run("tpicd",'w',ip);
	  ip[0]=ip[1]=ip[2]=0;
	  return;
      } else if (command->argv[0]==NULL) {
	goto parse;  /* simple equals */
      } else if (command->argv[1]==NULL) {/* special cases */
        if (*command->argv[0]=='?') {
          tpicd_dis(command,ip);
	  return;
	} else if(0==strcmp(command->argv[0],"stop")){
	  shm_addr->tpicd.stop_request=1;
	  skd_run("tpicd",'w',ip);
	  ip[0]=ip[1]=ip[2]=0;
          return;
	} else if(0==strcmp(command->argv[0],"tsys")){
	  if(0==shm_addr->dbbc_cont_cal.mode) {
	    ierr=-301;
	    goto error;
	  }
	  for(i=0;i<MAX_DET;i++)
	    if(0!=shm_addr->tpicd.itpis[i])
	      goto Tsys;
	  ierr=-302;
	  goto error;
	Tsys:
	  shm_addr->tpicd.tsys_request=1;
	  skd_run("tpicd",'w',ip);
	  ip[0]=ip[1]=ip[2]=0;
          return;
	} else if(0==strcmp(command->argv[0],"display_on")) {
	  int val;
	  memcpy(&val,"pn",2);
	  cls_snd(&shm_addr->iclbox,0,0,0,val);
	  ip[0]=ip[1]=ip[2]=0;
	  return;
	} else if(0==strcmp(command->argv[0],"display_off")) {
	  int val;
	  memcpy(&val,"pf",2);
	  cls_snd(&shm_addr->iclbox,0,0,0,val);
	  ip[0]=ip[1]=ip[2]=0;
	  return;
	}
      }
/* if we get this far it is a set-up command so parse it */

parse:
      ilast=0;                                      /* last argv examined */

      memcpy(&lcl,&shm_addr->tpicd,sizeof(lcl));
      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=tpicd_dec(&lcl,&count, ptr);
        if(ierr !=0 ) goto error;
      }

/* all parameters parsed okay, update common */

      memcpy(&shm_addr->tpicd,&lcl,sizeof(lcl));

      ip[0]=ip[1]=ip[2]=0;

      tpicd_dis(command,ip);
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"tc",2);
      return;
}
