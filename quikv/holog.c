/* holog snap command */

#include <math.h>
#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void holog(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;
int ip[5];                           /* ipc parameters */
{
      int ilast, ierr, count;
      char *ptr;
      struct holog_cmd lcl;

      int holog_dec();                 /* parsing utilities */
      char *arg_next();

      void holog_dis();

      void skd_run(), skd_par();      /* program scheduling utilities */

      ierr=0;

      if (command->equal != '=') {           /* run holog */
	int set;
	if ( 1 == nsem_test("onoff") || 1 == nsem_test("fivpt") ||
	     1 == nsem_test("holog") ) {
	  ierr=-301;
	  goto error;
	}
	set=shm_addr->holog.proc[0]!=0;
	if(!set) {
	  ierr=-302;
	  goto error;
	}

	shm_addr->holog.setup=1;	
	shm_addr->holog.stop_request=0;
	skd_run("holog",'n',ip);
	ip[0]=ip[1]=ip[2]=0;
	return;
      } else if (command->argv[0]==NULL)
	goto parse;  /* simple equals */
      else if (command->argv[1]==NULL) {/* special cases */
        if (*command->argv[0]=='?') {
          holog_dis(command,ip);
	  return;
	} else if(0==strcmp(command->argv[0],"stop")){
	  shm_addr->holog.stop_request=1;
	  skd_run("holog",'w',ip);
	  ip[0]=ip[1]=ip[2]=0;
          return;
	}
      }
/* if we get this far it is a set-up command so parse it */

parse:
      ilast=0;                                      /* last argv examined */

      memcpy(&lcl,&shm_addr->holog,sizeof(lcl));
      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=holog_dec(&lcl,&count, ptr);
        if(ierr !=0 ) goto error;
      }

/* all parameters parsed okay, update common */

      memcpy(&shm_addr->holog,&lcl,sizeof(lcl));

      ip[0]=ip[1]=ip[2]=0;

      holog_dis(command,ip);
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"qh",2);
      return;
}
