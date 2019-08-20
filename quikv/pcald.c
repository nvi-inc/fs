/* pcald snap command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>


#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void pcald(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;
int ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ichold, i, count;
      int verr;
      char *ptr;
      struct pcald_cmd lcl;

      int pcald_dec();                 /* parsing utilities */
      char *arg_next();

      void pcald_dis();

      void skd_run(), skd_par();      /* program scheduling utilities */

      if (command->equal != '=') {           /* run pcald */
	  shm_addr->pcald.stop_request=0;
	  skd_run("pcald",'w',ip);
	  ip[0]=ip[1]=ip[2]=0;
	  return;
      } else if (command->argv[0]==NULL)
	goto parse;  /* simple equals */
      else if (command->argv[1]==NULL) {/* special cases */
        if (*command->argv[0]=='?') {
          pcald_dis(command,ip);
	  return;
	} else if(0==strcmp(command->argv[0],"stop")){
	  shm_addr->pcald.stop_request=1;
	  skd_run("pcald",'w',ip);
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

      memcpy(&lcl,&shm_addr->pcald,sizeof(lcl));
      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=pcald_dec(&lcl,&count, ptr);
        if(ierr !=0 ) goto error;
      }

/* all parameters parsed okay, update common */

      memcpy(&shm_addr->pcald,&lcl,sizeof(lcl));

      ip[0]=ip[1]=ip[2]=0;

      pcald_dis(command,ip);
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"pd",2);
      return;
}
