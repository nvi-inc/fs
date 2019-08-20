/* satoff snap command */

#include <stdlib.h>
#include <math.h>
#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#define round(x) ((x)>=0?(int)((x)+0.5):(int)((x)-0.5))

void satoff(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;
int ip[5];                           /* ipc parameters */
{
      int ilast, ierr, count;
      char *ptr;
      struct satoff_cmd lcl;
      char buff[120];
      FILE *fd;
      int id, iret, i, it[6], idinyr;
      int seconds;
      float epoch;
      double azcmd,elcmd;

      int satoff_dec();                 /* parsing utilities */
      char *arg_next();

      void satoff_dis();

      void skd_run(), skd_par();      /* program scheduling utilities */

      ierr=0;

      if (command->equal != '=') {           /* display */
	satoff_dis(command,ip);
	return;
      } else if (command->argv[0]==NULL)
	goto parse;  /* simple equals */
      else if (command->argv[1]==NULL) {/* special cases */
        if (*command->argv[0]=='?') {
          satoff_dis(command,ip);
	  return;
	}
      }
/* if we get this far it is a set-up command so parse it */

parse:
      ilast=0;                                      /* last argv examined */

      memcpy(&lcl,&shm_addr->satoff,sizeof(lcl));
      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=satoff_dec(&lcl,&count, ptr);
        if(ierr !=0 ) goto error;
      }

/* all parameters parsed okay, update common */

      memcpy(&shm_addr->satoff,&lcl,sizeof(lcl));

      if(shm_addr->satellite.satellite != 1) {
	ierr=-304;
	goto error;
      } else {
	if(shm_addr->satellite.mode == 1 || shm_addr->satellite.mode == 2) {
	  int adder;
	  rte_time(it,it+5);
	  rte2secs(it,&seconds);
	  if(lcl.seconds >=0.0) {
	    adder=lcl.seconds*100+0.5;
	  } else {
	    adder=-(-lcl.seconds*100+.5);
	  }
	  seconds+=adder/100;
	  it[0]+=adder%100;
	  if (it[0] > 99) {
	    seconds++;
	    it[0]-=100;
	  } else if (it[0] < 0) {
	    seconds--;
	    it[0]+=100;
	  }
	  secs2rte(&seconds,it);
	  ierr=satpos(it,&azcmd,&elcmd);
	  if(ierr==-1) {
	    ierr=-301;
	    goto error;
	  }  else if (ierr==+1) {
	    ierr=-302;
	    goto error;
	  }
	  idinyr=365;
	  if(it[5]%400 == 0 || (it[5]%4 == 0 && it[5]%100 !=0))
	    idinyr=366;
	  epoch=it[5]+it[4]/(float)idinyr;
	}

	if(shm_addr->satellite.mode == 1) {
	  cnvrt(2,azcmd,elcmd, &shm_addr->ra50,&shm_addr->dec50,
		it,shm_addr->alat,shm_addr->wlong);
	  shm_addr->ep1950=epoch;
	  shm_addr->radat=shm_addr->ra50;
	  shm_addr->decdat=shm_addr->dec50;
	  shm_addr->epoch=shm_addr->ep1950;
	  ip[0]=1;
	  antcn(ip);
	  if(ip[2]!=0)
	    return;
	} else if(shm_addr->satellite.mode==2) {
	  shm_addr->ra50=azcmd;
	  shm_addr->dec50=elcmd;
	  shm_addr->ep1950=-1;
	  shm_addr->radat=azcmd;
	  shm_addr->decdat=elcmd;
	  shm_addr->epoch=epoch;
	  ip[0]=1;
	  antcn(ip);
	  if(ip[2]!=0)
	    return;
	} else if (shm_addr->satellite.mode==0) {
	  ip[0]=9;
	  antcn(ip);
	  if(ip[2]!=0)
	    return;
	} else {
	  ierr=-303;
	  goto error;
	}
      }

      ip[0]=ip[1]=ip[2]=0;

      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"q3",2);
      return;
}
