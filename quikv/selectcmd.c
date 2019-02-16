/* Recorder select snap command */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void selectcmd(command,itask,ip)
struct cmd_ds *command;                /* parsed command structure */
int itask;
int ip[5];                           /* ipc parameters */
{
      int ilast, ierr, ichold, i, count;
      int verr;
      char *ptr;
      int lcl;

      int data_valid_dec();                 /* parsing utilities */
      char *arg_next();

      void selectcmd_dis();

      if (command->equal != '=') {           /* read module */
	  selectcmd_dis(command,ip);
	  return;
      } else if (command->argv[0]==NULL)
	goto parse;  /* simple equals */
      else if (command->argv[1]==NULL) /* special cases */
        if (*command->argv[0]=='?') {
          selectcmd_dis(command,ip);
          return;
         }

/* if we get this far it is a set-up command so parse it */

parse:
      if(shm_addr->equip.drive[0]==0||shm_addr->equip.drive[1]==0) {
	ierr=-301;
	goto error;
      }
  
      ilast=0;                                      /* last argv examined */

      lcl=shm_addr->select;

      count=1;
      while( count>= 0) {
        ptr=arg_next(command,&ilast);
        ierr=selectcmd_dec(&lcl,&count, ptr);
        if(ierr !=0 ) goto error;
      }

/* all parameters parsed okay, update common */

      shm_addr->select=lcl;

      ip[0]=ip[1]=0;
      return;

error:
      ip[0]=0;
      ip[1]=0;
      ip[2]=ierr;
      memcpy(ip+3,"se",2);
      return;
}
