/* vsi4 snap command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void vsi4(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;                            /* sub-task, ifd number +1  */
long ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ichold, i, count, nrec;
      long iclass;
      short int buff[80];
      char *ptr;

      struct vsi4_cmd lcl;          /* local instance of vform command */

      int vsi4_dec();                 /* parsing utilities */
      char *arg_next();

      void vsi4_dis();
      void skd_run(), skd_par();      /* program scheduling utilities */

      ichold= -99;                    /* check vlaue holder */

      iclass=0;
      nrec=0;

      buff[0]=8;
      memcpy(buff+1,"5b",2);
      buff[2]=0;

      if (command->equal != '=') {            /* read module */

	buff[0]=-1;
	 cls_snd(&iclass,buff,4,0,0); nrec++;
         goto matcn;
      } else if (command->argv[0]==NULL)
	goto parse;  /* simple equals */
      else if (command->argv[1]==NULL) /* special cases */
	if (*command->argv[0]=='?') {
	  vsi4_dis(command,itask,ip);
	  return;
	} 

/* if we get this far it is a set-up command so parse it */

parse:
      ierr=0;
      ilast=0;                                      /* last argv examined */
      memcpy(&lcl,&shm_addr->vsi4,sizeof(lcl));

      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=vsi4_dec(&lcl,&count, ptr);
        if(ierr !=0 ) goto error;
      }

/* all parameters parsed okay, update common */

/*
      ichold=shm_addr->ICHK[16];
      shm_addr->ICHK[16]=0;

*/
      memcpy(&shm_addr->vsi4,&lcl,sizeof(lcl));

      if(lcl.config.set) {
	sprintf((char *) (buff+2),"!%d",lcl.config.value);
	cls_snd(&iclass,buff,4+strlen((char *) (buff+2)),0,0); nrec++;
      }
      if(lcl.pcalx.set) {
	sprintf((char *) (buff+2),"%%%X",(lcl.pcalx.value-1)%16);
	cls_snd(&iclass,buff,4+strlen((char *) (buff+2)),0,0); nrec++;
      }
      if(lcl.pcaly.set) {
	sprintf((char *) (buff+2),"(%X",(lcl.pcaly.value-1)%16);
	cls_snd(&iclass,buff,4+strlen((char *) (buff+2)),0,0); nrec++;
      }

matcn:
      if(nrec==0) {
	ierr=-301;
	goto error;
      }

      ip[0]=iclass;
      ip[1]=nrec;
      skd_run("matcn",'w',ip);
      skd_par(ip);
/*
      if (ichold != -99) {
         if (ichold >= 0)
            ichold=ichold % 1000 + 1;
	 shm_addr->ICHK[16]=ichold;
      }
*/
      if(ip[2]<0) return;
      vsi4_dis(command,itask,ip);
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"v4",2);
      return;
}
