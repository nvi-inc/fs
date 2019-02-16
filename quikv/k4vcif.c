/* k4 video converter lo snap command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void k4vcif(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;
int ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ichold, i, count, type, rack;
      char *ptr;
      struct k4vcif_cmd lcl;

      char *arg_next();

      void k4vcif_dis();

      void skd_run(), skd_par();      /* program scheduling utilities */

      ichold= -99;                    /* check vlaue holder */

      ip[0]=ip[1]=0;

      type=shm_addr->equip.rack_type;
      if( type!=K41 && type!=K41U) {
	ierr=-301;
	goto error;
      }

      if (command->equal != '=') {            /* read module */
	k4vcif_req_q(ip);
	goto k4con;
      } 
      else if (command->argv[0]==NULL) goto parse;  /* simple equals */
      else if (command->argv[1]==NULL) /* special cases */
        if (*command->argv[0]=='?') {
          k4vcif_dis(command,itask,ip);
          return;
         }

/* if we get this far it is a set-up command so parse it */

parse:
      ilast=0;                                      /* last argv examined */
      memcpy(&lcl,&shm_addr->k4vcif,sizeof(lcl));

      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=k4vcif_dec(&lcl,&count, ptr);
        if(ierr !=0 ) goto error;
      }

/* all parameters parsed okay, update common */

      ichold=shm_addr->check.k4rec.check;
      shm_addr->check.k4rec.check=0;

      memcpy(&shm_addr->k4vcif,&lcl,sizeof(lcl));
      
/* format buffers for k4con */

      k4vcif_req_c(ip,&lcl);

k4con:
      skd_run("ibcon",'w',ip);
      skd_par(ip);

      if (ichold != -99) {
	shm_addr->check.k4rec.state=TRUE;
	if (ichold >= 0)
	  ichold=ichold % 1000 + 1;
	shm_addr->check.k4rec.check=ichold;
      }

      if(ip[2]<0) {
	cls_clr(ip[0]);
	ip[0]=ip[1]=0;
	return;
      }

      k4vcif_dis(command,itask,ip);
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"ki",2);
      return;
}
