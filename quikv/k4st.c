/* k4 recorder st snap command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void k4st(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;
long ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ichold, i, count, tcoff;
      long sqn;
      char *ptr;
      struct k4st_cmd lcl;

      char *arg_next();

      void k4st_dis();

      void skd_run(), skd_par();      /* program scheduling utilities */

      ichold= -99;                    /* check vlaue holder */

      ip[0]=ip[1]=0;

      if (command->equal != '=') {            /* read module */
	k4st_req_q(ip);
	goto k4con;
      } 
      else if (command->argv[0]==NULL) goto parse;  /* simple equals */
      else if (command->argv[1]==NULL) /* special cases */
        if (*command->argv[0]=='?') {
          k4st_dis(command,ip);
          return;
         }

/* if we get this far it is a set-up command so parse it */

parse:
      ilast=0;                                      /* last argv examined */
      memcpy(&lcl,&shm_addr->k4st,sizeof(lcl));

      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=k4st_dec(&lcl,&count, ptr);
        if(ierr !=0 ) goto error;
      }

/* all parameters parsed okay, update common */

      ichold=shm_addr->check.k4rec.check;
      shm_addr->check.k4rec.check=0;

      memcpy(&shm_addr->k4st,&lcl,sizeof(lcl));
      shm_addr->k4_rec_state=lcl.record;
      
      /* get sequence count */

      k4st_reqs_q(ip);
      skd_run("ibcon",'w',ip);
      skd_par(ip);
      if(ip[2]<0) {
	cls_clr(ip[0]);
	ip[0]=ip[1]=0;
	return;
      }
      k4st_ress_q(ip,&sqn);
      if(ip[1]!=0) {
	cls_clr(ip[0]);
	ip[0]=ip[1]=0;
      }
      
/* format buffers for k4con if BW is 256 set time code off after 30 seconds */

      tcoff=shm_addr->equip.drive[0]==K4 &&
	(shm_addr->equip.drive_type[0]== K42 ||
	 shm_addr->equip.drive_type[0] == K42DMS)  &&
	shm_addr->k4rec_mode.bw==5;

      ip[0]=ip[1]=0;
      k4st_req_c(ip,&lcl,tcoff,sqn);

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

      k4st_dis(command,ip);
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"ks",2);
      return;
}
